`include "baud_setting.svh"

//------------------------------------------------------------------------------
// Description :
//
//   UART Top Level Interface Module.
//   This module wraps the UART TX controller and RX controller, providing a unified interface for UART communication.
//   It includes a TX master command FSM to enable consecutive transmission of multiple bytes, supporting use cases such as sending strings from a processing core.
//   The module manages the coordination of transmission and reception, and is designed for easy integration with higher-level systems.
//   TX and RX FIFO integration is planned for future enhancements.
//
// Author      : Jingling Hou
//------------------------------------------------------------------------------

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
    input logic [31:0] TOTAL_TX_BYTES,
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

    logic tx_byte_done_pulse;
    logic tx_byte_start_pulse;
    // TX Controller instantiation
    uart_tx_controller #(
        .INPUT_DATA_WIDTH(INPUT_DATA_WIDTH),
        .F_CLK(F_CLK)
    ) u_uart_tx_controller (
        .data_in(data_in),
        .clk_16mhz(clk_16mhz),
        .rstn(rstn),
        .tx_en(tx_byte_start_pulse),
        .baud_setting(baud_setting),
        .tx_done(tx_byte_done_pulse),
        .serial_out(serial_out)
    );

    // RX Controller instantiation
    uart_rx_controller #(
        .F_CLK(F_CLK),
        .OUTPUT_DATA_WIDTH(OUTPUT_DATA_WIDTH)
    ) u_uart_rx_controller (
        .clk_16mhz(clk_16mhz),
        .rstn(rstn),
        .serial_in(serial_in),
        .data_out(data_out),
        .rx_done_pulse(rx_done_pulse),
        .rx_start_pulse(rx_start_pulse),
        .rx_error(rx_error)
    );

    //Tx Master Command FSM and related logics
    // to control consecutive sending operation

    //latch the total num of bytes to be sent
    logic [31:0] total_tx_bytes;
    logic init_ff, init_ff2;
    always @(clk_16mhz) begin
        if (!rstn) begin
            init_ff <= 1'b0;
            init_ff2 <= 1'b1;
        end
        else begin
            init_ff <= tx_start;
            init_ff2 <= init_ff;
        end

        if (tx_start && ~init_ff2) //Rising edge trig to check tx_start rising edge
            total_tx_bytes <= TOTAL_TX_BYTES;
    end

    //tx byte counter
    logic [31:0] tx_bytes_count;
    always@ (posedge clk_16mhz) begin
        if (!rstn || tx_done_pulse) tx_bytes_count <= 'b0;
        else if (tx_byte_done_pulse) tx_bytes_count <= tx_bytes_count + 1'b1;
    end

    assign tx_done_pulse = (tx_bytes_count == total_tx_bytes);
    assign tx_byte_start_pulse = (cfsm_cur_state == TX_ENABLE);

    localparam logic [1:0] IDLE = 2'b00, TX_ENABLE = 2'b01, SEND_BYTE = 2'b10, TX_DONE_CHECK = 2'b11;

    logic [1:0] cfsm_cur_state, cfsm_next_state;

    always_comb begin : comb_input_logic
        case(cfsm_cur_state)
            IDLE: begin
                if(tx_start) cfsm_next_state = TX_ENABLE;
                else cfsm_next_state = IDLE;
            end

            TX_ENABLE: begin
                cfsm_next_state = SEND_BYTE;
            end

            SEND_BYTE: begin
                if (tx_byte_done_pulse) cfsm_next_state = TX_DONE_CHECK;
                else cfsm_next_state = SEND_BYTE;
            end

            TX_DONE_CHECK: begin
                if(tx_done_pulse) cfsm_next_state = IDLE;
                else cfsm_next_state = TX_ENABLE;
            end

        endcase
    end
    
    always @ (posedge clk_16mhz) begin
        if (!rstn)
            cfsm_cur_state <= IDLE;
        else begin
            cfsm_cur_state <= cfsm_next_state;
        end
    end
    //Reserved Space for TX FIFO and RX FIFO

endmodule