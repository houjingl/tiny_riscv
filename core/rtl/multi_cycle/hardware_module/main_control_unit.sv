`include "core\rtl\multi_cycle\hardware_module\mux_ctrl.svh"

module main_control_unit (
    input logic clk,
    input logic rstn,

    input logic zeroFlag,
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic funct7_5,
    
    output logic PCWrite,
    output logic RegWrite,          
    output logic MemWrite,          
    output logic IRWrite,
    //FF enable signals end
    //MUX control signals begin
    output result_src_t ResultSrc,
    output alu_src_b_t ALUSrcB,
    output alu_src_a_t ALUSrcA,
    output adr_src_t AdrSrc,
    output logic [2:0] ALUControl,
    output logic [1:0] immSrc
);

    alu_op_t ALUop;

    instr_decoder INSTR_DECODER (
        .opcode(opcode),
        .immSrc(immSrc)
    );

    alu_decoder ALU_DECODER (
        .opcode(opcode),
        .funct3(funct3),
        .ALUop(ALUop),
        .funct7_5(funct7_5),
        .ALUControl(ALUControl)
    );

    main_FSM CTRL_FSM (
        .clk(clk),
        .rstn(rstn),
        .opcode(opcode),
        .branch(branch),
        .PCupdate(PCupdate),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .IRWrite(IRWrite),
        .ResultSrc(ResultSrc),
        .ALUSrcB(ALUSrcB),
        .ALUSrcA(ALUSrcA),
        .AdrSrc(AdrSrc),
        .ALUop(ALUop) 
    );
    
endmodule