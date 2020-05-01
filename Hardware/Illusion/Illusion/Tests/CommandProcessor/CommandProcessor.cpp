#include "TestBench.h"
#include "TestRunner.h"

#include "VCommandProcessor.h"

class SimpleCommandProcessor : public Test, public TestBench<VCommandProcessor>
{
public:
	SimpleCommandProcessor() : Test("Simple command processor"), TestBench(99, "simplecommand.vcd") {}

	void Initialize() override
	{
		memset(myCommandBuffer, 0x00, sizeof(myCommandBuffer));

		myCommandBuffer[1] = 0xffff0000;
	}

	bool Execute() override
	{
		myCore->aReset = 1;
		Tick();
		myCore->aReset = 0;
		Tick();

		myCore->aCommandPointer = 0;
		myCore->anExecute = 1;
		Tick();
		TEST_ASSERT_EQ(myCore->CommandProcessor__DOT__state, 1, "Core in fetching state");

		while (myCore->CommandProcessor__DOT__commandFetcher__DOT__state != 2)
		{ 
			myCore->anExecute = 0;
			if (myCore->anOutMemoryEnable)
			{
				myCore->aMemoryData = myCommandBuffer[myCore->anOutMemoryAddr];
			}
			Tick();
		}
		Tick();
		TEST_ASSERT_EQ(myCore->CommandProcessor__DOT__state, 2, "Core in executing state");
		Tick();
		Tick();
		Tick();
		Tick();
		Tick();

		
		return true;
	}

	void Tick() override
	{
		myCore->eval();
		DumpTrace();
		myCore->aClock = 1;
		myCore->eval();
		DumpTrace();
		myCore->aClock = 0;
	}

	void Clean() override
	{
		delete this;
	}

private:
	uint32_t myCommandBuffer[64];
};

class BasicCommandScenario : public Test, public TestBench<VCommandProcessor>
{
public:
	BasicCommandScenario() : Test("Basic command scenario"), TestBench(99, "basicscenario.vcd") {}

	void Initialize() override
	{
		Tick();
		myCore->CommandProcessor__DOT__state = 2; // Execution state for the processor
		myCore->CommandProcessor__DOT__commandFetcher__DOT__state = 2; // Ready state for the fetcher

		myCore->CommandProcessor__DOT__commandFetcher__DOT__commandBufferCache__DOT__mem[0] = 0x0001F800;
		myCore->CommandProcessor__DOT__commandFetcher__DOT__commandBufferCache__DOT__mem[1] = 0x00020000;
		myCore->CommandProcessor__DOT__commandFetcher__DOT__commandBufferCache__DOT__mem[2] = 0xffff0000;
	}

	bool Execute() override
	{
		Tick();
		TEST_ASSERT_EQ(myCore->CommandProcessor__DOT__state, 2, "Core in executing state");
		myCore->aCommandRequested = 1;
		Tick();
		Tick();
		Tick();
		TEST_ASSERT_EQ(myCore->anOutCommand, 0x0001, "Clear command");
		TEST_ASSERT_EQ(myCore->anOutCommandData, 0xF800, "Full red no alpha");
		Tick();
		TEST_ASSERT_EQ(myCore->anOutCommand, 0x0002, "Draw triangle");
		TEST_ASSERT_EQ(myCore->anOutCommandData, 0x0000, "Address 0");
		Tick();
		TEST_ASSERT_EQ(myCore->CommandProcessor__DOT__state, 0, "End of execution");
		Tick();
		Tick();

		
		return true;
	}

	void Tick() override
	{
		myCore->eval();
		DumpTrace();
		myCore->aClock = 1;
		myCore->eval();
		DumpTrace();
		myCore->aClock = 0;
	}

	void Clean() override
	{
		delete this;
	}

private:
	uint32_t myCommandBuffer[64];
};

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);

	TestSuite suite;
	suite.myName = "Command Processor";
	suite.myTests.emplace_back(new SimpleCommandProcessor());
	suite.myTests.emplace_back(new BasicCommandScenario());

	bool success = suite.Execute();
	suite.Stop();

	return (success ? 0 : -1);
}
