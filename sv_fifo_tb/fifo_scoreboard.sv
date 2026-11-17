// ==============================================================================
// SystemVerilog Scoreboard Class: fifo_scoreboard
// IEEE 1800-2017 Scoreboard & Reference Model
// Dynamic golden queue comparison, order verification, data integrity checking
// ==============================================================================

`ifndef FIFO_SCOREBOARD_SV
`define FIFO_SCOREBOARD_SV

class fifo_scoreboard;
    mailbox #(fifo_transaction) mon2scb_mb;

    // Golden Reference Model
    bit [7:0] golden_queue[$];
    bit [7:0] exp_read_queue[$];

    // Verification Metrics
    int total_transactions = 0;
    int num_writes         = 0;
    int num_reads          = 0;
    int num_matches        = 0;
    int num_mismatches     = 0;
    int num_overflow_seen  = 0;
    int num_underflow_seen = 0;
    int flag_errors        = 0;

    function new(mailbox #(fifo_transaction) mb);
        this.mon2scb_mb = mb;
    endfunction

    task run();
        fifo_transaction tr;
        $display("[SCOREBOARD] Reference Model and Checker Active.");

        forever begin
            mon2scb_mb.get(tr);
            total_transactions++;

            // 1. Verify read data from previous read cycle (1-cycle registered latency)
            if (exp_read_queue.size() > 0) begin
                bit [7:0] expected_dout = exp_read_queue.pop_front();
                if (tr.dout === expected_dout) begin
                    num_matches++;
                    $display("[SCOREBOARD] [PASS] Read Data Match: Expected=0x%02h, Actual=0x%02h (Matches: %0d)",
                             expected_dout, tr.dout, num_matches);
                end else begin
                    num_mismatches++;
                    $error("[SCOREBOARD] [FAIL] Read Data Mismatch! Expected=0x%02h, Actual=0x%02h",
                           expected_dout, tr.dout);
                end
            end

            // 2. Verify Full / Empty Flag Consistency BEFORE clock edge state updates
            if (tr.full !== (golden_queue.size() == 16)) begin
                flag_errors++;
                $error("[SCOREBOARD] Full flag mismatch! DUT full=%0b, Expected=%0b (Queue size=%0d)",
                       tr.full, (golden_queue.size() == 16), golden_queue.size());
            end

            if (tr.empty !== (golden_queue.size() == 0)) begin
                flag_errors++;
                $error("[SCOREBOARD] Empty flag mismatch! DUT empty=%0b, Expected=%0b (Queue size=%0d)",
                       tr.empty, (golden_queue.size() == 0), golden_queue.size());
            end

            // 3. Process Write Stimulus
            if (tr.wr_en) begin
                if (!tr.full) begin
                    golden_queue.push_back(tr.din);
                    num_writes++;
                    $display("[SCOREBOARD] Written: 0x%02h | Golden Queue Depth: %0d", tr.din, golden_queue.size());
                end else begin
                    num_overflow_seen++;
                    $display("[SCOREBOARD] Attempted Write while FULL (Overflow safely prevented by DUT).");
                end
            end

            // 4. Process Read Stimulus
            if (tr.rd_en) begin
                if (!tr.empty) begin
                    if (golden_queue.size() > 0) begin
                        bit [7:0] exp_val = golden_queue.pop_front();
                        exp_read_queue.push_back(exp_val);
                        num_reads++;
                        $display("[SCOREBOARD] Read Requested | Golden Queue Depth remaining: %0d", golden_queue.size());
                    end
                end else begin
                    num_underflow_seen++;
                    $display("[SCOREBOARD] Attempted Read while EMPTY (Underflow safely prevented by DUT).");
                end
            end
        end
    endtask

    // Final Report and Verification Signoff
    function void report();
        $display("\n================================================================================");
        $display("                   SYSTEMVERILOG SCOREBOARD VERIFICATION REPORT                 ");
        $display("================================================================================");
        $display("  Total Transactions Monitored : %0d", total_transactions);
        $display("  Total Writes Accepted        : %0d", num_writes);
        $display("  Total Reads Completed        : %0d", num_reads);
        $display("  Read Data Matches (PASSED)   : %0d", num_matches);
        $display("  Read Data Mismatches (FAILED): %0d", num_mismatches);
        $display("  Overflow Attempts Prevented  : %0d", num_overflow_seen);
        $display("  Underflow Attempts Prevented : %0d", num_underflow_seen);
        $display("  Flag Divergences / Errors    : %0d", flag_errors);
        $display("  Golden Queue Residual Items  : %0d", golden_queue.size());
        $display("--------------------------------------------------------------------------------");
        if (num_mismatches == 0 && flag_errors == 0 && num_matches > 0) begin
            $display("  VERDICT: *** TEST PASSED (100%% DATA INTEGRITY & SVA SIGN-OFF) ***");
        end else begin
            $display("  VERDICT: *** TEST FAILED (%0d MISMATCHES, %0d FLAG ERRORS) ***",
                     num_mismatches, flag_errors);
        end
        $display("================================================================================\n");
    endfunction

endclass

`endif
