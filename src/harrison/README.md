# Harrison's DUT

## Bugs

- The `BR` instruction was taking one fewer clock cycles than the specification
  said.
- The `address` and `writeEnable` lines were disconnected.
- The `SR1` register was not correctly set for certain instructions.
