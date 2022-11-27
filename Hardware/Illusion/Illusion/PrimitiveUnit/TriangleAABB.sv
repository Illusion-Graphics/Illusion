`include "Types.svh"

module TriangleAABB
(
	input Point aPoint1,
	input Point aPoint2,
	input Point aPoint3,

	output TriangleData anOutAABB
);

assign anOutAABB.min.X = (aPoint1.X < aPoint2.X) ? ((aPoint1.X > aPoint3.X) ?  aPoint3.X : aPoint1.X) : ((aPoint2.X > aPoint3.X) ?  aPoint3.X : aPoint2.X);
assign anOutAABB.min.Y = (aPoint1.Y < aPoint2.Y) ? ((aPoint1.Y > aPoint3.Y) ?  aPoint3.Y : aPoint1.Y) : ((aPoint2.Y > aPoint3.Y) ?  aPoint3.Y : aPoint2.Y);

assign anOutAABB.max.X = (aPoint1.X > aPoint2.X) ? ((aPoint1.X < aPoint3.X) ?  aPoint3.X : aPoint1.X) : ((aPoint2.X < aPoint3.X) ?  aPoint3.X : aPoint2.X);
assign anOutAABB.max.Y = (aPoint1.Y > aPoint2.Y) ? ((aPoint1.Y < aPoint3.Y) ?  aPoint3.Y : aPoint1.Y) : ((aPoint2.Y < aPoint3.Y) ?  aPoint3.Y : aPoint2.Y);

endmodule // TriangleAABB
