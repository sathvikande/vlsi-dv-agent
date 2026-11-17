// ==============================================================================
// SystemVerilog Transaction Class: fifo_transaction
// IEEE 1800-2017 SystemVerilog Layered OOP Architecture
// ==============================================================================

`ifndef FIFO_TRANSACTION_SV
`define FIFO_TRANSACTION_SV

class fifo_transaction;
    // Stimulus fields (randomized)
    rand bit                  wr_en;
    rand bit                  rd_en;
    rand bit [7:0]            din;

    // Response / State fields (sampled from DUT)
    bit [7:0]                 dout;
    bit                       full;
    bit                       empty;

    // Directed-random valid operations constraint
    // Ensures write, read, or simultaneous write & read occurs
    constraint c_valid_op {
        {wr_en, rd_en} inside {2'b10, 2'b01, 2'b11};
    }

    // Constructor
    function new();
    endfunction

    // Deep copy method
    function fifo_transaction copy();
        fifo_transaction c = new();
        c.wr_en = this.wr_en;
        c.rd_en = this.rd_en;
        c.din   = this.din;
        c.dout  = this.dout;
        c.full  = this.full;
        c.empty = this.empty;
        return c;
    endfunction

    // Display method
    function void display(string prefix = "");
        $display("[TIME: %0t] %s Transaction: wr=%0b, rd=%0b, din=0x%02h, dout=0x%02h, full=%0b, empty=%0b",
                 $time, prefix, wr_en, rd_en, din, dout, full, empty);
    endfunction

endclass

`endif
