#include "TestBench.h"
#include "TestRunner.h"

#include "VPrimitiveUnit.h"

#include <random>

union Point
{
	struct
	{
		uint16_t x;
		uint16_t y;
	};
	uint32_t p;
};


class Basic : public Test, public TestBench<VPrimitiveUnit>
{
public:
	Basic() : Test("Basic"), TestBench(99, "basic.vcd") {}

	void Initialize() override
	{
		for(uint i = 0; i < 16*3*2; ++i)
		{
			myPointBuffer[i].x = i;
			myPointBuffer[i].y = i;
		}
	}

	bool Execute() override
	{
		Tick();
		Tick();

		myCore->anExecute = 1;
		myCore->aSize = 3;
		Tick();
		myCore->anExecute = 0;
		myCore->aSize = 0;

		while(!myCore->anOutReady)
		{
			Tick();

			// Requesting some data from the main bus
			if(myCore->anOutMemoryEnable == 1)
			{
				// Introduce a delay on the memory line
				std::random_device dev;
    			std::mt19937 rng(dev());
				std::uniform_int_distribution<std::mt19937::result_type> randomDelay(1,6); 
				for(uint i = 0; i < randomDelay(rng); ++i)
				{
					Tick();
				}

				myCore->aMemoryData = myPointBuffer[myCore->anOutMemoryAddr].p;
				myCore->aMemoryValid = 1;
				Tick();
				myCore->aMemoryValid = 0;
			}

			if(myCore->aWriteEnable)
			{
				myPrimitiveBuffer[myCore->aWriteAddress].p = myCore->aWriteData;
				printf("@%#08x [%#08x] \n",myCore->aWriteAddress, myCore->aWriteData);
				
				myCore->aWriteValid = 1;
				Tick();
				myCore->aWriteValid = 0;
			}
		}

		TEST_ASSERT_EQ(myPrimitiveBuffer[0].x, 2, "Min x");
		TEST_ASSERT_EQ(myPrimitiveBuffer[0].y, 2, "Min y");
		TEST_ASSERT_EQ(myPrimitiveBuffer[1].x, 0, "Max x");
		TEST_ASSERT_EQ(myPrimitiveBuffer[1].y, 0, "Max y");

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
	Point myPointBuffer[16 * 3];
	Point myPrimitiveBuffer[64 * 2];
};

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);

	TestSuite suite;
	suite.myName = "Primitive Unit";
	suite.myTests.emplace_back(new Basic());

	bool success = suite.Execute();
	suite.Stop();

	return (success ? 0 : -1);
}
