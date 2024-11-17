module hazard_detection_unit(

    input id_ex_mem_read,
    input if_id_rs,
    input if_id_rt,
    input id_ex_rt,
    
    output pc_wen,            // write_enable signal to pc_update register
    output if_id_wen,         // write_enable signal to the IF/ID. pipeline register

    input branch,
    input branchr,

    output global_stall                // global stall if needed  

);

wire stall

// load-to-use stalls : COD pg314
assign stall = (id_ex_mem_read==1)? 
               (if_id_rs==id_ex_rt) | (if_id_reg_rt==id_ex_rt)? 1'b1 : 1'b0;

// branching stalls according to changes in flag register value



// stall the pipeline
assign pc_wen = ~stall;
assign if_id_wen = ~stall;

endmodule

/*
Load-to-Use Stall  
e.g.  sub after load
1. load is in ex stage so gets its register values from id_ex pipeline register
2. sub is in decode so gets its values from the if_id pipeline register


*/


