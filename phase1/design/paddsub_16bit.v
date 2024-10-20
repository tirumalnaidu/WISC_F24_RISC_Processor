`include "cla_adder_4bit.v"

module paddsub_16bit (
    input [15:0] 	a_in,
	input [15:0] 	b_in,
    //input is_sub,
    output [15:0] 	sum_out
    // paddsub does not modify flags
);

wire [3:0] carry;    // to store carry from 4 4-bit CLA
wire [15:0] out;     // to store the sum from the 4 4-bit CLA
// wire ovfl;
wire o0, o1, o2, o3; // to store overflow
wire condition1,  condition2, condition3, condition4,
condition5, condition6, condition7, condition8,
condition9,  condition10, condition11, condition12,
condition13, condition14, condition15, condition16;


// 4 possible overflow conditions
// condition-1 : a + (b)   	--> positive overflow (possible in paddsub)
// condition-2 : a - (-b)	--> positive overflow (not possible)
// condition-3 : -a + (-b)	--> negative overflow (possible in paddsub)
// condition-4 : -a - (b)	--> negative overflow (not possible)

assign condition1 = out[3] & ~a_in[3] & ~b_in[3];
// assign condition2 = out[3] & ~a_in[3] & b_in[3] & is_sub;
assign condition3 = ~out[3] & a_in[3] & b_in[3];
// assign condition4 = ~out[3] & a_in[3] & ~b_in[3] & is_sub;

assign condition5 = out[7] & ~a_in[7] & ~b_in[7];
// assign condition6 = out[7] & ~a_in[7] & b_in[7] & is_sub;
assign condition7 = ~out[7] & a_in[7] & b_in[7];
// assign condition8 = ~out[7] & a_in[7] & ~b_in[7] & is_sub;

assign condition9 = out[11] & ~a_in[11] & ~b_in[11];
//assign condition10 = out[11] & ~a_in[11] & b_in[11] & is_sub;
assign condition11 = ~out[11] & a_in[11] & b_in[11];
// assign condition12 = ~out[11] & a_in[11] & ~b_in[11] & is_sub;

assign condition13 = out[15] & ~a_in[15] & ~b_in[15];
// assign condition14 = out[15] & ~a_in[15] & b_in[15] & is_sub;
assign condition15 = ~out[15] & a_in[15] & b_in[15];
// assign condition16 = ~out[15] & a_in[15] & ~b_in[15] & is_sub;

// b = (is_sub)? ~b_in: b_in;

cla_adder_4bit cla0(.a_in(a_in[3:0]), .b_in(b_in[3:0]), .carry_in(1'b0), .adder_out(out[3:0]), .carry_out(carry[0]), .ovfl(o0));
cla_adder_4bit cla1(.a_in(a_in[7:4]), .b_in(b_in[7:4]), .carry_in(1'b0), .adder_out(out[7:4]), .carry_out(carry[1]), .ovfl(o1));
cla_adder_4bit cla2(.a_in(a_in[11:8]), .b_in(b_in[11:8]), .carry_in(1'b0), .adder_out(out[11:8]), .carry_out(carry[2]), .ovfl(o2));
cla_adder_4bit cla3(.a_in(a_in[15:12]), .b_in(b_in[15:12]), .carry_in(1'b0), .adder_out(out[15:12]), .carry_out(carry[3]), .ovfl(o3));



// Saturate 4-bits in case of overflow 
assign sum_out[3:0] =   (condition1)? 4'b0111 : 
                        (condition3) ? 4'b1111 : out[3:0] ;

assign sum_out[7:4] =   (condition5)? 4'b0111 : 
                        (condition7)? 4'b1000 : out[7:4] ;

assign sum_out[11:8] =  (condition9)? 4'b0111 : 
                        (condition11) ? 4'b1000 : out[11:8] ;

assign sum_out[15:12] = (condition13)? 4'b0111 : 
                        (condition15) ? 4'b1000 : out[15:12] ;



//assign sum_out = out;


endmodule