`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/06 12:17:20
// Design Name: 
// Module Name: tb_uart
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


module tb_uart();
reg clk;
reg rst;
reg mem2uart;
wire recv_done;
wire send_done;
reg  Rx_Serial;
wire Tx_Serial;
wire IRQ;
wire [11:0] digi;
reg [7:0] idx;
reg [7:0] buff;
reg [7:0] test1 [0:99];

TOP top(clk,rst,Rx_Serial,mem2uart,Tx_Serial,recv_done,send_done,IRQ,digi);


initial begin
    clk<=0;
    rst<=1;
    mem2uart<=0;
    Rx_Serial<=1;//Idle
    idx<=8'b0;
    buff<=8'b0;
    $readmemh("E:/vivado/myprojs/UART_TEST/data.txt",test1);
    #1 rst<=0;

end
always #1 clk = ~clk; //目前一个周期是2
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
