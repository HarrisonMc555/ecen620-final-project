# ECEn 620 Final Project

Dallin Skouson and Harrison McCullough


## Instructions

Go to the `src/test` directory. You can run `make` to compile the files and
`make test` to run the test. You will need to specify a test name, which can be
passed to `make test`. Here are the valid tests:

  - `make test +TESTNAME=TestRandomGood`
  - `make test +TESTNAME=TestRandomAll`
  - `make test +TESTNAME=TestWithReset`


## Finishing

The testbench is not smart enough stop automatically, so you will have to simply
watch the coverage/assertions window and see when things are done or go poorly.

Manually step time with the `run` command. The testbench will print out a
summary of the errors every 100 transactions (~5000 nanoseconds).
