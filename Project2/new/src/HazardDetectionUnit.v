 `timescale 1ns/1ps
module HazardDetectionUnit (
    input  wire       id_ex_mem_read, // The ID_EX instruction is LW
    input  wire [2:0] id_ex_rt,       // The loaded register
    input  wire [2:0] if_id_rs,       // Next instruction's Rs
    input  wire [2:0] if_id_rt,       // Next instruction's Rt
    output reg        stall
);
    always @(*) begin
        stall = 0;
        // If the ID_EX is a load, and the next instruction (IF_ID) 
        // uses the same register => stall
        if (id_ex_mem_read &&
           ((id_ex_rt == if_id_rs) || (id_ex_rt == if_id_rt))) begin
            stall = 1;
        end
    end
endmodule

