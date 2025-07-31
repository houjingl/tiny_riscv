module data_mem (
    input logic [31:0] addr, w_datain,
    input logic w_enable, clk,
    output logic [31:0] r_dataout
);

    logic [31:0] memory_cell [63:0];

    always_ff@(posedge clk) begin
        if (w_enable) begin
            memory_cell[addr[31:2]] <= w_datain;
        end
    end

    always_comb begin
        r_dataout = memory_cell[addr[31:2]];
    end
endmodule