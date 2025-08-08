/*******************************(C) COPYRIGHT 2017 Wind (Xie Yushen)*********************************/
/**============================================================================
* @FileName    : Drive_Usart_Bsp.v
* @Description : UART low-level driver module
* @Date        : 2017/5/1
* @By          : Wind (Xie Yushen)
* @Email       : 1659567673@ qq.com
* @Platform    : Quartus II 15.0 (64-bit) (EP4CE22E22C8)
* @Explain     : Low-level UART driver (9600bps, 104us/bit)
*=============================================================================*/

/**
 * UART BSP (Board Support Package) Module
 * Low-level UART communication driver providing basic send/receive functionality.
 * Configured for 9600 baud rate with 1MHz clock input.
 */ 
module Drive_Usart_Bsp
(   
	 input in_clr,              // Reset signal, active low 
	 input in_clk_us,           // Microsecond clock input
	 input in_rx,               // UART receive data input
     input in_send_update,      // Send update signal
	 input [7:0]in_send_byte,   // Byte data to be transmitted

	 output out_tx,             // UART transmit data output 
	 output out_receive_update, // Receive update signal output
	 output [7:0]out_receive_byte // Received byte data output
);

//Parameter Definitions
parameter  CLK_FREQ = 1000000;          // System clock frequency (1MHz)
parameter  UART_BPS = 9600;             // UART baud rate (9600 bps)

/**
 * UART Receive Module Instance
 * Handles incoming UART data reception
 */
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





