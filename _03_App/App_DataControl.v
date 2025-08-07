/*******************************(C) COPYRIGHT 2019 Teemo (Chen Xiaodong)*********************************/
/**============================================================================
* @FileName    : App_DataControl.v
* @Description : Read real-time ADC data, store to FIFO, and send via UART
* @Date        : 2019/7/22
* @By          : Teemo (Chen Xiaodong)
* @Email       : 
* @Platform    : Quartus Prime 18.0 (64-bit) (EP4CE22E22C8)
* @Explain     : Controls data transfer between ADC and UART
*=============================================================================*/

/**
 * Data Control Application Module
 * Main controller for ADC data acquisition and UART transmission.
 * Supports multiple sampling modes:
 * - Real-time 1kHz sampling (in_sample_rate_select[1] = 1)
 * - Equivalent 10MHz sampling (in_sample_rate_select = 2'b01) 
 * - Equivalent 200MHz sampling (in_sample_rate_select = 2'b00)
 */ 
/* Interface Setup ------------------*/
module App_DataControl
( 
    input       in_rst,                    // Reset signal, active low
    input       in_clk,                    // Main system clock
    input       in_clk_200M,               // 200MHz high-speed clock
    input       in_clk_10M,                // 10MHz medium-speed clock
    input       in_clk_1k,                 // 1kHz low-speed clock
    input       in_trigger_n,              // External trigger signal, active low
    input[9:0]  in_addata,                 // 10-bit ADC input data
    input       in_request_n,              // Sampling request signal, active low
    input[1:0]  in_sample_rate_select,     // Sample rate selection bits
    
    // UART interface
    output      out_uart_txd,              // UART transmit data output
    
    output      out_adc_clk,               // ADC sampling clock output
    output      out_measure_hold_sig       // Sampling hold signal output
);

//in_sample_rate_select[1]: 1=1kHz real-time sampling, 0=equivalent sampling
//in_sample_rate_select[0]: 1=10MHz equivalent sampling, 0=200MHz equivalent sampling (valid when [1]=0)

// Sampling control signals
wire measure_sig;

/**
 * Sample Control Module
 * Manages sampling timing, trigger detection, and clock generation
 * for different sampling modes (real-time vs equivalent sampling)
 */
sample_control u_sample_control
( 
    .in_rst(in_rst),
    .in_clk(in_clk),
    .in_clk_200M(in_clk_200M),
    .in_clk_10M(in_clk_10M),
    .in_clk_1k(in_clk_1k),
    .in_trigger_n(in_trigger_n),
    .in_request_n(in_request_n),
    .in_sample_rate_select(in_sample_rate_select),
    
    .out_adc_clk(out_adc_clk),
    .out_measure_hold_sig(out_measure_hold_sig),
    .out_measure_sig(measure_sig)
);


// FIFO control signals
wire out_uart_send_sig;     // UART send completion signal
wire uart_send_start;       // UART send start signal  
wire [7:0]fifo_data2uart;   // 8-bit data from FIFO to UART
wire uart_start_sig;        // UART transmission start signal

/**
 * FIFO Control Module  
 * Manages data buffering between ADC sampling and UART transmission.
 * Controls FIFO write/read operations and data flow timing.
 */
fifo_control u_fifo_control
(
    .in_rst(in_rst),
    .in_clk(in_clk),
    .fifo_enable(~in_sample_rate_select[1]),
    .measure_sig(measure_sig),
    .measure_adc_clk(out_adc_clk),
    .in_uart_send_sig(out_uart_send_sig),
    .in_uart_send_start(uart_send_start),
    .in_addata(in_addata[9:2]), 
    .out_fifo_data(fifo_data2uart),
    .out_fifo_end_sig(uart_start_sig)
);

// Force send mode for real-time sampling
wire uart_force_send;
assign uart_force_send = in_sample_rate_select[1] ? in_clk_1k : 1'b0 ;

// Data multiplexing for different sampling modes  
wire [7:0] uart_data;
assign uart_data = in_sample_rate_select[1] ? in_addata[9:2] : fifo_data2uart ;

/**
 * UART Send Control Module
 * Coordinates UART transmission timing and data flow.
 * Handles both real-time direct transmission and FIFO-buffered transmission.
 */
uart_send_control u_uart_send_control
( 
    .in_rst(in_rst),
    .in_clk(in_clk),
    .in_uart_data(uart_data),
    .in_uart_start_sig(uart_start_sig),
    .uart_force_send(uart_force_send),

    .out_uart_txd(out_uart_txd),
    .out_uart_send_sig(out_uart_send_sig),
    .out_uart_send_start(uart_send_start)
);

endmodule
/*******************************(C) COPYRIGHT 2019 Teemo (Chen Xiaodong)*********************************/



