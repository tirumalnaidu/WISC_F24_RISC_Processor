module cla_adder_4bit(
	input [3:0] a_in,
	input [3:0] b_in,
	input carry_in,
	output [3:0] adder_out,
	output carry_out,
	output ovfl
);


wire p0, p1, p2, p3;	// Carry propagate
wire g0, g1, g2, g3;	// Carry generate
wire c1, c2, c3;		// Carries

// Propagate values -> This is involved
// in propagating the cin -> cout
assign p0 = a_in[0] ^ b_in[0];
assign p1 = a_in[1] ^ b_in[1];
assign p2 = a_in[2] ^ b_in[2];
assign p3 = a_in[3] ^ b_in[3];

// Generate values -> This is involved
// in generating new cout (independent of cin)
assign g0 = a_in[0] & b_in[0];
assign g1 = a_in[1] & b_in[1];
assign g2 = a_in[2] & b_in[2];
assign g3 = a_in[3] & b_in[3];

// Carry Values
assign c1 			= g0 | (p0 & carry_in);																		// g0 + p0.c0
assign c2 			= g1 | (p1 & g0) | (p1 & p0 & carry_in);													// g1 + p1.c1
assign c3 			= g2 | (p2 & g1) | (p2 & p1 & g0) | (p2 & p1 & p0 & carry_in);								// g2 + p2.c2
assign carry_out 	= g3 | (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0) | (p3 & p2 & p1 & p0 & carry_in);	// g3 + p3.c3

// Sum Values
assign adder_out[0] = p0 ^ carry_in;
assign adder_out[1] = p1 ^ c1;
assign adder_out[2] = p2 ^ c2;
assign adder_out[3] = p3 ^ c3;

assign ovfl = carry_out ^ c3;

endmodule