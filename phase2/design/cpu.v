// WISC-FA24 Processor Phase-2
// Authors: 
//          - Tirumal Naidu
//          - Yash Deshpande
//          - Balaji Adithya

// forwarding - done
// hazard - detection; resolve?
// pc-update -> normal case and hlt case -> done
//           -> ctrl hazard? 
// stalls - ? (into pipeline - enables)
// flush - ? (into pipeline - resets)

module cpu(
    input clk,
    input rst,
    output hlt,
    output [15:0] pc
);

// Local parameters
localparam DWIDTH = 16;
localparam AWIDTH = 16;
localparam TWO = 16'h0002;

// PC
wire [15:0] pc_cur;
wire [15:0] pc_nxt;

// IF
wire [DWIDTH-1:0] instr;
wire [1:0] branch_type;

// ID
wire [3:0] src_reg1, src_reg2, dst_reg;
wire [15:0] src1_data, src2_data;

// EX
wire [2:0] flag, flag_en, flag_reg_out;
wire [15:0] alu_in1, alu_in2, alu_out;
wire [15:0] sign_ext_imm;

// MEM
wire [15:0] mem_data;
wire mem_enable;

// WB
wire [15:0] dst_data;

// Control signals
wire reg_dst;
wire write_reg;
wire alu_src;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire llb_en;
wire hlb_en;
wire branch;
wire branchr;
wire pcs;
wire halt;

// ---------- IF ------------
wire [15:0] pc_hlt;
wire [15:0] pc_plus_two;
wire [3:0] opcode;
wire if_stage_hlt;

pc_update pc_up(.clk(clk), 
                .rst(rst), 
                .pc_in(pc_nxt), 
                .pc_out(pc_cur)
                );

assign opcode = instr[15:12];
assign if_stage_hlt = &opcode;
assign pc_hlt = pc;
addsub_16bit pc_incr(.a_in(pc_cur), .b_in(TWO), .is_sub(1'b0), .sum_out(pc_plus_two), .flag(/*unconnected*/));

// assign pc_nxt = (/*from ctrl_hazard*/)? pc_hazard: (if_stage_hlt)? pc_hlt: pc_plus_two;

memory1c_instr #(   .DWIDTH(DWIDTH), 
                    .AWIDTH(AWIDTH)
                ) imem (.data_out(instr), 
                        .data_in(/*unconnected*/), 
                        .addr(pc_cur), 
                        .enable(1'b1), 
                        .wr(1'b0), 
                        .clk(clk), 
                        .rst(rst)
                        );

assign pc = pc_cur; // Current PC as output

// --------------------------------------

// ---------- IF/ID Pipeline ------------

wire [15:0] if_id_instr;
wire [15:0] if_id_pc_nxt;

if_id_pipe  if_id_pipe_inst (
    .clk(clk),
    .rst(rst), //TODO: flush
    .en(), //TODO: stall 
    .in_instr(instr),
    .in_pc_nxt(pc_nxt),
    .out_instr(if_id_instr),
    .out_pc_nxt(if_id_pc_nxt)
  );

// --------------------------------------

// ---------- ID ------------
// Glue Logic for pc_control
assign branch_type = (halt)? 2'b11:(pcs)? 2'b10:(branch & branchr)? 2'b01: 2'b00;

pc_control pc_ctrl( .c(if_id_instr[11:9]),
                    .f(flag_reg_out),
                    .i(if_id_instr[8:0]),
                    .target(src1_data),
                    .branch(branch),
                    .pcs(pcs),
                    .hlt(halt),
                    .branch_type(branch_type),
                    .pc_in(pc_cur), // TODO: ???
                    .pc_out(if_id_pc) // TODO: ???
                    );

assign src_reg1 = (llb_en | hlb_en) ? if_id_instr[11:8] : if_id_instr[7:4];
assign src_reg2 = (mem_write | mem_read) ? if_id_instr[11:8] : if_id_instr[3:0];
assign dst_reg = if_id_instr[11:8];

register_file regfile(
    .clk(clk),
    .rst(rst),
    .src_reg1(src_reg1),
    .src_reg2(src_reg2),
    .dst_reg(dst_reg),
    .write_reg(write_reg),
    .dst_data(dst_data),
    .src_data1(src1_data),
    .src_data2(src2_data)
);
 
control_unit cpu_ctrl(
    .opcode(opcode),
    .reg_dst(reg_dst),
    .reg_write(write_reg),
    .alu_src(alu_src),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .llb_en(llb_en),
    .hlb_en(hlb_en),
    .branch(branch),
    .branchr(branchr),
    .pcs(pcs),
    .halt(halt),
    .flag_en(flag_en)
);

// for mem read or write, addr = (Reg[ssss] & 0xFFFE) + (sign-extend(oooo) << 1).
// three diff ext - (lw, sw), (llb, hlb), (sll, srl, ror)
assign sign_ext_imm = (mem_read | mem_write) ? ({{12{1'b0}}, if_id_instr[3:0]} << 1) : 
                        (llb_en) ? {{8{1'b0}},if_id_instr[7:0]} : 
                        (hlb_en) ? {if_id_instr[7:0], {8{1'b0}}} : 
                        {{12{1'b0}},if_id_instr[3:0]}; // for sll, srl, ror

// TODO hlt signal to be given at the WB stage only
// assign hlt = halt;
// ---------------------------

// ----------- ID/EX Pipeline -------------
wire id_ex_mem_read, id_ex_mem_write, id_ex_mem_to_reg, id_ex_write_reg, id_ex_alu_src, id_ex_pcs, id_ex_halt;
wire [15:0] id_ex_pc_nxt, id_ex_sign_ext_imm, id_ex_src1_data, id_ex_src2_data;
wire [3:0] id_ex_opcode, id_ex_src_reg1, id_ex_src_reg2, id_ex_dst_reg;    
wire [2:0] id_ex_flag_en;

id_ex_pipe  id_ex_pipe_inst (
    .clk(clk),
    .rst(rst), //TODO: flush
    .en(en), //TODO: stall
    .in_mem_read(mem_read),
    .in_mem_write(mem_write),
    .in_mem_to_reg(mem_to_reg),
    .in_write_reg(write_reg),
    .in_alu_src(alu_src),
    .in_pcs(pcs),
    .in_halt(halt),
    .in_pc_nxt(if_id_pc_nxt), // latching from if-id pipe
    .in_flag_en(flag_en),
    .in_opcode(opcode),
    .in_src_reg1(src_reg1),
    .in_src_reg2(src_reg2),
    .in_dst_reg(dst_reg),
    .in_sign_ext_imm(sign_ext_imm),
    .in_src1_data(src1_data),
    .in_src2_data(src2_data),
    .out_mem_read(id_ex_mem_read),
    .out_mem_write(id_ex_mem_write),
    .out_mem_to_reg(id_ex_mem_to_reg),
    .out_write_reg(id_ex_write_reg),
    .out_alu_src(id_ex_alu_src),
    .out_pcs(id_ex_pcs),
    .out_halt(id_ex_halt),
    .out_pc_nxt(id_ex_pc_nxt),
    .out_flag_en(id_ex_flag_en),
    .out_opcode(id_ex_opcode),
    .out_src_reg1(id_ex_src_reg1),
    .out_src_reg2(id_ex_src_reg2),
    .out_dst_reg(id_ex_dst_reg),
    .out_sign_ext_imm(id_ex_sign_ext_imm),
    .out_src1_data(id_ex_src1_data),
    .out_src2_data(id_ex_src2_data)
  );

// ----------------------------------------

// ---------- EX ------------
assign alu_in1 = (id_ex_mem_read | id_ex_mem_write) ? (id_ex_src1_data & 16'hFFFE) : id_ex_src1_data;
assign alu_in2 = id_ex_alu_src ? id_ex_sign_ext_imm : id_ex_src2_data;


alu_16bit alu(.alu_in1(alu_in1),
        .alu_in2(alu_in2),
        .opcode(id_ex_opcode),
        .alu_out(alu_out),
        .flag(flag)  // {sign, ovfl, zero};
        );

// flag register for pc_control
dff ff0(.q(flag_reg_out[0]), .d(flag[0]), .wen(id_ex_flag_en[0]), .clk(clk), .rst(rst));
dff ff1(.q(flag_reg_out[1]), .d(flag[1]), .wen(id_ex_flag_en[1]), .clk(clk), .rst(rst));
dff ff2(.q(flag_reg_out[2]), .d(flag[2]), .wen(id_ex_flag_en[2]), .clk(clk), .rst(rst));

// ---------------------------

// ----------- EX-MEM PIPELINE--------------
wire ex_mem_mem_read, ex_mem_mem_write, ex_mem_mem_to_reg, ex_mem_write_reg, ex_mem_pcs, ex_mem_halt;
wire [15:0] ex_mem_alu_out, ex_mem_src2_data, ex_mem_pc_nxt;
wire [3:0] ex_mem_src_reg1, ex_mem_src_reg2, ex_mem_dst_reg;    

ex_mem_pipe  ex_mem_pipe_inst (
    .clk(clk),
    .rst(rst), //TODO: flush
    .en(en), //TODO: stall
    .in_mem_read(id_ex_mem_read),
    .in_mem_write(id_ex_mem_write),
    .in_mem_to_reg(id_ex_mem_to_reg),
    .in_write_reg(id_ex_write_reg),
    .in_pcs(id_ex_pcs),
    .in_src_reg1(id_ex_src_reg1),
    .in_src_reg2(id_ex_src_reg2),
    .in_dst_reg(id_ex_dst_reg),
    .in_alu_out(alu_out),
    .in_src2_data(id_ex_src2_data),
    .in_halt(id_ex_halt),
    .in_pc_nxt(id_ex_pc_nxt),
    .out_mem_read(ex_mem_mem_read),
    .out_mem_write(ex_mem_mem_write),
    .out_mem_to_reg(ex_mem_mem_to_reg),
    .out_write_reg(ex_mem_write_reg),
    .out_pcs(ex_mem_pcs),
    .out_src_reg1(ex_mem_src_reg1),
    .out_src_reg2(ex_mem_src_reg2),
    .out_dst_reg(ex_mem_dst_reg),
    .out_alu_out(ex_mem_alu_out),
    .out_src2_data(ex_mem_src2_data),
    .out_halt(ex_mem_halt),
    .out_pc_nxt(ex_mem_pc_nxt)
  );
// --------------------------------------

// ---------- MEM ------------
assign mem_enable = ex_mem_mem_write | ex_mem_mem_read;

memory1c_data #(.DWIDTH(DWIDTH), 
                .AWIDTH(AWIDTH)
                ) data_mem (.data_out(mem_data),
                        .data_in(ex_mem_src2_data),
                        .addr(ex_mem_alu_out),
                        .enable(mem_enable),
                        .wr(ex_mem_mem_write),
                        .clk(clk),
                        .rst(rst)
                        );
// ---------------------------

// ----------- MEM-WB Pipeline -------------

wire [15:0] mem_wb_alu_out, mem_wb_mem_data, mem_wb_pc_nxt;
wire mem_wb_mem_to_reg, mem_wb_write_reg, mem_wb_pcs, mem_wb_hlt;

mem_wb_pipe  mem_wb_pipe_inst (
    .clk(clk),
    .rst(rst),
    .en(en),
    .in_mem_to_reg(ex_mem_mem_to_reg),
    .in_write_reg(ex_mem_write_reg),
    .in_pcs(ex_mem_pcs),
    .in_alu_out(ex_mem_alu_out),
    .in_mem_data(mem_data),
    .in_halt(ex_mem_halt),
    .in_pc_nxt(ex_mem_pc_nxt),
    .out_mem_to_reg(mem_wb_mem_to_reg),
    .out_write_reg(mem_wb_write_reg),
    .out_pcs(mem_wb_pcs),
    .out_alu_out(mem_wb_alu_out),
    .out_mem_data(mem_wb_mem_data),
    .out_halt(mem_wb_halt),
    .out_pc_nxt(mem_wb_pc_nxt)
    );

// ------------------------------------------



// ---------- WB ------------
assign dst_data = (mem_wb_pcs)? mem_wb_pc_nxt: (mem_wb_mem_to_reg)? mem_wb_mem_data: mem_wb_alu_out;
// ---------------------------

endmodule