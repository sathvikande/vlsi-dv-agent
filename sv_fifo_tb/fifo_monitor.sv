// ==============================================================================
// SystemVerilog Monitor Class: fifo_monitor
// IEEE 1800-2017 Monitor Component
// Non-intrusively samples bus activity via clocking block and samples coverage
// ==============================================================================

`ifndef FIFO_MONITOR_SV
`define FIFO_MONITOR_SV

class fifo_monitor;
    virtual fifo_if.MONITOR      vif;
    mailbox #(fifo_transaction) mon2scb_mb;
    fifo_coverage               cov;

    function new(virtual fifo_if.MONITOR vif, mailbox #(fifo_transaction) mb, fifo_coverage cov);
        this.vif        = vif;
        this.mon2scb_mb = mb;
        this.cov        = cov;
    endfunction

    task run();
        fifo_transaction tr;
        $display("[MONITOR] Starting Passive Bus Monitoring...");
        forever begin
            @(vif.mon_cb);
            if (vif.rst_n) begin
                tr = new();
                tr.wr_en = vif.mon_cb.wr_en;
                tr.rd_en = vif.mon_cb.rd_en;
                tr.din   = vif.mon_cb.din;
                tr.dout  = vif.mon_cb.dout;
                tr.full  = vif.mon_cb.full;
                tr.empty = vif.mon_cb.empty;

                // Sample functional coverage
                cov.sample(tr.wr_en, tr.rd_en, tr.din, tr.full, tr.empty);

                // Forward transaction to Scoreboard for verification
                mon2scb_mb.put(tr);
            end
        end
    endtask

endclass

`endif
