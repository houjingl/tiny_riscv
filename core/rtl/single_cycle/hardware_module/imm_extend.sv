module imm_extend(
    input logic [1:0] immSrc,
    input logic [31:7] instr,
    output logic [31:0] imm32
);

    always_comb begin
        case (immSrc)
            2'b00: imm32 = {{20{instr[31]}}, instr[31:20]}; //I-type 12 bit imm
            2'b01: imm32 = {{20{instr[31]}}, instr[31:25], instr[11:7]}; //S-type 12 bit imm
            2'b10: imm32 = {{20{instr[31]}}, instr[7], instr[30:25],instr[11:8], 1'b0}; //B-type 13 bit imm
            2'b11: imm32 = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; //J-type 21 bit imm
        endcase    
    end

endmodule