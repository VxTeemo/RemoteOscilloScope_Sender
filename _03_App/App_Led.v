/*******************************(C) COPYRIGHT 2017 Wind (Xie Yushen)*********************************/
/**============================================================================
* @FileName    : App_Led.v
* @Description : LED indicator control module
* @Date        : 2017/4/16
* @By          : Wind (Xie Yushen)
* @Email       : 1659567673@ qq.com
* @Platform    : Quartus II 15.0 (64-bit) (EP4CE22E22C8)
* @Explain     : LED application for visual system status indication
*=============================================================================*/

/**
 * LED Application Module
 * Creates a flowing LED pattern to indicate system operation status.
 * Uses 4 LEDs in a sequential pattern with configurable timing.
 */ 
/* Interface Setup ------------------*/
module App_Led
( 
	input in_rst,           // Reset signal, active low    
	input in_clk_ms,        // Millisecond clock input     
	
	output[3:0] out_led     // 4-bit LED output bus
);	 

/* Register Configuration -----------*/
reg [3:0]led = 4'b0001;         // LED state register, initialized to first LED on
reg [15:0]cnt;                  // Counter for timing control
parameter Flash_Delay = 16'd100; // Flash delay parameter (100ms intervals)

/* Connect Output -------------------*/
assign out_led = led;

// Loop variable for LED pattern generation
integer i;
/* Main LED Control Logic -----------*/
/**
 * Creates a flowing LED pattern where each LED lights up sequentially.
 * Pattern: LED0 -> LED1 -> LED2 -> LED3 -> repeat
 * Each LED stays on for Flash_Delay milliseconds before moving to the next.
 */
always @(posedge in_clk_ms or negedge in_rst)
begin   
	if(in_rst == 0) begin
		led <= 4'b0111;     // Initialize LED pattern during reset
	end
	else begin
        cnt <= (cnt + 1'd1)%(16'd4*Flash_Delay);   // Counter cycles through 4 LED positions
        for( i=0; i<4; i=i+1) begin
            if(cnt == i*Flash_Delay) begin 
                led <= 4'b1111 &~ (4'b1000 >> i);  // Light up LED i, turn off others
            end
        end
	end
end 
  

endmodule
/*******************************(C) COPYRIGHT 2017 Wind (Xie Yushen)*********************************/







