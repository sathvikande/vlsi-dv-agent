// ==============================================================================
// SystemVerilog Functional Coverage Class: fifo_coverage
// IEEE 1800-2017 Functional Coverage (Covergroups, Coverpoints, Bins, Cross)
// ==============================================================================

`ifndef FIFO_COVERAGE_SV
`define FIFO_COVERAGE_SV

class fifo_coverage;
    bit       cov_wr_en;
    bit       cov_rd_en;
    bit [7:0] cov_din;
    bit       cov_full;
    bit       cov_empty;

    covergroup cg_fifo;
        cp_wr: coverpoint cov_wr_en {
            bins write_idle   = {0};
            bins write_active = {1};
        }

        cp_rd: coverpoint cov_rd_en {
            bins read_idle   = {0};
            bins read_active = {1};
        }

        cp_rw_cross: cross cp_wr, cp_rd;

        cp_full: coverpoint cov_full {
            bins not_full = {0};
            bins is_full  = {1};
        }

        cp_empty: coverpoint cov_empty {
            bins not_empty = {0};
            bins is_empty  = {1};
        }

        cp_din: coverpoint cov_din {
            bins low_range  = {[0:63]};
            bins mid_range  = {[64:191]};
            bins high_range = {[192:255]};
        }
    endgroup

    function new();
        cg_fifo = new();
    endfunction

    function void sample(bit wr, bit rd, bit [7:0] data, bit full_flag, bit empty_flag);
        cov_wr_en = wr;
        cov_rd_en = rd;
        cov_din   = data;
        cov_full  = full_flag;
        cov_empty = empty_flag;
        cg_fifo.sample();
    endfunction

    function real get_coverage();
        return cg_fifo.get_inst_coverage();
    endfunction

endclass

`endif
