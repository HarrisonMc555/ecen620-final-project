# Changelog

## Dallin Friday Night:

I put in most of the back side stuff. There is some working out that needs to be
done to make sure that all the connections wire up. I didnt' get around to
connecting it to the environment.

Possibly the hardest thing to do will be to figure out how to put in the random
data that was written to the dut into the transaction. That's the only thing all
these changes would require

### What I did:

Monitor:

Watches the dut, counts cycles, signals the event that the dut is done.  Also
packages what the dut does into a verification object and passes that to the
checker


Checker:

Waits for the verification object from the monitor. runs the golden
model (0 cycles) and packages the result into the verification object. then
calls the scoreboard check

Scoreboard_pkg:

Ripped off from the lab 8? scoreboard that we used. I made some improvments.  it
now works with our verification objects, it also keeps track of the number of
errors that might occur if we decide we want to keep going after an error.

golden model:

Runs in 1 cycle. keeps track, however of how long that instruction should take.
I think that all instructions are implemented and should work.  I also decided
that for simplicity I would ignore any read and just check the registers.

TODO:

I think I figured out what is ment by the monitor and checker existing now that
I did this It would be a good idea to make them actually do what I think they
should. Right now I have the functionality of both inside the monitor kinda.

TODO:

I also need to look at a DUT to make sure I am getting the signals I need out
properly.



## Harrison Monday morning:

I combined Transaction.sv and Verification.sv into verification_pkg.sv. I fixed
several bugs, mostly consisting of missing semicolons and/or typos.


TODO:

The GoldenLC3 does not compile. It is referencing signals that are never
defined, and I'm not sure what you were going for. If you could look at that I
can try to make sure the front half all fits together.

It looks like everything else is compiling right now.
