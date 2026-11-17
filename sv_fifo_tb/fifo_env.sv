// ==============================================================================
// SystemVerilog Environment Class: fifo_env
// IEEE 1800-2017 Layered Testbench Environment
// Connects components, manages mailboxes, and coordinates phase execution
// ==============================================================================

`ifndef FIFO_ENV_SV
`define FIFO_ENV_SV

class fifo_env;
    // Virtual interfaces
    virtual fifo_if.DRIVER  vif_drv;
    virtual fifo_if.MONITOR vif_mon;

    // Mailboxes & Events
    mailbox #(fifo_transaction) gen2drv_mb;
    mailbox #(fifo_transaction) mon2scb_mb;
    event                       drv_done;

    // Components
    fifo_generator  gen;
    fifo_driver     drv;
    fifo_monitor    mon;
    fifo_scoreboard scb;
    fifo_coverage   cov;

    function new(virtual fifo_if.DRIVER vif_d, virtual fifo_if.MONITOR vif_m, int num_tx = 50);
        this.vif_drv = vif_d;
        this.vif_mon = vif_m;

        // Construct communications
        gen2drv_mb = new();
        mon2scb_mb = new();

        // Construct verification components
        cov = new();
        gen = new(gen2drv_mb, drv_done, num_tx);
        drv = new(vif_drv, gen2drv_mb, drv_done);
        mon = new(vif_mon, mon2scb_mb, cov);
        scb = new(mon2scb_mb);
    endfunction

    task run();
        $display("[ENVIRONMENT] Resetting DUT and initializing simulation...");
        drv.reset_dut();

        $display("[ENVIRONMENT] Launching concurrent verification components...");
        fork
            drv.run();
            mon.run();
            scb.run();
        join_none

        // Run stimulus generation to completion
        gen.run();

        // Allow DUT pipeline to settle and drain residual reads
        $display("[ENVIRONMENT] Stimulus complete. Draining simulation pipeline...");
        repeat (10) @(vif_drv.drv_cb);

        // Print Verification and Functional Coverage Reports
        scb.report();
        $display("================================================================================");
        $display("                   SYSTEMVERILOG FUNCTIONAL COVERAGE REPORT                     ");
        $display("================================================================================");
        $display("  Overall Functional Coverage Score: %0.2f%%", cov.get_coverage());
        $display("================================================================================\n");
    endtask

endclass

`endif
