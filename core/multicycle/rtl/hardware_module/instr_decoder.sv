module instr_decoder (
    input logic [6:0] opcode,
    output logic [2:0] immSrc
);

    always_comb begin
        if (opcode[1:0] == 2'b11) begin //The least two significant bits of opcode for RV32I should always be 11
            case (opcode[6:2])
                5'b0:     immSrc = 3'b000; //I_type_mem -> Load
                5'b00100: immSrc = 3'b000; //I_type_alu -> ALU
                5'b01000: immSrc = 3'b001; //S_type
                5'b01100: immSrc = 3'b000; //R_type
                5'b11000: immSrc = 3'b010; //B_type
                5'b11011: immSrc = 3'b011; //J_type
                5'b01101: immSrc = 3'b100; //U_type
                default:  immSrc = 3'b000; //Should never be in this state
            endcase
        end
        else begin
            immSrc = 2'bxx; //Should never be in this state
        end
            
    end
    
endmodule