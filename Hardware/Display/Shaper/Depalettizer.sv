module Depalettizer
(
	input logic [2:0] aPalleteID,

	output logic [7:0] anOutRed,
	output logic [7:0] anOutGreen,
	output logic [7:0] anOutBlue
);

reg [23:0] palette [8];

initial
begin
	palette[0] = 24'h000000; // 0: White
	palette[1] = 24'hffffff; // 1: Black
	palette[2] = 24'hff0000; // 2: Red
	palette[3] = 24'h00ff00; // 3: Green
	palette[4] = 24'h0000ff; // 4: Blue
end

assign anOutRed = palette[aPalleteID][23:16];
assign anOutGreen = palette[aPalleteID][15:8];
assign anOutBlue = palette[aPalleteID][7:0];

endmodule
