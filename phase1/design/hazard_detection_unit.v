module hazard_detection_unit(

    // ---------- Maybe Not Needed ------------
    input [3:0] ifid_reg_rs,
    input [3:0] ifid_reg_rt, 

    input [3:0] idex_write_reg,
    input [3:0] exmem_write_reg,
    input [3:0] memwb_write_reg,

    input idex_reg_write,
    input exmem_reg_write,
    input memwb_reg_write,

    // ---------- Maybe Not Needed ------------

    input idex_mem_read,
    
    output pc_write,            // write_enable signal to pc_update register
    output ifid_write           // write_enable signal to the IF/ID. pipeline register

    output stall                // global stall if needed  

);

// forwarding
assign stall = (idex_reg_write==1 && ifid_reg_rs==idex_write_reg)? 1'b1 : 
               (idex_reg_write==1 && ifid_reg_rt==idex_write_reg)? 1'b1 : 
               (exmem_reg_write==1 && ifid_reg_rs==exmem_write_reg)? 1'b1 : 
               (exmem_reg_write==1 && ifid_reg_rt==exmem_write_reg)? 1'b1 : 
               (memwb_reg_write==1 && ifid_reg_rs==memwb_write_reg)? 1'b1 : 
               (memwb_reg_write==1 && ifid_reg_rt==memwb_write_reg)? 1'b1 : 1'b0;


// load-to-use stalls
assign stall = (idex_mem_read==1 && ifid_reg_rs==idex_write_reg)? 1'b1 : 
               (idex_mem_read==1 && ifid_reg_rt==idex_write_reg)? 1'b1 : 1'b0

endmodule