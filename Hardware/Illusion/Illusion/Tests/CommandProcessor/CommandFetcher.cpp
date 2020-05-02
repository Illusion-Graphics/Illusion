#include "TestBench.h"
#include "TestRunner.h"

#include "VCommandFetcher.h"

class SimpleCommandFetch : public Test, public TestBench<VCommandFetcher>
{
public:
	SimpleCommandFetch() : Test("Simple command fetch"), TestBench(99, "simplefetch.vcd") {}

	void Initialize() override
	{
		for (uint i = 0; i < 64; ++i)
		{
			commandBuffer[i] = i;
		}
	}

	bool Execute() override
	{
		Tick();

		myCore->anExecute = 1;
		myCore->aCommandPointer = 0;

		uint clockBeforeReady = 0;
		while (!myCore->anOutReady)
		{ 
			Tick();
			clockBeforeReady++;

			myCore->anExecute = 0;

			if (myCore->anOutMemoryEnable)
			{
				myCore->aMemoryData = commandBuffer[myCore->anOutMemoryAddr];
			}

			if (clockBeforeReady > 65)
			{
				TEST_ASSERT(false, "Ready state not reached in time")
				return false;
			}
		}
		TEST_ASSERT(true, "Ready state reached")

		Tick();
		Tick();

		myCore->aCommandIndex = 0;
		myCore->aCommandRead = 1;

		Tick();

		TEST_ASSERT_EQ(myCore->aCommandData, commandBuffer[0], "Command Stored");

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
	uint32_t commandBuffer[64];
};

class DoubleCommandFetch : public Test, public TestBench<VCommandFetcher>
{
public:
	DoubleCommandFetch() : Test("Double command fetch"), TestBench(99, "doublefetch.vcd") {}

	void Initialize() override
	{
		for (uint i = 0; i < 128; ++i)
		{
			commandBuffer[i] = i;
		}
		commandBuffer[0] = 99;
	}

	bool Execute() override
	{
		// First fetch from address 0
		{
			myCore->anExecute = 1;
			myCore->aCommandPointer = 0;

			uint clockBeforeReady = 0;
			while (!myCore->anOutReady)
			{ 
				Tick();
				clockBeforeReady++;

				myCore->anExecute = 0;

				if (myCore->anOutMemoryEnable)
				{
					myCore->aMemoryData = commandBuffer[myCore->anOutMemoryAddr];
				}

				if (clockBeforeReady > 65)
				{
					TEST_ASSERT(false, "Ready state not reached in time")
					return false;
				}
			}
			TEST_ASSERT(true, "Ready state reached")
			Tick();
			myCore->aCommandIndex = 0;
			myCore->aCommandRead = 1;
			Tick();
			TEST_ASSERT_EQ(myCore->aCommandData, commandBuffer[0], "Command Stored");

			myCore->aCommandRead = 0;
		}

		TEST_ASSERT(myCore->anOutReady, "Fetcher still ready")

		// Second fetch from address 64
		{
			myCore->anExecute = 1;
			myCore->aCommandPointer = 64;

			Tick();
			TEST_ASSERT(!myCore->anOutReady, "Fetcher no longer ready")

			uint clockBeforeReady = 0;
			while (!myCore->anOutReady)
			{ 

				myCore->anExecute = 0;

				if (myCore->anOutMemoryEnable)
				{
					myCore->aMemoryData = commandBuffer[myCore->anOutMemoryAddr];
				}
				
				Tick();
				clockBeforeReady++;

				if (clockBeforeReady > 65)
				{
					TEST_ASSERT(false, "Ready state not reached in time")
					return false;
				}
			}
			TEST_ASSERT(true, "Ready state reached")
			Tick();
			myCore->aCommandIndex = 0;
			myCore->aCommandRead = 1;
			Tick();
			TEST_ASSERT_EQ(myCore->aCommandData, commandBuffer[64], "Command Stored");
		}

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
	uint32_t commandBuffer[128];
};

class PreInitializeSample : public Test, public TestBench<VCommandFetcher>
{
public:
	PreInitializeSample() : Test("Pre-initialization sample") {}

	void Initialize() override
	{
		// Initial clock tick is required
		Tick();

		// Put in ready state and fill the cache
		myCore->CommandFetcher__DOT__state = 2; 
		memset(myCore->CommandFetcher__DOT__commandBufferCache__DOT__mem, 0x01, sizeof(uint32_t) * 64);
	}

	bool Execute() override
	{
		Tick();
		TEST_ASSERT(myCore->anOutReady, "Core ready");

		myCore->aCommandIndex = 0;
		myCore->aCommandRead = 1;

		Tick();

		TEST_ASSERT_EQ(myCore->aCommandData, 0x01010101, "Command Stored");

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
};

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);

	TestSuite suite;
	suite.myName = "Command Fetcher";
	suite.myTests.emplace_back(new SimpleCommandFetch());
	suite.myTests.emplace_back(new DoubleCommandFetch());
	suite.myTests.emplace_back(new PreInitializeSample());

	bool success = suite.Execute();
	suite.Stop();

	return (success ? 0 : -1);
}
