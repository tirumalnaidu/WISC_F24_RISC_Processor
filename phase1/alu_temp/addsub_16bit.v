`include "cla_adder_4bit.v"

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

assign b = (is_sub)? ~b_in: b_in;

cla_adder_4bit cla0(.a_in(a_in[3:0]), .b_in(b[3:0]), .carry_in(is_sub), .adder_out(out[3:0]), .carry_out(carry[0]), .ovfl(o0));
cla_adder_4bit cla1(.a_in(a_in[7:4]), .b_in(b[7:4]), .carry_in(carry[0]), .adder_out(out[7:4]), .carry_out(carry[1]), .ovfl(o1));
cla_adder_4bit cla2(.a_in(a_in[11:8]), .b_in(b[11:8]), .carry_in(carry[1]), .adder_out(out[11:8]), .carry_out(carry[2]), .ovfl(o2));
cla_adder_4bit cla3(.a_in(a_in[15:12]), .b_in(b[15:12]), .carry_in(carry[2]), .adder_out(out[15:12]), .carry_out(carry[3]), .ovfl(o3));

// Doubt : does this work for +ve overflow as well ?
assign sum_out = (o3)? 16'h8000: out;	// Saturate in case of overflow 

// condition : positive overflow assign 7fff

assign ovfl = o0 | o1 | o2 | o3;
assign zero = |sum_out;
assign sign = sum_out[15];

assign flag = {sign, ovfl, zero};

endmodule