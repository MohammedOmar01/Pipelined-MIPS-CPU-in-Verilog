`include "defines.vh"

module CPU (
    input  wire clk,
    input  wire rst,

    // Performance Counters
    output wire [31:0] total_instructions,
    output wire [31:0] total_loads,
    output wire [31:0] total_stores,
    output wire [31:0] total_alus,
    output wire [31:0] total_controls,
    output wire [31:0] total_cycles,
    output wire [31:0] total_stall_cycles,


    // Stop signal once pipeline done
    output reg  done
);

    //--------------------------
    // 1) Program Counter
    //--------------------------
    reg [15:0] pc;

    // Instruction Memory
    wire [15:0] instruction;
    InstructionMemory imem(
        .addr(pc),
        .clk(clk),
        .instruction(instruction)
    );

    // IF/ID
    wire flush, stall;
    wire [15:0] if_id_pc, if_id_instruction;

    IF_ID if_id_reg(
        .clk(clk),
        .rst(rst),
        .pc_in(pc),
        .instruction_in(instruction),
        .flush(flush),
        .stall(stall),
        .pc_out(if_id_pc),
        .instruction_out(if_id_instruction)
    );

    // Decode
    wire [3:0] opcode = if_id_instruction[15:12];
    wire [2:0] rd     = if_id_instruction[11:9];
    wire [2:0] rs     = if_id_instruction[8:6];
    wire [2:0] rt     = if_id_instruction[5:3];
    wire [2:0] funct  = if_id_instruction[2:0];
    wire [5:0] imm6   = if_id_instruction[5:0];

    // RegisterFile
    wire [15:0] rd1, rd2, rr_out;
    wire [2:0] mem_wb_rd;
    wire [15:0] mem_wb_wd;
    wire mem_wb_reg_write;

    // Control
    wire alu_src, mem_to_reg, reg_write;
    wire mem_read, mem_write;
    wire [2:0] branch;
    wire [3:0] alu_op;
    wire jump, call, ret, sign_extend, for_loop;

    ControlUnit ctrl(
        .opcode(opcode),
        .funct(funct),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .alu_op(alu_op),
        .jump(jump),
        .call(call),
        .ret(ret),
        .sign_extend(sign_extend),
        .for_loop(for_loop)
    );

    // Next PC => store into RR if call=1
    wire [15:0] next_pc_val = pc + 1;

    RegisterFile regfile(
        .clk(clk),
        .reset(rst),
        .rs(rs),
        .rt(rt),
        .rd(mem_wb_rd),
        .wd(mem_wb_wd),
        .we(mem_wb_reg_write),
        .rr_in(next_pc_val),
        .rr_we(call),
        .rs_data(rd1),
        .rt_data(rd2),
        .rr_out(rr_out)
    );

    // Sign Extension
    wire [15:0] extended_imm;
    SignExtension sext(
        .immediate(imm6),
        .mode(sign_extend),
        .extended_immediate(extended_imm)
    );

    // Hazard
    wire id_ex_mem_read;
    wire [2:0] id_ex_rt_internal;
    HazardDetectionUnit hazard(
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_rt(id_ex_rt_internal),
        .if_id_rs(rs),
        .if_id_rt(rt),
        .stall(stall)
    );

    // ID_EX
    wire [15:0] id_ex_pc, id_ex_rd1, id_ex_rd2, id_ex_imm;
    wire [2:0]  id_ex_rd, id_ex_funct;
    wire [3:0]  id_ex_alu_op;
    wire        id_ex_alu_src, id_ex_mem_to_reg, id_ex_reg_write;
    wire        id_ex_mem_write;
    wire [2:0]  id_ex_branch;
    wire        id_ex_jump, id_ex_call, id_ex_ret, id_ex_sign_extend;
    wire        id_ex_for_loop;
    wire [2:0]  id_ex_rs_internal;

    ID_EX id_ex_reg_inst(
        .clk(clk),
        .rst(rst),
        .pc_in(if_id_pc),
        .rd1_in(rd1),
        .rd2_in(rd2),
        .imm_in(extended_imm),
        .rd_in(rd),
        .rs_in(rs),
        .rt_in(rt),
        .funct_in(funct),
        .alu_op_in(alu_op),
        .alu_src_in(alu_src),
        .mem_to_reg_in(mem_to_reg),
        .reg_write_in(reg_write),
        .mem_read_in(mem_read),
        .mem_write_in(mem_write),
        .branch_in(branch),
        .jump_in(jump),
        .call_in(call),
        .ret_in(ret),
        .sign_extend_in(sign_extend),
        .for_loop_in(for_loop),
        .stall(stall),

        .pc_out(id_ex_pc),
        .rd1_out(id_ex_rd1),
        .rd2_out(id_ex_rd2),
        .imm_out(id_ex_imm),
        .rd_out(id_ex_rd),
        .rs_out(id_ex_rs_internal),
        .rt_out(id_ex_rt_internal),
        .funct_out(id_ex_funct),
        .alu_op_out(id_ex_alu_op),
        .alu_src_out(id_ex_alu_src),
        .mem_to_reg_out(id_ex_mem_to_reg),
        .reg_write_out(id_ex_reg_write),
        .mem_read_out(id_ex_mem_read),
        .mem_write_out(id_ex_mem_write),
        .branch_out(id_ex_branch),
        .jump_out(id_ex_jump),
        .call_out(id_ex_call),
        .ret_out(id_ex_ret),
        .sign_extend_out(id_ex_sign_extend),
        .for_loop_out(id_ex_for_loop)
    );

    // EX Stage
    wire [1:0] forward_a, forward_b;
    wire ex_mem_reg_write;
    wire [15:0] ex_mem_alu_result;

    ForwardingUnit fwd(
        .id_ex_rs(id_ex_rs_internal),
        .id_ex_rt(id_ex_rt_internal),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    // Normal ALU inputs
    wire [15:0] forwarded_a = (forward_a == 2'b01) ? ex_mem_alu_result
                           : (forward_a == 2'b10) ? mem_wb_wd
                           : id_ex_rd1;

    wire [15:0] forwarded_b = (forward_b == 2'b01) ? ex_mem_alu_result
                           : (forward_b == 2'b10) ? mem_wb_wd
                           : id_ex_rd2;

    wire [15:0] normal_b    = (id_ex_alu_src) ? id_ex_imm : forwarded_b;

    // FOR logic: if for_loop => do (Rt - 1)
    // We will treat a = old Rt" and "b = 1"
    wire [15:0] for_a = forwarded_b;  // old loop counter is in "forwarded_b" or "forwarded_a" 
                                      // depends on how you read 'Rt'. 
                                      // Suppose we read it in rd2 => so that is forwarded_b.
    wire [15:0] for_b = 16'h0001;     // subtract 1

    wire [15:0] alu_in_a = (id_ex_for_loop) ? for_a : forwarded_a;
    wire [15:0] alu_in_b = (id_ex_for_loop) ? for_b : normal_b;

    wire [15:0] alu_result;
    wire Z, C, V, N;

    ALU alu_inst(
        .a(alu_in_a),
        .b(alu_in_b),
        .alu_control(id_ex_alu_op),
        .Function(id_ex_funct),
        .signed_op(id_ex_sign_extend),
        .result(alu_result),
        .Z(Z), .C(C), .V(V), .N(N)
    );

    // EX/MEM
    wire [15:0] ex_mem_rd2;
    wire [2:0]  ex_mem_rd_out;
    wire [2:0]  ex_mem_funct;
    wire        ex_mem_mem_to_reg;
    wire        ex_mem_mem_read;
    wire        ex_mem_mem_write;
    wire [2:0]  ex_mem_branch;
    wire        ex_mem_jump;
    wire        ex_mem_call;
    wire        ex_mem_ret;
    wire [15:0] ex_mem_pc;
    wire [2:0]  ex_mem_rs;
    wire [2:0]  ex_mem_rt;
    wire        ex_mem_for_loop;
    wire [15:0] ex_mem_for_addr; // If we want the loop address from Rs
                                 // We can read it as 'forwarded_a' or 'id_ex_rd1' if needed.

    EX_MEM ex_mem_reg_inst(
        .clk(clk),
        .rst(rst),
        .alu_result_in(alu_result),
        .rd2_in(forwarded_b),
        .rd_in(id_ex_rd),
        .funct_in(id_ex_funct),
        .mem_to_reg_in(id_ex_mem_to_reg),
        .reg_write_in(id_ex_reg_write),
        .mem_read_in(id_ex_mem_read),
        .mem_write_in(id_ex_mem_write),
        .branch_in(id_ex_branch),
        .jump_in(id_ex_jump),
        .call_in(id_ex_call),
        .ret_in(id_ex_ret),
        .pc_in(id_ex_pc),
        .rs_in(id_ex_rs_internal),
        .rt_in(id_ex_rt_internal),
        .for_loop_in(id_ex_for_loop),
        .rd1_in_forAddress(id_ex_rd1), // if 'Rs' was in rd1
        
        .alu_result_out(ex_mem_alu_result),
        .rd2_out(ex_mem_rd2),
        .rd_out(ex_mem_rd_out),
        .funct_out(ex_mem_funct),
        .mem_to_reg_out(ex_mem_mem_to_reg),
        .reg_write_out(ex_mem_reg_write),
        .mem_read_out(ex_mem_mem_read),
        .mem_write_out(ex_mem_mem_write),
        .branch_out(ex_mem_branch),
        .jump_out(ex_mem_jump),
        .call_out(ex_mem_call),
        .ret_out(ex_mem_ret),
        .pc_out(ex_mem_pc),
        .rs_out(ex_mem_rs),
        .rt_out(ex_mem_rt),
        .for_loop_out(ex_mem_for_loop),
        .for_address_out(ex_mem_for_addr)
    );
    assign ex_mem_rd = ex_mem_rd_out;

    // MEM stage => DataMemory
    wire [15:0] mem_data_out;
    DataMemory dmem(
        .clk(clk),
        .addr(ex_mem_alu_result),
        .wd(ex_mem_rd2),
        .we(ex_mem_mem_write),
        .rd(mem_data_out),
        .monitor_addr1(8'd0),
        .monitor_data1(monitor_data1),
        .monitor_addr2(8'd1),
        .monitor_data2(monitor_data2)
    );

    // MEM/WB
    wire [15:0] mem_wb_alu_result, mem_wb_mem_data;
    wire        mem_wb_mem_to_reg;

    MEM_WB mem_wb_reg_inst(
        .clk(clk),
        .rst(rst),
        .alu_result_in(ex_mem_alu_result),
        .mem_data_in(mem_data_out),
        .rd_in(ex_mem_rd_out),
        .mem_to_reg_in(ex_mem_mem_to_reg),
        .reg_write_in(ex_mem_reg_write),
        .funct_in(ex_mem_funct),

        .alu_result_out(mem_wb_alu_result),
        .mem_data_out(mem_wb_mem_data),
        .rd_out(mem_wb_rd),
        .mem_to_reg_out(mem_wb_mem_to_reg),
        .reg_write_out(mem_wb_reg_write),
        .funct_out(/*unused*/)
    );

    // Writeback
    assign mem_wb_wd = (mem_wb_mem_to_reg) ? mem_wb_mem_data : mem_wb_alu_result;

    // Performance Counters
    wire instruction_executed = 1'b1; 
    wire load_instruction     = ex_mem_mem_read;
    wire store_instruction    = ex_mem_mem_write;
    wire alu_instruction      = ~(load_instruction | store_instruction);
    wire control_instruction  = (ex_mem_branch != 3'b000) || ex_mem_jump || ex_mem_call || ex_mem_ret || ex_mem_for_loop;
    wire stall_cycle          = stall;

    PerformanceCounters perf_counters_inst(
        .clk(clk),
        .rst(rst),
        .instruction_executed(instruction_executed),
        .load_instruction(load_instruction),
        .store_instruction(store_instruction),
        .alu_instruction(alu_instruction),
        .control_instruction(control_instruction),
        .stall_cycle(stall_cycle),

        .total_instructions(total_instructions),
        .total_loads(total_loads),
        .total_stores(total_stores),
        .total_alus(total_alus),
        .total_controls(total_controls),
        .total_cycles(total_cycles),
        .total_stall_cycles(total_stall_cycles)
    );

    // PC update & done logic
    localparam TOTAL_INSTR = 9; // or however many you have
    localparam PIPE_DEPTH  = 5;
    reg [31:0] fetched_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc            <= 16'b0;
            fetched_count <= 0;
            done          <= 1'b0;
        end
        else if (!done) begin
            // If stall => do not update pc
            if (stall) begin
                pc <= pc;
            end
            else begin
                // If FOR in EX/MEM => ex_mem_for_loop 
                // new_counter = ex_mem_alu_result
                // if new_counter != 0 => jump to ex_mem_for_addr
                if (ex_mem_for_loop) begin
                    if (ex_mem_alu_result != 16'b0) begin
                        pc <= ex_mem_for_addr; 
                        // flush pipeline if you'd like:
                        // flush <= 1;
                    end
                    else begin
                        pc <= pc + 1;
                        // flush <= 0;
                    end
                end
                else if (ex_mem_branch == 3'b001 && (Z==1)) begin // BEQ
                    pc <= ex_mem_pc + id_ex_imm; // or some branch offset
                end
                else if (ex_mem_branch == 3'b010 && (Z==0)) begin // BNE
                    pc <= ex_mem_pc + id_ex_imm;
                end
                else if (ex_mem_jump) begin
                    // J-type
                    pc <= { ex_mem_pc[15:9], ex_mem_alu_result[8:0] };
                end
                else if (ex_mem_call) begin
                    pc <= ex_mem_alu_result;
                end
                else if (ex_mem_ret) begin
                    pc <= rr_out;
                end
                else begin
                    pc <= pc + 1;
                end
            end

            // Count new fetch
            fetched_count <= fetched_count + 1;

            // done if we fetched enough instructions + pipeline depth
            if (fetched_count >= (TOTAL_INSTR + PIPE_DEPTH))
                done <= 1'b1;
        end
        else begin
            // done=1 => freeze
            pc <= pc;
        end
    end

    assign flush = 1'b0; // simplistic (no real flush logic for branch)
endmodule
