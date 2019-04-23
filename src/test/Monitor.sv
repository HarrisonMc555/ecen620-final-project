import verification_pkg::Transaction;
import verification_pkg::Verification;

class Monitor;
   //reads the dut and packages the information nicely with its coresponding transaction
   Transaction tr;
   Verification vr;
   //gets a transaction from the driver
   //mailbox #(Transaction) mbx_out;
   //this mailbox will pass along the verification object to the monitor
   mailbox #(Verification) mbx_out;
   mailbox #(bit)          transactionDone;
   virtual dut_if dif;

   LC3_result result;
   LC3_result last_result;

   function new(
                //input mailbox #(Transaction) mbx_out,
                mailbox #(Verification) mbx_out,
                virtual dut_if dif,
                mailbox #(bit) transactionDone
                );
      //this.mbx_out = mbx_out;
      this.mbx_out = mbx_out;
      this.transactionDone = transactionDone;
      this.dif = dif;
   endfunction


   task time_dut();
      int i;
      result = new();
      @(negedge dif.reset);
      forever begin
         @(negedge dif.clk);
           result.cycles_taken++;
         if(/*dut memory write conditions here*/
            dif.writeEnable
            ) begin
            result.write_address.push_back(dif.address);
            result.write_data.push_back(dif.dataToMemory);
            result.write_count++;
         end
         if(/*dut about to cycle conditions here*/
            //top.dut.controller.curState === lc3::STATE_FETCH0 //harrison
            top.dut.state === 0; //dallin
            ) begin
            last_result = result;
            result = new();
            //last_result.PC = top.dut.datapath.pcOut; //harrison
            last_result.PC = top.dut.PC; //dallin
            for(i = 0; i < 8; i++) begin
               //last_result.regs[i] = top.dut.datapath.registerFile[i]; //harrison
               last_result.regs[i] = top.dut.regs[i]; //dallin
            end
            last_result.P_flag = top.dut.Pf; //dallin
            last_result.Z_flag = top.dut.Zf;
            last_result.N_flag = top.dut.Nf;
            //last_result.P_flag = top.dut.datapath.flagP; //harrison
            //last_result.N_flag = top.dut.datapath.flagN;
            //last_result.Z_flag = top.dut.datapath.flagZ;
            vr = new();
            vr.to_dut = tr;
            vr.dut_result = last_result;
            mbx_out.put(vr);
            transactionDone.put(1);
         end
      end
   endtask;



   //task read_mail();
   //   tr = new();
   //   forever begin
   //      //mbx_out.get(tr);
   //      vr = new();
   //      //get the transaction out and store it in the verification packet
   //      mbx_out.put(vr);
   //   end
   //endtask

   task run();
      time_dut();
   endtask

   task wrap_up();
   endtask
endclass
