module cache_fill_fsm(
  input clk,
  input rst, 
  input dcache_miss_detected, 
  input icache_miss_detected, 
  input [15:0] dcache_miss_address, 
  input [15:0] icache_miss_address, 
  output dcache_fsm_data_wen, 
  output dcache_fsm_tag_wen, 
  output icache_fsm_data_wen, 
  output icache_fsm_tag_wen, 

  output [15:0] memory_address, 
  input memory_data_valid 
);

// state -> 0: IDLE, 1: WAIT
wire i_state, i_next_state;
wire d_state, d_next_state;

wire start_count;

// wire [3:0] byte_count, byte_count_next;
wire [11:0] send_read;
wire shift_reg_start;

wire [2:0] addr_count, addr_count_incr;

// replace this counter with a 12-bit shift register 
// cla_adder_4bit byte_count_incr(
//                   .a_in(byte_count),
//                   .b_in(4'h1),
//                   .carry_in(1'b0),
//                   .adder_out(byte_count_next),
//                   .carry_out(),
//                   .ovfl()
// );

assign shift_reg_start = ~d_next_state & (icache_miss_detected | dcache_miss_detected); 
 
shift_register #(.WIDTH(12)) 
                      shift_reg_inst(
                        .clk(clk),
                        .rst(rst),
                        .start(shift_reg_start),
                        .en(icache_miss_detected | dcache_miss_detected),
                        .shift_reg_out(send_read)
);

cla_adder_4bit addr_incr(
                  .a_in({1'b0,memory_address[3:1]}),
                  .b_in(4'h1),
                  .carry_in(1'b0),
                  .adder_out(addr_count_incr),
                  .carry_out(),
                  .ovfl()
);

dff i_state_dff(.clk(clk), .rst(rst), .d(i_next_state), .q(i_state), .wen(1'b1));
dff d_state_dff(.clk(clk), .rst(rst), .d(d_next_state), .q(d_state), .wen(1'b1));

dff addr_dff[2:0](.clk(clk), .rst(rst), .d(addr_count_incr), .q(addr_count), .wen(dcache_miss_detected | icache_miss_detected));


//TODO:
// if imiss before dmiss => consider dmiss
// if i_state = 1 (busy) and we encounter a dcache_miss_detected = 1 -> 
//        wait till send_read[7] == 1 and we can toggle d_next_state from 0 (idle) to 1 (busy)


// if d_state = 1 (busy) and we encounter a icache_miss_detected = 1 -> 
//        

wire [15:0] i_mem_addr, d_mem_addr;

// TODO
assign i_mem_addr = i_state ? {icache_miss_address[15:4], addr_count << 1} : 
                                      (icache_miss_detected ? {icache_miss_address[15:4], 4'h0} : {icache_miss_address[15:4], addr_count << 1});

// TODO
assign d_mem_addr = d_state ? {dcache_miss_address[15:4], addr_count << 1} : 
                                      (dcache_miss_detected ? {dcache_miss_address[15:4], 4'h0} : {dcache_miss_address[15:4], addr_count << 1});

assign memory_address = (i_state & d_state) ? d_mem_addr : i_state ? i_mem_addr : d_state ? d_mem_addr : 16'h0000;

assign i_next_state   = i_state ? ((send_read[10] == 1'b1) ? 1'b0 : 1'b1) : ((icache_miss_detected & d_next_state == 1'b0)  ? 1'b1 : 1'b0);
assign d_next_state   = d_state ? ((send_read[10] == 1'b1) ? 1'b0 : 1'b1) : ((dcache_miss_detected & addr_count == 3'h0) ? 1'b1 : 1'b0);

assign icache_fsm_data_wen = i_state ? ((memory_data_valid & (send_read[10] != 1'b1)) ? 1'b1 : 1'b0) : 1'b0;
assign dcache_fsm_data_wen = d_state ? ((memory_data_valid & (send_read[10] != 1'b1)) ? 1'b1 : 1'b0) : 1'b0;

assign icache_fsm_tag_wen  = i_state ? ((send_read[10] == 1'b1) ? 1'b1 : 1'b0) : 1'b0;
assign dcache_fsm_tag_wen  = d_state ? ((send_read[10] == 1'b1) ? 1'b1 : 1'b0) : 1'b0;

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

pldff #(.WIDTH(12)) shift_reg_pldff (
            .clk(clk),
            .rst(rst),
            .wen(en),
            .d(pldff_in),
            .q(pldff_out)
);

assign shift_reg_out = pldff_out;

endmodule
