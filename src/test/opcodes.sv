package opcodes;
   const logic [3:0] ADD  = 4'b0001;
   const logic [3:0] AND  = 4'b0101;
   const logic [3:0] NOT  = 4'b1001;
   const logic [3:0] BR   = 4'b0000;
   const logic [3:0] JMP  = 4'b1100;
   const logic [3:0] JSR  = 4'b0100;
   const logic [3:0] LD   = 4'b0010;
   const logic [3:0] LDI  = 4'b1010;
   const logic [3:0] LDR  = 4'b0110;
   const logic [3:0] LEA  = 4'b1110;
   const logic [3:0] ST   = 4'b0011;
   const logic [3:0] STI  = 4'b1011;
   const logic [3:0] STR  = 4'b0111;
   const logic [3:0] TRAP = 4'b1111;
   const logic [3:0] RTI  = 4'b1000;
endpackage
