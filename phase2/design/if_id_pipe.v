module if_id_pipe(
    input clk,
    input rst,
    input en,
    input flush_in,
    input [15:0] in_instr,
    input [15:0] in_pc_nxt,
    output [15:0] out_instr,
    output [15:0] out_pc_nxt
);

wire [15:0] tmp_instr;
assign tmp_instr = (~en)? out_instr: in_instr;

pldff #(.WIDTH(16)) instr_pldff (.d(tmp_instr), .q(out_instr), .wen(en), .clk(clk), .rst(rst | flush_in));
pldff #(.WIDTH(16)) pc_nxt_pldff (.d(in_pc_nxt), .q(out_pc_nxt), .wen(en), .clk(clk), .rst(rst | flush_in));

endmodule