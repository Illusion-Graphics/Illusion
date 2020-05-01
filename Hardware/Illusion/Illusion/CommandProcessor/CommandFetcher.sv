`include "IllusionDefines.sv"

module CommandFetcher
#(
	parameter COMMAND_BUFFER_SIZE = 64
)
(
	input bit aClock,
	input bit aReset,

	input logic [MAIN_MEMORY_BUS_ADDR_WIDTH - 1:0] aCommandPointer,
	input logic anExecute,

	output logic [MAIN_MEMORY_BUS_ADDR_WIDTH - 1:0] anOutMemoryAddr,
	input logic [MAIN_MEMORY_BUS_DEPTH - 1:0] aMemoryData,
	output logic anOutMemoryEnable,

	input logic [COMMAND_BUFFER_WIDTH - 1:0] aCommandIndex,
	output logic [MAIN_MEMORY_BUS_DEPTH - 1:0] aCommandData,
	input logic aCommandRead,

	output logic anOutReady
);

localparam COMMAND_BUFFER_WIDTH = $clog2(COMMAND_BUFFER_SIZE);

typedef enum {IDLE, FETCH, READY} State;
State state;

reg [COMMAND_BUFFER_WIDTH - 1:0] commandCounter;
wire [MAIN_MEMORY_BUS_ADDR_WIDTH - 1:0] currentMemoryRead = aCommandPointer + {{58'b0}, commandCounter};

wire bufferWrite;

// Onboard command cache
RAM_1R_1W
#(
	.DEPTH(COMMAND_DEPTH),
	.SIZE(COMMAND_BUFFER_SIZE)
)
commandBufferCache
(
	.aClock(aClock),

	.aReadAddress(aCommandIndex),
	.anOutReadData(aCommandData),
	.aReadEnable(aCommandRead),

	.aWriteAddress(commandCounter),
	.aWriteData(aMemoryData),
	.aWriteEnable(bufferWrite)
);

assign anOutReady = (state == READY);
assign anOutMemoryAddr = currentMemoryRead;

initial begin
	// Size mismatch between the bus and the command
	assert (MAIN_MEMORY_BUS_DEPTH == COMMAND_DEPTH);

	state = IDLE;
	commandCounter = 0;
end

assign anOutMemoryEnable = state == FETCH;
assign bufferWrite = state == FETCH;

always_ff @(posedge aClock)
begin
	case (state)
		IDLE, READY: begin
			if (aReset) begin
				state <= IDLE;
				commandCounter <= 0;
			end

			if (anExecute) begin
				state <= FETCH;
				commandCounter <= 0;
			end
		end
		FETCH: begin
			commandCounter <= commandCounter + 1;

			if(commandCounter == 63) begin
				state <= READY;
			end
		end
	endcase
end

endmodule // CommandFetcher
