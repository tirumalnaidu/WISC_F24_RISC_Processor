// ALU is effectively all compute subcomponent connected to a MUX; 
// opcode is the selection signal


`include "addsub_16bit.v"       // for ADD & SUB
`include "red_16bit.v"          // for RED
`include "paddsub_16bit.v"      // for PADDSUB
`include "xor_16bit.v"          // for XOR

module alu_16bit (
    input [15:0] alu_in1,
    input [15:0] alu_in2,
    input [3:0] opcode,         // 4-bit opcode
    output [15:0] alu_out,      // 16-bit ALU output
    output [2:0] flag           // 3-bit flag 
);


// wires to hold results
// wire [2:0]flag;
wire [15:0] addsub_out;
wire [15:0] xor_out;
wire [15:0] paddsub_out;
wire [15:0] red_out;
wire is_sub;

// set is_sub for ADD & SUB type instructions
assign is_sub = (opcode == 4'b0000) ? 1'b0 : 
                (opcode == 4'b0001)? 1'b1 : 1'bx;

// call modules to set results into wires
addsub_16bit ADDSUB(.a_in(alu_in1[15:0]), .b_in(alu_in2[15:0]), .is_sub(is_sub), .sum_out(addsub_out[15:0]), .flag(flag[2:0]));
xor_16bit XOR (.a_in(alu_in1[15:0]), .b_in(alu_in2[15:0]), .xor_out(xor_out[15:0]), .flag(flag[2:0]));
paddsub_16bit PADDSUB (.a_in(alu_in1[15:0]),  .b_in(alu_in2[15:0]),  .sum_out(paddsub_out[15:0]));
red_16bit RED (.a_in(alu_in1[15:0]), .b_in(alu_in2[15:0]), .sum_out(red_out[15:0]));

always @(opcode) begin
    case (opcode)
        4'b0000: begin
            // ADD
            alu_out = addsub_out;
        end
        4'b0001: begin
            // SUB
            alu_out = addsub_out;
        end
        4'b0010: begin
            // XOR
            alu_out = xor_out;
            
        end
        4'b0011: begin
            // RED
            alu_out = red_out;
            assign flag = {1'b0, 1'b0, 1'b0};
        end
        
        4'b0100: begin
            // SLL
            
        end
        4'b0101: begin
            // SRA
            
        end
        4'b0110: begin
            // ROR
        end

        4'b0111: begin
            // PADDSUB
            alu_out = paddsub_out;
            assign flag = {1'b0, 1'b0, 1'b0};
        end

        4'b1000: begin
            // LW
            
        end
        4'b1001: begin
            // SW
            
        end
        4'b1010: begin
            // LLB
        end
        4'b1011: begin
            // LHB
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
        


        default: alu_out = 16'b0000_0000_0000_0000;
        
    endcase
end


    
endmodule