`include "./common/cla_adder_4bit.v"
`include "shifter_3_8.v"
`include "shifter_6_64.v"
// `include "../ip/*.v"

module cache (
    input clk,
    input rst,
    input wen,                          // SW instruction generates this wen
    input rden,                         // LW instruction generates this rden
    input fsm_data_wen,                 // FSM generated data array write-enable 
    input fsm_tag_wen,                  // FSM generated metadata array write-enable 
    input [15:0] data_in,
    input [15:0] address_in,
    
    output [15:0] data_out,
    output miss_detected,               // indicates cache miss
    output [15:0] miss_address          // starting address of the block to be brought into cache
);

// -------------------------------- cases to handle --------------------------------
     

// read - hit
//      -> LRU_bit update
//      -> data output

// write - hit
//       -> LRU_bit update


// read - miss 
//      -> LRU_bit update
//      -> new data
//      -> data output

// write - miss 
//       -> LRU_bit update
//       -> new data

// ---------------------------------------------------------------------------------


// metadata entry -> | 5 | 4 | 3 | 2 | 1 | 0 | valid | LRU | 

wire LRU_way0_out;                      // current value of LRU bit
wire LRU_way0_in;                       // updated value of LRU bit
wire valid_way0;                        // way0 valid bit
wire valid_way1;                        // way1 valid bit

wire tag_match_way0;                    // asserted when tag matches with way0
wire tag_match_way1;                    // asserted when tag matches with way1

wire [7:0] metadata_way0_in;            // 8-bit metadata way0 input
wire [7:0] metadata_way1_in;            // 8-bit metadata way1 input


wire [15:0] data_way0_out;              // 16-bit data output from way0
wire [15:0] data_way1_out;              // 16-bit data output from way1
wire [7:0] metadata_way0_out;           // 8-bit metadata output stored in way0
wire [7:0] metadata_way1_out;           // 8-bit metadata output stored in way1

wire [3:0] offset_cnt_in;         // 4-bit input to shift register used to calculate offset
wire [3:0] offset_cnt_out;        // 4-bit output from shift register used to calculate offset

wire [5:0]tag;                          // 6-bit tag
wire [5:0]index;                        // 6-bit index
wire [3:0]addr_offset;                  // 4-bit offset from address_in -> LSB dropped
wire [63:0]set_enable;                  // 64-bit select signal to 1/64 sets
wire [7:0] word_enable;

wire [3:0] offset;                  // correct value of offset

// -------------------------------- Inputs to the modules --------------------------------
assign tag = address_in[15:10];
assign index = address_in[9:4];
assign addr_offset = address_in[3:1];


// ---- counter logic ----
pldff #(.WIDTH(4)) offset_counter (
    .q(offset_cnt_out), 
    .d(offset_cnt_in), 
    .wen(fsm_data_wen), 
    .clk(clk), 
    .rst(rst)
);

cla_adder_4bit cla_4(
	.a_in(offset_cnt_out),
	.b_in(4'b1),
	.carry_in(1'b0),

	.adder_out(offset_cnt_in),
	.carry_out(/*not connected*/),
	.ovfl(/*not connected*/)
);
// ---------------------------

// select between offset from SW address or fsm_miss address
assign offset = (miss_detected)? offset_cnt_out : addr_offset;

// one-hot 1/64 selector for set_enable
shifter_6_64 sh_6_64(
    .shift_in(64'b1),
    .shift_val(index),
    .shift_out(set_enable)
);

shifter_3_8 sh_3_8(
    .shift_in(8'b1),
    .shift_val(offset[3:1]),
    .shift_out(word_enable)
);

assign LRU_way0_out = metadata_way0_out[0];             // current value of LRU bit 
assign valid_way0 = metadata_way0_out[1];
assign valid_way1 = metadata_way1_out[1];

assign tag_match_way0 = (tag == metadata_way0_out[7:2] & valid_way0);
assign tag_match_way1 = (tag == metadata_way1_out[7:2] & valid_way1);

assign LRU_way0_in = (tag_match_way0)? 1'b1 :
                     (tag_match_way1)? 1'b0 : LRU_way0_out;


assign metadata_way0_in = (~miss_detected)? {metadata_way0_out[7:2], LRU_way0_in, 1'b1} : {tag, LRU_way0_in, 1'b1};
assign metadata_way1_in = {tag, 1'bz, 1'b1};              // should the LRU bit be z or x

// -------------------------------- storage modules of cache.v --------------------------------

// TODO : what happens on a store word hit ?

// instantiate data_way_array0
data_way_array d0 (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .wen(((~miss_detected & wen) & tag_match_way0) | (fsm_data_wen & ~LRU_way0_out) /*check tag match on SW hit*/),
    .set_enable(set_enable),
    .word_enable(word_enable),
    .data_out(data_way0_out)

);

// instantiate data_way_array1
data_way_array d1 (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .wen(((~miss_detected & wen) & tag_match_way1) | (fsm_data_wen & LRU_way0_out)),
    .set_enable(set_enable),
    .word_enable(word_enable),
    .data_out(data_way1_out)

);

metadata_way_array m0(
    .clk(clk),
    .rst(clk),
    .data_in(metadata_way0_in),
    .wen((~miss_detected & (wen | rden)) | fsm_tag_wen),
    .set_enable(set_enable),
    .data_out(metadata_way0_out)
);

metadata_way_array m1(
    .clk(clk),
    .rst(rst),
    .data_in(metadata_way1_in),
    .wen(((~miss_detected & wen) & tag_match_way1) | (fsm_tag_wen & LRU_way0_out)),
    .set_enable(set_enable),
    .data_out(metadata_way1_out)
);

assign miss_detected = (tag_match_way0)? 1'b0 : 
                       (tag_match_way1)? 1'b0 : 1'b1;

assign miss_address =  {address_in[15:4], {4{1'b0}}};


// output data only when LW & tag hit
assign data_out =(~miss_detected & rden & tag_match_way0)? data_way0_out : 
                 (~miss_detected & rden & tag_match_way1)? data_way1_out :  16'hzzzz;

endmodule

/*

###################################### concepts for cache.v ######################################

Assuming miss_detected signal will stay asserted till the correct block is not available in the cache
    miss_detected is dependent on tag_match signals
    tag_match only happens in the last cycle in case of a miss

Q. why do we need seperate wen from the instruction vs fsm 
    wen from the instruction will be high even when the rest of the processor is stalled (generated by control unit)
    wen from the fsm will only be high when valid data is available

Q. why do we need a seperate fsm_wen for data array & meta_data array ?
    on a miss, 
    for the 1st 8-cycles only data will be available to write to the cache
    only on the 8th cycle after the miss, the tag array should be updated

Q who controls writes to the data way array ?
    LRU_bit_out & tag_match

Q when to update LRU bit ?
    if tag match happens then change the LRU bit else keep it same

Q why do we need a counter ?
    when the data starts coming in after a miss, it has to be directed to the correct offset in the data-block
    for each 2B of data coming in, the offset should change to the next address location
    this will happen 8-times i.e. 0-7 

Q how does the offset_shift_register start counting from zero at the correct time ?


// ---------------------------------------------------------------------------------

// way0 will always be written whether or not we write to way0 to way1 
// shift register
// how does cache know where to write 
// fsm does not send address to cache 
// data_out 
// data_in logic rewrite
// write tag array & write data array  

###################################### concepts for cache_fill_fsm ######################################

1. 2 separate fsm_busy / statll signals for i-cache & d-cache
2. does the data from memory need to go to the cache_fill_fsm ? 
    if yes, fsm can decide which cache to forward data to 
    if no, how to decide which cache to forward data to ??
        data can directly go to cache from memory
        using the fsm_data_wen you can decide which cache to write to
        fsm_data_wen is dependent on data_valid & some logic to select the correct cache
3. does data_valid need to go to the cache_fill_fsm ?
    yes to give out fsm_data_wen
4. select b/w data from memory & data from SW instruction on a write miss
    D-cache : if valid data from memory then it is prioritized

what are the possible cache miss scenarios
1. I-cache only
2. D-cache only
3. I-cache followed by D-cache -> priority I-cache
4. I-cache & D-cache together  -> priority D-cache 



*/
 