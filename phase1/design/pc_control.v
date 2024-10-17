`include "flags.vh"

module pc_control(
/*INPUT*/
// Branch condition & Flag
input [2:0] 	c,		// 3-bit condition
input [2:0] 	f,		// 3-bit flag

// Possible target values
input [8:0] 	i,		// 9-bit offset	[B-Type Instruction Support]
input [15:0]	target,	// 16-bit "rs" reg val [BR-Type instruction Support]

// Enable & select signals
input 			branch,	// 1-bit branch flag
input [1:0]		branch_type,

input [15:0] 	pc_in,

/*OUTPUT*/
output [15:0] 	pc_out
);

// Condition
/* 	3'b000: Not Equal				(Z==0)
	3'b001: Equal					(Z==1)
	3'b010: Greater Than			(Z==N==0)
	3'b011: Less Than				(N==1)
	3'b100: Greater Than or Equal	(Z==1 or Z==N==0)
	3'b101: Less Than or Equal		(N==1 or Z==1)
	3'b110: Overflow 				(V==1)
	3'b111: Unconditional 
*/ 

// Flag
/* 	flag[0] -> Z
	flag[1] -> V
 	flag[2] -> N
 */

localparam TWO = 16'h0002;

reg br_taken;
reg [15:0] pc_next;

wire [15:0] i_ext;
wire [15:0] i_shft;

wire [15:0] pc_B;
wire [15:0] pc_BR;
wire [15:0] pc_HLT;
wire [15:0] pc_update;

always @ (*) begin
	case(c)
		3'b000: br_taken = (~f[`FLAG_Z])? 1'b1: 1'b0;								// Z=0
		3'b001: br_taken = (f[`FLAG_Z])? 1'b1: 1'b0;								// Z=1
		3'b010: br_taken = (~f[`FLAG_Z] & ~f[`FLAG_N])? 1'b1: 1'b0;					// Z==N==0
		3'b011: br_taken = (f[`FLAG_N])? 1'b1: 1'b0;								// N==1
		3'b100: br_taken = (f[`FLAG_Z] | (~f[`FLAG_Z] & ~f[`FLAG_N]))? 1'b1: 1'b0;	// Z==1 or Z==N==0
		3'b101: br_taken = (f[`FLAG_Z] | f[`FLAG_N])? 1'b1: 1'b0;					// N==1 or Z==1
		3'b110: br_taken = (f[`FLAG_V])? 1'b1: 1'b0;								// V==1
		3'b111: br_taken = 1'b1;													// Unconditional
		default: br_taken = 1'b0;
	endcase
end


assign i_ext = {{7{i[8]}}, i};	// get the 16-bit sign extended immediate value
assign i_shft = i_ext<<1;

addsub_16bit add0(.a_in(pc_in), .b_in(TWO), .is_sub(1'b0), .sum_out(pc_update), .flag(/*unconnected*/));
addsub_16bit add1(.a_in(pc_update), .b_in(i_shft), .is_sub(1'b0), .sum_out(pc_B), .flag(/*unconnected*/));
assign pc_BR = target;

always @(*) begin
	case(branch_type)
		2'b00: pc_next = (branch & br_taken)? pc_B: pc_update;	// B
		2'b01: pc_next = (branch & br_taken)? pc_BR: pc_update;	// BR
		2'b10: pc_next = pc_update;								// PCS
		2'b11: pc_next = pc_in;									// HLT
	endcase
end
assign pc_out = pc_next;

endmodule