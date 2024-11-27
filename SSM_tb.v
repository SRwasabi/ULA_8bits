`include "ula.v"
`timescale 1ns/100ps

module SSM_tb;
  reg [7:0] Atb, Btb;
  reg [2:0] selectb;
  wire [8:0] Stb;
  wire [15:0] Stb2;
  reg en;
  reg clk, pr, clr;

  ULA # (.N(8)) ulaon (.A_in(Atb), .B_in(Btb), .selec(selectb), .S(Stb), .Smulti(Stb2), .en(en), .Tclk(clk), .Tpr(pr), .Tclr(clr));
                  	 
  initial begin
	$dumpfile("SSM.vcd");
	$dumpvars(0, ulaon);
    en = 1'b1;
    clr = 1; #10;
    clr = 0; #10;

    selectb = 3'b111; // Multiplicacao
    Atb = 8'd55; Btb = 8'd100; #10;
    Atb = 8'd200; Btb = 8'd3; #10;
    Atb = 8'd50; Btb = 8'd50; #10;

    selectb = 3'b000; // Soma
    Atb = 8'd55; Btb = 8'd100; #10;
    Atb = 8'd200; Btb = 8'd3; #10;
    Atb = 8'd50; Btb = 8'd50; #10;

    selectb = 3'b001; // Soma
    Atb = 8'd55; Btb = 8'd100; #10;
    Atb = 8'd200; Btb = 8'd3; #10;
    Atb = 8'd50; Btb = 8'd50; #10;
    $finish;
  end

  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end
                  	 
  always @(selectb) begin
	$display("%b", selectb);
  end
 
endmodule
