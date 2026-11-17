// ==============================================================================
// SystemVerilog Driver Class: fifo_driver
// IEEE 1800-2017 Driver Component
// Drives interface clocking block signals synchronously
// ==============================================================================

`ifndef FIFO_DRIVER_SV
`define FIFO_DRIVER_SV

class fifo_driver;
    virtual fifo_if.DRIVER       vif;
    mailbox #(fifo_transaction) gen2drv_mb;
    event                       drv_done;

    function new(virtual fifo_if.DRIVER vif, mailbox #(fifo_transaction) mb, event done_ev);
        this.vif        = vif;
        this.gen2drv_mb = mb;
        this.drv_done   = done_ev;
    endfunction

    // Reset sequence: Assert reset active-low for 5 clock cycles
    task reset_dut();
        $display("[DRIVER] Initiating Synchronous Hardware Reset...");
        vif.rst_n         <= 1'b0;
        vif.drv_cb.wr_en  <= 1'b0;
        vif.drv_cb.rd_en  <= 1'b0;
        vif.drv_cb.din    <= '0;
        repeat (5) @(vif.drv_cb);
        vif.rst_n         <= 1'b1;
        repeat (2) @(vif.drv_cb);
        $display("[DRIVER] Reset Released. DUT is Ready.");
    endtask

    // Main driving task
    task run();
        fifo_transaction tr;
        forever begin
            gen2drv_mb.get(tr);
            @(vif.drv_cb);
            vif.drv_cb.wr_en <= tr.wr_en;
            vif.drv_cb.rd_en <= tr.rd_en;
            vif.drv_cb.din   <= tr.din;
            -> drv_done;
        end
    endtask

endclass

`endif
