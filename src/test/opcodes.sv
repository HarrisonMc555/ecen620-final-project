package opcodes;
   const logic [3:0] OPCODE_ADD = 4'b0001;
   const logic [3:0] OPCODE_AND = 4'b0101;
   const logic [3:0] OPCODE_NOT = 4'b1001;
   const logic [3:0] OPCODE_JSR = 4'b0100;
   const logic [3:0] OPCODE_BR  = 4'b0000;
   const logic [3:0] OPCODE_LD  = 4'b0010;
   const logic [3:0] OPCODE_ST  = 4'b0011;
   const logic [3:0] OPCODE_JMP = 4'b1100;
   const logic [3:0] OPCODE_INV = 4'b111;
endpackage
