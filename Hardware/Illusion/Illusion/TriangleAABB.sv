module TriangleAABB
(
	input logic [10:0] aPoint1 [2],
	input logic [10:0] aPoint2 [2],
	input logic [10:0] aPoint3 [2],

	output logic [10:0] anOutMin [2],
	output logic [10:0] anOutMax [2]
);

assign anOutMin[0] = (aPoint1[0] < aPoint2[0]) ? ((aPoint1[0] > aPoint3[0]) ?  aPoint3[0] : aPoint1[0]) : ((aPoint2[0] > aPoint3[0]) ?  aPoint3[0] : aPoint2[0]);
assign anOutMin[1] = (aPoint1[1] < aPoint2[1]) ? ((aPoint1[1] > aPoint3[1]) ?  aPoint3[1] : aPoint1[1]) : ((aPoint2[1] > aPoint3[1]) ?  aPoint3[1] : aPoint2[1]);

assign anOutMax[0] = (aPoint1[0] > aPoint2[0]) ? ((aPoint1[0] < aPoint3[0]) ?  aPoint3[0] : aPoint1[0]) : ((aPoint2[0] < aPoint3[0]) ?  aPoint3[0] : aPoint2[0]);
assign anOutMax[1] = (aPoint1[1] > aPoint2[1]) ? ((aPoint1[1] < aPoint3[1]) ?  aPoint3[1] : aPoint1[1]) : ((aPoint2[1] < aPoint3[1]) ?  aPoint3[1] : aPoint2[1]);

endmodule // TriangleAABB
