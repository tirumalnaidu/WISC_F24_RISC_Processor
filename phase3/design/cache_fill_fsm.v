module cache_fill_fsm(
  input clk,
  input rst, 
  input miss_detected, 
  input [15:0] miss_address, 
  output fsm_busy, 
  output fsm_data_wen, 
  output fsm_tag_wen, 
  output [15:0] memory_address, 
  input memory_data_valid 
);

// state -> 0: IDLE, 1: WAIT
wire state, next_state;
wire start_count;
wire [11:0] send_read;
wire shift_reg_start;

wire [3:0] addr_count, addr_count_incr;
wire mem_en;

// replace this counter with a 12-bit shift register 
// cla_adder_4bit byte_count_incr(
//                   .a_in(byte_count),
//                   .b_in(4'h1),
//                   .carry_in(1'b0),
//                   .adder_out(byte_count_next),
//                   .carry_out(),
//                   .ovfl()
// );

assign shift_reg_start = ~state & miss_detected & (send_read == 12'h000);
 
shift_register #(.WIDTH(12)
) shift_reg_inst(
  .clk(clk),
  .rst(rst),
  .start(shift_reg_start),
  .en(miss_detected),
  .shift_reg_out(send_read)
);

cla_adder_4bit addr_incr(
  .a_in({1'b0, memory_address[3:1]}),
  .b_in(4'h1),
  .carry_in(1'b0),
  .adder_out(addr_count_incr),
  .carry_out(/*unconnected*/),
  .ovfl(/*unconnected*/)
);

// dff to hold current state
dff state_dff(
  .clk(clk), 
  .rst(rst), 
  .d(next_state), 
  .q(state), 
  .wen(1'b1));

// dff byte_count_dff[3:0](.clk(clk), .rst(start_count), .d(byte_count_next), .q(byte_count), .wen(incr));
dff addr_dff[3:0](
  .clk(clk), 
  .rst(rst), 
  .d(addr_count_incr), 
  .q(addr_count), 
  .wen(mem_en));

assign mem_en = state ? (addr_count != 4'b1000) : (miss_detected ? 1'b1 : 1'b0);	
// assign incr   = state ? ((memory_data_valid & (send_read != 12h'800)) ? 1'b1 : 1'b0) : 1'b0;

assign memory_address = state ? {miss_address[15:4], addr_count << 1} : 
                                      (miss_detected ? {miss_address[15:4], 4'h0} : {miss_address[15:4], addr_count << 1});


assign next_state   = state ? ((send_read == 12'h800) ? 1'b0 : 1'b1) : (miss_detected ? 1'b1 : 1'b0);
assign fsm_busy     = state ? ((send_read != 12'h800) ? 1'b0 : 1'b1) : (miss_detected ? 1'b1 : 1'b0);
assign start_count  = state ? 1'b0 : (miss_detected ? 1'b1 : 1'b0);

assign fsm_data_wen = state ? ((memory_data_valid & (send_read != 12'h800)) ? 1'b1 : 1'b0) : 1'b0;
assign fsm_tag_wen  = state ? ((send_read == 12'h800) ? 1'b1 : 1'b0) : 1'b0;

endmodule

module shift_register #(
  parameter WIDTH = 12
) (
  input clk,
  input rst,
  input en,
  input start,
  output [WIDTH-1:0] shift_reg_out
);

wire [WIDTH-1:0] pldff_in;
wire [WIDTH-1:0] pldff_out;

assign pldff_in = {pldff_out[10:0],start};

endmodule