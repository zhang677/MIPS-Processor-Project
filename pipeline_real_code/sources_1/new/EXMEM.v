`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 18:29:07
// Design Name: 
// Module Name: EXMEM
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


module EXMEM(reset, clk, EX_Rt, EX_PC4, EX_ALUout, MUX1,
    EX_Write_register, EX_MemRead, EX_MemWrite, EX_MemtoReg, EX_RegWrite,
    MEM_Rt, MEM_PC4, MEM_MUX1, MEM_Write_register, MEM_ALUout,
    MEM_MemRead, MEM_MemWrite, MEM_RegWrite, MEM_MemtoReg);

input reset, clk, EX_MemRead, EX_MemWrite, EX_RegWrite;
input [1:0] EX_MemtoReg;
input [31:0] EX_PC4, EX_ALUout, MUX1;
input [4:0] EX_Rt, EX_Write_register;


(* DONT_TOUCH= "TRUE" *) output reg MEM_MemRead, MEM_MemWrite, MEM_RegWrite;
(* DONT_TOUCH= "TRUE" *) output reg [1:0] MEM_MemtoReg;
(* DONT_TOUCH= "TRUE" *) output reg [4:0] MEM_Rt, MEM_Write_register;
(* DONT_TOUCH= "TRUE" *) output reg [31:0] MEM_MUX1;
(* DONT_TOUCH= "TRUE" *) output reg [31:0] MEM_ALUout;
output reg [31:0]  MEM_PC4;

always @(posedge reset or posedge clk) begin
    if (reset) begin
        MEM_Rt<=5'b0; MEM_PC4<=32'b0; MEM_MUX1<=32'b0;
        MEM_Write_register<=5'b0; MEM_ALUout<=32'b0;
        MEM_MemRead<=0; MEM_MemWrite<=0; MEM_RegWrite<=0; 
        MEM_MemtoReg<=2'b0;
    end
    else begin
        MEM_Rt<=EX_Rt; MEM_PC4<=EX_PC4; MEM_MUX1<=MUX1;
        MEM_Write_register<=EX_Write_register; MEM_ALUout<=EX_ALUout;
        MEM_MemRead<=EX_MemRead; MEM_MemWrite<=EX_MemWrite; MEM_RegWrite<=EX_RegWrite; 
        MEM_MemtoReg<=EX_MemtoReg; 
    end
end
endmodule
