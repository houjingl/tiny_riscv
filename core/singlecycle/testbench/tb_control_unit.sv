`timescale 1ns/1ps

module tb();
    // Inputs to the main controller
     logic [6:0] opcode;
     logic [2:0] funct3;
     logic funct7_5, zeroFlag;
    
    // Outputs from the main controller 
    logic PCSrc, MemWrite, ALUSrc, RegWrite;
    logic [1:0] ResultSrc, immSrc;
    logic [2:0] ALUControl;

    logic [31:0] machine_code;
    localparam[31:0] lw_ = 32'hffc4_a303, sw_ = 32'h0064_a423, or_ = 32'h0062_e233, and_ = 32'hfe42_0ae3;

    assign opcode = machine_code[6:0];
    assign funct3 = machine_code[14:12];
    logic [7:0] funct7;
    assign funct7 = machine_code[31:25];
    assign funct7_5 = funct7[5];
    assign zeroFlag = 1'b1;

    control_unit UT (.opcode(opcode), .funct3(funct3), .funct7_5(funct7_5), .zeroFlag(zeroFlag), .PCSrc(PCSrc), 
                    .MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite), .ResultSrc(ResultSrc), .immSrc(immSrc), .ALUControl(ALUControl));

    initial begin
        #20;
        machine_code = lw_;

        #20;
        machine_code = sw_;

        #20;
        machine_code = or_;

        #20;
        machine_code = and_;
    end
endmodule