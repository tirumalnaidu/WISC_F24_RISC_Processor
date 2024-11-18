module pc_update(
    input clk,
    input rst,
    input [15:0] pc_in,
    input pc_wen,
    output [15:0] pc_out
);

dff dff00(.q(pc_out[0]), .d(pc_in[0]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff01(.q(pc_out[1]), .d(pc_in[1]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff02(.q(pc_out[2]), .d(pc_in[2]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff03(.q(pc_out[3]), .d(pc_in[3]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff04(.q(pc_out[4]), .d(pc_in[4]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff05(.q(pc_out[5]), .d(pc_in[5]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff06(.q(pc_out[6]), .d(pc_in[6]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff07(.q(pc_out[7]), .d(pc_in[7]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff08(.q(pc_out[8]), .d(pc_in[8]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff09(.q(pc_out[9]), .d(pc_in[9]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff10(.q(pc_out[10]), .d(pc_in[10]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff11(.q(pc_out[11]), .d(pc_in[11]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff12(.q(pc_out[12]), .d(pc_in[12]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff13(.q(pc_out[13]), .d(pc_in[13]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff14(.q(pc_out[14]), .d(pc_in[14]), .wen(pc_wen), .clk(clk), .rst(rst));
dff dff15(.q(pc_out[15]), .d(pc_in[15]), .wen(pc_wen), .clk(clk), .rst(rst));

endmodule