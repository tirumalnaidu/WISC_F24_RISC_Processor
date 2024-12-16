`timescale 1ns / 1ps

module tb_memory_system();

    parameter AWIDTH = 16;
    parameter DWIDTH = 16;

    reg clk;
    reg rst;
    reg mem_write;
    reg mem_en;
    reg [15:0] instr_addr_in;
    reg [15:0] data_addr_in;

    reg [15:0] data_in;
    wire [15:0] instr_out;
    wire [15:0] data_out;
    wire icache_miss_stall;
    wire dcache_miss_stall;

    memory_system # (
        .DWIDTH(16),
        .AWIDTH(16)
      )
      memory_system_inst (
        .clk(clk),
        .rst(rst),
        .mem_write(mem_write),
        .mem_en(mem_en),
        .instr_addr_in(instr_addr_in),
        .data_addr_in(data_addr_in),
        .data_in(data_in),
        .instr_out(instr_out),
        .data_out(data_out),
        .icache_miss_stall(icache_miss_stall),
        .dcache_miss_stall(dcache_miss_stall)
      );

    task i_read_mem(input [AWIDTH-1:0] addr, input miss);
    begin
        @(posedge clk);
        instr_addr_in = addr;

        if(miss) begin
            @(negedge icache_miss_stall);
        end   

        repeat(3) @(posedge clk);
    end
    endtask

    task d_read_mem(input [AWIDTH-1:0] addr, input miss);
    begin
        @(posedge clk);
        mem_en = 1'b1;
        mem_write = 1'b0;
        data_addr_in = addr;

        if(miss) begin
            @(negedge dcache_miss_stall);
        end   

        repeat(3) @(posedge clk);

        mem_en = 1'b0;
    end
    endtask

    task d_write_mem(input [AWIDTH-1:0] addr, input [DWIDTH-1:0] data, input miss);
    begin
        @(posedge clk);
        mem_en = 1'b1;
        mem_write = 1'b1;
        data_addr_in = addr;
        data_in = data;

        if(miss) begin
            @(negedge dcache_miss_stall);
        end

        repeat(3) @(posedge clk);

        mem_en = 1'b0;
    end
    endtask

    initial begin
        clk <= 1;
        $dumpfile("tb_memory_system.vcd"); 
        $dumpvars(0, tb_memory_system); 

        forever #10 clk <= ~clk;
      end
    
    initial begin
        rst = 1;  /* Intial reset state */
        #21 rst = 0;  // delay until slightly after two clock periods
    end

      
    initial begin
        mem_write = 0;
        mem_en = 0;
        instr_addr_in = 16'h0000;
        data_addr_in = 16'h0000;
        data_in = 16'h0000;
        #20;

        // i_read_mem(16'h0000, 1'b1);

        d_write_mem(16'h0000, 16'hABCD, 1'b1);
        d_write_mem(16'h0002, 16'h1234, 1'b0);

        d_write_mem(16'h0100, 16'hFF00, 1'b1);

        d_read_mem(16'h0000, 1'b0);

        $finish;
    end

endmodule
