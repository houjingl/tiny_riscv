module instruction_mem (
    // input logic rstn, clk,
    input logic [31:0] mem_addr,
    output logic [31:0] instr
);

    logic [31:0] memory_cell [63:0];

    // always_ff@(posedge clk) begin : memory_reset
    //     if(!rstn) memory_cell = '{default: 32'h0};
    // end

    initial begin
        $readmemh("riscv_test_program.txt", memory_cell);
    end

    assign instr = memory_cell[mem_addr[31:2]]; //ensure the memory is word addressable


endmodule