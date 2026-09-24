`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2026 12:42:26 PM
// Design Name: 
// Module Name: gen_phase
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


module gen_phase #(
    parameter PULSE_W = 16
)(
    input logic clk, 
    input logic ena_tick, 
    input logic i_set, 
    input logic i_swap, 
    input logic [5:0] i_phase, 
    input logic [4:0] i_counter, 

    output logic pulse; 
    );

    logic pulse_reg, next_pulse; 
    logic set_d, swap_d; 
    logic [5:0] phase_data_0, next_phase_data_0; 
    logic [5:0] phase_data_1, next_phase_data_1; 
    logic [4:0] pulse_count, next_pulse_count; 
    logic rising_set, rising_swap; 

    always_ff @(posedge clk) begin 
        phase_data_0 <= next_phase_data_0; 
        phase_data_1 <= next_phase_data_1; 
        pulse_count <= next_pulse_count;
        set_d <= i_set; 
        swap_d <= i_swap;
        pulse_reg <= next_pulse;
    end

    assign rising_set = (~set_d & i_set); 
    assign rising_swap = (~swap_d & i_swap);

    always_comb begin 
        next_phase_data_0 = phase_data_0; 
        next_phase_data_1 = phase_data_1; 
        next_pulse_count  = pulse_count; 
        next_pulse = pulse_reg; 


        if (ena_tick) begin 
            next_pulse_count = pulse_count + 1;

            if (rising_set) begin 
                next_phase_data_1 = i_phase; 
            end 

            if (rising_swap) begin 
                next_phase_data_0 = phase_data_1;
                next_phase_data_1 = phase_data_0;  
            end 

            if (phase_data_0 == i_counter) begin 
                next_pulse = 1'b0; 
                next_pulse_count = 0; 
            end else begin 
                if (pulse_count == PULSE_W -1) begin 
                    next_pulse = 1'b1; 
                    next_pulse_count = 0; 
                end else next_pulse_count = pulse_count + 1; 
            end 

        end
    end  


endmodule
