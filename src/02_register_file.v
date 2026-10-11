module register_file (
    input  wire        clk,
    input  wire        RegWrite,

    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,

    input  wire [31:0] writeData,

    output wire [31:0] readData1,
    output wire [31:0] readData2
);

    // 32 registers, each 32 bits wide
    reg [31:0] registers [0:31];

    // Read operations
    assign readData1 = (rs1 == 5'b00000) ? 32'b0 : registers[rs1];
    assign readData2 = (rs2 == 5'b00000) ? 32'b0 : registers[rs2];

    // Write operation
    always @(posedge clk) begin

        if (RegWrite && (rd != 5'b00000))
            registers[rd] <= writeData;

    end

endmodule