`include "Types.svh"
`include "Defines.svh"

module FPCore
(
	input Commands aCommand,
	input [31:0] anInput1,
	input [31:0] anInput2,

	output [31:0] anOutput
);

wire [31:0] f32toi32_out;
Float32ToInt Float32ToInt_inst
(
	.anInput(anInput1),
	.anOutput(f32toi32_out)
);

wire [31:0] i32tof32_out;
IntToFloat32 IntToFloat32_inst
(
	.anInput(anInput1[15:0]),
	.anOutput(i32tof32_out)
);


always_comb
begin
	case (aCommand)
		COMMAND_OP_FLOAT_INT: begin
			anOutput = f32toi32_out;
		end
		COMMAND_OP_INT_FLOAT: begin
			anOutput = i32tof32_out;
		end
	endcase
end

endmodule // FPCore
