// WISC-FA24 Processor
// Authors: 
//          - Tirumal Naidu
//          - Yash Deshpande
//          - Balaji Adithya

module cpu(
    /*INPUT*/
    input clk,
    input rst,

    /*OUTPUT*/
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


// IF
pc_update pc_up(.clk(clk), 
                .rst(rst), 
                .pc_in(pc_nxt), 
                .pc_out(pc_cur)
                );

memory1c_instr #(   .DWIDTH(DWIDTH), 
                    .AWIDTH(AWIDTH)
                ) imem (.data_out(), 
                        .data_in(), 
                        .addr(), 
                        .enable(), 
                        .wr(), 
                        .clk(clk), 
                        .rst(rst)
                        );

// Glue Logic for pc_control
wire [1:0] branch_type;
assign branch_type = (hlt)? 2'b11:(pcs)? 2'b10:(branch & branchr)? 2'b01: 2'b00;

pc_control pc_ctrl( .c(),
                    .f(),
                    .i(),
                    .target(),
                    .branch(branch),
                    .branch_type(branch_type),
                    .pc_in(),
                    .pc_out()
                    );

// ID
register_file regfile(.clk(clk),
                      .rst(rst),
                      .src_reg1(),
                      .src_reg2(),
                      .dst_reg(),
                      .write_reg(),
                      .dst_data(),
                      .src_data1(),
                      .src_data2()
                      );

control_unit cpu_ctrl(
    .opcode(),
    .reg_dst(),
    .reg_write(),
    .alu_src(),
    .mem_read(),
    .mem_write(),
    .mem_to_reg(),
    .llb_en(),
    .hlb_en(),
    .branch(),
    .branchr(),
    .pcs(),
    .halt()
);

// EX
alu_16bit alu(.alu_in1(),
        .alu_in2(),
        .opcode(),
        .alu_out(),
        .flag()
        );

alu_control alu_ctrl();

// MEM
memory1c_data #(.DWIDTH(DWIDTH), 
                .AWIDTH(AWIDTH)
                ) dmem (.data_out(),
                        .data_in(),
                        .addr(),
                        .enable(),
                        .wr(),
                        .clk(clk),
                        .rst(rst)
                        );

// WB

endmodule