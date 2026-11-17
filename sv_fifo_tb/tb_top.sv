// ==============================================================================
// Top-Level SystemVerilog Testbench: tb_top
// IEEE 1800-2017 Top-Level Module
// Instantiates Clock, Interface, DUT, SVA Bindings, VCD Dump, and Test Program
// ==============================================================================

`timescale 1ns/1ps

import fifo_pkg::*;

module tb_top;
    localparam int DATA_WIDTH = 8;
    localparam int DEPTH      = 16;
    localparam int CLK_PERIOD = 10; // 100 MHz clock

    // Clock generation
    logic clk;
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Interface Instantiation
    fifo_if #(.DATA_WIDTH(DATA_WIDTH)) inf(clk);

    // Design Under Test (DUT) Instantiation
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) u_fifo (
        .clk   (inf.clk),
        .rst_n (inf.rst_n),
        .wr_en (inf.wr_en),
        .rd_en (inf.rd_en),
        .din   (inf.din),
        .dout  (inf.dout),
        .full  (inf.full),
        .empty (inf.empty)
    );

    // SystemVerilog Assertions (SVA) Module Instantiation
    fifo_sva #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) u_fifo_sva (
        .clk   (inf.clk),
        .rst_n (inf.rst_n),
        .wr_en (inf.wr_en),
        .rd_en (inf.rd_en),
        .din   (inf.din),
        .dout  (inf.dout),
        .full  (inf.full),
        .empty (inf.empty),
        .count (u_fifo.count)
    );

    // Testbench Control Block
    initial begin
        fifo_test test;

        // Waveform dumping for GTKWave / Surfer analysis
        $dumpfile("dump_sv.vcd");
        $dumpvars(0, tb_top);

        $display("\n================================================================================");
        $display("          IEEE 1800 SYSTEMVERILOG LAYERED OOP TESTBENCH INITIALIZED             ");
        $display("================================================================================\n");

        test = new(inf.DRIVER, inf.MONITOR, 60);
        test.run();

        $display("[TB_TOP] Simulation successfully finished at time %0t ns.", $time);
        $finish;
    end

endmodule
