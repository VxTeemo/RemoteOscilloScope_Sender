/*******************************(C) COPYRIGHT 2017 Wind（谢玉伸）*********************************/
/**============================================================================
* @FileName    : Drive_Usart_Bsp.v
* @Description : 串口底层文件
* @Date        : 2017/5/1
* @By          : Wind（谢玉伸）
* @Email       : 1659567673@ qq.com
* @Platform    : Quartus II 15.0 (64-bit) (EP4CE22E22C8)
* @Explain     : 底层文件(9600bps 104us/bit)
*=============================================================================*/ 
module Drive_Usart_Bsp
(   
	 input in_clr 
	 ,input in_clk_us 
	 ,input in_rx 
     ,input in_send_update
	 ,input [7:0]in_send_byte

	 ,output out_tx 
	 ,output out_receive_update
	 ,output [7:0]out_receive_byte 
);
//parameter define
parameter  CLK_FREQ = 1000000;       //定义系统时钟频率
parameter  UART_BPS = 9600;         //定义串口波特率

uart_recv #(                          //串口接收模块
    .CLK_FREQ       (CLK_FREQ),       //设置系统时钟频率
    .UART_BPS       (UART_BPS))       //设置串口接收波特率
u_uart_recv(                 
    .sys_clk        (in_clk_us), 
    .sys_rst_n      (in_clr),
    
    .uart_rxd       (in_rx),
    .uart_done      (out_receive_update),
    .uart_data      (out_receive_byte)
    );

uart_send #(                          //串口发送模块
    .CLK_FREQ       (CLK_FREQ),       //设置系统时钟频率
    .UART_BPS       (UART_BPS))       //设置串口发送波特率
u_uart_send(                 
    .sys_clk        (in_clk_us),
    .sys_rst_n      (in_clr),
     
    .uart_en        (in_send_update),
    .uart_din       (in_send_byte),
    .uart_txd       (out_tx)
    );


endmodule
/*******************************(C) COPYRIGHT 2017 Wind（谢玉伸）*********************************/





