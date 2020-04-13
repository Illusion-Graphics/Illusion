module Memory
#(
	parameter DEPTH = 8
	, parameter SIZE = 16
)
(
	input bit aClock

	, input logic [ADDR_WIDTH - 1:0] aReadAddress
	, output logic [DEPTH - 1:0] anOutReadData

	, input logic [ADDR_WIDTH - 1:0] aWriteAddress
	, input logic [DEPTH - 1:0] aWriteData
	, input logic aWriteEnable
);

localparam ADDR_WIDTH = $clog2(SIZE);

reg [DEPTH - 1:0] mem [SIZE];

assign anOutReadData = mem[aReadAddress];

always @(posedge aClock)
begin
	if(aWriteEnable)
	begin
		mem[aWriteAddress] <= aWriteData;
	end
end

endmodule
