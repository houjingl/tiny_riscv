`timescale 1ns/1ps
`include "core\testbench\multi_cycle\utils.svh"

module lw_tb();

    reg clk;
    reg rstn;

    multi_cycle uut (.clk(clk),
                     .rstn(rstn));
    
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    task wait_till_next_cfsm_state(input [5:0] expected_state);
        @(posedge clk); #1;
        `assert_equal(uut.control_fsm.current_state, expected_state)
    endtask

    initial begin
        reset = 1'b0;

        uut.MEM.memory_cells[ 0] = 32'h00012083; // lw x1, 0(x2)
        uut.MEM.memory_cells[ 1] = 32'h00412083; // lw x1, 4(x2)
        uut.MEM.memory_cells[ 2] = 32'hff812083; // lw x1, -8(x2)
        uut.MEM.memory_cells[40] = 32'hbadab00f; // have some data at address 0xa0
        uut.MEM.memory_cells[42] = 32'hdeadbeef; // have some data at address 0xa8
        uut.MEM.memory_cells[43] = 32'hcafebabe; // have some data at address 0xac

        // set up register file
        uut.RF.reg_file[2] = 32'ha8; // x2 = 42 * 4 = 168 = 0xa8

        wait_till_next_cfsm_state(uut.M_CTRL.CTRL_FSM.FETCH);

        reset = 1'b1;

        wait_till_next_cfsm_state(uut.M_CTRL.CTRL_FSM.DECODE);

        `assert_equal(uut.opcode, 7'b0000011)
        `assert_equal(uut.instruction_decode.instr[19:15], 2)
        `assert_equal(uut.instruction_decode.instr[24:20], 0)
        `assert_equal(uut.instruction_decode.immExt, 0)

        wait_till_next_cfsm_state(uut.control_fsm.MEMADR);

        //Check ALU input and output
        `assert_equal(uut.RF.reg_file[2], 32'ha8)
        `assert_equal(uut.srcA, 32'ha8)
        `assert_equal(uut.srcB, 0)
        `assert_equal(uut.ALUResult, 32'ha8)

        wait_till_next_cfsm_state(uut.control_fsm.MEMREAD);
        //Verify correct mem adr was provided by ALU
        `assert_equal(uut.Result, 32'ha8)
        `assert_equal(uut.Adr, 32'ha8)

        wait_till_next_cfsm_state(uut.control_fsm.MEMWB);

        //Check memory output
        `assert_equal(uut.data, 32'hdeadbeef) //from the data reg
        `assert_equal(uut.Result, 32'hdeadbeef) //Ensure that reg file gets this

        wait_till_next_cfsm_state(uut.control_fsm.FETCH);

        `assert_equal(uut.RF.reg_file[1], 32'hdeadbeef) //verify that rf did get deadbeef
        `assert_equal(uut.PC, 32'h4) //PC at this stage should be 4 already

        wait_till_next_cfsm_state(uut.M_CTRL.CTRL_FSM.DECODE);

        `assert_equal(uut.opcode, 7'b0000011)
        `assert_equal(uut.instruction_decode.instr[19:15], 2)
        `assert_equal(uut.instruction_decode.instr[24:20], 0)
        `assert_equal(uut.instruction_decode.immExt, 0)

        wait_till_next_cfsm_state(uut.control_fsm.MEMADR);

        //Check ALU input and output
        `assert_equal(uut.RF.reg_file[2], 32'ha8)
        `assert_equal(uut.srcA, 32'ha8)
        `assert_equal(uut.srcB, 4)
        `assert_equal(uut.ALUResult, 32'hac)

        wait_till_next_cfsm_state(uut.control_fsm.MEMREAD);
        //Verify correct mem adr was provided by ALU
        `assert_equal(uut.Result, 32'hac)
        `assert_equal(uut.Adr, 32'hac)

        wait_till_next_cfsm_state(uut.control_fsm.MEMWB);

        //Check memory output
        `assert_equal(uut.data, 32'hbadab00f) //from the data reg
        `assert_equal(uut.Result, 32'hbadab00f) //Ensure that reg file gets this

        wait_till_next_cfsm_state(uut.control_fsm.FETCH);

        `assert_equal(uut.RF.reg_file[1], 32'hbadab00f) //verify that rf did get deadbeef
        `assert_equal(uut.PC, 32'h8) //PC at this stage should be 4 already

        wait_till_next_cfsm_state(uut.M_CTRL.CTRL_FSM.DECODE);

        `assert_equal(uut.opcode, 7'b0000011)
        `assert_equal(uut.instruction_decode.instr[19:15], 2)
        `assert_equal(uut.instruction_decode.instr[24:20], 0)
        `assert_equal(uut.instruction_decode.immExt, 0)

        wait_till_next_cfsm_state(uut.control_fsm.MEMADR);

        //Check ALU input and output
        `assert_equal(uut.RF.reg_file[2], 32'ha8)
        `assert_equal(uut.srcA, 32'ha8)
        `assert_equal(uut.srcB, -8)
        `assert_equal(uut.ALUResult, 32'ha0)

        wait_till_next_cfsm_state(uut.control_fsm.MEMREAD);
        //Verify correct mem adr was provided by ALU
        `assert_equal(uut.Result, 32'ha0)
        `assert_equal(uut.Adr, 32'ha0)

        wait_till_next_cfsm_state(uut.control_fsm.MEMWB);

        //Check memory output
        `assert_equal(uut.data, 32'hcafebabe) //from the data reg
        `assert_equal(uut.Result, 32'hcafebabe) //Ensure that reg file gets this

        wait_till_next_cfsm_state(uut.control_fsm.FETCH);

        `assert_equal(uut.RF.reg_file[1], 32'hcafebabe) //verify that rf did get deadbeef
        `assert_equal(uut.PC, 32'hc) //PC at this stage should be 4 already

        $finish;
    end

    `SETUP_VCD_DUMP(lw_tb)

endmodule