`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/30 20:46:09
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 去掉了Zero和ALUOp=3`b001的情况
// Dependencies: 
// 对应Control.v中ALUOp不用检测比较命令beq,bne等
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(In1,In2,ALUOp,Funct,Result);
input [31:0] In1,In2;
input [3:0] ALUOp;
input [5:0] Funct;
output reg [31:0] Result;
wire Sign;
reg [4:0] ALUConf;
	parameter aluADD = 5'b00000;
	parameter aluOR  = 5'b00001;
	parameter aluAND = 5'b00010;
	parameter aluSUB = 5'b00110;
	parameter aluSLT = 5'b00111;
	parameter aluNOR = 5'b01100;
	parameter aluXOR = 5'b01101;
	parameter aluSRL = 5'b10000;
	parameter aluSRA = 5'b11000;
	parameter aluSLL = 5'b11001;

    assign Sign = (ALUOp[2:0] == 3'b010)? ~Funct[0]: ~ALUOp[3];

    wire [1:0] ss;
	assign ss = {In1[31], In2[31]};
	
	wire lt_31;
	assign lt_31 = (In1[30:0] < In2[30:0]);
	
	wire lt_signed;
	assign lt_signed = (In1[31] ^ In2[31])? 
		((ss == 2'b01)? 0: 1): lt_31;

    reg [4:0] aluFunct;
	always @(*)
		case (Funct)
			6'b00_0000: aluFunct <= aluSLL;
			6'b00_0010: aluFunct <= aluSRL;
			6'b00_0011: aluFunct <= aluSRA;
			6'b10_0000: aluFunct <= aluADD;
			6'b10_0001: aluFunct <= aluADD;
			6'b10_0010: aluFunct <= aluSUB;
			6'b10_0011: aluFunct <= aluSUB;
			6'b10_0100: aluFunct <= aluAND;
			6'b10_0101: aluFunct <= aluOR;
			6'b10_0110: aluFunct <= aluXOR;
			6'b10_0111: aluFunct <= aluNOR;
			6'b10_1010: aluFunct <= aluSLT;
			6'b10_1011: aluFunct <= aluSLT;
			default: aluFunct <= aluADD;
		endcase
	
	always @(*)
		case (ALUOp[2:0])
			3'b000: ALUConf <= aluADD; // lw sw lui j jal addi addiu
			3'b100: ALUConf <= aluAND; // andi
			3'b101: ALUConf <= aluSLT; // slti || sltiu
			3'b010: ALUConf <= aluFunct; // R-type
			default: ALUConf <= aluADD;
		endcase

    always @(*) begin
		case (ALUConf)
			5'b00000: Result <= In1 + In2;
			5'b00001: Result <= In1 | In2;
			5'b00010: Result <= In1 & In2;
			5'b00110: Result <= In1 - In2;
			5'b00111: Result <= {31'h00000000, Sign? lt_signed: (In1 < In2)};
			5'b01100: Result <= ~(In1 | In2);
			5'b01101: Result <= In1 ^ In2;
			5'b10000: Result <= (In2 >> In1[4:0]);
			5'b11000: Result <= ({{32{In2[31]}}, In2} >> In1[4:0]);
            5'b11001: Result <= (In2 << In1[4:0]);
			5'b11010: Result <= (In1 ^ In2) & In1;
			default: Result <= 32'h00000000;
		endcase
    end
endmodule
