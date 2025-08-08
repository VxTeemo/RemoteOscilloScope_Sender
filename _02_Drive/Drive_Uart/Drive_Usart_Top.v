/*******************************(C) COPYRIGHT 2017 Wind (Xie Yushen)*********************************/
/**============================================================================
* @FileName    : Drive_Usart_Top.v
* @Description : UART top-level module
* @Date        : 2017/5/1
* @By          : Wind (Xie Yushen)
* @Email       : 1659567673@ qq.com
* @Platform    : Quartus II 15.0 (64-bit) (EP4CE22E22C8)
* @Explain     : UART top-level interface for frequency measurement transmission
*=============================================================================*/

/**
 * UART Top-Level Module
 * Integrates UART communication handling and frequency data transmission.
 * Manages communication between frequency measurement module and external PC.
 */ 
module Drive_Usart_Top
(   
    input in_clr,               // Reset signal, active low
    input in_clk_us,            // Microsecond clock input  
    input in_rx,                // UART receive data input
    input in_key,               // Key input for manual transmission

    output out_tx,              // UART transmit data output
    output [4:2]out_led,        // LED status indicators

    input [31:0]out_set_freq    // Frequency data to be transmitted
);



// Internal signal connections
wire w_send_update;         // Send update signal from handler to BSP
wire [7:0]w_send_byte;      // Byte data to be transmitted

/**
 * UART Protocol Handler Module
 * Processes frequency data formatting and transmission control
 */
Drive_Usart_Handle  Drive_Usart_Handle
(
    .in_clr(in_clr),
    .in_clk_us(in_clk_us),
    .in_receive_update(w_receive_update),
    .in_receive_byte(w_receive_byte),
    .in_key(in_key),
    
    .out_send_update(w_send_update),
    .out_send_byte(w_send_byte),
    .out_led(out_led[3:2]),
    
    .out_set_freq(out_set_freq)
);


// UART physical layer interface signals
wire w_receive_update;      // Receive update signal from BSP to handler 
wire [7:0]w_receive_byte;   // Received byte data

/**
 * UART Physical Layer (BSP) Module
 * Handles low-level UART communication at 9600 bps
 */ 
Drive_Usart_Bsp Drive_Usart_Bsp
(
    .in_clr(in_clr),
    .in_clk_us(in_clk_us),
    .in_rx(in_rx),
    .in_send_update(w_send_update),
    .in_send_byte(w_send_byte),
    
    .out_receive_byte(w_receive_byte),
    .out_tx(out_tx),
    .out_receive_update(w_receive_update)
);  



endmodule

/*******************************(C) COPYRIGHT 2017 Wind (Xie Yushen)*********************************/











