module xor_16bit(
	input [15:0] 	a_in,
	input [15:0] 	b_in,
	output [15:0] 	xor_out,
	output [2:0] 	flag  // xor modifies only the ZERO flag
);

// bit-wise XOR
assign xor_out = a_in ^ b_in;

// how do I take flag values as input & output 
// I need to modify Z flag but not the rest

// set flag register to 000
assign flag = {1'b0, 1'b0, 1'b0};

// modify the ZERO flag only
assign flag[0] = |xor_out;


endmodule

// assign xor_out[0] = a_in[0] ^ b_in[0];
// assign xor_out[1] = a_in[1] ^ b_in[1];
// assign xor_out[2] = a_in[2] ^ b_in[2];
// assign xor_out[3] = a_in[3] ^ b_in[3];

// assign xor_out[4] = a_in[4] ^ b_in[4];
// assign xor_out[5] = a_in[5] ^ b_in[5];
// assign xor_out[6] = a_in[6] ^ b_in[6];
// assign xor_out[7] = a_in[7] ^ b_in[7];

// assign xor_out[8] = a_in[8] ^ b_in[8];
// assign xor_out[9] = a_in[9] ^ b_in[9];
// assign xor_out[10] = a_in[10] ^ b_in[10];
// assign xor_out[11] = a_in[11] ^ b_in[11];

// assign xor_out[12] = a_in[12] ^ b_in[12];
// assign xor_out[13] = a_in[13] ^ b_in[13];
// assign xor_out[14] = a_in[14] ^ b_in[14];
// assign xor_out[15] = a_in[15] ^ b_in[15];