`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/01 10:46:58
// Design Name: 
// Module Name: PCIFID
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// PC and IF/ID 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PCIFID(reset,clk,IRQ,stall,JumpDst,BranchDst,isBranch,isJump,PC31,PCSrc,IF_Inst,ID_Inst,ID_PC4,IF_PC,ID_Inst_Addr,recv_done);
input reset,clk,IRQ,stall,isBranch,isJump,recv_done;
input [31:0] JumpDst,BranchDst,IF_Inst;
input [2:0] PCSrc;


(* DONT_TOUCH= "TRUE" *) output reg [31:0] ID_Inst;
(* DONT_TOUCH= "TRUE" *) output reg [31:0] ID_PC4;
(* DONT_TOUCH= "TRUE" *) output wire [31:0] IF_PC;
(* DONT_TOUCH= "TRUE" *) output wire PC31;
(* DONT_TOUCH= "TRUE" *) output reg [7:0] ID_Inst_Addr;

wire [7:0] IF_Inst_Addr;
reg flag;
reg [31:0] PC;
wire [31:0] PC_4;
wire firstBranch;
assign PC_4 = PC + 32'd4;
assign PC31 = PC[31];
assign IF_PC = PC;
assign firstBranch = (IF_Inst[31:26]==6'h01 || IF_Inst[31:26]==6'h04 || IF_Inst[31:26]==6'h05
       ||IF_Inst[31:26]==6'h06 ||IF_Inst[31:26]==6'h07);   
assign IF_Inst_Addr = IF_PC[9:2];

/*
always @(posedge reset or posedge clk or posedge recv_done) begin
    if(reset || ~recv_done) begin
        ID_Inst_Addr <= 8'd0;
        ID_Inst <= {6'h02,26'd3};
        ID_PC4 <= 32'h00000008;
        PC <= 32'h00000004;
        flag <= 1'b0;
    end
    else if (PCSrc == 3'b000) begin
        ID_Inst_Addr <= IF_Inst_Addr;
        ID_Inst <= IF_Inst;
        ID_PC4 <= PC_4;
        PC <= 32'h80000008; // Exception
        flag <= 1'b0;
    end
    else if (PCSrc == 3'b001) begin
        ID_Inst_Addr <= IF_Inst_Addr;
        ID_Inst <= IF_Inst;
        ID_PC4 <= PC_4;
        PC <= 32'h80000004;
        flag <= 1'b0; // Interrupt 
    end
    else if (stall)
        flag <= 1'b0;
    else if (~flag && firstBranch) begin // 在IF阶段判断遇到beq 再做一次beq（PC不更新）
        ID_Inst_Addr <= IF_Inst_Addr;
        ID_Inst <= IF_Inst;
        ID_PC4 <= PC_4;
        flag <= 1'b1;   
    end
    else if (~flag && isBranch) begin // 第二个beq 之后必须stall 一个周期
        ID_Inst_Addr <= 32'd0;
        ID_Inst <= 32'b0;
        ID_PC4 <= 32'b0;
        PC[30:0] <= BranchDst[30:0];
        flag <= 1'b0;
    end
    else if (isJump) begin
        flag <= 1'b0;
	  	if(PC == 32'h80000004 && IRQ) begin
            if(PCSrc == 3'b011) PC[31] <= 1'b0;
            ID_Inst_Addr <= IF_Inst_Addr; 
            ID_Inst <= IF_Inst; // 因为如果jump下一条是interrupt则不能stall，否则会错过j interrupt指令
            ID_PC4 <= PC_4;
            PC[30:0]<= JumpDst[30:0];
		end
        else begin
            if (PCSrc == 3'b011) PC[31] <= 1'b0; // 因为jalr,jr更改PC31
            
            ID_Inst_Addr <= 32'b0;
            ID_Inst <= 32'b0;
            ID_PC4 <= PC_4; // 因为jal,jalr在WB阶段要用到PC+4的值，所以需要传下去
            PC[30:0] <= JumpDst[30:0];
        end
    end
    else begin
        ID_Inst_Addr <= IF_Inst_Addr;
        ID_Inst <= IF_Inst; // 正常
        ID_PC4 <= PC_4;
        PC[30:0] <= PC_4[30:0];
        if(PC_4[9:2]==8'd143) begin
            PC[31] <= 1'b0;
        end
        else begin
            PC[31] <= PC_4[31];
        end
        flag <= 1'b0;
    end
end
*/

wire [6:0] PC_Ctrl;
assign PC_Ctrl = {PCSrc,stall,flag,firstBranch,isBranch};

//assign isJump = ((PCSrc == 3'b010)||(PCSrc == 3'b011)) ? 1'b1 : 1'b0;

always @(posedge reset or posedge clk or posedge recv_done) begin
    if(reset || ~recv_done) begin
        ID_Inst_Addr <= 8'd0;
        ID_Inst <= {6'h02,26'd3};
        ID_PC4 <= 32'h00000008;
        PC <= 32'h00000004;
        flag <= 1'b0;
    end
    else begin
    case (PC_Ctrl)
        7'b0100000 : begin
            flag <= 1'b0;
            if(PC == 32'h80000004 && IRQ) begin
                ID_Inst_Addr <= IF_Inst_Addr; 
                ID_Inst <= IF_Inst; // 因为如果jump下一条是interrupt则不能stall
                ID_PC4 <= PC_4;
                PC <= {PC[31], JumpDst[30:0]};
            end
            else 
            begin
                ID_Inst_Addr <= 32'b0;
                ID_Inst <= 32'b0;
                ID_PC4 <= PC_4; // 因为jal,jalr在WB阶段要用到PC+4的值，所以需要传下去
                PC <= {PC[31], JumpDst[30:0]};
            end
        end
        7'b0110000 : begin
            flag <= 1'b0;
            if(PC == 32'h80000004 && IRQ) begin
                ID_Inst <= IF_Inst; // 因为如果jump下一条是interrupt则不能stall
                ID_PC4 <= PC_4;
                PC <= {1'b0,JumpDst[30:0]};
            end
            else 
            begin
                ID_Inst <= 32'b0;
                ID_PC4 <= PC_4; // 因为jal,jalr在WB阶段要用到PC+4的值，所以需要传下去
                PC <= {1'b0,JumpDst[30:0]};
            end
        end
        7'b0000000 : begin
            ID_Inst_Addr <= IF_Inst_Addr;
            ID_Inst <= IF_Inst;
            ID_PC4 <= PC_4;
            PC <= 32'h80000008; // Exception
            flag <= 1'b0;            
        end
        7'b0010000 : begin
            ID_Inst_Addr <= IF_Inst_Addr;
            ID_Inst <= IF_Inst;
            ID_PC4 <= PC_4;
            PC <= 32'h80000004;
            flag <= 1'b0; // Interrupt 
        end

        7'b1001010 : begin
            flag <= 1'b0;
        end
        7'b1001000 : begin
            flag <= 1'b0;
        end
        7'b1000010 : begin
            ID_Inst_Addr <= IF_Inst_Addr;
            ID_Inst <= IF_Inst;
            ID_PC4 <= PC_4;
            flag <= 1'b1; 
        end
        7'b1000001 : begin
            ID_Inst_Addr <= 32'd0;
            ID_Inst <= 32'b0;
            ID_PC4 <= 32'b0;
            PC <= {PC[31],BranchDst[30:0]};
            flag <= 1'b0;
        end
        default : begin
            ID_Inst_Addr <= IF_Inst_Addr;
            ID_Inst <= IF_Inst; // 正常
            ID_PC4 <= PC_4;
            PC[30:0] <= PC_4[30:0];
            if(PC_4[9:2]==8'd143) begin
                PC <= {1'b0,PC_4[30:0]};
            end
            else begin
                PC <= PC_4;
            end
            flag <= 1'b0;
    end
    endcase
    end
end

/*
wire [6:0] PC_Ctrl;
assign PC_Ctrl = {PCSrc,stall,flag,firstBranch,isBranch};

//assign isJump = ((PCSrc == 3'b010)||(PCSrc == 3'b011)) ? 1'b1 : 1'b0;

always @(posedge reset or posedge clk or posedge recv_done) begin
    if(reset || recv_done) begin
        ID_Inst <= {6'h02,26'd3};
        ID_PC4 <= 32'h00000008;
        PC <= 32'h00000004;
        flag <= 1'b0;
    end
    else begin
    case (PC_Ctrl)
        7'b000???? : begin
            ID_Inst <= IF_Inst;
            ID_PC4 <= PC_4;
            PC <= 32'h80000008; // Exception
            flag <= 1'b0;            
        end
        7'b001???? : begin
            ID_Inst <= IF_Inst;
            ID_PC4 <= PC_4;
            PC <= 32'h80000004;
            flag <= 1'b0; // Interrupt 
        end
        7'b010???? :
        7'b011???? : begin
            flag <= 1'b0;
            if(PC == 32'h80000004 && IRQ) begin
                ID_Inst <= IF_Inst; // 因为如果jump下一条是interrupt则不能stall
                ID_PC4 <= PC_4;
                if(PCSrc == 3'b011) begin
                    PC <= {1'b0,JumpDst[30:0]};
                end 
                else begin
                    PC <= {PC[31], JumpDst[30:0]};
                end
            end
            else 
            begin
                ID_Inst <= 32'b0;
                ID_PC4 <= PC_4; // 因为jal,jalr在WB阶段要用到PC+4的值，所以需要传下去
                if (PCSrc == 3'b011) begin
                    PC <= {1'b0,JumpDst[30:0]}; // 因为jalr,jr更改PC31
                end
                else begin
                    PC <= {PC[31], JumpDst[30:0]};
                end
            end
        end
        7'b1001??? : begin
            flag <= 1'b0;
        end
        7'b100001? : begin
            ID_Inst <= IF_Inst;
            ID_PC4 <= PC_4;
            flag <= 1'b1; 
        end
        7'b1000001 : begin
            ID_Inst <= 32'b0;
            ID_PC4 <= 32'b0;
            PC <= {PC[31],BranchDst[30:0]};
            flag <= 1'b0;
        end
    endcase
    end
end
*/
endmodule
