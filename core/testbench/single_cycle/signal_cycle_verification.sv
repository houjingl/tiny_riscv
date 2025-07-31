`timescale 1ns/1ps
// module single_cycle_riscv (
//     input logic clk, //System Clock
//     input logic system_rstn,
//     input logic [31:0] instr,
//     input logic [31:0] ReadData,
//     output logic [31:0] PC,
//     output logic MemWrite,
//     output logic [31:0] ALUResult,
//     output logic [31:0] WriteData
// );

// I-memory
// instruction_mem IMEM (.mem_addr(PC), .instr(instr));
// Data Memory
// data_mem DATAMEM (.addr(ALUResult), .w_datain(WriteData), .w_enable(MemWrite), .clk(clk), .r_dataout(ReadData));

module testbench ();

    logic clk, rstn;

    parameter clk_cycle = 10; // 10ns

    always begin : clock_generator
        #(clk_cycle/2) clk <= ~clk;
    end

    initial begin
        $display("Resetting system \n");
        rstn <= 1'b0;
        #10;
    end

    //input logics
    logic [31:0] instr, ReadData;

    //output logics
    logic [31:0] PC, ALUResult, WriteData;
    logic MemWrite;

    // I-memory
    instruction_mem IMEM (.mem_addr(PC), .instr(instr));
    // Data Memory
    data_mem DATAMEM (.addr(ALUResult), .w_datain(WriteData), .w_enable(MemWrite), .clk(clk), .r_dataout(ReadData));
    single_cycle_riscv DUT (.clk(clk), .system_rstn(rstn), .instr(instr), .ReadData(ReadData), .PC(PC), .MemWrite(MemWrite), .ALUResult(ALUResult), .WriteData(WriteData));

    always@(negedge clk) begin : Score_board //Checking the last Sw instr
        if(MemWrite)
        begin
            if (ALUResult === 100 && WriteData === 25) begin
                $display("Simulation Result:");
                $display("Successful");
         
            end
            else if (ALUResult !== 96) begin
                $display("Simulation Result:");
                $display("Failed");
               
            end
        end
        else if (instr == 32'h0021_0063) // done j done
        begin
            $stop;
        end 
    end
   
endmodule