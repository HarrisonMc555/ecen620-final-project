import verification_pkg::LC3_result;
import verification_pkg::Transaction;

class GoldenLC3;

   const logic [3:0] ADD  = 4'b0001;
   const logic [3:0] AND  = 4'b0101;
   const logic [3:0] NOT  = 4'b1001;
   const logic [3:0] BR   = 4'b0000;
   const logic [3:0] JMP  = 4'b1100;
   const logic [3:0] JSR  = 4'b0100;
   //const logic[3:0] RET  = 4'b1100; //same as jmp
   const logic [3:0] LD   = 4'b0010;
   const logic [3:0] LDI  = 4'b1010;
   const logic [3:0] LDR  = 4'b0110;
   const logic [3:0] LEA  = 4'b1110;
   const logic [3:0] ST   = 4'b0011;
   const logic [3:0] STI  = 4'b1011;
   const logic [3:0] STR  = 4'b0111;
   const logic [3:0] TRAP = 4'b1111;
   //const logic[3:0] RTI  = 4'b0001; //no interupts
   //const logic[3:0] RESERVERD = 4'b1101; //just a nop

   logic [15:0]      PC = 0;
   logic [15:0]      regfile [7:0] = {0,0,0,0,0,0,0,0};
   logic             Nf = 0;
   logic             Pf = 0;
   logic             Zf = 0;

   LC3_result res;

   function void set_regs(ref logic[15:0] regs[7:0]);
      int            i;
      for(i = 0; i < 8; i++) begin
         regs[i] = regfile[i];
      end
   endfunction

   function void set_npz(logic[15:0] alu_out);
      Nf = alu_out[15];
      Pf = ~(alu_out[15]) && alu_out !== 16'h000;
      Zf = (alu_out === 16'h0000);
   endfunction;

   function LC3_result run(Transaction tr);
      int i;
      logic [15:0] instruction;
      logic [ 3:0] opcode;
      logic [ 2:0] sr1;
      logic [ 2:0] sr2;
      logic [ 2:0] dr;
      logic        imm_sw;
      logic [15:0] imm5;
      logic        br_n;
      logic        br_z;
      logic        br_p;
      logic [ 2:0] base_r;
      logic        jsr_sw;
      logic [15:0] pcoffset11;
      logic [15:0] pcoffset9;
      logic [15:0] pcoffset6;
      logic [ 7:0] trapvect8;
      logic [15:0] ir;

      res         = new();
      ir          = tr.instruction;
      opcode      = ir[15:12];
      dr          = ir[11: 9];
      sr1         = ir[ 8: 6];
      sr2         = ir[ 2: 0];
      imm_sw      = ir[ 5];
      imm5        = {{11{ir[4]}}, ir[ 4: 0]};
      br_n        = ir[11];
      br_z        = ir[10];
      br_p        = ir[ 9];
      base_r      = ir[ 8: 6];
      jsr_sw      = ir[11]; //0: jsrr, 1: jsr
      pcoffset6   = {{10{ir[5]}}, ir[ 5: 0]};
      pcoffset9   = {{7{ir[8]}}, ir[ 8: 0]};
      pcoffset11  = {{5{ir[10]}}, ir[10: 0]};
      trapvect8   = ir[ 7: 0];

      PC = PC + 1;

      res.write_count = 0;

      if(opcode === ADD) begin
         res.cycles_taken = 5;
         if(imm_sw) begin
            regfile[dr] = regfile[sr1] + imm5;
         end
         else begin
            regfile[dr] = regfile[sr1] + regfile[sr2];
         end
         set_npz(regfile[dr]);
      end
      else if(opcode === AND) begin
         res.cycles_taken = 5;
         if(imm_sw) begin
            regfile[dr] = regfile[sr1] & imm5;
         end
         else begin
            regfile[dr] = regfile[sr1] & regfile[sr2];
         end
         set_npz(regfile[dr]);
      end
      else if(opcode === NOT) begin
         res.cycles_taken = 5;
         regfile[dr] = ~(regfile[sr1]);
         set_npz(regfile[dr]);
      end
      else if(opcode === BR) begin
         res.cycles_taken = 5;
         if((Nf && br_n) || (Pf && br_p) || (Zf && br_z)) begin
            res.cycles_taken += 1;
            PC = PC + pcoffset9;
         end
      end
      else if(opcode === JMP) begin //also RET
         res.cycles_taken = 5;
         PC = regfile[sr1];
      end
      else if(opcode === JSR) begin //aslo JSRR
         res.cycles_taken = 6;
         if(jsr_sw) begin
            regfile[7] = PC;
            PC = PC + pcoffset11;
         end
         else begin
            regfile[7] = PC;
            PC = regfile[base_r];
         end
      end
      else if(opcode === LD) begin
         res.cycles_taken = 7;
         regfile[dr] = tr.mem_data[0];
         set_npz(regfile[dr]);
      end
      else if(opcode === LDI) begin
         res.cycles_taken = 9;
         if($size(tr.mem_data) > 1) begin
            regfile[dr] = tr.mem_data[1];
         end
         else begin
            regfile[dr] = tr.mem_data[0];
         end
         set_npz(regfile[dr]);
      end
      else if(opcode === LDR) begin
         res.cycles_taken = 7;
         regfile[dr] = tr.mem_data[0];
         set_npz(regfile[dr]);
      end
      else if(opcode === LEA) begin
         res.cycles_taken = 5;
         regfile[dr] = PC + pcoffset9;
         set_npz(regfile[dr]);
      end
      else if(opcode === ST) begin
         res.cycles_taken = 7;
         res.write_data.push_back(regfile[dr]);
         res.write_address.push_back(pcoffset9 + PC);
         res.write_count = 1;
      end
      else if(opcode === STI) begin
         res.cycles_taken = 10;
         res.write_data.push_back(regfile[dr]);
         res.write_count = 1;
         res.write_address.push_back(tr.mem_data[0]);
      end
      else if(opcode === STR) begin
         res.cycles_taken = 7;
         res.write_count = 1;
         res.write_address.push_back(regfile[base_r] + pcoffset6);
         res.write_data.push_back(regfile[dr]);
      end
      else if(opcode === TRAP) begin
         res.cycles_taken = 7;
         regfile[7] = PC;
         PC = tr.mem_data[0];
      end
      else begin //NOP
         res.cycles_taken = 4;
      end
      if(tr.is_reset && tr.reset_clock_cycle <= res.cycles_taken) begin
         PC = 0;
         Pf = 0;
         Zf = 0;
         Nf = 0;
         for(i=0; i<8; i++) begin
            regfile[i] = 0;
         end
      end
      res.PC = PC;
      set_regs(res.regs);
      res.P_flag = Pf;
      res.Z_flag = Zf;
      res.N_flag = Nf;
      return res;
   endfunction

   //begin
   //    memWE = 0;
   //    if(opcode == 4'b0101) begin //and
   //        if (instruction[5])
   //        begin
   //            regfile[instruction[11:9]] = regfile[instruction[8:6]] & instruction[4:0];
   //        end
   //        else begin
   //            regfile[instruction[11:9]] = regfile[instruction[8:6]] & regfile[instruction[2:0]];
   //        end
   //    end
   //    else if(opcode == 4'b0001) begin //add
   //        if (instruction[5])
   //        begin
   //            regfile[instruction[11:9]] = regfile[instruction[8:6]] + instruction[4:0];
   //        end
   //        else begin
   //            regfile[instruction[11:9]] = regfile[instruction[8:6]] + regfile[instruction[2:0]];
   //        end
   //    end
   //    else if(opcode == 4'b1001) begin //not
   //        regfile[instruction[11:9]] = ~regfile[instruction[8:6]];
   //    end
   //    else if(opcode == 4'b0100) begin //jsr
   //        regfile[7] = PC + 1;
   //        PC = instruction[10:0] + PC;
   //    end
   //    else if(opcode == 4'b0000) begin //Br
   //        if((Nf && instruction[11]) || (Pf && instruction[10]) || (Zf && instruction[9])) begin
   //            PC = instruction[8:0] + PC;
   //        end
   //        else begin
   //            PC = PC + 1;
   //        end
   //    end
   //    else if(opcode == 4'b0010) begin //ld
   //        memAddrIn = instruction[8:0] + PC;
   //        regfile[instruction[11:9]] = memDataIn;
   //    end
   //    else if(opcode == 4'b0011) begin //st
   //        memWE = 1;
   //        memAddr = PC + instruction[8:0];
   //        memDataIn = regfile[instruction[11:9]];
   //    end
   //    else if(opcode == 4'b1100) begin //jmp or ret
   //        PC = PC regfile[instruction[8:6]];
   //    end
   //    else begin
   //        state <= 1;
   //    end
   //end


endclass
