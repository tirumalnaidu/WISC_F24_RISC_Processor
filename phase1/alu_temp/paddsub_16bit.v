`include "cla_adder_4bit.v"

module paddsub_16bit (
    input [15:0] 	a_in,
	input [15:0] 	b_in,
    output [15:0] 	sum_out
    // paddsub does not modify flags
);

wire [3:0] carry;    // to store carry from 4 4-bit CLA
wire [15:0] out;     // to store the sum from the 4 4-bit CLA
wire o0, o1, o2, o3; // to store overflow

cla_adder_4bit cla0(.a_in(a_in[3:0]), .b_in(b_in[3:0]), .carry_in(1'b0), .adder_out(out[3:0]), .carry_out(carry[0]), .ovfl(o0));
cla_adder_4bit cla1(.a_in(a_in[7:4]), .b_in(b_in[7:4]), .carry_in(1'b0), .adder_out(out[7:4]), .carry_out(carry[1]), .ovfl(o1));
cla_adder_4bit cla2(.a_in(a_in[11:8]), .b_in(b_in[11:8]), .carry_in(1'b0), .adder_out(out[11:8]), .carry_out(carry[2]), .ovfl(o2));
cla_adder_4bit cla3(.a_in(a_in[15:12]), .b_in(b_in[15:12]), .carry_in(1'b0), .adder_out(out[15:12]), .carry_out(carry[3]), .ovfl(o3));

// Saturate 4-bits in case of overflow 
assign sum_out[3:0] = (o0)? 4'b0111 : out[3:0];
assign sum_out[7:4] = (o1)? 4'b0111 : out[7:4];
assign sum_out[11:8] = (o2)? 4'b0111 : out[11:8];
assign sum_out[15:12] = (o3)? 4'b0111 : out[15:12];






endmodule