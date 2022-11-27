`include "Types.svh"

module Multiplication
(
	input Float32 anInput1,
	input Float32 anInput2,

	output Float32 anOutput
);

wire [35:0] tempMantissa;

always_comb
begin
	anOutput.Sign = anInput1.Sign ^ anInput2.Sign;
	anOutput.Exponent = anInput1.Exponent + anInput2.Exponent;

	tempMantissa = anInput1.Mantissa + anInput2.Mantissa
end

endmodule // Multiplication
