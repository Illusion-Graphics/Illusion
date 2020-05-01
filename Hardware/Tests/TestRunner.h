#pragma once

#include <vector>
#include <functional>
#include <string>

#define KNRM  "\x1B[0m"
#define KRED  "\x1B[31m"
#define KGRN  "\x1B[32m"
#define KYEL  "\x1B[33m"
#define KBLU  "\x1B[34m"
#define KMAG  "\x1B[35m"
#define KCYN  "\x1B[36m"
#define KWHT  "\x1B[37m"

namespace TestUtils
{
	void LogError(const char* aMessage)
	{
		printf("\t\t[%sError%s] %s\n", KRED, KNRM, aMessage);
	}
	void LogSuccess(const char* aMessage)
	{
		printf("\t\t[%sSUCCESS%s] %s\n", KGRN, KNRM, aMessage);
	}
}

#define POKE(variable) {					\
	printf("\t\t%s: %u\n", #variable, variable);	\
}											\

#define TEST_ASSERT(condition, test) {		\
	if (condition)							\
	{										\
		TestUtils::LogSuccess(test);		\
	}										\
	else									\
	{										\
		TestUtils::LogError(test);			\
		return false;						\
	}										\
}

#define TEST_ASSERT_NOTEQ(op1, op2, test) {	\
	if (op1 != op2)							\
	{										\
		TestUtils::LogSuccess(test);		\
	}										\
	else									\
	{										\
		std::string message = test;			\
		message += " expected: " + std::to_string(op2);	\
		message += " got: " + std::to_string(op1);		\
		TestUtils::LogError(message.c_str());			\
		return false;						\
	}										\
}

#define TEST_ASSERT_EQ(op1, op2, test) {	\
	if (op1 == op2)							\
	{										\
		TestUtils::LogSuccess(test);		\
	}										\
	else									\
	{										\
		std::string message = test;			\
		message += " expected: " + std::to_string(op2);	\
		message += " got: " + std::to_string(op1);		\
		TestUtils::LogError(message.c_str());			\
		return false;						\
	}										\
}

class Test
{
public:
	Test(const std::string& aName) : myName(aName) {}

	virtual void Initialize() = 0;
	virtual bool Execute() = 0;
	virtual void Clean() = 0;

public:
	std::string myName;
	bool myState;
};

class TestSuite
{
public:
	bool Execute()
	{
		// Run the initialization sequences
		for (Test* test : myTests)
		{
			test->Initialize();
		}

		bool testFailed = false;
		uint testFailedCounter = 0;


		printf("----------\n");
		printf("Running test suite [%s]\n", myName.c_str());

		for (Test* test : myTests)
		{
			printf("\tRunning test: %s\n", test->myName.c_str());
			bool testResult = test->Execute();
			testFailedCounter += testResult ? 0 : 1;
			if (testResult)
			{
				printf("\tTest %s [%sSUCCEEDED%s]\n", test->myName.c_str(), KGRN, KNRM);
			}
			else
			{
				printf("\tTest %s [%sFAILED%s]\n", test->myName.c_str(), KRED, KNRM);
			}
		}

		printf("Finished running test suite [%s] %lu/%lu\n", myName.c_str(), myTests.size() - testFailedCounter, myTests.size());

		return testFailedCounter == 0;
	}

	bool Stop()
	{
		
		for (Test* test : myTests)
		{
			test->Clean();
		}
	}

public:
	std::string myName;
	std::vector<Test*> myTests;
};
