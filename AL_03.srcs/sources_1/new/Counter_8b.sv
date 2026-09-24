`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2026 12:33:02 PM
// Design Name: 
// Module Name: Counter_8b
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


module Counter_8b(
    input logic clk, 
    input logic sync_reset,  

    output logic [7:0] count_8b, 
    output logic div_8_tick, 
    output logic div_128_tick
    );

    logic div_8_tick_reg, next_div_8_tick; 
    logic div_128_tick_reg, next_div_128_tick; 

    always_ff @(posedge clk) begin 
        if (sync_reset) 
            count_8b <= '0;
            div_8_tick_reg <= 1'b0;
            div_128_tick_reg <= 1'b0;  
        else 
            count_8b <= count_8b + 1; 
            div_8_tick_reg <= next_div_8_tick; 
            div_128_tick_reg <= next_div_128_tick; 
    end 

    assign next_div_8_tick = (count_8b == 7); 
    assign next_div_128_tick = (count_8b == 127);  

    assign div_8_tick = div_8_tick_reg; 
    assign div_128_tick = div_128_tick_reg; 


endmodule
