module ManagementUnit
(
	input bit aClock,
	input bit aReset,

	// Control signals
	input logic anExecute,
	input logic [31:0] aCommandBufferAddress,

	// To main memory
	output logic [31:0] anOutMemoryAddr,
	input logic [31:0] aMemoryData,
	output logic anOutMemoryEnable,
	input logic aMemoryValid
);

typedef enum {Initial, ReadCommand, WaitReadCommand, ExecuteCommand, WaitExecuteCommand} State;
State currentState;
State nextState;

wire logic executionDone;

reg [7:0] commandCounter;

// FSM - State block
always_ff @(posedge aClock, posedge aReset)
begin
	if(aReset) begin
		currentState <= Initial;
	end
	else begin
		currentState <= nextState;
	end
end

// FSM - Next state block
always_comb
begin
	case(currentState)
		Initial: begin
			if(anExecute) begin
				nextState = ReadCommand;
			end
			else begin
				nextState = Initial;
			end
		end
		ReadCommand: begin
			nextState = WaitReadCommand;
		end
		WaitReadCommand: begin
			if(aMemoryValid) begin
				nextState = ExecuteCommand;
			end
			else begin
				nextState = WaitReadCommand;
			end
		end
		ExecuteCommand: begin
			nextState = WaitExecuteCommand;
		end
		WaitExecuteCommand: begin
			if(executionDone) begin
				nextState = ReadCommand;
			end
			else begin
				nextState = WaitExecuteCommand;
			end
		end
	endcase
end

// FSM - Output block
always_comb
begin
	case(currentState)
		Initial: begin
			commandCounter = 0;
		end
		ReadCommand: begin
			anOutMemoryEnable = 1;

		end
		ExecuteCommand: begin
			anOutMemoryEnable = 0;
		end
	endcase
end
	
endmodule // ManagementUnit
