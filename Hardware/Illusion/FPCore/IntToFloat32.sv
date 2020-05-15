`include "Types.svh"

module IntToFloat32
(
	input Int16 anInput,
	output Float32 anOutput
);

wire [31:0] index;
wire Int16 number = anInput.Sign ? -anInput : anInput;

always_comb
begin

	if (anInput.Number == 0)
	begin
		anOutput.Sign = 0;
		anOutput.Exponent = 0;
		anOutput.Mantissa = 0;
	end
	else
	begin
		for (integer i = 0; i < 15; i = i + 1)
		begin
			if (number.Number[i])
			begin
				index = i;
			end
		end
/* verilator lint_off WIDTH */
		anOutput.Sign = anInput.Sign;
		anOutput.Exponent = 127 + index;
		anOutput.Mantissa = number.Number << (23 - index);
/* verilator lint_on WIDTH */
	end


end

endmodule // IntToFloat32
