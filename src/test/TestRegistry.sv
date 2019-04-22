class TestRegistry;

   static TestBase registry[string];

   static function void register(string name, TestBase t);
      registry[name] = t;
      $display("Registered Test %0s", name);
   endfunction

   static function TestBase get_test();
      string name;

      if (!$value$plusargs("TESTNAME=%s", name)) begin
         $display("ERROR: No +TESTNAME switch found");
         $finish(1);
      end else begin
         $display("%m found +TESTNAME=%s", name);
      end

      if (!registry.exists(name)) begin
         $display("ERROR: '%0s' is not a valid test name", name);
         $finish(1);
      end
      return registry[name];
   endfunction

endclass


class TestRandomGood extends TestBase;

   function new(virtual dut_if dut_if);
      super.new(dut_if);
      TestRegistry::register("TestRandomGood", this);
   endfunction

   virtual task run_test();
      // Driver_cb_send_to_scoreboard scoreboard_callback;
      // $display("%m");
      env.gen_cfg();
      env.build();
      // scoreboard_callback = new(env.sb);
      // env.drv.cbs.push_back(scoreboard_callback);
      env.run();
      env.wrap_up();
   endtask

endclass

class TestWithBad extends TestBase;

   function new(virtual dut_if dut_if);
      super.new(dut_if);
      TestRegistry::register("TestWithBad", this);
   endfunction

   virtual task run_test();
      // Driver_cb_send_to_scoreboard scoreboard_callback;
      // $display("%m");
      env.gen_cfg();
      env.build();
      // scoreboard_callback = new(env.sb);
      // env.drv.cbs.push_back(scoreboard_callback);
      env.gen.blueprint.valid_instruction.constraint_mode(0);
      env.run();
      env.wrap_up();
   endtask

endclass
