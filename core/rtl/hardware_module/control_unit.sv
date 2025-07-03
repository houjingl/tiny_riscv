module control_unit(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic funct7_5, zeroFlag,
    output logic PCSrc, MemWrite, ALUSrc, RegWrite,
    output logic [1:0] ResultSrc, immSrc,
    output logic [2:0] ALUControl
); 

    logic branch, jump;
    logic [1:0] ALUop;

    assign PCSrc = (zeroFlag & branch) | jump;

    alu_decoder ALU_DECODER(.opcode(opcode), .funct3(funct3), .funct7_5(funct7_5), .ALUop(ALUop), .ALUControl(ALUControl));
    main_decoder MAIN_DECODER(.opcode(opcode), .branch(branch), .jump(jump), .ResultSrc(ResultSrc), .MemWrite(MemWrite), .ALUSrc(ALUSrc), .immSrc(immSrc), .RegWrite(RegWrite), .ALUop(ALUop));

endmodule