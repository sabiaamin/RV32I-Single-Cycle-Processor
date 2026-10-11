module data_memory (
    input wire        clk,

    input wire        MemRead,
    input wire        MemWrite,

    input wire [31:0] address,
    input wire [31:0] writeData,

    input wire [1:0]  MemSize,
    input wire        LoadUnsigned,

    output reg [31:0] readData
);

    // 1024 bytes of memory
    reg [7:0] memory [0:1023];


    // =====================================
    // READ
    // =====================================

    always @(*) begin

        readData = 32'b0;

        if (MemRead) begin

            case (MemSize)

                // ---------------------------------
                // BYTE
                // ---------------------------------
                2'b00: begin

                    if (LoadUnsigned)
                        readData = {24'b0,
                                    memory[address]};
                    else
                        readData = {{24{memory[address][7]}},
                                    memory[address]};

                end


                // ---------------------------------
                // HALFWORD
                // ---------------------------------
                2'b01: begin

                    if (LoadUnsigned)
                        readData = {16'b0,
                                    memory[address + 1],
                                    memory[address]};
                    else
                        readData = {{16{memory[address + 1][7]}},
                                    memory[address + 1],
                                    memory[address]};

                end


                // ---------------------------------
                // WORD
                // ---------------------------------
                2'b10: begin

                    readData = {
                        memory[address + 3],
                        memory[address + 2],
                        memory[address + 1],
                        memory[address]
                    };

                end


                default:
                    readData = 32'b0;

            endcase

        end

    end


    // =====================================
    // WRITE
    // =====================================

    always @(posedge clk) begin

        if (MemWrite) begin

            case (MemSize)

                // ---------------------------------
                // STORE BYTE
                // ---------------------------------
                2'b00: begin

                    memory[address] <= writeData[7:0];

                end


                // ---------------------------------
                // STORE HALFWORD
                // ---------------------------------
                2'b01: begin

                    memory[address]     <= writeData[7:0];
                    memory[address + 1] <= writeData[15:8];

                end


                // ---------------------------------
                // STORE WORD
                // ---------------------------------
                2'b10: begin

                    memory[address]     <= writeData[7:0];
                    memory[address + 1] <= writeData[15:8];
                    memory[address + 2] <= writeData[23:16];
                    memory[address + 3] <= writeData[31:24];

                end

            endcase

        end

    end

endmodule