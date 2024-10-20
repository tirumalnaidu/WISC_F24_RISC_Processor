module control_unit(
    input [3:0] opcode,
    output reg_dst,
    output reg_write,
    output alu_src,
    output mem_read,
    output mem_write,
    output mem_to_reg,
    output llb_en,
    output hlb_en,
    output branch,
    output branchr,
    output pcs,
    output halt
);

reg opcode_reg, reg_dst_reg, alu_src_reg, mem_read_reg, mem_write_reg, mem_to_reg_reg, reg_write_reg,
  llb_en_reg, hlb_en_reg, branch_reg, branchr_reg, pcs_reg, halt_reg;
  
always @(*) begin
  
    casex (opcode)       
        // For ADD, SUB, XOR, RED, PADDSB  
        4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0111: begin       
            reg_dst_reg <= 1;
            reg_write_reg <= 1;
            alu_src_reg <= 0;
            mem_read_reg <= 0;
            mem_write_reg <= 0;
            mem_to_reg_reg <= 0;
            llb_en_reg <= 0;
            hlb_en_reg <= 0;
            branch_reg <= 0;
            branchr_reg <= 0;
            pcs_reg <= 0;
            halt_reg <= 0;
        end

        // For SLL, SRA, ROR
        4'b0100, 4'b0101, 4'b0110: begin        
             reg_dst_reg <= 1;
             reg_write_reg <= 1;
             alu_src_reg <= 1;
             mem_read_reg <= 0;
             mem_write_reg <= 0;
             mem_to_reg_reg <= 0;
             llb_en_reg <= 0;
             hlb_en_reg <= 0;
             branch_reg <= 0;
             branchr_reg <= 0;
             pcs_reg <= 0;
             halt_reg <= 0;
        end

        // For LW
        4'b1000: begin       
             reg_dst_reg <= 0;
             reg_write_reg <= 1;
             alu_src_reg <= 1;
             mem_read_reg <= 1;
             mem_write_reg <= 0;
             mem_to_reg_reg <= 1; 
             llb_en_reg <= 0;
             hlb_en_reg <= 0;
             branch_reg <= 0;
             branchr_reg <= 0;
             pcs_reg <= 0;
             halt_reg <= 0;
        end

        // For SW
        4'b1001: begin        
             reg_dst_reg <= 0;
             reg_write_reg <= 0;
             alu_src_reg <= 1;
             mem_read_reg <= 0;
             mem_write_reg <= 1;
             mem_to_reg_reg <= 0;
             llb_en_reg <= 0;
             hlb_en_reg <= 0;
             branch_reg <= 0;
             branchr_reg <= 0;
             pcs_reg <= 0;
             halt_reg <= 0;
        end

        // For LLB
        4'b1010: begin       
             reg_dst_reg <= 1;
             reg_write_reg <= 1;
             alu_src_reg <= 1;
             mem_read_reg <= 0;
             mem_write_reg <= 0;
             mem_to_reg_reg <= 0;
             llb_en_reg <= 1;
             hlb_en_reg <= 0;
             branch_reg <= 0;
             branchr_reg <= 0;
             pcs_reg <= 0;
             halt_reg <= 0;
        end

        // For LHB
        4'b1011: begin       
             reg_dst_reg <= 1;
             reg_write_reg <= 1;
             alu_src_reg <= 1;
             mem_read_reg <= 0;
             mem_write_reg <= 0;
             mem_to_reg_reg <= 0;
             llb_en_reg <= 0;
             hlb_en_reg <= 1;
             branch_reg <= 0;
             branchr_reg <= 0;
             pcs_reg <= 0;
             halt_reg <= 0;
        end

        // For B
        4'b1100: begin        
             reg_dst_reg <= 0;
             reg_write_reg <= 0;
             alu_src_reg <= 0;
             mem_read_reg <= 0;
             mem_write_reg <= 0;
             mem_to_reg_reg <= 0;
             llb_en_reg <= 0;
             hlb_en_reg <= 0;
             branch_reg <= 1;
             branchr_reg <= 0;
             pcs_reg <= 0;
             halt_reg <= 0;
        end

        // For BR
        4'b1101: begin        
             reg_dst_reg <= 0;
             reg_write_reg <= 0;
             alu_src_reg <= 0;
             mem_read_reg <= 0;
             mem_write_reg <= 0;
             mem_to_reg_reg <= 0;      
             llb_en_reg <= 0;
             hlb_en_reg <= 0;
             branch_reg <= 1;
             branchr_reg <= 1;
             pcs_reg <= 0;
             halt_reg <= 0;
        end

        // For PCS
        4'b1110: begin       
             reg_dst_reg <= 0;
             reg_write_reg <= 1;
             alu_src_reg <= 0;
             mem_read_reg <= 0;
             mem_write_reg <= 0;
             mem_to_reg_reg <= 0;
             llb_en_reg <= 0;
             hlb_en_reg <= 0;
             branch_reg <= 0;
             branchr_reg <= 0;
             pcs_reg <= 1;
             halt_reg <= 0;
        end

        // For HLT
        4'b1111: begin        
             reg_dst_reg <= 0;
             reg_write_reg <= 0;
             alu_src_reg <= 0;
             mem_read_reg <= 0;
             mem_write_reg <= 0;
             mem_to_reg_reg <= 0;
             llb_en_reg <= 0;
             hlb_en_reg <= 0;
             branch_reg <= 0;
             branchr_reg <= 0;
             pcs_reg <= 0;
             halt_reg <= 1;
        end

        // Default case
        default: begin       
             reg_dst_reg <= 0;
             reg_write_reg <= 0;
             alu_src_reg <= 0;
             mem_read_reg <= 0;
             mem_write_reg <= 0;
             mem_to_reg_reg <= 0;
             llb_en_reg <= 0;
             hlb_en_reg <= 0;
             branch_reg <= 0;
             branchr_reg <= 0;
             pcs_reg <= 0;
             halt_reg <= 0;
        end
    endcase
end

    assign reg_dst = reg_dst_reg;
    assign reg_write = reg_write_reg;
    assign alu_src = alu_src_reg;
    assign  mem_read = mem_read_reg;
    assign  mem_write = mem_write_reg;
    assign  mem_to_reg = mem_to_reg_reg;
    assign  llb_en = llb_en_reg;
    assign  hlb_en = hlb_en_reg;
    assign  branch = branch_reg;
    assign  branchr = branchr_reg;
    assign  pcs = pcs_reg;
    assign  halt = halt_reg;

endmodule