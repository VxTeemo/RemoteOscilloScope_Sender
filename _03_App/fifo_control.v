module fifo_control
(
    input       in_rst,
    input       in_clk,
    input       measure_sig,
    input       measure_adc_clk,
    input       in_uart_send_start,
    input       in_uart_send_sig,
    input[7:0]  in_addata,
    output[7:0] out_fifo_data,
    output      out_fifo_sig
);
assign out_fifo_sig = fifo_rdclk_mess_start;

//parameter define
parameter  DATA_NUM = 10'd405;


//FIFO存储与串口发送
wire fifo_rdclk;
wire fifo_rdreq;
wire fifo_wrclk;
wire fifo_wrreq;

wire rdempty_sig;
wire wrfull_sig;
wire wrusedw_sig;
wire rdusedw_sig;

assign fifo_rdclk = fifo_rdclk_sig | in_uart_send_sig;
assign fifo_rdreq = in_uart_send_start | fifo_rdclk_mess_start;
assign fifo_wrclk = measure_adc_clk;
assign fifo_wrreq = measure_sig;

fifo_addata u_fifo_addata (
    .data ( in_addata ),
    .rdclk ( fifo_rdclk ),
    .rdreq ( fifo_rdreq ),
    .wrclk ( fifo_wrclk ),
    .wrreq ( fifo_wrreq ),
    .q ( out_fifo_data ),
    .rdempty ( rdempty_sig ),
    .rdusedw ( rdusedw_sig ),
    .wrfull ( wrfull_sig ),
    .wrusedw ( wrusedw_sig )
    );

reg measure_sig_d;
always @(posedge in_clk)
    measure_sig_d <= measure_sig;

reg         fifo_rdclk_sig;
reg         fifo_rdclk_mess_start;
reg [9:0]   fifo_rdclk_mess_cnt;

always @(posedge in_clk)
begin
    if(measure_sig == 0 && measure_sig_d == 1) begin //检测测量信号下降沿，即测量结束信号
        fifo_rdclk_mess_start <= 1;
    end
    else if(fifo_rdclk_mess_cnt == 110) begin
        fifo_rdclk_mess_start <= 0;
    end
    else begin
        fifo_rdclk_mess_start <= fifo_rdclk_mess_start;
    end
end

always @(posedge in_clk)
begin
    if(fifo_rdclk_mess_start)
        fifo_rdclk_mess_cnt <= fifo_rdclk_mess_cnt + 1'b1;
    else
        fifo_rdclk_mess_cnt <= 0;
end

always @(posedge in_clk)
begin
    if(fifo_rdclk_mess_start) begin
        case(fifo_rdclk_mess_cnt)
            10,30,50,70,90: begin
                fifo_rdclk_sig <= 1;
            end
            20,40,60,80,100 :begin
                fifo_rdclk_sig <= 0;
            end
            default: begin
                fifo_rdclk_sig <= fifo_rdclk_sig;
            end
        endcase
    end
    else
        fifo_rdclk_sig <= 0;
end



endmodule
