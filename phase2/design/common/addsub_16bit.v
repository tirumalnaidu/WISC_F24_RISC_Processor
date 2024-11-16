// `include "design/cla_adder_4bit.v"

module addsub_16bit(
	input [15:0] 	a_in,
	input [15:0] 	b_in,
	input 			is_sub,
	output [15:0] 	sum_out,
	output [2:0] 	flag
);

wire [3:0] carry;
wire [15:0] b;
wire [15:0] out;
wire o0, o1, o2, o3;

wire zero, ovfl, sign;

// 4 possible overflow conditions
// condition-1 : a + (b)   	--> positive overflow
// condition-2 : a - (-b)	--> positive overflow
// condition-3 : -a + (-b)	--> negative overflow
// condition-4 : -a - (b)	--> negative overflow

wire condition1 = out[15] & ~a_in[15] & ~b_in[15] & ~is_sub;
wire condition2 = out[15] & ~a_in[15] & b_in[15] & is_sub;
wire condition3 = ~out[15] & a_in[15] & b_in[15] & ~is_sub;
wire condition4 = ~out[15] & a_in[15] & ~b_in[15] & is_sub;

assign b = (is_sub)? ~b_in: b_in;

cla_adder_4bit cla0(.a_in(a_in[3:0]), .b_in(b[3:0]), .carry_in(is_sub), .adder_out(out[3:0]), .carry_out(carry[0]), .ovfl(o0));
cla_adder_4bit cla1(.a_in(a_in[7:4]), .b_in(b[7:4]), .carry_in(carry[0]), .adder_out(out[7:4]), .carry_out(carry[1]), .ovfl(o1));
cla_adder_4bit cla2(.a_in(a_in[11:8]), .b_in(b[11:8]), .carry_in(carry[1]), .adder_out(out[11:8]), .carry_out(carry[2]), .ovfl(o2));
cla_adder_4bit cla3(.a_in(a_in[15:12]), .b_in(b[15:12]), .carry_in(carry[2]), .adder_out(out[15:12]), .carry_out(carry[3]), .ovfl(o3));

// Saturate in case of overflow
// positive overflow : 
// negative overflow

assign sum_out = 	(condition1|condition2) ? 16'h7fff :
					(condition3 |condition4) ? 16'h8000 : out;				


assign ovfl = o3;
assign zero = ~(|sum_out);
assign sign = sum_out[15];

assign flag = {sign, ovfl, zero};

endmodule