`include "baud_setting.svh"
module baud_tick_generator #(
    parameter int ACC_WIDTH = 32, //a 32 bit width phase accmulator
    parameter int F_CLK = 16000000 //Clock freq is 16Mhz
) (
    input logic clk_16mhz,
    input logic rstn,
    input baud_set_t baud_setting,
    input logic tx_en,
    input logic tx_done,
    output logic baud_tick
);

    BAUD_CONFIG COUNTER_RESET_LIM;
    logic [ACC_WIDTH -1 : 0] sum;
    logic enabled;

    always@(*) begin
        case(baud_setting)
            BAUD_SET_9600: COUNTER_RESET_LIM = BAUD_9600;
            BAUD_SET_460800: COUNTER_RESET_LIM = BAUD_460800;
            BAUD_SET_115200: COUNTER_RESET_LIM = BAUD_115200;
            BAUD_SET_1000000: COUNTER_RESET_LIM = BAUD_1000000;
            default: COUNTER_RESET_LIM = BAUD_9600;
        endcase
    end

    always@(posedge clk_16mhz) begin
        if (!rstn || baud_tick) begin
            sum <= 'b0;
        end 
        else if (enabled)
        begin
            sum <= sum + 1;
        end
    end
    assign baud_tick = (sum == COUNTER_RESET_LIM - 1) ? 1:0;
    
    always_ff @ (posedge clk_16mhz) begin
        if (tx_done) enabled <= 1'b0;
        else if (tx_en) enabled <= 1'b1;
    end
    
    
endmodule