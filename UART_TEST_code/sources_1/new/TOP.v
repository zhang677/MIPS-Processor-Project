module TOP (
    input clk,
    input reset,
    input Rx_Serial,
    input mem2uart,
    output wire Tx_Serial,
    output wire recv_done,
    output wire send_done,
    output wire IRQ,
    output wire [11:0] digi
);
wire [31:0] o_addr0;
wire rd_e0,wr_en0;
wire [31:0] data35,wdata0;
UART_MEM UART_mem(.clk(clk),.rst(reset),.mem2uart(mem2uart),.recv_done(recv_done),
.send_done(send_done),.o_addr0(o_addr0),.wr_en0(wr_en0),.rdata0(data35),.wdata0(wdata0),
.Rx_Serial(Rx_Serial),.Tx_Serial(Tx_Serial));

mem MEM(.reset(reset), .clk(clk), .Address(o_addr0), .Write_data(wdata0), .Read_data(rdata0), .MemRead(rd_en0), .MemWrite(wr_en0), .IRQ(IRQ), .digi(digi),.data35(data35)
);



endmodule