`ifndef CLA_4BIT_V
`define CLA_4BIT_V
// `include "1-bit_adder.v"

// cla 4bit module declaration
module cla_4bit(
	input [3:0] a,
	input [3:0] b,
	input is_sub,
	output [3:0] sum,
	output ovfl,
	output P,
	output G
	);
	
	
wire [3:0] p; // propagate
wire [3:0] g; // generate 
wire [3:0] c; // carry 
//wire [3:0] b; // for subtraction

//assign b = b_in ^ {4{is_sub}};
assign p = a | b;
assign g = a & b;

// carry out calculation for each bit position
assign c[0] = (g[0])|(p[0]&is_sub);
assign c[1] = (g[1])|(p[1]&g[0])|(p[1]&p[0]&c[0]);
assign c[2] = (g[2])|(p[2]&g[1])|(p[2]&p[1]&g[0])|(p[2]&p[1]&p[0]&c[0]);
assign c[3] = (g[3])|(p[3]&g[2])|(p[3]&p[2]&g[1])|(p[3]&p[2]&p[1]&g[0])|(p[3]&p[2]&p[1]&p[0]&c[0]);

// full adder 1 bit instantiation for each bit position
full_adder_1bit fa0(
	.a(a[0]),
	.b(b[0]),
	.cin(is_sub),
	.sum(sum[0])
	);
	
full_adder_1bit fa1(
	.a(a[1]),
	.b(b[1]),
	.cin(c[0]),
	.sum(sum[1])
	);
	
full_adder_1bit fa2(
	.a(a[2]),
	.b(b[2]),
	.cin(c[1]),
	.sum(sum[2])
	);
	
full_adder_1bit fa3(
	.a(a[3]),
	.b(b[3]),
	.cin(c[2]),
	.sum(sum[3])
	);

// calculating final propagate & generate signal
assign P = p[0] & p[1] & p[2] & p[3];
assign G = g[3] | (p[3] & g[2]) |(p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);

// calculating overflow flag
assign ovfl = c[3] ^ c[2];
endmodule
`endif