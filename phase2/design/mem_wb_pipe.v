module mem_wb_pipe(
    input clk,
    input rst,
    input en,
    input in_mem_to_reg,
    input in_write_reg,
    input in_pcs,
    input [3:0] in_src_reg1,
    input [3:0] in_src_reg2,
    input [3:0] in_dst_reg,
    input [15:0] in_alu_out,
    input [15:0] in_mem_data,
    input in_halt,
    input [15:0] in_pc_nxt,
    output out_mem_to_reg,
    output out_write_reg,
    output out_pcs,
    output [3:0] out_src_reg1,
    output [3:0] out_src_reg2,
    output [3:0] out_dst_reg,
    output [15:0] out_alu_out,
    output [15:0] out_mem_data,
    output out_halt,
    output [15:0] out_pc_nxt
);

pldff #(.WIDTH(1)) mem_to_reg_pldff (.d(in_mem_to_reg), .q(out_mem_to_reg), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) write_reg_pldff (.d(in_write_reg), .q(out_write_reg), .wen(out_write_reg), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) pcs_pldff (.d(in_pcs), .q(out_pcs), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(4)) src1_reg_pldff (.q(out_src_reg1), .d(in_src_reg1), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(4)) src2_reg_pldff (.q(out_src_reg2), .d(in_src_reg2), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(4)) dst_reg_pldff (.q(out_dst_reg), .d(in_dst_reg), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(16)) alu_out_pldff (.d(in_alu_out), .q(out_alu_out), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(16)) mem_data_pldff (.d(in_mem_data), .q(out_mem_data), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) halt_pldff (.d(in_halt), .q(out_halt), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(16)) pc_pldff (.d(in_pc_nxt), .q(out_pc_nxt), .wen(en), .clk(clk), .rst(rst));

endmodule