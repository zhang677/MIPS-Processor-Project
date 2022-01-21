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


module test_cpu();
    reg reset;
    reg sysclk;
    wire [11:0] digi;
    wire [7:0] LED;
    reg mem2uart;
    reg Rx_Serial;
    wire Tx_Serial;
    reg [7:0] idx;
    reg [7:0] buff;
    reg [7:0] test1 [0:99];
    
    CPU CPU_1(reset,sysclk,digi,LED,mem2uart,Tx_Serial,Rx_Serial);
    
initial begin
    sysclk<=0;
    reset<=0;
    mem2uart<=0;
    Rx_Serial<=1;//Idle
    idx<=8'b0;
    buff<=8'b0;
    $readmemh("E:/vivado/myprojs/pipeline/data.txt",test1);
    #1 reset<=1;
    #1 reset<=0;

end
always #1 sysclk = ~sysclk; //目前一个周期是2
initial begin
    //读进来25*4个bytes，所以循环100次
    for (idx=8'd0;idx<8'd100;idx=idx+8'd1) begin
        buff<=test1[idx];
        #10 Rx_Serial<=0;//start
        #10 Rx_Serial<=buff[0];
        #10 Rx_Serial<=buff[1];
        #10 Rx_Serial<=buff[2];
        #10 Rx_Serial<=buff[3];
        #10 Rx_Serial<=buff[4];
        #10 Rx_Serial<=buff[5];
        #10 Rx_Serial<=buff[6];
        #10 Rx_Serial<=buff[7];
        #10 Rx_Serial<=1;//stop       
    end
    #10 mem2uart<=1;   
end
endmodule
