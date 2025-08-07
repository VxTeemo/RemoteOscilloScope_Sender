/**
 * Frequency Measurement Module
 * Measures input signal frequency using gate-controlled counting method.
 * Uses 50MHz reference clock with 1-second measurement window.
 * 
 * Working principle:
 * 1. Generate 1Hz gate signal from 50MHz reference clock
 * 2. Count input signal edges during the gate period  
 * 3. Output the count as frequency measurement result
 */
module Drive_Freq
(
    input   Freq_clk,           // Input frequency clock (currently unused)
    input   in_clk_50M,         // 50MHz reference clock
    input   in_clr,             // Reset signal, active low
    input   Sig_in,             // Input signal to be measured
     
    output  reg [31:0] data_fx  // Measured frequency output (Hz)
);

parameter T_1s = 28'd49_999_999;   // 1 second count for 50MHz clock (50M-1)

//————————————————————————————————————————————————
//          Gate Signal Generation - Creates 1Hz gate signal
//————————————————————————————————————————————————
reg [27:0] TCount;    // Gate timer counter (1 second period)

/**
 * 1-second timer counter
 * Counts from 0 to 49,999,999 (1 second at 50MHz)
 */
always @ (posedge in_clk_50M or negedge in_clr)
    if(!in_clr)
        TCount <= 28'd0;
    else if(TCount >= T_1s)
        TCount <= 28'd0;
    else
        TCount <= TCount + 1'b1;

reg TCountCnt;    // Gate control signal (toggles every second)

/**
 * Gate control signal generation
 * Creates a 1Hz square wave for measurement window control
 */
always @ (posedge in_clk_50M or negedge in_clr)
    if(!in_clr)
        TCountCnt <= 1'b0;
    else if(TCount >= T_1s)
        TCountCnt <= ~TCountCnt;

//————————————————————————————————————————————————
//          Measurement Gate Control
//————————————————————————————————————————————————
reg startCnt;    // Actual measurement gate signal

/**
 * Measurement gate synchronization
 * Starts counting when gate signal is high and input signal rising edge occurs
 */
always @ (posedge Sig_in)   // Triggered on input signal rising edge
    if(TCountCnt == 1'b1)
        startCnt <= 1'b1;
    else
        startCnt <= 1'b0;

//————————————————————————————————————————————————
//          Frequency Counter - Count edges during gate period  
//————————————————————————————————————————————————
reg [31:0] SigTemp;     // Temporary signal counter
reg [1:0]  flag_cnt;    // Clock divider flag (unused)

always @ (posedge in_clk_50M)
	flag_cnt <= (flag_cnt+1)% 2'd2;

/**
 * Input signal edge counter
 * Counts rising edges of input signal during measurement gate period
 */	
always @ (posedge Sig_in )   // Count on input signal rising edge
    if(startCnt == 1'b1)     // Count only when measurement gate is active
        SigTemp <= SigTemp + 1'b1;
    else
        SigTemp <= 'd0;
	  
//————————————————————————————————————————————————
//          Output Latch - Store measurement result
//————————————————————————————————————————————————

/**
 * Frequency result output
 * Latches the counted value when measurement gate goes low
 * Result represents frequency in Hz (counts per second)
 */
always @ (negedge startCnt)   // Latch result on gate falling edge
    data_fx <= SigTemp;
	

endmodule