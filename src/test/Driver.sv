class Driver;

   // Driver_cbs cbs[$];
   mailbox #(Transaction) gen2drv;
   virtual dut_if dut_if;
   event transactionDone;

   function new(input mailbox #(Transaction) gen2drv, virtual dut_if dut_if, 
                event transactionDone);
      this.gen2drv = gen2drv;
      this.dut_if = dut_if;
   endfunction

   task run(int num_trans);
      // bit drop;
      Transaction trans;
      reset();
      while (1); begin // not done
         gen2drv.peek(trans);
         // foreach (cbs[i]) cbs[i].pre_tx(trans, drop);
         transmit(trans);
         // foreach (cbs[i]) cbs[i].post_tx(trans);
         gen2drv.get(trans);
      end
   endtask

   task reset();
      // Do nothing (?)
   endtask;

   task wrap_up();
      // Do nothing
   endtask

   task transmit(input Transaction trans);
      @(posedge dut_if.clk); // Cycle where IR is loaded into MAR
      // golden.memory[dut_if.address] = trans.instruction;
      @(transactionDone);
   endtask;

endclass;
