`ifndef DEFINES_VH
`define DEFINES_VH

//------------------------------------------------
// Major Opcodes (4 bits):
//------------------------------------------------
`define OP_R_TYPE  4'b0000   // R-Type
`define OP_J_TYPE  4'b0001   // J-Type
`define ANDI_OP    4'b0010
`define ADDI_OP    4'b0011
`define LW_OP      4'b0100
`define SW_OP      4'b0101
`define BEQ_OP     4'b0110
`define BNE_OP     4'b0111
`define FOR_OP     4'b1000   // FOR

//------------------------------------------------
// R-Type (Function field):
//------------------------------------------------
`define AND_OP     3'b000
`define ADD_OP     3'b001
`define SUB_OP     3'b010
`define SLL_OP     3'b011
`define SRL_OP     3'b100

//------------------------------------------------
// J-Type (Function field):
//------------------------------------------------
`define JMP_FUNC   3'b000
`define CALL_FUNC  3'b001
`define RET_FUNC   3'b010

`endif

