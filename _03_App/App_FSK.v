/*******************************(C) COPYRIGHT 2019 Teemo (Chen Xiaodong)*********************************/
/**============================================================================
* @FileName    : App_FSK.v
* @Description : FSK modulation module
* @Date        : 2019/4/23
* @By          : Teemo (Chen Xiaodong)
* @Email       : 
* @Platform    : Quartus Prime 18.0 (64-bit) (EP4CE22E22C8)
* @Explain     : FSK modulation application for data transmission
*=============================================================================*/

/**
 * FSK Modulation Module
 * Implements Frequency Shift Keying (FSK) modulation for data transmission.
 * Modulates digital data onto carrier frequencies:
 * - Logic '1': 500kHz carrier (2us period)  
 * - Logic '0': 400kHz carrier (2.5us period)
 * 
 * Features:
 * - 10-bit data frame transmission
 * - FIFO data reading interface
 * - Temperature sensor data integration
 * - Configurable transmission timing
 */ 
/* Interface Setup ------------------*/
module App_FSK
( 
	input in_clr,                   // Reset signal, active low     
	input in_clk,                   // System clock input    
	input[9:0] in_ADFIFO,           // 10-bit data from FIFO  
	input in_rdFIFOempty,           // FIFO empty flag
    input[4:0] DS18B20_Input,       // 5-bit temperature sensor input
    
	output reg out_rdFIFOclk,       // FIFO read clock   
	output reg out_rdFIFOreq,       // FIFO read request
	output reg fsk_data,            // Current data bit being transmitted
	output out_FSK                  // FSK modulated output signal
);	 

/* Register Configuration -----------*/
reg fsk_signal;                 // FSK carrier signal output
reg [6:0]fsk_wave_cnt;          // Wave generation counter for carrier frequency
reg [3:0]fsk_switch_cnt;        // Counter for level switching within each bit
reg [9:0]output_data;           // Current 10-bit data frame being transmitted
reg [9:0]old_output_data;       // Previous data frame (for repeat on FIFO empty)
reg [7:0]output_data_cnt;       // Bit counter within current data frame
reg [8:0]send_data_cnt;         // Frame counter for transmission sequence

/* Output Connections ---------------*/
assign out_FSK = fsk_signal;
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



