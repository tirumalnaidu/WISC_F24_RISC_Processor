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

wire data_miss_detect;
wire instr_miss_detect;
wire mem_data_valid;

wire [15:0] mem_access_address;
wire data_write_array;
wire tag_write_data_array;
wire instr_write_data_array;
wire instr_tag_write_array;
wire combined_tag_write_array;

wire [15:0] memory_output_data;

wire [15:0] mem_ctrl_address;
wire mem_write_enable = (data_miss_detect) ? 1'b0 : wen;
assign mem_ctrl_address = (data_miss_detect | instr_miss_detect) ? (mem_access_address) : (d_addr);

memory4c memory4c_unit (
    .data_out(memory_output_data),
    .data_valid(mem_data_valid),
    .data_in(data_in),
    .addr(mem_ctrl_address),
    .enable(d_stall | i_stall | wen),
    .wr(mem_write_enable),
    .clk(clk),
    .rst(rst)
);

cache instruction_cache (
    .clk(clk),
    .rst(rst),
    .data_in(memory_output_data),
    .wen(1'b0),
    .en(i_read_en),
    .addr(i_addr), 
    .write_tag_array(instr_tag_write_array),
    .write_data_array(instr_write_data_array),
    .data_out(i_data_out),
    .miss_detected(instr_miss_detect)
);

wire [15:0] data_cache_input_data;
assign data_cache_input_data = (wen & (~data_miss_detect)) ? (data_in) : (memory_output_data);

cache data_cache (
    .clk(clk),
    .rst(rst),
    .en(d_read_en),
    .data_in(data_cache_input_data), 
    .wen(wen),
    .addr(d_addr),
    .write_tag_array(tag_write_data_array),
    .write_data_array(data_write_array),
    .data_out(d_data_out),
    .miss_detected(data_miss_detect)
);

cache_fill_fsm cache_fsm (
    .clk(clk),
    .rst(rst),
    .d_miss_detected(data_miss_detect),
    .i_miss_detected(instr_miss_detect),
    .d_miss_address(d_addr),
    .i_miss_address(i_addr),
    .memory_data_valid(mem_data_valid),
    .d_stall(d_stall),
    .i_stall(i_stall),
    .memory_address(mem_access_address),
    .write_d_data_array(data_write_array),
    .write_d_tag_array(tag_write_data_array),
    .write_i_data_array(instr_write_data_array),
    .write_i_tag_array(instr_tag_write_array)
);

endmodule
