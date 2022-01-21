`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 09:26:12
// Design Name: 
// Module Name: Controller
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


module Controller(
Funct,OpCode,ALUin1,ALUin2,PC31,IRQ,isJump,ExtOp,LuiOp,ALUSrc1,ALUSrc2,RegDst,
MemRead,MemWrite,MemtoReg,ALUOp,PCSrc,RegWrite,ID_Inst,blez,bne,bgtz,bltz,beq);
input [5:0] Funct;
input [5:0] OpCode;
input [31:0] ALUin1,ALUin2,ID_Inst;
input PC31,IRQ;
output wire isJump,ExtOp,LuiOp,ALUSrc1,ALUSrc2,MemRead,MemWrite,RegWrite;
//output wire isBranch;
output wire [1:0] RegDst,MemtoReg;
output wire [2:0] PCSrc;
output wire [3:0] ALUOp;

output wire blez,bne,bgtz,bltz,beq;
wire exception; // 只检查命令，不检查溢出；


assign blez = (OpCode == 6'h06 && (ALUin1[31]||ALUin1==32'b0)) ? 1'b1: 1'b0;
assign bne = (OpCode == 6'h05 &&  (ALUin1 != ALUin2)) ? 1'b1: 1'b0;
assign bgtz = (OpCode == 6'h07 && ~ALUin1[31] && ALUin1!=32'b0) ? 1'b1: 1'b0;
assign bltz = (OpCode == 6'h01 && ALUin1[31]) ? 1'b1: 1'b0;
assign beq = (OpCode == 6'h04 &&  (ALUin1 == ALUin2)) ?1'b1: 1'b0;
//assign isBranch = (beq || bltz || bgtz || bne || blez);

assign exception = ~(
        (OpCode==6'h0f)||(OpCode==6'h23)||(OpCode==6'h2b)
        ||((OpCode>=6'h01)&&(OpCode<=6'h0c))
		||((OpCode==6'h00)&&(Funct==6'h00||Funct==6'h02||Funct==6'h03||Funct==6'h2a||
		Funct==6'h2b||Funct==6'h08||Funct==6'h09||((Funct>=6'h20)&&(Funct<=6'h27))))
        );
assign ExtOp = (OpCode == 6'h0c) ? 1'b0: 1'b1;
assign LuiOp = (OpCode == 6'h0f) ? 1'b1: 1'b0;
assign ALUSrc1 = (OpCode == 6'h00 && (Funct == 6'd00||Funct == 6'd02||Funct == 6'h03))?1'b1:1'b0;
assign ALUSrc2 = (OpCode == 6'h23||OpCode == 6'h2b||OpCode == 6'h0f||OpCode == 6'h08
        ||OpCode == 6'h09||OpCode == 6'h0c||OpCode == 6'h0a||OpCode == 6'h0b)?1'b1:1'b0;
assign MemRead = (OpCode == 6'h23)? 1'b1:1'b0; 
assign MemWrite = (OpCode == 6'h2b)? 1'b1:1'b0;
assign RegDst = (~PC31 && IRQ)? 2'b11:(OpCode==6'h23||OpCode==6'h0f
        ||OpCode==6'h08||OpCode==6'h09||OpCode==6'h0c||OpCode==6'h0a||OpCode==6'h0b)?2'b00:
        (OpCode==6'h03||(OpCode==6'h00&&Funct==6'h09))?2'b10:2'b01;      
assign MemtoReg = (~PC31 && IRQ)? 2'b11:(OpCode==6'h23)?2'b00:
        (OpCode==6'h03||(OpCode==6'h00&&Funct==6'h09))?2'b10:2'b01;
assign ALUOp[3] = OpCode[0];
assign ALUOp[2:0] = 
    (OpCode == 6'h00)? 3'b010: 
    (OpCode == 6'h0c)? 3'b100: 
    (OpCode == 6'h0a || OpCode == 6'h0b)? 3'b101: 3'b000;
assign PCSrc = exception?3'b000:(~PC31 && IRQ)?3'b001:(OpCode==6'h02||OpCode==6'h03)?3'b010:
       (OpCode==6'h00&&(Funct==6'h08||Funct==6'h09))?3'b011:3'b100;
assign isJump = ((PCSrc == 3'b010)||(PCSrc == 3'b011)) ? 1'b1 : 1'b0;
assign RegWrite =
    ((OpCode==6'h2b||OpCode==6'h04||OpCode==6'h05||OpCode==6'h06||OpCode==6'h07||OpCode==6'h01||OpCode==6'h02||
    ((OpCode==6'h00)&&(Funct==6'h08))||(ID_Inst==32'h00000000)) && ~(~PC31 && IRQ))?1'b0:1'b1;
endmodule
