module alu_input_mux (

    input wire [31:0] rs2Data,
    input wire [31:0] immediate,

    input wire ALUSrc,

    output wire [31:0] aluB

);

    assign aluB = (ALUSrc == 1'b0)
                  ? rs2Data
                  : immediate;

endmodule