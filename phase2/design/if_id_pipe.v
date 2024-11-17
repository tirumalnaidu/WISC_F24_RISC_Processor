module if_id_pipe(
    input clk,
    input rst,
    input en,
    input [15:0] in_instr,
    input [15:0] in_pc_next,
    output [15:0] out_instr,
    output [15:0] out_pc_next
);

pldff #(.WIDTH(16)) alu_out_pldff (.d(in_instr), .q(out_instr), .wen(en), .clk(clk), .rst(rst));
pldff #(.WIDTH(16)) src2_data_pldff (.d(in_pc_next), .q(out_pc_next), .wen(en), .clk(clk), .rst(rst));


endmodule