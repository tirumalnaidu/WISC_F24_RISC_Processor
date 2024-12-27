`timescale 1ns / 1ps

// Top-level testbench for ECE 552 cpu.v Phase 2
module phase3_cpu_tb ();
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
    repeat (3) @(negedge clk);
    rst <= 0;
  end

wire icache_req, icache_hit;
wire dcache_req, dcache_hit;

  cache_trace_p3 icache_trace_p3 (

.clk(clk),

.rst(rst),

.enable(DUT.memory_inst.i_read_en),

.addr(DUT.memory_inst.i_addr),

.stall(DUT.memory_inst.i_stall),

.req(icache_req),

.hit(icache_hit),

.miss(),

.halt(DUT.halt)

);



cache_trace_p3 dcache_trace_p3 (

.clk(clk),

.rst(rst),

.enable(DUT.memory_inst.d_read_en),

.addr(DUT.memory_inst.d_addr),

.stall(DUT.memory_inst.d_stall),

.req(dcache_req),

.hit(dcache_hit),

.miss(),

.halt(DUT.halt)

);

  // Assign internal signals - See wisc_trace_p3.v for instructions.
  // Edit the example below. You must change the signal names on the right hand side to match your naming convention.
  wisc_trace_p3 wisc_trace_p3 (
      .clk(clk),
      .rst(rst),
      .PC(PC),
      .Halt(Halt),
      .Inst(DUT.instr),
      .RegWrite(DUT.regfile.write_reg),
      .WriteRegister(DUT.regfile.dst_reg),
      .WriteData(DUT.regfile.dst_data),
      .MemRead(DUT.mem_read),
      .MemWrite(DUT.mem_write),
      .MemAddress(DUT.memory_inst.d_addr),
      .MemDataIn(DUT.memory_inst.data_in),
      .MemDataOut(DUT.memory_inst.d_data_out),
      .icache_req(icache_req),
      .icache_hit(icache_hit),
      .dcache_req(dcache_req),
      .dcache_hit(dcache_hit)
  );

  /* Add anything else you want here */

endmodule



module cache_trace_p3 (

input clk,

input rst,

input enable,

input [15:0] addr,

input stall,

input halt,

output req,

output hit,

output miss

);



reg [15:0] addr_d;

reg stall_d, rst_d;



always @(posedge clk) begin

rst_d <= rst;

if (rst) begin

addr_d <= 16'h0;

end else begin

addr_d <= addr;

end

end



wire tracking_enabled = ~rst & enable;

wire addr_changed = addr != addr_d;

// req: not halt or reset, but either clock came out of reset or address changed, and enable.

assign req  = tracking_enabled & (rst_d | addr_changed);

// Hit is defined as enable/stall and it didn't just stop stalling,

// as the first clock after stall drop is the miss now "hitting".

assign hit  = tracking_enabled & ~stall & addr_changed;

assign miss = req & ~hit;



endmodule  // hit_detect

