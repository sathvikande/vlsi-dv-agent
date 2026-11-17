// ==============================================================================
// SystemVerilog Interface: fifo_if
// Standard: IEEE 1800-2017 SystemVerilog
// Features: Clocking blocks for race-free driving & sampling, modports
// ==============================================================================

`timescale 1ns/1ps

interface fifo_if #(
    parameter int DATA_WIDTH = 8
)(
    input logic clk
);

    // Interface signals
    logic                  rst_n;
    logic                  wr_en;
    logic                  rd_en;
    logic [DATA_WIDTH-1:0] din;
    logic [DATA_WIDTH-1:0] dout;
    logic                  full;
    logic                  empty;

    // Driver Clocking Block (Skewed outputs to prevent setup/hold race conditions)
    clocking drv_cb @(posedge clk);
        default input #1ns output #1ns;
        output wr_en;
        output rd_en;
        output din;
        input  full;
        input  empty;
        input  dout;
    endclocking

    // Monitor Clocking Block (Samples synchronous signals post-setup)
    clocking mon_cb @(posedge clk);
        default input #1ns output #0;
        input wr_en;
        input rd_en;
        input din;
        input dout;
        input full;
        input empty;
    endclocking

    // Modports defining directional access
    modport DRIVER  (clocking drv_cb, output rst_n);
    modport MONITOR (clocking mon_cb, input rst_n);
    modport DUT     (input clk, rst_n, wr_en, rd_en, din, output dout, full, empty);

endinterface
