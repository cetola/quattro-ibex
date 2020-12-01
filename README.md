# quattro-ibex
Emulating the Ibex core on a Veloce Quattro 

This project is for educational purposes only.

Project Overview
----------------
dut.f: DUT and testbench include file.

tbx_bfm.sv: Currently this is HDL. Connects RAM with the Ibex core.

hvl/opgen.cxx: Contains import functions for populating RAM and eventually a
connection to the checker.

hvl/tbx_main.czz: Hack for now. Fixes issue with exports not HVL compiling.

hdl/ibex_core_tb.sv: HDL testbench code.


