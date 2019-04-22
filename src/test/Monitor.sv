import verification_pkg::Transaction;
import verification_pkg::Verification;

class Monitor;
   //reads the dut and packages the information nicely with its coresponding transaction
   Transaction tr;
   Verification vr;
   //gets a transaction from the driver
   //mailbox #(Transaction) mbx_in;
   //this mailbox will pass along the verification object to the monitor
   mailbox #(Verification) mbx_in;
   event   dut_reset;
   //event dut_reset2;
   virtual dut_if dif;

   LC3_result result;
   LC3_result last_result;

   function new(
                //input mailbox #(Transaction) mbx_in,
                mailbox #(Verification) mbx_in,
                virtual dut_if dif,
                event   dut_reset
                );
      //this.mbx_in = mbx_in;
      this.mbx_in = mbx_in;
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
            top.dut.controller.nextState === lc3::STATE_FETCH0 //harrison
            //dut.state === 0 //dallin
            ) begin
            last_result = result;
            result = new();
            last_result.PC = top.dut.datapath.pcOut; //harrison
            for(i = 0; i < 8; i++) begin
               last_result.regs[i] = top.dut.datapath.regs[i]; //harrison
            end
            //last_result.P_flag = top.dut.Pf; //dallin
            //last_result.Z_flag = top.dut.Zf;
            //last_result.N_flag = top.dut.Nf;
            last_result.P_flag = top.dut.datapath.flagP; //harrison
            last_result.N_flag = top.dut.datapath.flagN;
            last_result.Z_flag = top.dut.datapath.flagZ;
            vr.to_dut = tr;
            vr.dut_result = last_result;
            mbx_in.put(vr);
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
         mbx_in.put(vr);
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
