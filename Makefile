# File: Makefile
# Authors:
# Stephano Cetola

MODE ?= veloce
#MODE ?= puresim

all: clean lib compile run

lib:
ifeq ($(MODE),puresim)
	vlib work.$(MODE)
	vmap work work.$(MODE) 
else	
	vellib work.$(MODE)
	velmap work work.$(MODE)
endif

compile:
ifeq ($(MODE),puresim)
	vlog -f dut.f -dpiheader tbxbindings.h
	vlog hvl/opgen.cpp
else
	velanalyze -f dut.f
	velcomp
endif

run:
ifeq ($(MODE),puresim)
	vsim -c ibex_core_tb -do "run -all" | tee transcript.puresim
else
	velrun -64bit -emul Greg  | tee transcript.veloce
endif

waves:
	vsim -classdebug +DBG-INSTR ibex_core_tb 

debug:
	@echo "Running debug"
	vsim -c +DBG-INSTR toptb -do "run -all"

clean:
	rm -rf edsenv transcript tmon.log vsim.wlf report.* modelsim.ini transcript.veloce transcript.puresim veloce.map veloce.wave velrunopts.ini work.puresim work.veloce veloce.out veloce.med veloce.log

