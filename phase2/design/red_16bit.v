// `include "cla_adder_4bit.v"

module red_16bit (
    input [15:0] 	a_in,
	input [15:0] 	b_in,
	output [15:0] 	sum_out
	// red instruction cannot modify flags
);

// 9-bit sum0 between lower bytes of the 16-bit inputs
wire [8:0]sum0;
// 9-bit sum1 between upper bytes of the 16-bit inputs
wire [8:0]sum1;

// 9-bit addition of upper & lower 9-bit sums
wire [11:0]sum_final;

// 2-bit carry for the nibble additions
wire [1:0]lower_carry;
wire [1:0]upper_carry;
wire [2:0]final_carry;

// overflow
wire o0, o1, o2, o3; 

// lower byte addition
cla_adder_4bit cla0(.a_in(a_in[3:0]), .b_in(b_in[3:0]), .carry_in(1'b0), .adder_out(sum0[3:0]), .carry_out(lower_carry[0]), .ovfl());
cla_adder_4bit cla1(.a_in(a_in[7:4]), .b_in(b_in[7:4]), .carry_in(lower_carry[0]), .adder_out(sum0[7:4]), .carry_out(lower_carry[1]), .ovfl());
assign sum0[8] = lower_carry[1];

// higher byte addition
cla_adder_4bit cla2(.a_in(a_in[11:8]), .b_in(b_in[11:8]), .carry_in(1'b0), .adder_out(sum1[3:0]), .carry_out(upper_carry[0]), .ovfl());
cla_adder_4bit cla3(.a_in(a_in[15:12]), .b_in(b_in[15:12]), .carry_in(upper_carry[0]), .adder_out(sum1[7:4]), .carry_out(upper_carry[1]), .ovfl());
assign sum1[8] = upper_carry[1];


// Adding the 9-bit results
// using 3 4-bit CLA ladder
// to get 12-bit result
cla_adder_4bit cla4(.a_in(sum0[3:0]), .b_in(sum1[3:0]), .carry_in(1'b0), .adder_out(sum_final[3:0]), .carry_out(final_carry[0]), .ovfl());
cla_adder_4bit cla5(.a_in(sum0[7:4]), .b_in(sum1[7:4]), .carry_in(final_carry[0]), .adder_out(sum_final[7:4]), .carry_out(final_carry[1]), .ovfl());
cla_adder_4bit cla6(.a_in({3'b000,sum0[8]}), .b_in({3'b000,sum1[8]}), .carry_in(final_carry[1]), .adder_out(sum_final[11:8]), .carry_out(final_carry[2]), .ovfl());


// sign extended value of the 9-bit reduction sum to 16-bit
// sign extend the 9th bit
assign sum_out[15:0] = {{7{sum_final[8]}}, sum_final[8:0]};

endmodule