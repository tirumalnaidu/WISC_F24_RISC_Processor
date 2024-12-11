module shifter_6_64(
    input [7:0]  shift_in,  // data to be shifted
    input [5:0]   shift_val, // 6-bit shift amount
    output [7:0] shift_out  // data result of shift
);

wire [7:0]t1;
wire [7:0]t2;
wire [7:0]t3;


assign t1 = (shift_val & 6'b100)?shift_in<<8:shift_in;      // 100 bit is set            
assign t2 = (shift_val & 6'b010)?t1<<4:t1;                  // 010 bit is set
assign shift_out = (shift_val & 6'b001)?t2<<2:t2;           // 001 bit is set


endmodule