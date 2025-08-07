/*******************************(C) COPYRIGHT 2017 Wind (Xie Yushen)*********************************/
/**============================================================================
* @FileName    : Drive_Clock.v
* @Description : Clock generation module
* @Date        : 2017/4/16
* @By          : Wind (Xie Yushen)
* @Email       : 1659567673@ qq.com
* @Platform    : Quartus II 15.0 (64-bit) (EP4CE22E22C8)
* @Explain     : Provides us, ms, and s level clock signal sources
*=============================================================================*/

/**
 * Clock Divider Module
 * Generates multiple clock frequencies from 50MHz input:
 * - 1MHz (us level): 50 cycles per toggle
 * - 1kHz (ms level): 50,000 cycles per toggle  
 * - 50Hz (20ms level): 1,000,000 cycles per toggle
 * - 1Hz (s level): 50,000,000 cycles per toggle
 */ 
module Drive_Clock
(
    input in_clk_50M,    // 50MHz input clock
    input in_rst,        // Reset signal, active low

    output out_clk_us,   // 1MHz output (microsecond level)
    output out_clk_ms,   // 1kHz output (millisecond level) 
    output reg  out_clk_20ms,  // 50Hz output (20 millisecond level)
    output out_clk_s     // 1Hz output (second level)
);

/* Register Configuration -----------*/
reg [31:0]time_20ns;  // 20ns level counter (based on 50MHz = 20ns period)
reg clk_us;           // Microsecond level clock register
reg clk_ms;           // Millisecond level clock register  
reg clk_s;            // Second level clock register
 
/* Connect Output Registers ---------*/
assign out_clk_us = clk_us; 
assign out_clk_ms = clk_ms;  
assign out_clk_s = clk_s;  
 
 
/* Main Clock Generation Logic ------*/
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
			if(time_20ns%(50/2) == 0) clk_us = ~clk_us;           // Toggle every 25 cycles (1MHz)
			if(time_20ns%(50000/2) == 0) clk_ms = ~clk_ms;        // Toggle every 25,000 cycles (1kHz)
			if(time_20ns%(1000000/2) == 0) out_clk_20ms = ~out_clk_20ms; // Toggle every 500,000 cycles (50Hz)
			if(time_20ns == (50000000/2)) clk_s = ~clk_s;         // Toggle every 25,000,000 cycles (1Hz)
		end
end

 
 
endmodule
/*******************************(C) COPYRIGHT 2017 Wind (Xie Yushen)*********************************/














