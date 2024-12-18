

module memory (
    input clk,
    input rst,
    input [15:0] data_in, 
    input wen,
    input [15:0] i_addr,
    input [15:0] d_addr, 
    input i_read_en, d_read_en,
    output [15:0] d_data_out,
    output [15:0] i_data_out,
    output d_stall, 
    output i_stall
);

wire d_miss_detected;
wire i_miss_detected;
wire memory_data_valid;

wire [15:0] memory_address;
wire write_d_data_array;
wire write_d_tag_array;
wire write_i_data_array;
wire write_i_tag_array;
wire write_tag_array;

wire [15:0] mem_data_out;

wire [15:0] mem_addr;
wire mem_wen = (d_miss_detected) ? 1'b0 : wen;
assign mem_addr = (d_miss_detected | i_miss_detected) ? (memory_address) : (d_addr);

memory4c memory4c_inst (
    .data_out(mem_data_out),
    .data_valid(memory_data_valid),
    .data_in(data_in),
    .addr(mem_addr),
    .enable(d_stall | i_stall | wen),
    .wr(mem_wen),
    .clk(clk),
    .rst(rst)
);

cache icache_inst (
    .clk(clk),
    .rst(rst),
    .data_in(mem_data_out),
    .wen(1'b0),
    .en(i_read_en),
    .addr(i_addr), 
    .write_tag_array(write_i_tag_array),
    .write_data_array(write_i_data_array),
    .data_out(i_data_out),
    .miss_detected(i_miss_detected)
);

wire [15:0] d_cache_data_in;
assign d_cache_data_in = (wen & (~d_miss_detected)) ? (data_in) : (mem_data_out);

cache dcache_inst (
    .clk(clk),
    .rst(rst),
    .en(d_read_en),
    .data_in(d_cache_data_in), 
    .wen(wen),
    .addr(d_addr),
    .write_tag_array(write_d_tag_array),
    .write_data_array(write_d_data_array),
    .data_out(d_data_out),
    .miss_detected(d_miss_detected)
);

cache_fill_fsm cache_fill_fsm_inst (
    .clk(clk),
    .rst(rst),
    .d_miss_detected(d_miss_detected),
    .i_miss_detected(i_miss_detected),
    .d_miss_address(d_addr),
    .i_miss_address(i_addr),
    .memory_data_valid(memory_data_valid),
    .d_stall(d_stall),
    .i_stall(i_stall),
    .memory_address(memory_address),
    .write_d_data_array(write_d_data_array),
    .write_d_tag_array(write_d_tag_array),
    .write_i_data_array(write_i_data_array),
    .write_i_tag_array(write_i_tag_array)
);

endmodule