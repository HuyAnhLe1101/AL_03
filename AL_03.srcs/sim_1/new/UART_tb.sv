`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2026 06:03:04 PM
// Design Name: 
// Module Name: UART_tb
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


module UART_tb #(
    parameter DATA_WIDTH = 8, 
    parameter CLK_FRE = 10_240_000, 
    parameter BAUD_RATE = 230_400
);

    localparam CLK_CYCLE = 1_000_000_000 / CLK_FRE; 
    localparam CYCS_PER_BITS = CLK_FRE / BAUD_RATE; 

    logic clk, rst_n;  
    logic rx = 1'b1; 
    logic [DATA_WIDTH-1:0] dout; 
    logic rx_done_tick;
    logic [9:0] debug_div; 
    logic [1:0] debug_state; 
    logic [3:0] debug_tick_count;  
    logic [2:0] debug_data_count; 
    logic debug_enable_tick; 

    UART uart_dut(.*); 

    // ----- Testbench parameters ------------ 
    // Queue for storing UART data
    logic [DATA_WIDTH-1:0] deubg_data_send_tx; 
    logic [DATA_WIDTH-1:0] model [$];
    int errors, transfers; 

    logic done_rst = 0; 

    logic finish_tx = 1'b0; 
    logic finish_rx = 1'b0; 

    //logic byte_sent_done = 1'b0; 

    // Clock and reset 
    initial begin 
        clk = 1'b0; 
        forever #(CLK_CYCLE/2) clk = ~clk;
    end 

    initial begin 
        rst_n = 1'b0; 
        repeat (5) @(posedge clk); 
        rst_n = 1'b1; 
        done_rst = 1'b1; 
    end 

    ////////////////////////////
    task automatic wait_cycle(input int cycle_nums);
        repeat (cycle_nums) @(posedge clk); 
    endtask

    task automatic tx_send(input logic [DATA_WIDTH-1:0] data_send);
        // Start bit 

        deubg_data_send_tx = data_send; 
        model.push_back(data_send); 
        rx <= 1'b0; 
        wait_cycle(CYCS_PER_BITS); 

        // Data byte
        for (int i = 0; i < DATA_WIDTH; i++) begin 
            rx <= data_send[i];
            wait_cycle(CYCS_PER_BITS);  
        end 

        // Stop bit 
        rx <= 1'b1; 
        wait_cycle(CYCS_PER_BITS); 

    endtask  


    task automatic rx_receive(); 
        logic [DATA_WIDTH-1:0] exp; // expectation value

        @(posedge rx_done_tick);
        //wait (rx_done_tick);  
        exp = model.pop_front(); 

        @(negedge rx_done_tick);
        if (dout != exp) begin 
            $error("%t: Data mismatch: got %h instead of %h", $time, dout, exp);
            errors++; 
        end else transfers++; 

    endtask 

    initial begin : tx_send_op
        wait (done_rst); 

        repeat (10) begin 
            tx_send($urandom); 
            repeat ($urandom_range(1, 3)) @(posedge clk);
        end 

        finish_tx = 1'b1; 
    end  

    initial begin : rx_receive_op 

        wait (done_rst); 
        
        // We cannot use while (!finish_tx ||  model.size() != 0) here since finish_tx triggers 
        // after sending data so rx_receive will reenter while there is no data is sent --> stuck 
        // for model.size() != 0 condition, when rx_recieve enters, model.size() reset to 0, function enter 
        // sets finish_rx to 1 --> misses other data 
        // --> let rx run to number of tx send 
        repeat (10) begin 
            rx_receive(); 
            repeat ($urandom_range(1, 3)) @(posedge clk); 
        end 

        finish_rx = 1'b1; 
    end 

    // TIMEOUT, 
    initial begin 
        #1_000_000_000; 
        $fatal("Testbench timed out"); 
    end 

    initial begin 
        wait (finish_tx && finish_rx); 
        repeat (10) @(posedge clk); 
        $finish; 
    end 

    final begin 
        if (errors || model.size()) 
            $display("FAILED: %d errors and %d transfers remaining, ran %d transfers", errors, model.size(), transfers); 
        else 
            $display("PASSED: total %d transfers", transfers);
    end 

endmodule
