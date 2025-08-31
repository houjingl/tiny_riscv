module system_mem #(
    parameter integer C_MEMORY_CELLS = 1024, //4K byte memory
    parameter integer C_DATA_WIDTH = 32,
    parameter integer C_ADDR_WIDTH = 32
) (
    input logic clk,
    input logic [C_ADDR_WIDTH - 1:0] addr_in,
    input logic data_write_en,
    input logic [C_DATA_WIDTH - 1: 0] write_data_in,
    output logic [C_DATA_WIDTH - 1:0] read_data_out
);

    logic [C_DATA_WIDTH- 1: 0] memory_cells [0: C_MEMORY_CELLS - 1];

    //Need to load the memory cells with instructions in the testbench
    //May need to allocate a instruction specific location, set instructions to read only?

    always_comb begin
        read_data_out = memory_cells[addr_in[C_ADDR_WIDTH - 1: 2]]; //Ensuring memory is wordaddressable
    end

    always @(posedge clk) begin
        if(data_write_en) begin
            memory_cells[addr_in[C_ADDR_WIDTH - 1: 2]] <= write_data_in;
        end
    end
    
endmodule