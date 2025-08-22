`timescale  1ns/1ps
`include "baud_setting.svh"

module tb ();

    // ---------------------------------------------------------------------------
    // Local params
    // ---------------------------------------------------------------------------
    localparam real   CLK_FREQ_HZ  = 16_000_000.0;   // 16 MHz
    localparam real   CLK_PERIOD_NS= 62.5;
    localparam int    INPUT_DATA_WIDTH  = 8;
    localparam int    OUTPUT_DATA_WIDTH = 8;
    localparam int    TX_BYTES_NUM = 10;

    // ---------------------------------------------------------------------------
    // DUT I/O
    // ---------------------------------------------------------------------------
    logic clk_16mhz;
    logic rstn;

    // TX side
    logic [INPUT_DATA_WIDTH-1:0]  data_in;
    logic                         tx_start;
    logic [31:0]                  TOTAL_TX_BYTES;
    baud_set_t                    baud_setting;
    logic                         tx_done_pulse;
    logic                         serial_out;

    // RX side
    logic                         serial_in;
    logic [OUTPUT_DATA_WIDTH-1:0] data_out;
    logic                         rx_done_pulse;
    logic                         rx_start_pulse;
    logic                         rx_error;

    // ---------------------------------------------------------------------------
    // Clock generation (16 MHz)
    // ---------------------------------------------------------------------------
    initial begin
        clk_16mhz = 1'b0;
        forever #(CLK_PERIOD_NS/2.0) clk_16mhz = ~clk_16mhz;
    end

    // ---------------------------------------------------------------------------
    // Reset generation (active-low) & Baud rate set to 115200
    // ---------------------------------------------------------------------------
    task automatic apply_reset(input int cycles = 10);
        begin
        baud_setting = BAUD_SET_115200;
        rstn = 1'b0;
        repeat (cycles) @(posedge clk_16mhz);
        rstn = 1'b1;
        @(posedge clk_16mhz);
        end
    endtask

    // ---------------------------------------------------------------------------
    // Serial loopback: connect TX to RX
    // ---------------------------------------------------------------------------
    assign serial_in = serial_out;

    // ---------------------------------------------------------------------------
    // DUT instantiation
    // ---------------------------------------------------------------------------
    uart_top_level_interface #(
        .INPUT_DATA_WIDTH (INPUT_DATA_WIDTH),
        .OUTPUT_DATA_WIDTH(OUTPUT_DATA_WIDTH),
        .F_CLK            (16_000_000)
    ) dut (
        .clk_16mhz     (clk_16mhz),
        .rstn          (rstn),

        .data_in       (data_in),
        .tx_start      (tx_start),
        .TOTAL_TX_BYTES(TOTAL_TX_BYTES),
        .baud_setting  (baud_setting),
        .tx_done_pulse (tx_done_pulse),
        .serial_out    (serial_out),

        .serial_in     (serial_in),
        .data_out      (data_out),
        .rx_done_pulse (rx_done_pulse),
        .rx_start_pulse(rx_start_pulse),
        .rx_error      (rx_error)
    );

    //simple scoreboard
    logic [INPUT_DATA_WIDTH - 1:0] expected[TX_BYTES_NUM];
    int i;
    initial begin
        for (i = 0; i < TX_BYTES_NUM; i = i + 1)
            expected[i] = 8'hff - i * 7;
    end
    logic [INPUT_DATA_WIDTH - 1:0] received[TX_BYTES_NUM];

    task automatic send_bytes();
        begin
        TOTAL_TX_BYTES = TX_BYTES_NUM;
        @(posedge clk_16mhz);
        tx_start = 1'b1;

        for (i = 0; i < TX_BYTES_NUM; i = i + 1)
            begin
                data_in = expected[i];
                $display("[%0t ps] TX byte=0x%02h", $time, data_in);
                @ (posedge dut.tx_byte_done_pulse === 1'b1); // blocking 
            end
    
        @(posedge clk_16mhz); // one extra cycle for clean edge
        end
    endtask

    task automatic compare_received();
        for (i = 0; i < TX_BYTES_NUM; i = i + 1)
            begin
                assert(expected[i] == received[i])
                else begin
                    $fatal(1,"@ index %0d: Expected -> 0x%0h | Received -> 0x%0h\n Test Failed", i, expected[i], received[i]);
                    $finish;
                end
            end
        $display("Test Complete. Test Passed");
        $finish;
    endtask

    int rx_count;
    always @ (posedge clk_16mhz) begin
        if (!rstn) rx_count <= 0;
        if (rx_done_pulse) begin
            rx_count <= rx_count + 1;
            received[rx_count] <= data_out;
            $display("[%0t ps] RX byte=0x%02h", $time, data_out);
        end
    end

    initial begin
        apply_reset(10);
        tx_start = 1'b0;
        serial_in = 1'b1;
        serial_out = 1'b1;
        //Reset everything set UART line to idle mode

        send_bytes();

        compare_received();
    end


endmodule