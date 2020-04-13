module VideoSignalGenerator
#(
	parameter H_DISPLAY = 640,
	parameter	H_BACK = 48,
	parameter H_FRONT = 16,
	parameter H_SYNC = 96,

	parameter V_DISPLAY = 480,
	parameter V_TOP = 10,
	parameter V_BOTTOM = 33,
	parameter V_SYNC = 2
)
(
	input bit aClock,
	input bit aReset,
	
	output logic anOutHorizontalSync,
	output logic anOutVerticalSync,
	output logic anOutDisplayEnabled,

	output reg [9:0] anOutX,
	output reg [9:0] anOutY
);

localparam H_SYNC_START = H_DISPLAY + H_FRONT;
localparam H_SYNC_END = H_SYNC_START + H_SYNC - 1;
localparam H_MAX = H_SYNC_END + H_BACK;

localparam V_SYNC_START = V_DISPLAY + V_TOP;
localparam V_SYNC_END = V_SYNC_START + V_SYNC - 1;
localparam V_MAX = V_SYNC_END + V_BOTTOM;


assign anOutHorizontalSync = (anOutX >= H_SYNC_START) && (anOutX <= H_SYNC_END);
assign anOutVerticalSync = (anOutY >= V_SYNC_START) && (anOutY <= V_SYNC_END);
assign anOutDisplayEnabled = (anOutX < H_DISPLAY) && (anOutY < V_DISPLAY);


wire maxX = anOutX == H_MAX;
wire maxY = anOutY == V_MAX;

initial
begin
	anOutY = 0;
	anOutY = 0;	
end

always @(posedge aClock)
begin
	if(aReset)
	begin
		anOutX <= 0;
		anOutY <= 0;
	end

	if(maxX)
	begin
		anOutX <= 0;
		
		if(maxY)
		begin
			anOutY <= 0;
		end
		else
		begin
			anOutY <= anOutY + 1;
		end
	end
	else
	begin
		anOutX <= anOutX + 1;
	end
end

endmodule // VideoSignalGenerator
