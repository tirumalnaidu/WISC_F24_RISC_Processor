`timescale 1ns/1ns;
`include "shifter.v"
module shifter_tb();
    reg [15:0]  shift_in;
    reg [3:0]   shift_val;
    reg [1:0]   mode;
    wire [15:0] shift_out;
    wire [2:0]  flag;

    shifter shft(shift_in, shift_val, mode, shift_out, flag);

    initial begin
        $dumpfile("shifter_tb.vcd");
	    $dumpvars(0, shifter_tb);
    end

    initial begin
        shift_in = 16'h1234;
        // SLL
        /*
        mode = 2'b00;
        shift_val = 4'h0;
        #10;
        if(shift_out != (shift_in << shift_val)) $display("Error1");
        shift_val = 4'h1;
        #10;
        if(shift_out != (shift_in << 1)) $display("Error2");
        shift_val = 4'h4;
        #10;
        if(shift_out != (shift_in << 4)) $display("Error3");
        shift_val = 4'h5;
        #10;
        if(shift_out != (shift_in << 5)) $display("Error4");
        shift_val = 4'hA;
        #10;
        if(shift_out != (shift_in << 10)) $display("Error5");
        shift_val = 4'hF;        
        #10;
        if(shift_out != (shift_in << 15)) $display("Error6");
        */

        /*
        mode = 2'b01;
        shift_val = 4'h1;
        #10;
        if(shift_out != (temp >>> 1)) $display("Error1 %h", (shift_in>>>1));
        shift_val = 4'h2;
        #10;
        if(shift_out != (shift_in >>> 2)) $display("Error2");
        shift_val = 4'hB;
        #10;
        if(shift_out != (shift_in >>> 11)) $display("Error3");
        shift_val = 4'hC;
        #10;
        if(shift_out != (shift_in >>> 12)) $display("Error4");
        shift_val = 4'hD;
        #10;
        if(shift_out != (shift_in >>> 13)) $display("Error5");
        shift_val = 4'hF;        
        #10;
        if(shift_out != (shift_in >>> 15)) $display("Error6");
        */

        
        mode = 2'b10;
        shift_val = 4'h0;
        #10;
        if(shift_out != (shift_in >> 0 | shift_in<<16)) $display("Error1");
        shift_val = 4'h4;
        #10;
        if(shift_out != (shift_in >> 4 | shift_in<<12)) $display("Error2");
        shift_val = 4'h8;
        #10;
        if(shift_out != (shift_in >> 8 | shift_in << 8)) $display("Error3");
        shift_val = 4'hC;
        #10;
        if(shift_out != (shift_in >> 12 | shift_in << 4)) $display("Error4");
                
        $finish;
    end

endmodule