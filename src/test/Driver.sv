class Driver;

   // Driver_cbs cbs[$];
   mailbox #(Transaction) gen2drv;
   virtual dut_if dut_if;

   function new(input mailbox #(Transaction) gen2drv, virtual dut_if dut_if);
      this.gen2drv = gen2drv;
      this.dut_if = dut_if;
   endfunction

   task run(int num_trans);
      // bit drop;
      Transaction trans;
      reset();
      repeat (num_trans) begin
         gen2drv.peek(trans);
         // foreach (cbs[i]) cbs[i].pre_tx(trans, drop);
         // if (drop) continue;
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
      #10ns;
      // Actually drive the transaction...
   endtask;

endclass;
