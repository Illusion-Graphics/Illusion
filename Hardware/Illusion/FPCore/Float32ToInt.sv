`include "Types.svh"

module Float32ToInt
(
	input Float32 anInput,
	output Int32 anOutput
);
/* verilator lint_off WIDTH */

integer signed exp = anInput.Exponent - 127;
integer shift = 23 - exp;
integer number;

always_comb
begin
	if (anInput.Exponent == 8'h00)
	begin
		anOutput.Sign = 0;
		anOutput.Number = 0;
	end
	else
	begin
		anOutput.Sign = exp > 0 ? anInput.Sign : 0;
		number = anInput.Mantissa >> shift;
		number[exp] = 1'b1;
		anOutput.Number = anInput.Sign ? -number : number;
	end
/* verilator lint_on WIDTH */
end

endmodule // IntToFloat32
