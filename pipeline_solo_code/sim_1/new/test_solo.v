`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/09 14:37:54
// Design Name: 
// Module Name: test_solo
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


module test_solo();
    reg reset;
    reg clk;
    wire [11:0] digi;
    wire [12:0] LED;
    CPU CPU_1(reset, clk,digi,LED);
    
    initial begin
        reset = 0;
        clk = 0;
        #1 reset = 1;
        #1 reset = 0;
    end
    
    always #1 clk = ~clk;
endmodule
