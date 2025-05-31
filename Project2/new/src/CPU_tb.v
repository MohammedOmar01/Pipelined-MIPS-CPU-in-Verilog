`timescale 1ns/1ps
module CPU_tb;
    reg clk;
    reg rst;

    wire [31:0] total_instructions;
    wire [31:0] total_loads;
    wire [31:0] total_stores;
    wire [31:0] total_alus;
    wire [31:0] total_controls;
    wire [31:0] total_cycles;
    wire [31:0] total_stall_cycles;

    wire [15:0] monitor_data1;
    wire [15:0] monitor_data2;
    wire done;

    CPU uut (
        .clk(clk),
        .rst(rst),
        .total_instructions(total_instructions),
        .total_loads(total_loads),
        .total_stores(total_stores),
        .total_alus(total_alus),
        .total_controls(total_controls),
        .total_cycles(total_cycles),
        .total_stall_cycles(total_stall_cycles),
        .done(done)
    );

    // Clock
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 10ns period
    end

    // Main test
    initial begin
        rst = 1;
        #0;
        rst = 0;

        @(posedge done);
        #0
        $display("----- Simulation Complete -----");
        $display("Performance Counters:");
        $display("  Instructions = %d", total_instructions);
        $display("  Loads        = %d", total_loads);
        $display("  Stores       = %d", total_stores);
        $display("  ALUs         = %d", total_alus);
        $display("  Controls     = %d", total_controls);
        $display("  Cycles       = %d", total_cycles);
        $display("  StallCycles  = %d", total_stall_cycles);
        $stop;
    end

    initial begin
        $monitor("Time=%0t | PC=%h | Instr=%H |",
                 $time, uut.pc, uut.if_id_instruction,);
    end
endmodule
