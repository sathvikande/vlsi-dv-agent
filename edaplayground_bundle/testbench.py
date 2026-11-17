"""
Cocotb Verification Testbench for Synchronous FIFO
Demonstrating autonomous bug detection, waveform inspection, and root-cause analysis.
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles


async def watchdog(dut, cycles: int = 2000):
    """Failsafe simulation watchdog coroutine."""
    await ClockCycles(dut.clk, cycles)
    assert False, f"FATAL: Simulation Watchdog timed out after {cycles} cycles! DUT deadlock detected."


async def reset_dut(dut, cycles: int = 5):
    """Applies active-low reset for at least 5 clock cycles according to DV guardrails."""
    dut._log.info(f"Asserting active-low reset for {cycles} clock cycles...")
    dut.rst_n.value = 0
    dut.wr_en.value = 0
    dut.rd_en.value = 0
    dut.din.value = 0
    await ClockCycles(dut.clk, cycles)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    dut._log.info("Reset deasserted. DUT in operational state.")


@cocotb.test()
async def test_fifo_fill_to_depth(dut):
    """
    Verifies that the FIFO can accept up to DEPTH (16) items before asserting 'full'.
    According to spec.md:
      - 15 items written -> full MUST be 0.
      - 16 items written -> full MUST be 1.
    """
    # 1. Start 100MHz clock (10ns period)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # 2. Start Watchdog
    cocotb.start_soon(watchdog(dut, cycles=1000))

    # 3. Apply Mandatory 5-cycle Reset
    await reset_dut(dut, cycles=5)

    # Initial state checks
    assert dut.empty.value == 1, f"Expected empty=1 after reset, got {dut.empty.value}"
    assert dut.full.value == 0, f"Expected full=0 after reset, got {dut.full.value}"

    # 4. Sequentially write items 1 through 16
    for i in range(16):
        data_val = (0xA0 + i) & 0xFF
        await FallingEdge(dut.clk)
        dut.wr_en.value = 1
        dut.din.value = data_val

        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        dut.wr_en.value = 0

        num_written = i + 1
        dut._log.info(f"Written item #{num_written}: data=0x{data_val:02x}, full={dut.full.value}, empty={dut.empty.value}")

        # Check: Before writing 16 items, FIFO must NOT be full
        if num_written < 16:
            assert dut.full.value == 0, (
                f"Specification Violation at item #{num_written}: "
                f"FIFO declared FULL prematurely! Spec requires DEPTH=16, but full asserted with only {num_written} items stored."
            )

    # After 16 items, FIFO must be full
    assert dut.full.value == 1, "Expected full=1 after writing 16 items."
    dut._log.info("Successfully pushed 16 items into FIFO. Full asserted correctly.")
