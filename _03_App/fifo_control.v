/**
 * FIFO Control Module
 * Manages data buffering between ADC sampling and UART transmission.
 * Controls FIFO read/write operations, timing, and data flow coordination.
 * 
 * Key Features:
 * - Dual-clock FIFO interface (write on ADC clock, read on UART clock)
 * - Automatic read/write enable control based on sampling and transmission states
 * - Data count management and overflow protection
 * - Synchronization between measurement and transmission phases
 */
module fifo_control
(
    input       in_rst,                // Reset signal, active low
    input       in_clk,                // Main system clock
    input       fifo_enable,           // FIFO operation enable
    input       measure_sig,           // Measurement active signal
    input       measure_adc_clk,       // ADC measurement clock
    input       in_uart_send_start,    // UART transmission start signal
    input       in_uart_send_sig,      // UART transmission active signal
    input[7:0]  in_addata,             // 8-bit ADC data input
    output[7:0] out_fifo_data,         // 8-bit FIFO data output
    output      out_fifo_end_sig       // FIFO transmission end signal
);
assign out_fifo_end_sig = fifo_enable ? fifo_rdclk_mess_start : 1'b0;

//Parameter Definitions
parameter  DATA_NUM = 10'd405;          // Number of data samples to process

//FIFO Interface Signals for Storage and UART Transmission
wire fifo_rdclk;        // FIFO read clock
wire fifo_rdreq;        // FIFO read request
wire fifo_wrclk;        // FIFO write clock  
wire fifo_wrreq;        // FIFO write request

wire rdempty_sig;       // FIFO read empty flag
wire wrfull_sig;        // FIFO write full flag  
wire wrusedw_sig;       // FIFO write used words count
wire rdusedw_sig;       // FIFO read used words count

// FIFO Control Logic - Clock and Request Multiplexing
assign fifo_rdclk = fifo_enable ? (fifo_rdclk_sig | in_uart_send_sig) : 1'b0;
assign fifo_rdreq = fifo_enable ? (in_uart_send_start | fifo_rdclk_mess_start) : 1'b0;
assign fifo_wrclk = fifo_enable ? measure_adc_clk : 1'b0;
assign fifo_wrreq = fifo_enable ? measure_sig : 1'b0;

/**
 * Dual-Clock FIFO Instance
 * Provides data buffering between different clock domains
 * Write side: ADC measurement clock domain
 * Read side: UART transmission clock domain
 */

fifo_addata u_fifo_addata (
    .data ( in_addata ),
    .rdclk ( fifo_rdclk ),
    .rdreq ( fifo_rdreq ),
    .wrclk ( fifo_wrclk ),
    .wrreq ( fifo_wrreq ),
    .q ( out_fifo_data ),
    .rdempty ( rdempty_sig ),
    .rdusedw ( rdusedw_sig ),
    .wrfull ( wrfull_sig ),
    .wrusedw ( wrusedw_sig )
    );

reg measure_sig_d;
always @(posedge in_clk)
    measure_sig_d <= measure_sig;

reg         fifo_rdclk_sig;
reg         fifo_rdclk_mess_start;
reg [9:0]   fifo_rdclk_mess_cnt;

always @(posedge in_clk)
begin
    if(measure_sig == 0 && measure_sig_d == 1 && fifo_enable) begin // Detect measurement signal falling edge (measurement end signal)
        fifo_rdclk_mess_start <= 1;
    end
    else if(fifo_rdclk_mess_cnt == 110) begin
        fifo_rdclk_mess_start <= 0;
    end
    else begin
        fifo_rdclk_mess_start <= fifo_rdclk_mess_start;
    end
end

always @(posedge in_clk)
begin
    if(fifo_rdclk_mess_start)
        fifo_rdclk_mess_cnt <= fifo_rdclk_mess_cnt + 1'b1;
    else
        fifo_rdclk_mess_cnt <= 0;
end

always @(posedge in_clk)
begin
    if(fifo_rdclk_mess_start) begin
        case(fifo_rdclk_mess_cnt)
            10,30,50,70,90: begin
                fifo_rdclk_sig <= 1;
            end
            20,40,60,80,100 :begin
                fifo_rdclk_sig <= 0;
            end
            default: begin
                fifo_rdclk_sig <= fifo_rdclk_sig;
            end
        endcase
    end
    else
        fifo_rdclk_sig <= 0;
end



endmodule
