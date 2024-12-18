
module cache (
    input clk,
    input rst,
    input [15:0] data_in, // 2 byte data input port
    input wen,
    input en,
    input [15:0] addr, //address input port
    input write_data_array,
    input write_tag_array,
    output [15:0] data_out,
    output miss_detected
);

// 16 bits of address
wire [5:0] tag;
wire [5:0] set;
wire [63:0] set_enable;
wire [63:0] t1, t2, t3, t4, t5;

wire [3:0] word;
wire [3:0] next_word;
wire [7:0] word_enable;
wire [7:0] w1, w2;

wire data_way_select;
wire [15:0] data_in_way0; 
wire [15:0] data_in_way1;
wire [15:0] data_out_way0; 
wire [15:0] data_out_way1;

wire [7:0] metadata_in_way0;
wire [7:0] metadata_in_way1;
wire [7:0] metadata_out_way0;
wire [7:0] metadata_out_way1;
wire meta0_wen;
wire meta1_wen;

//instantiating data_way_array for way 0
data_way_array dataWay0 (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .wen(data0_wen),
    .set_enable(set_enable),
    .word_enable(word_enable),
    .data_out(data_out_way0)
);

//instantiating data_way_array for way 1
data_way_array dataWay1 (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .wen(data1_wen),
    .set_enable(set_enable),
    .word_enable(word_enable),
    .data_out(data_out_way1)
);

//instantiating matadata_way_array for way 0
metadata_way_array metaDataWay0 (
    .clk(clk),
    .rst(rst),
    .data_in(metadata_in_way0),
    .wen(meta0_wen),
    .set_enable(set_enable),
    .data_out(metadata_out_way0)
);

//instantiating matadata_way_array for way 1
metadata_way_array metaDataWay1 (
    .clk(clk),
    .rst(rst),
    .data_in(metadata_in_way1),
    .wen(meta1_wen),
    .set_enable(set_enable),
    .data_out(metadata_out_way1)
);


pldff #(.WIDTH(4)) data_count_reg(
	.clk(clk),
	.rst(rst | (~miss_detected)),
	.q(word),
	.d(next_word),
	.wen(data0_wen | data1_wen)
);

cla_4bit data_counter(
 .a(word),
 .b(4'b0001),
 .is_sub(1'b0),
 .sum(next_word)
);




assign set = addr[9:4];
assign tag = addr[15:10];

//set enable logic
assign t1 = set[0] ? 64'b1 << 1 : 64'b1;
assign t2 = set[1] ? t1 << 2 : t1;
assign t3 = set[2] ? t2 << 4 : t2;
assign t4 = set[3] ? t3 << 8 : t3;
assign t5 = set[4] ? t4 << 16 : t4;
assign set_enable = set[5] ? t5 << 32 : t5;

wire [7:0] word_sel;
assign word_sel = ((data0_wen | data1_wen) & (~wen | (miss_detected))) ? (word) : (addr[3:1]); 
assign w1 = word_sel[0] ? 8'b1 << 1 : 8'b1;
assign w2 = word_sel[1] ? w1 << 2 : w1;
assign word_enable = word_sel[2] ? w2 << 4 : w2;

//LRU
wire lru;
assign lru = metadata_out_way0[0];
//valid bits
wire valid0, valid1;
assign valid0 = metadata_out_way0[1];
assign valid1 = metadata_out_way1[1];

//tag_match bits
wire tag_match_way0;
assign tag_match_way0 = ((tag == metadata_out_way0[7:2]) & valid0);

wire tag_match_way1;
assign tag_match_way1 = ((tag == metadata_out_way1[7:2]) & valid1);

//miss condition
assign miss_detected = (~tag_match_way0) & (~tag_match_way1) & (en | wen);

assign metadata_in_way0 = (tag_match_way0) ? ({metadata_out_way0[7:1],1'b1}):
						  (tag_match_way1) ? ({metadata_out_way0[7:1],1'b0}):
						  (miss_detected)  ? ((~lru) ? {addr[15:10],2'b11}:({metadata_out_way0[7:1],1'b1})):
						  8'h00;

assign metadata_in_way1 = (en) ? ((miss_detected & (lru)) ? {addr[15:10],2'b10} : 8'h00):8'h00;

assign meta0_wen = (en | wen) ? ((miss_detected) ? write_tag_array : 1'b1):1'b0;

assign meta1_wen = (en | wen) ? ((miss_detected & lru) ? write_tag_array : 1'b0): 1'b0;

assign data0_wen = (en | wen)  & ( ((~miss_detected) & wen & tag_match_way0) | (miss_detected & (~lru) & write_data_array) );

assign data1_wen = (en | wen) & (((~miss_detected) & wen & tag_match_way1) | (miss_detected & (lru) & write_data_array));

assign data_out = (tag_match_way0) ? data_out_way0 : data_out_way1;

endmodule







 
						  
