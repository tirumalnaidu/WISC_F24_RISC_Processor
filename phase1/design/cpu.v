// WISC-FA24 Processor
// Authors: 
//          - Tirumal Naidu
//          - Yash Deshpande
//          - Balaji Adithya

module cpu(
    input clk,
    input rst,
    output hlt,
    output [15:0] pc
);

// Local parameters
localparam DWIDTH = 16;
localparam AWIDTH = 16;

// PC
wire [15:0] pc_cur;
wire [15:0] pc_nxt;

// Control signals
wire reg_dst;
wire reg_write;
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
pc_update pc_up(.clk(clk), 
                .rst(rst), 
                .pc_in(pc_nxt), 
                .pc_out(pc_cur)
                );

wire instr[DWIDTH-1:0];

memory1c_instr #(   .DWIDTH(DWIDTH), 
                    .AWIDTH(AWIDTH)
                ) imem (.data_out(instr), 
                        .data_in(), 
                        .addr(pc_cur), 
                        .enable(), 
                        .wr(), 
                        .clk(clk), 
                        .rst(rst)
                        );

// Glue Logic for pc_control
wire [1:0] branch_type;
assign branch_type = (hlt)? 2'b11:(pcs)? 2'b10:(branch & branchr)? 2'b01: 2'b00;

pc_control pc_ctrl( .c(instr[11:9]),
                    .f(flag_reg_out),
                    .i(instr[8:0]),
                    .target(),
                    .branch(branch),
                    .branch_type(branch_type),
                    .pc_in(pc_cur),
                    .pc_out(pc_nxt)
                    );

wire [3:0] src1_data, src2_data, dst_data;

// ---------- ID ------------
wire [2:0] src_reg1, src_reg2, dst_reg;

assign src_reg1 = instr[7:4];
assign src_reg2 = (mem_write | mem_read) ? instr[11:8] : instr[3:0];
assign dst_reg = instr[11:8];

register_file regfile(
    .clk(clk),
    .rst(rst),
    .src_reg1(src_reg1),
    .src_reg2(src_reg2),
    .dst_reg(dst_reg),
    .write_reg(reg_write),
    .dst_data(dst_data),
    .src_data1(src1_data),
    .src_data2(src2_data)
);
 
control_unit cpu_ctrl(
    .opcode(instr[15:12]),
    .reg_dst(reg_dst),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .llb_en(llb_en),
    .hlb_en(hlb_en),
    .branch(branch),
    .branchr(branchr),
    .pcs(),
    .halt(halt)
);

assign hlt = halt;
// ---------------------------


// ---------- EX ------------
wire [2:0] flag;
wire [15:0] alu_in1, alu_in2, alu_out;
wire [15:0] sign_ext_imm;

// for mem read or write, addr = (Reg[ssss] & 0xFFFE) + (sign-extend(oooo) << 1).
// three diff ext - (lw, sw), (llb, hlb), (sll, srl, ror)
assign sign_ext_imm = (mem_read | mem_write) ? ({{12{1'b0}}, instr[3:0]} << 1) : 
                        (llb_en) ? {{8{1'b0}},instr[7:0]} : 
                        (hlb_en) ? {instr[7:0], {8{1'b0}}} : 
                        {{12{1'b0}},instr[3:0]}; // for sll, srl, ror

assign alu_in1 = src1_data;
assign alu_in2 = alu_src ? sign_ext_imm : src2_data;

alu_16bit alu(.alu_in1(alu_in1),
        .alu_in2(alu_in2),
        .opcode(instr[15:12]),
        .alu_out(alu_out),
        .flag(flag)  // {sign, ovfl, zero};
        );

input [2:0] en;
input [2:0] flag_reg_out;

// flag register for pc_control
dff ff0(.q(flag_reg_out[0]), .d(flag[0]), .wen(en[0]), .clk(clk), .rst(rst));
dff ff1(.q(flag_reg_out[1]), .d(flag[1]), .wen(en[1]), .clk(clk), .rst(rst));
dff ff2(.q(flag_reg_out[2]), .d(flag[2]), .wen(en[2]), .clk(clk), .rst(rst));

// ---------------------------


// ---------- MEM ------------
wire [15:0] mem_data;
memory1c_data #(.DWIDTH(DWIDTH), 
                .AWIDTH(AWIDTH)
                ) dmem (.data_out(mem_data),
                        .data_in(src2_data),
                        .addr(alu_out),
                        .enable(mem_read),
                        .wr(mem_write),
                        .clk(clk),
                        .rst(rst)
                        );
// ---------------------------


// ---------- WB ------------
assign dst_data = mem_to_reg ? mem_data : alu_out;
// ---------------------------

endmodule