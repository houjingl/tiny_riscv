`include "baud_setting.svh"

//------------------------------------------------------------------------------
// Description :
//
//   UART TX Controller module.
//   This module serializes input data and transmits it over a UART interface.
//   It uses a baud tick generator to control transmission timing based on the selected baud rate.
//   Data transmission starts on a pulse of tx_en, and tx_done indicates completion.
//   The module outputs the serialized data on serial_out, including start and stop bits.
//
// Author      : Jingling Hou
//------------------------------------------------------------------------------

module uart_tx_controller #(
    parameter int INPUT_DATA_WIDTH = 8,
    parameter int F_CLK = 16000000
) (
    input logic [INPUT_DATA_WIDTH -1 : 0] data_in,
    input logic clk_16mhz,
    input logic rstn,
    input logic tx_en, //NOTE: Tx_en MUST BE A PULSE // //NOTE: TX EN CAN ONLY HAPPEN ONE CYCLE AFTER SEEING TX DONE
    input baud_set_t baud_setting,
    output logic tx_done, //NOTE: Tx_done WILL BE A PULSE
    output logic serial_out
);

    logic baud_tick;
    baud_tick_generator BAUD_TICK_GEN(.clk_16mhz(clk_16mhz),.rstn(rstn),
                                    .baud_setting(baud_setting),.baud_tick(baud_tick),.tx_en(tx_en),.tx_done(tx_done));

    logic [INPUT_DATA_WIDTH -1: 0] data_tbs;
    logic [4:0] count;

    always@(posedge clk_16mhz) begin
        if (tx_en) begin //will start the tick generator
            data_tbs <= data_in; //clock data
            serial_out <= 1'b0;
            count <= 0;
        end
        else if (tx_done) begin
            count <= 1'b0;
        end
        else if (baud_tick) begin
            if (count >= INPUT_DATA_WIDTH) serial_out <= 1'b1; //Need to send out Stop bit as last clock cycle count is 8
            else serial_out <= data_tbs[count];
            count <= count + 1;
        end

    end

    assign tx_done = (count == INPUT_DATA_WIDTH + 2) ? 1:0;

endmodule