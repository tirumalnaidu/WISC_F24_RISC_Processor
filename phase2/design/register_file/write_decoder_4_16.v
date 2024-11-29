module write_decoder_4_16(
	input  [3:0] 	reg_id,
	input 			write_reg,
	output [15:0] 	wordline
);

// TODO: Can improve by just making write_reg & (conditions)
// Output generated only if write_reg is 1. Else send out all zeros

assign wordline[0] 	= (~write_reg)? 1'b0: ~reg_id[3] & ~reg_id[2] & ~reg_id[1] & ~reg_id[0];
assign wordline[1] 	= (~write_reg)? 1'b0: ~reg_id[3] & ~reg_id[2] & ~reg_id[1] & reg_id[0];
assign wordline[2] 	= (~write_reg)? 1'b0: ~reg_id[3] & ~reg_id[2] & reg_id[1] & ~reg_id[0];
assign wordline[3] 	= (~write_reg)? 1'b0: ~reg_id[3] & ~reg_id[2] & reg_id[1] & reg_id[0];
assign wordline[4] 	= (~write_reg)? 1'b0: ~reg_id[3] & reg_id[2] & ~reg_id[1] & ~reg_id[0];
assign wordline[5] 	= (~write_reg)? 1'b0: ~reg_id[3] & reg_id[2] & ~reg_id[1] & reg_id[0];
assign wordline[6] 	= (~write_reg)? 1'b0: ~reg_id[3] & reg_id[2] & reg_id[1] & ~reg_id[0];
assign wordline[7] 	= (~write_reg)? 1'b0: ~reg_id[3] & reg_id[2] & reg_id[1] & reg_id[0];
assign wordline[8] 	= (~write_reg)? 1'b0: reg_id[3] & ~reg_id[2] & ~reg_id[1] & ~reg_id[0];
assign wordline[9] 	= (~write_reg)? 1'b0: reg_id[3] & ~reg_id[2] & ~reg_id[1] & reg_id[0];
assign wordline[10] = (~write_reg)? 1'b0: reg_id[3] & ~reg_id[2] & reg_id[1] & ~reg_id[0];
assign wordline[11] = (~write_reg)? 1'b0: reg_id[3] & ~reg_id[2] & reg_id[1] & reg_id[0];
assign wordline[12] = (~write_reg)? 1'b0: reg_id[3] & reg_id[2] & ~reg_id[1] & ~reg_id[0];
assign wordline[13] = (~write_reg)? 1'b0: reg_id[3] & reg_id[2] & ~reg_id[1] & reg_id[0];
assign wordline[14] = (~write_reg)? 1'b0: reg_id[3] & reg_id[2] & reg_id[1] & ~reg_id[0];
assign wordline[15] = (~write_reg)? 1'b0: reg_id[3] & reg_id[2] & reg_id[1] & reg_id[0];

endmodule