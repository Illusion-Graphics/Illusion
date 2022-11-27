`include "Types.svh"

module PrimitiveUnit
(
	input bit aClock,
	input bit aReset,

	input logic anExecute,
	input logic [7:0] aSize,
	output logic anOutReady,

	// To main memory
	output logic [31:0] anOutMemoryAddr,
	input logic [31:0] aMemoryData,
	output logic anOutMemoryEnable,
	input logic aMemoryValid,

	// To primitive cache
	output logic [31:0] aWriteAddress,
	output logic [31:0] aWriteData,
	output logic aWriteEnable,
	input logic aWriteValid
);

assign anOutReady = currentState == Ready;

reg [7:0] latchedSize;

reg [7:0] triangleCounter;
TriangleData triangleBuffer;

reg stateClock;

reg [1:0] pointCounter;
Point pointBuffer[3];

reg [2:0] writeCounter;

typedef enum {Initial, GetPointData, WaitGetPointData, GetAABB, Ready} State;
State currentState;
State nextState;

// Module declaration
TriangleAABB triangleAABB
(
	.aPoint1(pointBuffer[0]),
	.aPoint2(pointBuffer[1]),
	.aPoint3(pointBuffer[2]),
	.anOutAABB(triangleBuffer)
);

// Type check
always_comb
begin
	label: assert (`TriangleDataBlockSize == 1)
		else $error("Assertion label failed!");
end

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
	if(aReset) begin
		nextState = Initial;
	end
	else begin
		case(currentState)
			Initial, Ready: begin
				if(anExecute) begin
					nextState = GetPointData;
				end
			end
			GetPointData: begin
				nextState = WaitGetPointData;
			end
			WaitGetPointData: begin
				if(pointCounter == 3) begin
					nextState = GetAABB;
				end
				else begin
					if(aMemoryValid) begin
						nextState = GetPointData;
					end
					else begin
						nextState = WaitGetPointData;
					end
				end
			end
			GetAABB: begin
				if({29'h0, writeCounter} == `TriangleDataBlockSize && aWriteValid)
				begin
					if(triangleCounter == latchedSize) begin
						nextState = Ready;
					end
					else begin
						nextState = GetPointData;
					end
				end
			end
		endcase
	end
end

// FSM - Output block
always_ff @(posedge aClock)
begin
	case(currentState)
		Initial, Ready: begin
			pointCounter <= 0;
			triangleCounter <= 0;
			aWriteEnable <= 0;
		end
		GetPointData: begin
			/* verilator lint_off WIDTH */
			anOutMemoryAddr <= (triangleCounter * 3) + pointCounter;
			/* verilator lint_on WIDTH */
			anOutMemoryEnable <= 1;
			aWriteEnable <= 0;
			writeCounter <= 0;
		end
		WaitGetPointData: begin
			// anOutMemoryEnable = 0;
			/* verilator lint_off WIDTH */
			pointBuffer[pointCounter] <= aMemoryData;
			/* verilator lint_on WIDTH */
			if(aMemoryValid) begin
				pointCounter <= pointCounter + 1;
				anOutMemoryEnable <= 0;
			end
		end
		GetAABB: begin
			anOutMemoryEnable <= 0;
			pointCounter <= 0;
			if(aWriteValid) begin
				writeCounter <= writeCounter + 1;
				aWriteEnable <= 0;
			end
			else begin
				if({29'h0, writeCounter} == `TriangleDataBlockSize)
					triangleCounter <= triangleCounter + 1;
				else
					aWriteEnable <= 1;

			end
		end
	endcase
end

// Get the output data
always_comb
begin
	aWriteAddress = (triangleCounter * `TriangleDataBlockSize) + {29'h0, writeCounter};
	aWriteData = triangleBuffer[32 * writeCounter +: 32];
end

// Latch the inputs
always_comb
begin
	if(anExecute)
		latchedSize = aSize;
end
	
endmodule // PrimitiveUnit
