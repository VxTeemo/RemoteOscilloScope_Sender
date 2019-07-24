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
	input       in_clk_ad,
	input[9:0]  in_ADDATA,  
    
    //uart接口    
    input       in_uart_rxd,
	output      out_uart_txd
    
);	 

/* 寄存器配置 -------------------------*/


/* 连接输出 ---------------------------*/
wire fifo_rdclk;
wire fifo_rdreq;
wire fifo_wrclk;
wire fifo_wrreq;
wire fifo_data2uart;
fifo_addata	u_fifo_addata (
	.data ( in_ADDATA[9:2] ),
	.rdclk ( fifo_rdclk ),
	.rdreq ( fifo_rdreq ),
	.wrclk ( fifo_wrclk ),
	.wrreq ( fifo_wrreq ),
	.q ( fifo_data2uart ),
	.rdempty ( rdempty_sig ),
	.wrfull ( wrfull_sig )
	);



//parameter define
parameter  CLK_FREQ = 100000000;       //定义系统时钟频率
parameter  UART_BPS = 230400;         //定义串口波特率

//wire define   
wire       uart_en_w;                 //UART发送使能
//wire [7:0] uart_data_w;               //UART发送数据

uart_send #(                          //串口发送模块
    .CLK_FREQ       (CLK_FREQ),       //设置系统时钟频率
    .UART_BPS       (UART_BPS))       //设置串口发送波特率
u_uart_send(                 
    .sys_clk        (in_clk),
    .sys_rst_n      (in_rst),
     
    .uart_en        (uart_en_w),
    .uart_din       (fifo_data2uart),
    .uart_txd       (out_uart_txd)
    );
    
    
    
/* 运行线程 ---------------------------*/
always @(posedge in_clk or negedge in_rst)
begin   

end
endmodule
/*******************************(C) COPYRIGHT 2019 Teemo（陈晓东）*********************************/



