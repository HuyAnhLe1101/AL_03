`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2026 12:33:32 PM
// Design Name: 
// Module Name: UARTReader
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


module UARTReader #(
    parameter DATA_WIDTH = 8,
    parameter STOPBIT_TICK = 16, // ticks for stop bits (1 stop bit)
    parameter OVERSAMPLE_CNT = 16
)(
    input logic clk, rst_n, 
    input logic rx, baud_tick, 
    output logic rx_done_tick, 
    output logic [DATA_WIDTH-1:0] dout, 

    output logic [1:0] debug_state,
    output logic [3:0] debug_tick_count, 
    output logic [2:0] debug_data_count
    );
    localparam CLKS_PER_BIT = 44; 
    // fsm state type
    typedef enum {idle, start, data, stop} uart_read_state; 

    // logic declaration 
    uart_read_state state_reg, next_state; 
    logic [$clog2(CLKS_PER_BIT)-1:0] tick_count_reg, next_tick_count; // for counting number of tick for each bit
    logic [$clog2(DATA_WIDTH)-1:0] data_count_reg, next_data_count; // for counting number of data bits 
    logic [DATA_WIDTH-1:0] data_reg, next_data; 

    // Memory components 
    always_ff @(posedge clk, negedge rst_n) begin 
        if (!rst_n) begin 
            state_reg      <= idle; 
            tick_count_reg <= '0; 
            data_count_reg <= '0; 
            data_reg       <= '0; 
        end else begin 
            state_reg      <= next_state; 
            tick_count_reg <= next_tick_count; 
            data_count_reg <= next_data_count; 
            data_reg       <= next_data; 
        end 
    end 



    // Next state 
    always_comb begin : fsm_state
        // default value 
        next_state = state_reg; 
        next_tick_count = tick_count_reg; 
        next_data_count = data_count_reg; 
        next_data       = data_reg; 
        rx_done_tick = 1'b0; 

        // state machine 
        case (state_reg)
            idle: begin 
                next_tick_count = 0; 
                next_data_count = 0; 
                next_data       = 0;

                if (~rx) next_state = start;  
            end 

            start: begin

                // only increament tick count when baud tick is triggered 
                //if (baud_tick) begin 
                    next_tick_count = tick_count_reg + 1; 
                
                    if (tick_count_reg == CLKS_PER_BIT/2) begin // check rx again to confirm that data still high
                        if (~rx) begin 
                            next_state = data; // if still low, move to next state
                            next_tick_count = 0; // reset tick count 
                        end else next_state = idle; 
                    end 
                //end 
            end 

            data: begin 
                //if (baud_tick) begin 
                    next_tick_count = tick_count_reg + 1; 

                    if (tick_count_reg == CLKS_PER_BIT-1) begin 
                        next_data = {rx, data_reg[7:1]}; 
                        next_data_count = data_count_reg + 1;
                        next_tick_count = 0;  
                    end 

                    if (data_count_reg == DATA_WIDTH-1 && tick_count_reg == CLKS_PER_BIT-1) begin 
                        next_state = stop; 
                        next_tick_count = 0; 
                    end 
                //end 
            end 

            stop: begin 
                //if (baud_tick) begin 
                    next_tick_count = tick_count_reg + 1; 

                    if (tick_count_reg == CLKS_PER_BIT-1) begin 
                        next_tick_count = 0; 
                        next_state = idle; 
                        rx_done_tick = 1'b1;  
                    end
                //end 
            end 

        endcase  
    end

    assign dout = data_reg; 
    assign debug_state = state_reg; 
    assign debug_data_count = data_count_reg; 
    assign debug_tick_count = tick_count_reg; 

endmodule
