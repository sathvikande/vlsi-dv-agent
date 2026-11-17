// ==============================================================================
// SystemVerilog Package: fifo_pkg
// Standard: IEEE 1800-2017 SystemVerilog
// Encapsulates all OOP Testbench Verification Components
// ==============================================================================

`ifndef FIFO_PKG_SV
`define FIFO_PKG_SV

package fifo_pkg;
    import std::*;

    `include "fifo_transaction.sv"
    `include "fifo_coverage.sv"
    `include "fifo_generator.sv"
    `include "fifo_driver.sv"
    `include "fifo_monitor.sv"
    `include "fifo_scoreboard.sv"
    `include "fifo_env.sv"
    `include "fifo_test.sv"
endpackage

`endif
