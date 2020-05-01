module Top
(
	// General signals
	input bit aClock,
	input bit aPixelClock,
	input bit aReset,

	// Display signals
	output logic anOutHorizontalSync,
	output logic anOutVerticalSync,
	output logic anOutDisplayEnabled,
	output logic [7:0] anOutRed,
	output logic [7:0] anOutGreen,
	output logic [7:0] anOutBlue,

`ifdef IMMEDIATE_OUTPUT
	output logic [9:0] anOutX,
	output logic [9:0] anOutY
`endif // IMMEDIATE_OUTPUT
);

wire [9:0] x;
wire [9:0] y;

`ifdef IMMEDIATE_OUTPUT
	assign anOutX = x;
	assign anOutY = y;
`endif // IMMEDIATE_OUTPUT


wire frameDone;
reg frameFlipped;

wire [31:0] pixelAddress;
wire [2:0] pixelData;

Illusion illusion_inst
(
	.aClock(aClock),
	.aReset(aReset),
	.aFrameFlipped(frameFlipped),
	.anOutFrameDone(frameDone),
	.anOutPixelAddr(pixelAddress),
	.anOutPixelData(pixelData)
);

VideoSignalGenerator videoSignalGenerator_inst
(
	.aClock(aPixelClock),
	.aReset(aReset),
	.anOutHorizontalSync(anOutHorizontalSync),
	.anOutVerticalSync(anOutVerticalSync),
	.anOutDisplayEnabled(anOutDisplayEnabled),
	.anOutX(x),
	.anOutY(y)
);

wire [9:0] memX;
wire [9:0] memY;


Shaper shaper_inst
(
	.aX(x),
	.aY(y),
	.anOutMemX(memX),
	.anOutMemY(memY),
	.aPixelData(frameBufferData),
	.anOutRed(anOutRed),
	.anOutGreen(anOutGreen),
	.anOutBlue(anOutBlue)
);

/* verilator lint_off WIDTH */
wire [17:0] framebufferReadAddress = readFramebufferAddr + ((memY * 320) + memX);
/* verilator lint_on WIDTH */

wire [2:0] frameBufferData;

wire [31:0] framebuffer1Addr = 0;
wire [31:0] framebuffer2Addr = 76800;
reg currentFramebuffer;
wire [31:0] framebufferAddr = currentFramebuffer ? framebuffer1Addr : framebuffer2Addr;
wire [31:0] readFramebufferAddr = (~currentFramebuffer) ? framebuffer1Addr : framebuffer2Addr;

RAM_1R_1W
#(
	.DEPTH(3),
	.SIZE(76800 * 2) // 320*240
)
framebuffer_inst
(
	.aClock(aClock),
	.aReadAddress(framebufferReadAddress),
	.anOutReadData(frameBufferData),
	.aReadEnable(1),
	.aWriteAddress(framebufferAddr[17:0] + pixelAddress[17:0]),
	.aWriteData(pixelData),
	.aWriteEnable(!frameDone)
);

always @(posedge aClock)
begin
	if(frameDone && x == 0 && y == 0)
	begin
		frameFlipped <= 1;
		currentFramebuffer <= currentFramebuffer + 1;
	end
	else
	begin
		frameFlipped <= 0;
	end
end

endmodule // Top
