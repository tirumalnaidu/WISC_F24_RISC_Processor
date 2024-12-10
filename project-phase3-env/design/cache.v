module cache (
    input clk,
    input rst,
    input [15:0] data_in,
    input wen,
    input [15:0] address_in,
    
    output [15:0] data_out,
    output miss_detected,
    output [15:0] miss_address
);

wire [15:0] data_out_way0;          // 2-byte output from way0
wire [15:0] data_out_way1;          // 2-byte output from way1
wire [7:0] metadata_way0;           // 8-bit metadata stored in way0
wire [7:0] metadata_way1;           // 8-bit metadata stored in way1

wire [5:0]tag;                      // 6-bit tag
wire [5:0]index;                    // 6-bit index
wire [63:0]set_enable;              // 64-bit select signal to 1/64 sets

assign tag = address_in[15:10];
assign index = address_in[9:4];


barrel_shifter index_shifter(
    .shift_in(6'h1),
    .shift_val(index),
    .shift_out(set_enable)
);

// instantiate data_way_array0
data_way_array d0 (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .wen(wen),
    .set_enable(set_enable),
    .word_enable(/*output from the barrel shifter*/),
    .data_out(data_out_way0)

);

// instantiate data_way_array1
data_way_array d1 (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .wen(wen),
    .set_enable(set_enable),
    .word_enable(/*output from the barrel shifter*/),
    .data_out(data_out_way1)

);

metadata_way_array m0(
    .clk(clk),
    .rst(clk),
    .data_in(),
    .wen(),
    .set_enable(set_enable),
    .data_out()
);

metadata_way_array m1(
    .clk(clk),
    .rst(rst),
    .data_in(),
    .wen(),
    .set_enable(set_enable),
    .data_out()
);


endmodule