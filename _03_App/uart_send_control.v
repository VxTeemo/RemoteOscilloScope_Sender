/**
 * UART Send Control Module
 * Coordinates UART transmission timing and data flow control.
 * Handles both FIFO-buffered data transmission and real-time force send mode.
 * 
 * Key Features:
 * - Configurable transmission count (405 data samples)
 * - Force send capability for real-time sampling mode
 * - Automatic byte-by-byte transmission control
 * - Status signaling for data flow synchronization
 */
module uart_send_control
( 
    input       in_rst,                // Reset signal, active low
    input       in_clk,                // Main system clock
    input[7:0]  in_uart_data,          // 8-bit data to be transmitted
    input       in_uart_start_sig,     // Start signal for transmission sequence
    input       uart_force_send,       // Force send mode (for real-time sampling)
    
    // UART interface
    output      out_uart_txd,          // UART transmit data output
    output      out_uart_send_sig,     // Send signal to external modules
    output      out_uart_send_start    // Send start signal to external modules
);
assign out_uart_send_sig = uart_send_sig;
assign out_uart_send_start = uart_send_start;

//Parameter Definitions
parameter  DATA_NUM = 10'd405;          // Number of data samples to transmit

//UART Configuration Parameters  
parameter  CLK_FREQ = 200000000;        // System clock frequency (200MHz)
parameter  UART_BPS = 115200;           // UART baud rate (115200 bps)

//Internal Signal Definitions   
wire        uart_en_w;                  // UART transmission enable
wire        uart_send_once_done;        // Single byte transmission completion

assign      uart_en_w = uart_send_sig | uart_force_send;

/**
 * UART Send Module Instance
 * Low-level UART transmission module with configurable baud rate
 */
uart_send #(                            // UART transmission module
    .CLK_FREQ       (CLK_FREQ),         // Set system clock frequency
    .UART_BPS       (UART_BPS))         // Set UART transmission baud rate
u_uart_send(                 
    .sys_clk        (in_clk),
    .sys_rst_n      (in_rst),
    
    .uart_en        (uart_en_w),
    .uart_din       (in_uart_data),
    .uart_txd       (out_uart_txd),
    .done_flag      (uart_send_once_done)
);

// Control Registers and Counters
reg         uart_send_start;            // UART transmission start control
reg [9:0]   uart_send_cnt;              // Transmitted data counter

reg in_uart_start_sig_d;                // Delayed start signal for edge detection
always @(posedge in_clk)
    in_uart_start_sig_d <= in_uart_start_sig;

/**
 * UART Send Start Control
 * Controls uart_send_start signal and overall transmission state
 */
always @(posedge in_clk)
begin
    if(in_uart_start_sig == 0 && in_uart_start_sig_d == 1) begin // Detect transmission start signal
        uart_send_start <= 1;
    end
    else if(uart_send_cnt == DATA_NUM) begin
        uart_send_start <= 0;
    end
    else
        uart_send_start <= uart_send_start;
end

reg uart_send_once_done_d;              // Delayed completion signal for edge detection
always @(posedge in_clk)
    uart_send_once_done_d <= uart_send_once_done;

/**
 * Transmission Counter
 * Counts number of bytes transmitted, increments after each byte completion
 */
always @(posedge in_clk)
begin
    if(uart_send_start) begin
        if(uart_send_once_done == 1 && uart_send_once_done_d == 0) // UART single byte transmission completion rising edge
            uart_send_cnt <= uart_send_cnt + 1'b1;
    end
    else
        uart_send_cnt <= 0;
end

// Delayed Send State Signals
reg uart_send_sig;                      // Send signal for low-level UART module
reg uart_send_start_d0;                 // First stage delay of start signal
reg uart_send_start_d1;                 // Second stage delay of start signal

always @(posedge in_clk) begin
    uart_send_start_d0 <= uart_send_start;
    uart_send_start_d1 <= uart_send_start_d0;
end

/**
 * UART Send Signal Generation
 * Generates send pulses for the low-level UART transmission module
 */
always @(posedge in_clk)
begin
    if(uart_send_start) begin
        if(uart_send_start_d0 == 1 && uart_send_start_d1 == 0) begin // UART transmission start, delay one clock
            uart_send_sig <= 1;
        end
        else if(uart_send_once_done == 1 && uart_send_once_done_d == 0) begin
            uart_send_sig <= 1;
        end
        else
            uart_send_sig <= 0;
    end
    else
        uart_send_sig <= 0;
end

endmodule
