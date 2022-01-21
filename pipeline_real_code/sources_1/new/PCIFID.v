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


module PCIFID(reset,clk,IRQ,stall,JumpDst,BranchDst,isBranch,isJump,PC31,PCSrc,IF_Inst,ID_Inst,ID_PC4,IF_PC,recv_done);
input reset,clk,IRQ,stall,isBranch,isJump,recv_done;
input [31:0] JumpDst,BranchDst,IF_Inst;
input [2:0] PCSrc;


(* DONT_TOUCH= "TRUE" *) output reg [31:0] ID_Inst;
 output reg [31:0] ID_PC4;
 output wire [31:0] IF_PC;
 output wire PC31;


wire [7:0] IF_Inst_Addr;
reg flag;
reg [31:0] PC;
wire [31:0] PC_4;
//wire [2:0] PC_Ctrl;
wire firstBranch;

assign PC_4 = {PC[31:10], PC[9:2] + 8'd1,PC[1:0]};
assign PC31 = PC[31];
assign IF_PC = PC;
assign firstBranch = (IF_Inst[31:26]==6'h01 || IF_Inst[31:26]==6'h04 || IF_Inst[31:26]==6'h05
       ||IF_Inst[31:26]==6'h06 ||IF_Inst[31:26]==6'h07);   


/*
wire [7:0] PC_Ctrl;
assign PC_Ctrl = {PCSrc,stall,flag,firstBranch,isBranch,isJump};

always @(posedge reset or posedge clk or posedge recv_done) begin
    if(reset || ~recv_done) begin
        ID_Inst <= {6'h02,26'd3};
        ID_PC4 <= 32'h00000008;
        PC <= 32'h00000004;
        flag <= 1'b0;
    end
    else begin
    case (PC_Ctrl)
        8'b000????? : begin
            ID_Inst <= IF_Inst;
            ID_PC4 <= PC_4;
            PC <= 32'h80000008; // Exception
            flag <= 1'b0;            
        end
        8'b001????? : begin
            ID_Inst <= IF_Inst;
            ID_PC4 <= PC_4;
            PC <= 32'h80000004;
            flag <= 1'b0; // Interrupt 
        end
        8'b???1???? : begin
            flag <= 1'b0;
        end
        8'b????01?? : begin
            ID_Inst <= IF_Inst;
            ID_PC4 <= PC_4;
            flag <= 1'b1; 
        end
        8'b????0?1? : begin
            ID_Inst <= 32'b0;
            ID_PC4 <= 32'b0;
            PC[30:0] <= BranchDst[30:0];
            flag <= 1'b0;
        end
        8'b???????1 : begin
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
        default : begin
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


    end
end


*/
/*assign PC_Ctrl = (PCSrc == 3'b000) ? 3'b000 :
        (PCSrc == 3'b001) ? 3'b001 :
        stall ? 3'b010 :
        (~flag && firstBranch) ? 3'b011 :
        (~flag && isBranch) ? 3'b100 :
        (isJump && PC == 32'h80000004 && IRQ) ? 3'b101 :
        (isJump && ~(PC == 32'h80000004 && IRQ)) ? 3'b110 :
        3'b111;

always @(posedge reset or posedge clk) begin
    if(reset) begin
        ID_Inst <= {6'h02,26'd3};
    end
    else begin
        case (PC_Ctrl)
            3'b000: ID_Inst <= IF_Inst;
            3'b001: ID_Inst <= IF_Inst;
            3'b010: ;
            3'b011: ID_Inst <= IF_Inst;
            3'b100: ID_Inst <= 32'b0;
            3'b101: ID_Inst <= IF_Inst;
            3'b110: ID_Inst <= 32'b0;
            3'b111: ID_Inst <= IF_Inst;
        endcase
    end
end

always @(posedge reset or posedge clk) begin
    if(reset) begin
        ID_PC4 <= 32'h00000008;
    end
    else begin
        case (PC_Ctrl)
            3'b000: ID_PC4 <= PC_4;
            3'b001: ID_PC4 <= PC_4;
            3'b010: ;
            3'b011: ID_PC4 <= PC_4;
            3'b100: ID_PC4 <= 32'b0;
            3'b101: ID_PC4 <= PC_4;
            3'b110: ID_PC4 <= PC_4; 
            3'b111: ID_PC4 <= PC_4;
        endcase
    end
end

always @(posedge reset or posedge clk) begin
    if(reset) begin
        PC <= 32'h00000004;
    end
    else begin
        case (PC_Ctrl)
            3'b000: PC <= 32'h80000008;
            3'b001: PC <= 32'h80000004;
            3'b010: ;
            3'b011: ;
            3'b100: PC <= {PC[31],BranchDst[30:0]};
            3'b101: begin
                if(PCSrc == 3'b011) begin
                    PC <= {1'b0,JumpDst[30:0]};
                end 
                else begin
                    PC <= {PC[31], JumpDst[30:0]};
                end
            end
            3'b110: begin
                if(PCSrc == 3'b011) begin
                    PC <= {1'b0,JumpDst[30:0]};
                end 
                else begin
                    PC <= {PC[31], JumpDst[30:0]};
                end
            end
            3'b111: begin
                if(PC_4[9:2]==8'd143) begin
                    PC <= {1'b0,PC_4[30:0]};
                end
                else begin
                    PC <= PC_4;
                end
            end
        endcase
    end
end

always @(posedge reset or posedge clk) begin
    if(reset) begin
        flag <= 1'b0;
    end
    else begin
        case (PC_Ctrl)
            3'b011: flag <= 1'b1;
            default: flag <= 1'b0;
        endcase
    end
end
*/

always @(posedge reset or posedge clk or posedge recv_done) begin
    if(reset || ~recv_done) begin
        ID_Inst <= {6'h02,26'd3};
        ID_PC4 <= 32'h00000008;
        PC <= 32'h00000004;
        flag <= 1'b0;
    end
    else if (PCSrc == 3'b000) begin

        ID_Inst <= IF_Inst;
        ID_PC4 <= PC_4;
        PC <= 32'h80000008; // Exception
        flag <= 1'b0;
    end
    else if (PCSrc == 3'b001) begin

        ID_Inst <= IF_Inst;
        ID_PC4 <= PC_4;
        PC <= 32'h80000004;
        flag <= 1'b0; // Interrupt 
    end
    else if (stall)
        flag <= 1'b0;
    else if (~flag && firstBranch) begin // 在IF阶段判断遇到beq 再做一次beq（PC不更新）

        ID_Inst <= IF_Inst;
        ID_PC4 <= PC_4;
        flag <= 1'b1;   
    end
    else if (~flag && isBranch) begin // 第二个beq 之后必须stall 一个周期

        ID_Inst <= 32'b0;
        ID_PC4 <= 32'b0;
        PC <= {PC[31],BranchDst[30:0]};
        flag <= 1'b0;
    end
    else if (isJump) begin
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
    else begin

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
end

/*
wire [6:0] PC_Ctrl;
assign PC_Ctrl = {PCSrc,stall,flag,firstBranch,isBranch};

//assign isJump = ((PCSrc == 3'b010)||(PCSrc == 3'b011)) ? 1'b1 : 1'b0;

always @(posedge reset or posedge clk or posedge recv_done) begin
    if(reset || ~recv_done) begin
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
                ID_Inst <= IF_Inst; // 因为如果jump下一条是interrupt则不能stall
                ID_PC4 <= PC_4;
                PC <= {PC[31], JumpDst[30:0]};
            end
            else 
            begin
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
            ID_Inst <= IF_Inst;
            ID_PC4 <= PC_4;
            PC <= 32'h80000008; // Exception
            flag <= 1'b0;            
        end
        7'b0010000 : begin
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
        default : begin
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
*/

endmodule
