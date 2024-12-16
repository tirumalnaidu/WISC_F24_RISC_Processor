module shifter_3_8(
    input [7:0]  shift_in,  // data to be shifted
    input [2:0]   shift_val, // 3-bit shift amount
    output [7:0] shift_out  // data result of shift
);

wire [7:0]t1;
wire [7:0]t2;
wire [7:0]t3;


assign t1 = (shift_val & 3'b100)?shift_in<<4:shift_in;      // 100 bit is set            
assign t2 = (shift_val & 3'b010)?t1<<2:t1;                  // 010 bit is set
assign shift_out = (shift_val & 3'b001)?t2<<1:t2;           // 001 bit is set


endmodule