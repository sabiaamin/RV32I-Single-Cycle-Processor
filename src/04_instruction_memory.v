module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];

    integer i;

    initial begin

        // Initialize all memory locations with NOP
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013;

        // Load our program
        $readmemh("program/program.mem", memory, 0, 19);

    end

    // Word-aligned instruction access
    assign instruction = memory[address[9:2]];

endmodule