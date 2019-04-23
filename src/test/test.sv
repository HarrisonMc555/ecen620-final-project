program automatic test(dut_if.Memory dut_if);

   TestBase tb;

   initial begin
      // List each test
      static TestRandomGood trg = new(dut_if);
      static TestRandomAll tra = new(dut_if);
      tb = TestRegistry::get_test();
      tb.run_test();
   end

endprogram
