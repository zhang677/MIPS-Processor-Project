`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/30 23:46:12
// Design Name: 
// Module Name: DataMemory
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


module DataMemory(
reset, clk, Address, Write_data, Read_data, MemRead, MemWrite, IRQ, digi
    );
input reset,clk;
input [31:0] Address, Write_data;
input MemRead,MemWrite;
output reg [31:0] Read_data;
output wire IRQ;
output reg [11:0] digi;
reg [31:0] TH;//0x40000000
reg [31:0] TL;//0x40000004
reg [2:0] TCON;//TCON only needs 3 bits
parameter RAM_SIZE = 256;
parameter RAM_SIZE_BIT = 8;
assign IRQ = TCON[2];
reg [31:0] RAM_data[RAM_SIZE - 1: 0];
parameter Count_time = 32'd10000;
//write data
integer i;
always @(posedge reset or posedge clk) begin
    if(reset) begin
        RAM_data[8'd0] <= 32'h00000064;
        RAM_data[8'd1] <= 32'd10;
        RAM_data[8'd2] <= 32'd10;
        RAM_data[8'd3] <= 32'h00000014;
        RAM_data[8'd4] <= 32'h0000003C;
        RAM_data[8'd5] <= 32'd12;
        RAM_data[8'd6] <= 32'd10;
        RAM_data[8'd7] <= 32'd20;
        RAM_data[8'd8] <= 32'd15;
        RAM_data[8'd9] <= 32'd8;
        RAM_data[8'd10] <= 32'd12;
        RAM_data[8'd11] <= 32'd10;
        RAM_data[8'd12] <= 32'd20;
        RAM_data[8'd13] <= 32'd15;
        RAM_data[8'd14] <= 32'd8;
        RAM_data[8'd15] <= 32'd2;
        RAM_data[8'd16] <= 32'd1;
        RAM_data[8'd17] <= 32'd3;
        RAM_data[8'd18] <= 32'd2;
        RAM_data[8'd19] <= 32'd1;
        RAM_data[8'd20] <= 32'd2;
        RAM_data[8'd21] <= 32'd1;
        RAM_data[8'd22] <= 32'd3;
        RAM_data[8'd23] <= 32'd2;
        RAM_data[8'd24] <= 32'd1;

        for(i = 8'd25 ; i < RAM_SIZE ; i = i + 1)
            RAM_data[i] <= 32'h00000000;

        TL <= 32'hffffffff - Count_time; //��ʱ��������
        TH <= 32'hffffffff - Count_time;
        TCON <= 3'b0;
        digi <= 12'b1;        

    end
    else begin
        if (MemWrite) begin
            if(Address >= 32'd0 && Address <= 32'h000007ff) begin
                RAM_data[Address[RAM_SIZE_BIT + 1:2]] <= Write_data;
            end
            else begin
                case(Address) 
                32'h40000000:TH <=Write_data;
                32'h40000004:TL <=Write_data;
                32'h40000008:TCON <=Write_data[2:0];
                32'h40000010:digi <=Write_data[11:0];
                default: ;
                endcase                  
            end
        end
        if (TCON[0]) begin
            if(TL==32'hffffffff) begin
                TL <= TH;
                if(TCON[1]) begin
                    TCON[2] <= 1'b1; //
                end
            end
            else begin
                TL <= TL + 1;
            end 
        end
    end
end
//MemRead
always @(*) begin
    if (MemRead) begin
        if(Address >= 32'd0 && Address <= 32'h000007ff) begin
            Read_data <= RAM_data[Address[RAM_SIZE_BIT + 1:2]];
        end
        else begin
            case(Address) 
                32'h40000000:Read_data <= TH;
                32'h40000004:Read_data <= TL;
                32'h40000008:Read_data <= {29'b0,TCON};
                32'h40000010:Read_data <= {20'b0,digi};
                default: Read_data <= 32'h00000000;
            endcase                  
        end
    end
    else begin
        Read_data <= 32'h00000000;
    end
end

endmodule
