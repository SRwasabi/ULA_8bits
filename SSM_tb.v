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
    clr = 0;

    Atb = 8'd55; Btb = 8'd10; //Primeiro Iput

    selectb = 3'b111; #20; // Multiplicacao
    Atb = 8'd10; Btb = 8'd90; #20;
    Atb = 8'd100; Btb = 8'd254; #20;

    selectb = 3'b000; #20; // Soma
    Atb = 8'd100; Btb = 8'd254; #20;
    Atb = 8'd10; Btb = 8'd89; #20;

    selectb = 3'b001; #20; // Soma
    Atb = 8'd251; Btb = 8'd50; #20;
    Atb = 8'd255; Btb = 8'd255; #20;
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
