sources = clock_unit.sv Environment.sv macros.sv TestBase.sv TestRegistry.sv test.sv top.sv

all: $(sources)
	vlog -mfcu $^

test: all
	vsim -c top -do "run -all" +TESTNAME=$(+TESTNAME)
