/*******************************(C) COPYRIGHT 2019 Teemo（陈晓东）*********************************/
/**============================================================================
* @FileName    : App_fsk_signal.v
* @Description : FSK调制模块
* @Date        : 2019/4/23
* @By          : Teemo（陈晓东）
* @Email       : 
* @Platform    : Quartus Prime 18.0 (64-bit) (EP4CE22E22C8)
* @Explain     : FSK的应用程序
*=============================================================================*/ 
/* 设置接口 ---------------------------*/
module App_FSK
( 
	input in_clr     
	,input in_clk     
	,input[9:0] in_ADFIFO  
	,input in_rdFIFOempty
    ,input[4:0] DS18B20_Input
    
	,output reg out_rdFIFOclk   
	,output reg out_rdFIFOreq
	,output reg fsk_data
	,output out_FSK
	 
);	 

/* 寄存器配置 -------------------------*/
reg fsk_signal;//fsk_signal
reg [6:0]fsk_wave_cnt;
reg [3:0]fsk_switch_cnt;
reg [9:0]output_data;
reg [9:0]old_output_data;
reg [7:0]output_data_cnt;
reg [8:0]send_data_cnt;


/* 连接输出 ---------------------------*/
assign out_FSK = fsk_signal;
//assign fsk_data = output_data[0];
/* 运行线程 ---------------------------*/
always @(posedge in_clk or negedge in_clr)// or posedge sig_20msclk or posedge ack_20msclk
begin   
	if(in_clr == 0) 
	begin
		fsk_signal = 0;
        output_data = 10'b1010101010;    //01001010    10110101   01001010
        output_data_cnt <= 0;
        out_rdFIFOreq <= 0;
	end
	
    else
    
    begin
        //out_rdFIFOreq <= 1;
        
        if(fsk_data==1)   //1发送500k,高电平
        begin
            fsk_wave_cnt <= (fsk_wave_cnt + 1)%100; //25 500k 1us切换一次电平 2us一个周期
        end
        else
        begin
            fsk_wave_cnt <= (fsk_wave_cnt + 1)%125; //20 400k 1.25us切换一次电平 2.5us一个周期
        end
        
        
        if(fsk_wave_cnt == 0) //计数半次波形结束，需要切换电平 
        begin
            fsk_switch_cnt = fsk_switch_cnt + 1;
            fsk_signal = ~fsk_signal;
           
            if((fsk_data==0 && fsk_switch_cnt==8) || (fsk_data==1 && fsk_switch_cnt==10)) //一个位的数据发送结束，需要切换下一位数据
            begin                                                                         //10us 4/5次完整周期 100k
                fsk_switch_cnt = 0;
                output_data_cnt <= (output_data_cnt + 1)%10;
                //fsk_data = 1;
                //fsk_data <= !fsk_data;
                fsk_data <= output_data[0];
                output_data <= (output_data>>1);
                
                if(output_data_cnt == 0) //一串数据发送结束,100us    10bit 10k 100us 0.1ms*160=16ms
                begin
                    send_data_cnt <= (send_data_cnt+1)%100;   //100 10ms/cycle
                    
                    
                    if(send_data_cnt < 1)//5
                    begin
                        output_data <= 10'b0111111111;//10'b0000000000;
                        out_rdFIFOreq <= 0;
                    end
                    
                    else if(send_data_cnt < 2)//5
                    begin
                        output_data <= (DS18B20_Input<<5)|5'b10101;// 10101       10'b0101010101;//10'b0000000000;
                        out_rdFIFOreq <= 0;
                    end
                    
                    else if(send_data_cnt < 82)//161   80
                    begin
                        if(in_rdFIFOempty)
                        begin
                            output_data <= old_output_data;
                            out_rdFIFOreq <= 0;
                        end
                        else
                        begin
                            out_rdFIFOreq <= 1;
                            out_rdFIFOclk <= 1;
                            output_data <= in_ADFIFO;//10'b1110100001;//
                            old_output_data <= in_ADFIFO;//10'b1110100001;//
                        end
                    end
                    
                    else
                    begin
                        output_data <= 10'b1111111111;
                        out_rdFIFOreq <= 0;
                    end
                    
                    
                    //out_rdFIFOreq <= 1;
                    //output_data = in_ADFIFO;
                end
            end
            
        
        end    
        
            

    
    end
    
	
end 
  
  
  


endmodule
/*******************************(C) COPYRIGHT 2019 Teemo（陈晓东）*********************************/



