# Synchronous FIFO Specification

## 1. Overview
This document specifies the architecture and interface for an 8-bit wide, 16-depth synchronous First-In First-Out (FIFO) buffer designed for on-chip inter-module rate matching.

---

## 2. Architectural Parameters

| Parameter | Type | Default Value | Description |
|:---|:---|:---|:---|
| `DATA_WIDTH` | Integer | 8 | Width of the data word in bits |
| `DEPTH` | Integer | 16 | Number of storage locations (words) in the FIFO |

---

## 3. Port Interface

| Port Name | Direction | Width | Clock/Polarity | Description |
|:---|:---|:---|:---|:---|
| `clk` | Input | 1 | Pos-edge | Primary simulation and system clock |
| `rst_n` | Input | 1 | Active-low | Synchronous active-low system reset |
| `wr_en` | Input | 1 | Level | Active-high write enable |
| `rd_en` | Input | 1 | Level | Active-high read enable |
| `din` | Input | `DATA_WIDTH` (8) | Synchronous | Write data payload |
| `dout` | Output | `DATA_WIDTH` (8) | Synchronous | Read data payload |
| `full` | Output | 1 | Combinational / Registered | High when FIFO cannot accept further writes |
| `empty` | Output | 1 | Combinational / Registered | High when FIFO contains zero items |

---

## 4. Detailed Functional Requirements

### 4.1 Reset State
- When `rst_n` is asserted (`rst_n == 0`):
  - `empty` MUST assert (`1`).
  - `full` MUST deassert (`0`).
  - `dout` MUST clear to `8'h00`.
  - Internal write and read pointers MUST reset to 0.
  - Internal storage count MUST reset to 0.

### 4.2 Write Operation
- When `wr_en == 1` and `full == 0` on the rising edge of `clk`:
  - Data from `din` is latched into memory at `wr_ptr`.
  - `wr_ptr` advances to `(wr_ptr + 1) mod DEPTH`.
  - Stored count increases by 1.
  - `empty` deasserts.
- When `full == 1`:
  - Further write attempts MUST be rejected without corrupting existing memory contents or pointers.

### 4.3 Read Operation
- When `rd_en == 1` and `empty == 0` on the rising edge of `clk`:
  - Data at `rd_ptr` is presented on `dout`.
  - `rd_ptr` advances to `(rd_ptr + 1) mod DEPTH`.
  - Stored count decreases by 1.
  - `full` deasserts.
- When `empty == 1`:
  - Further read attempts are ignored; `dout` holds previous value.

### 4.4 Full and Empty Flag Requirements
- **`empty` flag**:
  - MUST be asserted if and only if `count == 0`.
- **`full` flag (CRITICAL REQUIREMENT)**:
  - The FIFO depth is **16**.
  - `full` MUST be asserted IF AND ONLY IF the FIFO contains exactly `DEPTH` (16) unread items (`count == 16`).
  - When 15 items have been written, `full` MUST remain `0`.
  - The 16th write MUST be accepted. Immediately following the completion of the 16th write, `full` MUST transition to `1`.
