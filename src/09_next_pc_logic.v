module next_pc_logic (

    input wire [31:0] PC,

    input wire [31:0] branchImmediate,
    input wire [31:0] jalImmediate,
    input wire [31:0] jalrImmediate,

    input wire [31:0] rs1,

    input wire        BranchTaken,
    input wire        Jump,
    input wire        JALR,

    output reg [31:0] nextPC

);

    always @(*) begin

        // Default:
        // normal sequential execution
        nextPC = PC + 32'd4;


        // =====================================
        // BRANCH
        // =====================================

        if (BranchTaken) begin

            nextPC = PC + branchImmediate;

        end


        // =====================================
        // JAL
        // =====================================

        if (Jump && !JALR) begin

            nextPC = PC + jalImmediate;

        end


        // =====================================
        // JALR
        // =====================================

        if (Jump && JALR) begin

            nextPC = rs1 + jalrImmediate;

            // RISC-V JALR clears bit 0
            nextPC[0] = 1'b0;   // lsb=0 for even addresses only as addreses are multiples of 4

        end

    end

endmodule