// ALU is effectively all compute subcomponent connected to a MUX; 
// opcode is the selection signal


// `include "addsub_16bit.v"       // for ADD & SUB
// `include "red_16bit.v"          // for RED
// `include "paddsub_16bit.v"      // for PADDSUB
// `include "xor_16bit.v"          // for XOR
// `include "shifter.v"

module alu_16bit (
    input [15:0] alu_in1,       // 16-bit ALU input-1
    input [15:0] alu_in2,       // 16-bit ALU input-2
    input [3:0] opcode,         // 4-bit opcode
    output [15:0] alu_out,      // 16-bit ALU output
    output [2:0] flag           // 3-bit flag 
);


/*
Instruction     Opcode
ADD             0000
SUB             0001
XOR             0010
RED             0011
SLL             0100
SRA             0101
ROR             0110
PADDSB          0111
LW              1000
SW              1001
LLB             1010
LHB             1011
B               1100
BR              1101
PCS             1110
HLT             1111
*/


// wires to hold results
// wire [2:0]flag;
wire [15:0] addsub_out;
wire [15:0] xor_out;
wire [15:0] paddsub_out;
wire [15:0] red_out;
wire [15:0] shifter_out;
wire [15:0] or_out;        // store the result of LLB/LHB instruction
wire is_sub;                // select between ADD & SUB

// flag for each instruction that affects flag
wire [2:0] addsub_flag;
wire [2:0] xor_flag;
wire [2:0] shifter_flag;

// temporary reg type holders for the always block
// always block needs reg type
reg [15:0] alu_out_temp;     
reg [2:0] flag_temp;

// set is_sub for SUB type instruction
assign is_sub = (opcode == 4'b0001) ? 1'b1 : 1'b0;

// calculate llb  & lhb
assign or_out = alu_in1 | alu_in2;

// call modules to set results into wires
addsub_16bit    Adder   (.a_in(alu_in1[15:0]), .b_in(alu_in2[15:0]), .is_sub(is_sub), .sum_out(addsub_out[15:0]), .flag(addsub_flag[2:0]));
xor_16bit       XOR     (.a_in(alu_in1[15:0]), .b_in(alu_in2[15:0]), .xor_out(xor_out[15:0]), .flag(xor_flag[2:0]));
paddsub_16bit   Paddsub (.a_in(alu_in1[15:0]),  .b_in(alu_in2[15:0]),  .sum_out(paddsub_out[15:0]));
red_16bit       Red     (.a_in(alu_in1[15:0]), .b_in(alu_in2[15:0]), .sum_out(red_out[15:0]));
shifter         Shifter (.shift_in(alu_in1[15:0]), .shift_val(alu_in2[15:0]), .mode(opcode[1:0]), .shift_out(shifter_out), .flag(shifter_flag[2:0]));

// always block for alu_out
always @(*) begin
    case (opcode)
        4'b0000: begin
            // ADD
            alu_out_temp = addsub_out;  
        end

        4'b0001: begin
            // SUB
            alu_out_temp = addsub_out;
        end

        4'b0010: begin
            // XOR
            alu_out_temp = xor_out;
        end

        4'b0011: begin
            // RED
            alu_out_temp = red_out; 
        end
        
        4'b0100: begin
            // SLL
            alu_out_temp = shifter_out;
        end

        4'b0101: begin
            // SRA
            alu_out_temp = shifter_out;
        end

        4'b0110: begin
            // ROR
            alu_out_temp = shifter_out;
        end

        4'b0111: begin
            // PADDSUB
            alu_out_temp = paddsub_out; 
        end

        4'b1000: begin
            // LW
            alu_out_temp = addsub_out;
        end

        4'b1001: begin
            // SW
            alu_out_temp = addsub_out;
        end

        4'b1010: begin
            // LLB
            alu_out_temp = or_out;
        end

        4'b1011: begin
            // LHB
            alu_out_temp = or_out;
        end

        4'b1100: begin
            // B
        end

        4'b1101: begin
            // BR
        end
        4'b1110: begin
            // PCS
        end
        4'b1111: begin
            // HLT
        end
        
        default: alu_out_temp = 16'h0000;
        
    endcase
end


// always block for the flag register
always @(*) begin
    case (opcode)
        // ADD / SUB instructions change all flags
        // LW / SW modify ZERO flag
        // ADD / SUB / LW / SW use the addsub_16bit module
        4'b0000, 4'b0001, 4'b1000, 4'b1001 : begin
            flag_temp = addsub_flag;
        end 

        // XOR can modify the ZERO flag
        4'b0010 : begin
            flag_temp = xor_flag;
        end

        // SLL / SRA / ROR can modify the ZERO flag
        4'b0100, 4'b0101, 4'b0110 : begin
            flag_temp = shifter_flag;
        end

        default: flag_temp = 3'b000;
    endcase
end

// assign alu_out
assign alu_out = alu_out_temp;


// asign flag
assign flag =  flag_temp;   


endmodule