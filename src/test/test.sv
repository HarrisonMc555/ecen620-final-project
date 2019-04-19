program automatic test;

   TestBase tb;

   initial begin
      // List each test
      // static TestGood TestGood_handle = new();
      // static Test_v3 Test_v3_handle = new();
      // static TestBad TestBad_handle = new();
      tb = TestRegistry::get_test();
      tb.run_test();
   end

endprogram
