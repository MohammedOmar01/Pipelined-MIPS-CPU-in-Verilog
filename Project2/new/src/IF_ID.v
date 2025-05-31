`timescale 1ns/1ps
module IF_ID (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] pc_in,
    input  wire [15:0] instruction_in,
    input  wire        flush,
    input  wire        stall,
    output reg [15:0]  pc_out,
    output reg [15:0]  instruction_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out          <= 16'b0;
            instruction_out <= 16'b0;
        end
        else if (flush) begin
            pc_out          <= 16'b0;
            instruction_out <= 16'b0;
        end
        else if (!stall) begin
            pc_out          <= pc_in;
            instruction_out <= instruction_in;
        end
        // If stall=1, hold values
    end
endmodule

