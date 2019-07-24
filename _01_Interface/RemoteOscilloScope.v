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
    
	/* Drive_Led ---------------------*/
	output[3:0] led_bus,

    /* Drive_ADC ---------------------*/
	input [9:0] in_ADC_data,
	output      out_OE_n,
	output      ADC_CLK,
    
    /* Drive_DataControl -------------*/    
    input       in_uart_rxd,
    output      out_uart_txd
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


wire out_clk_100M; 
wire out_clk_ADC;
assign ADC_CLK = out_clk_ADC;
 Drive_PLL u_Drive_PLL
 (
    .inclk0(clk_50M),
    .c0(out_clk_100M),
    .c1(out_clk_ADC)
 );
 
Drive_ADC u_Drive_ADC
(
    .in_rst(rst),
    .in_clk(out_clk_ADC),
    .in_ADC_data(in_ADC_data),

    .out_OE_n(out_OE_n),
    .out_ADC_data(out_ADC_data)
);


App_DataControl u_App_DataControl
( 
    .in_rst(rst),     
    .in_clk(out_clk_100M),     
    .in_clk_ad(out_clk_ADC),
    .in_ADDATA(out_ADC_data),  
 
    .in_uart_rxd(in_uart_rxd),
    .out_uart_txd(out_uart_txd)
    
);	


 App_Led u_App_Led
(    
	.in_rst(rst), 
	.in_clk_ms(out_clk_ms), 
	.out_led(led_bus)  
);




endmodule
/*******************************(C) COPYRIGHT 2019 Teemo（陈晓东）*********************************/





  
  
  
  
  
 
  
  