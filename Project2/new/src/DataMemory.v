`timescale 1ns/1ps
module DataMemory (
    input  wire        clk,
    input  wire [15:0] addr,     // Word address
    input  wire [15:0] wd,       // Write data
    input  wire        we,       // Write enable
    output reg  [15:0] rd,       // Read data

    // Optional monitoring
    input  wire [7:0]  monitor_addr1,
    output wire [15:0] monitor_data1,
    input  wire [7:0]  monitor_addr2,
    output wire [15:0] monitor_data2
);
    reg [15:0] memory [0:255];	  // 256 bytes of memory (byte-addressable)

    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 16'h0000;
        end
    end

    // Synchronous write
    always @(posedge clk) begin
        if (we && addr < 256) begin
            memory[addr] <= wd;
        end
    end

    // Synchronous read
    always @(posedge clk) begin
        if (addr < 256)
            rd <= memory[addr];
        else
            rd <= 16'h0000;
    end

    // Monitor
    assign monitor_data1 = (monitor_addr1 < 256) ? memory[monitor_addr1] : 16'hXXXX;
    assign monitor_data2 = (monitor_addr2 < 256) ? memory[monitor_addr2] : 16'hXXXX;
endmodule
