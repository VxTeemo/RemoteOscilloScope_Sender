/*******************************(C) COPYRIGHT 2017 Wind (Xie Yushen)*********************************/
/**============================================================================
* @FileName    : Drive_ADC.v
* @Description : ADC interface module
* @Date        : 2017/5/1
* @By          : Wind (Xie Yushen)
* @Email       : 1659567673@ qq.com
* @Platform    : Quartus II 15.0 (64-bit) (EP4CE22E22C8)
* @Explain     : ADC data acquisition with bit reordering for specific chip configuration
*=============================================================================*/

/**
 * ADC Interface Module
 * Handles 10-bit ADC data acquisition with proper bit order mapping.
 * Provides output enable control and bit reversal to match ADC chip layout.
 */ 
module Drive_ADC
(   
    input in_rst,                // Reset signal, active low
    input in_clk,                // ADC sampling clock
    input [9:0]in_ADC_data,      // 10-bit ADC input data

    output reg out_OE_n,         // ADC output enable, active low    
    output reg [9:0]out_ADC_data // 10-bit processed ADC output data
);

/**
 * ADC Data Processing Logic
 * - Enables ADC output (OE_n = 0) 
 * - Reverses bit order to match ADC chip configuration
 * - Maps input bits [9:0] to output bits [0:9] (MSB to LSB swap)
 */
always @(negedge in_rst or posedge in_clk)
begin
    if(in_rst == 0)
    begin
        out_ADC_data <= 10'b0;
        out_OE_n <= 1;	        // Disable ADC output during reset
    end
    else
	begin 
        out_OE_n <= 0;          // Enable ADC output
    
		// Bit order reversal for ADC chip compatibility
		out_ADC_data[9] <= in_ADC_data[0];
		out_ADC_data[8] <= in_ADC_data[1];
		out_ADC_data[7] <= in_ADC_data[2];
		out_ADC_data[6] <= in_ADC_data[3];
		out_ADC_data[5] <= in_ADC_data[4];
		out_ADC_data[4] <= in_ADC_data[5];
		out_ADC_data[3] <= in_ADC_data[6];
		out_ADC_data[2] <= in_ADC_data[7];
		out_ADC_data[1] <= in_ADC_data[8];
		out_ADC_data[0] <= in_ADC_data[9];
	end
end
	
	
	
	
	
	
endmodule

/*******************************(C) COPYRIGHT 2017 Wind (Xie Yushen)*********************************/













