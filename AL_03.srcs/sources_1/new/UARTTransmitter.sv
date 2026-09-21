`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2026 10:00:44 AM
// Design Name: 
// Module Name: UARTTransmitter
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


module UARTTransmitter #(
    parameter DATA_WIDTH = 8, 
    parameter CLKS_PER_BIT = 44
)(
    input logic clk, rst_n,
    input logic [DATA_WIDTH-1:0] din,
    input logic tx_send_data,   

    output logic tx, 
    output logic tx_done_tick, 

    output logic [1:0] debug_state,
    output logic [$clog2(CLKS_PER_BIT)-1:0] debug_tick_count, 
    output logic [2:0] debug_data_count
);

// fsm state type 
typedef enum {idle, start, data, stop} uart_send_state;

// logic declaration 
uart_send_state state_reg, next_state;
logic [$clog2(CLKS_PER_BIT)-1:0] tick_count_reg, next_tick_count; 
logic [$clog2(DATA_WIDTH)-1:0] data_count_reg, next_data_count; 
logic [DATA_WIDTH-1:0] tx_data_reg, next_tx_data; 

// Memory component 
always_ff @(posedge clk, negedge rst_n) begin 
    if (!rst_n) begin 
        state_reg      <= idle; 
        tick_count_reg <= '0; 
        data_count_reg <= '0; 
        tx_data_reg    <= '0;
    end else begin 
        state_reg      <= next_state; 
        tick_count_reg <= next_tick_count; 
        data_count_reg <= next_data_count; 
        tx_data_reg    <= next_tx_data; 
    end 
end 

// Next state logic 
always_comb begin : fsm_state_wr 
    // default value 
    next_state = state_reg; 
    next_tick_count = tick_count_reg; 
    next_data_count = data_count_reg; 
    tx_done_tick    = 1'b0; 
    tx = 1'b1; 

    case (state_reg) 
        idle: begin 
            next_tick_count = 0; 
            next_data_count = 0; 
            next_tx_data    = 1'b1; 

            if (tx_send_data) begin 
                next_state = start;
                next_tx_data =  din; 
            end 
        end 

        start : begin 
            next_tick_count = tick_count_reg + 1; 
            tx = 1'b0; 

            if (tick_count_reg == CLKS_PER_BIT-1) begin 
                next_tick_count = 0; 
                next_state = data; 
            end   
        end 

        data : begin 
            next_tick_count = tick_count_reg + 1; 
            tx = tx_data_reg[data_count_reg]; 

            if (tick_count_reg == CLKS_PER_BIT-1) begin 
                next_tick_count = 0; 
                next_data_count = data_count_reg + 1;

                if (data_count_reg == DATA_WIDTH-1) begin 
                    next_data_count = 0; 
                    next_state = stop; 
                end  
            end 

        end 

        stop : begin 
            next_tick_count = tick_count_reg + 1; 
            tx = 1'b1;

            if (tick_count_reg == CLKS_PER_BIT-1) begin 
                next_tick_count = 0; 
                next_state = idle; 
                tx_done_tick = 1'b1; 
            end 
        end 
    endcase
end

assign debug_state = state_reg; 
assign debug_data_count = data_count_reg; 
assign debug_tick_count = tick_count_reg;

endmodule
