# ==============================================================================
# Pure SystemVerilog IEEE 1800 OOP Testbench Makefile
# Simulator: Verilator 5.0+ (Native SV Classes, Timing, Mailboxes, Covergroups)
# ==============================================================================

SIM = verilator
VERILATOR_FLAGS = --binary --timing --trace \
                  -Wno-IMPLICITSTATIC -Wno-SYNCASYNCNET -Wno-UNUSEDSIGNAL \
                  -I. -I../demo_fifo

SRCS = fifo_if.sv \
       ../demo_fifo/fifo.sv \
       ../demo_fifo/fifo_sva.sv \
       fifo_pkg.sv \
       tb_top.sv

TOP = tb_top
TARGET = obj_dir/V$(TOP)
VCD = dump_sv.vcd

.PHONY: all compile run waves clean help

all: run

compile: $(TARGET)

$(TARGET): $(SRCS)
	@echo "=== [1/2] Compiling Pure SystemVerilog Testbench with Verilator 5 ==="
	$(SIM) $(VERILATOR_FLAGS) $(SRCS) --top-module $(TOP)

run: compile
	@echo "=== [2/2] Running Pure SystemVerilog Simulation ==="
	./$(TARGET)

waves:
	@which surfer >/dev/null 2>&1 && surfer $(VCD) || \
	(which gtkwave >/dev/null 2>&1 && gtkwave $(VCD) || \
	echo "Install surfer or gtkwave to inspect $(VCD)")

clean:
	rm -rf obj_dir $(VCD)
	@echo "Cleaned build artifacts."

help:
	@echo "Pure SystemVerilog DV Targets:"
	@echo "  make compile  : Compiles SV testbench and SVA into native binary"
	@echo "  make run      : Compiles and executes testbench with coverage report"
	@echo "  make waves    : Opens waveform in Surfer / GTKWave"
	@echo "  make clean    : Removes binary and waveform artifacts"
