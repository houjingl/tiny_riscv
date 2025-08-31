module main_decoder (
    input logic [6:0] opcode,
    output logic jump, branch, MemWrite, ALUSrc, RegWrite,
    output logic [1:0] ResultSrc, immSrc, ALUop
);

    logic [10:0] control_signals;
    assign {RegWrite, immSrc, ALUSrc, MemWrite, ResultSrc, branch, ALUop, jump} = control_signals;

    always_comb begin
        if (opcode[1:0] == 2'b11) begin //The least two significant bits of opcode for RV32I should always be 11
            case (opcode[6:2])
                5'b0:     control_signals = 11'b1_00_1_0_01_0_00_0; //I_type -> Load
                5'b00100: control_signals = 11'b1_00_1_0_00_0_10_0; //I_type -> ALU
                5'b01000: control_signals = 11'b0_01_1_1_00_0_00_0; //S_type
                5'b01100: control_signals = 11'b1_00_0_0_00_0_10_0; //R_type
                5'b11000: control_signals = 11'b0_10_0_0_00_1_01_0; //B_type
                5'b11011: control_signals = 11'b1_11_0_0_10_0_00_1; //J_type
                default: control_signals = 11'b0; //Should never be in this state
            endcase
        end
        else begin
            control_signals = 11'bx_xx_x_x_xx_x_xx_x; //Should never be in this state
        end
            
    end

endmodule