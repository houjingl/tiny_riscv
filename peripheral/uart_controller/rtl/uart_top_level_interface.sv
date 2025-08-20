`include "peripheral\uart_controller\rtl\baud_setting.svh"

module uart_top_level_interface #(
    parameter int INPUT_DATA_WIDTH = 8,
    parameter int OUTPUT_DATA_WIDTH = 8,
    parameter int F_CLK = 16000000
) (
    //16MHZ clk and reset
    input logic clk_16mhz,
    input logic rstn,

    //TX SIDE
    input logic [INPUT_DATA_WIDTH -1 : 0] data_in,
    input logic tx_start,
    input logic [31:0] total_tx_bytes,
    input baud_set_t baud_setting,
    output logic tx_done_pulse,
    output logic serial_out,

    //RX SIDE
    input logic serial_in,
    output logic [OUTPUT_DATA_WIDTH - 1: 0] data_out,
    output logic rx_done_pulse,
    output logic rx_start_pulse,
    output logic rx_error
);

endmodule