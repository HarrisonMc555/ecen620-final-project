`default_nettype none

import lc3::*;

module controller (
                   /***** Output *****/
                   /* MARMux */
                   enaMARM, selMAR,
                   /* PC */
                   enaPC, selPC, ldPC,
                   /* Reg File */
                   DR, SR1, SR2, regWE,
                   /* Memory */
                   enaMDR, ldMAR, ldMDR, memWE, selMDR,
                   /* ALU */
                   enaALU, aluControl,
                   /* Instruction Register */
                   ldIR,
                   /* EAB */
                   selEAB1, selEAB2,
                   /* Condition Code Flags */
                   flagWE,

                   /***** Input *****/
                   /* System */
                   clk, reset,
                   /* Instruction Register */
                   ir,
                   /* Condition Codes */
                   flagN, flagZ, flagP
                   );
   output logic        enaMARM, selMAR, enaPC, ldPC, regWE, enaMDR, ldMAR,
                       ldMDR, memWE, selMDR, enaALU, ldIR, selEAB1, flagWE;
   output logic [1:0]  selPC, selEAB2;
   output logic [2:0]  DR, SR1, SR2;
   output aluControl_t aluControl;
   input logic[15:0]   ir;
   input logic         clk, reset, flagN, flagZ, flagP;


   /* Globals */
   state_t curState, nextState;
   logic [3:0] opCode;
   logic       irFlagN, irFlagZ, irFlagP, nMatches, zMatches, pMatches;


   /***** Current State *****/
   /* State actions */
   always_comb begin
      /* All signals are low by default */
      enaMARM    = 1'b0;
      selMAR     = 1'b0;
      enaPC      = 1'b0;
      ldPC       = 1'b0;
      selPC      = 2'b00;
      DR         = ir[11:9]; /* DR is always ir[11:9] if used */
      SR1        = ir[8:6]; /* SR1 is *almost* always ir[8:6] if used (not in ST* instructions) */
      SR2        = ir[2:0]; /* SR2 is always ir[2:0] if used */
      regWE      = 1'b0;
      enaMDR     = 1'b0;
      ldMAR      = 1'b0;
      ldMDR      = 1'b0;
      memWE      = 1'b0;
      selMDR     = 1'b0;
      enaALU     = 1'b0;
      aluControl = ALU_CONTROL_PASS;
      ldIR       = 1'b0;
      selEAB1    = 1'b0;
      selEAB2    = 2'b0;
      flagWE     = 1'b0;

      unique case (curState)
        STATE_FETCH0  : curStateFetch0;
        STATE_FETCH1  : curStateFetch1;
        STATE_FETCH2  : curStateFetch2;
        STATE_DECODE  : curStateDecode;
        STATE_AND0    : curStateAnd0;
        STATE_ADD0    : curStateAdd0;
        STATE_NOT0    : curStateNot0;
        STATE_BR0     : curStateBr0;
        STATE_BR1     : curStateBr1;
        STATE_JMP0    : curStateJmp0;
        STATE_JSR0    : curStateJsr0;
        STATE_JSR1    : curStateJsr1;
        STATE_LD0     : curStateLd0;
        STATE_LDI0    : curStateLdi0;
        STATE_LDI1    : curStateLdi1;
        STATE_LDI2    : curStateLdi2;
        STATE_LDR0    : curStateLdr0;
        STATE_ALL_LD0 : curStateAllLd0;
        STATE_ALL_LD1 : curStateAllLd1;
        STATE_LEA0    : curStateLea0;
        STATE_ST0     : curStateSt0;
        STATE_STI0    : curStateSti0;
        STATE_STI1    : curStateSti1;
        STATE_STI2    : curStateSti2;
        STATE_STR0    : curStateStr0;
        STATE_ALL_ST0 : curStateAllSt0;
        STATE_ALL_ST1 : curStateAllSt1;
        STATE_TRAP0   : curStateTrap0;
        STATE_TRAP1   : curStateTrap1;
        STATE_TRAP2   : curStateTrap2;
        default       : curStateUnknown;
      endcase
   end

   /* Individual current state actions */
   task curStateFetch0;
      begin
         /* IR = mem [ PC ] */
         /* This state: MAR = PC */
         enaPC = 1'b1;
         ldMAR = 1'b1;
      end
   endtask

   task curStateFetch1;
      begin
         /* PC = PC + 1 */
         selPC = 2'b00;
         ldPC = 1'b1;
         /* IR = mem [ PC ] */
         /* This state: MDR = mem [ MAR ] */
         selMDR = 1'b1;
         ldMDR = 1'b1;
      end
   endtask

   task curStateFetch2;
      begin
         /* IR = mem [ PC ] */
         /* This state: IR = MDR */
         enaMDR = 1'b1;
         ldIR = 1'b1;
      end
   endtask

   task curStateDecode;
      begin
         /* Nothing? */
         /* You could probably combine all the first states of each instruction
          into this one, but it might increase the longest path. It would also
          make this code a lot more complicated. I won't do it unless I need
          to. */
      end
   endtask

   task curStateAnd0;
      begin
         /* DR = SR1 AND ALUSR2 */
         /* ALUSR2 = SR2 OR SEXT(imm5) */
         curStateALU(ALU_CONTROL_AND);
      end
   endtask

   task curStateAdd0;
      begin
         /* DR = SR1 + ALUSR2 */
         /* ALUSR2 = SR2 OR SEXT(imm5) */
         curStateALU(ALU_CONTROL_ADD);
      end
   endtask

   task curStateNot0;
      begin
         /* DR = NOT(SR1) */
         curStateALU(ALU_CONTROL_NOT);
      end
   endtask

   task curStateBr0;
      begin
         /* Check for branch or not in nextStateBr0 */
      end
   endtask

   task curStateBr1;
      begin
         /* PC = PC + SEXT(PCoffset9) */
         ldPC = 1'b1;
         selPC = 2'b01;
         selEAB1 = 1'b0;
         selEAB2 = 2'b10;
      end
   endtask

   task curStateJmp0;
      begin
         ldPC = 1'b1;
         selPC = 2'b01;
         selEAB1 = 1'b1;
         selEAB2 = 2'b00;
         SR1 = ir[8:6];
      end
   endtask

   task curStateJsr0;
      begin
         /* R7 = PC */
         DR = 3'd7;
         regWE = 1'b1;
         enaPC = 1'b1;
      end
   endtask

   task curStateJsr1;
      begin
         ldPC = 1'b1;
         selPC = 2'b01;
         if (ir[11] == 1'b1) begin
            /* PC = PC + SEXT(PCoffset11) */
            selEAB1 = 1'b0;
            selEAB2 = 2'b11;
         end else begin
            /* PC = R[BaseR] */
            selEAB1 = 1'b1;
            selEAB2 = 2'b00;
         end
      end
   endtask

   task curStateLd0;
      begin
         /* DR = mem [ PC + SEXT(PCoffset9) ] */
         /* This state: MAR = PC + SEXT(PCoffset9) */
         curStateLoadMARPCOffset9();
      end
   endtask

   task curStateLdi0;
      begin
         /* R[DR] = mem [ mem [ PC + SEXT(PCoffset9) ] ] */
         /* This state: MAR = PC + SEXT(PCoffset9) */
         curStateLoadMARPCOffset9();
      end
   endtask

   task curStateLdi1;
      begin
         /* R[DR] = mem [ mem [ PC + SEXT(PCoffset9) ] ] */
         /* This state: MDR = mem [ MAR ] */
         curStateLoadMDR();
      end
   endtask

   task curStateLdi2;
      begin
         /* R[DR] = mem [ mem [ PC + SEXT(PCoffset9) ] ] */
         /* This state: MAR = MDR */
         curStateMDR2MAR();
      end
   endtask

   task curStateLdr0;
      begin
         /* R[DR] = mem [ R[BaseR] + SEXT(PCoffset6) ] */
         /* This state: MAR = R[BaseR] + SEXT(PCoffset6) */
         ldMAR = 1'b1;
         enaMARM = 1'b1;
         selMAR = 1'b0;
         selEAB1 = 1'b1;
         selEAB2 = 2'b01;
      end
   endtask

   task curStateAllLd0;
      begin
         /* DR = mem [ PC + SEXT(PCoffset9) ] */
         /* This state: MDR = mem [ MAR ] */
         curStateLoadMDR();
      end
   endtask

   task curStateAllLd1;
      begin
         /* DR = mem [ PC + SEXT(PCoffset9) ] */
         /* This state: DR = MDR */
         regWE = 1'b1;
         enaMDR = 1'b1;
         flagWE = 1'b1;
      end
   endtask

   task curStateLea0;
      begin
         /* DR = PC + SEXT(PCoffset9) */
         regWE = 1'b1;
         enaMARM = 1'b1;
         selMAR = 1'b0;
         selEAB1 = 1'b0;
         selEAB2 = 2'b10;
         flagWE = 1'b1;
      end
   endtask

   task curStateSt0;
      begin
         /* mem [ PC + SEXT(PCoffset9) ] = R[SR] */
         /* This state: MAR = PC + SEXT(PCoffset9) */
         curStateLoadMARPCOffset9();
      end
   endtask

   task curStateSti0;
      begin
         /* mem [ mem [ PC + SEXT(PCoffset9) ] ] = R[SR] */
         /* This state: MAR = PC + SEXT(PCoffset9) */
         curStateLoadMARPCOffset9();
      end
   endtask

   task curStateSti1;
      begin
         /* mem [ mem [ PC + SEXT(PCoffset9) ] ] = R[SR] */
         /* This state: MDR = mem [ MAR ] */
         curStateLoadMDR();
      end
   endtask

   task curStateSti2;
      begin
         /* mem [ mem [ PC + SEXT(PCoffset9) ] ] = R[SR] */
         /* This state: MAR = MDR */
         curStateMDR2MAR();
      end
   endtask

   task curStateStr0;
      begin
         /* mem [ R[BaseR] + SEXT(PCoffset6) ] = R[SR] */
         /* This state: MAR = R[BaseR] + SEXT(PCoffset6) */
         ldMAR = 1'b1;
         enaMARM = 1'b1;
         selMAR = 1'b0;
         selEAB1 = 1'b1;
         selEAB2 = 2'b01;
      end
   endtask

   task curStateAllSt0;
      begin
         /* This state: MDR = R[SR] */
         ldMDR = 1'b1;
         selMDR = 1'b0;
         enaALU = 1'b1;
         aluControl = ALU_CONTROL_PASS;
         SR1 = ir[11:9];
      end
   endtask

   task curStateAllSt1;
      begin
         /* This state: mem [ MAR ] = MDR */
         memWE = 1'b1;
      end
   endtask

   task curStateTrap0;
      begin
         /* MAR = ZEXT(IR[7:0]) */
         ldMAR = 1'b1;
         selMAR = 1'b1;
         enaMARM = 1'b1;
      end
   endtask

   task curStateTrap1;
      begin
         /* MDR = mem [ MAR ] */
         curStateLoadMDR();
         /* R7 = PC */
         DR = 3'd7;
         regWE = 1'b1;
         enaPC = 1'b1;
      end
   endtask

   task curStateTrap2;
      begin
         /* PC = MDR */
         enaMDR = 1'b1;
         selPC = 2'b10;
         ldPC = 1'b1;
      end
   endtask

   task curStateUnknown;
      begin
         $display("ERROR: unknown state.");
      end
   endtask

   /* Helper tasks */
   task curStateALU;
      input aluControl_t inAluControl;
      begin
         regWE = 1'b1;
         enaALU = 1'b1;
         SR1 = ir[8:6];
         aluControl = inAluControl;
         flagWE = 1'b1;
      end
   endtask

   task curStateLoadMARPCOffset9;
      begin
         ldMAR = 1'b1;
         enaMARM = 1'b1;
         selMAR = 1'b0;
         selEAB1 = 1'b0;
         selEAB2 = 2'b10;
      end
   endtask

   task curStateLoadMDR;
      begin
         ldMDR = 1'b1;
         selMDR = 1'b1;
      end
   endtask


   task curStateMDR2MAR;
      begin
         enaMDR = 1'b1;
         ldMAR = 1'b1;
      end
   endtask   

   /***** Next State *****/
   /* State transition */
   always_ff @ (posedge clk) begin
      if (reset) begin
         curState <= STATE_INITIAL;
      end else begin
         curState <= nextState;
      end
   end

   /* Next state calculation */
   always_comb begin
      unique case (curState)
        STATE_FETCH0  : nextStateFetch0(nextState);
        STATE_FETCH1  : nextStateFetch1(nextState);
        STATE_FETCH2  : nextStateFetch2(nextState);
        STATE_DECODE  : nextStateDecode(nextState);
        STATE_AND0    : nextStateAnd0(nextState);
        STATE_ADD0    : nextStateAdd0(nextState);
        STATE_NOT0    : nextStateNot0(nextState);
        STATE_BR0     : nextStateBr0(nextState);
        STATE_BR1     : nextStateBr1(nextState);
        STATE_JMP0    : nextStateJmp0(nextState);
        STATE_JSR0    : nextStateJsr0(nextState);
        STATE_JSR1    : nextStateJsr1(nextState);
        STATE_LD0     : nextStateLd0(nextState);
        STATE_LDI0    : nextStateLdi0(nextState);
        STATE_LDI1    : nextStateLdi1(nextState);
        STATE_LDI2    : nextStateLdi2(nextState);
        STATE_LDR0    : nextStateLdr0(nextState);
        STATE_ALL_LD0 : nextStateAllLd0(nextState);
        STATE_ALL_LD1 : nextStateAllLd1(nextState);
        STATE_LEA0    : nextStateLea0(nextState);
        STATE_ST0     : nextStateSt0(nextState);
        STATE_STI0    : nextStateSti0(nextState);
        STATE_STI1    : nextStateSti1(nextState);
        STATE_STI2    : nextStateSti2(nextState);
        STATE_STR0    : nextStateStr0(nextState);
        STATE_ALL_ST0 : nextStateAllSt0(nextState);
        STATE_ALL_ST1 : nextStateAllSt1(nextState);
        STATE_TRAP0   : nextStateTrap0(nextState);
        STATE_TRAP1   : nextStateTrap1(nextState);
        STATE_TRAP2   : nextStateTrap2(nextState);
        default       : nextStateUnknown(nextState);
      endcase
   end

   /* Individual state calculations */
   task nextStateFetch0;
      output state_t outNextState;
      begin
         outNextState = STATE_FETCH1;
      end
   endtask

   task nextStateFetch1;
      output state_t outNextState;
      begin
         outNextState = STATE_FETCH2;
      end
   endtask

   task nextStateFetch2;
      output state_t outNextState;
      begin
         outNextState = STATE_DECODE;
      end
   endtask

   task nextStateDecode;
      output state_t outNextState;
      begin
         unique case (opCode)
           OPCODE_AND : outNextState = STATE_AND0;
           OPCODE_ADD : outNextState = STATE_ADD0;
           OPCODE_NOT : outNextState = STATE_NOT0;
           OPCODE_JSR : outNextState = STATE_JSR0;
           OPCODE_BR  : outNextState = STATE_BR0;
           OPCODE_LD  : outNextState = STATE_LD0;
           OPCODE_LDI : outNextState = STATE_LDI0;
           OPCODE_LDR : outNextState = STATE_LDR0;
           OPCODE_ST  : outNextState = STATE_ST0;
           OPCODE_LEA : outNextState = STATE_LEA0;
           OPCODE_STI : outNextState = STATE_STI0;
           OPCODE_STR : outNextState = STATE_STR0;
           OPCODE_JMP : outNextState = STATE_JMP0;
           default    : outNextState = STATE_FETCH0;
         endcase
      end
   endtask

   task nextStateAnd0;
      output state_t outNextState;
      begin
         outNextState = STATE_FETCH0;
      end
   endtask

   task nextStateAdd0;
      output state_t outNextState;
      begin
         outNextState = STATE_FETCH0;
      end
   endtask

   task nextStateNot0;
      output state_t outNextState;
      begin
         outNextState = STATE_FETCH0;
      end
   endtask

   task nextStateBr0;
      output state_t outNextState;
      begin
         if (nMatches | zMatches | pMatches) begin
            outNextState = STATE_BR1;
         end else begin
            outNextState = STATE_FETCH0;
         end
      end
   endtask

   task nextStateBr1;
      output state_t outNextState;
      begin
         outNextState = STATE_FETCH0;
      end
   endtask

   task nextStateJmp0;
      output state_t outNextState;
      begin
         outNextState = STATE_FETCH0;
      end
   endtask

   task nextStateJsr0;
      output state_t outNextState;
      begin
         outNextState = STATE_JSR1;
      end
   endtask

   task nextStateJsr1;
      output state_t outNextState;
      begin
         outNextState = STATE_FETCH0;
      end
   endtask

   task nextStateLd0;
      output state_t outNextState;
      begin
         outNextState = STATE_ALL_LD0;
      end
   endtask

   task nextStateLdi0;
      output state_t outNextState;
      begin
         outNextState = STATE_LDI1;
      end
   endtask

   task nextStateLdi1;
      output state_t outNextState;
      begin
         outNextState = STATE_LDI2;
      end
   endtask

   task nextStateLdi2;
      output state_t outNextState;
      begin
         outNextState = STATE_ALL_LD0;
      end
   endtask

   task nextStateLdr0;
      output state_t outNextState;
      begin
         outNextState = STATE_ALL_LD0;
      end
   endtask

   task nextStateAllLd0;
      output state_t outNextState;
      begin
         outNextState = STATE_ALL_LD1;
      end
   endtask

   task nextStateAllLd1;
      output state_t outNextState;
      begin
         outNextState = STATE_FETCH0;
      end
   endtask

   task nextStateLea0;
      output state_t outNextState;
      begin
         outNextState = STATE_FETCH0;
      end
   endtask

   task nextStateSt0;
      output state_t outNextState;
      begin
         outNextState = STATE_ALL_ST0;
      end
   endtask

   task nextStateSti0;
      output state_t outNextState;
      begin
         outNextState = STATE_STI1;
      end
   endtask

   task nextStateSti1;
      output state_t outNextState;
      begin
         outNextState = STATE_STI2;
      end
   endtask

   task nextStateSti2;
      output state_t outNextState;
      begin
         outNextState = STATE_ALL_ST0;
      end
   endtask

   task nextStateStr0;
      output state_t outNextState;
      begin
         outNextState = STATE_ALL_ST0;
      end
   endtask

   task nextStateAllSt0;
      output state_t outNextState;
      begin
         outNextState = STATE_ALL_ST1;
      end
   endtask

   task nextStateAllSt1;
      output state_t outNextState;
      begin
         outNextState = STATE_FETCH0;
      end
   endtask

   task nextStateTrap0;
      output state_t outNextState;
      begin
         outNextState = STATE_TRAP1;
      end
   endtask

   task nextStateTrap1;
      output state_t outNextState;
      begin
         outNextState = STATE_TRAP2;
      end
   endtask

   task nextStateTrap2;
      output state_t outNextState;
      begin
         outNextState = STATE_FETCH0;
      end
   endtask

   task nextStateUnknown;
      output state_t outNextState;
      begin
         outNextState = STATE_UNKNOWN;
      end
   endtask


   /* Intermediates calculations */
   always_comb begin
      opCode = ir[15:12];
      irFlagN = ir[11];
      irFlagZ = ir[10];
      irFlagP = ir[9];
      nMatches = flagN & irFlagN;
      zMatches = flagZ & irFlagZ;
      pMatches = flagP & irFlagP;
   end

endmodule
