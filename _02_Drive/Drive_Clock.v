/*******************************(C) COPYRIGHT 2017 Wind（谢玉伸）*********************************/
/**============================================================================
* @FileName    : Drive_Clock.v
* @Description : 时钟文件
* @Date        : 2017/4/16
* @By          : Wind（谢玉伸）
* @Email       : 1659567673@ qq.com
* @Platform    : Quartus II 15.0 (64-bit) (EP4CE22E22C8)
* @Explain     : 提供us、ms、s的时钟信号源
*=============================================================================*/ 
module Drive_Clock
(
    input in_clk_50M    
    ,input in_rst 

    ,output out_clk_us 
    ,output out_clk_ms
    ,output reg  out_clk_20ms
    ,output out_clk_s  
);

/* 寄存器配置 -------------------------*/
reg [31:0]time_20ns;//20ns级的计时器
//reg [31:0]time_20ns_2;//20ns级的计时器
reg clk_us;//us级的时钟 
reg clk_ms;//ms级的时钟 
reg clk_s;//s级的时钟 
 
/* 连接寄存器 ---------------------------*/
assign out_clk_us = clk_us; 
assign out_clk_ms = clk_ms;  
assign out_clk_s = clk_s;  
 
 
/* 运行线程 ---------------------------*/
always @(posedge in_clk_50M or negedge in_rst)
begin 
    if(in_rst == 0) 
		begin
			time_20ns = 0;
			clk_us = 0;
			clk_ms = 0;
            out_clk_20ms = 0;
			clk_s = 0;
		end
	 else 
		begin
			time_20ns <= (time_20ns + 1)%500000000; 
			if(time_20ns%(50/2) == 0) clk_us = ~clk_us;
			if(time_20ns%(50000/2) == 0) clk_ms = ~clk_ms;
			if(time_20ns%(1000000/2) == 0) out_clk_20ms = ~out_clk_20ms; 
			if(time_20ns == (50000000/2)) clk_s = ~clk_s; 
		end
end

 
 
endmodule
/*******************************(C) COPYRIGHT 2017 Wind（谢玉伸）*********************************/














