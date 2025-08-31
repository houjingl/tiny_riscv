module PC_ff (
    input logic clk, rstn,
    input logic [31:0] PCNext,
    output logic [31:0] PC
);

    always_ff@(posedge clk) begin
        if(!rstn)
            PC <= 32'b0;
        else
            PC <= PCNext;
    end


endmodule