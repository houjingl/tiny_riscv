`include "baud_setting.svh"

//------------------------------------------------------------------------------
// Description :
//
//   UART RX Controller module.
//   This module detects the external start bit as the activation signal and samples each incoming bit at its center to improve accuracy.
//   Each bit is sampled multiple times (1/3 of baud tick clock cycles) to reduce possible interference in real-world situations.
//   A finite state machine (FSM) manages the behavior and actions at each stage of the reception process.
//
// Author      : Jingling Hou
//------------------------------------------------------------------------------

module uart_rx_controller #(
    parameter int F_CLK = 16000000,
    parameter int OUTPUT_DATA_WIDTH = 8,
    parameter int RX_BAUD_RATE = BAUD_115200, //RX Baud rate is non configurable
    parameter int SAMPLE_NUM = RX_BAUD_RATE / 3 //sample one bit multiple times to prevent sudden interference possible in read world (can be simulated using testbench)
) (
    input clk_16mhz,
    input rstn,

    input logic serial_in,
    output logic [OUTPUT_DATA_WIDTH - 1: 0] data_out,
    output logic rx_done_pulse,
    output logic rx_start_pulse,
    output logic rx_error
);

    logic baud_tick;
    baud_set_t baud_setting;
    assign baud_setting = BAUD_SET_115200;
    baud_tick_generator BAUD_TICK_GEN(.clk_16mhz(clk_16mhz),.rstn(rstn),
                                    .baud_setting(baud_setting),.baud_tick(baud_tick),.tx_en(rx_start_pulse),.tx_done(rx_done_pulse));

    //start bit negedge trigger
    reg start_bit_ff, start_bit_ff2;
    wire start_pulse;
    always @(posedge clk_16mhz) begin
        if (!rstn) begin
            start_bit_ff <= 1'b0;
            start_bit_ff2 <= 1'b0;
            rx_error <= 1'b0;
        end
        else begin
            start_bit_ff <= serial_in;
            start_bit_ff2 <= start_bit_ff;
        end
    end 
    assign start_pulse = ~serial_in & start_bit_ff2; //if ff1 = 0 and ff2 is 1 means we encountered a negedge 

    localparam int DELAY_COUNTER_WIDTH = clogb2(SAMPLE_NUM);
    logic [DELAY_COUNTER_WIDTH : 0] delay_count;
    logic delay_count_enable;
    logic delay_count_done;

    assign delay_count_done = (delay_count == SAMPLE_NUM) ? 1:0;
    assign delay_count_enable = (cfsm_cur_state == DELAY_START) ? 1:0;

    always @(posedge clk_16mhz) begin
        if (!rstn || cfsm_cur_state != DELAY_START) 
            delay_count <= 0;
        else if (delay_count_enable) 
            delay_count <= delay_count + 1;
    end

    assign rx_start_pulse = (cfsm_cur_state == TICK_GEN_EN) ? 1:0; //rx_start_pulse_gen

    //Count number of bits sampled
    localparam int TICK_COUNTER_WIDTH = clogb2(OUTPUT_DATA_WIDTH);
    logic [TICK_COUNTER_WIDTH : 0] tick_sum;

    always @(posedge clk_16mhz) begin: tick_counter
        if(!rstn || rx_done_pulse)
            tick_sum <= 1'b0;
        else if (baud_tick)
            tick_sum <= tick_sum + 1'b1;
    end

    assign rx_done_pulse = (tick_sum == OUTPUT_DATA_WIDTH + 1);

    //Sampling
    logic [DELAY_COUNTER_WIDTH : 0] sample_high_sum, total_sample;
    logic sampler_reset;
    logic sampler_enable;
    //Sampler will be turned on for a while after each baud tick and turned off automatically
    always @(posedge clk_16mhz) begin : sampler
        if (!rstn || sampler_reset) sample_high_sum <= 'b0;
        else if(sampler_enable && serial_in && cfsm_cur_state == WAIT_DONE) sample_high_sum <= sample_high_sum + 1'b1;
        
        //sampler enable signal
        if(!rstn || sampler_reset) sampler_enable <= 1'b0;
        else if(baud_tick) sampler_enable <= 1'b1;
        
        //Total Sample
        if (!rstn || sampler_reset) total_sample <= 'b0;
        else if (sampler_enable && cfsm_cur_state == WAIT_DONE) total_sample <= total_sample + 1'b1;
    end
    assign sampler_reset = (total_sample == SAMPLE_NUM);
    


    //Fill output byte
    always @(posedge clk_16mhz) begin : data_out_assign
        if (sampler_reset)begin //@ sampler_reset == 1, we check the number of 1's
            if(sample_high_sum > SAMPLE_NUM / 2) data_out[tick_sum - 1] <= 1'b1; 
            else if (sample_high_sum < SAMPLE_NUM / 2) data_out[tick_sum - 1] <= 1'b0;
            else begin
                data_out[tick_sum - 1] <= 1'bx;
                rx_error <= 1'b1;
            end  //ERROR, smt really weird happened
        end
    end

    localparam logic [1:0] IDLE = 2'b00, DELAY_START = 2'b01, TICK_GEN_EN = 2'b10, WAIT_DONE = 2'b11;
    logic [1:0] cfsm_cur_state, cfsm_next_state;
    //next state logic
    always_comb begin: comb_input_logic
        case(cfsm_cur_state)
            IDLE: begin
                if (start_pulse) cfsm_next_state = DELAY_START;
                else cfsm_next_state = IDLE;
            end

            DELAY_START: begin
                if (delay_count_done) cfsm_next_state = TICK_GEN_EN;
                else cfsm_next_state = DELAY_START;
            end

            TICK_GEN_EN: begin
                cfsm_next_state = WAIT_DONE;
            end

            WAIT_DONE: begin
                if(rx_done_pulse) cfsm_next_state = IDLE;
                else cfsm_next_state = WAIT_DONE;
            end
        endcase
    end

    //next to cur state ff
    always @(posedge clk_16mhz) begin
        if (!rstn) begin
            cfsm_cur_state <= IDLE;
        end
        else begin
            cfsm_cur_state <= cfsm_next_state;
        end
    end


endmodule