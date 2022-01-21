`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 17:59:27
// Design Name: 
// Module Name: IDEX
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


module IDEX(reset,clk,stall,ID_Write_register, ID_Rs, ID_Rt, ID_Read_data1, ID_Read_data2,
    ID_ImmExt, ID_PC4, ID_MemtoReg, ID_ALUOp,ID_LuiOp, ID_MemRead, ID_MemWrite,
    ID_ALUSrc1, ID_ALUSrc2, ID_RegWrite,
    EX_Write_register, EX_Rs, EX_Rt, EX_Read_data1, EX_Read_data2,
    EX_ImmExt, EX_PC4, EX_MemtoReg, EX_ALUOp,EX_LuiOp, EX_MemRead, EX_MemWrite,
    EX_ALUSrc1, EX_ALUSrc2, EX_RegWrite,ID_Inst_Addr,EX_Inst_Addr);

input reset, clk, stall;
input [4:0] ID_Write_register, ID_Rs, ID_Rt;
input [31:0] ID_Read_data1, ID_Read_data2, ID_ImmExt, ID_PC4;
input [1:0] ID_MemtoReg;
input [3:0] ID_ALUOp;
input ID_LuiOp, ID_MemRead, ID_MemWrite, ID_ALUSrc1, ID_ALUSrc2, ID_RegWrite;
input [7:0] ID_Inst_Addr;

(* DONT_TOUCH= "TRUE" *) output reg [4:0] EX_Write_register, EX_Rs, EX_Rt;
(* DONT_TOUCH= "TRUE" *) output reg [31:0] EX_Read_data1, EX_Read_data2, EX_ImmExt, EX_PC4;
(* DONT_TOUCH= "TRUE" *) output reg [1:0] EX_MemtoReg;
(* DONT_TOUCH= "TRUE" *) output reg [3:0] EX_ALUOp;
(* DONT_TOUCH= "TRUE" *) output reg EX_LuiOp, EX_MemRead, EX_MemWrite, EX_ALUSrc1, EX_ALUSrc2, EX_RegWrite;
(* DONT_TOUCH= "TRUE" *) output reg [7:0] EX_Inst_Addr;
always @(posedge reset or posedge clk) begin
    if(reset) begin
        EX_Write_register<=5'b0; EX_Rs<=5'b0; EX_Rt<=5'b0; EX_Read_data1<=32'b0; EX_Read_data2<=32'b0;
        EX_ImmExt<=32'b0; EX_PC4<=32'b0; EX_MemtoReg<=2'b0; EX_ALUOp<=4'b0; 
        EX_LuiOp<=0; EX_MemRead<=0; EX_MemWrite<=0; EX_ALUSrc1<=0; EX_ALUSrc2<=0; EX_RegWrite<=0;
        EX_Inst_Addr<=8'd0;
    end		      
    else if(stall) begin //阻塞时所有EX置为0
        EX_Write_register<=5'b0; EX_Rs<=5'b0; EX_Rt<=5'b0; EX_Read_data1<=32'b0; EX_Read_data2<=32'b0;
        EX_ImmExt<=32'b0; EX_PC4<=32'b0; EX_MemtoReg<=2'b0; EX_ALUOp<=4'b0; 
        EX_LuiOp<=0; EX_MemRead<=0; EX_MemWrite<=0; EX_ALUSrc1<=0; EX_ALUSrc2<=0; EX_RegWrite<=0;
        EX_Inst_Addr <= 8'd0;    
    end
    else begin
        EX_Write_register<=ID_Write_register; EX_Rs<=ID_Rs; EX_Rt<=ID_Rt; EX_Read_data1<=ID_Read_data1; EX_Read_data2<=ID_Read_data2;
        EX_ImmExt<=ID_ImmExt; EX_PC4<=ID_PC4; EX_MemtoReg<=ID_MemtoReg;
        EX_ALUOp<=ID_ALUOp; EX_LuiOp<=ID_LuiOp; 
        EX_MemRead<=ID_MemRead; EX_MemWrite<=ID_MemWrite; 
        EX_ALUSrc1<=ID_ALUSrc1; EX_ALUSrc2<=ID_ALUSrc2; EX_RegWrite<=ID_RegWrite;
        EX_Inst_Addr <= ID_Inst_Addr;
    end
end

endmodule
