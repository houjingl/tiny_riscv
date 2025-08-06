`timescale 1ns/1ps
`include "mux_ctrl.svh"
`include "fsm_tb_helper.svh"
//Main FSM def
// module main_FSM

module tb_fsm ();
    // System Clock and reset
    logic clk;
    logic rstn;
    //Control signals
    op_code_t opcode;
    //FF enable signals begin
    logic branch;            
    logic PCupdate;          
    logic RegWrite;          
    logic MemWrite;          
    logic IRWrite;
    //FF enable signals end
    //MUX control signals begin
    result_src_t ResultSrc;
    alu_src_b_t ALUSrcB;
    alu_src_a_t ALUSrcA;
    adr_src_t AdrSrc;
    alu_op_t ALUop;
    //MUX control signals end

    always
    begin : clock_generator
        #5 clk <= ~clk;
    end

    main_FSM DUT(
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

    //Testing all the states of the FSM
    initial begin
        clk = 1'b0;
        rstn = 1'b0;
        #10;
        rstn = 1'b1;

        // Wait for FSM to enter FETCH state, then replace the opcode with the new one
        loop_through_all_opcodes();

        @(DUT.fsm_current_state == FETCH);
        @(DUT.fsm_current_state == FETCH);

        $finish;

    end

    function check_state(input fsm_state_t cur_state);
        begin
            
        end
    endfunction
    
    task loop_through_all_opcodes;
    begin 
        
        // cast the loop index back to the enum
        opcode = I_TYPE_MEM;
        @(posedge DUT.fsm_current_state == FETCH);
        // cast the loop index back to the enum
        opcode = I_TYPE_ALU;
        @(posedge DUT.fsm_current_state == FETCH);
        // cast the loop index back to the enum
        opcode = S_TYPE;
        @(posedge DUT.fsm_current_state == FETCH);
        // cast the loop index back to the enum
        opcode = B_TYPE;
        @(posedge DUT.fsm_current_state == FETCH);
        // cast the loop index back to the enum
        opcode = R_TYPE;
        @(posedge DUT.fsm_current_state == FETCH);
        // cast the loop index back to the enum
        opcode = J_TYPE_JAL;
        
    end 
    endtask 

    task check_exe(input op_code_t cur_opcode);
    begin
        case(cur_opcode)
            
        endcase
    end
    endtask





endmodule