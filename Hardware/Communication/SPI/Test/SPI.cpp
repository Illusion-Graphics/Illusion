#include "VSPI.h"
#include "verilated.h"
#include <verilated_vcd_c.h>

using uint = unsigned int;
using Packet = uint16_t;

uint traceCounter;

VSPI* tb;
VerilatedVcdC* trace;

void TransmitBit(const bool aBit)
{
	tb->aMOSI = aBit;
	tb->aSCK = 1;
	tb->eval();
	trace->dump(traceCounter++);
	tb->aSCK = 0;
	tb->eval();
	trace->dump(traceCounter++);
}

void TransmitByte(const Packet aPacket)
{
	tb->aCS = 1;

	for(uint i = 0; i < 16; ++i)
	{
		TransmitBit((aPacket >> i) & 0x01);
	}

	tb->aCS = 0;
	tb->eval();
	trace->dump(traceCounter++);
}

int main(int argc, char** argv)
{
	traceCounter = 0;

    Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);

	tb = new VSPI();
	trace = new VerilatedVcdC();
	tb->trace(trace, 99);
	trace->open("trace.vcd");


	TransmitByte(0xffff);
	tb->eval();
	trace->dump(traceCounter++);
	TransmitByte(0x0001);
	tb->eval();
	trace->dump(traceCounter++);
	TransmitByte(0x4242);
	tb->eval();
	trace->dump(traceCounter++);
	tb->aDataRead = 1;
	tb->eval();
	trace->dump(traceCounter++);
	tb->aDataRead = 0;
	tb->eval();
	trace->dump(traceCounter++);
	tb->aDataRead = 1;
	tb->eval();
	trace->dump(traceCounter++);
	tb->aDataRead = 0;
	tb->eval();
	trace->dump(traceCounter++);
	tb->aDataRead = 1;
	tb->eval();
	trace->dump(traceCounter++);
	tb->aDataRead = 0;
	tb->eval();
	trace->dump(traceCounter++);
	tb->aDataRead = 1;
	tb->eval();
	trace->dump(traceCounter++);
	tb->aDataRead = 0;
	tb->eval();
	trace->dump(traceCounter++);
	tb->eval();
	trace->dump(traceCounter++);
	tb->eval();
	trace->dump(traceCounter++);
	tb->eval();
	trace->dump(traceCounter++);

	trace->close();
}
