module Shaper
#(
	parameter WIDTH = 640,
	parameter HEIGHT = 480
)
(
	input logic [9:0] aX,
	input logic [9:0] aY,

	output logic [9:0] anOutMemX,
	output logic [9:0] anOutMemY,

	input logic [2:0] aPixelData,

	output logic [7:0] anOutRed,
	output logic [7:0] anOutGreen,
	output logic [7:0] anOutBlue
);

Depalettizer depalletizer_inst(.aPalleteID(aPixelData), .anOutRed(anOutRed), .anOutGreen(anOutGreen), .anOutBlue(anOutBlue));

assign anOutMemX = aX / 2;
assign anOutMemY = aY / 2;

endmodule  // Shaper
