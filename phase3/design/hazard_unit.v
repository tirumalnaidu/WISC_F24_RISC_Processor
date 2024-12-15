// `include "common/flags.vh"
module hazard_detection_unit(

// ---- control signals for load-to-use type stall ---- 
    input clk,
    input rst,

    input id_ex_mem_read,
    input id_ex_reg_write,
    input ex_mem_reg_write,
    input if_id_mem_write,          // directly from control signal
    
    input [3:0] if_id_rs,
    input [3:0] if_id_rt,
    input [3:0] id_ex_rd,
    input [3:0] ex_mem_rd,

    input br_taken,
    
    output pc_wen,                  // to : pc_update -> write_enable signal to pc_update register
    output if_id_wen,               // to : if_id_pipe -> write_enable signal to the IF/ID. pipeline register

    input branch,
    input branchr,
    input [3:0] opcode,
    // input [3:0] condition,
    input [2:0] id_ex_flag_en,
    input [2:0] ex_mem_flag_en,
    input [2:0] condition,

    // output global_stall,         // global stall if needed
    output if_id_flush,             // to : if_id_pipe -> flush the if_id pipeline register
    output control_stall,          // to : pc_if_stage mux -> on detecting a hazard, pc will contain branch address
    output stall
);



// --- Stall for everything other than branch ----
assign stall = (id_ex_mem_read) & ((id_ex_rd == if_id_rs) | (id_ex_rd == if_id_rt));
// ----------------------------------------


assign if_id_flush = branch & br_taken;


endmodule




