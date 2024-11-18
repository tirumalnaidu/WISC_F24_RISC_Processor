// WISC-FA24 Processor Phase-2
// Authors: 
//          - Tirumal Naidu
//          - Yash Deshpande
//          - Balaji Adithya

// forwarding - done
// hazard - detection; resolve (what pc to take)?
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

// hazard unit
wire pc_wen;
wire if_id_wen;
wire if_id_flush;
wire control_hazard;


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

//
wire [15:0] pc_branch; // output from the pc-control block
//


// Forwarding Select Lines
wire [1:0] forwardA_ALU;
wire [1:0] forwardB_ALU;
wire forward_BRANCH;
wire forward_MEM;

wire [15:0] forwardA_data;
wire [15:0] forwardB_data;
wire [15:0] forwardMEM_data;

// ---------- IF ------------
wire [15:0] pc_hlt;
wire [15:0] pc_plus_two;
wire [15:0] pc_if_stage;
wire [3:0] opcode;
wire if_stage_hlt;
wire stall;

pc_update pc_up(.clk(clk), 
                .rst(rst), 
                .pc_in(pc_if_stage), 
                .pc_wen(pc_wen),
                .pc_out(pc_cur)
                );

assign opcode = instr[15:12];
assign if_stage_hlt = &opcode;
assign pc_hlt = pc_cur;
addsub_16bit pc_incr(.a_in(pc_cur), .b_in(TWO), .is_sub(1'b0), .sum_out(pc_plus_two), .flag(/*unconnected*/));

assign pc_if_stage = (/* TODO: from ctrl_hazard*/ 1'b0)? pc_branch: (if_stage_hlt | stall)? pc_hlt: pc_plus_two;

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
// wire if_id_flush;

// DONE: Comment - we need to propagate the flush to next pipeline stages also
if_id_pipe  if_id_pipe_inst (
    .clk(clk),

    .rst(rst),        //TODO: flush
    .en(~stall),      //TODO: stall 

    // .in_flush(if_id_flush),

    .in_instr(instr),
    .in_pc_nxt(pc_if_stage),
    .out_instr(if_id_instr),
    .out_pc_nxt(if_id_pc_nxt)
  );

// --------------------------------------

// ---------- ID ------------
// Glue Logic for pc_control
wire [3:0] id_opcode;
assign id_opcode = if_id_instr[15:12];
assign branch_type = (halt)? 2'b11:(pcs)? 2'b10:(branch & branchr)? 2'b01: 2'b00;


hazard_detection_unit hazard_unit(
    .clk(clk),
    .rst(rst),
    .id_ex_mem_read(id_ex_mem_read),
    .id_ex_reg_write(id_ex_mem_write),
    .ex_mem_reg_write(ex_mem_write_reg),
    .if_id_mem_write(mem_write),          // directly from control signal
    .if_id_rs(src_reg1),
    .if_id_rt(src_reg2),
    .id_ex_rd(id_ex_dst_reg),
    .ex_mem_rd(ex_mem_dst_reg),
    .pc_wen(pc_wen),                  // to : pc_update -> write_enable signal to pc_update register
    .if_id_wen(if_id_wen),               // to : if_id_pipe -> write_enable signal to the IF/ID. pipeline register
    .branch(branch),
    .branchr(branchr),
    .opcode(if_id_instr[15:12]),
    .stall(stall),

    .id_ex_flag_en(id_ex_flag_en),
    .ex_mem_flag_en(ex_mem_flag_en),
    .condition(if_id_instr[11:9]),
    .if_id_flush(if_id_flush),             // to : if_id_pipe -> flush the if_id pipeline register
    .control_hazard(control_hazard)           // to : pc_if_stage mux -> on detecting a hazard, pc will contain branch address
);




pc_control pc_ctrl( .c(if_id_instr[11:9]),
                    .f(flag_reg_out),       //TODO: Should not use this flag_reg_out -> must use the one propagated till WB
                    .i(if_id_instr[8:0]),
                    .target(src1_data),
                    .branch(branch),
                    .pcs(pcs),
                    .hlt(halt),
                    .branch_type(branch_type),
                    .pc_in(if_id_pc_nxt), 
                    .pc_out(pc_branch)
                    );

assign src_reg1 = (llb_en | hlb_en) ? if_id_instr[11:8] : if_id_instr[7:4];
assign src_reg2 = (mem_write | mem_read) ? if_id_instr[11:8] : if_id_instr[3:0];
assign dst_reg = if_id_instr[11:8];

register_file regfile(
    .clk(clk),
    .rst(rst),
    .src_reg1(src_reg1),
    .src_reg2(src_reg2),
    .dst_reg(mem_wb_dst_reg),
    .write_reg(mem_wb_write_reg),
    .dst_data(dst_data),
    .src1_data(src1_data),
    .src2_data(src2_data)
);
 
control_unit cpu_ctrl(
    .opcode(id_opcode),
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

// DONE hlt signal to be given at the WB stage only
// assign hlt = halt;
// ---------------------------

// ----------- ID/EX Pipeline -------------
wire id_ex_mem_read, id_ex_mem_write, id_ex_mem_to_reg, id_ex_write_reg, id_ex_alu_src, id_ex_pcs, id_ex_halt, id_ex_reg_dst;
wire [15:0] id_ex_pc_nxt, id_ex_sign_ext_imm, id_ex_src1_data, id_ex_src2_data;
wire [3:0] id_ex_opcode, id_ex_src_reg1, id_ex_src_reg2, id_ex_dst_reg;    
wire [2:0] id_ex_flag_en;

id_ex_pipe  id_ex_pipe_inst (
    .clk(clk),
    .rst(rst), //DONE: flush - use the flush propagated from if_id_stage (need to add)
    .en(~stall), //TODO: stall - generated from load-to-use and branch-based stalls (Check Ex 10/15 conditions-1 & 2)

    // IN - Control
    .in_mem_read(mem_read),
    .in_mem_write(mem_write),
    .in_mem_to_reg(mem_to_reg),
    .in_write_reg(write_reg),
    .in_alu_src(alu_src),
    .in_pcs(pcs),
    .in_halt(halt),
    .in_opcode(id_opcode),
    .in_reg_dst(reg_dst),

    // IN - Flag related
    .in_flag_en(flag_en),

    // IN - PC
    .in_pc_nxt(if_id_pc_nxt), // latching from if-id pipe

    // IN - Reg
    .in_src_reg1(src_reg1),
    .in_src_reg2(src_reg2),
    .in_dst_reg(dst_reg),

    // IN - Data
    .in_sign_ext_imm(sign_ext_imm),
    .in_src1_data(src1_data),
    .in_src2_data(src2_data),

    // OUT - Control
    .out_mem_read(id_ex_mem_read),
    .out_mem_write(id_ex_mem_write),
    .out_mem_to_reg(id_ex_mem_to_reg),
    .out_write_reg(id_ex_write_reg),
    .out_alu_src(id_ex_alu_src),
    .out_pcs(id_ex_pcs),
    .out_halt(id_ex_halt),
    .out_opcode(id_ex_opcode),
    .out_reg_dst(id_ex_reg_dst),

    // OUT - Flag Related
    .out_flag_en(id_ex_flag_en),

    // OUT - PC
    .out_pc_nxt(id_ex_pc_nxt),

    // OUT - Reg
    .out_src_reg1(id_ex_src_reg1),
    .out_src_reg2(id_ex_src_reg2),
    .out_dst_reg(id_ex_dst_reg),

    // OUT - Data
    .out_sign_ext_imm(id_ex_sign_ext_imm),
    .out_src1_data(id_ex_src1_data),
    .out_src2_data(id_ex_src2_data),

    // OUT - Flush
    .out_flush(id_ex_flush)
  );

// ----------------------------------------

// ---------- EX ------------
// assign forwardA_data = (~forwardA_ALU[1] & ~forwardA_ALU[0])? id_ex_src1_data: (~forwardA_ALU[1] & forwardA_ALU[0])? dst_data: ex_mem_alu_out;
// assign forwardB_data = (~forwardB_ALU[1] & ~forwardB_ALU[0])? id_ex_src2_data: (~forwardB_ALU[1] & forwardB_ALU[0])? dst_data: ex_mem_alu_out;

assign forwardA_data = (forwardA_ALU == 2'b10) ? ex_mem_alu_out : (forwardA_ALU == 2'b01) ? dst_data : id_ex_src1_data;
assign forwardB_data = (forwardB_ALU == 2'b10) ? ex_mem_alu_out : (forwardB_ALU == 2'b01) ? dst_data : id_ex_src2_data;

assign alu_in1 = (id_ex_mem_read | id_ex_mem_write) ? (forwardA_data & 16'hFFFE) : forwardA_data;
assign alu_in2 = id_ex_alu_src ? id_ex_sign_ext_imm : forwardB_data;

//assign alu_in1 = (id_ex_mem_read | id_ex_mem_write) ? (id_ex_src1_data & 16'hFFFE) : id_ex_src1_data;
//assign alu_in2 = id_ex_alu_src ? id_ex_sign_ext_imm : id_ex_src2_data;


alu_16bit alu(.alu_in1(alu_in1),
              .alu_in2(alu_in2),
              .opcode(id_ex_opcode),
              .alu_out(alu_out),
              .flag(flag)  // {sign, ovfl, zero};
        );

// DONE: flag register for pc_control - shift to the end (@ WB stage)
// dff ff0(.q(flag_reg_out[0]), .d(flag[0]), .wen(id_ex_flag_en[0]), .clk(clk), .rst(rst));
// dff ff1(.q(flag_reg_out[1]), .d(flag[1]), .wen(id_ex_flag_en[1]), .clk(clk), .rst(rst));
// dff ff2(.q(flag_reg_out[2]), .d(flag[2]), .wen(id_ex_flag_en[2]), .clk(clk), .rst(rst));

// ---------------------------

// ----------- EX-MEM PIPELINE--------------
wire ex_mem_mem_read, ex_mem_mem_write, ex_mem_mem_to_reg, ex_mem_write_reg, ex_mem_pcs, ex_mem_halt;
wire [15:0] ex_mem_alu_out, ex_mem_src1_data, ex_mem_src2_data, ex_mem_pc_nxt;
wire [3:0] ex_mem_src_reg1, ex_mem_src_reg2, ex_mem_dst_reg;    
wire [2:0] ex_mem_flag, ex_mem_flag_en;

ex_mem_pipe  ex_mem_pipe_inst (
    .clk(clk),
    .rst(rst),  //DONE: flush - use the flush propagated from id_ex_stage (need to add)
    .en(1'b1),    //TODO: stall - No stall needed from here on?
    
    // IN - Control
    .in_mem_read(id_ex_mem_read),
    .in_mem_write(id_ex_mem_write),
    .in_mem_to_reg(id_ex_mem_to_reg),
    .in_write_reg(id_ex_write_reg),
    .in_pcs(id_ex_pcs),
    .in_halt(id_ex_halt),

    // IN - Reg
    .in_src_reg1(id_ex_src_reg1),
    .in_src_reg2(id_ex_src_reg2),
    .in_dst_reg(id_ex_dst_reg),

    // IN - Data
    .in_alu_out(alu_out),
    .in_src1_data(id_ex_src1_data), 
    .in_src2_data(id_ex_src2_data), // DONE: What about SRC1 data?

    // IN - PC
    .in_pc_nxt(id_ex_pc_nxt),

    // IN - Flag
    // DONE: Add registers with respect to flags (enable and the computed flag values as well)
    .in_flag(flag),
    .in_flag_en(id_ex_flag_en),




    // OUT - Control
    .out_mem_read(ex_mem_mem_read),
    .out_mem_write(ex_mem_mem_write),
    .out_mem_to_reg(ex_mem_mem_to_reg),
    .out_write_reg(ex_mem_write_reg),
    .out_pcs(ex_mem_pcs),
    .out_halt(ex_mem_halt),

    // OUT - Reg
    .out_src_reg1(ex_mem_src_reg1),
    .out_src_reg2(ex_mem_src_reg2),
    .out_dst_reg(ex_mem_dst_reg),

    // OUT - Data
    .out_alu_out(ex_mem_alu_out),
    .out_src1_data(ex_mem_src1_data),
    .out_src2_data(ex_mem_src2_data),

    // OUT - PC
    .out_pc_nxt(ex_mem_pc_nxt),

    // OUT - Flag
    // DONE:
    .out_flag(ex_mem_flag),
    .out_flag_en(ex_mem_flag_en)
  );
// --------------------------------------

// ---------- MEM ------------
assign mem_enable = ex_mem_mem_write | ex_mem_mem_read;
assign forwardMEM_data = (forward_MEM)? dst_data: ex_mem_src2_data;

memory1c_data #(.DWIDTH(DWIDTH), 
                .AWIDTH(AWIDTH)
                ) data_mem (.data_out(mem_data),
                        .data_in(forwardMEM_data),
                        .addr(ex_mem_alu_out),
                        .enable(mem_enable),
                        .wr(ex_mem_mem_write),
                        .clk(clk),
                        .rst(rst)
                        );
// ---------------------------

// ----------- MEM-WB Pipeline -------------
wire [15:0] mem_wb_alu_out, mem_wb_mem_data, mem_wb_pc_nxt;
wire [3:0] mem_wb_src_reg1, mem_wb_src_reg2, mem_wb_dst_reg;
wire mem_wb_mem_to_reg, mem_wb_write_reg, mem_wb_pcs, mem_wb_hlt;
wire [2:0] mem_wb_flag, mem_wb_flag_en;

mem_wb_pipe  mem_wb_pipe_inst (
    .clk(clk),
    .rst(rst),  // Flush - needs to propagate from previous stage - ex_mem_pipe
    .en(1'b1),    // Stall - no need right? (never stalls)

    // IN - Control
    .in_mem_to_reg(ex_mem_mem_to_reg),
    .in_write_reg(ex_mem_write_reg),
    .in_pcs(ex_mem_pcs),
    .in_halt(ex_mem_halt),

    // IN - Data
    .in_alu_out(ex_mem_alu_out),
    .in_mem_data(mem_data),

    // IN - PC
    .in_pc_nxt(ex_mem_pc_nxt),

    // IN - Flag
    // DONE
    .in_flag(ex_mem_flag),
    .in_flag_en(ex_mem_flag_en),

    // IN - Reg
    // DONE: Needed for fwd logic
    .in_src_reg1(ex_mem_src_reg1),
    .in_src_reg2(ex_mem_src_reg2),
    .in_dst_reg(ex_mem_dst_reg),

    // OUT - Control
    .out_mem_to_reg(mem_wb_mem_to_reg),
    .out_write_reg(mem_wb_write_reg),
    .out_pcs(mem_wb_pcs),
    .out_halt(mem_wb_halt),

    // OUT - Data
    .out_alu_out(mem_wb_alu_out),
    .out_mem_data(mem_wb_mem_data),

    // OUT - PC
    .out_pc_nxt(mem_wb_pc_nxt),

    // OUT - Flag
    // DONE
    .out_flag(mem_wb_flag),
    .out_flag_en(mem_wb_flag_en),

    // OUT - Reg
    // DONE: Needed for fwd logic
    .out_src_reg1(mem_wb_src_reg1),
    .out_src_reg2(mem_wb_src_reg2),
    .out_dst_reg(mem_wb_dst_reg)

    );

// ------------------------------------------

// ---------- WB ------------
// TODO: Shift pcs operation to ALU unit itself -> assign the value within ALU (and give output via alu_out); 
// don't have to propagate PCS signal till here
assign dst_data = (mem_wb_pcs)? mem_wb_pc_nxt: (mem_wb_mem_to_reg)? mem_wb_mem_data: mem_wb_alu_out;
assign hlt = mem_wb_halt;
// ---------------------------

// Forwarding Unit
forward_unit fwd(
    .if_id_rs(src_reg1),
    .if_id_rt(src_reg2),
    .if_id_branch(1'b0),    //TODO: Whenever there's a branch? Or should there be extra check?

    .id_ex_rs(id_ex_src_reg1),
    .id_ex_rt(id_ex_src_reg2),
    .id_ex_rd(id_ex_dst_reg),
    .id_ex_write_reg(id_ex_write_reg),
    .id_ex_reg_dst(id_ex_reg_dst),
    .id_ex_alu_src(id_ex_alu_src),

    .ex_mem_rs(ex_mem_src_reg1),
    .ex_mem_rt(ex_mem_src_reg2),
    .ex_mem_rd(ex_mem_dst_reg),
    .ex_mem_write_reg(ex_mem_write_reg),

    .mem_wb_rs(mem_wb_src_reg1),
    .mem_wb_rt(mem_wb_src_reg2),
    .mem_wb_rd(mem_wb_dst_reg),
    .mem_wb_write_reg(mem_wb_write_reg),

    .forwardA_ALU(forwardA_ALU),
    .forwardB_ALU(forwardB_ALU),
    .forward_MEM(forward_MEM),
    .forward_BRANCH(forward_BRANCH)
);

endmodule