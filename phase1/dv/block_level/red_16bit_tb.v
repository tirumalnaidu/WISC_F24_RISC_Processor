`include "red_16bit.v"

module red_16bit_tb ();

// reg is input
reg [15:0] a_in;
reg [15:0] b_in;

// wire is output
wire [15:0] sum_out;

red_16bit idut (.a_in(a_in), .b_in(b_in), .sum_out(sum_out));

initial begin
    $dumpfile("red_16bit.vcd");
    $dumpvars(0, idut);
  end

  initial begin
    a_in = 16'h22bb;
    b_in = 16'h22bb;

    #15

    // [N V Z]
    if (sum_out === 16'h01ba) 
    begin
        $display("RED Works\n");
    end
    else begin
        $display("RED Fails\n");
    end
  end

endmodule