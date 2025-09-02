# My Tiny RISC-V MCU Project

## I. Overview  
This project is my own implementation of a RISC-V processor series that supports the **RV32I** instruction set, with three architectural versions:  

- **Single-Cycle CPU**  
- **Multi-Cycle CPU**  
- **Pipelined CPU**  

The ultimate goal is to create a **functional RISC-V microcontroller** capable of serving basic embedded system needs. To achieve this, I am developing **GPIO peripherals** that can be integrated with the processor, including:  

- Memory-Mapped Register Interface  
- Memory Controller  
- I²C Controller  
- SPI Controller  
- UART Controller  

All CPU cores and peripherals are written in **SystemVerilog**. Each processor design and datapath is simulated in **Vivado** & **GTKWave** using SystemVerilog testbenches. For architectural correctness, the **RISCOF test framework** is also used to verify performance using Python scripts.  

---

## II. ReadMe Navigator  
- [Overview](#i-overview)  
- [ReadMe Navigator](#ii-readme-navigator)  
- [Project Contents](#iii-project-contents)  
- [Skills & Technologies Applied](#iv-skills--technologies-applied)  
- [Current Focus / Status](#v-current-focus--status)  
- [Next Steps / Roadmap](#vi-next-steps--roadmap)  

---

## III. Project Contents  

```bash
Core/        # Processor core digital design files, testbenches, and Vivado simulations
Peripheral/  # GPIO peripheral designs, testbenches, and Vivado simulations
Reference/   # Reference files and resources used during development
```

---

## IV. Skills & Technologies Applied  
- **HDL & Simulation**: SystemVerilog (CPU core + peripherals), testbench writing, RTL design & verification  
- **EDA Tools**: Xilinx Vivado, GTKWave  
- **Processor Architecture**: RISC-V RV32I ISA, datapath design (single-cycle, multi-cycle, pipelined)  
- **Verification Frameworks**: RISCOF test framework, Python-based instruction tests  
- **Bus & Interface Design**: Memory-Mapped Register Interface, AXI-Lite concepts, custom memory controller  
- **Peripheral Design**: UART, SPI, I²C controllers from scratch  
- **Embedded Systems Context**: Building toward a microcontroller usable for real applications  

---

## V. Current Focus / Status  
1. Designing **instruction-directed testbenches** to cover most commonly used RV32I instructions.  
2. Implementing the **Memory Controller** and **Memory-Mapped Register Interface**, and integrating them with the **UART controller**.  

---

## VI. Next Steps / Roadmap  
1. Implement remaining hardware peripherals (SPI, I²C, GPIO).  
2. Develop the **hazard control unit** required for the pipelined RISC-V CPU.  
3. Expand test coverage with RISCOF and real software programs.  
4. Prepare for FPGA deployment and hardware-in-the-loop testing.  

---





## III. Project Contents  


