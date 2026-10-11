module writeback_mux (
    input wire [31:0] aluResult,
    input wire [31:0] memoryData,
    input wire [31:0] PCPlus4,
    input wire [1:0]  ResultSrc,
    output wire [31:0] writeData
);

    assign writeData =
        (ResultSrc == 2'b00) ? aluResult :
        (ResultSrc == 2'b01) ? memoryData :
        (ResultSrc == 2'b10) ? PCPlus4 :
                               32'b0;

endmodule