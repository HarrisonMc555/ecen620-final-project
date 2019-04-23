# harrison = 1

sources = 
ifdef harrison
sources += ../harrison/lc3.sv
sources += ../harrison/controller.sv
sources += ../harrison/datapath.sv
sources += ../harrison/dut.sv
else
sources += $(wildcard ../dallin/*.sv)
endif
sources += dut_if.sv
sources += assert_macros.sv
sources += bindfiles.sv
sources += dut_asserts.sv
sources += opcodes.sv
sources += verification_pkg.sv
sources += scoreboard_pkg.sv
sources += GoldenLC3.sv
sources += Generator.sv
sources += Driver.sv
sources += Checker.sv
sources += Monitor.sv
sources += Environment.sv
sources += macros.sv
sources += TestBase.sv
sources += TestRegistry.sv
sources += test.sv
sources += top.sv

all: $(sources)
	vlog -mfcu $^

test: all
	vsim top +TESTNAME=$(+TESTNAME)
