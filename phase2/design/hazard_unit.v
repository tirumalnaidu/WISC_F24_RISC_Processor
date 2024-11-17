module hazard_detection_unit(

    input id_ex_mem_read,
    input if_id_rs,
    input if_id_rt,
    input id_ex_rd,
    input ex_mem_rd,
    
    output pc_wen,            // write_enable signal to pc_update register
    output if_id_wen,         // write_enable signal to the IF/ID. pipeline register

    input branch,
    input branchr,
    input [3:0] opcode,
    input [2:0] id_ex_flag,
    input [2:0] ex_mem_flag,
    input [2:0] condtion,

    output global_stall                // global stall if needed  

);

wire l2u_stall;
reg br_flag_stall_reg;
reg br_flag_stall;
wire br_rs_stall;
wire if_id_flush;

wire branch_condition;

assign branch_condition = branch | branch;

// load-to-use stalls : COD pg314
assign l2u_stall = (id_ex_mem_read==1) & (id_ex_rd != 4'b0000)? 
                    (opcode != 4'b1001)?
               (if_id_rs==id_ex_rd) | (if_id_reg_rt==id_ex_rd)? 1'b1 : 1'b0;

// branching stalls -> branch follows some instruction

// condition-1 : previous instruction modifies flags
always @ (*) begin
	case(c)
		3'b000: br_flag_stall = (~id_ex_flag[`FLAG_Z] | ~ex_mem_flag[`FLAG_Z])? 1'b1: 1'b0;								// Z=0
		3'b001: br_flag_stall = (id_ex_flag[`FLAG_Z] | ex_mem_flag[`FLAG_Z])? 1'b1: 1'b0;								// Z=1


		3'b010: br_flag_stall = ((~id_ex_flag[`FLAG_Z] & ~id_ex_flag[`FLAG_N]) | (~ex_mem_flag[`FLAG_Z] & ~ex_mem_flag[`FLAG_N]))? 1'b1: 1'b0;					// Z==N==0
		
        3'b011: br_flag_stall = ((id_ex_flag[`FLAG_N] | ex_mem_flag[`FLAG_N]))? 1'b1: 1'b0;								// N==1
		
        3'b100: br_flag_stall = ((id_ex_flag[`FLAG_Z] | (~id_ex_flag[`FLAG_Z] & ~id_ex_flag[`FLAG_N])) | (ex_mem_flag[`FLAG_Z] | (~ex_mem_flag[`FLAG_Z] & ~f[`FLAG_N])))? 1'b1: 1'b0;	// Z==1 or Z==N==0
		3'b101: br_flag_stall = ((id_ex_flag[`FLAG_Z] | id_ex_flag[`FLAG_N]) | (ex_mem_flag[`FLAG_Z] | ex_mem_flag[`FLAG_N]))? 1'b1: 1'b0;					// N==1 or Z==1
		3'b110: br_flag_stall = ((id_ex_flag[`FLAG_V]) | (ex_mem_flag[`FLAG_V]))? 1'b1: 1'b0;								// V==1
		3'b111: br_flag_stall = 1'b1;													// Unconditional
		default: br_flag_stall = 1'b0;
	endcase
end

assign br_flag_stall = br_flag_stall_reg;

// condition-2 : previous instruction changes values in rs register
assign br_rs_stall = (id_ex_write_reg) & (id_ex_rd != 4'b0000) ? (if_id_rs == id_ex_rd)? 1'b1:
                         (ex_mem_write_reg) ?(if_id_rs == ex_mem_rd)? 1'b1:1'b0


// stall the pipeline
assign pc_wen = ~l2u_stall | ~br_flag_stall| ~br_rs_stall;
assign if_id_wen = ~l2u_stall | ~br_flag_stall| ~br_rs_stall;

// flush the instruction in IF stage -> flush if_id pipeline
assign if_id_flush = branch_condition;

endmodule

/*
Load-to-Use Stall  
e.g.  sub after load
1. load is in ex stage so gets its register values from id_ex pipeline register
2. sub is in decode so gets its values from the if_id pipeline register


*/


