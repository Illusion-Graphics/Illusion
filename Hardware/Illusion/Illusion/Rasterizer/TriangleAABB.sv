`include "Types.svh"

module TriangleAABB
(
	input logic [10:0] aPoint1 [2],
	input logic [10:0] aPoint2 [2],
	input logic [10:0] aPoint3 [2],

	output TriangleData anOutAABB
);

assign anOutAABB.minX = (aPoint1[0] < aPoint2[0]) ? ((aPoint1[0] > aPoint3[0]) ?  aPoint3[0] : aPoint1[0]) : ((aPoint2[0] > aPoint3[0]) ?  aPoint3[0] : aPoint2[0]);
assign anOutAABB.minY = (aPoint1[1] < aPoint2[1]) ? ((aPoint1[1] > aPoint3[1]) ?  aPoint3[1] : aPoint1[1]) : ((aPoint2[1] > aPoint3[1]) ?  aPoint3[1] : aPoint2[1]);

assign anOutAABB.maxX = (aPoint1[0] > aPoint2[0]) ? ((aPoint1[0] < aPoint3[0]) ?  aPoint3[0] : aPoint1[0]) : ((aPoint2[0] < aPoint3[0]) ?  aPoint3[0] : aPoint2[0]);
assign anOutAABB.maxY = (aPoint1[1] > aPoint2[1]) ? ((aPoint1[1] < aPoint3[1]) ?  aPoint3[1] : aPoint1[1]) : ((aPoint2[1] < aPoint3[1]) ?  aPoint3[1] : aPoint2[1]);

endmodule // TriangleAABB
