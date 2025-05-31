module ID_EX (
    input  wire clk,
    input  wire rst,
    input  wire [15:0] pc_in,
    input  wire [15:0] rd1_in,
    input  wire [15:0] rd2_in,
    input  wire [15:0] imm_in,
    input  wire [2:0]  rd_in,
    input  wire [2:0]  rs_in,
    input  wire [2:0]  rt_in,
    input  wire [2:0]  funct_in,
    input  wire [3:0]  alu_op_in,
    input  wire        alu_src_in,
    input  wire        mem_to_reg_in,
    input  wire        reg_write_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire [2:0]  branch_in,
    input  wire        jump_in,
    input  wire        call_in,
    input  wire        ret_in,
    input  wire        sign_extend_in,
    input  wire        for_loop_in,
    input  wire        stall,

    output reg [15:0]  pc_out,
    output reg [15:0]  rd1_out,
    output reg [15:0]  rd2_out,
    output reg [15:0]  imm_out,
    output reg [2:0]   rd_out,
    output reg [2:0]   rs_out,
    output reg [2:0]   rt_out,
    output reg [2:0]   funct_out,
    output reg [3:0]   alu_op_out,
    output reg         alu_src_out,
    output reg         mem_to_reg_out,
    output reg         reg_write_out,
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg [2:0]   branch_out,
    output reg         jump_out,
    output reg         call_out,
    output reg         ret_out,
    output reg         sign_extend_out,
    output reg         for_loop_out // NEW
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out          <= 16'b0;
            rd1_out         <= 16'b0;
            rd2_out         <= 16'b0;
            imm_out         <= 16'b0;
            rd_out          <= 3'b0;
            rs_out          <= 3'b0;
            rt_out          <= 3'b0;
            funct_out       <= 3'b0;
            alu_op_out      <= 4'b0;
            alu_src_out     <= 1'b0;
            mem_to_reg_out  <= 1'b0;
            reg_write_out   <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            branch_out      <= 3'b0;
            jump_out        <= 1'b0;
            call_out        <= 1'b0;
            ret_out         <= 1'b0;
            sign_extend_out <= 1'b0;
            for_loop_out    <= 1'b0;
        end
        else if (stall) begin
            // hold
            pc_out          <= pc_out;
            rd1_out         <= rd1_out;
            rd2_out         <= rd2_out;
            imm_out         <= imm_out;
            rd_out          <= rd_out;
            rs_out          <= rs_out;
            rt_out          <= rt_out;
            funct_out       <= funct_out;
            alu_op_out      <= alu_op_out;
            alu_src_out     <= alu_src_out;
            mem_to_reg_out  <= mem_to_reg_out;
            reg_write_out   <= reg_write_out;
            mem_read_out    <= mem_read_out;
            mem_write_out   <= mem_write_out;
            branch_out      <= branch_out;
            jump_out        <= jump_out;
            call_out        <= call_out;
            ret_out         <= ret_out;
            sign_extend_out <= sign_extend_out;
            for_loop_out    <= for_loop_out;
        end
        else begin
            pc_out          <= pc_in;
            rd1_out         <= rd1_in;
            rd2_out         <= rd2_in;
            imm_out         <= imm_in;
            rd_out          <= rd_in;
            rs_out          <= rs_in;
            rt_out          <= rt_in;
            funct_out       <= funct_in;
            alu_op_out      <= alu_op_in;
            alu_src_out     <= alu_src_in;
            mem_to_reg_out  <= mem_to_reg_in;
            reg_write_out   <= reg_write_in;
            mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;
            branch_out      <= branch_in;
            jump_out        <= jump_in;
            call_out        <= call_in;
            ret_out         <= ret_in;
            sign_extend_out <= sign_extend_in;
            for_loop_out    <= for_loop_in;
        end
    end
endmodule
