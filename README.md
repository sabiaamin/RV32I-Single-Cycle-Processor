# RV32I Single-Cycle Processor

## 1. Project Overview

This project implements a 32-bit RISC-V RV32I single-cycle processor using Verilog HDL.

The processor executes each instruction in one clock cycle. Its datapath is organized into five logical stages: Instruction Fetch, Instruction Decode, Execute, Memory Access, and Writeback. These are not separate pipeline stages.

## 2. Instruction Support

The processor implements 37 instructions across the following categories:

- **R-type:** ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
- **I-type ALU:** ADDI, SLLI, SLTI, SLTIU, XORI, SRLI, SRAI, ORI, ANDI
- **Load:** LB, LH, LW, LBU, LHU
- **Store:** SB, SH, SW
- **Branch:** BEQ, BNE, BLT, BGE, BLTU, BGEU
- **Jump:** JAL, JALR
- **Upper immediate:** LUI, AUIPC

MOV is a pseudo-instruction and can be represented using ADDI with an immediate value of zero.

## 3. Project Structure

```text
RISV Processor/
├── src/
│   ├── 01_alu.v
│   ├── 02_register_file.v
│   ├── 03_immediate_generator.v
│   ├── 04_instruction_memory.v
│   ├── 05_control_unit.v
│   ├── 06_data_memory.v
│   ├── 07_branch_unit.v
│   ├── 08_pc_register.v
│   ├── 09_next_pc_logic.v
│   ├── 10_alu_input_mux.v
│   ├── 11_writeback_mux.v
│   └── 12_riscv_cpu.v
├── tb/
│   └── 12_riscv_cpu_tb.v
├── program/
│   └── program.mem
├── README.md
└── .gitignore
```

## 4. Main Components

- **ALU:** Performs arithmetic, logical, shift, and comparison operations.
- **Register File:** Stores 32 general-purpose registers.
- **Immediate Generator:** Extracts and extends instruction immediates.
- **Instruction Memory:** Stores the program's machine-code instructions.
- **Control Unit:** Decodes instructions and generates control signals.
- **Data Memory:** Handles load and store operations.
- **Branch Unit:** Evaluates conditional branches.
- **PC Register and Next-PC Logic:** Manage sequential execution, branches, and jumps.
- **Multiplexers:** Select ALU inputs and the register writeback result.
- **Top-Level CPU:** Connects all modules into the complete processor.

## 5. Requirements

- Visual Studio Code
- Icarus Verilog
- Windows PowerShell or a compatible terminal

## 6. How to Compile and Run

Open the terminal in the project root directory.

Compile the processor and testbench:

```powershell
iverilog -o cpu_sim src\01_alu.v src\02_register_file.v src\03_immediate_generator.v src\04_instruction_memory.v src\05_control_unit.v src\06_data_memory.v src\07_branch_unit.v src\08_pc_register.v src\09_next_pc_logic.v src\10_alu_input_mux.v src\11_writeback_mux.v src\12_riscv_cpu.v tb\12_riscv_cpu_tb.v
```

Run the simulation:

```powershell
vvp cpu_sim
```

The testbench displays the program counter, instruction, selected register values, and final test result.

## 7. Program Input

The file `program/program.mem` contains 32-bit machine-code instructions in hexadecimal format, one instruction per line.

The instruction memory loading range must cover all instructions in the program.

## 8. Testing

The processor has been simulated with arithmetic, logical, shift, load/store, branch, jump, and upper-immediate instructions. The final demonstration testbench executes representative instructions and checks expected register values.

## 9. Architecture

The processor follows the logical flow:

**Instruction Fetch → Instruction Decode → Execute → Memory Access → Writeback**

All these operations belong to a single instruction's clock cycle. The design is not pipelined.

## 10. Authors

- Sabia Amin — Enrollment No. 2024BITE002
- Abdul Mateen — Enrollment No. 2024BITE012

**Submitted to:** Dr. Janib Bashir