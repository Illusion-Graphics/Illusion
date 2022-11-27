module SPI
(
	input bit aReset,

	input bit aSCK,
	input bit aMOSI,
	input bit aMISO,
	input bit aCS,

	output bit anOutDataAvailable,
	output bit [15:0] anOutData,
	input bit aDataRead
);

reg [3:0] bitCounter;
reg [15:0] tempBuffer;

reg [15:0] storage [31:0];
reg [4:0] storageCounterWrite;
reg [4:0] storageCounterRead;

assign anOutDataAvailable = storageCounterWrite != storageCounterRead;
assign anOutData = storage[storageCounterRead];

wire discard;

initial begin
	bitCounter = 0;
	tempBuffer = 0;
	storageCounterWrite = 0;
	storageCounterRead = 0;
end


always @(posedge aSCK) begin
	if (aReset) begin
		tempBuffer <= 0;
	end
	else begin
		// If the chip is active start filling the temp buffer
		if (aCS) begin
			{tempBuffer, discard} <= {aMOSI, tempBuffer};
		end
	end
end

always @(negedge aSCK) begin
	if (bitCounter == 15) begin
		bitCounter <= 0;
		storage[storageCounterWrite] <= tempBuffer;
		storageCounterWrite <= storageCounterWrite + 1;
	end
	else begin
		bitCounter <= bitCounter + 1;
	end
end

always @(posedge aDataRead) begin
	if (anOutDataAvailable) begin
		storageCounterRead <= storageCounterRead + 1;
	end
end


endmodule // SPI
