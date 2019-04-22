import verification_pkg::Transaction;
import verification_pkg::Verification;

class Monitor;
   //reads the dut and packages the information nicely with its coresponding transaction
   Transaction tr;
   Verification vr;
   //gets a transaction from the driver
   //mailbox #(Transaction) mbx_in;
   //this mailbox will pass along the verification object to the monitor
   mailbox #(Verification) mbx_out;
   event   dut_reset;
   //event dut_reset2;
   virtual dut_if dif;

   LC3_result result;
   LC3_result last_result;

   function new(
                //input mailbox #(Transaction) mbx_in,
                mailbox #(Verification) mbx_out,
                virtual dut_if dif,
                event   dut_reset
                );
      //this.mbx_in = mbx_in;
      this.mbx_out = mbx_out;
      this.dut_reset = dut_reset;
      this.dif = dif;
   endfunction


   task time_dut();
      int i;
      forever begin
         @(dif.cb)
           result.cycles_taken++;
         if(/*dut memory write conditions here*/
            dif.writeEnable
            ) begin
            result.write_address.push_back(dif.address);
            result.write_data.push_back(dif.dataFromMemory);
            result.write_count++;
         end
         if(/*dut about to cycle conditions here*/
            dut.controller.nextState === lc3::STATE_FETCH0 //harrison
            //dut.state === 0 //dallin
            ) begin
            last_result = result;
            result = new();
            last_result.PC = dut.PC;
            for(i = 0; i < 8; i++) begin
               last_result.regs[i] = dut.regs[i];
            end
            last_result.P_flag = dut.Pf; //dallin
            last_result.Z_flag = dut.Zf;
            last_result.N_flag = dut.Nf;
            //last_result.P_flag = dut.flagP; //harrison
            //last_result.N_flag = dut.flagN;
            //last_result.Z_flag = dut.flagZ;
            last_result.to_dut = tr;
            vr.dut_result = last_result;
            mbx_out.put(vr);
            vr = new();
            -> dut_reset;
            //-> dut_reset2;
         end
      end
   endtask;



   task read_mail();
      tr = new();
      forever begin
         mbx_in.get(tr);
         vr = new();
         //get the transaction out and store it in the verification packet
         mbx_out.put(vr);
      end
   endtask

   task run();
      result = new();
      vr = new();
      time_dut();
   endtask

   task wrap_up();
   endtask
endclass
