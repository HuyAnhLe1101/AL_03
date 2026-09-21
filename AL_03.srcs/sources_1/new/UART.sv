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
    parameter DATA_WIDTH = 8
    
)(
    input logic clk, rst_n,

    // RX side 
    input logic rx, 
    output logic [DATA_WIDTH-1:0] dout, 
    output logic rx_done_tick, 

    // TX side 
    input logic [DATA_WIDTH-1:0] din, 
    input logic tx_send_data, 
    output logic tx, 
    output logic tx_done_tick, 

    // debug signals 
    output logic [1:0] debug_state,
    output logic [4:0] debug_tick_count, 
    output logic [2:0] debug_data_count

);
    localparam CLKS_PER_BIT = CLK_FRE / BAUD_RATE;  

    UARTReader #(.DATA_WIDTH(DATA_WIDTH), 
                 .CLKS_PER_BIT(CLKS_PER_BIT)) 
    uartreader_0(.*); 

    UARTTransmitter #(.DATA_WIDTH(DATA_WIDTH),
                      .CLKS_PER_BIT(CLKS_PER_BIT))
    uartransmitter_0(.*); 


endmodule
