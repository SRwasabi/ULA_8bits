`include "ula.v"
`timescale 1ns/100ps

module ULA_tb;
  reg [7:0] Atb, Btb;
  reg [2:0] selectb;
  wire [8:0] Stb;
  reg en;

  ULA # (.N(8)) ulaon (.A(Atb), .B(Btb), .selec(selectb), .S(Stb), .en(en));
                  	 
  initial begin
	$dumpfile("ula.vcd");
	$dumpvars(0, ulaon);
    en = 1'b1;

    Atb = 8'd55; Btb = 8'd10;

    selectb = 3'b000; #20; // +
    selectb = 3'b001; #20; // -

    selectb = 3'b010; #20; // >
    Atb = 8'd55; Btb = 8'd100; #20;

    selectb = 3'b011; #20; // <
    Atb = 8'd55; Btb = 8'd10; #20;

    selectb = 3'b100; #20; // >=
    Atb = 8'd55; Btb = 8'd10; #20;
    Atb = 8'd10; Btb = 8'd10; #20;
    Atb = 8'd5; Btb = 8'd10; #20;

    selectb = 3'b101; #20; // <=
    Atb = 8'd10; Btb = 8'd125; #20;
    Atb = 8'd100; Btb = 8'd12; #20;

    selectb = 3'b110; #20; // ==
    Atb = 8'd10; Btb = 8'd10; #20;

  end
                  	 
  always @(selectb) begin
	$display("%b", selectb);
  end
 
endmodule
