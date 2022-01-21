`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 08:56:20
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CPU(reset,sysclk,digi,LED,mem2uart,Tx_Serial,Rx_Serial);
input reset,sysclk,mem2uart,Rx_Serial;
output wire [11:0] digi;
output wire [11:0] LED;
output Tx_Serial;
//global
wire clk;
wire IRQ;
wire PC31;
wire stall;
//PCIFID
wire [31:0] JumpDst;
wire [31:0] BranchDst;
wire isBranch;
wire isJump;
wire [31:0] IF_PC;
wire [2:0] PCSrc;
wire [31:0] IF_Inst;
wire [31:0] ID_Inst;
//chain
wire [31:0] ID_Read_data1,EX_Read_data1;
wire [31:0] ID_Read_data2,EX_Read_data2;
wire [4:0] ID_Write_register,EX_Write_register,MEM_Write_register,WB_Write_register;
wire ID_ExtOp;
wire ID_LuiOp,EX_LuiOp;
wire ID_ALUSrc1,EX_ALUSrc1;
wire ID_ALUSrc2,EX_ALUSrc2;
wire [1:0] ID_RegDst;
wire ID_MemRead,EX_MemRead,MEM_MemRead,WB_MemRead;
wire ID_MemWrite,EX_MemWrite,MEM_MemWrite;
wire [1:0] ID_MemtoReg,EX_MemtoReg,MEM_MemtoReg,WB_MemtoReg;
wire [3:0] ID_ALUOp,EX_ALUOp;
wire [31:0] ID_PC4,EX_PC4,MEM_PC4,WB_PC4;
wire [4:0] EX_Rs;
wire [4:0] EX_Rt,MEM_Rt;
wire ID_RegWrite,EX_RegWrite,MEM_RegWrite,WB_RegWrite;
wire [31:0] MEM_Read_data,WB_Read_data;
wire [31:0] WB_Writeback_Data;
wire [31:0] EX_ALUout,MEM_ALUout,WB_ALUout;
wire [31:0] MUX0,MUX1,MUX2;
wire [31:0] ID_ImmExt,EX_ImmExt;
wire [1:0] ForwardA,ForwardB;
wire Forward_lwsw;
wire [31:0] ALUin1,ALUin2;
wire [31:0] MEM_MUX1,MEM_data;
wire blez,bne,bgtz,bltz,beq;
wire [31:0] MEM_PC,WB_PC;
wire [31:0] MEM_Address_MUX,MEM_data_MUX;
wire MEM_wren_MUX;
wire recv_done, send_done,wr_en0;
wire [31:0] o_addr0, wdata0;
wire [31:0] data35;

assign LED[0] = recv_done;

assign LED[1] = send_done;

assign LED[2] = reset;

assign LED[3] = Rx_Serial;

assign LED[11:4] = IF_PC[9:2];
//clk_gen clkgen(.reset(reset),.clk(sysclk),.clk_10(clk));
assign clk = sysclk;


assign WB_Writeback_Data=(WB_MemtoReg==2'b11)?WB_PC:
    (WB_MemtoReg==2'b00)?WB_Read_data:(WB_MemtoReg==2'b10)? WB_PC4: WB_ALUout;

assign BranchDst = isBranch ? (ID_PC4+{ID_ImmExt[29:0],2'b00}): ID_PC4;

assign JumpDst = (PCSrc == 3'b010 || PCSrc == 3'b001)? {ID_PC4[31:28],ID_ImmExt[25:0],2'b00}:
    (PCSrc == 3'b011)? {ID_Read_data1}: 32'd0;

assign ID_ImmExt = {(ID_ExtOp? {16{ID_Inst[15]}}: 16'h0000),ID_Inst[15:0] };

assign MUX0 = EX_ALUSrc1 ? {27'h00000, EX_ImmExt[10:6]}: EX_Read_data1; //shamt or $rs

assign MUX1 = (ForwardB==2'b00)?EX_Read_data2:(ForwardB==2'b10)?MEM_ALUout:WB_Writeback_Data;

assign MUX2 = EX_LuiOp ? {EX_ImmExt[15:0], 16'h0000}: EX_ImmExt; 

assign ID_Write_register = (ID_RegDst == 2'b11)? 5'd26:(ID_RegDst == 2'b00)? ID_Inst[20:16]:
    (ID_RegDst == 2'b10)? 5'd31:ID_Inst[15:11];

assign ALUin1 = (ForwardA==2'b10)?MEM_ALUout:(ForwardA==2'b01)?WB_Writeback_Data:MUX0;

assign ALUin2 = EX_ALUSrc2 ? MUX2 : MUX1;

assign MEM_data = Forward_lwsw ? WB_Writeback_Data : MEM_MUX1;

assign  isBranch = (beq || bltz || bgtz || bne || blez);

assign MEM_PC = MEM_PC4 - 32'd4;

assign MEM_Address_MUX = recv_done ? MEM_ALUout : o_addr0;

assign MEM_data_MUX = recv_done ?  MEM_data : wdata0;

assign MEM_wren_MUX = recv_done ? MEM_MemWrite : wr_en0;

PCIFID pcifid(.reset(reset),.clk(clk),.IRQ(IRQ),
.stall(stall),.JumpDst(JumpDst),.BranchDst(BranchDst),
.isBranch(isBranch),.isJump(isJump),.PC31(PC31),.PCSrc(PCSrc),
.IF_Inst(IF_Inst),.ID_Inst(ID_Inst),.ID_PC4(ID_PC4),.IF_PC(IF_PC),.recv_done(recv_done));

InstMemory instmem(.Address(IF_PC),.Inst(IF_Inst));

RegisterFile rf(.reset(reset),.clk(clk),.RegWrite(WB_RegWrite),.Read_register1(ID_Inst[25:21]),
    .Read_register2(ID_Inst[20:16]),.Write_register(WB_Write_register),.Write_data(WB_Writeback_Data),.Read_data1(ID_Read_data1),
    .Read_data2(ID_Read_data2));

Controller ctrl(.Funct(ID_Inst[5:0]),.OpCode(ID_Inst[31:26]),.ALUin1(ALUin1),.ALUin2(ALUin2),.PC31(PC31),.IRQ(IRQ),
    .isJump(isJump),.ExtOp(ID_ExtOp),.LuiOp(ID_LuiOp),
    .ALUSrc1(ID_ALUSrc1),.ALUSrc2(ID_ALUSrc2),.RegDst(ID_RegDst),.MemRead(ID_MemRead),.MemWrite(ID_MemWrite),
    .MemtoReg(ID_MemtoReg),.ALUOp(ID_ALUOp),.PCSrc(PCSrc),.RegWrite(ID_RegWrite),.ID_Inst(ID_Inst),
    .blez(blez),.bne(bne),.bgtz(bgtz),.bltz(bltz),.beq(beq));

ALU alu(.In1(ALUin1),.In2(ALUin2),.ALUOp(EX_ALUOp),.Funct(EX_ImmExt[5:0]),.Result(EX_ALUout));//funct就是指令的[5:0],因为立即数扩展时在高位,所以不改变低16位的值

DataMemory datamem(.reset(reset),.clk(clk),.Address(MEM_Address_MUX),.Write_data(MEM_data_MUX),.Read_data(MEM_Read_data),.MemRead(MEM_MemRead),.MemWrite(MEM_wren_MUX),.IRQ(IRQ),.digi(digi),.data35(data35));

ForwardHazard fh(.ID_MemWrite(ID_MemWrite),.ID_RegDst(ID_RegDst),.ID_Inst(ID_Inst),
.EX_MemRead(EX_MemRead),.EX_Rs(EX_Rs),.EX_Rt(EX_Rt),.MEM_RegWrite(MEM_RegWrite),.MEM_MemWrite(MEM_MemWrite),
.MEM_Rt(MEM_Rt),.MEM_Write_register(MEM_Write_register),
.WB_RegWrite(WB_RegWrite),.WB_Write_register(WB_Write_register),.WB_MemRead(WB_MemRead),
.ForwardA(ForwardA),.ForwardB(ForwardB),.Forward_lwsw(Forward_lwsw),.stall(stall));

IDEX idex(.reset(reset),.clk(clk),.stall(stall),.ID_Write_register(ID_Write_register), .ID_Rs(ID_Inst[25:21]), .ID_Rt(ID_Inst[20:16]), .ID_Read_data1(ID_Read_data1), .ID_Read_data2(ID_Read_data2),
    .ID_ImmExt(ID_ImmExt), .ID_PC4(ID_PC4), .ID_MemtoReg(ID_MemtoReg), .ID_ALUOp(ID_ALUOp),.ID_LuiOp(ID_LuiOp), .ID_MemRead(ID_MemRead), .ID_MemWrite(ID_MemWrite),
    .ID_ALUSrc1(ID_ALUSrc1), .ID_ALUSrc2(ID_ALUSrc2), .ID_RegWrite(ID_RegWrite),
    .EX_Write_register(EX_Write_register), .EX_Rs(EX_Rs), .EX_Rt(EX_Rt), .EX_Read_data1(EX_Read_data1), .EX_Read_data2(EX_Read_data2),
    .EX_ImmExt(EX_ImmExt), .EX_PC4(EX_PC4), .EX_MemtoReg(EX_MemtoReg), .EX_ALUOp(EX_ALUOp),.EX_LuiOp(EX_LuiOp), .EX_MemRead(EX_MemRead), .EX_MemWrite(EX_MemWrite),
    .EX_ALUSrc1(EX_ALUSrc1), .EX_ALUSrc2(EX_ALUSrc2), .EX_RegWrite(EX_RegWrite));

EXMEM exmem(.reset(reset), .clk(clk), .EX_Rt(EX_Rt), .EX_PC4(EX_PC4), .EX_ALUout(EX_ALUout), .MUX1(MUX1),
    .EX_Write_register(EX_Write_register), .EX_MemRead(EX_MemRead), .EX_MemWrite(EX_MemWrite), .EX_MemtoReg(EX_MemtoReg), .EX_RegWrite(EX_RegWrite),
    .MEM_Rt(MEM_Rt), .MEM_PC4(MEM_PC4), .MEM_MUX1(MEM_MUX1), .MEM_Write_register(MEM_Write_register), .MEM_ALUout(MEM_ALUout),
    .MEM_MemRead(MEM_MemRead), .MEM_MemWrite(MEM_MemWrite), .MEM_RegWrite(MEM_RegWrite),.MEM_MemtoReg(MEM_MemtoReg));

MEMWB memwb(.reset(reset), .clk(clk), .MEM_PC4(MEM_PC4), .MEM_Write_register(MEM_Write_register), .MEM_Read_data(MEM_Read_data), .MEM_ALUout(MEM_ALUout),
    .MEM_MemRead(MEM_MemRead), .MEM_RegWrite(MEM_RegWrite), .MEM_MemtoReg(MEM_MemtoReg),.MEM_PC(MEM_PC),
    .WB_PC4(WB_PC4), .WB_Write_register(WB_Write_register), .WB_Read_data(WB_Read_data),
    .WB_ALUout(WB_ALUout), .WB_MemRead(WB_MemRead), .WB_RegWrite(WB_RegWrite), .WB_MemtoReg(WB_MemtoReg),.WB_PC(WB_PC));

UART_MEM uart_mem(.clk(clk),.rst(reset),.mem2uart(mem2uart),.recv_done(recv_done),
.send_done(send_done),.o_addr0(o_addr0),.wr_en0(wr_en0),.rdata0(data35),.wdata0(wdata0),
.Rx_Serial(Rx_Serial),.Tx_Serial(Tx_Serial));

endmodule
