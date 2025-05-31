`timescale 1ns/1ps
module ForwardingUnit (
    input  wire [2:0] id_ex_rs,	   				// Source register in ID/EX stage
    input  wire [2:0] id_ex_rt,		  			// Target register in ID/EX stage
    input  wire [2:0] ex_mem_rd,				// Destination register in EX/MEM stage
    input  wire       ex_mem_reg_write,			// RegWrite signal in EX/MEM stage
    input  wire [2:0] mem_wb_rd,		 		// Destination register in MEM/WB stage
    input  wire       mem_wb_reg_write,			// RegWrite signal in MEM/WB stage
    output reg  [1:0] forward_a,				// Forwarding control for source A
    output reg  [1:0] forward_b				    // Forwarding control for source B

); 
    // Forwarding control encoding:
    // 00 => No forwarding
    // 01 => Forward from EX/MEM
    // 10 => Forward from MEM/WB

    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        // Check for forwarding for source A
        if (ex_mem_reg_write && (ex_mem_rd != 3'b000) && (ex_mem_rd == id_ex_rs))
            forward_a = 2'b01;
        else if (mem_wb_reg_write && (mem_wb_rd != 3'b000) && (mem_wb_rd == id_ex_rs))
            forward_a = 2'b10;

        // Check for forwarding for source B
        if (ex_mem_reg_write && (ex_mem_rd != 3'b000) && (ex_mem_rd == id_ex_rt))
            forward_b = 2'b01;	 // Forward from EX/MEM
        else if (mem_wb_reg_write && (mem_wb_rd != 3'b000) && (mem_wb_rd == id_ex_rt))
            forward_b = 2'b10;   // Forward from MEM/WB
    end
endmodule
