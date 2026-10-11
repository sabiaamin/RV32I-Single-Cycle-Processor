module pc_register (
    input wire        clk,
    input wire        reset,

    input wire [31:0] nextPC,

    output reg [31:0] PC
);

    always @(posedge clk) begin

        if (reset)
            PC <= 32'b0;
        else
            PC <= nextPC;

    end

endmodule