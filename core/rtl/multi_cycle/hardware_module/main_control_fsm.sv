`include "core\rtl\multi_cycle\hardware_module\mux_ctrl.svh"

module main_FSM(
    //System Clock and reset
    input logic clk,
    input logic rstn,
    //Control signals
    input logic [6:0] opcode,
    //FF enable signals begin
    output logic branch,            
    output logic PCupdate,          
    output logic RegWrite,          
    output logic MemWrite,          
    output logic IRWrite,
    //FF enable signals end
    //MUX control signals begin
    output result_src_t ResultSrc,
    output alu_src_b_t ALUSrcB,
    output alu_src_a_t ALUSrcA,
    output adr_src_t AdrSrc,
    output alu_op_t ALUop
    //MUX control signals end
);
    //This FSM will be a Moore FSM i.e. Outputs are only related to the present state

    //FSM state encoding
    logic [4:0] fsm_current_state, fsm_next_state;
    localparam [4:0] FETCH     = 5'b00000,  //Fetch instruction and PC inc
                     DECODE    = 5'b00001,  //Decode opcode and OldPC + immExt -> ALUOUT
                    //Below States are determined by the OPcode
                    //lw
                     MEMADR    = 5'b00010,  //Compute target memory address
                     MEMREAD   = 5'b00011,  //Read data from memory
                     MEMWB     = 5'b00100,  //Write back to RF
                    //sw
                     MEMWRITE  = 5'b00101,  //Save word to memory
                    //R-type Register
                     EXECUTER  = 5'b00110,  //ALU with reg and reg
                    //I-type Immediate       
                     EXECUTEI  = 5'b01000,  //ALU with Reg and imm
                     ALUWB     = 5'b00111,  //ALU writeback to RF
                    //jal
                     JAL       = 5'b01001,  //Jump to target addr
                    //beq
                     BEQ       = 5'b01010,  //Conditionally branch to target addr
                    //lui
                     LUI       = 5'b01011, //add immext with hardware 0

                     //ERROR
                     ERROR     = 5'bxxxxx
                    ;

    // RV32I opcode definitions
    localparam [6:0] I_TYPE_MEM = 7'b0000011,
                     S_TYPE     = 7'b0100011,
                     R_TYPE     = 7'b0110011,
                     I_TYPE_ALU = 7'b0010011,
                     J_TYPE_JAL = 7'b1101111,
                     B_TYPE     = 7'b1100011,
                     U_TYPE     = 7'b0110111;


    //FSM Next State Logic
    always_comb begin
        case(fsm_current_state)
            FETCH:
                fsm_next_state = DECODE;
            DECODE:
                case(opcode)
                    I_TYPE_MEM:
                        fsm_next_state = MEMADR;
                    S_TYPE:
                        fsm_next_state = MEMADR;
                    R_TYPE:
                        fsm_next_state = EXECUTER;
                    I_TYPE_ALU:
                        fsm_next_state = EXECUTEI;
                    J_TYPE_JAL:
                        fsm_next_state = JAL;
                    B_TYPE:
                        fsm_next_state = BEQ;
                    U_TYPE: 
                        fsm_next_state = LUI; // LUI change
                    default:
                        fsm_next_state = ERROR;
                endcase
            MEMADR:
                case(opcode)
                    I_TYPE_MEM:
                        fsm_next_state = MEMREAD;
                    S_TYPE:
                        fsm_next_state = MEMWRITE;
                    default:
                        fsm_next_state = ERROR;
                endcase
            MEMREAD:
                fsm_next_state = MEMWB;
            MEMWB:
                fsm_next_state = FETCH;
            MEMWRITE:
                fsm_next_state = FETCH;
            EXECUTER:
                fsm_next_state = ALUWB;
            EXECUTEI:
                fsm_next_state = ALUWB;
            JAL:
                fsm_next_state = ALUWB;
            LUI:
                fsm_next_state = ALUWB; //LUI change
            ALUWB:
                fsm_next_state = FETCH;
            BEQ:
                fsm_next_state = FETCH;
            default:
                fsm_next_state = ERROR;
        endcase
    end

    //FSM output logic
    //NOTE: For all the FF control signals, must be set to 0 if not asserted
    //      -> the sequential logics will affect the state of the processor @ rising edge, must be strictly regulated
    //      For all the Mux Control and ALU control signals, if not needed in that state, are seen as DONT CARE
    always_comb begin
        case(fsm_current_state)
            FETCH: begin
                // Outputs for FETCH state
                IRWrite   = 1'b1;
                PCupdate  = 1'b1;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                branch    = 1'b0;

                ALUSrcA   = ALU_SRC_A_PC;
                ALUSrcB   = ALU_SRC_B_FOUR;
                ALUop     = ALU_OP_ADD;
                ResultSrc = RESULT_SRC_ALURESULT;
            end
            DECODE: begin
                // Outputs for DECODE state
                IRWrite   = 1'b0;
                PCupdate  = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                branch    = 1'b0;

                ALUSrcA   = ALU_SRC_A_OLDPC;
                ALUSrcB   = ALU_SRC_B_IMMEXT;
                ALUop     = ALU_OP_ADD;
            end
            MEMADR: begin
                // Outputs for MEMADR state
                IRWrite   = 1'b0;
                PCupdate  = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                branch    = 1'b0;

                ALUSrcA   = ALU_SRC_A_RD1;
                ALUSrcB   = ALU_SRC_B_IMMEXT;
                ALUop     = ALU_OP_ADD;
            end
            MEMREAD: begin
                // Outputs for MEMREAD state
                IRWrite   = 1'b0;
                PCupdate  = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                branch    = 1'b0;

                ResultSrc = RESULT_SRC_ALUOUT;
                AdrSrc    = ADR_SRC_ALU_RESULT;
            end
            MEMWB: begin
                // Outputs for MEMWB state
                IRWrite   = 1'b0;
                PCupdate  = 1'b0;
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                branch    = 1'b0;

                ResultSrc = RESULT_SRC_ALUOUT;
                AdrSrc    = ADR_SRC_ALU_RESULT;
            end
            MEMWRITE: begin
                // Outputs for MEMWRITE state
                IRWrite   = 1'b0;
                PCupdate  = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b1;
                branch    = 1'b0;

                ResultSrc = RESULT_SRC_ALUOUT;
                AdrSrc    = ADR_SRC_ALU_RESULT;
            end
            EXECUTER: begin
                // Outputs for EXECUTER state
                IRWrite   = 1'b0;
                PCupdate  = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                branch    = 1'b0;

                ALUSrcA   = ALU_SRC_A_RD1;
                ALUSrcB   = ALU_SRC_B_RD2;
                ALUop     = ALU_OP_FUNCT3;
            end
            EXECUTEI: begin
                // Outputs for EXECUTEI state
                IRWrite   = 1'b0;
                PCupdate  = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                branch    = 1'b0;

                ALUSrcA   = ALU_SRC_A_RD1;
                ALUSrcB   = ALU_SRC_B_IMMEXT;
                ALUop     = ALU_OP_FUNCT3;
            end
            JAL: begin
                // Outputs for JAL state
                IRWrite   = 1'b0;
                PCupdate  = 1'b1;
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                branch    = 1'b0;

                ALUSrcA   = ALU_SRC_A_OLDPC;
                ALUSrcB   = ALU_SRC_B_FOUR;
                ALUop     = ALU_OP_ADD;
                ResultSrc = RESULT_SRC_ALUOUT;
            end
            LUI:begin
                IRWrite   = 1'b0;
                PCupdate  = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                branch    = 1'b0;

                ALUSrcA = ALU_SRC_A_ZERO;
                ALUSrcB = ALU_SRC_B_IMMEXT;
                ALUop = ALU_OP_ADD;
            end
            ALUWB: begin
                // Outputs for ALUWB state
                IRWrite   = 1'b0;
                PCupdate  = 1'b0;
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                branch    = 1'b0;

                ResultSrc = RESULT_SRC_ALUOUT;
            end
            BEQ: begin
                // Outputs for BEQ state
                IRWrite   = 1'b0;
                PCupdate  = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                branch    = 1'b1;

                ALUSrcA   = ALU_SRC_A_RD1;
                ALUSrcB   = ALU_SRC_B_RD2;
                ALUop     = ALU_OP_SUB;
                ResultSrc = RESULT_SRC_ALUOUT;
            end
            default: begin
                branch    = 'x;
                PCupdate  = 'x;
                RegWrite  = 'x;
                MemWrite  = 'x;
                IRWrite   = 'x;
                ResultSrc = RESULT_SRC_UNKNOWN;
                ALUSrcB   = ALU_SRC_B_UNKNOWN;
                ALUSrcA   = ALU_SRC_A_UNKNOWN;
                AdrSrc    = ADR_SRC_UNKNOWN;
                ALUop     = ALU_OP_UNKNOWN;
            end
        endcase
    end
    //FSM Next State -> Current State FF
    always_ff @ (posedge clk) begin
        if (!rstn)
        begin
            fsm_current_state <= FETCH;
        end
        else
        begin
            fsm_current_state <= fsm_next_state;
        end
    end


endmodule