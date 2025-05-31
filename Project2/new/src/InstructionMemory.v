`include "defines.vh"
 `timescale 1ns/1ps
module InstructionMemory (
    input  wire [15:0] addr, 
    input  wire        clk,
    output reg  [15:0] instruction
);
    reg [15:0] memory [0:63];

    initial begin
        integer i;
        // Initialize all to 16'hF000 
        for (i = 0; i < 64; i = i + 1) begin
            memory[i] = 16'hF000;
        end

   
// 1) SRL R3, R6, R5 => 0x0764
//    Logical right shift: R3 = R6 >> R5
memory[0] = 16'h0764;

// 2) CALL offset=3 => 0x1031
//    Call a subroutine at offset 3
memory[1] = 16'h1031;

// 3) ADDI R2, R2, 1 => 0x3241
//    Add immediate value: R2 = R2 + 1
memory[2] = 16'h3241;

// 4) RET => 0x1002
//    Return from subroutine
memory[3] = 16'h1002;

// 5) SRL R1, R1, R2 => 0x0164
//    Logical right shift: R1 = R1 >> R2
memory[4] = 16'h0164;

// 6) JMP offset=10 => 0x10A0
//    Jump to address offset 10
memory[5] = 16'h10A0;

// 7) LW R7, 4(R6) => 0x4F84
//    Load word: R7 = Mem[R6 + 4]
memory[6] = 16'h4F84;

// 8) ADD R5, R5, R7 => 0x0A57
//    Add: R5 = R5 + R7
memory[7] = 16'h0A57;
	end

    always @(posedge clk) begin
        if (addr < 64)
            instruction <= memory[addr];
        else
            instruction <= 16'hF000;
    end
endmodule
