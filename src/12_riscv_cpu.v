module riscv_cpu (
    input wire clk,
    input wire reset
);

    // ============================================================
    // 1. PROGRAM COUNTER
    // ============================================================

    wire [31:0] PC;
    wire [31:0] nextPC;

    pc_register pc_reg (
        .clk(clk),
        .reset(reset),
        .nextPC(nextPC),
        .PC(PC)
    );


    // ============================================================
    // 2. INSTRUCTION FETCH
    // ============================================================

    wire [31:0] instruction;

    instruction_memory instr_mem (
        .address(PC),
        .instruction(instruction)
    );


    // ============================================================
    // 3. INSTRUCTION FIELDS
    // ============================================================

    wire [6:0] opcode;
    wire [4:0] rd;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];


    // ============================================================
    // 4. CONTROL UNIT
    // ============================================================

    wire       RegWrite;
    wire       MemRead;
    wire       MemWrite;

    wire [1:0] ALUSrcA;
    wire       ALUSrc;

    wire [1:0] ResultSrc;

    wire       Branch;
    wire       Jump;

    wire [3:0] ALUControl;
    wire [2:0] ImmSrc;

    wire [1:0] MemSize;
    wire       LoadUnsigned;

    wire [2:0] BranchType;

    control_unit control (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),

        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),

        .ALUSrcA(ALUSrcA),
        .ALUSrc(ALUSrc),

        .ResultSrc(ResultSrc),

        .Branch(Branch),
        .Jump(Jump),

        .ALUControl(ALUControl),
        .ImmSrc(ImmSrc),

        .MemSize(MemSize),
        .LoadUnsigned(LoadUnsigned),

        .BranchType(BranchType)
    );


    // ============================================================
    // 5. IMMEDIATE GENERATOR
    // ============================================================

    wire [31:0] immediate;

    immediate_generator imm_gen (
        .instruction(instruction),
        .ImmSrc(ImmSrc),
        .immediate(immediate)
    );


    // ============================================================
    // 6. REGISTER FILE
    // ============================================================

    wire [31:0] rs1Data;
    wire [31:0] rs2Data;

    wire [31:0] writeData;

    register_file registers (
        .clk(clk),
        .RegWrite(RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .writeData(writeData),
        .readData1(rs1Data),
        .readData2(rs2Data)
    );


    // ============================================================
    // 7. ALU INPUT A MUX
    // ============================================================

    wire [31:0] aluA;

    assign aluA =
        (ALUSrcA == 2'b00) ? rs1Data :
        (ALUSrcA == 2'b01) ? PC :
        (ALUSrcA == 2'b10) ? 32'b0 :
                             32'b0;


    // ============================================================
    // 8. ALU INPUT B MUX
    // ============================================================

    wire [31:0] aluB;

    alu_input_mux alu_mux (
        .rs2Data(rs2Data),
        .immediate(immediate),
        .ALUSrc(ALUSrc),
        .aluB(aluB)
    );


    // ============================================================
    // 9. ALU
    // ============================================================

    wire [31:0] aluResult;

    alu main_alu (
        .A(aluA),
        .B(aluB),
        .ALUControl(ALUControl),
        .Result(aluResult)
    );


    // ============================================================
    // 10. DATA MEMORY
    // ============================================================

    wire [31:0] memoryData;

    data_memory data_mem (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(aluResult),
        .writeData(rs2Data),
        .MemSize(MemSize),
        .LoadUnsigned(LoadUnsigned),
        .readData(memoryData)
    );


    // ============================================================
    // 11. BRANCH UNIT
    // ============================================================

    wire BranchTaken;

    branch_unit branch_logic (
        .rs1(rs1Data),
        .rs2(rs2Data),
        .BranchType(BranchType),
        .BranchTaken(BranchTaken)
    );


    // ============================================================
    // 12. JALR DETECTION
    // ============================================================

    wire JALR;

    assign JALR = (opcode == 7'b1100111);


    // ============================================================
    // 13. NEXT PC LOGIC
    // ============================================================

    next_pc_logic next_pc (
        .PC(PC),
        .branchImmediate(immediate),
        .jalImmediate(immediate),
        .jalrImmediate(immediate),
        .rs1(rs1Data),
        .BranchTaken(Branch && BranchTaken),
        .Jump(Jump),
        .JALR(JALR),
        .nextPC(nextPC)
    );


    // ============================================================
    // 14. PC + 4
    // ============================================================

    wire [31:0] PCPlus4;

    assign PCPlus4 = PC + 32'd4;


    // ============================================================
    // 15. WRITEBACK MUX
    // ============================================================
    writeback_mux wb_mux (
        .aluResult(aluResult),
        .memoryData(memoryData),
        .PCPlus4(PCPlus4),
        .ResultSrc(ResultSrc),
        .writeData(writeData)
    );
    

endmodule