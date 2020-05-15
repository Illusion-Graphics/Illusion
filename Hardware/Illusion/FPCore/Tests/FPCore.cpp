#include "TestBench.h"
#include "TestRunner.h"

#include "VFPCore.h"

union UglyCast
{
	UglyCast(uint32_t& aBinary)
	{
		u = aBinary;
	}
	
	UglyCast(float aBinary)
	{
		f = aBinary;
	}

	float f;
	int32_t u;
};

class FloatToInteger : public Test, public TestBench<VFPCore>
{
public:
	FloatToInteger() : Test("Float to integer"), TestBench(99, "f2i.vcd") {}

	void Initialize() override
	{
		myCore->aCommand = 1;
	}

	bool Execute() override
	{
		for(const float val : myTestValues)
		{
			myCore->anInput1 = static_cast<UglyCast>(val).u;
			Tick();
			TEST_ASSERT_EQ(myCore->anOutput, static_cast<int32_t>(val), std::to_string(val).c_str());
		}

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

private:
	std::vector<float> myTestValues = {2.5f, 42.1f, 42.9f, -42.1f, -42.9f, 0.5f, -0.5f, 0.0f};
};

class IntegerToFloat : public Test, public TestBench<VFPCore>
{
public:
	IntegerToFloat() : Test("Integer to float"), TestBench(99, "i2f.vcd") {}

	void Initialize() override
	{
		myCore->aCommand = 2;
	}

	bool Execute() override
	{
		for(const int16_t val : myTestValues)
		{
			myCore->anInput1 = val;
			Tick();
			TEST_ASSERT_EQ(static_cast<UglyCast>(myCore->anOutput).f, static_cast<float>(val), std::to_string(val).c_str());
		}

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

private:
	std::vector<int16_t> myTestValues = {2, 42, -42, 0};
};

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);

	TestSuite suite;
	suite.myName = "Command Fetcher";
	suite.myTests.emplace_back(new FloatToInteger());
	suite.myTests.emplace_back(new IntegerToFloat());

	bool success = suite.Execute();
	suite.Stop();

	return (success ? 0 : -1);
}
