/*******************************(C) COPYRIGHT 2017 Wind（谢玉伸）*********************************/
/**============================================================================
* @FileName    : App_Led.v
* @Description : Led灯
* @Date        : 2017/4/16
* @By          : Wind（谢玉伸）
* @Email       : 1659567673@ qq.com
* @Platform    : Quartus II 15.0 (64-bit) (EP4CE22E22C8)
* @Explain     : Led的应用程序
*=============================================================================*/ 
/* 设置接口 ---------------------------*/
module App_Led
( 
	input in_rst     
	,input in_clk_ms     
	
	,output[3:0] out_led
);	 

/* 寄存器配置 -------------------------*/
reg [3:0]led = 4'b0001;//LED灯
reg [15:0]cnt; 
parameter Flash_Delay = 16'd100;
/* 连接输出 ---------------------------*/
assign out_led = led;
integer i;
/* 运行线程 ---------------------------*/
always @(posedge in_clk_ms or negedge in_rst)
begin   
	if(in_rst == 0) begin
		led <= 4'b0111; 
	end
	else begin
        cnt <= (cnt + 1'd1)%(16'd4*Flash_Delay); 
        for( i=0; i<4; i=i+1) begin
            if(cnt == i*Flash_Delay) begin 
                led <= 4'b1111 &~ (4'b1000 >> i);
            end
        end
	end
	
end 
  

endmodule
/*******************************(C) COPYRIGHT 2017 Wind（谢玉伸）*********************************/







