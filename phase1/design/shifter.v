`include "flags.vh"

module shifter(
    input [15:0] shift_in,
    input [3:0] shift_val,
    input [1:0] mode,
    output [15:0] shift_out,
    output [2:0]  flag
);

// Conversion from 4'b(Base-2) to 6'b(Base-3)
reg [5:0] shift_base3;
reg [15:0] tmp0;
reg [15:0] tmp1;
reg [15:0] tmp2;

always@(*) begin
    case(shift_val)
        4'b0000: shift_base3 = 6'b000000;  //6'b 00 | 00 | 00 = 0
        4'b0001: shift_base3 = 6'b000001;  //6'b 00 | 00 | 01 = 1
        4'b0010: shift_base3 = 6'b000010;  //6'b 00 | 00 | 10 = 2
        4'b0011: shift_base3 = 6'b000100;  //6'b 00 | 01 | 00 = 3
        4'b0100: shift_base3 = 6'b000101;  //6'b 00 | 01 | 01 = 4
        4'b0101: shift_base3 = 6'b000110;  //6'b 00 | 01 | 10 = 5
        4'b0110: shift_base3 = 6'b001000;  //6'b 00 | 10 | 00 = 6 
        4'b0111: shift_base3 = 6'b001001;  //6'b 00 | 10 | 01 = 7
        4'b1000: shift_base3 = 6'b001010;  //6'b 00 | 10 | 10 = 8
        4'b1001: shift_base3 = 6'b010000;  //6'b 01 | 00 | 00 = 9
        4'b1010: shift_base3 = 6'b010001;  //6'b 01 | 00 | 01 = 10
        4'b1011: shift_base3 = 6'b010010;  //6'b 01 | 00 | 10 = 11
        4'b1100: shift_base3 = 6'b010100;  //6'b 01 | 01 | 00 = 12
        4'b1101: shift_base3 = 6'b010101;  //6'b 01 | 01 | 01 = 13
        4'b1110: shift_base3 = 6'b010110;  //6'b 01 | 01 | 10 = 14
        4'b1111: shift_base3 = 6'b011000;  //6'b 01 | 10 | 00 = 15
        default: shift_base3 = 6'b000000;
    endcase
end

always@(*) begin
    case(mode)
        2'b00:  begin   // SLL
                tmp0 =  (~shift_base3[1] & ~shift_base3[0])? shift_in:
                        (~shift_base3[1] & shift_base3[0])? {shift_in[14:0], 1'b0}: 
                                                            {shift_in[13:0], 2'b0};
                tmp1 =  (~shift_base3[3] & ~shift_base3[2])? tmp0:
                        (~shift_base3[3] & shift_base3[2])? {tmp0[12:0], 3'b0}: 
                                                            {tmp0[9:0], 6'b0};
                tmp2 =  (~shift_base3[5] & ~shift_base3[4])? tmp1:
                        (~shift_base3[5] & shift_base3[4])? {tmp1[7:0], 9'b0}: 
                                                            16'h0000;    // Impossible case     
                end
        2'b01:  begin   // SRA
                tmp0 =  (~shift_base3[1] & ~shift_base3[0])? shift_in:
                        (~shift_base3[1] & shift_base3[0])? {shift_in[15], shift_in[15:1]}:
                                                            {{2{shift_in[15]}}, shift_in[15:2]};
                tmp1 =  (~shift_base3[3] & ~shift_base3[2])? tmp0:
                        (~shift_base3[3] & shift_base3[2])? {{3{tmp0[15]}}, tmp0[15:3]}:
                                                            {{6{tmp0[15]}}, tmp0[15:6]};
                tmp2 =  (~shift_base3[5] & ~shift_base3[4])? tmp1:
                        (~shift_base3[5] & shift_base3[4])? {{9{tmp1[15]}}, tmp1[15:9]}:
                                                            {16{tmp1[15]}}; // Impossible case
                end    
        2'b10:  begin    // ROR
                tmp0 =  (~shift_base3[1] & ~shift_base3[0])? shift_in:
                        (~shift_base3[1] & shift_base3[0])? {shift_in[0], shift_in[15:1]}:
                                                            {shift_in[1:0], shift_in[15:2]};
                tmp1 =  (~shift_base3[3] & ~shift_base3[2])? tmp0:
                        (~shift_base3[3] & shift_base3[2])? {tmp0[2:0], tmp0[15:3]}:
                                                            {tmp0[5:0], tmp0[15:6]};
                tmp2 =  (~shift_base3[5] & ~shift_base3[4])? tmp1:
                        (~shift_base3[5] & shift_base3[4])? {tmp1[8:0], tmp1[15:9]}:
                                                            tmp1;   // Impossible case
                end
        default:    begin
                    tmp0 = 16'h0000;
                    tmp1 = 16'h0000;
                    tmp2 = 16'h0000;
                    end
    endcase
end

assign shift_out = tmp2;
assign flag[`FLAG_Z] = ~(|tmp2);
assign flag[`FLAG_V] = 1'b0;
assign flag[`FLAG_N] = 1'b0;

endmodule