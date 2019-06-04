module MUX (A,B,S,Y);//Módulo MUX
  input wire A, B, S;//A = Entrada1; B = Entrada2; S = Controle;
  output wire Y;//Y = Saída;
  wire Sinv, A1, B1;//Auxiliares

  not neg( Sinv, S );//Sinv recebe ~S
  and e( A1, Sinv, A );//A1 recebe Sinv & A
  and e1( B1, S, B );//B1 recebe S & B
  or  ou( Y, A1, B1 );//Y recebe A1 | B1
endmodule//Fim módulo MUX

module meio_somador (A, B, Soma, Cout);//Módulo de soma parcial
  input  A, B;//Bits a serem somados
  output Soma, Cout;//Resultado da soma e Cout

  assign Soma = A ^ B;//Realiza a soma dos dois bits
  assign Cout = A & B;//Cálculo do Cout
endmodule//Fim módulo de soma parcial

module SOMADOR_1bit (A, B, Cin, Soma, Cout);//Somador completo de 1 bit
  input  A, B, Cin;//Bits a serem somados e Cin de entrada
  output Soma, Cout;//Resultado da soma e Cout
  wire Carry_1, Carry_2, Soma_1;//Carries para cada soma

  meio_somador sum1 (A, B, Soma_1, Carry_1);//Soma os dois bits
  meio_somador sum2 (Cin, Soma_1, Soma, Carry_2);//Trata o caso de overflow
  or ou (Cout, Carry_1, Carry_2);//Cálculo do Cout final
endmodule//Fim módulo de soma completa

module ripple_carry_adder (Soma, Cout, A, B, Cin);//Módulo que soma dois valores de 32 bits
  output [31:0]Soma;//Resultado da soma
  output Cout;//Cout final
  input  [31:0]A;//Primeiro valor
  input  [31:0]B;//Segundo valor
  input  Cin;//Cin de entrada
  wire C0, C1, C2, C3, C4,//Couts auxiliares das somas bit a bit
       C5, C6, C7, C8, C9, C10,
       C11, C12, C13, C14, C15,
       C16, C17, C18, C19, C20,
       C21, C22, C23, C24, C25,
       C26, C27, C28, C29, C30;
//Somas bit a bit
  SOMADOR_1bit U0 (Soma[0], C0, A[0], B[0], Cin);
  SOMADOR_1bit U1 (Soma[1], C1, A[1], B[1], C0);
  SOMADOR_1bit U2 (Soma[2], C2, A[2], B[2], C1);
  SOMADOR_1bit U3 (Soma[3], C3, A[3], B[3], C2);
  SOMADOR_1bit U4 (Soma[4], C4, A[4], B[4], C3);
  SOMADOR_1bit U5 (Soma[5], C5, A[5], B[5], C4);
  SOMADOR_1bit U6 (Soma[6], C6, A[6], B[6], C5);
  SOMADOR_1bit U7 (Soma[7], C7, A[7], B[7], C6);
  SOMADOR_1bit U8 (Soma[8], C8, A[8], B[8], C7);
  SOMADOR_1bit U9 (Soma[9], C9, A[9], B[9], C8);
  SOMADOR_1bit U10 (Soma[10], C10, A[10], B[10], C9);
  SOMADOR_1bit U11 (Soma[11], C11, A[11], B[11], C10);
  SOMADOR_1bit U12 (Soma[12], C12, A[12], B[12], C11);
  SOMADOR_1bit U13 (Soma[13], C13, A[13], B[13], C12);
  SOMADOR_1bit U14 (Soma[14], C14, A[14], B[14], C13);
  SOMADOR_1bit U15 (Soma[15], C15, A[15], B[15], C14);
  SOMADOR_1bit U16 (Soma[16], C16, A[16], B[16], C15);
  SOMADOR_1bit U17 (Soma[17], C17, A[17], B[17], C16);
  SOMADOR_1bit U18 (Soma[18], C18, A[18], B[18], C17);
  SOMADOR_1bit U19 (Soma[19], C19, A[19], B[19], C18);
  SOMADOR_1bit U20 (Soma[20], C20, A[20], B[20], C19);
  SOMADOR_1bit U21 (Soma[21], C21, A[21], B[21], C20);
  SOMADOR_1bit U22 (Soma[22], C22, A[22], B[22], C21);
  SOMADOR_1bit U23 (Soma[23], C23, A[23], B[23], C22);
  SOMADOR_1bit U24 (Soma[24], C24, A[24], B[24], C23);
  SOMADOR_1bit U25 (Soma[25], C25, A[25], B[25], C24);
  SOMADOR_1bit U26 (Soma[26], C26, A[26], B[26], C25);
  SOMADOR_1bit U27 (Soma[27], C27, A[27], B[27], C26);
  SOMADOR_1bit U28 (Soma[28], C28, A[28], B[28], C27);
  SOMADOR_1bit U29 (Soma[29], C29, A[29], B[29], C28);
  SOMADOR_1bit U30 (Soma[30], C30, A[30], B[30], C29);
  SOMADOR_1bit U31 (Soma[31], Cout, A[31], B[31], C30);
endmodule//Fim módulo que soma dois valores de 32 bits

module ALU (Controle, Dado1, Dado2, saida, zero);//Módulo da Unidade Lógica Aritmética
  input wire Controle, Dado1, Dado2;//Valores sujeitos à operação a ser feita e Controle que indica a instrução executada
  output reg saida;//Saída dos valores
  output wire zero;//Flag indicando se o resultado foi 0
  always @ ( * ) begin//Começo da operação a ser feita
  //Condições para verificar qual tipo de operação será feita na ALU
    saida = Dado1 + Dado2;
  end//Fim da operação
endmodule//Fim do módulo da ALU

//Fazer um módulo de controle para verificar as instruções a serem executadas

module CaminhoDeDados (PC,);

endmodule //
