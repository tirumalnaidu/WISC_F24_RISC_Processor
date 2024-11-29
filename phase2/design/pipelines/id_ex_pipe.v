module id_ex_pipe(
    input clk,
    input rst,
    input en,
    
    input in_mem_read,
    input in_mem_write,
    input in_mem_to_reg,
    input in_write_reg,
    input in_alu_src,
    input in_pcs,
    input in_halt,
    input in_reg_dst,
    input [15:0] in_pc_nxt,
    input [2:0] in_flag_en,
    input [3:0] in_opcode,
    input [3:0] in_src_reg1,
    input [3:0] in_src_reg2,
    input [3:0] in_dst_reg,
    input [15:0] in_sign_ext_imm,
    input [15:0] in_src1_data,
    input [15:0] in_src2_data,


    output out_mem_read,
    output out_mem_write,
    output out_mem_to_reg,
    output out_write_reg,
    output out_alu_src,
    output out_pcs,
    output out_halt,
    output out_reg_dst,
    output [15:0] out_pc_nxt,
    output [2:0] out_flag_en,
    output [3:0] out_opcode,
    output [3:0] out_src_reg1,
    output [3:0] out_src_reg2,
    output [3:0] out_dst_reg,
    output [15:0] out_sign_ext_imm,
    output [15:0] out_src1_data,
    output [15:0] out_src2_data,
    output out_flush
);

pldff #(.WIDTH(1)) mem_read_pldff (.q(out_mem_read), .d(in_mem_read), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) mem_write_pldff (.q(out_mem_write), .d(in_mem_write), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) mem_to_reg_pldff (.q(out_mem_to_reg), .d(in_mem_to_reg), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) write_reg_pldff (.q(out_write_reg), .d(in_write_reg), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) alu_src_pldff (.q(out_alu_src), .d(in_alu_src), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) pcs_pldff (.q(out_pcs), .d(in_pcs), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) halt_pldff (.q(out_halt), .d(in_halt), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) reg_dst_pldff (.q(out_reg_dst), .d(in_reg_dst), .wen(en), .clk(clk), .rst(rst));

pldff #(.WIDTH(16)) pc_pldff (.q(out_pc_nxt), .d(in_pc_nxt), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(3)) flag_en_pldff (.q(out_flag_en), .d(in_flag_en), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(4)) opcode_pldff (.q(out_opcode), .d(in_opcode), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(4)) src1_reg_pldff (.q(out_src_reg1), .d(in_src_reg1), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(4)) src2_reg_pldff (.q(out_src_reg2), .d(in_src_reg2), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(4)) dst_reg_pldff (.q(out_dst_reg), .d(in_dst_reg), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(16)) sign_ext_imm_pldff (.q(out_sign_ext_imm), .d(in_sign_ext_imm), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(16)) src1_data_pldff (.q(out_src1_data), .d(in_src1_data), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(16)) src2_data_pldff (.q(out_src2_data), .d(in_src2_data), .wen(en), .clk(clk), .rst(rst));

pldff #(.WIDTH(1)) flush_pldff (.q(out_flush), .d(rst), .wen(en), .clk(clk), .rst(rst));

endmodule
