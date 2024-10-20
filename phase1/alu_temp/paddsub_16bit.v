`include "cla_adder_4bit.v"

module paddsub_16bit (
    input [15:0] 	a_in,
	input [15:0] 	b_in,
    input is_sub;
    output [15:0] 	sum_out
    // paddsub does not modify flags
);

wire [3:0] carry;    // to store carry from 4 4-bit CLA
wire [15:0] out;     // to store the sum from the 4 4-bit CLA
wire o0, o1, o2, o3; // to store overflow


// 4 possible overflow conditions
// condition-1 : a + (b)   	--> positive overflow
// condition-2 : a - (-b)	--> positive overflow
// condition-3 : -a + (-b)	--> negative overflow
// condition-4 : -a - (b)	--> negative overflow

wire condition1 = out[3] & ~a_in[3] & ~b_in[3] & ~is_sub;
wire condition2 = out[3] & ~a_in[3] & b_in[3] & is_sub;
wire condition3 = ~out[3] & a_in[3] & b_in[3] & ~is_sub;
wire condition4 = ~out[3] & a_in[3] & ~b_in[3] & is_sub

wire condition5 = out[7] & ~a_in[7] & ~b_in[7] & ~is_sub;
wire condition6 = out[7] & ~a_in[7] & b_in[7] & is_sub;
wire condition7 = ~out[7] & a_in[7] & b_in[7] & ~is_sub;
wire condition8 = ~out[7] & a_in[7] & ~b_in[7] & is_sub

wire condition9 = out[11] & ~a_in[11] & ~b_in[11] & ~is_sub;
wire condition10 = out[11] & ~a_in[11] & b_in[11] & is_sub;
wire condition11 = ~out[11] & a_in[11] & b_in[11] & ~is_sub;
wire condition12 = ~out[11] & a_in[11] & ~b_in[11] & is_sub

wire condition13 = out[15] & ~a_in[15] & ~b_in[15] & ~is_sub;
wire condition14 = out[15] & ~a_in[15] & b_in[15] & is_sub;
wire condition15 = ~out[15] & a_in[15] & b_in[15] & ~is_sub;
wire condition16 = ~out[15] & a_in[15] & ~b_in[15] & is_sub


cla_adder_4bit cla0(.a_in(a_in[3:0]), .b_in(b_in[3:0]), .carry_in(is_sub), .adder_out(out[3:0]), .carry_out(carry[0]), .ovfl(o0));
cla_adder_4bit cla1(.a_in(a_in[7:4]), .b_in(b_in[7:4]), .carry_in(is_sub), .adder_out(out[7:4]), .carry_out(carry[1]), .ovfl(o1));
cla_adder_4bit cla2(.a_in(a_in[11:8]), .b_in(b_in[11:8]), .carry_in(is_sub), .adder_out(out[11:8]), .carry_out(carry[2]), .ovfl(o2));
cla_adder_4bit cla3(.a_in(a_in[15:12]), .b_in(b_in[15:12]), .carry_in(is_sub), .adder_out(out[15:12]), .carry_out(carry[3]), .ovfl(o3));



// Saturate 4-bits in case of overflow 
assign sum_out[3:0] =   (condition1 | condition2)? 4'b0111 : 
                        (condition3|condition4) ? 4'b1000 : out[3:0] ;

assign sum_out[7:4] =   (condition5 | condition6)? 4'b0111 : 
                        (condition7|condition8)? 4'b1000 : out[3:0] ;

assign sum_out[11:8] =  (condition9 | condition10)? 4'b0111 : 
                        (condition11|condition12) ? 4'b1000 : out[3:0] ;

assign sum_out[15:12] = (condition13 | condition14)? 4'b0111 : 
                        (condition15|condition16) ? 4'b1000 : out[3:0] ;






endmodule