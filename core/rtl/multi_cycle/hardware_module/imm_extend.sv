module imm_extend(
    input logic [2:0] immSrc,
    input logic [31:7] instr,
    output logic [31:0] imm32
);

    always_comb begin
        case (immSrc)
            3'b000: imm32 = {{20{instr[31]}}, instr[31:20]}; // I-type 12 bit imm
            3'b001: imm32 = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type 12 bit imm
            3'b010: imm32 = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type 13 bit imm
            3'b011: imm32 = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type 21 bit imm
            3'b100: imm32 = {instr[31:12], 12'b0}; // U-type 20 bit imm
        endcase
    end

endmodule