`default_nettype none

package lc3;
   /* State */
   typedef enum logic [4:0] { STATE_FETCH0,
                              STATE_FETCH1,
                              STATE_FETCH2,
                              STATE_DECODE,
                              STATE_ADD0,
                              STATE_AND0,
                              STATE_NOT0,
                              STATE_JSR0,
                              STATE_JSR1,
                              STATE_BR0,
                              STATE_LD0,
                              STATE_LD1,
                              STATE_LD2,
                              STATE_ST0,
                              STATE_ST1,
                              STATE_ST2,
                              STATE_JMP0,
                              STATE_UNKNOWN
                              } state_t;
   const state_t STATE_INITIAL = STATE_FETCH0;

   /* OpCodes */
   const logic [3:0] OPCODE_ADD = 4'b0001;
   const logic [3:0] OPCODE_AND = 4'b0101;
   const logic [3:0] OPCODE_NOT = 4'b1001;
   const logic [3:0] OPCODE_JSR = 4'b0100;
   const logic [3:0] OPCODE_BR  = 4'b0000;
   const logic [3:0] OPCODE_LD  = 4'b0010;
   const logic [3:0] OPCODE_ST  = 4'b0011;
   const logic [3:0] OPCODE_JMP = 4'b1100;
   const logic [3:0] OPCODE_INV = 4'b111;

   /* ALU Control */
   typedef enum logic [1:0] { 
                              ALU_CONTROL_PASS,
                              ALU_CONTROL_ADD,
                              ALU_CONTROL_AND,
                              ALU_CONTROL_NOT
                              } aluControl_t;
endpackage
