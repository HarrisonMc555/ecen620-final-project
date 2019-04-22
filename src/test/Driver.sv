class Driver;

   // Driver_cbs cbs[$];
   mailbox #(Transaction) gen2drv;
   mailbox #(Transaction) drv2chk;
   virtual dut_if dif;
   event transactionDone;

   logic[15:0] mem_data = 0;

   function new(input mailbox #(Transaction) gen2drv,
                input mailbox #(Transaction) drv2chk,
                virtual       dut_if dif,
                event         transactionDone);
      this.gen2drv = gen2drv;
      this.drv2chk = drv2chk;
      this.dif = dif;
      this.transactionDone = transactionDone;
   endfunction

   task run(int num_trans);
      // bit drop;
      Transaction trans = new();
      //reset();
      //while (1); begin // not done
      repeat(num_trans) begin
         gen2drv.peek(trans);
         // foreach (cbs[i]) cbs[i].pre_tx(trans, drop);
         transmit(trans);
         // foreach (cbs[i]) cbs[i].post_tx(trans);
         gen2drv.get(trans);
      end
   endtask

   //task reset();
   //   // Do nothing (?)
   //endtask;

   task wrap_up();
      // Do nothing
   endtask

   task transmit(input Transaction trans);
      @(posedge dif.clk); // Cycle where IR is loaded into MAR
      // golden.memory[dif.address] = trans.instruction;
      dif.dataToMemory = trans.instruction;
      @(posedge dif.clk);  
      mem_data = $urandom(); 
      dif.dataToMemory = mem_data;
      trans.mem_data.push_back(mem_data);
      drv2chk.put(trans);
      @(transactionDone);
   endtask;

endclass;
