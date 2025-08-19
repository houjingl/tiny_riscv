`include "baud_setting.svh"
module uart_controller #(
    parameter int INPUT_DATA_WIDTH = 8,
    parameter int F_CLK = 16000000
) (
    input logic [INPUT_DATA_WIDTH -1 : 0] data_in,
    input logic clk_16mhz,
    input logic rstn,
    input logic tx_en,
    input baud_set_t baud_setting,
    output logic tx_done,
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