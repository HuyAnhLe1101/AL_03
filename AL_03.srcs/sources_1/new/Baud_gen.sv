`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2026 12:52:30 PM
// Design Name: 
// Module Name: Baud_gen
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


module Baud_gen #(parameter COUNTSIZE = 10)(
    input logic clk, rst_n, 
    input logic [COUNTSIZE-1:0] dvsr, 
    output logic tick 
    );

    logic [COUNTSIZE-1:0] count_reg, count_next; 

    always_ff @(posedge clk, negedge rst_n) begin 
        if (!rst_n) count_reg <= '0; 
        else count_reg <= count_next; 
    end 

    assign count_next = (count_reg == dvsr) ? '0 : count_reg + 1; 
    assign tick = (count_reg == 1); // avoid count_reg == 0 since it is reset value

endmodule
