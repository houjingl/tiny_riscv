`ifndef MUX_CTRL
`define  MUX_CTRL

`define C_DATA_BUS_WIDTH 32

typedef enum logic [0:0] {
    ADR_SRC_PC          = 1'b0,
    ADR_SRC_ALU_RESULT  = 1'b1,
    ADR_SRC_UNKNOWN     = 1'bx
} adr_src_t;

typedef enum logic [1:0] {
    ALU_SRC_A_PC        = 2'b00,
    ALU_SRC_A_OLDPC     = 2'b01,
    ALU_SRC_A_RD1       = 2'b10,
    ALU_SRC_A_ZERO      = 2'b11,
    ALU_SRC_A_UNKNOWN   = 2'bxx
} alu_src_a_t;

typedef enum logic [1:0] {
    ALU_SRC_B_RD2       = 2'b00,
    ALU_SRC_B_IMMEXT    = 2'b01,
    ALU_SRC_B_FOUR      = 2'b10,
    ALU_SRC_B_UNKNOWN   = 2'bxx
} alu_src_b_t;

typedef enum logic [1:0] {
    RESULT_SRC_ALUOUT   = 2'b00,
    RESULT_SRC_MEMDATA  = 2'b01,
    RESULT_SRC_ALURESULT= 2'b10,
    RESULT_SRC_UNKNOWN  = 2'bxx
} result_src_t;

typedef enum logic [1:0] {
    ALU_OP_ADD          = 2'b00,
    ALU_OP_SUB          = 2'b01,
    ALU_OP_FUNCT3       = 2'b10,
    ALU_OP_UNKNOWN      = 2'bxx
} alu_op_t;

`endif