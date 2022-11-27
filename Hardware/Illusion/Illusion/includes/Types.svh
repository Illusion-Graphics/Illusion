`ifndef __TYPES_SVH
`define __TYPES_SVH

typedef struct packed
{
	logic signed [15:0] X;
	logic signed [15:0] Y;
} Point;
`define PointBlockSize $bits(Point) / 32

typedef struct packed
{
	// Triangle AABB in screen space
	Point min;
	Point max;
} TriangleData;
`define TriangleDataBlockSize $bits(TriangleData) / 32

`endif // __TYPES_SVH
