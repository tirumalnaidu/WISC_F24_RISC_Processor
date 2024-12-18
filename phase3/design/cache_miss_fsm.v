module cache_fill_fsm (
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

reg cache_data_ctrl;
reg cache_data_reset;
wire cache_data_select;

dff cache_data_reg(
    .d(cache_data_ctrl | (cache_data_select & (~cache_data_reset))),
    .q(cache_data_select),
    .wen(1'b1),
    .clk(clk),
    .rst(rst)
);

reg cache_addr_ctrl;
reg cache_addr_reset;
wire cache_addr_select;

dff cache_addr_reg( 
    .d(cache_addr_ctrl | (cache_addr_select & (~cache_addr_reset))),
    .q(cache_addr_select),
    .wen(1'b1),
    .clk(clk),
    .rst(rst)
);

reg init_signal;
wire [11:0] shift_register_out;

pldff #(.WIDTH(12))shift_register(
    .d({shift_register_out[10:0],init_signal}),
    .q(shift_register_out),
    .clk(clk),
    .rst(rst),
    .wen(1'b1)
);

localparam IDLE_STATE = 1'b0;
localparam WAIT_STATE = 1'b1;

wire current_state;
reg next_state;

dff state_reg(
    .d(next_state),
    .q(current_state),
    .clk(clk),
    .rst(rst),
    .wen(1'b1)
);

always @(*) begin

    init_signal = 0;
    memory_address = 16'hffff;
    next_state = current_state;
    cache_addr_ctrl = 0;
    cache_addr_reset = 0;
    cache_data_ctrl = 0;
    cache_data_reset = 0;
    write_d_data_array = 0;
    write_i_data_array = 0;
    write_d_tag_array = 0;
    write_i_tag_array = 0;
    d_stall = 0;
    i_stall = 0;

    case(current_state)
        IDLE_STATE: begin
            next_state = (d_miss_detected | i_miss_detected);
            init_signal = ((d_miss_detected | i_miss_detected) == 1'b1);
            cache_addr_ctrl = d_miss_detected;
            cache_data_ctrl = d_miss_detected;
            i_stall = i_miss_detected;
            d_stall = d_miss_detected;
            memory_address = (i_miss_detected) ? {i_miss_address[15:4],4'b0000}:
		     (d_miss_detected) ? {d_miss_address[15:4],4'b0000}:
		     16'hffff;
        end
        
        WAIT_STATE: begin
            i_stall = i_miss_detected;
            d_stall = d_miss_detected;

            write_d_data_array = (cache_data_select & memory_data_valid & (|shift_register_out[11:4]));
            write_i_data_array = ((~cache_data_select) & memory_data_valid & (|shift_register_out[11:4]));

            cache_addr_reset = (shift_register_out[8] & cache_addr_select);
            cache_data_reset = (shift_register_out[11] & cache_data_select);

            cache_addr_ctrl = (shift_register_out[8] & d_miss_detected & (~cache_addr_select));
            cache_data_ctrl = (shift_register_out[11] & d_miss_detected & (~cache_data_select));

            write_d_tag_array = (shift_register_out[11] & cache_data_select);
            write_i_tag_array = (shift_register_out[11] & ~cache_data_select);

            init_signal = ((i_miss_detected & (cache_data_select)) | (d_miss_detected & (~cache_data_select))) & (~(|shift_register_out[6:0]));

            memory_address[15:4] = (cache_addr_select | cache_addr_ctrl) ? (d_miss_address[15:4]) : (i_miss_address[15:4]);

            memory_address[3:0] =   (shift_register_out[7:0] == 8'h01) ? ({4'b0000}):
                                    (shift_register_out[7:0] == 8'h02) ? ({4'b0010}):
                                    (shift_register_out[7:0] == 8'h04) ? ({4'b0100}):
                                    (shift_register_out[7:0] == 8'h08) ? ({4'b0110}):
                                    (shift_register_out[7:0] == 8'h10) ? ({4'b1000}):
                                    (shift_register_out[7:0] == 8'h20) ? ({4'b1010}):
                                    (shift_register_out[7:0] == 8'h40) ? ({4'b1100}):
                                    (shift_register_out[7:0] == 8'h80) ? ({4'b1110}):
                                    4'b0000;
	    next_state = (d_miss_detected | i_miss_detected);
	    end
	    default: begin
		next_state = IDLE_STATE;
		init_signal = 0;
	    end
    endcase
    
end
endmodule
