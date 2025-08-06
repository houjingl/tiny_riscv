`ifndef FSM_TB_HELPER
`define FSM_TB_HELPER

`include "mux_ctrl.svh"

`define C_NUM_OF_OPCODES 6

typedef enum logic [4:0] {
    FETCH     = 5'b00000,  // Fetch instruction and PC inc
    DECODE    = 5'b00001,  // Decode opcode and OldPC + immExt -> ALUOUT
    // Below States are determined by the OPcode
    // lw
    MEMADR    = 5'b00010,  // Compute target memory address
    MEMREAD   = 5'b00011,  // Read data from memory
    MEMWB     = 5'b00100,  // Write back to RF
    // sw
    MEMWRITE  = 5'b00101,  // Save word to memory
    // R-type Register
    EXECUTER  = 5'b00110,  // ALU with reg and reg
    // I-type Immediate       
    EXECUTEI  = 5'b01000,  // ALU with Reg and imm
    ALUWB     = 5'b00111,  // ALU writeback to RF
    // jal
    JAL       = 5'b01001,  // Jump to target addr
    // beq
    BEQ       = 5'b01010,  // Conditionally branch to target addr
    // ERROR
    ERROR     = 5'bxxxxx
} fsm_state_t;

typedef enum logic[6:0] {
    I_TYPE_MEM = 7'b0000011,
    S_TYPE     = 7'b0100011,
    R_TYPE     = 7'b0110011,
    I_TYPE_ALU = 7'b0010011,
    J_TYPE_JAL = 7'b1101111,
    B_TYPE     = 7'b1100011
} op_code_t;

//class FSM_tb_helper;
//    op_code_t opcode;
//    reg [4:0] exe_sequence;

////     // logic branch;
////     // logic PCupdate;
////     // logic RegWrite;
////     // logic MemWrite;
////     // logic IRWrite;

////     // result_src_t ResultSrc;
////     // alu_src_b_t ALUSrcB;
////     // alu_src_a_t ALUSrcA;
////     // adr_src_t AdrSrc;
////     // alu_op_t ALUop;
//    function new(op_code_t new_op_code);
//        this.opcode = new_op_code;
//        case(new_op_code)
//            I_TYPE_MEM: begin
//                for(int i = 0; i < 5; i = i + 1);
//                begin
                    
//                end
//            end
//            S_TYPE: begin
//            // TODO: Add test for S_TYPE
//            end
//            R_TYPE: begin
//            // TODO: Add test for R_TYPE
//            end
//            I_TYPE_ALU: begin
//            // TODO: Add test for I_TYPE_ALU
//            end
//            J_TYPE_JAL: begin
//            // TODO: Add test for J_TYPE_JAL
//            end
//            B_TYPE: begin
//            // TODO: Add test for B_TYPE
//            end
//        endcase
//    endfunction //new()
//endclass //FSM_state

`endif