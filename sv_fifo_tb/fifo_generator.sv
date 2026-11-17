// ==============================================================================
// SystemVerilog Generator Class: fifo_generator
// IEEE 1800-2017 Constrained-Random Stimulus Generator
// ==============================================================================

`ifndef FIFO_GENERATOR_SV
`define FIFO_GENERATOR_SV

class fifo_generator;
    mailbox #(fifo_transaction) gen2drv_mb;
    event                       drv_done;
    int                         num_transactions;

    function new(mailbox #(fifo_transaction) mb, event done_ev, int count = 50);
        this.gen2drv_mb        = mb;
        this.drv_done          = done_ev;
        this.num_transactions = count;
    endfunction

    // Phase 1: Directed write fill to depth
    task generate_fill(int count = 16);
        fifo_transaction tr;
        $display("[GENERATOR] Starting DIRECTED FILL Phase (%0d transactions)...", count);
        for (int i = 0; i < count; i++) begin
            tr = new();
            void'(tr.randomize() with { wr_en == 1; rd_en == 0; });
            gen2drv_mb.put(tr);
            @drv_done;
        end
        $display("[GENERATOR] DIRECTED FILL Phase Completed.");
    endtask

    // Phase 2: Directed read drain
    task generate_drain(int count = 16);
        fifo_transaction tr;
        $display("[GENERATOR] Starting DIRECTED DRAIN Phase (%0d transactions)...", count);
        for (int i = 0; i < count; i++) begin
            tr = new();
            void'(tr.randomize() with { wr_en == 0; rd_en == 1; });
            gen2drv_mb.put(tr);
            @drv_done;
        end
        $display("[GENERATOR] DIRECTED DRAIN Phase Completed.");
    endtask

    // Phase 3: Simultaneous Read & Write
    task generate_simultaneous(int count = 20);
        fifo_transaction tr;
        $display("[GENERATOR] Starting SIMULTANEOUS R/W Phase (%0d transactions)...", count);
        for (int i = 0; i < count; i++) begin
            tr = new();
            void'(tr.randomize() with { wr_en == 1; rd_en == 1; });
            gen2drv_mb.put(tr);
            @drv_done;
        end
        $display("[GENERATOR] SIMULTANEOUS R/W Phase Completed.");
    endtask

    // Phase 4: Constrained Random
    task generate_random(int count = 50);
        fifo_transaction tr;
        $display("[GENERATOR] Starting CONSTRAINED RANDOM Phase (%0d transactions)...", count);
        for (int i = 0; i < count; i++) begin
            tr = new();
            if (tr.randomize() == 0) begin
                $fatal(1, "[GENERATOR] Randomization failed!");
            end
            gen2drv_mb.put(tr);
            @drv_done;
        end
        $display("[GENERATOR] CONSTRAINED RANDOM Phase Completed.");
    endtask

    task run();
        generate_fill(16);
        generate_drain(16);
        generate_simultaneous(20);
        generate_random(num_transactions);
        $display("[GENERATOR] All stimulus generation phases finished!");
    endtask

endclass

`endif
