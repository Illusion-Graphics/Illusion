`include "Types.svh"

module Illusion
(
	input bit aClock,
	input bit aReset,

	input logic aFrameFlipped,
	output logic anOutFrameDone,

	// To framebuffer memory
	output logic [31:0] anOutPixelAddr,
	output logic [2:0] anOutPixelData,
	output logic anOutPixelWrite,

	// To central memory
	output logic [31:0] anOutMemoryAddr,
	input logic [31:0] aMemoryData,
	output logic anOutMemoryEnable,
	input logic aMemoryValid
);

// Primitive cache, used to store processed primitives
wire primitiveReadAddress;
wire primitiveReadData;
wire primitiveReadEnable;
wire primitiveWriteAddress;
wire primitiveWriteData;
wire primitiveWriteEnable;

RAM_1R_1W primitiveCache
#(
	.DEPTH(32),
	.SIZE($bits(TriangleData))
)
(
	.aClock(aClock),
	.aReadAddress(primitiveReadAddress),
	.anOutReadData(primitiveReadData),
	.aReadEnable(primitiveReadEnable),
	.aWriteAddress(primitiveWriteAddress),
	.aWriteData(primitiveWriteData),
	.aWriteEnable(primitiveWriteEnable)
)



endmodule // Illusion
