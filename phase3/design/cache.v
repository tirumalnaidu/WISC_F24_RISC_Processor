module cache (
    input clk,
    input rst,
    input [15:0] data_in, 
    input wen,
    input en,
    input [15:0] addr,
    input write_data_array,
    input write_tag_array,
    output [15:0] data_out,
    output miss_detected
);

wire [5:0] tag_field;
wire [5:0] set_field;
wire [63:0] set_decoder;
wire [63:0] temp_t1, temp_t2, temp_t3, temp_t4, temp_t5;

wire [3:0] word_index;
wire [3:0] next_word_index;
wire [7:0] word_decoder;
wire [7:0] temp_w1, temp_w2;

wire selected_data_way;
wire [15:0] data_input_way0; 
wire [15:0] data_input_way1;
wire [15:0] data_output_way0; 
wire [15:0] data_output_way1;

wire [7:0] metadata_input_way0;
wire [7:0] metadata_input_way1;
wire [7:0] metadata_output_way0;
wire [7:0] metadata_output_way1;
wire metadata_write_enable_way0;
wire metadata_write_enable_way1;

data_way_array_beh dataWay0 (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .wen(data_write_enable_way0),
    .set_enable(set_decoder),
    .word_enable(word_decoder),
    .data_out(data_output_way0)
);

data_way_array_beh dataWay1 (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .wen(data_write_enable_way1),
    .set_enable(set_decoder),
    .word_enable(word_decoder),
    .data_out(data_output_way1)
);

metadata_way_array_beh metaDataWay0 (
    .clk(clk),
    .rst(rst),
    .data_in(metadata_input_way0),
    .wen(metadata_write_enable_way0),
    .set_enable(set_decoder),
    .data_out(metadata_output_way0)
);

metadata_way_array_beh metaDataWay1 (
    .clk(clk),
    .rst(rst),
    .data_in(metadata_input_way1),
    .wen(metadata_write_enable_way1),
    .set_enable(set_decoder),
    .data_out(metadata_output_way1)
);

pldff #(.WIDTH(4)) data_count_reg(
	.clk(clk),
	.rst(rst | (~miss_detected)),
	.q(word_index),
	.d(next_word_index),
	.wen(data_write_enable_way0 | data_write_enable_way1)
);

cla_4bit data_counter(
 .a(word_index),
 .b(4'b0001),
 .is_sub(1'b0),
 .sum(next_word_index)
);

assign set_field = addr[9:4];
assign tag_field = addr[15:10];

assign temp_t1 = set_field[0] ? 64'b1 << 1 : 64'b1;
assign temp_t2 = set_field[1] ? temp_t1 << 2 : temp_t1;
assign temp_t3 = set_field[2] ? temp_t2 << 4 : temp_t2;
assign temp_t4 = set_field[3] ? temp_t3 << 8 : temp_t3;
assign temp_t5 = set_field[4] ? temp_t4 << 16 : temp_t4;
assign set_decoder = set_field[5] ? temp_t5 << 32 : temp_t5;

wire [7:0] word_selector;
assign word_selector = ((data_write_enable_way0 | data_write_enable_way1) & (~wen | (miss_detected))) ? (word_index) : (addr[3:1]); 
assign temp_w1 = word_selector[0] ? 8'b1 << 1 : 8'b1;
assign temp_w2 = word_selector[1] ? temp_w1 << 2 : temp_w1;
assign word_decoder = word_selector[2] ? temp_w2 << 4 : temp_w2;

wire lru_bit;
assign lru_bit = metadata_output_way0[0];

wire valid_bit_way0, valid_bit_way1;
assign valid_bit_way0 = metadata_output_way0[1];
assign valid_bit_way1 = metadata_output_way1[1];

wire tag_match_way0;
assign tag_match_way0 = ((tag_field == metadata_output_way0[7:2]) & valid_bit_way0);

wire tag_match_way1;
assign tag_match_way1 = ((tag_field == metadata_output_way1[7:2]) & valid_bit_way1);

assign miss_detected = (~tag_match_way0) & (~tag_match_way1) & (en | wen);

assign metadata_input_way0 = (tag_match_way0) ? ({metadata_output_way0[7:1],1'b1}):
				  (tag_match_way1) ? ({metadata_output_way0[7:1],1'b0}):
				  (miss_detected)  ? ((~lru_bit) ? {addr[15:10],2'b11}:({metadata_output_way0[7:1],1'b1})):
				  8'h00;
assign metadata_input_way1 = (en) ? ((miss_detected & (lru_bit)) ? {addr[15:10],2'b10} : 8'h00):8'h00;

assign metadata_write_enable_way0 = (en | wen) ? ((miss_detected) ? write_tag_array : 1'b1):1'b0;
assign metadata_write_enable_way1 = (en | wen) ? ((miss_detected & lru_bit) ? write_tag_array : 1'b0): 1'b0;
assign data_write_enable_way0 = (en | wen)  & ( ((~miss_detected) & wen & tag_match_way0) | (miss_detected & (~lru_bit) & write_data_array) );
assign data_write_enable_way1 = (en | wen) & (((~miss_detected) & wen & tag_match_way1) | (miss_detected & (lru_bit) & write_data_array));
assign data_out = (tag_match_way0) ? data_output_way0 : data_output_way1;

endmodule
