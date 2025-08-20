`timescale  1ns/1ps
`include "baud_setting.svh"
module tb();

    // --- Parameters to mirror DUT defaults ---
    parameter int F_CLK_HZ   = 16000000;
    BAUD_CONFIG BAUD = BAUD_115200;
    parameter real CLK_CYCLE = 62.5;
    parameter real BIT_RATE = 8687;
    parameter int OUTPUT_DATA_WIDTH = 8;

    // --- DUT I/O ---
    logic clk_16mhz;
    logic rstn;

    logic serial_in;
    logic [7:0] data_out;
    logic rx_done_pulse;
    logic rx_start_pulse;
    logic rx_error;

    // --- Clock generation: 16 MHz ---
    initial begin
        clk_16mhz = 1'b0;
        forever #(CLK_CYCLE/2.0) clk_16mhz = ~clk_16mhz; // 31.25 ns high/low
    end

    // --- Instantiate DUT ---
    uart_rx_controller #(
        .F_CLK(16000000),
        .OUTPUT_DATA_WIDTH(OUTPUT_DATA_WIDTH)
        // RX_BAUD_RATE and SAMPLE_NUM left as DUT defaults (115200, etc.)
    ) dut (
        .clk_16mhz     (clk_16mhz),
        .rstn          (rstn),
        .serial_in     (serial_in),
        .data_out      (data_out),
        .rx_done_pulse (rx_done_pulse),
        .rx_start_pulse(rx_start_pulse),
        .rx_error      (rx_error)
    );

    //Tasks implementations here
    task wait_n_clock_cycles(int n);
        int i;
        for(i = 0; i < n; i= i + 1)
        begin
            @(posedge clk_16mhz);
        end
    endtask

    task automatic inject_short_glitch_low(real width_ns = BIT_RATE/8.0);
        serial_in <= 1'b0; #(width_ns);
        serial_in <= 1'b1;
    endtask

    task automatic send_uart_byte(input logic [OUTPUT_DATA_WIDTH-1 :0] byte_);
        int i;
        begin
            serial_in = 1'b0;
            #BIT_RATE;
            for(i = 0; i < OUTPUT_DATA_WIDTH; i = i + 1)
            begin
                serial_in = byte_[i];
                #BIT_RATE;
            end
            serial_in = 1'b1; 
            #BIT_RATE;
        end
    endtask

    task automatic compare_data_out(input byte expected_output);
        assert (data_out == expected_output)begin
            $display("Data out == Expected -> 0x%0h", data_out);
        end
        else   begin
            $fatal(1, "Data Out: 0x%0h | Expected: 0x%0h", data_out, expected_output);
            $finish;
        end
    endtask

    //Reset system    
    initial begin
        dut.BAUD_TICK_GEN.COUNTER_RESET_LIM = BAUD_115200;
        serial_in = 1'b1;   // UART serial in set to idle mode
        rstn      = 1'b0;
        wait_n_clock_cycles(10);
        rstn      = 1'b1;
        wait_n_clock_cycles(100);
        
        //Executing tasks
        for (test_in = 8'hDB; test_in > 0; test_in = test_in - 1'b1)
        begin
            send_uart_byte(test_in);
            compare_data_out(test_in);
            wait_n_clock_cycles(100);
        end
        
        $display("Test Passed\n");
        $finish; 
    end
    logic [OUTPUT_DATA_WIDTH - 1 : 0] test_in;
    
    
endmodule