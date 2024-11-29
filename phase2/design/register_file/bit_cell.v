module bit_cell(
	input clk,
	input rst,
	input d,
	input wren,
	input rden1,
	input rden2,
	inout bitline1,
	inout bitline2
);

wire dff_q;

dff dff0(.q(dff_q), .d(d), .wen(wren), .clk(clk), .rst(rst));

// Tri-state buffer implementation
assign bitline1 = (rden1)? dff_q: 1'bz;
assign bitline2 = (rden2)? dff_q: 1'bz;
endmodule