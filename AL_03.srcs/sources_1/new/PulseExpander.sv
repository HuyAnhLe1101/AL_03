`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2026 12:35:13 PM
// Design Name: 
// Module Name: PulseExpander
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


module PulseExpander #(
    parameter PULSE_LENGTH = 8
)(
    input logic clk, 
    input logic i_signal, 
    output logic exp_signal
);

logic exp_signal_reg, next_exp_signal; 
logic [$clog2(PULSE_LENGTH)-1:0] pulse_count_reg, next_pulse_count; 

always_ff @(posedge clk) begin 
    exp_signal_reg <= next_exp_signal; 
    pulse_count_reg <= next_pulse_count;    
end 

always_comb begin
    next_exp_signal = exp_signal_reg; 
    next_pulse_count = pulse_count_reg; 

    if (i_signal) begin 
        next_exp_signal = 1'b1; 
        next_pulse_count = 0; 
    end else begin 
        if (pulse_count == PULSE_LENGTH - 1) next_exp_signal = 1'b0; 
        else next_pulse_count = pulse_count_reg + 1; 
    end 

end 
endmodule
