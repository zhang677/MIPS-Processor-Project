`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/04 00:19:07
// Design Name: 
// Module Name: test_cpu
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


module tb_cpu();
    reg reset;
    reg clk;
    wire [11:0] digi;
    CPU CPU_1(reset, clk,digi);
    
    initial begin
        reset = 0;
        clk = 0;
        #1 reset = 1;
        #1 reset = 0;
    end
    
    always #1 clk = ~clk;
endmodule
