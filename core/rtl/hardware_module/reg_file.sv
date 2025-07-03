module register_file(
    input logic [0:0] w_en, clk, //rstn,
    input logic [5:0] addr1, addr2, addr_w,
    input logic [31:0] w_data,
    output logic [31:0] r_data1, r_data2
);

// For a RISCV processor, register file contains 32 32-bit registers
// Address inputs: A1 A2 A3 (Data Width = 6, 2^5 is 32)
// Data outputs: RD1 RD2
// Write Data input: WD1
// Write Enable: w_en

logic [31:0] reg_file[31:0];

always_ff @(posedge clk) begin
    // if (!rstn) begin
    //     reg_file <= '{default: 32'h0};
    // end
    if (w_en) begin
        reg_file[addr_w] <= w_data;
    end
    
end

always_comb begin //equivlent to always@(*)
    // If addr1 == 0, rdata output 0, same for rdata2
    // RISC V x0 hardwired to 0
    r_data1 = (addr1 != 32'h0) ? reg_file[addr1] : 0; 
    r_data2 = (addr2 != 32'h0) ? reg_file[addr2] : 0;
end
endmodule