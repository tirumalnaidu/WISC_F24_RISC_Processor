module memory_system #(
    parameter DWIDTH = 16,
    parameter AWIDTH = 16
) (
    input clk,
    input rst,
    input mem_write,                            // from the SW instruction -> to d_cache & memory 
    input mem_en,                               // decide when instantiating in cpu.v
    input [AWIDTH-1:0] addr_in,                 // from instruction
    input [DWIDTH-1:0] data_in,                 // from the SW instruction 

    output [DWIDTH-1:0] data_out,               // data output from d-cache
    output cache_miss_stall                     // stalls full processor 
);

// --------------------- for main_memory ---------------------
wire memory_data_valid;
wire [AWIDTH-1:0] memory_addr_in;
wire [DWIDTH-1:0] memory_data_out;

// --------------------- for d_cache ---------------------

wire cache_miss_detected;
wire [AWIDTH-1:0] cache_miss_address;
wire [DWIDTH-1:0] cache_data_out;
wire [DWIDTH-1:0] cache_data_in;
wire cache_fsm_data_wen;
wire cache_fsm_tag_wen;

wire cache_mem_read;
wire cache_mem_write;

// --------------------- for cache_fill_fsm ---------------------
wire [AWIDTH-1:0] miss_address;
wire [AWIDTH-1:0] fsm_miss_address;
wire fsm_busy;

// ################################################################################################

// on a cache hit : write to addr_in
// on a cache miss : read from miss_address
assign memory_addr_in = cache_miss_detected ? fsm_miss_address : addr_in;

assign cache_data_in = (cache_miss_detected)? memory_data_out : data_in;


assign cache_miss_stall = cache_miss_detected;
assign data_out = (cache_mem_read & ~cache_miss_detected)? cache_data_out : 16'h0000;

assign cache_mem_read = mem_en & ~mem_write;
assign cache_mem_write = mem_en & mem_write;

// ######################################## Instantiations ########################################

memory4c #(.DWIDTH(DWIDTH),
           .AWIDTH(AWIDTH)
) main_memory(
    .data_in(data_in),                             // for SW instruction
    .addr(memory_addr_in),                         // output from fsm OR SW instruction
    .enable(mem_en),
    .wr(mem_write & ~cache_miss_detected),         // from the SW instruction
    .clk(clk),
    .rst(rst),
    /*OUT*/
    .data_out(memory_data_out),                    // goes to d-cache & i-cache*
    .data_valid(memory_data_valid)
);

cache d_cache(
    .clk(clk),
    .rst(rst),
    .wen(cache_mem_write),                        // SW instruction generates this wen
    .rden(cache_mem_read),                        // LW instruction generates this rden
    .fsm_data_wen(cache_fsm_data_wen),            // FSM generated data array write-enable 
    .fsm_tag_wen(cache_fsm_tag_wen),              // FSM generated metadata array write-enable 
    .data_in(cache_data_in),                      // either from SW insns or memory4c ?????
    .address_in(addr_in),                         // from input to memory_system
    /*OUT*/ 
    .data_out(cache_data_out),                    // d-cache data output ONlY on cache-hit
    .miss_detected(cache_miss_detected),          // indicates d-cache miss
    .miss_address(cache_miss_address)             // starting address of the block to be brought into cache
);

cache_fill_fsm  cache_fill_fsm_inst (
    .clk(clk),
    .rst(rst),
    .miss_detected(cache_miss_detected),
    .miss_address(cache_miss_address),
    .fsm_busy(fsm_busy),
    .fsm_data_wen(cache_fsm_data_wen),
    .fsm_tag_wen(cache_fsm_tag_wen),
    .memory_address(fsm_miss_address),
    .memory_data_valid(memory_data_valid)
  );  

endmodule