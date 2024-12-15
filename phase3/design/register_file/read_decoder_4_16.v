module read_decoder_4_16(
	input  [3:0] 	reg_id,
	output [15:0] 	wordline
);

assign wordline[0] 	= ~reg_id[3] & ~reg_id[2] & ~reg_id[1] & ~reg_id[0];
assign wordline[1] 	= ~reg_id[3] & ~reg_id[2] & ~reg_id[1] & reg_id[0];
assign wordline[2] 	= ~reg_id[3] & ~reg_id[2] & reg_id[1] & ~reg_id[0];
assign wordline[3] 	= ~reg_id[3] & ~reg_id[2] & reg_id[1] & reg_id[0];
assign wordline[4] 	= ~reg_id[3] & reg_id[2] & ~reg_id[1] & ~reg_id[0];
assign wordline[5] 	= ~reg_id[3] & reg_id[2] & ~reg_id[1] & reg_id[0];
assign wordline[6] 	= ~reg_id[3] & reg_id[2] & reg_id[1] & ~reg_id[0];
assign wordline[7] 	= ~reg_id[3] & reg_id[2] & reg_id[1] & reg_id[0];
assign wordline[8] 	= reg_id[3] & ~reg_id[2] & ~reg_id[1] & ~reg_id[0];
assign wordline[9] 	= reg_id[3] & ~reg_id[2] & ~reg_id[1] & reg_id[0];
assign wordline[10] = reg_id[3] & ~reg_id[2] & reg_id[1] & ~reg_id[0];
assign wordline[11] = reg_id[3] & ~reg_id[2] & reg_id[1] & reg_id[0];
assign wordline[12] = reg_id[3] & reg_id[2] & ~reg_id[1] & ~reg_id[0];
assign wordline[13] = reg_id[3] & reg_id[2] & ~reg_id[1] & reg_id[0];
assign wordline[14] = reg_id[3] & reg_id[2] & reg_id[1] & ~reg_id[0];
assign wordline[15] = reg_id[3] & reg_id[2] & reg_id[1] & reg_id[0];

endmodule