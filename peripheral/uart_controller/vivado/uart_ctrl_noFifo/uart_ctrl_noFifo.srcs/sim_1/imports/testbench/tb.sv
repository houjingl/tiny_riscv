`timescale  1ns/1ps
`include "baud_setting.svh"
module tb();

  // Clock/Reset
  logic clk_16mhz;
  logic rstn;

  // DUT I/O
  localparam int INPUT_DATA_WIDTH = 8;
  logic [INPUT_DATA_WIDTH-1:0] data_in;
  logic tx_en;
  baud_set_t baud_setting;     
  logic tx_done;
  logic serial_out;

  // Instantiate DUT
  uart_controller #(
    .INPUT_DATA_WIDTH(INPUT_DATA_WIDTH),
    .F_CLK(16000000)
  ) uut (
    .data_in     (data_in),
    .clk_16mhz   (clk_16mhz),
    .rstn        (rstn),
    .tx_en       (tx_en),
    .baud_setting(baud_setting),
    .tx_done     (tx_done),
    .serial_out  (serial_out)
  );

  task wait_n_clock_cycles(int n);
    int i;
    for(i = 0; i < n; i= i + 1)
    begin
        @(posedge clk_16mhz);
    end
  endtask

  task wait_for_tx_done();
    @(negedge tx_done);
  endtask

  task generate_tx_en_pulse();
    @(posedge clk_16mhz);
    tx_en = 1'b1;
    @(posedge clk_16mhz);
    tx_en = 1'b0;
  endtask
  
  task uart_output(input logic [INPUT_DATA_WIDTH-1 :0] test_data);
    data_in = test_data;
    generate_tx_en_pulse();
    wait_for_tx_done(); //Marks the termination of transferring one byte
  endtask 
  
  always #31.25 clk_16mhz = ~clk_16mhz;
  

  // 16 MHz clock: 62.5 ns period
  initial begin 
    clk_16mhz = 1'b0;
    rstn = 1'b0;
    wait_n_clock_cycles(2);
    rstn = 1'b1;
    
    baud_setting = BAUD_SET_9600;
    uart_output(8'hD1);
    uart_output(8'h01);
    uart_output(8'hff);
    
    baud_setting = BAUD_SET_115200;
    uart_output(8'hD1);
    uart_output(8'h01);
    uart_output(8'hff);
    
    baud_setting = BAUD_SET_1000000;
    uart_output(8'hD1);
    uart_output(8'h01);
    uart_output(8'hff);
    
    $finish;
  end 
  

  
  

endmodule