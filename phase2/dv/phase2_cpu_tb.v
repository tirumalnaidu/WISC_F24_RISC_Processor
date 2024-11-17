`timescale 1ns / 1ps

// Top-level testbench for ECE 552 cpu.v Phase 2
module phase2_cpu_tb ();
  localparam half_cycle = 50;

  // Signals that interface to the DUT.
  wire [15:0] PC;
  wire Halt;  /* Halt executed and in Memory or writeback stage */
  reg clk;  /* Clock input */
  reg rst;  /* (Active high) Reset input */

  // Instantiate the processor as Design Under Test.
  cpu DUT (
      .clk(clk),
      .rst(rst),
      .pc (PC),
      .hlt(Halt)
  );

  initial begin
    clk <= 1;
    forever #half_cycle clk <= ~clk;
  end

  initial begin
    rst <= 1;  /* Intial reset state */
    repeat (2) @(posedge clk);
    rst <= 0;
  end

  // Assign internal signals - See wisc_trace_p2.v for instructions.
  // Edit the example below. You must change the signal names on the right hand side to match your naming convention.
  wisc_trace_p2 wisc_trace_p2_inst (
      .clk(clk),
      .rst(rst),
      .PC(PC),
      .Inst(DUT.instr),
      .RegWrite(DUT.regfile.write_reg),
      .WriteRegister(DUT.regfile.dst_reg),
      .WriteData(DUT.regfile.dst_data),
      .MemRead(DUT.mem_read),
      .MemWrite(DUT.mem_write),
      .MemAddress(DUT.data_mem.addr),
      .MemDataIn(DUT.data_mem.data_in),
      .MemDataOut(DUT.data_mem.data_out)
  );

  /* Add anything else you want here */

endmodule