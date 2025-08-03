module instr_decoder (
    input logic [6:0] opcode,
    output logic [1:0] immSrc
);

    always_comb begin
        if (opcode[1:0] == 2'b11) begin //The least two significant bits of opcode for RV32I should always be 11
            case (opcode[6:2])
                5'b0:     immSrc = 2'b00; //I_type -> Load
                5'b00100: immSrc = 2'b00; //I_type -> ALU
                5'b01000: immSrc = 2'b01; //S_type
                5'b01100: immSrc = 2'b00; //R_type
                5'b11000: immSrc = 2'b10; //B_type
                5'b11011: immSrc = 2'b11; //J_type
                default:  immSrc = 2'b00; //Should never be in this state
            endcase
        end
        else begin
            immSrc = 2'bxx; //Should never be in this state
        end
            
    end
    
endmodule