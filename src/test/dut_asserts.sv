module dut_asserts
  (input bit        clk, reset,
   input bit [15:0] dataFromMemory,
   input bit [15:0] dataToMemory,
   input bit [15:0] address,
   input bit        writeEnable);

`include "assert_macros.sv"

   // ERR_FIFO_RESET_SHOULD_CAUSE_EMPTY1_FULL0_RPTR0_WPTR0_CNT0:
   //   `assert_clk( !rst_n |-> empty && !full && rptr == 0 && wptr == 0 && cnt == 0);

   // ERR_FIFO_SHOULD_BE_FULL:
   //   `assert_clk_xrst( cnt >= 16 |-> full);

   // ERR_FIFO_SHOULD_NOT_BE_FULL:
   //   `assert_clk_xrst( cnt < 16 |-> !full);

   // ERR_FIFO_DO_NOT_GO_FULL:
   //   `assert_clk_xrst( cnt == 15 && write && !read |-> ##1 full);

   // ERR_FIFO_SHOULD_BE_EMPTY:
   //   `assert_clk_xrst( cnt == 0 |-> empty);

   // ERR_FIFO_DID_NOT_GO_EMPTY:
   //   `assert_clk_xrst( cnt == 1 && read && !write |-> ##1 empty);

   // ERR_FIFO_FULL_WRITE_CAUSED_FULL_FLAG_TO_CHANGE:
   //   `assert_clk_xrst( full && write && !read |-> ##1 $stable(full));

   // ERR_FIFO_FULL_WRITE_CAUSED_WPTR_TO_CHANGE:
   //   `assert_clk_xrst( full && write && !read |-> ##1 $stable(wptr));

   // ERR_FIFO_EMPTY_READ_CAUSED_EMPTY_FLAG_TO_CHANGE:
   //   `assert_clk_xrst( empty && read && !write |-> ##1 $stable(empty));

   // ERR_FIFO_EMPTY_READ_CAUSED_RPTR_TO_CHANGE:
   //   `assert_clk_xrst( empty && read && !write |-> ##1 $stable(rptr));

   // ERR_FIFO_FULL_EMPTY_BOTH_HIGH:
   //   `assert_clk_xrst( !(empty && full) );

   // ERR_FIFO_READWRITE_ILLEGAL_FIFO_FULL_OR_EMPTY:
   //   `assert_clk_xrst( read && write |-> ##1 !full && !empty );

endmodule
