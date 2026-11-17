// ==============================================================================
// SystemVerilog Test Class: fifo_test
// IEEE 1800-2017 Base Test Component
// Configures and launches the verification environment
// ==============================================================================

`ifndef FIFO_TEST_SV
`define FIFO_TEST_SV

class fifo_test;
    fifo_env env;

    function new(virtual fifo_if.DRIVER vif_d, virtual fifo_if.MONITOR vif_m, int num_tx = 50);
        env = new(vif_d, vif_m, num_tx);
    endfunction

    task run();
        $display("\n================================================================================");
        $display("                   STARTING SYSTEMVERILOG FIFO REGRESSION TEST                  ");
        $display("================================================================================");
        env.run();
        $display("================================================================================");
        $display("                   SYSTEMVERILOG FIFO TEST EXECUTION COMPLETE                   ");
        $display("================================================================================\n");
    endtask

endclass

`endif
