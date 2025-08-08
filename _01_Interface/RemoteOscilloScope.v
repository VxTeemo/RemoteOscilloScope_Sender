 /*******************************(C) COPYRIGHT 2019 Teemo (Chen Xiaodong)*********************************/
/**============================================================================
* @FileName    : RemoteOscilloScope.v
* @Description : Top-level interface module
* @Date        : 2019/7/22
* @By          : Teemo (Chen Xiaodong)
* @Email       : 
* @Platform    : Quartus Prime 18.0 (64-bit) (EP4CE22E22C8)
* @Explain     : Main top-level interface for remote oscilloscope system
*=============================================================================*/   
/**
 * Top-level interface module for Remote Oscilloscope Sender
 * Integrates clock generation, ADC data acquisition, UART communication,
 * frequency measurement, LED indicators, and sampling control
 */
module RemoteOscilloScope
( 
    /* Clock and Control Inputs -----*/
    input       clk_50M,                // 50MHz main input clock
    input       rst,                    // Global reset signal, active low
    input       in_key,                 // Sampling request key
    input       in_request_n,           // Sampling request signal, active low
    input[1:0]  in_sample_rate_select,  // Sample rate selection {1kHz, 10MHz, 200MHz}
    
    /* LED Output --------------------*/
    output[3:0] led_bus,                // 4-bit LED status indicators

    /* ADC Interface -----------------*/
    input [9:0] in_ADC_data,            // 10-bit ADC parallel data input
    output      out_OE_n,               // ADC output enable, active low
    output      out_clk_ADC,            // ADC sampling clock
    
    /* UART Data Output --------------*/    
    output      out_uart_txd,           // UART transmit data for ADC samples
    
    /* Trigger Signal ----------------*/
    input       in_trigger_n,           // External trigger signal, active low
    output      out_measure_hold_sig,   // Sampling hold signal output
    
    /* Frequency Measurement ---------*/
    output      out_freq_uart_tx,       // UART transmit for frequency measurement
    
    /* Clock Output ------------------*/
    output      out_clk_100k            // 100kHz output clock
);

/* Clock Generation Module ---------*/
// Internal clock signals for different timing requirements
wire out_clk_us;        // Microsecond clock
wire out_clk_ms;        // Millisecond clock  
wire out_clk_20ms;      // 20 millisecond clock
wire out_clk_s;         // Second clock

/**
 * Clock divider module - generates multiple clock frequencies
 * from the main 50MHz input clock for system timing
 */

Drive_Clock u_Drive_Clock
(  
    .in_clk_50M(clk_50M),
    .in_rst(rst),

    .out_clk_us(out_clk_us),
    .out_clk_ms(out_clk_ms),
    .out_clk_20ms(out_clk_20ms), 
    .out_clk_s(out_clk_s) 
);

// PLL-generated high-speed clocks
wire out_clk_200M;      // 200MHz high-speed sampling clock
wire out_clk_10M;       // 10MHz medium-speed sampling clock

/**
 * Phase-Locked Loop (PLL) module - generates high-frequency clocks
 * from 50MHz input for high-speed ADC sampling operations
 */
Drive_PLL u_Drive_PLL
(
   .inclk0(clk_50M),
   .c0(out_clk_200M),
   .c1(out_clk_10M),
   .c2(out_clk_100k)
);

// ADC data interface signals  
wire [9:0]out_ADC_data;   // Processed ADC data output

/**
 * ADC interface module - handles 10-bit ADC data acquisition
 * with proper bit ordering and output enable control
 */
Drive_ADC u_Drive_ADC
(
    .in_rst(rst),
    .in_clk(out_clk_ADC),
    .in_ADC_data(in_ADC_data),

    .out_OE_n(out_OE_n),
    .out_ADC_data(out_ADC_data)
);

// ADC clock selection logic
wire out_adc_clk;        // Internal ADC clock signal
// Select between 100kHz (real-time) or high-speed (equivalent sampling) clock
assign out_clk_ADC = in_sample_rate_select[1] ? out_clk_100k : out_adc_clk;

/**
 * Data control module - main data acquisition and transmission controller
 * Manages ADC sampling, FIFO buffering, and UART data transmission
 */
App_DataControl u_App_DataControl
(
    .in_rst(rst),     
    .in_clk(out_clk_200M),     
    .in_clk_200M(out_clk_200M),
    .in_clk_10M(out_clk_10M),
    .in_clk_1k(out_clk_ms),
    .in_addata(out_ADC_data),
    .in_trigger_n(in_trigger_n),
    .in_request_n(in_key & in_request_n),
    .in_sample_rate_select(in_sample_rate_select),

    .out_uart_txd(out_uart_txd),
    
    .out_adc_clk(out_adc_clk),
    .out_measure_hold_sig(out_measure_hold_sig)
);  


/**
 * LED application module - provides visual status indication
 * using flowing LED pattern to show system operation status
 */
 App_Led u_App_Led
(    
    .in_rst(rst), 
    .in_clk_ms(out_clk_ms), 
    .out_led(led_bus)  
);

// Frequency measurement data interface
wire [31:0]data_fx;      // Measured frequency value

/**
 * UART top module for frequency measurement output
 * Transmits frequency measurement results via dedicated UART channel
 */
Drive_Usart_Top Drive_Usart_Top
(
    .in_clk_us(out_clk_us),
    .in_clr(rst),

    .out_set_freq(data_fx),
    .out_tx(out_freq_uart_tx)
);

// Frequency measurement input signal mapping
wire in_freq_sig;
assign in_freq_sig = in_trigger_n;  // Use trigger signal for frequency measurement

/**
 * Frequency measurement module - measures external signal frequency
 * using gate-controlled counting method with 50MHz reference clock
 */
Drive_Freq u_Drive_Freq
(
    .in_clk_50M(clk_50M),             // Reference clock signal (50MHz)
    .in_clr(rst),                     // Reset signal
    .Sig_in(in_freq_sig),             // Input signal to be measured
    .data_fx(data_fx)                 // Measured frequency output
);


endmodule
/*******************************(C) COPYRIGHT 2019 Teemo (Chen Xiaodong)*********************************/





  
  
  
  
  
 
  
  