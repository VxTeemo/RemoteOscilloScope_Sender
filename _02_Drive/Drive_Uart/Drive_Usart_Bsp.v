/*******************************(C) COPYRIGHT 2017 Wind（谢玉伸）*********************************/
/**============================================================================
* @FileName    : Drive_Usart_Bsp.v
* @Description : 串口底层文件
* @Date        : 2017/5/1
* @By          : Wind（谢玉伸）
* @Email       : 1659567673@ qq.com
* @Platform    : Quartus II 15.0 (64-bit) (EP4CE22E22C8)
* @Explain     : 底层文件(9600bps 104us/bit)
*=============================================================================*/ 
module Drive_Usart_Bsp
(   
	 input in_clr 
	 ,input in_clk_us 
	 ,input in_rx 
     ,input in_send_update
	 ,input [7:0]in_send_byte

	 ,output reg out_tx 
	 ,output reg out_receive_update
	 ,output reg [7:0]out_receive_byte 
);
//parameter define
parameter  CLK_FREQ = 1000000;       //定义系统时钟频率
parameter  UART_BPS = 9600;         //定义串口波特率

localparam ONEBIT  = CLK_FREQ/UART_BPS;
localparam HAFTBIT = CLK_FREQ/UART_BPS/2;
/* 检测下降沿 -------------------------*/
reg fall_sign;
always @(posedge in_clk_us)
begin 
	if(!in_rx)
	begin
		if(!receive_state) fall_sign <= 1;//没有接收数据,检测下降沿    
	end
	
   if(receive_state) fall_sign <= 0; 
		
end


/* 接收线程 ---------------------------*/
reg [31:0] receive_us_cnt; 
reg error;
reg receive_state; 

always @(posedge in_clk_us)
begin 
	if(fall_sign) //检测到下降沿
	begin
		receive_state <= 1;//开始接收数据
	end
	
	if(receive_state) 
	begin 
		receive_us_cnt <= receive_us_cnt + 1; 
		case(receive_us_cnt)  
			HAFTBIT:	error <= in_rx;//这是起始位,1就是错误数据
			ONEBIT+HAFTBIT:	out_receive_byte[0] <= in_rx; 
			2*ONEBIT+HAFTBIT:	out_receive_byte[1] <= in_rx; 
			3*ONEBIT+HAFTBIT:	out_receive_byte[2] <= in_rx; 
			4*ONEBIT+HAFTBIT:	out_receive_byte[3] <= in_rx; 
			5*ONEBIT:	begin out_receive_update <= 0;end
			5*ONEBIT+HAFTBIT:	out_receive_byte[4] <= in_rx; 
			6*ONEBIT+HAFTBIT:	out_receive_byte[5] <= in_rx; 
			7*ONEBIT+HAFTBIT:	out_receive_byte[6] <= in_rx; 
			8*ONEBIT+HAFTBIT:	out_receive_byte[7] <= in_rx; 
			9*ONEBIT+HAFTBIT:	begin if(!error) if(in_rx) out_receive_update <= 1; end//如果接收成功,产生一个上升沿
            10*ONEBIT:	begin receive_us_cnt <= 0; receive_state <= 0; end //完成接收  
		endcase
	end
	 
end


/* 发送线程 ---------------------------*/
reg [31:0] send_us_cnt;  
reg send_state; 


always @(posedge in_clk_us)
begin 
	if(in_send_update == 1) //检测到上升沿
	begin
		send_state = 1;//开始接收数据
	end
	
	if(send_state == 1) 
	begin 
		send_us_cnt = send_us_cnt + 1; 
        case(send_us_cnt)
            1:		begin out_tx <= 0;end//起始位 
            ONEBIT+1:	out_tx <= in_send_byte[0]; 
            2*ONEBIT+1:	out_tx <= in_send_byte[1]; 
            3*ONEBIT+1:	out_tx <= in_send_byte[2]; 
            4*ONEBIT+1:	out_tx <= in_send_byte[3]; 
            5*ONEBIT+1:	out_tx <= in_send_byte[4]; 
            6*ONEBIT+1:	out_tx <= in_send_byte[5]; 
            7*ONEBIT+1:	out_tx <= in_send_byte[6]; 
            8*ONEBIT+1:	out_tx <= in_send_byte[7]; 
            9*ONEBIT+1:	out_tx <= 1;//停止位
            9*ONEBIT+HAFTBIT+1:	begin send_us_cnt = 0; send_state = 0; end //完成发送
        endcase 
	end 
end
 







endmodule
/*******************************(C) COPYRIGHT 2017 Wind（谢玉伸）*********************************/





