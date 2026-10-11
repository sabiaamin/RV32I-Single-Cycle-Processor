module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,

    output reg        RegWrite,
    output reg        MemRead,
    output reg        MemWrite,

    output reg [1:0]  ALUSrcA,
    output reg        ALUSrc,

    output reg [1:0]  ResultSrc,

    output reg        Branch,
    output reg        Jump,

    output reg [3:0]  ALUControl,
    output reg [2:0]  ImmSrc,

    output reg [1:0]  MemSize,
    output reg        LoadUnsigned,

    output reg [2:0]  BranchType
);

    // Opcodes
    localparam R_TYPE     = 7'b0110011;
    localparam I_ALU      = 7'b0010011;
    localparam LOAD       = 7'b0000011;
    localparam STORE      = 7'b0100011;
    localparam BRANCH     = 7'b1100011;
    localparam LUI        = 7'b0110111;
    localparam AUIPC      = 7'b0010111;
    localparam JAL        = 7'b1101111;
    localparam JALR       = 7'b1100111;

    always @(*) begin

        // Default values
        RegWrite    = 1'b0;
        MemRead     = 1'b0;
        MemWrite    = 1'b0;

        ALUSrcA     = 2'b00;
        ALUSrc      = 1'b0;

        ResultSrc   = 2'b00;

        Branch      = 1'b0;
        Jump        = 1'b0;

        ALUControl  = 4'b0000;
        ImmSrc      = 3'b000;

        MemSize     = 2'b10;
        LoadUnsigned = 1'b0;

        BranchType  = 3'b000;


        case (opcode)

            // =====================================================
            // R-TYPE
            // ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
            // =====================================================
            R_TYPE: begin

                RegWrite = 1'b1;
                ALUSrcA  = 2'b00;
                ALUSrc  = 1'b0;
                ResultSrc = 2'b00;

                case (funct3)

                    3'b000: begin
                        if (funct7 == 7'b0100000)
                            ALUControl = 4'b0001; // SUB
                        else
                            ALUControl = 4'b0000; // ADD
                    end

                    3'b001:
                        ALUControl = 4'b0010; // SLL

                    3'b010:
                        ALUControl = 4'b0011; // SLT

                    3'b011:
                        ALUControl = 4'b0100; // SLTU

                    3'b100:
                        ALUControl = 4'b0101; // XOR

                    3'b101: begin
                        if (funct7 == 7'b0100000)
                            ALUControl = 4'b0111; // SRA
                        else
                            ALUControl = 4'b0110; // SRL
                    end

                    3'b110:
                        ALUControl = 4'b1000; // OR

                    3'b111:
                        ALUControl = 4'b1001; // AND

                    default:
                        ALUControl = 4'b0000;

                endcase
            end


            // =====================================================
            // I-TYPE ALU
            // ADDI, SLLI, SLTI, SLTIU, XORI, SRLI, SRAI, ORI, ANDI
            // MOV = ADDI rd, rs1, 0
            // =====================================================
            I_ALU: begin

                RegWrite = 1'b1;
                ALUSrcA  = 2'b00;
                ALUSrc   = 1'b1;
                ResultSrc = 2'b00;

                ImmSrc = 3'b000;

                case (funct3)

                    3'b000:
                        ALUControl = 4'b0000; // ADDI

                    3'b001:
                        ALUControl = 4'b0010; // SLLI

                    3'b010:
                        ALUControl = 4'b0011; // SLTI

                    3'b011:
                        ALUControl = 4'b0100; // SLTIU

                    3'b100:
                        ALUControl = 4'b0101; // XORI

                    3'b101: begin
                        if (funct7 == 7'b0100000)
                            ALUControl = 4'b0111; // SRAI
                        else
                            ALUControl = 4'b0110; // SRLI
                    end

                    3'b110:
                        ALUControl = 4'b1000; // ORI

                    3'b111:
                        ALUControl = 4'b1001; // ANDI

                    default:
                        ALUControl = 4'b0000;

                endcase
            end


            // =====================================================
            // LOAD
            // LB, LH, LW, LBU, LHU
            // =====================================================
            LOAD: begin

                RegWrite = 1'b1;
                MemRead  = 1'b1;

                ALUSrcA  = 2'b00;
                ALUSrc   = 1'b1;

                ResultSrc = 2'b01;

                ALUControl = 4'b0000; // address = rs1 + immediate
                ImmSrc = 3'b000;

                case (funct3)

                    3'b000: begin
                        MemSize = 2'b00;
                        LoadUnsigned = 1'b0; // LB
                    end

                    3'b001: begin
                        MemSize = 2'b01;
                        LoadUnsigned = 1'b0; // LH
                    end

                    3'b010: begin
                        MemSize = 2'b10;
                        LoadUnsigned = 1'b0; // LW
                    end

                    3'b100: begin
                        MemSize = 2'b00;
                        LoadUnsigned = 1'b1; // LBU
                    end

                    3'b101: begin
                        MemSize = 2'b01;
                        LoadUnsigned = 1'b1; // LHU
                    end

                    default: begin
                        MemSize = 2'b10;
                        LoadUnsigned = 1'b0;
                    end

                endcase
            end


            // =====================================================
            // STORE
            // SB, SH, SW
            // =====================================================
            STORE: begin

                MemWrite = 1'b1;

                ALUSrcA = 2'b00;
                ALUSrc  = 1'b1;

                ALUControl = 4'b0000; // address = rs1 + immediate
                ImmSrc = 3'b001;

                case (funct3)

                    3'b000:
                        MemSize = 2'b00; // SB

                    3'b001:
                        MemSize = 2'b01; // SH

                    3'b010:
                        MemSize = 2'b10; // SW

                    default:
                        MemSize = 2'b10;

                endcase
            end


            // =====================================================
            // BRANCH
            // BEQ, BNE, BLT, BGE, BLTU, BGEU
            // =====================================================
            BRANCH: begin

                Branch = 1'b1;

                ALUSrcA = 2'b00;
                ALUSrc  = 1'b0;

                ImmSrc = 3'b010;

                case (funct3)

                    3'b000:
                        BranchType = 3'b000; // BEQ

                    3'b001:
                        BranchType = 3'b001; // BNE

                    3'b100:
                        BranchType = 3'b010; // BLT

                    3'b101:
                        BranchType = 3'b011; // BGE

                    3'b110:
                        BranchType = 3'b100; // BLTU

                    3'b111:
                        BranchType = 3'b101; // BGEU

                    default:
                        BranchType = 3'b000;

                endcase
            end


            // =====================================================
            // LUI
            // rd = immediate
            // =====================================================
            LUI: begin

                RegWrite = 1'b1;

                ALUSrcA = 2'b10; // 0
                ALUSrc  = 1'b1;  // immediate

                ResultSrc = 2'b00;

                ALUControl = 4'b0000; // 0 + immediate
                ImmSrc = 3'b011;      // U-type

            end


            // =====================================================
            // AUIPC
            // rd = PC + immediate
            // =====================================================
            AUIPC: begin

                RegWrite = 1'b1;

                ALUSrcA = 2'b01; // PC
                ALUSrc  = 1'b1;  // immediate

                ResultSrc = 2'b00;

                ALUControl = 4'b0000; // PC + immediate
                ImmSrc = 3'b011;      // U-type

            end


            // =====================================================
            // JAL
            // rd = PC + 4
            // PC = PC + immediate
            // =====================================================
            JAL: begin

                RegWrite = 1'b1;
                Jump = 1'b1;

                ResultSrc = 2'b10; // PC + 4

                ImmSrc = 3'b100;   // J-type

            end


            // =====================================================
            // JALR
            // rd = PC + 4
            // PC = rs1 + immediate
            // =====================================================
            JALR: begin

                RegWrite = 1'b1;
                Jump = 1'b1;

                ALUSrcA = 2'b00;
                ALUSrc  = 1'b1;

                ResultSrc = 2'b10; // PC + 4

                ALUControl = 4'b0000;
                ImmSrc = 3'b000;  // I-type

            end


            default: begin
                // Keep all default values
            end

        endcase
    end

endmodule