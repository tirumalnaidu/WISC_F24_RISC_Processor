`include "paddsub_16bit.v"

module paddsub_16bit_tb ();
    
    // reg is input
    reg [15:0] 	a_in;
    reg [15:0] 	b_in;
    // reg is_sub;

    // wire is output
    wire [15:0] sum_out;

    paddsub_16bit idut (.a_in(a_in), .b_in(b_in), .sum_out(sum_out));

    initial begin
    $dumpfile("paddsub_16bit.vcd");
    $dumpvars(0, idut);
  end


  initial begin
    a_in = 16'h1284;
    b_in = 16'h1111;

    #15

    // [N V Z]
    if (sum_out === 16'h2395) 
    begin
        $display("Paddsub Works\n");
    end
    else begin
        $display("Paddsub Fails\n");
    end

   


  end

endmodule