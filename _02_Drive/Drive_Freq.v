 module  Drive_Freq
(
	  input   Freq_clk
    ,input   in_clk_50M 
    ,input   in_clr  //复位
    ,input   Sig_in //被测信号
	 
    ,output  reg [31:0]   data_fx
);

parameter T_1s = 28'd49_999_999;
//————————————————————————
//          预置闸门    产生一个1S的方波
reg [27:0]  TCount;//预置阀门记数值
always @ (posedge in_clk_50M or negedge in_clr)
    if(!in_clr)
        TCount <= 28'd0;
    else if(TCount >= T_1s)
        TCount <= 28'd0;
    else
        TCount <= TCount + 1'b1;

reg TCountCnt;//in_clr
always @ (posedge in_clk_50M or negedge in_clr)
    if(!in_clr)
        TCountCnt <= 1'b0;
    else if(TCount >= T_1s)
        TCountCnt <= ~TCountCnt;

//————————————————————————
//          实际闸门
reg startCnt;//实际阀门
always @ (posedge Sig_in)//被测信号为上升沿
    if(TCountCnt == 1'b1)
        startCnt <= 1'b1;
    else
        startCnt <= 1'b0;

//————————————————————————
//          在实际闸门中计数
reg [31:0]  SigTemp;
reg [1:0]  flag_cnt;
always @ (posedge in_clk_50M)
	flag_cnt <= (flag_cnt+1)%2;
	
	
	
always @ (posedge Sig_in )//被测信号为下降沿
    if(startCnt == 1'b1)//实际阀门为高电平
        SigTemp <= SigTemp + 1'b1;
    else
        SigTemp <= 'd0;
	  
//————————————————————————
//          锁存输出
always @ (negedge startCnt)//实际阀门为下降沿时送出频率
    data_fx <= SigTemp;
	

endmodule