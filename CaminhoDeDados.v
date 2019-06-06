module MUX1 (A,B,Sel,Out);//Módulo MUX
  input wire [4:0] A, B; //four 32-bit inputs
  input wire Sel; //selector signal
  output reg [4:0] Out;// 32-bit output
  always @(A, B, Sel) begin
    case (Sel) //a 2->1 multiplexor
      0: Out <= A;
      1: Out <= B;
    endcase
  end
endmodule//Fim módulo MUX

module MUX2 (A,B,Sel,Out);//Módulo MUX
  input wire [31:0] A, B; //four 32-bit inputs
  input wire Sel; //selector signal
  output reg [31:0] Out;// 32-bit output
  always @(A, B, Sel) begin
    case (Sel) //a 2->1 multiplexor
      0: Out <= A;
      1: Out <= B;
    endcase
  end
endmodule//Fim módulo MUX

module ShiftLeft2 (ValSignExtend, Result);
  input wire [31:0]ValSignExtend;
  output reg [31:0]Result;
  always @ (*) begin
    Result <= (ValSignExtend << 2);
  end
endmodule

module SignExtend(ImdEnd, ValSignExtend, clock);
  input wire [15:0]ImdEnd;
  input wire clock;
  output reg [31:0]ValSignExtend;
  always @ (posedge clock) begin
    ValSignExtend[15:0] <= ImdEnd;
    if(ImdEnd[15] == 1) begin
      ValSignExtend[31:16] <= 15'b111111111111111;
    end
    else if(ImdEnd[15] == 0) begin
      ValSignExtend[31:16] <= 15'b000000000000000;
    end
  end
endmodule
//Fazer um módulo de controle para verificar as instruções a serem executadas
module Control (OpCode, clock, RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp);
  input wire [5:0]OpCode;
  input wire clock;
  output reg RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
  output reg [1:0]ALUOp;
  always @ (posedge clock) begin
    if(OpCode == 6'b000000) begin
      RegDst <= 1;
      Branch <= 0;
      MemRead <= 0;
      MemtoReg <= 0;
      ALUOp <= 2'b10;
      MemWrite <= 0;
      ALUSrc <= 0;
      RegWrite <= 1;
    end
    else if(OpCode == 6'b100011) begin
      RegDst <= 0;
      Branch <= 0;
      MemRead <= 1;
      MemtoReg <= 1;
      ALUOp <= 2'b00;
      MemWrite <= 0;
      ALUSrc <= 1;
      RegWrite <= 1;
    end
    else if(OpCode == 6'b101011) begin
      RegDst <= x;
      Branch <= 0;
      MemRead <= 0;
      MemtoReg <= x;
      ALUOp <= 2'b00;
      MemWrite <= 1;
      ALUSrc <= 1;
      RegWrite <= 0;
    end
    else if(OpCode == 6'b000100) begin
      RegDst <= x;
      Branch <= 1;
      MemRead <= 0;
      MemtoReg <= x;
      ALUOp <= 2'b01;
      MemWrite <= 0;
      ALUSrc <= 0;
      RegWrite <= 0;
    end
  end
endmodule

module ALUControl (ALUOp, Funct, clock, ALUCtrl);
  input wire [1:0]ALUOp;
  input wire [5:0]Funct;
  input wire clock;
  output reg [3:0]ALUCtrl;
  always @ (posedge clock) begin
    if(ALUOp == 2'b00 && Funct == 6'bxxxxxx) begin
      ALUCtrl <= 4'b0010;
    end
    else if(ALUOp == 2'b01 && Funct == 6'bxxxxxx) begin
      ALUCtrl <= 4'b0110;
    end
    else if(ALUOp == 2'b10 && Funct == 6'b100000) begin
      ALUCtrl <= 4'b0010;
    end
    else if(ALUOp == 2'b10 && Funct == 6'b100010) begin
      ALUCtrl <= 4'b0110;
    end
    else if(ALUOp == 2'b10 && Funct == 6'b100100) begin
      ALUCtrl <= 4'b0000;
    end
    else if(ALUOp == 2'b10 && Funct == 6'b100101) begin
      ALUCtrl <= 4'b0001;
    end
    else if(ALUOp == 2'b10 && Funct == 6'b101010) begin
      ALUCtrl <= 4'b0111;
    end
    else if(ALUOp == 2'b10 && Funct == 6'b100111) begin
      ALUCtrl <= 4'b1100;
    end
  end
endmodule

module ALU (ALUControl, ReadData1, ReadData2, ALUResult, Zero, clock);//Módulo da Unidade Lógica Aritmética
  input wire [3:0]ALUControl;
  input wire clock;
  input wire [31:0]ReadData1, ReadData2;//Valores sujeitos à operação a ser feita e Controle que indica a instrução executada
  output reg [31:0]ALUResult;//Saída dos valores
  output reg Zero;//Flag indicando se o resultado foi 0
  always @ (posedge clock) begin//Começo da operação a ser feita
  //Condições para verificar qual tipo de operação será feita na ALU
    if(ALUControl == 4'b0010) begin
      ALUResult <= ReadData1 + ReadData2;
    end
    else if(ALUControl == 4'b0110) begin
      ALUResult <= ReadData1 - ReadData2;
    end
    else if(ALUControl == 4'b0000) begin
      ALUResult <= ReadData1 & ReadData2;
    end
    else if(ALUControl == 4'b0001) begin
      ALUResult <= ReadData1 | ReadData2;
    end
    else if(ALUControl == 4'b1100) begin
      ALUResult <= ~(ReadData1 | ReadData2);
    end
    else begin
      ALUResult <= ReadData1 < ReadData2;
    end
    if(ALUResult == 0) begin
      Zero <= 1;
    end
    else begin
      Zero <= 0;
    end
  end//Fim da operação
endmodule//Fim do módulo da ALU

module RegisterFile (Read1, Read2, WriteReg, WriteData, RegWrite, Data1, Data2, clock);
  input wire [4:0] Read1, Read2, WriteReg; // the register numbers to read or write
  input wire [31:0] WriteData; // data to write
  input wire RegWrite, clock;// the write control // the clock to trigger write
  output reg [31:0] Data1, Data2; // the register values read
  reg [31:0] RF [31:0]; // 32 registers each 32 bits long
  always @ (posedge clock) begin // write the register with new value if Regwrite is high
    Data1 <= RF[Read1];
    Data2 <= RF[Read2];
    if (RegWrite) begin
     RF[WriteReg] <= WriteData;
    end
  end
endmodule

module DataMemory (MemWrite, MemRead, Address, WriteData, clock, Result);
  input wire MemWrite, MemRead, clock;
  input wire [31:0] WriteData, Address;
  output reg [31:0]Result;
  reg [31:0] DM [31:0];
  reg [31:0] ReadData;
  always @ (posedge clock) begin // write the register with new value if Regwrite is high
    if (MemWrite) begin
      DM[Address] <= WriteData;
    end
    else if(MemRead) begin
      ReadData <= DM[Address];
    end
  end
endmodule

module InstructionMemory (ReadAddress, Instruction, clock);
  input wire [31:0]ReadAddress;
  input wire clock;
  output reg [31:0]Instruction;
  always @ (posedge clock) begin
    case (ReadAddress)
      0: Instruction <= 0;//Receber uma instrução;
      4: Instruction <= 0;//Receber uma instrução;
      8: Instruction <= 0;//Receber uma instrução;
      12: Instruction <= 0;//Receber uma instrução;
      16: Instruction <= 0;//Receber uma instrução;
      24: Instruction <= 0;//Receber uma instrução;
      20: Instruction <= 0;//Receber uma instrução;
      28: Instruction <= 0;//Receber uma instrução;
      32: Instruction <= 0;//Receber uma instrução;
    endcase
  end
endmodule

module PC (PC);
  output reg [31:0]PC;
  always @ (*) begin
    PC <= 32'b00000000000000000000000000000000;
    PC <= PC + 32'b00000000000000000000000000000100;
  end
endmodule

module ResultPC (A, B, Sum);
  input wire [31:0] A, B;
  output reg [31:0] Sum;
  always @ (*) begin
    Sum <= A + B;
  end
endmodule

module CaminhoDeDados (clock);
  input wire clock;
  wire [31:0]PC, ResultPC;
  wire [31:0]Instruction, ValSignExtend, Data1, Data2, DataAux, WriteData, ALUResult, ShiftValue, ReadData;
  wire [4:0]WriteReg;
  wire [3:0]ALUCtrl;
  wire Cout, RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Zero, ANDBranch;
  wire [1:0]ALUOp;
  InstructionMemory CatchIns (PC, Instruction, clock);
  PC CatchPC (PC);
  Control CatchVal (Instruction[31:26], clock, RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp);
  SignExtend CatchImdEnd (Instruction[15:0], ValSignExtend, clock);
  ALUControl CatchOp (ALUOp, Instruction[5:0], clock, ALUCtrl);
  MUX1 u1 (Instruction[20:16], Instruction[15:11], RegDst, WriteReg);
  RegisterFile Reg (Instruction[25:21], Instruction[20:16], WriteReg, WriteData, RegWrite, Data1, Data2, clock);
  MUX2 u2 (Data2, ValSignExtend, ALUSrc, DataAux);
  ALU CatchResult (ALUCtrl, Data1, DataAux, ALUResult, Zero, clock);
  ShiftLeft2 CatchBranch (ValSignExtend, ShiftValue);
  and CatchBranch1 (Branch, Zero, ANDBranch);
  ResultPC CatchPC2 (PC, ShiftValue, ResultPC);
  MUX2 u3 (PC, ResultPC, ANDBranch, PC);
  DataMemory CatchDat (MemWrite, MemRead, ALUResult, Data2, clock, ReadData);
  MUX2 u4 (ALUResult, ReadData, MemtoReg, WriteData);
endmodule //
