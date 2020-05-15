#include "TestBench.h"
#include "TestRunner.h"

#include "VIntToFloat32.h"

union UglyCast
{
	UglyCast(uint32_t& aBinary)
	{
		u = aBinary;
	}

	float f;
	uint32_t u;
};

class IntegerToFloat : public Test, public TestBench<VIntToFloat32>
{
public:
	IntegerToFloat() : Test("Integer to float"), TestBench(99, "int2float.vcd") {}

	void Initialize() override
	{
	}

	bool Execute() override
	{
		myCore->anInput = -2;
		Tick();
		TEST_ASSERT_EQ(static_cast<UglyCast>(myCore->anOutput).f, -2.0f, "-2");
		myCore->anInput = 42;
		Tick();
		TEST_ASSERT_EQ(static_cast<UglyCast>(myCore->anOutput).f, 42.0f, "42");
		myCore->anInput = 0;
		Tick();
		TEST_ASSERT_EQ(static_cast<UglyCast>(myCore->anOutput).f, 0.0f, "0");
		return true;
	}

	void Tick() override
	{
		myCore->eval();
		DumpTrace();
	}

	void Clean() override
	{
		delete this;
	}
};

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);

	TestSuite suite;
	suite.myName = "Command Fetcher";
	suite.myTests.emplace_back(new IntegerToFloat());

	bool success = suite.Execute();
	suite.Stop();

	return (success ? 0 : -1);
}
