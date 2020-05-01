`include "IllusionDefines.sv"

module CommandProcessor
(
	input bit aClock,
	input bit aReset,

	input logic [MAIN_MEMORY_BUS_ADDR_WIDTH - 1:0] aCommandPointer,
	input logic anExecute,

	output logic [MAIN_MEMORY_BUS_ADDR_WIDTH - 1:0] anOutMemoryAddr,
	input logic [MAIN_MEMORY_BUS_DEPTH - 1:0] aMemoryData,
	output logic anOutMemoryEnable,

	input logic aCommandRequested,
	output CommandOperands anOutCommand,
	output logic [15:0] anOutCommandData
);

typedef enum  {IDLE, FETCHING, EXECUTING} State;
State state;

wire fetcherReady;
CommandFetcher commandFetcher
(
	.aClock(aClock),
	.aReset(aReset),

	.aCommandPointer(aCommandPointer),
	.anExecute(anExecute),

	.anOutMemoryAddr(anOutMemoryAddr),
	.aMemoryData(aMemoryData),
	.anOutMemoryEnable(anOutMemoryEnable),

	.aCommandIndex(commandPointer),
	.aCommandData(command),
	.aCommandRead(commandRead),

	.anOutReady(fetcherReady)
);

reg [$clog2(64) - 1:0] commandPointer;
wire [MAIN_MEMORY_BUS_DEPTH - 1:0] command;
wire commandRead;

initial begin
	state = IDLE;
	commandPointer = -1;
end

always_ff @(posedge aClock)
begin
	case (state)
		IDLE: begin
			commandPointer <= -1;
			commandRead <= 0;

			if (anExecute) begin
				state <= FETCHING;
			end
		end
		FETCHING: begin
			if(fetcherReady) begin
				state <= EXECUTING;
			end
		end
		EXECUTING: begin
			if (aCommandRequested) begin
				commandRead <= 1;
				commandPointer <= commandPointer + 1;
				case (CommandOperands'(command[31:16]))
					COMMAND_OP_END: begin
						state <= IDLE;
					end
					default: begin
						anOutCommand <= CommandOperands'(command[31:16]);
						anOutCommandData <= command[15:0];
					end
				endcase
			end
			else begin
				commandRead <= 0;
			end
		end
	endcase
end

endmodule // CommandProcessor
