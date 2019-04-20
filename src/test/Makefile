harrison = 1

sources = 
sources += ../dut/dut_if.sv
ifdef harrison
sources += ../harrison/lc3.sv
sources += ../harrison/controller.sv
sources += ../harrison/datapath.sv
sources += ../harrison/dut.sv
else
sources += $(wildcard ../dallin/*.sv)
endif
sources += assert_macros.sv
sources += dut_asserts.sv
sources += bindfiles.sv
sources += clock_unit.sv
sources += opcodes.sv
sources += Transaction.sv
sources += Generator.sv
sources += Driver.sv
sources += Environment.sv
sources += macros.sv
sources += TestBase.sv
sources += TestRegistry.sv
sources += test.sv
sources += top.sv

all: $(sources)
	vlog -mfcu $^

test: all
	vsim -c top -do "run -all" +TESTNAME=$(+TESTNAME)
