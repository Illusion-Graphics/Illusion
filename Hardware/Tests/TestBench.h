#pragma once

#include "verilated.h"
#include <verilated_vcd_c.h>

template <class T>
class TestBench
{
public:
	TestBench(const uint aTraceDepth = 0, const char* aTraceName = nullptr)
		: myTick(0)
		, myCore(nullptr)
		, myTrace(nullptr)
	{
		myCore = new T();

		if (aTraceDepth)
		{
			myTrace = new VerilatedVcdC();

			myCore->trace(myTrace, aTraceDepth);
			myTrace->open(aTraceName);
		}
	}

	~TestBench()
	{
		if (myTrace)
		{
			myTrace->close();
			delete myTrace;
		}

		delete myCore;
	}

	void DumpTrace()
	{
		if(myTrace)
		{
			myTrace->dump(myTick++);
		}
	}

	virtual void Tick() = 0;

public:
	T* myCore;
	VerilatedVcdC* myTrace;

protected:
	uint myTick;
};
