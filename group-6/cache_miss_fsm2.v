
module cache_fill_fsm2 (
    input clk,
    input rst,
    input d_miss_detected,
    input i_miss_detected,
    input [15:0] d_miss_address,
    input [15:0] i_miss_address,
    input memory_data_valid,
    
    output reg d_stall,
    output reg i_stall,
    output reg [15:0] memory_address,
    output reg write_d_data_array,
    output reg write_d_tag_array,
    output reg write_i_data_array,
    output reg write_i_tag_array
);

//reg d_stall;
//reg i_stall;
//reg write_d_tag_array;
//reg write_d_data_array;
//reg write_i_tag_array;
//reg write_i_data_array;
//reg [15:0] memory_address;*/

reg set_which_cache_data;
reg rst_which_cache_data;
wire which_cache_data; //High if data is D-cache, low if data is I-cache
dff which_cache_data_reg(
    .d(set_which_cache_data | (which_cache_data & (~rst_which_cache_data))),
    .q(which_cache_data),
    .wen(1'b1),
    .clk(clk),
    .rst(rst)
);

reg set_which_cache_addr;
reg rst_which_cache_addr;
wire which_cache_addr; //High is address to be sent out is D-cache, low if address to be sent out is I-cache
dff which_cache_addr_reg( //using D-flip flop as set reset flop
    .d(set_which_cache_addr | (which_cache_addr & (~rst_which_cache_addr))),
    .q(which_cache_addr),
    .wen(1'b1),
    .clk(clk),
    .rst(rst)
);

reg init;
wire [11:0] shift_reg;
pldff #(.WIDTH(12))shift_register(
    .d({shift_reg[10:0],init}),
    .q(shift_reg),
    .clk(clk),
    .rst(rst),
    .wen(1'b1)
);
localparam IDLE = 1'b0;
localparam WAIT = 1'b1;

wire state;
reg nxt_state;
dff state_transition_flop(
    .d(nxt_state),
    .q(state),
    .clk(clk),
    .rst(rst),
    .wen(1'b1)
);

always @(*) begin
    init = 0;
    //$display("I do come here");
    memory_address = 16'hffff;
    nxt_state = state;
    set_which_cache_addr = 0;
    rst_which_cache_addr = 0;
    set_which_cache_data = 0;
    rst_which_cache_data = 0;
    write_d_data_array = 0;
    write_i_data_array = 0;
    write_d_tag_array = 0;
    write_i_tag_array = 0;
    d_stall = 0;
    i_stall = 0;
    case(state)
        IDLE: begin
	    //$display("I do come here also");
            nxt_state = (d_miss_detected | i_miss_detected);
            init = ((d_miss_detected | i_miss_detected) == 1'b1);
            set_which_cache_addr = d_miss_detected;
            set_which_cache_data = d_miss_detected;
            i_stall = i_miss_detected;
            d_stall = d_miss_detected;
            memory_address = (i_miss_detected) ? {i_miss_address[15:4],4'b0000}:
			     (d_miss_detected) ? {d_miss_address[15:4],4'b0000}:
			     16'hffff;
        end
        WAIT: begin
            i_stall = i_miss_detected;
            d_stall = d_miss_detected;

            write_d_data_array = (which_cache_data & memory_data_valid & (|shift_reg[11:4]));
            write_i_data_array = ((~which_cache_data) & memory_data_valid & (|shift_reg[11:4]));

            rst_which_cache_addr = (shift_reg[8] & which_cache_addr);
            rst_which_cache_data = (shift_reg[11] & which_cache_data);

            set_which_cache_addr = (shift_reg[8] & d_miss_detected & (~which_cache_addr));
            set_which_cache_data = (shift_reg[11] & d_miss_detected & (~which_cache_data));

            write_d_tag_array = (shift_reg[11] & which_cache_data);
            write_i_tag_array = (shift_reg[11] & ~which_cache_data);

            init = ((i_miss_detected & (which_cache_data)) | (d_miss_detected & (~which_cache_data))) & (~(|shift_reg[6:0]));

            memory_address[15:4] = (which_cache_addr | set_which_cache_addr) ? (d_miss_address[15:4]) : (i_miss_address[15:4]);

            memory_address[3:0] =   (shift_reg[7:0] == 8'h01) ? ({4'b0000}):
                                    (shift_reg[7:0] == 8'h02) ? ({4'b0010}):
                                    (shift_reg[7:0] == 8'h04) ? ({4'b0100}):
                                    (shift_reg[7:0] == 8'h08) ? ({4'b0110}):
                                    (shift_reg[7:0] == 8'h10) ? ({4'b1000}):
                                    (shift_reg[7:0] == 8'h20) ? ({4'b1010}):
                                    (shift_reg[7:0] == 8'h40) ? ({4'b1100}):
                                    (shift_reg[7:0] == 8'h80) ? ({4'b1110}):
                                    4'b0000;
	    nxt_state = (d_miss_detected | i_miss_detected);

	    end
	    default: begin
		nxt_state = IDLE;
		init = 0;
	    end
    endcase
    
end
endmodule