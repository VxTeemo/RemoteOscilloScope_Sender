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
    input       in_clk_1k,
    input       in_trigger_n,
    input[9:0]  in_addata,
    input       in_request_n,
    input[1:0]  in_sample_rate_select,
    
    //uart接口
    output      out_uart_txd,
    
    output      out_adc_clk,
    output      out_measure_hold_sig
    
);

//in_sample_rate_select[1] 1:1K实时采样 0:等效采样
//in_sample_rate_select[0] 1:10M等效采样 0:200M等效采样 in_sample_rate_select[1]为0时有效

wire measure_sig;
sample_control u_sample_control
( 
    .in_rst(in_rst),
    .in_clk(in_clk),
    .in_clk_200M(in_clk_200M),
    .in_clk_10M(in_clk_10M),
    .in_clk_1k(in_clk_1k),
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
    .fifo_enable(~in_sample_rate_select[1]),
    .measure_sig(measure_sig),
    .measure_adc_clk(out_adc_clk),
    .in_uart_send_sig(out_uart_send_sig),
    .in_uart_send_start(uart_send_start),
    .in_addata(in_addata[9:2]), 
    .out_fifo_data(fifo_data2uart),
    .out_fifo_sig(fifo_sig)
);

wire uart_force_send;
assign uart_force_send = in_sample_rate_select[1] ? in_clk_1k : 1'b0 ;


wire [7:0] uart_data;
assign uart_data = in_sample_rate_select[1] ? in_addata[9:2] : fifo_data2uart ;
uart_send_control u_uart_send_control
( 
    .in_rst(in_rst),
    .in_clk(in_clk),
    .in_uart_data(uart_data),
    .in_fifo_sig(fifo_sig),
    .uart_force_send(uart_force_send),

    .out_uart_txd(out_uart_txd),
    .out_uart_send_sig(out_uart_send_sig),
    .out_uart_send_start(uart_send_start)
);

endmodule
/*******************************(C) COPYRIGHT 2019 Teemo（陈晓东）*********************************/



