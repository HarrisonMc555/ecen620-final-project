.PHONY: all test print_tests clean

MAKEFLAGS=--warn-undefined-variables

define uniq =
  $(eval seen :=)
  $(foreach _,$1,$(if $(filter $_,${seen}),,$(eval seen += $_)))
  ${seen}
endef

WORK_NAME := work
WORK_DIR := $(WORK_NAME)
SRC_FILES := $(wildcard *.sv)
PACKAGE_FILES := lc3.sv
TESTBENCH_SRC_FILES := $(wildcard *_tb.sv)
SRC_FILES := $(strip $(call uniq, \
							$(PACKAGE_FILES) \
							$(patsubst %_tb.sv,%.sv,$(TESTBENCH_SRC_FILES)) \
							$(TESTBENCH_SRC_FILES) \
							$(wildcard *.sv)) \
							)
COMPILED_DIRS := $(patsubst %.sv,$(WORK_DIR)/%,$(SRC_FILES))
COMPILED_DAT_FILES := $(patsubst %,%/_primary.dat,$(COMPILED_DIRS))
ALL_DEPENDENCIES := $(WORK_DIR) $(COMPILED_DAT_FILES)
TESTBENCH_FILES := $(wildcard *_tb.sv)
TRANSCRIPT_FILES := $(patsubst %.sv, %.transcript,$(TESTBENCH_FILES))
TMP_FILES := transcript

all: $(ALL_DEPENDENCIES)

test: all print_tests

print_tests: $(TRANSCRIPT_FILES)
	for f in $?; do printf "\n\n"; echo "$$f"; cat "$$f"; printf "\n\n"; done

datapath_tb.transcript: datapath_tb.sv $(COMPILED_DAT_FILES)

controller_tb.transcript: controller_tb.sv $(COMPILED_DAT_FILES)

%.transcript:
	vsim -c -novopt -voptargs=+acc=lpm $(patsubst %.sv,%,$<) -do 'run -all'
	mv transcript $@
	sed	-i '\_# //_d' $@

$(WORK_DIR):
	vlib $(WORK_NAME)

$(COMPILED_DAT_FILES): $(SRC_FILES)
	vlog -O0 -novopt $^

clean:
	rm -f *~ */*~
	rm -f $(TMP_FILES)
	rm -rf $(WORK_DIR)
