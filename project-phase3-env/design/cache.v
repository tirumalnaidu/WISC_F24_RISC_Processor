module cache (
    input clk,
    input rst,
    input wen,                          // SW instruction generates this wen
    input [15:0] data_in,
    input [15:0] address_in,
    
    output [15:0] data_out,
    output miss_detected,               // indicates cache miss
    output [15:0] miss_address          // starting address of the block to be brought into cache
);

// -------------------------------- cases to handle --------------------------------
// read - miss 
//      -> LRU_bit update
//      -> new data
//      

// read - hit
//      -> LRU_bit update

// write - miss 
//       -> LRU_bit update
//       -> new data

// write - hit
//       -> LRU_bit update
// ---------------------------------------------------------------------------------

// way0 will always be written whether or not we write to way0 to way1 
// shift register
// how does cache know where to write 
// fsm does not send address to cache 
// data_out 
// data_in logic rewrite
// write tag array & write data array  

// ---------------------------------------------------------------------------------


// metadata
// | 5 | 4 | 3 | 2 | 1 | 0 | LRU | valid | 

wire LRU_bit_way0;
wire valid_way0;
wire valid_way1;

wire [7:0] metadata_way0_in;
wire [7:0] metadata_way1_in;            // 8-bit metadata way1 input


wire [15:0] data_way0_out;              // 16-bit data output from way0
wire [15:0] data_way1_out;              // 16-bit data output from way1
wire [7:0] metadata_way0_out;           // 8-bit metadata output stored in way0
wire [7:0] metadata_way1_out;           // 8-bit metadata output stored in way1

wire [5:0]tag;                      // 6-bit tag
wire [5:0]index;                    // 6-bit index
wire [3:1]offset                    // 3-bit offset -> LSB dropped
wire [63:0]set_enable;              // 64-bit select signal to 1/64 sets
wire [7:0] word_enable;


// -------------------------------- Inputs to the modules --------------------------------
assign tag = address_in[15:10];
assign index = address_in[9:4];
assign offset = address_in[3:1];

assign LRU_bit_way0 = metadata_way0_out[1];
assign valid_way0 = (metadata_way0_out[0])?;
assign valid_way1 = (metadata_way1_out[0])?;

shifter_6_64 sh_6_64(
    .shift_in(64'b1),
    .shift_val(index),
    .shift_out(set_enable)
);

shifter_3_8 sh_3_8(
    .shift_in(7'b1),
    .shift_val(offset),
    .shift_out(word_enable)
);

assign metadata_way0_in = {tag, ~LRU_bit_way0, 1'b1};
assign metadata_way1_in = {tag, 1'bz, 1'b1};              // should the LRU bit be z or x

// -------------------------------- Internal modules of cache.v --------------------------------

// instantiate data_way_array0
data_way_array d0 (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .wen(wen & ~LRU_bit_way0),
    .set_enable(set_enable),
    .word_enable(word_enable),
    .data_out(data_out_way0)

);

// instantiate data_way_array1
data_way_array d1 (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .wen(wen & LRU_bit_way0),
    .set_enable(set_enable),
    .word_enable(word_enable),
    .data_out(data_out_way1)

);

metadata_way_array m0(
    .clk(clk),
    .rst(clk),
    .data_in(metadata_way0_out),
    .wen(wen & ~LRU_bit_way0),
    .set_enable(set_enable),
    .data_out(metadata_way0_out)
);

metadata_way_array m1(
    .clk(clk),
    .rst(rst),
    .data_in(metadata_way1_in),
    .wen(wen & LRU_bit_way0),
    .set_enable(set_enable),
    .data_out(metadata_way1_out)
);

assign miss_detected = (tag == metadata_way0_out[7:2] && valid_way0)? 1'b0 : 
                       (tag == metadata_way1_out[7:2] && valid_way1)? 1'b0 : 1'b1;

assign miss_address =  {address_in[15:4], {4{1'b0}}};

endmodule