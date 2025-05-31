 `timescale 1ns/1ps
module RegisterFile (
    input  wire        clk,
    input  wire        reset,
    input  wire [2:0]  rs,
    input  wire [2:0]  rt,
    input  wire [2:0]  rd,
    input  wire [15:0] wd,
    input  wire        we,      // Write enable
    input  wire [15:0] rr_in,   // Return register in
    input  wire        rr_we,   // Write enable for RR
    output wire [15:0] rs_data,
    output wire [15:0] rt_data,
    output wire [15:0] rr_out
);
    reg [15:0] regfile [7:0];
    reg [15:0] RR;

    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<8; i=i+1) begin
                regfile[i] <= 16'b0;
            end
            RR <= 16'b0;
        end else begin
            // Write to GPR
            if (we && rd != 3'b000) begin
                regfile[rd] <= wd;
            end
            // Write to RR
            if (rr_we) begin
                RR <= rr_in;
            end
        end
    end

    // Reads
    assign rs_data = (rs == 3'b000) ? 16'b0 : regfile[rs];
    assign rt_data = (rt == 3'b000) ? 16'b0 : regfile[rt];
    assign rr_out  = RR;
endmodule
