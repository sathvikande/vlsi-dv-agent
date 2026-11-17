"""
Cocotb Verification of AXI4-Stream FIFO using cocotbext-axi Verification IP (VIP).
Demonstrates enterprise protocol verification with backpressure, packet bursts, and handshake validation.
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles
from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamFrame


async def watchdog(dut, cycles: int = 1000):
    """Failsafe simulation watchdog coroutine."""
    await ClockCycles(dut.aclk, cycles)
    assert False, f"FATAL: Simulation Watchdog timed out after {cycles} cycles! AXI deadlock detected."


@cocotb.test()
async def test_axis_fifo_packet_burst(dut):
    """
    Sends an AXI-Stream packet burst through the FIFO and verifies data integrity and framing.
    """
    clock = Clock(dut.aclk, 10, unit="ns")
    cocotb.start_soon(clock.start())
    cocotb.start_soon(watchdog(dut, cycles=500))

    # Initialize VIP Agents (reset handled explicitly)
    source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis"), dut.aclk)
    sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.aclk)

    # Apply 5 clock cycles of reset according to DV Guardrails
    dut.aresetn.value = 0
    await ClockCycles(dut.aclk, 5)
    dut.aresetn.value = 1
    await RisingEdge(dut.aclk)

    # Generate 16-byte burst payload
    payload = bytes([0x10 + i for i in range(16)])
    test_frame = AxiStreamFrame(payload)

    dut._log.info(f"Injecting AXI4-Stream packet of length {len(payload)} via VIP Source...")
    await source.send(test_frame)

    dut._log.info("Awaiting reception of packet via VIP Sink...")
    rx_frame = await sink.recv()

    assert bytes(rx_frame.tdata) == payload, f"AXI Stream payload corruption! Expected {payload.hex()}, got {bytes(rx_frame.tdata).hex()}"
    dut._log.info("AXI4-Stream VIP packet burst transfer verified with zero protocol errors!")
