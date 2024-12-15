`timescale 1ns / 1ps

module tb_memory_system();

    reg clk;
    reg rst;
    reg mem_write;
    reg mem_read;
    reg mem_en;
    reg [15:0] addr_in;
    reg [15:0] data_in;
    wire [15:0] data_out;
    wire cache_miss_stall;

    memory_system # (
        .DWIDTH(16),
        .AWIDTH(16)
      )
      memory_system_inst (
        .clk(clk),
        .rst(rst),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_en(mem_en),
        .addr_in(addr_in),
        .data_in(data_in),
        .data_out(data_out),
        .cache_miss_stall(cache_miss_stall)
      );

    initial begin
        clk = 0;
        rst = 1;
        
        $dumpfile("tb_memory_system.vcd"); 
        $dumpvars(0, tb_memory_system); 
    end

    always #10 begin
        clk = ~clk;
    end

    initial begin
        #20 
        rst = 0;
        mem_write = 0;
        mem_read = 0;
        mem_en = 0;

        #10 
        mem_en = 1;
        mem_write = 1;
        addr_in = 16'hFFFE;
        data_in = 16'hABCD;

        #200; 

        $finish;
    end

endmodule
