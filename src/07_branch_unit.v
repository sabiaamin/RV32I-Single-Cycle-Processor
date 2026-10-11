module branch_unit (
    input wire [31:0] rs1,
    input wire [31:0] rs2,

    input wire [2:0] BranchType,

    output reg BranchTaken
);

    always @(*) begin

        // Default:
        // branch is NOT taken
        BranchTaken = 1'b0;

        case (BranchType)

            // =================================
            // BEQ
            // Branch if Equal
            // =================================
            3'b000:
                BranchTaken = (rs1 == rs2);


            // =================================
            // BNE
            // Branch if Not Equal
            // =================================
            3'b001:
                BranchTaken = (rs1 != rs2);


            // =================================
            // BLT
            // Branch if Less Than
            // Signed comparison
            // =================================
            3'b010:
                BranchTaken = ($signed(rs1) < $signed(rs2));


            // =================================
            // BGE
            // Branch if Greater or Equal
            // Signed comparison
            // =================================
            3'b011:
                BranchTaken = ($signed(rs1) >= $signed(rs2));


            // =================================
            // BLTU
            // Branch if Less Than
            // Unsigned comparison
            // =================================
            3'b100:
                BranchTaken = (rs1 < rs2);


            // =================================
            // BGEU
            // Branch if Greater or Equal
            // Unsigned comparison
            // =================================
            3'b101:
                BranchTaken = (rs1 >= rs2);


            default:
                BranchTaken = 1'b0;

        endcase

    end

endmodule