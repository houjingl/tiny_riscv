`include "core\rtl\multi_cycle\hardware_module\mux_ctrl.svh"

module multi_cycle #(
    parameter integer C_DATA_WIDTH = 32
) (
    input logic clk,
    input logic rstn
);
    logic [C_DATA_WIDTH-1 : 0] PCNext;
    logic [C_DATA_WIDTH-1 :0] PC;
    //PC FF
    ff_en PC_ff (
        .clk(clk),
        .en(PCWrite),
        .rstn(rstn),
        .d(PCNext),
        .q(PC)
    );
    
    //mem
    logic [C_DATA_WIDTH - 1:0] Adr, memDataRd, memDataWt, Result;

    assign Adr = (AdrSrc == ADR_SRC_PC) ? PC : Result;

    system_mem MEM (
        .clk(clk),
        .addr_in(Adr),
        .data_write_en(MemWrite),
        .write_data_in(memDataWt),
        .read_data_out(memDataRd)
    );

    //Non_arch old PC & mem ff
    logic [C_DATA_WIDTH - 1:0] OLDPc, instr;
    always @ (posedge clk) begin
        if (!rstn) begin
            OLDPc <= 32'b0;
            instr <= 32'b0;
        end
        else if (IRWrite) begin
            OLDPc <= PC;
            instr <= memDataRd;
        end
    end

    //DR
    logic [C_DATA_WIDTH - 1: 0] Data;
    ff_en DataReg (
        .clk(clk),
        .rstn(rstn),
        .en(1'b1),
        .d(memDataRd),
        .q(data)
    );

    //Reg File
    logic [C_DATA_WIDTH - 1:0] rf_rd1, rf_rd2, a;
    register_file RF (
        .w_en(RegWrite),
        .clk(clk),
        .addr1(instr[19:15]),
        .addr2(instr[24:20]),
        .addr_w(instr[11:7]),
        .w_data(Result),
        .r_data1(rf_rd1),
        .r_data2(rf_rd2)
    );

    //Non_arch rf read reg
    always @ (posedge clk) begin
        if (!rstn) begin
            a <= 32'b0;
            memDataWt <= 32'b0;
        end
        else if (IRWrite) begin
            a <= rf_rd1;
            memDataWt <= rf_rd2;
        end
    end

    //immext
    logic [C_DATA_WIDTH-1 :0] immExt;
    imm_extend IMMEXT (
        .immSrc(immSrc),
        .instr(instr),
        .imm32(immExt)
    );
    
    logic [C_DATA_WIDTH -1 :0] srcA, srcB;
    assign srcA = (ALUSrcA == ALU_SRC_A_PC) ? PC :
                  ((ALUSrcA == ALU_SRC_A_OLDPC) ? OldPC :
                  ((ALUSrcA == ALUSRC_A_RD1)? a :
                   32'b0));

    assign srcB = (ALUSrcB == ALU_SRC_B_RD2) ? memDataWt :
                  ((ALUSrcB == ALU_SRC_B_IMMEXT) ? immExt :
                  32'd4);
    //ALU
    logic [C_DATA_WIDTH -1 : 0] ALUResult;
    ALU RISCALU (.SrcA(srcA), .SrcB(srcB), .ALUControl(ALUControl), .zeroFlag(zeroFlag), .ALUOut(ALUResult));

    //Non arch ALU result Reg
    logic [C_DATA_WIDTH -1 : 0] ALUOut;
    ff_en ALURESULT (
        .clk(clk),
        .rstn(rstn),
        .en(1'b1),
        .d(ALUResult),
        .q(ALUOut)
    );

    assign Result = (ResultSrc == RESULT_SRC_ALUOUT) ? ALUOut :
                    ((RESULT_SRC_MEMDATA) ? Data : ALUResult);

    assign PCNext = Result;

    //Main Control Unit
    logic zeroFlag;

    logic PCWrite;
    logic RegWrite;          
    logic MemWrite;          
    logic IRWrite;
    //FF enable signals end
    //MUX control signals begin
    result_src_t ResultSrc;
    alu_src_b_t ALUSrcB;
    alu_src_a_t ALUSrcA;
    adr_src_t AdrSrc;
    logic [2:0] ALUControl;
    logic [2:0] immSrc;

    main_control_unit M_CTRL (
        .opcode    (instr[6:0]),
        .funct3    (instr[14:12]),
        .funct7_5  (instr[30:30]),
        .zeroFlag  (zeroFlag),
        .PCWrite   (PCWrite),
        .RegWrite  (RegWrite),
        .MemWrite  (MemWrite),
        .IRWrite   (IRWrite),
        .ResultSrc (ResultSrc),
        .ALUSrcB   (ALUSrcB),
        .ALUSrcA   (ALUSrcA),
        .AdrSrc    (AdrSrc),
        .ALUControl(ALUControl),
        .immSrc    (immSrc)
    );

endmodule
