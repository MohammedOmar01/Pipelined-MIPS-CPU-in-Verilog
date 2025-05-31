`timescale 1ns/1ps
module MEM_WB (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] alu_result_in,
    input  wire [15:0] mem_data_in,
    input  wire [2:0]  rd_in,
    input  wire        mem_to_reg_in,
    input  wire        reg_write_in,
    input  wire [2:0]  funct_in,

    output reg [15:0]  alu_result_out,
    output reg [15:0]  mem_data_out,
    output reg [2:0]   rd_out,
    output reg         mem_to_reg_out,
    output reg         reg_write_out,
    output reg [2:0]   funct_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_out  <= 16'b0;
            mem_data_out    <= 16'b0;
            rd_out          <= 3'b0;
            mem_to_reg_out  <= 1'b0;
            reg_write_out   <= 1'b0;
            funct_out       <= 3'b0;
        end else begin
            alu_result_out  <= alu_result_in;
            mem_data_out    <= mem_data_in;
            rd_out          <= rd_in;
            mem_to_reg_out  <= mem_to_reg_in;
            reg_write_out   <= reg_write_in;
            funct_out       <= funct_in;
        end
    end
endmodule

