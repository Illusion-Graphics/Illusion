module Rasterizer
(
	input logic [10:0] aX,
	input logic [10:0] aY,
 
	input logic [10:0] aPoint1 [2],
	input logic [10:0] aPoint2 [2],
	input logic [10:0] aPoint3 [2],

	output wire anOutInside
);

// Get side to first segment p1 - p2
wire signed [10:0] s1v1x = (aX - aPoint2[0]);
wire signed [10:0] s1v1y = (aY - aPoint2[1]);
wire signed [10:0] s1v2x = (aPoint1[0] - aPoint2[0]);
wire signed [10:0] s1v2y = (aPoint1[1] - aPoint2[1]);
wire signed [32:0] s1 = (s1v1x * s1v2y) - (s1v2x * s1v1y);

// Get side to first segment p2 - p3
wire signed [10:0] s2v1x = (aX - aPoint3[0]);
wire signed [10:0] s2v1y = (aY - aPoint3[1]);
wire signed [10:0] s2v2x = (aPoint2[0] - aPoint3[0]);
wire signed [10:0] s2v2y = (aPoint2[1] - aPoint3[1]);
wire signed [32:0] s2 = (s2v1x * s2v2y) - (s2v2x * s2v1y);

// Get side to first segment p3 - p1
wire signed [10:0] s3v1x = (aX - aPoint1[0]);
wire signed [10:0] s3v1y = (aY - aPoint1[1]);
wire signed [10:0] s3v2x = (aPoint3[0] - aPoint1[0]);
wire signed [10:0] s3v2y = (aPoint3[1] - aPoint1[1]);
wire signed [32:0] s3 = (s3v1x * s3v2y) - (s3v2x * s3v1y);

wire pos = (s1 > 0) || (s2 > 0) || (s3 > 0);
wire neg = (s1 < 0) || (s2 < 0) || (s3 < 0);

assign anOutInside = !(pos && neg);

endmodule // Rasterizer
