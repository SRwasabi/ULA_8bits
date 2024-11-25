`include "operacoes.v"

//========ULA========//
module ULA # (parameter N = 8)
  (
   input [N-1:0] A_in, B_in,
   input [2:0] selec,
   input en, Tclk, Tpr, Tclr,
   output [N:0] S,
   output [N*2-1:0] Smulti
  );
    wire [N-1:0] CIN;
    wire [N-1:0] CIN1;
    wire [N-1:0] Op;
    wire [2:0] As;  
    wire [N-1:0] Ds;  
    wire [N:0] SomaFio;
    wire [N:0] SubFio;
	wire [N:0] CompFio;
	wire [N:0] MaiorFio;
	wire [N:0] MenorFio;
	wire [2*N-1:0] MultiFio;
	wire [N-1:0] A, B;
	wire [N:0] S_in;
	wire [N*2-1:0] Smulti_in;

	//Registradores
	Registrador # (.N(N)) A_reg (.Clk8(Tclk), .Pr8(Tpr), .Clr8(Tclr), .D8(A_in), .Q8(A));
	Registrador # (.N(N)) B_reg (.Clk8(Tclk), .Pr8(Tpr), .Clr8(Tclr), .D8(B_in), .Q8(B));
	Registrador # (.N(N+1)) S_reg (.Clk8(Tclk), .Pr8(Tpr), .Clr8(Tclr), .D8(S_in), .Q8(S));
	Registrador # (.N(N*2)) Smulti_reg (.Clk8(Tclk), .Pr8(Tpr), .Clr8(Tclr), .D8(Smulti_in), .Q8(Smulti));

	//Operacoes realizadas internamente
    decoder # (.N(8)) u0 (.As(selec), .Ds(Op), .en(en));
    somador_8 # (.N(8)) sum1 (.a1(A), .b1(B), .cin(CIN), .soma(SomaFio));
    sub_8 # (.N(8)) sub1 (.a1(A), .b1(B), .cin(CIN1), .sub(SubFio));
	comparadores_mag_8 # (.N(8)) comp1 (.a1(A), .b1(B), .Si(CompFio), .Sma(MaiorFio), .Sme(MenorFio));
	multi_8 # (.N(8)) mult1 (.a1(A), .b1(B), .S(MultiFio));

	//Saidas dos tristate
    tristate tsoma (.A(SomaFio), .B(S_in), .en(Op[0]));
    tristate tsub(.A(SubFio), .B(S_in), .en(Op[1]));
	tristate tmaior(.A(MaiorFio), .B(S_in), .en(Op[2]));
	tristate tmenor(.A(MenorFio), .B(S_in), .en(Op[3]));
	tristate tmaior_igual(.A(MaiorFio | CompFio), .B(S_in), .en(Op[4]));
	tristate tmenor_igual(.A(MenorFio | CompFio), .B(S_in), .en(Op[5]));
	tristate tcomp(.A(CompFio), .B(S_in), .en(Op[6]));
	tristate_16 tmulti(.A(MultiFio), .B(Smulti_in), .en(Op[7]));

endmodule

//========Decoder========//
module decoder # (parameter N = 8)
  	(
		input [2:0] As,
		input en,
		output reg [N-1:0] Ds
	);

	always @ (As, en) begin

    	if(en) begin
        	case (As)
        	3'b000: Ds = 8'b00000001;
        	3'b001: Ds = 8'b00000010;
        	3'b010: Ds = 8'b00000100;
        	3'b011: Ds = 8'b00001000;
        	3'b100: Ds = 8'b00010000;
        	3'b101: Ds = 8'b00100000;
        	3'b110: Ds = 8'b01000000;
        	3'b111: Ds = 8'b10000000;
        	endcase
    	end
    	else begin
        	Ds = 8'b00000000;
    	end
	end
endmodule
                   	 
//========Tristate========//
module tristate (
	input [8:0] A,	
	output reg [8:0] B,
	input en      
);

	always @(*) begin
    	if(en)
        	B = A;
    	else
        	B = 9'bzzzzzzzzZ;
	end
endmodule


//========Tristate para 16 Bits========//
module tristate_16(
	input [15:0] A,	
	output reg [15:0] B, 
	input en      	
);

	always @(*) begin
    	if(en)
        	B = A;
    	else
        	B = 15'bzzzzzzzzZ;
	end
endmodule

//========Flip Flop D========//
module ffd
    (
     input wire Pr, Clr, Clk,
     input wire D,
     output reg Q
    );

    always @(negedge !Clk) begin

        if(Pr) Q = 1;
        else if(Clr) Q = 0;
        else begin
            case(D)
                1'b0 : Q = 0;
                1'b1 : Q = 1;
                default: Q = 0;
            endcase
        end
    end
endmodule


//========Registrador========//
module Registrador # (parameter N = 8)
     (
     input wire Pr8, Clr8, Clk8,
     input wire [N-1:0] D8,
     output wire [N-1:0] Q8
     ); 

    genvar i;
    generate 
        for (i = 0; i < N; i = i + 1) begin
            ffd ffd8 (.Clk(Clk8), .D(D8[i]), .Pr(Pr8), .Clr(Clr8), .Q(Q8[i]));
        end
    endgenerate

endmodule