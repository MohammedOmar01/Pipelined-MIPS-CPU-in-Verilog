module EX_MEM(
    input  wire clk,
    input  wire rst,
    input  wire [15:0] alu_result_in,
    input  wire [15:0] rd2_in,
    input  wire [2:0]  rd_in,
    input  wire [2:0]  funct_in,
    input  wire        mem_to_reg_in,
    input  wire        reg_write_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire [2:0]  branch_in,
    input  wire        jump_in,
    input  wire        call_in,
    input  wire        ret_in,
    input  wire [15:0] pc_in,
    input  wire [2:0]  rs_in,
    input  wire [2:0]  rt_in,
    input  wire        for_loop_in,       
    input  wire [15:0] rd1_in_forAddress, // if we want the address from Rs

    output reg [15:0]  alu_result_out,
    output reg [15:0]  rd2_out,
    output reg [2:0]   rd_out,
    output reg [2:0]   funct_out,		 // Function field
    output reg         mem_to_reg_out,
    output reg         reg_write_out,
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg [2:0]   branch_out,
    output reg         jump_out,
    output reg         call_out,
    output reg         ret_out,
    output reg [15:0]  pc_out,
    output reg [2:0]   rs_out,
    output reg [2:0]   rt_out,
    output reg         for_loop_out,      
    output reg [15:0]  for_address_out    
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_out   <= 16'b0;
            rd2_out          <= 16'b0;
            rd_out           <= 3'b0;
            funct_out        <= 3'b0;
            mem_to_reg_out   <= 1'b0;
            reg_write_out    <= 1'b0;
            mem_read_out     <= 1'b0;
            mem_write_out    <= 1'b0;
            branch_out       <= 3'b0;
            jump_out         <= 1'b0;
            call_out         <= 1'b0;
            ret_out          <= 1'b0;
            pc_out           <= 16'b0;
            rs_out           <= 3'b0;
            rt_out           <= 3'b0;
            for_loop_out     <= 1'b0;
            for_address_out  <= 16'b0;
        end else begin
            alu_result_out   <= alu_result_in;
            rd2_out          <= rd2_in;
            rd_out           <= rd_in;
            funct_out        <= funct_in;
            mem_to_reg_out   <= mem_to_reg_in;
            reg_write_out    <= reg_write_in;
            mem_read_out     <= mem_read_in;
            mem_write_out    <= mem_write_in;
            branch_out       <= branch_in;
            jump_out         <= jump_in;
            call_out         <= call_in;
            ret_out          <= ret_in;
            pc_out           <= pc_in;
            rs_out           <= rs_in;
            rt_out           <= rt_in;
            for_loop_out     <= for_loop_in;
            for_address_out  <= rd1_in_forAddress;
        end
    end
endmodule
