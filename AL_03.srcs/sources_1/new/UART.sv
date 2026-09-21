`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2026 05:45:20 PM
// Design Name: 
// Module Name: UART
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART #(
    parameter CLK_FRE   = 10_240_000, 
    parameter BAUD_RATE = 230_400,
    parameter DATA_WIDTH = 8, 
    parameter OVERSAMPLE_CNT = 16 // oversampling CNT for each bit of RX 
)(
    input logic clk, rst_n, 
    input logic rx, 
    output logic [DATA_WIDTH-1:0] dout, 
    output logic rx_done_tick, 
    output logic [9:0] debug_div, 
    output logic [1:0] debug_state,
    output logic [3:0] debug_tick_count, 
    output logic [2:0] debug_data_count, 
    output logic debug_enable_tick 
);
    // the sampling rate for UART data is 16 times of baud rate 
    //localparam DIV_VALUE = (CLK_FRE / (BAUD_RATE*OVERSAMPLE_CNT)) - 1;
    localparam DIV_VALUE = 2; 
    logic enable_tick; 

    Baud_gen baud_gen_0(
        .dvsr(DIV_VALUE), 
        .tick(enable_tick), 
        .*
    ); 

    UARTReader #(.DATA_WIDTH(DATA_WIDTH), 
                 .OVERSAMPLE_CNT(OVERSAMPLE_CNT)) 
    uartreader_0(
        .baud_tick(enable_tick), 
        .*
    ); 
    
    assign debug_div = DIV_VALUE;
    assign debug_enable_tick = enable_tick;

endmodule
