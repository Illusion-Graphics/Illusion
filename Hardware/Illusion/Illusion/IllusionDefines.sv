`ifndef __DEFINES_SV
`define __DEFINES_SV

// Width of the main memory bus address line
localparam MAIN_MEMORY_BUS_ADDR_WIDTH = 64;
localparam MAIN_MEMORY_BUS_DEPTH = 32;

// Bit depth of a single full size instruction
localparam COMMAND_DEPTH = 32;

typedef enum [15:0] {
	COMMAND_OP_CLEAR = 16'h0001,
	COMMAND_OP_TRIANGLE = 16'h0002,
	COMMAND_OP_END = 16'hffff
} CommandOperands;

 
`endif // __DEFINES_SV
