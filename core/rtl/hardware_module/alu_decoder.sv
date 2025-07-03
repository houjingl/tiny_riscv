module alu_decoder(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [1:0] ALUop,
    input logic funct7_5,
    output logic [2:0] ALUControl
);
    localparam [2:0] ADD = 3'b000, SUB = 3'b001, SLT = 3'b101, OR = 3'b011, AND = 3'b010;

    logic op_5;
    assign op_5 = opcode[5:5];
    logic [1:0] op_funct7_5;
    assign op_funct7_5 = {op_5, funct7_5};

    always_comb begin
        case (ALUop)
            2'b00: ALUControl = ADD;
            2'b01: ALUControl = SUB;
            2'b10: begin
                case (funct3)
                    3'b000: begin
                        case (op_funct7_5)
                            2'b00, 
                            2'b01, 
                            2'b10: ALUControl = ADD;
                            2'b11: ALUControl = SUB;
                            default: ALUControl = 3'bxxx;
                        endcase
                    end
                    3'b010: ALUControl = SLT;
                    3'b110: ALUControl = OR;
                    3'b111: ALUControl = AND;
                    default: ALUControl = 3'bxxx;
                endcase
            end
            default: ALUControl = 3'bxxx;
        endcase
    end
endmodule