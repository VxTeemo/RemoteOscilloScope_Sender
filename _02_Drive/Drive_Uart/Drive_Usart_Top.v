/*******************************(C) COPYRIGHT 2017 Wind（谢玉伸）*********************************/
/**============================================================================
* @FileName    : Drive_Usart_Top.v
* @Description : 串口顶层文件
* @Date        : 2017/5/1
* @By          : Wind（谢玉伸）
* @Email       : 1659567673@ qq.com
* @Platform    : Quartus II 15.0 (64-bit) (EP4CE22E22C8)
* @Explain     : 串口顶层接口
*=============================================================================*/ 
module Drive_Usart_Top
(   
    input in_clr,
    input in_clk_us,
    input in_rx,
    input in_key,

    output out_tx,
    output [4:2]out_led,

    input [31:0]out_set_freq //设置频率
);



wire w_send_update;
wire [7:0]w_send_byte;
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


wire w_receive_update; 
wire [7:0]w_receive_byte; 
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



/*******************************(C) COPYRIGHT 2017 Wind（谢玉伸）*********************************/











