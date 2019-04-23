`default_nettype none

import lc3::*;

module datapath (
                 /***** Output *****/
                 /* Instruction Register */
                 ir,
                 /* Condition Codes */
                 flagN, flagZ, flagP,

                 /***** Input *****/
                 /* System */
                 clk, reset,
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
                 /* Memory (from testbench) */
                 dataToMemory, dataFromMemory, address, writeMemory
                 );
   output logic [15:0] ir, dataToMemory, address;
   output logic        flagN, flagZ, flagP, writeMemory;
   input logic         clk, reset, enaMARM, selMAR, enaPC, ldPC, regWE, enaMDR,
                       ldMAR, ldMDR, memWE, selMDR, enaALU, ldIR, selEAB1,
                       flagWE;
   
   input logic [1:0]   selPC, selEAB2;
   input logic [2:0]   DR, SR1, SR2;
   input logic [15:0]  dataFromMemory;
   input               aluControl_t aluControl;


   /* Globals */
   logic [15:0] bus;
   logic [15:0] Ra, Rb;
   logic [15:0] MARMuxOut, pcOut, marOut, mdrOut, MDRMuxOut, aluOut, eabOut;

   /* Bus */
   always_comb
     begin
        bus <= enaMARM ? MARMuxOut :
               enaPC   ? pcOut     :
               enaMDR  ? mdrOut    :
               enaALU  ? aluOut    :
               'Z;
     end

   /* Effective Address Block (EAB) */
   logic [15:0] irSext10_0, irSext8_0, irSext5_0, addr1, addr2;

   always_comb begin
      irSext5_0  = {{10{ir[ 5]}}, ir[ 5:0]};
      irSext8_0  = {{ 7{ir[ 8]}}, ir[ 8:0]};
      irSext10_0 = {{ 5{ir[10]}}, ir[10:0]};

      addr1 = selEAB1 ? Ra : pcOut;

      unique case (selEAB2)
        2'b00   : addr2 = 0;
        2'b01   : addr2 = irSext5_0;
        2'b10   : addr2 = irSext8_0;
        2'b11   : addr2 = irSext10_0;
        default : addr2 = 'X;
      endcase

      eabOut = addr1 + addr2;
   end

   /* Memory Address Multiplexer (MARMux) */
   logic [15:0] irZext7_0;

   always_comb begin
      irZext7_0 = {{8{1'b0}}, ir[7:0]};
      MARMuxOut = selMAR ? irZext7_0 : eabOut;
   end

   /* Program Counter (PC) */
   logic [15:0] incPC, nextPC;

   always_comb begin
      incPC = pcOut + 1;
      unique case (selPC)
        2'b00   : nextPC = incPC;
        2'b01   : nextPC = eabOut;
        2'b10   : nextPC = bus;
        default : nextPC = 'X;
      endcase
   end

   always_ff @ (posedge clk) begin
      if (reset) begin
         pcOut <= 0;
      end else if (ldPC) begin
         pcOut <= nextPC;
      end
   end

   /* Instruction Register (IR) */
   always_ff @ (posedge clk) begin
      if (reset) begin
         ir <= 0;
      end else if (ldIR) begin
         ir <= bus;
      end
   end

   /* Condition Code Flags */
   logic nextFlagN, nextFlagZ, nextFlagP;

   always_comb begin
      nextFlagN = bus[15] == 1'b1;
      nextFlagZ = bus == 16'h0000;
      nextFlagP = ~(nextFlagN | nextFlagZ);
   end

   always_ff @ (posedge clk) begin
      if (reset) begin
         flagN <= 0;
         flagZ <= 1; /* Arbitrary choice, ensures always one high */
         flagP <= 0;
      end else if (flagWE) begin
         flagN <= nextFlagN;
         flagZ <= nextFlagZ;
         flagP <= nextFlagP;
      end
   end

   /* Arithmetic Logic Unit (ALU) */
   logic [15:0] irSext4_0, ALUSR1, ALUSR2;

   always_comb begin
      irSext4_0 = {{ 11{ir[4]}}, ir[4:0]};
      ALUSR1 = Ra;
      ALUSR2 = ir[5] ? irSext4_0 : Rb;
      unique case (aluControl)
        ALU_CONTROL_ADD : aluOut = ALUSR1 + ALUSR2; /* Add  */
        ALU_CONTROL_AND : aluOut = ALUSR1 & ALUSR2; /* And  */
        ALU_CONTROL_NOT : aluOut = ~ALUSR1;         /* Not  */
        default         : aluOut = ALUSR1;          /* Pass */
      endcase
   end

   /* Memory */
   always_comb begin
      writeMemory = memWE;
      address = marOut;
      dataToMemory = mdrOut;
   end

   always_comb begin
      MDRMuxOut = selMDR ? dataFromMemory : bus;
   end

   always_ff @ (posedge clk) begin
      if (reset) begin
         marOut <= 0;
         mdrOut <= 0;
      end else begin
         if (ldMAR) begin
            marOut <= bus;
         end
         if (ldMDR) begin
            mdrOut <= MDRMuxOut;
         end
      end
   end

   /* Register File */
   logic [15:0] registerFile [0:7];

   always_comb begin
      Ra = registerFile[SR1];
      Rb = registerFile[SR2];
   end

   always_ff @ (posedge clk) begin
      if (reset) begin
         registerFile[0] = 0;
         registerFile[1] = 0;
         registerFile[2] = 0;
         registerFile[3] = 0;
         registerFile[4] = 0;
         registerFile[5] = 0;
         registerFile[6] = 0;
         registerFile[7] = 0;
      end else if (regWE) begin
         registerFile[DR] <= bus;
      end
   end

endmodule
