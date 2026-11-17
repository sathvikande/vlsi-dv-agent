// AMBA AXI4-Stream Synchronous FIFO with First-Word Fall-Through (FWFT)
// Fully compliant with ARM AMBA 4 AXI4-Stream Protocol Specification

`timescale 1ns/1ps

module axis_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 16
)(
    input  logic                  aclk,
    input  logic                  aresetn,

    // AXI4-Stream Slave Interface (Sink)
    input  logic [DATA_WIDTH-1:0] s_axis_tdata,
    input  logic                  s_axis_tvalid,
    output logic                  s_axis_tready,
    input  logic                  s_axis_tlast,

    // AXI4-Stream Master Interface (Source)
    output logic [DATA_WIDTH-1:0] m_axis_tdata,
    output logic                  m_axis_tvalid,
    input  logic                  m_axis_tready,
    output logic                  m_axis_tlast
);

    localparam int ADDR_WIDTH = $clog2(DEPTH);

    logic [DATA_WIDTH:0]   mem [0:DEPTH-1];
    logic [ADDR_WIDTH-1:0] wr_ptr;
    logic [ADDR_WIDTH-1:0] rd_ptr;
    logic [ADDR_WIDTH:0]   count;

    wire full  = (count == (ADDR_WIDTH+1)'(DEPTH));
    wire empty = (count == '0);

    assign s_axis_tready = !full;
    assign m_axis_tvalid = !empty;

    // First-Word Fall-Through: Current head of queue directly driven to master
    assign {m_axis_tlast, m_axis_tdata} = mem[rd_ptr];

    wire write_fire = s_axis_tvalid && s_axis_tready;
    wire read_fire  = m_axis_tvalid && m_axis_tready;

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
        end else begin
            if (write_fire) begin
                mem[wr_ptr] <= {s_axis_tlast, s_axis_tdata};
                wr_ptr      <= wr_ptr + 1'b1;
            end
            if (read_fire) begin
                rd_ptr      <= rd_ptr + 1'b1;
            end
            case ({write_fire, read_fire})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

endmodule
