`ifndef __TYPES_SVH
`define __TYPES_SVH

typedef struct packed 
{
	logic Sign;
	logic [7:0] Exponent;
	logic [22:0] Mantissa;
} Float32;

typedef struct packed 
{
	logic Sign;
	logic [14:0] Number;
} Int16;

typedef struct packed 
{
	logic Sign;
	logic [30:0] Number;
} Int32;

`endif //__TYPES_SVH
