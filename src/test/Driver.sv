class Driver;

   // Driver_cbs cbs[$];
   mailbox #(Transsaction) gen2drv;

   function new(input mailbox #(Transsaction) gen2drv);
      this.gen2drv = gen2drv;
   endfunction

   task run(int num_trans);
      // bit drop;
      Transsaction trans;
      reset();
      repeat (num_trans) begin
         gen2drv.peek(trans);
         // foreach (cbs[i]) cbs[i].pre_tx(trans, drop);
         // if (drop) continue;
         transsmit(trans);
         foreach (cbs[i]) cbs[i].post_tx(trans);
         gen2drv.get(trans);
      end
   endtask

   task reset();
      // Do nothing (?)
   endtask;

   task wrap_up();
      // Do nothing
   endtask

   task transsmit(input Transsaction trans);
      #10ns;
      // Actually drive the transaction...
   endtask;

endclass;
