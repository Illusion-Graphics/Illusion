`include "Types.svh"

module Illusion
(
	input bit aClock,
	input bit aReset,

	input logic aFrameFlipped,
	output logic anOutFrameDone,

	// To framebuffer memory
	output logic [31:0] anOutPixelAddr,
	output logic [2:0] anOutPixelData,
	output logic anOutPixelWrite,

	// To central memory
	output logic [MAIN_MEMORY_BUS_ADDR_WIDTH - 1:0] anOutMemoryAddr,
	input logic [MAIN_MEMORY_BUS_DEPTH - 1:0] aMemoryData,
	output logic anOutMemoryEnable
);

localparam RENDERING_WIDTH = 320;
localparam RENDERING_HEIGHT = 240;

typedef enum {IDLE, WAITING_COMMAND_PROCESSOR, EXECUTING_COMMAND, GENERATE_TRIANGLE_AABB, PREPARE_RASTERIZE, RASTERIZE, CLEAR_COLOR} States;
States state;

reg [10:0] x;
reg [10:0] y;

wire commandRequested;
wire [15:0] command;
wire [15:0] commandData;
wire commandProcessorReady;

wire executeCommandList;

CommandProcessor commandProcessor
(
	.aClock(aClock),
	.aReset(aReset),

	.aCommandPointer(0),
	.anExecute(executeCommandList),

	.anOutMemoryAddr(anOutMemoryAddr),
	.aMemoryData(aMemoryData),
	.anOutMemoryEnable(anOutMemoryEnable),

	.aCommandRequested(commandRequested),
	.anOutCommand(command),
	.anOutCommandData(commandData),
	.anOutReady(commandProcessorReady)
);


initial
begin
	state = IDLE;

	x = 0;
	y = 0;
	anOutFrameDone = 0;

	// Number of triangles
	triangleCache[0] = 2;
	
	// Triangle 1
	// Point 1
	triangleCache[1] = 100;
	triangleCache[2] = 100;
	// Point 2
	triangleCache[3] = 100;
	triangleCache[4] = 110;
	// Point 3
	triangleCache[5]= 80;
	triangleCache[6] = 110;
	
	// Triangle 2
	// Point 1
	triangleCache[7] = 225;
	triangleCache[8] = 15;
	// Point 2
	triangleCache[9] = 200;
	triangleCache[10] = 22;
	// Point 3
	triangleCache[11]= 180;
	triangleCache[12] = 225;
end


/* verilator lint_off WIDTH */
assign anOutPixelAddr = x + (y * RENDERING_WIDTH);
/* verilator lint_on WIDTH */


localparam MAX_NUM_TRIANGLE = 32;
localparam POINT_SIZE = 2;
localparam TRIANGLE_SIZE =  POINT_SIZE * 3;
localparam AABB_SIZE = 4;
localparam TRIANGLE_CACHE_SIZE = 1 + TRIANGLE_SIZE * MAX_NUM_TRIANGLE + AABB_SIZE * MAX_NUM_TRIANGLE;
localparam TRIANGLE_CACHE_WIDTH = $clog2(TRIANGLE_CACHE_SIZE);

localparam TRIANGLE_DATA_ADDR = 1;
localparam AABB_DATA_ADDR = 1 + TRIANGLE_SIZE * MAX_NUM_TRIANGLE;

reg [10:0] triangleCache [TRIANGLE_CACHE_SIZE];
TriangleData triangleDataCache [512];
reg [8:0] triangleCounter;

wire [10:0] point1 [2];
wire [10:0] point2 [2];
wire [10:0] point3 [2];


assign point1[0] = triangleCache[TRIANGLE_DATA_ADDR + triangleCounter * TRIANGLE_SIZE + 0];
assign point1[1] = triangleCache[TRIANGLE_DATA_ADDR + triangleCounter * TRIANGLE_SIZE + 1];
assign point2[0] = triangleCache[TRIANGLE_DATA_ADDR + triangleCounter * TRIANGLE_SIZE + 2];
assign point2[1] = triangleCache[TRIANGLE_DATA_ADDR + triangleCounter * TRIANGLE_SIZE + 3];
assign point3[0] = triangleCache[TRIANGLE_DATA_ADDR + triangleCounter * TRIANGLE_SIZE + 4];
assign point3[1] = triangleCache[TRIANGLE_DATA_ADDR + triangleCounter * TRIANGLE_SIZE + 5];

wire TriangleData triangleData;
TriangleAABB triangleAABB_inst
(
	.aPoint1(point1),
	.aPoint2(point2),
	.aPoint3(point3),
	.anOutAABB(triangleData)
);

wire rasterizerOutput;
wire writePixel;
reg [2:0] pixelOut;

Rasterizer rasterizer_inst
(
	.aX(x),
	.aY(y),
	.aPoint1(point1),
	.aPoint2(point2),
	.aPoint3(point3),
	.anOutInside(rasterizerOutput)
);

assign anOutPixelWrite = (state == RASTERIZE ? rasterizerOutput : writePixel);
assign anOutPixelData = (state == RASTERIZE ? 2 : pixelOut);

assign commandRequested = (state == EXECUTING_COMMAND);

always @(posedge aClock)
begin
	writePixel <= 1;

	if(aFrameFlipped) begin
		anOutFrameDone = 0;
	end

	if(aReset) begin
		x = 0;
		y = 0;
		state = IDLE;
	end
	else begin
		case(state)
			IDLE: begin
				x = 0;
				y = 0;
				triangleCounter = 0;

				if (!anOutFrameDone) begin
					state = WAITING_COMMAND_PROCESSOR;
					executeCommandList <= 1;
				end
			end

			WAITING_COMMAND_PROCESSOR: begin
				executeCommandList <= 0;

				if (commandProcessorReady) begin
					state = EXECUTING_COMMAND;
				end
			end

			EXECUTING_COMMAND: begin
				if (!commandProcessorReady) begin
					anOutFrameDone = 1;
					state = IDLE;
				end
				else begin
					case (command)
						16'h0001: begin
							state = CLEAR_COLOR;
							pixelOut <= commandData[15:13];
						end
						16'h0002: begin
							state = GENERATE_TRIANGLE_AABB;
						end
					endcase
				end
			end

			GENERATE_TRIANGLE_AABB: begin
				/* verilator lint_off WIDTH */
				if(triangleCounter < triangleCache[0]) begin
				/* verilator lint_on WIDTH */
					triangleDataCache[triangleCounter] = triangleData;

					triangleCounter = triangleCounter + 1;
				end
				else begin
					triangleCounter = 0;
					state = PREPARE_RASTERIZE;
				end
			end

			PREPARE_RASTERIZE: begin
				x = triangleDataCache[triangleCounter].minX;
				y = triangleDataCache[triangleCounter].minY;
				state = RASTERIZE;
			end

			RASTERIZE: begin
				/* verilator lint_off WIDTH */
				if(triangleCounter < triangleCache[0]) begin
				/* verilator lint_on WIDTH */
					if(x == triangleDataCache[triangleCounter].maxX) begin
						x = triangleDataCache[triangleCounter].minX;

						if(y == triangleDataCache[triangleCounter].maxY) begin
							y = triangleDataCache[triangleCounter].minY;
							triangleCounter =  triangleCounter + 1;
							state = PREPARE_RASTERIZE;
						end
						else begin
							y = y + 1;
						end
					end
					else begin
						x = x + 1;
					end
				end
				else begin
					state = EXECUTING_COMMAND;
				end
			end

			CLEAR_COLOR: begin
				writePixel <= 1;
				if(x == RENDERING_WIDTH) begin
					x = 0;

					if(y == RENDERING_HEIGHT) begin
						y = 0;
						state = EXECUTING_COMMAND;
					end
					else begin
						y = y + 1;
					end
				end
				else begin
					x = x + 1;
				end
			end

		endcase
	end
end

endmodule // Illusion
