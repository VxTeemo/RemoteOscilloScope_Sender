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
			52:	error <= in_rx;//这是起始位,1就是错误数据
			156:	out_receive_byte[0] <= in_rx; 
			260:	out_receive_byte[1] <= in_rx; 
			364:	out_receive_byte[2] <= in_rx; 
			468:	out_receive_byte[3] <= in_rx; 
			500:	begin out_receive_update <= 0;end
			572:	out_receive_byte[4] <= in_rx; 
			676:	out_receive_byte[5] <= in_rx; 
			780:	out_receive_byte[6] <= in_rx; 
			884:	out_receive_byte[7] <= in_rx; 
			988:	begin if(!error) if(in_rx) out_receive_update <= 1; end//如果接收成功,产生一个上升沿
		   1039:	begin receive_us_cnt <= 0; receive_state <= 0; end //完成接收  
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
            105:	out_tx <= in_send_byte[0]; 
            209:	out_tx <= in_send_byte[1]; 
            313:	out_tx <= in_send_byte[2]; 
            417:	out_tx <= in_send_byte[3]; 
            521:	out_tx <= in_send_byte[4]; 
            625:	out_tx <= in_send_byte[5]; 
            729:	out_tx <= in_send_byte[6]; 
            833:	out_tx <= in_send_byte[7]; 
            937:	out_tx <= 1;//停止位
           1000:	begin send_us_cnt = 0; send_state = 0; end //完成发送
        endcase 
	end 
end
 







endmodule
/*******************************(C) COPYRIGHT 2017 Wind（谢玉伸）*********************************/





