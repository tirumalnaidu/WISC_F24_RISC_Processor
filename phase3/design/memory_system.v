module memory_system #(
    parameter DWIDTH = 16,
    parameter AWIDTH = 16
) (
    input clk,
    input rst,
    input mem_write,                            // from the SW instruction -> to d_cache & memory 
    input mem_en,                               // decide when instantiating in cpu.v
    input [AWIDTH-1:0] instr_addr_in,                 // from instruction
    input [AWIDTH-1:0] data_addr_in,                 // from instruction
    
    input [DWIDTH-1:0] data_in,                 // from the SW instruction 

    output [DWIDTH-1:0] instr_out,               // data output from d-cache
    output [DWIDTH-1:0] data_out,               // data output from d-cache
    
    output icache_miss_stall,                     // stalls full processor 
    output dcache_miss_stall                     // stalls full processor 
);

// --------------------- for main_memory ---------------------
wire memory_data_valid;
wire [AWIDTH-1:0] memory_addr_in;

wire [DWIDTH-1:0] memory_data_out;

// --------------------- for d_cache ---------------------

wire icache_miss_detected;
wire dcache_miss_detected;

wire [AWIDTH-1:0] icache_miss_address;
wire [AWIDTH-1:0] dcache_miss_address;

wire [DWIDTH-1:0] icache_data_out;
wire [DWIDTH-1:0] dcache_data_out;


wire [DWIDTH-1:0] dcache_data_in;

wire icache_fsm_data_wen;
wire icache_fsm_tag_wen;

wire dcache_fsm_data_wen;
wire dcache_fsm_tag_wen;

wire dcache_mem_read;
wire dcache_mem_write;

// --------------------- for cache_fill_fsm ---------------------
wire [AWIDTH-1:0] fsm_miss_address;
wire fsm_busy;

// ################################################################################################

// on a cache hit : write to addr_in
// on a cache miss : read from miss_address
assign memory_addr_in = (icache_miss_detected | dcache_miss_detected) ? fsm_miss_address : (~dcache_miss_detected) ? data_addr_in: 16'h0000;
assign dcache_data_in = (mem_write & dcache_miss_detected)? memory_data_out : data_in;

assign icache_miss_stall = icache_miss_detected;
assign dcache_miss_stall = dcache_miss_detected;

assign instr_out = (~icache_miss_detected)? icache_data_out : 16'h0000;
assign data_out = (dcache_mem_read & ~dcache_miss_detected)? dcache_data_out : 16'h0000;

assign dcache_mem_read = mem_en & ~mem_write;
assign dcache_mem_write = mem_en & mem_write;

// ######################################## Instantiations ########################################

memory4c #(.DWIDTH(DWIDTH),
           .AWIDTH(AWIDTH)
) main_memory(
    .data_in(data_in),                             // for SW instruction
    .addr(memory_addr_in),                         // output from fsm OR SW instruction
    .enable(mem_en),
    .wr((mem_write & ~dcache_miss_detected)),         // from the SW instruction
    .clk(clk),
    .rst(rst),
    /*OUT*/
    .data_out(memory_data_out),                    // goes to d-cache & i-cache*
    .data_valid(memory_data_valid)
);

cache i_cache(
    .clk(clk),
    .rst(rst),
    .wen(1'b0),                        // SW instruction generates this wen
    .rden(1'b0),                        // LW instruction generates this rden
    .fsm_data_wen(icache_fsm_data_wen),            // FSM generated data array write-enable 
    .fsm_tag_wen(icache_fsm_tag_wen),              // FSM generated metadata array write-enable 
    .data_in(/*unconnected*/),                      // either from SW insns or memory4c ?????
    .address_in(instr_addr_in),                         // from input to memory_system
    /*OUT*/ 
    .data_out(icache_data_out),                    // d-cache data output ONlY on cache-hit
    .miss_detected(icache_miss_detected),          // indicates d-cache miss
    .miss_address(icache_miss_address)             // starting address of the block to be brought into cache
);

cache d_cache(
    .clk(clk),
    .rst(rst),
    .wen(dcache_mem_write),                        // SW instruction generates this wen
    .rden(dcache_mem_read),                        // LW instruction generates this rden
    .fsm_data_wen(dcache_fsm_data_wen),            // FSM generated data array write-enable 
    .fsm_tag_wen(dcache_fsm_tag_wen),              // FSM generated metadata array write-enable 
    .data_in(dcache_data_in),                      // either from SW insns or memory4c ?????
    .address_in(data_addr_in),                         // from input to memory_system
    /*OUT*/ 
    .data_out(dcache_data_out),                    // d-cache data output ONlY on cache-hit
    .miss_detected(dcache_miss_detected),          // indicates d-cache miss
    .miss_address(dcache_miss_address)             // starting address of the block to be brought into cache
);

  cache_fill_fsm  cache_fill_fsm_inst (
    .clk(clk),
    .rst(rst),
    .dcache_miss_detected(dcache_miss_detected),
    .icache_miss_detected(icache_miss_detected),
    .dcache_miss_address(dcache_miss_address),
    .icache_miss_address(icache_miss_address),
    .dcache_fsm_data_wen(dcache_fsm_data_wen),
    .dcache_fsm_tag_wen(dcache_fsm_tag_wen),
    .icache_fsm_data_wen(icache_fsm_data_wen),
    .icache_fsm_tag_wen(icache_fsm_tag_wen),
    .memory_address(fsm_miss_address),
    .memory_data_valid(memory_data_valid)
  );

endmodule