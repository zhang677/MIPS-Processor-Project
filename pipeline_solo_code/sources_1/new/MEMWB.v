`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 18:42:07
// Design Name: 
// Module Name: MEMWB
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


module MEMWB(reset, clk, MEM_PC4, MEM_Write_register, MEM_Read_data, MEM_ALUout,
    MEM_MemRead, MEM_RegWrite, MEM_MemtoReg, MEM_PC,
    WB_PC4, WB_Write_register, WB_Read_data,
    WB_ALUout, WB_MemRead, WB_RegWrite, WB_MemtoReg,WB_PC);
input reset, clk, MEM_MemRead, MEM_RegWrite;
input [31:0] MEM_PC4, MEM_Read_data, MEM_ALUout;
input [4:0] MEM_Write_register;
input [1:0] MEM_MemtoReg;
input [31:0] MEM_PC;

(* DONT_TOUCH= "TRUE" *) output reg WB_MemRead, WB_RegWrite;
(* DONT_TOUCH= "TRUE" *) output reg [31:0] WB_Read_data;
(* DONT_TOUCH= "TRUE" *) output reg [31:0] WB_ALUout;
output reg [4:0] WB_Write_register;
(* DONT_TOUCH= "TRUE" *) output reg [1:0] WB_MemtoReg;
output reg [31:0] WB_PC4;
output reg [31:0] WB_PC;

always @(posedge reset or posedge clk)
    if (reset) begin
        WB_PC4<=32'b0; WB_Write_register<=5'b0; WB_Read_data<=32'b0;
        WB_ALUout<=32'b0; WB_MemRead<=0; WB_RegWrite<=0; WB_MemtoReg<=2'b0;
        WB_PC <= 32'b0;
    end
    else begin
        WB_PC4<=MEM_PC4; WB_Write_register<=MEM_Write_register;
        WB_Read_data<=MEM_Read_data; WB_ALUout<=MEM_ALUout; 
        WB_MemRead<=MEM_MemRead; WB_RegWrite<=MEM_RegWrite; WB_MemtoReg<=MEM_MemtoReg;
        WB_PC <= MEM_PC;
    end
endmodule
