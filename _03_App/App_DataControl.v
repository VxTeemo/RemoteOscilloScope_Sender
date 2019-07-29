/*******************************(C) COPYRIGHT 2019 Teemo（陈晓东）*********************************/
/**============================================================================
* @FileName    : App_DataControl.v
* @Description : 读取ADC的实时数据，存储到FIFO中，并使用UART发送数据
* @Date        : 2019/7/22
* @By          : Teemo（陈晓东）
* @Email       : 
* @Platform    : Quartus Prime 18.0 (64-bit) (EP4CE22E22C8)
* @Explain     : 控制ADC与UART的数据传输
*=============================================================================*/ 
/* 设置接口 ---------------------------*/
module App_DataControl
( 
    input       in_rst,
    input       in_clk,
    input       in_clk_200M,
    input       in_clk_10M,
    input       in_trigger_n,
    input[9:0]  in_addata,
    input       in_request_n,
    input[1:0]  in_sample_rate_select,
    
    //uart接口
    output      out_uart_txd,
    
    output      out_adc_clk,
    output      out_measure_hold_sig
    
);

wire measure_sig;
sample_control u_sample_control
( 
    .in_rst(in_rst),
    .in_clk(in_clk),
    .in_clk_200M(in_clk_200M),
    .in_clk_10M(in_clk_10M),
    .in_trigger_n(in_trigger_n),
    .in_request_n(in_request_n),
    .in_sample_rate_select(in_sample_rate_select),
    
    .out_adc_clk(out_adc_clk),
    .out_measure_hold_sig(out_measure_hold_sig),
    .out_measure_sig(measure_sig)
);


wire out_uart_send_sig;
wire uart_send_start;
wire [7:0]fifo_data2uart;
wire fifo_sig;
fifo_control u_fifo_control
(
    .in_rst(in_rst),
    .in_clk(in_clk),
    .measure_sig(measure_sig),
    .measure_adc_clk(out_adc_clk),
    .in_uart_send_sig(out_uart_send_sig),
    .in_uart_send_start(uart_send_start),
    .in_addata(in_addata[9:2]), 
    .out_fifo_data(fifo_data2uart),
    .out_fifo_sig(fifo_sig)
);

uart_send_control u_uart_send_control
( 
    .in_rst(in_rst),
    .in_clk(in_clk),
    .in_uart_data(fifo_data2uart),
    .in_fifo_sig(fifo_sig),

    .out_uart_txd(out_uart_txd),
    .out_uart_send_sig(out_uart_send_sig),
    .out_uart_send_start(uart_send_start)
);

endmodule
/*******************************(C) COPYRIGHT 2019 Teemo（陈晓东）*********************************/



