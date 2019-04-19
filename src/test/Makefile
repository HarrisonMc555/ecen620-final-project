# sources = clock_unit.sv Transaction.sv Generator.sv Driver.sv Environment.sv \
# 					macros.sv TestBase.sv TestRegistry.sv test.sv top.sv
sources = 
sources += ../dut/dut_if.sv
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
