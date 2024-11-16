module ror_func(
    input [15:0] in,
    input [5:0] sel,
    output [15:0] out    
);

wire [15:0] tmp0;
wire [15:0] tmp1;
wire [15:0] tmp2;

//tmp0
assign tmp0[0] = (~sel[1] & ~sel[0])? in[0]: (~sel[1] & sel[0])? in[1]: in[2];
assign tmp0[1] = (~sel[1] & ~sel[0])? in[1]: (~sel[1] & sel[0])? in[2]: in[3];
assign tmp0[2] = (~sel[1] & ~sel[0])? in[2]: (~sel[1] & sel[0])? in[3]: in[4];
assign tmp0[3] = (~sel[1] & ~sel[0])? in[3]: (~sel[1] & sel[0])? in[4]: in[5];
assign tmp0[4] = (~sel[1] & ~sel[0])? in[4]: (~sel[1] & sel[0])? in[5]: in[6];
assign tmp0[5] = (~sel[1] & ~sel[0])? in[5]: (~sel[1] & sel[0])? in[6]: in[7];
assign tmp0[6] = (~sel[1] & ~sel[0])? in[6]: (~sel[1] & sel[0])? in[7]: in[8];
assign tmp0[7] = (~sel[1] & ~sel[0])? in[7]: (~sel[1] & sel[0])? in[8]: in[9];
assign tmp0[8] = (~sel[1] & ~sel[0])? in[8]: (~sel[1] & sel[0])? in[9]: in[10];
assign tmp0[9] = (~sel[1] & ~sel[0])? in[9]: (~sel[1] & sel[0])? in[10]: in[11];
assign tmp0[10] = (~sel[1] & ~sel[0])? in[10]: (~sel[1] & sel[0])? in[11]: in[12];
assign tmp0[11] = (~sel[1] & ~sel[0])? in[11]: (~sel[1] & sel[0])? in[12]: in[13];
assign tmp0[12] = (~sel[1] & ~sel[0])? in[12]: (~sel[1] & sel[0])? in[13]: in[14];
assign tmp0[13] = (~sel[1] & ~sel[0])? in[13]: (~sel[1] & sel[0])? in[14]: in[15];
assign tmp0[14] = (~sel[1] & ~sel[0])? in[14]: (~sel[1] & sel[0])? in[15]: in[0];
assign tmp0[15] = (~sel[1] & ~sel[0])? in[15]: (~sel[1] & sel[0])? in[0]: in[1];

//tmp1
assign tmp1[0] = (~sel[3] & ~sel[2])? tmp0[0]: (~sel[3] & sel[2])? tmp0[3]: tmp0[6];
assign tmp1[1] = (~sel[3] & ~sel[2])? tmp0[1]: (~sel[3] & sel[2])? tmp0[4]: tmp0[7];
assign tmp1[2] = (~sel[3] & ~sel[2])? tmp0[2]: (~sel[3] & sel[2])? tmp0[5]: tmp0[8];
assign tmp1[3] = (~sel[3] & ~sel[2])? tmp0[3]: (~sel[3] & sel[2])? tmp0[6]: tmp0[9];
assign tmp1[4] = (~sel[3] & ~sel[2])? tmp0[4]: (~sel[3] & sel[2])? tmp0[7]: tmp0[10];
assign tmp1[5] = (~sel[3] & ~sel[2])? tmp0[5]: (~sel[3] & sel[2])? tmp0[8]: tmp0[11];
assign tmp1[6] = (~sel[3] & ~sel[2])? tmp0[6]: (~sel[3] & sel[2])? tmp0[9]: tmp0[12];
assign tmp1[7] = (~sel[3] & ~sel[2])? tmp0[7]: (~sel[3] & sel[2])? tmp0[10]: tmp0[13];
assign tmp1[8] = (~sel[3] & ~sel[2])? tmp0[8]: (~sel[3] & sel[2])? tmp0[11]: tmp0[14];
assign tmp1[9] = (~sel[3] & ~sel[2])? tmp0[9]: (~sel[3] & sel[2])? tmp0[12]: tmp0[15];
assign tmp1[10] = (~sel[3] & ~sel[2])? tmp0[10]: (~sel[3] & sel[2])? tmp0[13]: tmp0[0];
assign tmp1[11] = (~sel[3] & ~sel[2])? tmp0[11]: (~sel[3] & sel[2])? tmp0[14]: tmp0[1];
assign tmp1[12] = (~sel[3] & ~sel[2])? tmp0[12]: (~sel[3] & sel[2])? tmp0[15]: tmp0[2];
assign tmp1[13] = (~sel[3] & ~sel[2])? tmp0[13]: (~sel[3] & sel[2])? tmp0[0]: tmp0[3];
assign tmp1[14] = (~sel[3] & ~sel[2])? tmp0[14]: (~sel[3] & sel[2])? tmp0[1]: tmp0[4];
assign tmp1[15] = (~sel[3] & ~sel[2])? tmp0[15]: (~sel[3] & sel[2])? tmp0[2]: tmp0[5];

//tmp2
assign tmp2[0] = (~sel[5] & ~sel[4])? tmp1[0]: (~sel[5] & sel[4])? tmp1[9]: tmp1[0];
assign tmp2[1] = (~sel[5] & ~sel[4])? tmp1[1]: (~sel[5] & sel[4])? tmp1[10]: tmp1[1];
assign tmp2[2] = (~sel[5] & ~sel[4])? tmp1[2]: (~sel[5] & sel[4])? tmp1[11]: tmp1[2];
assign tmp2[3] = (~sel[5] & ~sel[4])? tmp1[3]: (~sel[5] & sel[4])? tmp1[12]: tmp1[3];
assign tmp2[4] = (~sel[5] & ~sel[4])? tmp1[4]: (~sel[5] & sel[4])? tmp1[13]: tmp1[4];
assign tmp2[5] = (~sel[5] & ~sel[4])? tmp1[5]: (~sel[5] & sel[4])? tmp1[14]: tmp1[5];
assign tmp2[6] = (~sel[5] & ~sel[4])? tmp1[6]: (~sel[5] & sel[4])? tmp1[15]: tmp1[6];
assign tmp2[7] = (~sel[5] & ~sel[4])? tmp1[7]: (~sel[5] & sel[4])? tmp1[0]: tmp1[7];
assign tmp2[8] = (~sel[5] & ~sel[4])? tmp1[8]: (~sel[5] & sel[4])? tmp1[1]: tmp1[8];
assign tmp2[9] = (~sel[5] & ~sel[4])? tmp1[9]: (~sel[5] & sel[4])? tmp1[2]: tmp1[9];
assign tmp2[10] = (~sel[5] & ~sel[4])? tmp1[10]: (~sel[5] & sel[4])? tmp1[3]: tmp1[10];
assign tmp2[11] = (~sel[5] & ~sel[4])? tmp1[11]: (~sel[5] & sel[4])? tmp1[4]: tmp1[11];
assign tmp2[12] = (~sel[5] & ~sel[4])? tmp1[12]: (~sel[5] & sel[4])? tmp1[5]: tmp1[12];
assign tmp2[13] = (~sel[5] & ~sel[4])? tmp1[13]: (~sel[5] & sel[4])? tmp1[6]: tmp1[13];
assign tmp2[14] = (~sel[5] & ~sel[4])? tmp1[14]: (~sel[5] & sel[4])? tmp1[7]: tmp1[14];
assign tmp2[15] = (~sel[5] & ~sel[4])? tmp1[15]: (~sel[5] & sel[4])? tmp1[8]: tmp1[15];

assign out = tmp2;

endmodule