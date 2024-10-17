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
localparam DWIDTH = 16;
localparam AWIDTH = 16;

// IF
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

pc_control pc_ctrl( .c(),
                    .f(),
                    .i(),
                    .target(),
                    .branch(),
                    .branch_type(),
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
control cpu_ctrl();

// EX
alu alu();
alu_control alu_ctrl();


// M
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