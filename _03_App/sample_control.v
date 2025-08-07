/**
 * Sample Control Module
 * Controls ADC sampling timing and trigger detection for different sampling modes.
 * Supports both real-time sampling (1kHz) and equivalent sampling (10MHz/200MHz).
 * 
 * Key Features:
 * - Trigger edge detection and delay control
 * - Equivalent sampling with programmable delta-t timing
 * - Sample-and-hold signal generation  
 * - ADC clock generation with precise timing
 */
module sample_control
( 
    input       in_rst,                    // Reset signal, active low
    input       in_clk,                    // Main system clock (200MHz)
    input       in_clk_200M,               // 200MHz high-speed clock
    input       in_clk_10M,                // 10MHz medium-speed clock  
    input       in_clk_1k,                 // 1kHz low-speed clock
    input       in_trigger_n,              // External trigger signal, active low
    input       in_request_n,              // Sampling request signal, active low
    input[1:0]  in_sample_rate_select,     // Sample rate selection
    
    output      out_adc_clk,               // ADC sampling clock output
    output      out_measure_hold_sig,      // Sample-and-hold signal output
    output      out_measure_sig            // Measurement trigger signal output
);
assign out_measure_sig = measure_start;

//Parameter Definitions for Timing Control
parameter  DATA_NUM = 10'd405;             // Number of data samples to collect

parameter  SYS_CLK = 200_000_000;          // System clock frequency (200MHz)
parameter  TRIGGER_DELAY_TIME   = 1_000_000;    // 1M time units (1us)
parameter  TRIGGER_DELAY_CNT    =   10'd200;    // Trigger delay counter limit
parameter  MEASURE_DONE_TIME    = 2_000_000;    // 0.5us timing
parameter  MEASURE_DONE_CNT     =   10'd100;    // Measurement completion counter
parameter  ADC_CLK_DELAY_TIME   = 4_000_000;    // 0.25us timing  
parameter  ADC_CLK_DELAY        =    10'd50;    // ADC clock delay counter

//Alternative parameter calculations (commented)
//localparam TRIGGER_DELAY_CNT    = SYS_CLK / TRIGGER_DELAY_TIME;
//localparam MEASURE_DONE_CNT     = SYS_CLK / MEASURE_DONE_TIME;
//localparam ADC_CLK_DELAY        = SYS_CLK / ADC_CLK_DELAY_TIME;

/* Output Signal Assignments ----------*/
assign out_measure_hold_sig = measure_hold_sig;
assign out_adc_clk = measure_adc_clk;

/* Register Configuration -------------*/

// Trigger signal processing registers
reg in_trigger_d;               // Delayed trigger signal for edge detection
reg trigger_flag;               // Trigger detection flag
wire in_trigger;                // Active-high trigger signal
assign in_trigger = ~in_trigger_n;

/* Main Control Logic ----------------*/
/**
 * Trigger edge detection - registers input for rising edge detection
 */
always @(posedge in_clk)
    in_trigger_d <= in_trigger;

/**
 * Trigger flag generation and control
 * Generates trigger flag on rising edge of trigger signal when enabled
 * Clears flag when measurement starts
 */
always @(posedge in_clk)
begin
    if(measure_start) begin
        if(in_trigger == 1 && in_trigger_d == 0 && trigger_enable) begin // Detect trigger rising edge
            trigger_flag <= 1;
        end
        else if(measure_flag == 1 && measure_flag_d == 0) begin // Detect measure start rising edge
            trigger_flag <= 0;
        end
        else
            trigger_flag <= trigger_flag;
    end
    else begin 
        trigger_flag <= 0;
    end
end

// Trigger enable control registers  
reg trigger_flag_d;             // Delayed trigger flag for edge detection
reg trigger_enable;             // Trigger enable signal
reg [9:0] trigger_delay_cnt;    // Trigger delay counter

always @(posedge in_clk)
    trigger_flag_d <= trigger_flag;

/**
 * Trigger enable control with delay
 * After each trigger, delays 1M time units before allowing next trigger
 */
always @(posedge in_clk)
begin
    if(trigger_delay_cnt > TRIGGER_DELAY_CNT) begin
        trigger_enable <= 1;
    end
    else if(trigger_flag == 1 && trigger_flag_d == 0) begin
        trigger_enable <= 0;
    end
    else begin
        trigger_enable <= trigger_enable;
    end
end

/**
 * Trigger delay counter
 * Counts during trigger disable period
 */
always @(posedge in_clk)
begin
    if(trigger_enable == 0) begin
        trigger_delay_cnt <= trigger_delay_cnt + 1'b1;
    end
    else
        trigger_delay_cnt <= 0;
end

//in_sample_rate_select[1]: 1=1kHz real-time sampling, 0=equivalent sampling
//in_sample_rate_select[0]: 1=10MHz equivalent sampling, 0=200MHz equivalent sampling (valid when [1]=0)

// Clock multiplexer for equivalent sampling
wire delta_t_clk;
//assign delta_t_clk = in_sample_rate_select[0] ? in_clk_10M : in_clk_200M ;

/**
 * Delta-t Clock Multiplexer  
 * Selects between 10MHz and 200MHz clocks for equivalent sampling timing
 */

delta_t_clk_mux delta_t_clk_mux_inst (
    .data0 ( in_clk_10M ),
    .data1 ( in_clk_200M ),
    .sel ( in_sample_rate_select[0] ),
    .result ( delta_t_clk )
    );

// Post-trigger delay measurement counter - calculates delta-t increments, increasing delay time each cycle
reg [9:0] measure_delay_cnt;

always @(posedge delta_t_clk or negedge in_rst)
begin
    if(!in_rst) begin
        measure_delay_cnt <= 0;
    end
    else begin
        if(measure_start) begin
            if(trigger_flag)
                measure_delay_cnt <= measure_delay_cnt + 1'b1;
            else
                measure_delay_cnt <= 0;
        end
        else begin
            measure_delay_cnt <= 0;
        end
    end
end

reg [9:0] measure_index;
reg measure_flag;
// Measurement signal generation - triggers after reaching count value n*delta_t
always @(posedge in_clk)
begin
    if(measure_delay_cnt == measure_index) begin
        measure_flag <= 1;
    end
    else 
        measure_flag <= 0;
end

reg measure_flag_d;
always @(posedge in_clk)
    measure_flag_d <= measure_flag;

reg in_clk_1k_d;
always @(posedge in_clk)
    in_clk_1k_d <= in_clk_1k;
    
    
always @(posedge in_clk)
begin
    if(measure_start) begin
        if(in_sample_rate_select[1]) begin // Real-time sampling mode
            if(in_clk_1k == 1 && in_clk_1k_d == 0) begin // 1ms rising edge trigger
                measure_index <= measure_index + 1'b1;
            end
        end
        else begin // Equivalent sampling mode
            if(measure_flag == 1 && measure_flag_d == 0) begin // Detect measurement trigger rising edge
                measure_index <= measure_index + 1'b1;
            end
        end
    end
    else begin
        measure_index <= 1;
    end
end

reg measure_done;       // Measurement completion signal
reg measure_done_d;
reg [9:0] measure_cnt;
reg measure_once_start;
reg measure_hold_sig;
always @(posedge in_clk)
    measure_done_d <= measure_done;

// Sample-and-hold signal control
always @(posedge in_clk)
begin
    if(measure_start) begin
        if(measure_flag == 1 && measure_flag_d == 0) begin // Detect measurement signal rising edge
            measure_hold_sig <= 0;
        end
        else if(measure_done == 1 && measure_done_d == 0) begin // Detect measurement completion rising edge
            measure_hold_sig <= 1;
        end
        else 
            measure_hold_sig <= measure_hold_sig;
    end
    else begin
        measure_hold_sig <= 1;
    end
end

always @(posedge in_clk)
begin
    if(measure_hold_sig == 0)
        measure_cnt <= measure_cnt + 1'b1;
    else
        measure_cnt <= 0;
end

always @(posedge in_clk)
begin
    case (measure_cnt)
        MEASURE_DONE_CNT: begin
            measure_done <= 1;
        end
        default: begin
            measure_done <= 0;
        end
    endcase
end


reg measure_adc_sig;
reg [9:0]measure_adc_cnt;
reg measure_adc_done;
reg measure_adc_done_d;
always @(posedge in_clk)
    measure_adc_done_d <= measure_adc_done;

always @(posedge in_clk)
begin
    if(measure_start) begin
        if(measure_flag == 1 && measure_flag_d == 0) begin // Detect measurement signal rising edge
            measure_adc_sig <= 1;
        end
        else if(measure_adc_done == 1 && measure_adc_done_d == 0) begin // Detect measurement completion rising edge
            measure_adc_sig <= 0;
        end
        else 
            measure_adc_sig <= measure_adc_sig;
    end
    else begin
        measure_adc_sig <= 0;
    end
end

always @(posedge in_clk)
begin
    if(measure_adc_sig)
        measure_adc_cnt <= measure_adc_cnt + 1'b1;
    else
        measure_adc_cnt <= 0;
end

reg measure_adc_clk;
always @(posedge in_clk)
begin
    case (measure_adc_cnt)
        10'd1: begin
            measure_adc_clk <= 0;
        end
        ADC_CLK_DELAY: begin
            measure_adc_clk <= 1;
            measure_adc_done <= 1;
        end
        default: begin
            measure_adc_clk <= measure_adc_clk;
            measure_adc_done <= 0;
        end
    endcase
end


reg in_request_d;
always @(posedge in_clk)
    in_request_d <= in_request_n;

reg measure_start;
always @(posedge in_clk or negedge in_rst)
begin
    if(!in_rst) begin
        measure_start <= 0;
    end
    else if(in_request_d == 1 && in_request_n == 0) begin
        measure_start <= 1;
    end
    else if(measure_index == DATA_NUM) begin
        measure_start <= 0;
    end
    else
        measure_start <= measure_start;
end

endmodule