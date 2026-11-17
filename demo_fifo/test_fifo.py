"""
Cocotb Verification Testbench for Synchronous FIFO
Demonstrating autonomous bug detection, waveform inspection, functional coverage,
and vPlan traceability.
"""

import os
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
from cocotb_coverage.coverage import CoverPoint, CoverCross, coverage_db

# ==============================================================================
# Functional Coverage Model Definition
# ==============================================================================

@CoverPoint("top.fifo.count", bins=[0, 1, 14, 15, 16], vname="count")
@CoverPoint("top.fifo.full", bins=[0, 1], vname="full")
@CoverPoint("top.fifo.empty", bins=[0, 1], vname="empty")
@CoverPoint("top.fifo.wr_en", bins=[0, 1], vname="wr_en")
@CoverPoint("top.fifo.rd_en", bins=[0, 1], vname="rd_en")
@CoverCross("top.fifo.cross_count_full", items=["top.fifo.count", "top.fifo.full"])
@CoverCross("top.fifo.cross_rw", items=["top.fifo.wr_en", "top.fifo.rd_en"])
def sample_fifo_coverage(count: int, full: int, empty: int, wr_en: int, rd_en: int):
    """Samples functional coverage points for the synchronous FIFO."""
    pass


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
    Samples functional coverage bins on every write transaction.
    """
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())
    cocotb.start_soon(watchdog(dut, cycles=1000))

    try:
        await reset_dut(dut, cycles=5)
        assert dut.empty.value == 1, f"Expected empty=1 after reset, got {dut.empty.value}"
        assert dut.full.value == 0, f"Expected full=0 after reset, got {dut.full.value}"

        sample_fifo_coverage(
            int(dut.count.value),
            int(dut.full.value),
            int(dut.empty.value),
            0,
            0
        )

        for i in range(16):
            data_val = (0xA0 + i) & 0xFF
            await FallingEdge(dut.clk)
            dut.wr_en.value = 1
            dut.din.value = data_val

            await RisingEdge(dut.clk)
            await FallingEdge(dut.clk)
            dut.wr_en.value = 0

            num_written = i + 1
            cur_count = int(dut.count.value)
            cur_full = int(dut.full.value)
            cur_empty = int(dut.empty.value)

            sample_fifo_coverage(
                cur_count,
                cur_full,
                cur_empty,
                1,
                0
            )

            dut._log.info(f"Written item #{num_written}: data=0x{data_val:02x}, full={cur_full}, empty={cur_empty}")

            if num_written < 16:
                assert cur_full == 0, (
                    f"Specification Violation at item #{num_written}: "
                    f"FIFO declared FULL prematurely! Spec requires DEPTH=16, but full asserted with only {num_written} items stored."
                )

        assert dut.full.value == 1, "Expected full=1 after writing 16 items."
        dut._log.info("Successfully pushed 16 items into FIFO. Full asserted correctly.")

        # Drain all 16 items and verify strict FIFO ordering and empty flag assertion
        dut._log.info("Draining all 16 items to verify read pointer advancement and data order...")
        for i in range(16):
            expected_data = (0xA0 + i) & 0xFF
            await FallingEdge(dut.clk)
            dut.rd_en.value = 1
            await RisingEdge(dut.clk)
            await FallingEdge(dut.clk)
            dut.rd_en.value = 0

            actual_data = int(dut.dout.value)
            cur_count = int(dut.count.value)
            cur_full = int(dut.full.value)
            cur_empty = int(dut.empty.value)

            sample_fifo_coverage(
                cur_count,
                cur_full,
                cur_empty,
                0,
                1
            )

            assert actual_data == expected_data, (
                f"FIFO Data Corruption at item #{i}: expected 0x{expected_data:02x}, got 0x{actual_data:02x}"
            )
            dut._log.info(f"Read item #{i+1}: data=0x{actual_data:02x}, full={cur_full}, empty={cur_empty}, count={cur_count}")

        assert dut.empty.value == 1, "Expected empty=1 after draining all 16 items."
        assert dut.full.value == 0, "Expected full=0 after draining all 16 items."
        dut._log.info("Successfully drained 16 items. FIFO is empty and data order was strictly preserved.")

    finally:
        os.makedirs("sim_build", exist_ok=True)
        cov_file = "sim_build/functional_coverage.yml"
        coverage_db.export_to_yaml(cov_file)
        dut._log.info(f"Exported functional coverage database to '{cov_file}'.")


@cocotb.test()
async def test_fifo_simultaneous_rw(dut):
    """
    Verifies REQ-FIFO-04: Simultaneous read and write when FIFO is neither full nor empty.
    """
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())
    cocotb.start_soon(watchdog(dut, cycles=1000))

    try:
        await reset_dut(dut, cycles=5)

        # Write 4 initial items
        for i in range(4):
            await FallingEdge(dut.clk)
            dut.wr_en.value = 1
            dut.din.value = 0x10 + i
            await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        dut.wr_en.value = 0

        assert int(dut.count.value) == 4, f"Setup failed: count is {dut.count.value}"

        # Simultaneous write and read
        await FallingEdge(dut.clk)
        dut.wr_en.value = 1
        dut.rd_en.value = 1
        dut.din.value = 0x55
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        dut.wr_en.value = 0
        dut.rd_en.value = 0

        sample_fifo_coverage(
            int(dut.count.value),
            int(dut.full.value),
            int(dut.empty.value),
            1,
            1
        )

        assert int(dut.count.value) == 4, f"Count changed during simultaneous RW! Got {dut.count.value}"
        dut._log.info("Simultaneous read and write executed: count remained at 4.")

    finally:
        os.makedirs("sim_build", exist_ok=True)
        cov_file = "sim_build/functional_coverage.yml"
        coverage_db.export_to_yaml(cov_file)
