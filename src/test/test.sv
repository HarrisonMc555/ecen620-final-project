program automatic test(dut_if.Memory dut_if);

   TestBase tb;

   initial begin
      // List each test
      // static TestGood TestGood_handle = new();
      // static Test_v3 Test_v3_handle = new();
      // static TestBad TestBad_handle = new();
      static TestRandomGood trg = new(dut_if);
      static TestWithBad twb = new(dut_if);
      tb = TestRegistry::get_test();
      tb.run_test();
   end

endprogram
