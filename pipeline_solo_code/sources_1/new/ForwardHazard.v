`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 15:17:35
// Design Name: 
// Module Name: ForwardHazard
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


module ForwardHazard(ID_MemWrite,ID_RegDst,ID_Inst,EX_MemRead,EX_Rs,
    EX_Rt,MEM_RegWrite,MEM_MemWrite,MEM_Rt,MEM_Write_register,
    WB_RegWrite,WB_Write_register,WB_MemRead,
    ForwardA,ForwardB,Forward_lwsw,stall
    );
input ID_MemWrite,EX_MemRead,MEM_RegWrite,MEM_MemWrite,WB_RegWrite,WB_MemRead;
input [1:0] ID_RegDst;
input [4:0] EX_Rs,EX_Rt,MEM_Rt,MEM_Write_register,WB_Write_register;
input [31:0] ID_Inst;

output wire [1:0] ForwardA,ForwardB;
output wire Forward_lwsw,stall;

// six inputs not good!!!(Maybe)
assign ForwardA = (MEM_RegWrite && (MEM_Write_register!=5'd0) && (MEM_Write_register==EX_Rs))? 2'b10:
(WB_RegWrite && (WB_Write_register!=5'd0) && (WB_Write_register==EX_Rs) && (MEM_Write_register!=EX_Rs||~MEM_RegWrite))?2'b01:2'b00;
assign ForwardB = (MEM_RegWrite && (MEM_Write_register!=5'd0) && (MEM_Write_register==EX_Rt))? 2'b10:
(WB_RegWrite && (WB_Write_register!=5'd0) && (WB_Write_register==EX_Rt) && (MEM_Write_register!=EX_Rt||~MEM_RegWrite))?2'b01:2'b00;
assign stall = (~ID_MemWrite && EX_MemRead && (
((ID_RegDst==2'b00) && (ID_Inst[25:21] == EX_Rt))||
((ID_RegDst==2'b01) && (ID_Inst[25:21] == EX_Rt))||
((ID_RegDst==2'b01) && (ID_Inst[20:16] == EX_Rt))))?1'b1:1'b0;
assign Forward_lwsw = (WB_MemRead && MEM_MemWrite && MEM_Rt == WB_Write_register)? 1'b1:1'b0;
endmodule
