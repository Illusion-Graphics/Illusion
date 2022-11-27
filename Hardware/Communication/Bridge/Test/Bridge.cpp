#include "VBridge.h"
#include "verilated.h"
#include <verilated_vcd_c.h>

using uint = unsigned int;

uint traceCounter;

void Clock(VBridge* aTb, VerilatedVcdC* aTrace)
{
	aTb->aClock = 0;
	aTb->eval();
	aTrace->dump(traceCounter++);
	aTb->aClock = 1;
	aTb->eval();
	aTrace->dump(traceCounter++);
	aTb->aClock = 0;
	aTb->eval();
	aTrace->dump(traceCounter++);
}

const char DirectionBit = 0x01;
const char TransmissionBit = 0x02;
const char RequestBit = 0x04;
const char AcknowledgeBit = 0x08;
const char AcknowledgeMasterBit = 0x10;
const char CategoryBit = 0xe0;

int main(int argc, char** argv)
{
	traceCounter = 0;

    Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);

	VBridge* tb = new VBridge();
	VerilatedVcdC* trace = new VerilatedVcdC();
	tb->trace(trace, 99);
	trace->open("trace.vcd");

	Clock(tb, trace);
	Clock(tb, trace);

	tb->aDirection = 1;
	tb->aTransmission = 1;
	tb->anInterface = 0x0001;

	do {
		Clock(tb, trace);
	} while(!tb->anAcknowledge);

	do {
		Clock(tb, trace);
	} while(!tb->aRequest);

	tb->aTransmission = 0;

	do {
		Clock(tb, trace);
	} while(tb->anAcknowledge);

	uint data = tb->anOutInterface;

	Clock(tb, trace);

	tb->anAcknowledgeMaster = 1;
	Clock(tb, trace);
	tb->anAcknowledgeMaster = 0;
	Clock(tb, trace);
	Clock(tb, trace);
	Clock(tb, trace);

	printf("Data received: %u\n", data);

	trace->close();
}
