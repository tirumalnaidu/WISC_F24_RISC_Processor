module forward_unit(
    input [3:0] if_id_rs,
    input [3:0] if_id_rt,
    input if_id_branch,

    input [3:0] id_ex_rs,
    input [3:0] id_ex_rt,
    input [3:0] id_ex_rd,
    input id_ex_write_reg,

    input [3:0] ex_mem_rs,
    input [3:0] ex_mem_rt,
    input [3:0] ex_mem_rd,
    input ex_mem_write_reg,

    input [3:0] mem_wb_rs,
    input [3:0] mem_wb_rt,
    input [3:0] mem_wb_rd,
    input mem_wb_write_reg,

    output [1:0] forwardA_ALU,
    output [1:0] forwardB_ALU,
    output forward_MEM,
    output forward_BRANCH
 );

wire ex_ex_bypass_condition_A, ex_ex_bypass_condition_B;
wire mem_ex_bypass_condition_A, mem_ex_bypass_condition_B;
wire mem_mem_bypass_condition;
wire register_bypass_condition;

// Ex-to-Ex forwarding
// if(EX/MEM.RegWrite && EX/MEM.Rd != $0 && EX/MEM.Rd == ID/EX.Rs/Rt)
assign ex_ex_bypass_condition_A = (ex_mem_write_reg) & (|ex_mem_rd) & ~|(ex_mem_rd ^ id_ex_rs);
assign ex_ex_bypass_condition_B = (ex_mem_write_reg) & (|ex_mem_rd) & ~|(ex_mem_rd ^ id_ex_rt);

// Mem-to-Ex forwarding
// if(MEM/WB.RegWrite && MEM/WB.Rd != $0 && MEM/WB.Rd == ID/EX.Rs/Rt)
assign mem_ex_bypass_condition_A = (mem_wb_write_reg) & (|mem_wb_rd) & ~|(mem_wb_rd ^ id_ex_rs) & ~ex_ex_bypass_condition_A;
assign mem_ex_bypass_condition_B = (mem_wb_write_reg) & (|mem_wb_rd) & ~|(mem_wb_rd ^ id_ex_rt) & ~ex_ex_bypass_condition_B;

// Mem-to-Mem (load followed by a store); check only for Rt 
// (will need a stall in case of Rs as computation needs to be done on EX stage)
// if(MEM/WB.RegWrite && MEM/WB.Rd != $0 && MEM/WB.Rd == EX/MEM.Rt)
assign mem_mem_bypass_condition = (mem_wb_write_reg) & (|mem_wb_rd) & ~|(mem_wb_rd ^ ex_mem_rt);

// Register-Bypass (only used in case of dependent Branch instruction)
assign register_bypass_condition = (if_id_branch) & (mem_wb_write_reg) & (|mem_wb_rd) & ~|(mem_wb_rd ^ if_id_rs);

assign forwardA_ALU = (ex_ex_bypass_condition_A)? 2'b10:(mem_ex_bypass_condition_A)? 2'b01: 2'b00;
assign forwardB_ALU = (ex_ex_bypass_condition_B)? 2'b10:(mem_ex_bypass_condition_B)? 2'b01: 2'b00; 
assign forward_MEM = mem_mem_bypass_condition;
assign forward_BRANCH = register_bypass_condition;
endmodule