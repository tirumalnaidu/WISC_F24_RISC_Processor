module shifter_6_64(
    input [63:0]  shift_in,  // data to be shifted
    input [5:0]   shift_val, // 6-bit shift amount
    output [63:0] shift_out  // data result of shift
);

wire [63:0]t1;
wire [63:0]t2;
wire [63:0]t3;
wire [63:0]t4;
wire [63:0]t5;
wire [63:0]t6;

assign t1 = (shift_val & 6'b100000)?shift_in<<32:shift_in;      // 100000 bit is set            
assign t2 = (shift_val & 6'b010000)?t1<<16:t1;                  // 010000 bit is set
assign t3 = (shift_val & 6'b001000)?t2<<8:t2;                   // 001000 bit is set
assign t4 = (shift_val & 6'b000100)?t3<<4:t3;                   // 000100 bit is set
assign t5 = (shift_val & 6'b000010)?t4<<2:t4;                   // 000010 bit is set
assign shift_out = (shift_val & 6'b000001)?t5<<1:t5;            // 000001 bit is set


endmodule