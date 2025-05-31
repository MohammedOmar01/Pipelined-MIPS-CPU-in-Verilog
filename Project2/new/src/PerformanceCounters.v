`timescale 1ns/1ps
module PerformanceCounters (
    input  wire       clk,
    input  wire       rst,
    input  wire       instruction_executed,
    input  wire       load_instruction,
    input  wire       store_instruction,
    input  wire       alu_instruction,
    input  wire       control_instruction,
    input  wire       stall_cycle,
    output reg [31:0] total_instructions,
    output reg [31:0] total_loads,
    output reg [31:0] total_stores,
    output reg [31:0] total_alus,
    output reg [31:0] total_controls,
    output reg [31:0] total_cycles,
    output reg [31:0] total_stall_cycles
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            total_instructions <= 0;
            total_loads        <= 0;
            total_stores       <= 0;
            total_alus         <= 0;
            total_controls     <= 0;
            total_cycles       <= 0;
            total_stall_cycles <= 0;
        end else begin
            total_cycles <= total_cycles + 1;
            if (stall_cycle)
                total_stall_cycles <= total_stall_cycles + 1;

            if (instruction_executed) begin
                total_instructions <= total_instructions + 1;
                if (load_instruction)
                    total_loads <= total_loads + 1;
                if (store_instruction)
                    total_stores <= total_stores + 1;
                if (alu_instruction)
                    total_alus <= total_alus + 1;
                if (control_instruction)
                    total_controls <= total_controls + 1;
            end
        end
    end
endmodule
