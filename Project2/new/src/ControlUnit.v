`include "defines.vh"

module ControlUnit (
    input  wire [3:0] opcode,  // 4-bit opcode
    input  wire [2:0] funct,   // 3-bit function for R-type, J-type
    output reg        alu_src,
    output reg        mem_to_reg,
    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg [2:0]  branch,
    output reg [3:0]  alu_op,
    output reg        jump,
    output reg        call,
    output reg        ret,
    output reg        sign_extend,
    output reg        for_loop   
);
    always @(*) begin
        // Default signals
        alu_src     = 0;
        mem_to_reg  = 0;
        reg_write   = 0;
        mem_read    = 0;
        mem_write   = 0;
        branch      = 3'b000;
        alu_op      = `OP_R_TYPE; // default
        jump        = 0;
        call        = 0;
        ret         = 0;
        sign_extend = 0;
        for_loop    = 0;

        case (opcode)
            //------------------------------------------------
            // R-Type => opcode=0000
            //------------------------------------------------
            `OP_R_TYPE: begin
                reg_write = 1;
                alu_op    = `OP_R_TYPE;
            end

            //------------------------------------------------
            // I-Type
            //------------------------------------------------
            `ANDI_OP: begin
                alu_src     = 1;
                reg_write   = 1;
                alu_op      = `ANDI_OP;
                sign_extend = 0; // zero-extend for logical
            end
            `ADDI_OP: begin
                alu_src     = 1;
                reg_write   = 1;
                alu_op      = `ADDI_OP;
                sign_extend = 1; // sign-extend
            end
            `LW_OP: begin
                alu_src    = 1;
                mem_to_reg = 1;
                mem_read   = 1;
                reg_write  = 1;
                alu_op     = `ADD_OP; 
                sign_extend= 1;
            end
            `SW_OP: begin
                alu_src     = 1;
                mem_write   = 1;
                alu_op      = `ADD_OP;
                sign_extend = 1;
            end
            `BEQ_OP: begin
                branch      = 3'b001; // indicate BEQ
                alu_op      = `SUB_OP;  // compare
                sign_extend = 1;
            end
            `BNE_OP: begin
                branch      = 3'b010; // indicate BNE
                alu_op      = `SUB_OP;  // compare
                sign_extend = 1;
            end

            //------------------------------------------------
            // FOR => opcode=1000
            //------------------------------------------------
            `FOR_OP: begin
                // We'll do special hardware loop
                for_loop    = 1;       // tell pipeline this is a FOR
                reg_write   = 1;       // we rewrite the decremented Rt
                alu_op      = `SUB_OP; // do (Rt - 1) in ALU
                alu_src     = 0;       // we'll read old Rt from register
                // imm is ignored => sign_extend=0
            end

            //------------------------------------------------
            // J-Type => opcode=0001
            //------------------------------------------------
            `OP_J_TYPE: begin
                case(funct)
                    `JMP_FUNC: jump = 1;
                    `CALL_FUNC: begin
                        call      = 1;
                        reg_write = 1; // store return address to RR
                    end
                    `RET_FUNC: ret = 1;
                    default: ;
                endcase
            end

            default: begin
                // no-op
            end
        endcase
    end
endmodule
