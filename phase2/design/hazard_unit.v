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

wire l2u_stall;
reg br_flag_stall_reg;
wire br_flag_stall;
wire br_rs_stall;
// wire if_id_flush;

// --- Stall for everything other than branch ----
assign stall = (id_ex_mem_read) & ((id_ex_rd == if_id_rs) | (id_ex_rd == if_id_rt));
// ----------------------------------------

reg flag_change;
wire rs_change;

localparam ADD = 4'b0000;
localparam SUB = 4'b0001;
localparam XOR = 4'b0010;
localparam SLL = 4'b0100;
localparam SRA = 4'b0101;
localparam ROR = 4'b0110;

// For Branch stalls ---------------------------------------
// ID/EX or EX/MEM has RAW dependence rd update; if in MEM/WB -> can forward it using register bypass
//assign rs_change = ((id_ex_reg_write) & (id_ex_rd != 4'b0000) & (if_id_rs == id_ex_rd)) | ((ex_mem_reg_write) & (ex_mem_rd != 4'b0000) & (if_id_rs == ex_mem_rd));

/*always@(*) begin
    case(opcode)
        ADD, SUB, XOR, SLL, SRA, ROR: flag_change = 1;
        default:    flag_change = 0;
    endcase
end*/

// ----------------------------------------------------------


wire branch_condition;
assign branch_condition = branch | branchr;

// load-to-use stalls : COD pg314
// change this according to hw4
/*assign l2u_stall =  ((id_ex_mem_read==1) & 
                    (id_ex_rd != 4'b0000)) & 
                    ((if_id_rs==id_ex_rd) | ((if_id_rt==id_ex_rd) & (!if_id_mem_write)))? 1'b1 : 1'b0;*/

// branching stalls -> branch follows some instruction

// condition-1 : previous instruction modifies flags
/*always @ (*) begin
	case(condition)
		3'b000: br_flag_stall_reg = (id_ex_flag_en[`FLAG_Z] | ex_mem_flag_en[`FLAG_Z])? 1'b1: 1'b0;								    // Z=0
		3'b001: br_flag_stall_reg = (id_ex_flag_en[`FLAG_Z] | ex_mem_flag_en[`FLAG_Z])? 1'b1: 1'b0;								    // Z=1
		3'b010: br_flag_stall_reg = ((id_ex_flag_en[`FLAG_Z] | id_ex_flag_en[`FLAG_N]) | (ex_mem_flag_en[`FLAG_Z] | ex_mem_flag_en[`FLAG_N]))? 1'b1: 1'b0;					// Z==N==0
        3'b011: br_flag_stall_reg = ((id_ex_flag_en[`FLAG_N] | ex_mem_flag_en[`FLAG_N]))? 1'b1: 1'b0;								// N==1
        3'b100: br_flag_stall_reg = ((id_ex_flag_en[`FLAG_Z] | id_ex_flag_en[`FLAG_N]) | (ex_mem_flag_en[`FLAG_Z] | ex_mem_flag_en[`FLAG_N]))? 1'b1: 1'b0;	// Z==1 or Z==N==0
		3'b101: br_flag_stall_reg = ((id_ex_flag_en[`FLAG_Z] | id_ex_flag_en[`FLAG_N]) | (ex_mem_flag_en[`FLAG_Z] | ex_mem_flag_en[`FLAG_N]))? 1'b1: 1'b0;					// N==1 or Z==1
		3'b110: br_flag_stall_reg = ((id_ex_flag_en[`FLAG_V]) | (ex_mem_flag_en[`FLAG_V]))? 1'b1: 1'b0;								// V==1
		3'b111: br_flag_stall_reg = 1'b0;													                                        // Unconditional
		default: br_flag_stall_reg = 1'b0;
	endcase
end*/

//assign br_flag_stall = branch_condition & br_flag_stall_reg & flag_change;
//assign br_rs_stall = branch_condition & rs_change;
//assign br_rs_stall = branch_condition;
assign if_id_flush = branch_condition & br_taken;
//assign control_stall = br_flag_stall | br_rs_stall;

// condition-2 : previous instruction changes values in rs register
//assign br_rs_stall =    ((id_ex_reg_write) & (id_ex_rd != 4'b0000) & (if_id_rs == id_ex_rd))? 1'b1 :
                        //(ex_mem_reg_write) & (ex_mem_rd != 4'b0000) & (if_id_rs == ex_mem_rd)? 1'b1 : 1'b0;

//wire out_l2u_stall, out_br_flag_stall, out_br_rs_stall, wire_if_id_flush;

/*pldff #(.WIDTH(1)) l2u_stall_pldff (.d(l2u_stall), .q(out_l2u_stall), .wen(1'b1), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) br_flag_stall_pldff (.d(br_flag_stall), .q(out_br_flag_stall), .wen(1'b1), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) br_bs_stall_pldff (.d(1'b0), .q(out_br_rs_stall), .wen(1'b1), .clk(clk), .rst(rst));
pldff #(.WIDTH(1)) if_id_flush_pldff (.d(wire_if_id_flush), .q(if_id_flush), .wen(1'b1), .clk(clk), .rst(rst));*/

// stall the pipeline
//assign pc_wen = (out_l2u_stall | out_br_flag_stall| out_br_rs_stall)? 1'b0: 1'b1;
//assign if_id_wen = (out_l2u_stall | out_br_flag_stall| out_br_rs_stall)? 1'b0: 1'b1;

// flush the instruction in IF stage -> flush if_id pipeline
// assign wire_if_id_flush = (branch_condition & (out_br_flag_stall & out_br_rs_stall))? 1'b1: 1'b0;
// assign control_hazard = (branch_condition | ~if_id_flush) ? 1'b1: 1'b0;

endmodule

/*
Load-to-Use Stall  
e.g.  sub after load
1. load is in ex stage so gets its register values from id_ex pipeline register
2. sub is in decode so gets its values from the if_id pipeline register


*/


