module single_cycle_riscv (
    input logic clk, //System Clock
    input logic system_rstn
);

//32 bits data lines
logic[31:0] PCNext, PC, PCplus4, PCTarget, //PC reg and PC ++
            instr, SrcA, SrcB, immext, //Register file 
            ALUResult, //ALU
            WriteData, ReadData, //Data Memory
            result; //To the WD port of RF

//Control Signals
logic PCSrc, MemWrite, ALUSrc, RegWrite;
logic [1:0] ResultSrc, immSrc;
logic [2:0] ALUControl;
logic zeroFlag;

//Data Path will be divided using state elements
//PC reg
assign PCNext = (PCSrc == 1'b1) ? PCTarget : PCplus4;
adder PCimm (.a(PC), .b(immext), .out(PCTarget));
adder PCinc (.a(PC), .b(32'd4), .out(PCplus4));
PC_ff PCREG (.clk(clk), .rstn(system_rstn), .PCNext(PCNext), .PC(PC));

//I-memory
instruction_mem IMEM (.mem_addr(PC), .instr(instr));

//RF
register_file RF (.w_en(RegWrite), .clk(clk), 
                .addr1(instr[19:15]), .addr2(instr[24:20]), .addr_w(instr[11:7]), .w_data(result),
                .r_data1(SrcA), .r_data2(WriteData));
imm_extend IMMEXT (.immSrc(immSrc), .instr(instr[31:7]), .imm32(immext));

//ALU
assign SrcB = (ALUSrc == 1'b0) ? WriteData : immext;
ALU RISCALU (.SrcA(SrcA), .SrcB(SrcB), .ALUControl(ALUControl), .zeroFlag(zeroFlag), .ALUOut(ALUResult));

//Data Memory
data_mem DATAMEM (.addr(ALUResult), .w_datain(WriteData), .w_enable(MemWrite), .clk(clk), .r_dataout(ReadData));

always_comb begin: result_selection_mux
    case(ResultSrc)
        2'b00: result = ALUResult;
        2'b01: result = ReadData;
        2'b10: result = PCplus4;
        default: result = 32'bx; 
    endcase
end

control_unit CONTROLU (.opcode(instr[6:0]), .funct3(instr[14:12]), .funct7_5(instr[30]), .zeroFlag(zeroFlag),
                    .PCSrc(PCSrc), .MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite), .ResultSrc(ResultSrc), .immSrc(immSrc), .ALUControl(ALUControl));

endmodule