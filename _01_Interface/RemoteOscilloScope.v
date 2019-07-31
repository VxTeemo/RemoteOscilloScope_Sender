 /*******************************(C) COPYRIGHT 2019 Teemo（陈晓东）*********************************/
/**============================================================================
* @FileName    : RemoteOscilloScope.v
* @Description : 顶层接口
* @Date        : 2019/7/22
* @By          : Teemo（陈晓东）
* @Email       : 
* @Platform    : Quartus Prime 18.0 (64-bit) (EP4CE22E22C8)
* @Explain     : 接口的终端
*=============================================================================*/   
/* 顶层接口模块 ----------------------*/
module RemoteOscilloScope
( 
    /* Drive_Clock -------------------*/
    input       clk_50M,
    input       rst,
    input       in_key,
    input       in_request_n,
    input[1:0]  in_sample_rate_select,
    
    /* Drive_Led ---------------------*/
    output[3:0] led_bus,

    /* Drive_ADC ---------------------*/
    input [9:0] in_ADC_data,
    output      out_OE_n,
    output      out_clk_ADC,
    
    /* Drive_DataControl -------------*/    
    output      out_uart_txd,
    
    /* Trigger signal from Comparator*/
    input       in_trigger_n,
    output      out_measure_hold_sig,
    
    /* Signal Freq measure ----------*/
    output      out_freq_uart_tx,
    
    output      out_clk_100k
);

/* Drive_Clock ----------------------*/
wire out_clk_us;
wire out_clk_ms;
wire out_clk_20ms;
wire out_clk_s;

Drive_Clock u_Drive_Clock
(  
    .in_clk_50M(clk_50M),
    .in_rst(rst),

    .out_clk_us(out_clk_us),
    .out_clk_ms(out_clk_ms),
    .out_clk_20ms(out_clk_20ms), 
    .out_clk_s(out_clk_s) 
);

wire out_clk_200M;
wire out_clk_10M;
Drive_PLL u_Drive_PLL
(
   .inclk0(clk_50M),
   .c0(out_clk_200M),
   .c1(out_clk_10M),
   .c2(out_clk_100k)
);

wire [9:0]out_ADC_data;
Drive_ADC u_Drive_ADC
(
    .in_rst(rst),
    .in_clk(out_clk_ADC),
    .in_ADC_data(in_ADC_data),

    .out_OE_n(out_OE_n),
    .out_ADC_data(out_ADC_data)
);

wire out_adc_clk;
assign out_clk_ADC = in_sample_rate_select[1] ? out_clk_100k : out_adc_clk;
App_DataControl u_App_DataControl
(
    .in_rst(rst),     
    .in_clk(out_clk_200M),     
    .in_clk_200M(out_clk_200M),
    .in_clk_10M(out_clk_10M),
    .in_clk_1k(out_clk_ms),
    .in_addata(out_ADC_data),
    .in_trigger_n(in_trigger_n),
    .in_request_n(in_key & in_request_n),
    .in_sample_rate_select(in_sample_rate_select),

    .out_uart_txd(out_uart_txd),
    
    .out_adc_clk(out_adc_clk),
    .out_measure_hold_sig(out_measure_hold_sig)
);  


 App_Led u_App_Led
(    
    .in_rst(rst), 
    .in_clk_ms(out_clk_ms), 
    .out_led(led_bus)  
);

wire [31:0]data_fx;
Drive_Usart_Top Drive_Usart_Top
(
    .in_clk_us(out_clk_us),
    .in_clr(rst),

    .out_set_freq(data_fx),
    .out_tx(out_freq_uart_tx)
);

wire in_freq_sig;
assign in_freq_sig = in_trigger_n;
Drive_Freq u_Drive_Freq
(
    .in_clk_50M(clk_50M),             // 标准时钟信号
    .in_clr(rst),                     // 复位信号
    .Sig_in(in_freq_sig),                     // 被测时钟信号
    .data_fx(data_fx)                    // 被测时钟频率输出
);


endmodule
/*******************************(C) COPYRIGHT 2019 Teemo（陈晓东）*********************************/





  
  
  
  
  
 
  
  