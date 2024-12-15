module memory_system #(
    parameter DWIDTH = 16,
    parameter AWIDTH = 16
) (
    input clk,
    input rst,
    input wr,                                   // from the SW instruction -> to d_cache & memory 
    input rd,                                   // from the LW instruction -> to d_cache
    input enable,                               // decide when instantiating in cpu.v
    input [AWIDTH-1:0] addr_in,                 // from instruction
    input [DWIDTH-1:0] data_in,                 // from the SW instruction 

    output [DWIDTH-1:0] data_out,               // for all instructions -> select b/w d-cache/i-cache
    output d_cache_stall,                       // stalls full processor 
    output i_cache_stall                        // stalls only the IF stage
);

// --------------------- for main_memory ---------------------
wire memory_data_valid;
// wire [AWIDTH-1:0] memory_addr_in;
wire [DWIDTH-1:0] memory_data_in;
wire [DWIDTH-1:0] memory_data_out;

// --------------------- for i_cache ---------------------

wire i_cache_miss_detected;
wire [AWIDTH-1:0] i_cache_miss_addr;
wire [DWIDTH-1:0] i_cache_data_out;
wire i_cache_fsm_data_wen;
wire i_cache_fsm_tag_wen;

// --------------------- for d_cache ---------------------

wire d_cache_miss_detected;
wire [AWIDTH-1:0] d_cache_miss_addr;
wire [DWIDTH-1:0] d_cache_data_out;
wire d_cache_fsm_data_wen;
wire d_cache_fsm_tag_wen;

// --------------------- for cache_fill_fsm ---------------------
wire [AWIDTH-1:0] miss_address;
// wire miss_address;

assign memory_data_in = data_in;


memory4c #(.DWIDTH(DWIDTH),
           .AWIDTH(AWIDTH)
) main_memory(
    .data_in(memory_data_in),                   // from d-cache only
    .addr(miss_address),                        // only on miss -> either from d-cache / i-cache
    .enable(enable),
    .wr(wr & ~d_cache_miss_detected),           // from the SW instruction
    .clk(clk),
    .rst(rst),
    /*OUT*/
    .data_out(memory_data_out),                 // goes to d-cache & i-cache*
    .data_valid(memory_data_valid)
);

cache d_cache(
    .clk(clk),
    .rst(rst),
    .wen(wr),                                       // SW instruction generates this wen
    .rden(rd),                                      // LW instruction generates this rden
    .fsm_data_wen(d_cache_fsm_data_wen),            // FSM generated data array write-enable 
    .fsm_tag_wen(d_cache_fsm_tag_wen),              // FSM generated metadata array write-enable 
    .data_in(memory_data_out | data_in),            // either from SW insns or memory4c
    .address_in(addr_in),                           // from input to memory_system
    /*OUT*/ 
    .data_out(d_cache_data_out),                    // d-cache data output ONlY on cache-hit
    .miss_detected(d_cache_miss_detected),          // indicates d-cache miss
    .miss_address(d_cache_miss_addr)                // starting address of the block to be brought into cache
);

cache i_cache(
    .clk(clk),
    .rst(rst),
    .wen(/*unconnected*/),                          // No instruction can write to i-cache
    .rden(1'b1),                                    // i-cache will always be in Read-only mode
    .fsm_data_wen(i_cache_fsm_data_wen),            // FSM generated data array write-enable 
    .fsm_tag_wen(i_cache_fsm_tag_wen),              // FSM generated metadata array write-enable 
    .data_in(memory_data_out),                      // only takes output from memory4c      
    .address_in(addr_in),                           // from input to memory_system
    /*OUT*/ 
    .data_out(i_cache_data_out),                    // d-cache data output ONlY on cache-hit
    .miss_detected(i_cache_miss_detected),          // indicates d-cache miss
    .miss_address(i_cache_miss_addr)                // starting address of the block to be brought into cache
);

cache_fill_fsm cache_fill(
  .clk(clk),
  .rst(rst), 
  .d_cache_miss_detected(d_cache_miss_detected),    // from d-cache
  .d_cache_miss_address(d_cache_miss_address), 
  .i_cache_miss_detected(i_cache_miss_detected),    // from i-cache
  .i_cache_miss_address(i_cache_miss_address), 
  .memory_data_valid(memory_data_valid),            // from memory4c 

  /*OUT*/
  .d_cache_fsm_data_wen(d_cache_fsm_data_wen), 
  .d_cache_fsm_tag_wen(d_cache_fsm_tag_wen),
  .i_cache_fsm_data_wen(i_cache_fsm_data_wen), 
  .i_cache_fsm_tag_wen(i_cache_fsm_tag_wen),  
  .memory_address(miss_address),                  // sent to memory4c
//   .memory_data(memory_data), 
  
);


// ##################### Logic to write-back to memory on a SW instruction #####################




endmodule