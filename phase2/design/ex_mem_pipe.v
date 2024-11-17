module ex_mem_pipe(
    input clk,
    input rst,
    input en,
    input in_mem_read,
    input in_mem_write,
    input in_mem_to_reg,
    input in_write_reg,
    input in_pcs,
    input [15:0] in_alu_out,
    input [15:0] in_src2_data,
    input in_halt,
    input in_pc_nxt,
    output out_mem_read,
    output out_mem_write,
    output out_mem_to_reg,
    output out_write_reg,
    output out_pcs,
    output [15:0] out_alu_out,
    output [15:0] out_src2_data,
    output out_halt,
    output out_pc_nxt
);

pldff #(.WIDTH(1)) mem_read_pldff (.q(out_mem_read), .d(in_mem_read), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) mem_write_pldff (.q(out_mem_write), .d(in_mem_write), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) mem_to_reg_pldff (.q(out_mem_to_reg), .d(in_mem_to_reg), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) write_reg_pldff (.q(out_write_reg), .d(in_write_reg), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) pcs_pldff (.q(out_pcs), .d(in_pcs), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(16)) alu_out_pldff (.q(out_alu_out), .d(in_alu_out), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(16)) src2_data_pldff (.q(out_src2_data), .d(in_src2_data), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) halt_pldff (.q(out_halt), .d(in_halt), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) pc_pldff (.q(out_pc_nxt), .d(in_pc_nxt), .wen(en), .clk(clk), .rst(rst));

endmodule
