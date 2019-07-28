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
    input       in_key_n,
    
    //uart接口    
    input       in_uart_rxd,
	output      out_uart_txd,
    
    output      out_adc_clk,
    output      out_measure_hold_sig
    
);	 

//parameter define
parameter  DATA_NUM = 10'd206;
parameter  ADC_CLK_DELAY = 10'd50;
parameter  MEASURE_DONE_CNT = 10'd100;
parameter  TRIGGER_DELAY_CNT = 10'd200;

/* 连接输出 ---------------------------*/
assign out_measure_hold_sig = measure_hold_sig;
assign out_adc_clk = measure_adc_clk;
   

/* 寄存器配置 -------------------------*/
reg in_trigger_d;
reg trigger_flag;

/* 运行线程 ---------------------------*/
always @(posedge in_clk)
    in_trigger_d <= in_trigger;

//生成触发信号，开始计时
always @(posedge in_clk)
begin
    if(measure_start) begin
        if(in_trigger == 1 && in_trigger_d == 0 && trigger_enable) begin //检测到触发信号上升沿
            trigger_flag <= 1;
        end
        else if(measure_flag == 1 && measure_flag_d == 0) begin //检测到开始测量信号上升沿
            trigger_flag <= 0;
        end
        else
            trigger_flag <= trigger_flag;
    end
    else begin 
        trigger_flag <= 0;
    end
end

reg trigger_flag_d;
reg trigger_enable;
reg [9:0] trigger_delay_cnt;
always @(posedge in_clk)
    trigger_flag_d <= trigger_flag;
//触发使能信号，每次触发后，延迟1M时间后才能进行下一次触发
always @(posedge in_clk)
begin
    if(trigger_delay_cnt > TRIGGER_DELAY_CNT) begin
        trigger_enable <= 1;
    end
    else if(trigger_flag == 1 && trigger_flag_d == 0) begin
        trigger_enable <= 0;
    end
    else begin
        trigger_enable <= trigger_enable;
    end
end
//触发使能信号计数器，触发使能后开始计数
always @(posedge in_clk)
begin
    if(trigger_enable == 0) begin
        trigger_delay_cnt <= trigger_delay_cnt + 1'b1;
    end
    else
        trigger_delay_cnt <= 0;
end

//触发后延迟测量时间计数器，每次延迟的时间增加1
reg [9:0] measure_delay_cnt;
always @(posedge in_clk_200M or negedge in_rst)
begin
    if(!in_rst) begin
        measure_delay_cnt <= 0;
    end
    else begin
        if(measure_start) begin
            if(trigger_flag)
                measure_delay_cnt <= measure_delay_cnt + 1'b1;
            else
                measure_delay_cnt <= 0;
        end
        else begin
            measure_delay_cnt <= 0;
        end
    end
end

reg [9:0] measure_index;
reg measure_flag;
//测量信号，达到计数值n\deta t后产生信号
always @(posedge in_clk)
begin
    if(measure_delay_cnt == measure_index) begin
        measure_flag <= 1;
    end
    else 
        measure_flag <= 0;
end

reg measure_flag_d;
always @(posedge in_clk)
    measure_flag_d <= measure_flag;
    
always @(posedge in_clk)
begin
    if(measure_start) begin
        if(measure_flag == 1 && measure_flag_d == 0) begin //检测到触发信号上升沿
            measure_index <= measure_index + 1'b1;
        end
    end
    else begin
        measure_index <= 1;
    end
end

reg measure_done;       //测量结束信号
reg measure_done_d;
reg [9:0] measure_cnt;
reg measure_once_start;
reg measure_hold_sig;
always @(posedge in_clk)
    measure_done_d <= measure_done;

//采样保持信号
always @(posedge in_clk)
begin
    if(measure_start) begin
        if(measure_flag == 1 && measure_flag_d == 0) begin //检测到测量信号上升沿
            measure_hold_sig <= 0;
        end
        else if(measure_done == 1 && measure_done_d == 0) begin //检测到测量结束上升沿
            measure_hold_sig <= 1;
        end
        else 
            measure_hold_sig <= measure_hold_sig;
    end
    else begin
        measure_hold_sig <= 1;
    end
end

always @(posedge in_clk)
begin
    if(measure_hold_sig == 0)
        measure_cnt <= measure_cnt + 1'b1;
    else
        measure_cnt <= 0;
end

always @(posedge in_clk)
begin
    case (measure_cnt)
        MEASURE_DONE_CNT: begin
            measure_done <= 1;
        end
        default: begin
            measure_done <= 0;
        end
    endcase
end


reg measure_adc_sig;
reg [9:0]measure_adc_cnt;
reg measure_adc_done;
reg measure_adc_done_d;
always @(posedge in_clk)
    measure_adc_done_d <= measure_adc_done;

always @(posedge in_clk)
begin
    if(measure_start) begin
        if(measure_flag == 1 && measure_flag_d == 0) begin //检测到测量信号上升沿
            measure_adc_sig <= 1;
        end
        else if(measure_adc_done == 1 && measure_adc_done_d == 0) begin //检测到测量结束上升沿
            measure_adc_sig <= 0;
        end
        else 
            measure_adc_sig <= measure_adc_sig;
    end
    else begin
        measure_adc_sig <= 0;
    end
end

always @(posedge in_clk)
begin
    if(measure_adc_sig)
        measure_adc_cnt <= measure_adc_cnt + 1'b1;
    else
        measure_adc_cnt <= 0;
end

reg measure_adc_clk;
always @(posedge in_clk)
begin
    case (measure_adc_cnt)
        10'd1: begin
            measure_adc_clk <= 0;
        end
        ADC_CLK_DELAY: begin
            measure_adc_clk <= 1;
            measure_adc_done <= 1;
        end
        default: begin
            measure_adc_clk <= measure_adc_clk;
            measure_adc_done <= 0;
        end
    endcase
end


reg in_key_d;
always @(posedge in_clk)
    in_key_d <= in_key_n;

reg measure_start;
always @(posedge in_clk or negedge in_rst)
begin
    if(!in_rst) begin
        measure_start <= 0;
    end
    else if(in_key_d == 1 && in_key_n == 0) begin
        measure_start <= 1;
    end
    else if(measure_index == DATA_NUM) begin
        measure_start <= 0;
    end
    else
        measure_start <= measure_start;
end


//FIFO存储与串口发送
wire fifo_rdclk;
wire fifo_rdreq;
wire fifo_wrclk;
wire fifo_wrreq;
wire [7:0]fifo_data2uart;
wire rdempty_sig;
wire wrfull_sig;

assign fifo_rdclk = uart_send_sig;
assign fifo_rdreq = uart_send_start;
assign fifo_wrclk = measure_adc_clk;
assign fifo_wrreq = measure_start;

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
parameter  CLK_FREQ = 200000000;       //定义系统时钟频率
parameter  UART_BPS = 115200;         //定义串口波特率

//wire define   
wire        uart_en_w;                 //UART发送使能
//wire [7:0] uart_data_w;               //UART发送数据
wire        uart_send_once_done;

assign      uart_en_w = uart_send_sig;

uart_send #(                          //串口发送模块
    .CLK_FREQ       (CLK_FREQ),       //设置系统时钟频率
    .UART_BPS       (UART_BPS))       //设置串口发送波特率
u_uart_send(                 
    .sys_clk        (in_clk),
    .sys_rst_n      (in_rst),
    
    .uart_en        (uart_en_w),
    .uart_din       (fifo_data2uart),
    .uart_txd       (out_uart_txd),
    .done_flag      (uart_send_once_done)
);

reg measure_start_d;
always @(posedge in_clk)
    measure_start_d <= measure_start;
    
reg         uart_send_start;
reg [9:0]   uart_send_cnt;

always @(posedge in_clk)
begin
    if(measure_start == 0 && measure_start_d == 1) begin //检测测量信号下降沿，即测量结束信号
        uart_send_start <= 1;
    end
    else if(uart_send_cnt == DATA_NUM) begin
        uart_send_start <= 0;
    end
    else
        uart_send_start <= uart_send_start;
end

reg uart_send_once_done_d;
always @(posedge in_clk)
    uart_send_once_done_d <= uart_send_once_done;

always @(posedge in_clk)
begin
    if(uart_send_start) begin
        if(uart_send_once_done == 1 && uart_send_once_done_d == 0) //串口发送一个数据结束上升沿
            uart_send_cnt <= uart_send_cnt + 1'b1;
    end
    else
        uart_send_cnt <= 0;
end

reg uart_send_sig;
reg uart_send_start_d0;
reg uart_send_start_d1;
always @(posedge in_clk) begin
    uart_send_start_d0 <= uart_send_start;
    uart_send_start_d1 <= uart_send_start_d0;
end


always @(posedge in_clk)
begin
    if(uart_send_start) begin
        if(uart_send_start_d0 == 1 && uart_send_start_d1 == 0) begin //串口开始发送，延时一个时钟
            uart_send_sig <= 1;
        end
        else if(uart_send_once_done == 1 && uart_send_once_done_d == 0) begin
            uart_send_sig <= 1;
        end
        else
            uart_send_sig <= 0;
    end
    else
        uart_send_sig <= 0;
end





endmodule
/*******************************(C) COPYRIGHT 2019 Teemo（陈晓东）*********************************/



