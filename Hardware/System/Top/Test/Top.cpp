#include "VTop.h"
#include "verilated.h"
#include <verilated_vcd_c.h>
#include <numeric>

using uint = unsigned int;


#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#include<iostream>

inline double SecondsToNanoseconds(const double aSeconds)
{
	return aSeconds * 10e9;
}

class Clock
{
public:
	Clock(const uint aFrequency) : myFrequency(aFrequency), myStep(SecondsToNanoseconds(1.0 / aFrequency)), myCurrentStep(0)
	{
		printf("Creating a clock %uHz (%fns)\n", myFrequency, myStep);
	}

	bool Update(const uint aStep)
	{
		myCurrentStep += aStep;
		if (myCurrentStep >= (myStep - myDelta))
		{
			myCurrentStep = 0;
		}
		else if(myCurrentStep >= ((myStep / 2) - myDelta))
		{
			return true;
		}
		return false;
	}
	
	uint GetNextClock() const
	{
		return std::min(myStep - myCurrentStep, myStep / 2);
	}

private:
	const uint myFrequency; 
	const double myStep;

	double myCurrentStep;

	const double myDelta = 1.0; // 1ns
};

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);

	uint byteSize = 640 * 480 * 3;
	char* data = new char[byteSize];
	memset(data, 0x00, byteSize);

	Clock clock48(120000000);
	Clock clock25(24000000);

	// Screen screen(640, 480);

	//800*525

	VTop *tb = new VTop();
	VerilatedVcdC* trace = new VerilatedVcdC();
	tb->trace(trace, 99);
	trace->open("trace.vcd");

	tb->Top__DOT__mainMemory__DOT__mem[0] = 0x0001C000;
	tb->Top__DOT__mainMemory__DOT__mem[2] = 0x00020000;
	// tb->Top__DOT__mainMemory__DOT__mem[2] = 0x0001C000;
	// tb->Top__DOT__mainMemory__DOT__mem[3] = 0x0001C000;
	tb->Top__DOT__mainMemory__DOT__mem[4] = 0xFFFF0000;

	// tb->Top__DOT__framebuffer_inst__DOT__mem[0] = 2;
	// tb->Top__DOT__framebuffer_inst__DOT__mem[76799] = 4;


	tb->aReset = 1;
	tb->eval();
	tb->eval();
	tb->aReset = 0;

	uint frameCounter = 0;
	long long i =0;



	bool frameFlipped = false;

	while(frameCounter < 2)
	{
		trace->dump(static_cast<uint64_t>(i));
		double step = std::min(clock48.GetNextClock(), clock25.GetNextClock());
		i += step;

		bool updateClock[2];
		updateClock[0] = clock48.Update(step);
		updateClock[1] = clock25.Update(step);

		tb->aClock = updateClock[0];
		tb->aPixelClock = updateClock[1];
		tb->eval();

		if(tb->anOutDisplayEnabled)
		{
			data[(tb->anOutX + tb->anOutY * 640) * 3 + 0] = tb->anOutRed;
			data[(tb->anOutX + tb->anOutY * 640) * 3 + 1] = tb->anOutGreen;
			data[(tb->anOutX + tb->anOutY * 640) * 3 + 2] = tb->anOutBlue;
		}

		// Screen::Signals signals;
		// signals.myHSync = tb->anOutHorizontalSync;
		// signals.myVSync = tb->anOutVerticalSync;
		// signals.myRGB[0] = tb->anOutRed;
		// signals.myRGB[1] = tb->anOutGreen;
		// signals.myRGB[2] = tb->anOutBlue;
		// screen.Update(signals);
		if(tb->Top__DOT__frameFlipped && !frameFlipped)
		{
			printf("Frame flipped!\n");
			char filename[256];
			sprintf(filename, "frame-%u.png", frameCounter);

			frameCounter++;
			stbi_write_png(filename, 640, 480, 3, data, 640 * 3);
			frameFlipped = true;
		}
		else if(frameFlipped && !updateClock[0])
		{
			frameFlipped = false;
		}
	}
	trace->close();
	// stbi_write_png("pattern.png", 640, 480, 3, data, 640 * 3);
}
