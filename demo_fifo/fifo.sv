// Synchronous FIFO Implementation with Intentionally Injected Bug
// Top-level module: fifo

`timescale 1ns/1ps

module fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 16
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  wr_en,
    input  logic                  rd_en,
    input  logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout,
    output logic                  full,
    output logic                  empty
);

    localparam int ADDR_WIDTH = $clog2(DEPTH); // 4 for DEPTH=16

    // Memory array
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Read and Write pointers
    logic [ADDR_WIDTH-1:0] wr_ptr;
    logic [ADDR_WIDTH-1:0] rd_ptr;

    // Item counter (needs ADDR_WIDTH + 1 bits to represent DEPTH 16)
    logic [ADDR_WIDTH:0] count;

    // Status Flags
    assign empty = (count == 0);

    // =========================================================================
    // INTENTIONALLY INJECTED BUG:
    // Realistic off-by-one error in full flag condition.
    // Specification requires full = (count == DEPTH), i.e., 16 items.
    // The buggy logic asserts full when count == (DEPTH - 1), i.e., 15 items!
    // =========================================================================
    assign full = (count == 5'(DEPTH)); // BUG: Should be (count == DEPTH)

    // Synchronous Read & Write Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
            dout   <= '0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: begin // Write only
                    mem[wr_ptr] <= din;
                    wr_ptr      <= wr_ptr + 1'b1;
                    count       <= count + 1'b1;
                end

                2'b01: begin // Read only
                    dout   <= mem[rd_ptr];
                    rd_ptr <= rd_ptr + 1'b1;
                    count  <= count - 1'b1;
                end

                2'b11: begin // Simultaneous Write and Read
                    mem[wr_ptr] <= din;
                    wr_ptr      <= wr_ptr + 1'b1;
                    dout        <= mem[rd_ptr];
                    rd_ptr      <= rd_ptr + 1'b1;
                    // count remains unchanged
                end

                default: begin
                    // No-op
                end
            endcase
        end
    end

endmodule
