`ifndef ASSERT_MACROS
`define ASSERT_MACROS

`define assert_clk_xrst(ASSERTION) \
    assert property (@(posedge clk) disable iff(reset) ASSERTION)

`define assert_clk(ASSERTION) \
    assert property (@(posedge clk) ASSERTION)

`endif
