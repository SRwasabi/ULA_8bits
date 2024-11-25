//Meio somador
module meio_somador
    (input a, b,
     output sum, cout);

    assign sum = a ^ b;
    assign cout = a & b;
endmodule

//somador completo
module somador_completo
    (input a, b, cin,
     output sum, cout);

    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule

//Operacao com 8bits
module somador_8 # (parameter N = 8)
    (input[N-1:0] a1,
     input[N-1:0] b1,
     output [N-1:0] cin,
     output[N:0] soma);
    
    genvar i;
    generate 
        meio_somador u0 (.a(a1[0]), .b(b1[0]), .cout(cin[0]), .sum(soma[0]));
        for(i = 1; i < N; i = i + 1) begin
            somador_completo u1 (.a(a1[i]), .b(b1[i]), .cin(cin[i-1]), .cout(cin[i]), .sum(soma[i]));
        end
        assign soma[8] = cin[7];
    endgenerate
endmodule



//meio subtrator
module meio_sub
    (input a, b,
     output sub, cout);

    assign sub = a ^ b;
    assign cout = ~a & b;
endmodule

//Subtrator completo
module sub_completo
    (input a, b, cin,
     output sub, cout);

    assign sub = a ^ b ^ cin;
    assign cout = (~a & b) | (cin & (~a ^ b));
endmodule

//Subtratir 8bits
module sub_8 # (parameter N = 8)
    (input[N-1:0] a1,
     input[N-1:0] b1,
     output [N-1:0] cin,
     output[N:0] sub);
    
    genvar i;
    generate 
        meio_sub u0 (.a(a1[0]), .b(b1[0]), .cout(cin[0]), .sub(sub[0]));
        for(i = 1; i < N; i = i + 1) begin
            sub_completo u1 (.a(a1[i]), .b(b1[i]), .cin(cin[i-1]), .cout(cin[i]), .sub(sub[i]));
        end
        assign sub[8] = cin[7];
    endgenerate
endmodule

module comparador
    (
        input a, b,
        output S
    );
    assign S = ~(a ^ b);
endmodule

module comparadores_mag_8 # (parameter N = 8)
    (
        input[N-1:0] a1,
        input[N-1:0] b1,
        output[N:0] Si, Sma, Sme
    );
    
    wire[N-1:0]S1;

    genvar i;
    generate
        for(i = 0; i < N; i = i + 1)begin
            comparador u2 (.a(a1[i]), .b(b1[i]), .S(S1[i]));
        end
    endgenerate

    assign Si = &S1;
    assign Sma = (
     (a1[7] & ~b1[7]) | 
     (S1[7] & a1[6] & ~b1[6]) | 
     (S1[7] & S1[6] & a1[5] & ~b1[5]) | 
     (S1[7] & S1[6] & S1[5] & a1[4] & ~b1[4]) | 
     (S1[7] & S1[6] & S1[5] & S1[4] & a1[3] & ~b1[3]) |
     (S1[7] & S1[6] & S1[5] & S1[4] & S1[3] & a1[2] & ~b1[2]) |
     (S1[7] & S1[6] & S1[5] & S1[4] & S1[3] & S1[2] & a1[1] & ~b1[1]) |
     (S1[7] & S1[6] & S1[5] & S1[4] & S1[3] & S1[2] & S1[1] & a1[0] & ~b1[0]) 
    );
    assign Sme = &(~(Si | Sma));

endmodule

//Operacao com 16bits
module somador_16 # (parameter N = 16)
    (input[N-1:0] a1,
     input[N-1:0] b1,
     output[N-1:0] soma);

    wire [N-1:0] cin;
    
    genvar i;
    generate 
        meio_somador u0 (.a(a1[0]), .b(b1[0]), .cout(cin[0]), .sum(soma[0]));
        for(i = 1; i < N; i = i + 1) begin
            somador_completo u1 (.a(a1[i]), .b(b1[i]), .cin(cin[i-1]), .cout(cin[i]), .sum(soma[i]));
        end
    endgenerate
endmodule

module multi_8 #(parameter N = 8)
 (
    input [N-1:0] a1, 
    input [N-1:0] b1,  
    output [2*N-1:0] S  
 );

    wire [2*N-1:0] temp [N-1:0];
    wire [2*N-1:0] temp2 [N-1:0];

    genvar i;
    generate 
        for(i = 0; i < N; i = i + 1) begin
            assign temp[i] = (a1 & {N{b1[i]}}) << i;
        end
    endgenerate
    
        assign temp2[0] = temp[0];

    generate 
        for(i = 1; i < N; i = i + 1) begin
            somador_16 # (.N(N*2)) u1 (.a1(temp2[i-1]), .b1(temp[i]), .soma(temp2[i]));
        end
    endgenerate

    assign S = temp2[N-1];
endmodule


//E se para >, <, >= e <= eu apenas inverter a ordem?????

/*
module completo_somador # (parameter N = 8)
    (input[N-1:0] a1,
     input[N-1:0] b1,
     input[N-2:0] cin,
     output[N:0] soma;)
    
    genvar i;
    generate 
        meio_somador u0(.a(a1[0]), .b(b1[0]), .c(cin[0]), .sum(soma[0]));
        for(i = 1; i < N; i = i + 1) begin
            assign soma[i] = a1[i] ^ b1 ^ cin[i-1];
            assign cin[i] = (a1[i] & b1[i]) 
        end

    endgenerate


endmodule
*/

/*
module multi_8 #(parameter N = 8)
 (
    input [N-1:0] a1,  // 8-bit input a1
    input [N-1:0] b1,  // 8-bit input b1
    output reg [2*N-1:0] S  // 16-bit result (2 * N)
 );

    reg [2*N-1:0] aux;
    integer i;

    always @(*) begin
        aux = a1;
        S = 0;  // Initialize S to zero before accumulation
        
        // Loop over each bit of b1
        for(i = 0; i < N; i = i + 1) begin
            if (b1[i] == 1) begin
                S = S + (aux << i);  // Add the shifted value of a1 to S
            end
        end
    end

endmodule

*/