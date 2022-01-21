`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/21 13:48:39
// Design Name: 
// Module Name: clk_gen
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


module clk_gen(
    reset,
    clk,
    clk_10
    );
input reset;
input wire clk;
output clk_10;

reg             clk_10; 
parameter   CNT = 32'd1;//5:10MHz 1:50MHz
reg     [31:0]  count;

always @(posedge reset or posedge clk)
begin
    if(reset) begin
        count <= 32'd0;
        clk_10 <= 0;
    end
    else begin
        count <= (count==CNT-32'd1) ? 32'd0 : count + 32'd1;
        clk_10 <= (count==32'd0) ? ~clk_10 : clk_10;
    end

end

endmodule
