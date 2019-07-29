module sample_control
( 
    input       in_rst,
    input       in_clk,
    input       in_clk_200M,
    input       in_clk_10M,
    input       in_clk_1k,
    input       in_trigger_n,
    input       in_request_n,
    input[1:0]  in_sample_rate_select,
    
    output      out_adc_clk,
    output      out_measure_hold_sig,
    output      out_measure_sig
);
assign out_measure_sig = measure_start;

//parameter define
parameter  DATA_NUM = 10'd405;

parameter  SYS_CLK = 200_000_000;
parameter  TRIGGER_DELAY_TIME   = 1_000_000;    //1M的时间 1us
parameter  TRIGGER_DELAY_CNT    =   10'd200;
parameter  MEASURE_DONE_TIME    = 2_000_000;    //0.5us
parameter  MEASURE_DONE_CNT     =   10'd100;
parameter  ADC_CLK_DELAY_TIME   = 4_000_000;    //0.25us
parameter  ADC_CLK_DELAY        =    10'd50;

//localparam TRIGGER_DELAY_CNT    = SYS_CLK / TRIGGER_DELAY_TIME;
//localparam MEASURE_DONE_CNT     = SYS_CLK / MEASURE_DONE_TIME;
//localparam ADC_CLK_DELAY        = SYS_CLK / ADC_CLK_DELAY_TIME;

/* 连接输出 ---------------------------*/
assign out_measure_hold_sig = measure_hold_sig;
assign out_adc_clk = measure_adc_clk;


/* 寄存器配置 -------------------------*/

reg in_trigger_d;
reg trigger_flag;
wire in_trigger;
assign in_trigger = ~in_trigger_n;
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

//in_sample_rate_select[1] 1:1K实时采样 0:等效采样
//in_sample_rate_select[0] 1:10M等效采样 0:200M等效采样 in_sample_rate_select[1]为0时有效

wire delta_t_clk;
//assign delta_t_clk = in_sample_rate_select[0] ? in_clk_10M : in_clk_200M ;

delta_t_clk_mux delta_t_clk_mux_inst (
    .data0 ( in_clk_10M ),
    .data1 ( in_clk_200M ),
    .sel ( in_sample_rate_select[0] ),
    .result ( delta_t_clk )
    );

//触发后延迟测量时间计数器，即计算\delta t的计数器，每次延迟的时间增加1
reg [9:0] measure_delay_cnt;

always @(posedge delta_t_clk or negedge in_rst)
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
//测量信号，达到计数值n\delta t后产生信号
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

reg in_clk_1k_d;
always @(posedge in_clk)
    in_clk_1k_d <= in_clk_1k;
    
    
always @(posedge in_clk)
begin
    if(measure_start) begin
        if(in_sample_rate_select[1]) begin //实时采样
            if(in_clk_1k == 1 && in_clk_1k_d == 0) begin //1ms一次的上升沿
                measure_index <= measure_index + 1'b1;
            end
        end
        else begin //等效采样
            if(measure_flag == 1 && measure_flag_d == 0) begin //检测到触发信号上升沿
                measure_index <= measure_index + 1'b1;
            end
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


reg in_request_d;
always @(posedge in_clk)
    in_request_d <= in_request_n;

reg measure_start;
always @(posedge in_clk or negedge in_rst)
begin
    if(!in_rst) begin
        measure_start <= 0;
    end
    else if(in_request_d == 1 && in_request_n == 0) begin
        measure_start <= 1;
    end
    else if(measure_index == DATA_NUM) begin
        measure_start <= 0;
    end
    else
        measure_start <= measure_start;
end

endmodule