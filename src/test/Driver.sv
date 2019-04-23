class Driver;

   // Driver_cbs cbs[$];
   mailbox #(Transaction) gen2drv;
   mailbox #(Transaction) drv2chk;
   virtual dut_if dif;
   mailbox #(bit) transactionDone;

   logic[15:0] mem_data = 0;

   function new(input mailbox #(Transaction) gen2drv,
                input mailbox #(Transaction) drv2chk,
                virtual dut_if               dif,
                input mailbox #(bit)         transactionDone);
      this.gen2drv = gen2drv;
      this.drv2chk = drv2chk;
      this.dif = dif;
      this.transactionDone = transactionDone;
   endfunction

   task run();
      Transaction trans = new();
      dif.reset = 1;
      repeat (5) @(posedge dif.clk);
      @(negedge dif.clk);
      dif.reset = 0;
      forever begin
         gen2drv.peek(trans);
         // foreach (cbs[i]) cbs[i].pre_tx(trans, drop);
         // @(posedge dif.clk);
         transmit(trans);
         // foreach (cbs[i]) cbs[i].post_tx(trans);
         gen2drv.get(trans);
      end
   endtask

   task wrap_up();
      // Do nothing
   endtask

   task transmit(input Transaction trans);
      bit bogus;
      $display("Transaction:");
      $display("\tinstruction: %0b", trans.instruction);
      $display("\tis_reset: %0b", trans.is_reset);
      $display("\treset_clock_cycle: %0d", trans.reset_clock_cycle);
      drv2chk.put(trans);
      if (trans.is_reset) begin
         $display("Transaction is reset!!");
         $display("\tcycle: %0d", trans.reset_clock_cycle);
         if (trans.reset_clock_cycle == 0) begin
            $display("\tIt was in cycle 0", trans.reset_clock_cycle);
            dif.reset = 1;
            @(posedge dif.clk);
            dif.reset = 0;
            return;
         end
         $display("\tone more cycle");
         @(posedge dif.clk); // Cycle where IR is loaded into MAR
         // golden.memory[dif.address] = trans.instruction;
         dif.dataFromMemory = trans.instruction;
         if (trans.reset_clock_cycle == 1) begin
            $display("\tIt was in cycle 1", trans.reset_clock_cycle);
            dif.reset = 1;
            @(posedge dif.clk);
            dif.reset = 0;
            return;
         end
         $display("\tone more cycle");
         repeat (trans.reset_clock_cycle - 2) begin
            $display("\tone more cycle");
            if (transactionDone.num() > 0) begin
               // Transaction finished before we could reset.
               // That's fine.
               transactionDone.get(bogus);
               return;
            end
            @(posedge dif.clk);
         end
         // If we get here, we will reset.
         dif.reset = 1;
         @(posedge dif.clk);
         dif.reset = 0;

      end else begin
         @(posedge dif.clk); // Cycle where IR is loaded into MAR
         // golden.memory[dif.address] = trans.instruction;
         dif.dataFromMemory = trans.instruction;
         @(posedge dif.clk);
         mem_data = $urandom();
         dif.dataFromMemory = mem_data;
         trans.mem_data.push_back(mem_data);
         transactionDone.get(bogus);
      end
   endtask;

endclass;
