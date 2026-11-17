// Concurrent SystemVerilog Assertions (SVA) & Whitebox Binding
// Standard: IEEE 1800-2017 SVA

`timescale 1ns/1ps

module fifo_sva #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 16
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  wr_en,
    input  logic                  rd_en,
    /* verilator lint_off UNUSEDSIGNAL */
    input  logic [DATA_WIDTH-1:0] din,
    input  logic [DATA_WIDTH-1:0] dout,
    /* verilator lint_on UNUSEDSIGNAL */
    input  logic                  full,
    input  logic                  empty,
    input  logic [4:0]            count
);

    localparam logic [4:0] DEPTH_5B = 5'(DEPTH);

    // 1. Reset Property: When reset is low on a clock edge, empty is 1, full is 0, count is 0
    property p_reset_state;
        @(posedge clk) (!rst_n) |-> (empty && !full && (count == 5'd0));
    endproperty
    assert property (p_reset_state) else $error("SVA_FATAL: Reset state violation! Empty must be 1, full 0, count 0.");

    // 2. Count Upper Bound: Count must never exceed DEPTH (16)
    property p_count_bounded;
        @(posedge clk) disable iff (!rst_n)
        count <= DEPTH_5B;
    endproperty
    assert property (p_count_bounded) else $error("SVA_FATAL: FIFO buffer overflow! Count exceeded DEPTH.");

    // 3. Full Flag Equivalence (CRITICAL SVA):
    // Full MUST be asserted IF AND ONLY IF count == DEPTH
    property p_full_equiv;
        @(posedge clk) disable iff (!rst_n)
        full == (count == DEPTH_5B);
    endproperty
    assert property (p_full_equiv) else $error("SVA_FATAL: Full flag mismatch! Full asserted with count != DEPTH.");

    // 4. Empty Flag Equivalence:
    // Empty MUST be asserted IF AND ONLY IF count == 0
    property p_empty_equiv;
        @(posedge clk) disable iff (!rst_n)
        empty == (count == 5'd0);
    endproperty
    assert property (p_empty_equiv) else $error("SVA_FATAL: Empty flag mismatch! Empty asserted with count != 0.");

    // 5. Mutual Exclusion: Never full and empty simultaneously
    property p_never_full_and_empty;
        @(posedge clk) disable iff (!rst_n)
        !(full && empty);
    endproperty
    assert property (p_never_full_and_empty) else $error("SVA_FATAL: Illegal state! FIFO cannot be both full and empty.");

    // Functional Coverage Properties
    c_full: cover property (@(posedge clk) disable iff (!rst_n) full);
    c_empty: cover property (@(posedge clk) disable iff (!rst_n) empty);
    c_simul_rw: cover property (@(posedge clk) disable iff (!rst_n) (wr_en && rd_en));

endmodule

// Whitebox Bind Directive: Injects SVA into DUT without modifying original RTL
bind fifo fifo_sva #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
) u_fifo_sva (
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .din(din),
    .dout(dout),
    .full(full),
    .empty(empty),
    .count(count)
);
