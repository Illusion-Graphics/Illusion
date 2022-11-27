module Bridge
(
	input bit aClock,

	// Data bus
	input logic [15:0] anInterface,
	output logic [15:0] anOutInterface,

	// Flags
	input bit aDirection,
	input bit aTransmission,
	output reg aRequest,
	output reg anAcknowledge,
	input bit anAcknowledgeMaster,
	input bit [2:0] aCategory
);

typedef enum  {IDLE, RECEIVE, WAIT_FOR_BUS, TRANSMIT} State;

typedef enum bit {WRITE = 0, READ = 1} BusDirection;
typedef enum bit [2:0] {SYSTEM = 3'b000, ADDRESS = 3'b001, DEBUG = 3'b100, STAT = 3'b101} Category;

BusDirection direction = aDirection;
Category category = aCategory;

reg [15:0] data;
reg [15:0] dataOutBuffer;

wire transmissionInProgress = state == TRANSMIT;
assign anOutInterface = transmissionInProgress ? dataOutBuffer : 0;

State state;

initial begin
	state = IDLE;
	transmissionInProgress = 0;
	aRequest = 0;
	anAcknowledge = 0;
end

always @(posedge aClock) begin
	case(state)
		IDLE: begin
			if(aTransmission) begin
				state <= RECEIVE;
			end
		end

		RECEIVE: begin
			data <= anInterface;
			anAcknowledge <= 1;

			if(aDirection == READ) begin
				aRequest <= 1;
				state <= WAIT_FOR_BUS;
			end
			else begin
				state <= IDLE;
			end
		end

		WAIT_FOR_BUS: begin
			if(aTransmission == 0) begin
				state <= TRANSMIT;
			end
		end

		TRANSMIT: begin
			if(anAcknowledgeMaster) begin
				state <= IDLE;
				aRequest <= 0;
			end
			else begin
				anAcknowledge <= 0;
				dataOutBuffer <= 42;
			end
		end

	endcase
end

endmodule // Bridge
