`include "addsub_16bit.v"

module addsub_16bit_tb ();
    // input = reg
    reg [15:0] 	a_in;
	reg [15:0] 	b_in;
	reg 		is_sub;

    // output = wire
    wire [15:0] sum_out;
	wire [2:0] 	flag;

    addsub_16bit idut(.a_in(a_in), .b_in(b_in), .is_sub(is_sub), .sum_out(sum_out), .flag(flag));

  initial begin
    $dumpfile("addsub_16bit.vcd");
    $dumpvars(0, idut);
  end


  initial begin
    a_in = 16'h8000;
    b_in = 16'h0001;
    is_sub = 1'b1;

    #15

    // [N V Z]
    if (sum_out === 16'h8000 && flag === 3'b110) 
    begin
        $display("Addsub Works\n");
    end
    else begin
        $display("Addsub Fails\n");
    end


  end



endmodule