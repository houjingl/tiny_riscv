module ALU(
    input logic [31:0] SrcA, SrcB,
    input logic [2:0]ALUControl,
    output logic zeroFlag,
    output logic [31:0] ALUOut
);
    /*
    ALUControl Summary:
    000 -> Add
    001 -> Sub
    101 -> set less than
    011 -> or
    010 -> and
    */
    localparam [2:0] ADD = 3'b000, SUB = 3'b001, SLT = 3'b101, OR = 3'b011, AND = 3'b010;

    always_comb begin
        unique case (ALUControl)
            ADD : ALUOut = SrcA + SrcB;
            SUB : ALUOut = SrcA - SrcB;
            SLT : ALUOut = ($signed(SrcA) < $signed(SrcB)) ? 32'd1 : 32'd0;
            OR  : ALUOut = SrcA | SrcB;
            AND : ALUOut = SrcA & SrcB;
            default: ALUOut = -1; // Should never be triggered
        endcase
    end

    assign zeroFlag = (ALUOut == 32'b0) ? 1:0;

endmodule