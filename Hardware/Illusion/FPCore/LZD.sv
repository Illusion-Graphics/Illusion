module LZD2
(
	input aB0,
	input aB1

	output anOutValid,
	output anOutPosition
);

assign anOutPosition = aB1;
assign anOutValid = aB0 | aB1;

endmodule // LZD2

module LZD4
(
	input aValid0,
	input aPosition0,
	input aValid1,
	input aPosition1,

	output anOutValid,
	output [0:0] anOutPosition
);

assign anOutValid = aValid0 | aValid1;
assign anOutPosition[1] = ~aValid0;
assign anOutPosition[0] = aValid0 ? aPosition0 : aPosition1;

endmodule // LZD4
