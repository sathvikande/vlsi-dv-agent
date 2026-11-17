# Cocotb Multi-Simulator Makefile (Verilator & Icarus Verilog)
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(CURDIR)/fifo.sv
ifeq ($(SIM),verilator)
  VERILOG_SOURCES += $(CURDIR)/fifo_sva.sv
endif
TOPLEVEL = fifo
MODULE = test_fifo

# Verilator specific flags
ifeq ($(SIM),verilator)
  EXTRA_ARGS += --assert --trace --trace-structs --coverage -Wno-fatal -Wno-SYNCASYNCNET
  PLUSARGS += --trace
endif

# Icarus Verilog specific flags (SystemVerilog 2012 support and waveform dumping)
ifeq ($(SIM),icarus)
  COMPILE_ARGS += -g2012
  WAVES = 1
endif

# Include Cocotb standard simulator build rules
include $(shell cocotb-config --makefiles)/Makefile.sim
