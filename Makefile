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
	vlog +cover -f dut.f
	vlog +cover -dpiheader opgen/dpi_gen.h -f tb.f
	vlog -sv opgen/opgen.cpp
else
	velanalyze -f dut_tbx.f
	velcomp
endif

run:
ifeq ($(MODE),puresim)
	vsim -c toptb -do "coverage save -onexit report.ucdb; run -all;exit"
	vsim -c -cvgperinstance -viewcov report.ucdb -do "coverage report -output report.txt -srcfile=* -detail -option -cvg;exit"
else
	velrun -64bit -emul Greg  | tee transcript.veloce
endif

waves:
	vsim -classdebug +DBG-INSTR toptb

debug:
	@echo "Running debug"
	vsim -c +DBG-INSTR toptb -do "run -all"

clean:
	rm -rf edsenv transcript tmon.log vsim.wlf report.* modelsim.ini transcript.veloce transcript.puresim veloce.map veloce.wave velrunopts.ini work.puresim work.veloce veloce.out veloce.med veloce.log tbxbindings.h

