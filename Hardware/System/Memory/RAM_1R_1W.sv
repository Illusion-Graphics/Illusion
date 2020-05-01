module RAM_1R_1W
#(
	parameter DEPTH = 8,
	parameter SIZE = 16
)
(
	input bit aClock,

	input logic [ADDR_WIDTH - 1:0] aReadAddress,
	output logic [DEPTH - 1:0] anOutReadData,
	input logic aReadEnable,

	input logic [ADDR_WIDTH - 1:0] aWriteAddress,
	input logic [DEPTH - 1:0] aWriteData,
	input logic aWriteEnable
);

localparam ADDR_WIDTH = $clog2(SIZE);

reg [DEPTH - 1:0] mem [SIZE];


// Write
always_ff @(posedge aClock)
begin
	if (aWriteEnable)
	begin
		mem[aWriteAddress] <= aWriteData;
	end
end

// Read
always_ff @(posedge aClock)
begin
	if (aReadAddress == aWriteAddress && aReadEnable && aWriteEnable) begin
		// Read and write at the same address, just bridge
		anOutReadData <= aWriteData;
	end
	else if (aReadEnable) begin
		anOutReadData <= mem[aReadAddress];
	end
	else begin
		anOutReadData <= {DEPTH{1'b0}};
	end
end

endmodule
