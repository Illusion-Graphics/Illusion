`ifndef __TYPES_SVH
`define __TYPES_SVH

typedef struct packed
{
	// Triangle AABB in screen space
	logic signed [10:0] minX;
	logic signed [10:0] minY;
	
	logic signed [10:0] maxX;
	logic signed [10:0] maxY;
} TriangleData;


`endif // __TYPES_SVH
