module uart_send_control
( 
    input       in_rst,
    input       in_clk,
    input[7:0]  in_uart_data,
    input       in_fifo_sig,
    input       uart_force_send,
    
    //uart接口
    output      out_uart_txd,
    output      out_uart_send_sig,
    output      out_uart_send_start
);
assign out_uart_send_sig = uart_send_sig;
assign out_uart_send_start = uart_send_start;
//parameter define
parameter  DATA_NUM = 10'd405;

//parameter define
parameter  CLK_FREQ = 200000000;       //定义系统时钟频率
parameter  UART_BPS = 115200;         //定义串口波特率

//wire define   
wire        uart_en_w;                 //UART发送使能
//wire [7:0] uart_data_w;               //UART发送数据
wire        uart_send_once_done;

assign      uart_en_w = uart_send_sig | uart_force_send;

uart_send #(                          //串口发送模块
    .CLK_FREQ       (CLK_FREQ),       //设置系统时钟频率
    .UART_BPS       (UART_BPS))       //设置串口发送波特率
u_uart_send(                 
    .sys_clk        (in_clk),
    .sys_rst_n      (in_rst),
    
    .uart_en        (uart_en_w),
    .uart_din       (in_uart_data),
    .uart_txd       (out_uart_txd),
    .done_flag      (uart_send_once_done)
);


reg         uart_send_start;
reg [9:0]   uart_send_cnt;

reg in_fifo_sig_d;
always @(posedge in_clk)
    in_fifo_sig_d <= in_fifo_sig;

always @(posedge in_clk)
begin
    if(in_fifo_sig == 0 && in_fifo_sig_d == 1) begin //检测FIFO错误数据发送结束
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
