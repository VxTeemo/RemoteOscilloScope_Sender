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
    input       in_trigger,
	input[9:0]  in_addata, 
    input       in_key_n;
    
    //uart接口    
    input       in_uart_rxd,
	output      out_uart_txd,
    
    output      out_adc_clk,
    output      measure_flag
    
);	 

/* 寄存器配置 -------------------------*/


/* 连接输出 ---------------------------*/
wire fifo_rdclk;
wire fifo_rdreq;
wire fifo_wrclk;
wire fifo_wrreq;
wire [7:0]fifo_data2uart;
wire rdempty_sig;
wire wrfull_sig;

assign fifo_wrclk = measure_done;
fifo_addata	u_fifo_addata (
	.data ( in_addata[9:2] ),
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


reg in_trigger_d;
reg trigger_flag;
reg measure_done;       //测量结束信号
reg measure_done_d;

always @(posedge in_clk)
    in_trigger_d <= in_trigger;
always @(posedge in_clk)
    measure_done_d <= measure_done;

//生成触发信号，开始计时
always @(posedge in_clk)
begin
    if(in_trigger == 1 && in_trigger_d == 0) begin //检测到触发信号上升沿
        trigger_flag <= 1;
    end
    else if(measure_done == 1 && measure_done_d == 0) begin //检测到测量完成信号上升沿
        trigger_flag <= 0;
    end
    else
        trigger_flag <= trigger_flag;
end

reg [9:0] measure_delay_cnt;
always @(posedge in_clk_200M or negedge in_rst)
begin
    if(!in_rst) begin
        measure_delay_cnt <= 0;
    end
    else begin
        if(trigger_flag)
            measure_delay_cnt <= measure_delay_cnt + 1'b1;
        else
            measure_delay_cnt <= 0;
    end
end

reg [9:0] measure_index;
//wire measure_flag;
assign measure_flag = (measure_delay_cnt == measure_index);
reg measure_flag_d;
always @(posedge in_clk)
    measure_flag_d <= measure_flag;

always @(posedge in_clk)
begin
    if(measure_flag == 1 && measure_flag_d == 0) begin //检测到触发信号上升沿
        measure_index <= measure_index + 1'b1;
        measure_done <= 0;
    end
    else
        measure_done <= 1;
end

wire key_press_flag;
reg in_key_d;

always @(posedge in_clk)
    in_key_d <= in_key_n;
assign key_press_flag = (~in_key_n) & in_key_d;

reg measure_start;
always @(posedge in_clk or negedge in_rst)
begin
    if(!in_rst) begin
        measure_start <= 0;
    end
    else if(in_key_d == 1 && in_key_n == 0) begin
        measure_start <= 1;
    end
    else if(measure_index == 10'd200) begin
        measure_start <= 0;
    end
    else
        measure_start <= measure_start;
end



endmodule
/*******************************(C) COPYRIGHT 2019 Teemo（陈晓东）*********************************/



