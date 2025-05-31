`include "defines.vh"
   `timescale 1ns/1ps
module ALU (
    input wire [15:0] a,
    input wire [15:0] b,
    input wire [3:0]  alu_control, // For I-Type etc.
    input wire [2:0]  Function,    // R-Type function
    input wire        signed_op,
    output reg [15:0] result,
    output reg        Z, 
    output reg        C, 
    output reg        V, 
    output reg        N
);
    always @(*) begin
        // Default flags
        C      = 0;
        V      = 0;
        result = 16'b0;

        case (alu_control)
            `OP_R_TYPE: begin
                // R-Type, decode via Function
                case (Function)
                    `AND_OP: begin
                        result = a & b;
                    end
                    `ADD_OP: begin
                        if (signed_op) begin
                            {C, result} = $signed(a) + $signed(b);
                            V = (a[15] == b[15]) && (result[15] != a[15]);
                        end else begin
                            {C, result} = a + b;
                            V = (a[15] & b[15] & ~result[15]) |
                                (~a[15] & ~b[15] & result[15]);
                        end
                    end
                    `SUB_OP: begin
                        if (signed_op) begin
                            {C, result} = $signed(a) - $signed(b);
                            V = (a[15] != b[15]) && (result[15] != a[15]);
                        end else begin
                            {C, result} = a - b;
                            V = (a[15] & ~b[15] & ~result[15]) |
                                (~a[15] & b[15] & result[15]);
                        end
                    end
                    `SLL_OP: begin
                        // Shift by lower 4 bits for example
                        result = a << b[3:0];
                    end
                    `SRL_OP: begin
                        result = a >> b[3:0];
                    end
                    default: result = 16'b0;
                endcase
            end

            `ANDI_OP: begin
                result = a & b;
            end

            `ADDI_OP: begin
                if (signed_op) begin
                    {C, result} = $signed(a) + $signed(b);
                    V = (a[15] == b[15]) && (result[15] != a[15]);
                end else begin
                    {C, result} = a + b;
                    V = (a[15] & b[15] & ~result[15]) |
                        (~a[15] & ~b[15] & result[15]);
                end
            end

            

            default: result = 16'b0;
        endcase

        N = result[15];
        Z = (result == 16'b0);
    end
endmodule
