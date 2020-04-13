#include "VRasterizer.h"
#include "verilated.h"
#include <verilated_vcd_c.h>


#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"


int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);

	const int width = 58;
	const int height = 58;

	uint byteSize = width*height * 3;
	char* data = new char[byteSize];
	memset(data, 0x00, byteSize);

	VRasterizer* tb = new VRasterizer();
	VerilatedVcdC* trace = new VerilatedVcdC();
	tb->trace(trace, 99);
	trace->open("trace.vcd");

	tb->aPoint1[0] = 0;
	tb->aPoint1[1] = 0;

	tb->aPoint2[0] = 0;
	tb->aPoint2[1] = 9;

	tb->aPoint3[0] = 9;
	tb->aPoint3[1] = 9;

	for(uint i = 0; i < width * height; ++i)
	{
		tb->aX = i % width;
		tb->aY = floor(i / width);
		tb->eval();
		data[i * 3 + 0] = tb->anOutInside * 255;
		data[i * 3 + 1] = tb->anOutInside * 255;
		data[i * 3 + 2] = tb->anOutInside * 255;
		trace->dump(i);
	}

	trace->close();
	stbi_write_png("output.png", width, height, 3, data, width*3);
}
