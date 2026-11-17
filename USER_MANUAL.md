# 📘 Autonomous VLSI Design Verification User Manual

Welcome to the **Autonomous VLSI Design Verification (DV) System**.
This user manual provides an exhaustive, engineer-friendly operational guide for design verification engineers, architects, and autonomous AI agents.

---

## 📑 Table of Contents
1. [System Architecture & Capabilities](#-system-architecture--capabilities)
2. [Quickstart in 60 Seconds](#-quickstart-in-60-seconds)
3. [Unified CLI Interface (`vlsi`)](#-unified-cli-interface-vlsi)
4. [Hermes AI Agent Integration & Conversational Prompts](#-hermes-ai-agent-integration--conversational-prompts)
5. [Live Registered MCP Tool Catalog](#-live-registered-mcp-tool-catalog)
6. [Verification Tutorials & Step-by-Step Walkthroughs](#-verification-tutorials--step-by-step-walkthroughs)
7. [Maintenance & Auto-Updating Documentation](#-maintenance--auto-updating-documentation)
8. [Troubleshooting & Frequently Asked Questions (FAQ)](#-troubleshooting--frequently-asked-questions-faq)

---

## 🏛️ System Architecture & Capabilities

The system combines open-source hardware verification engines, formal solvers, and protocol VIPs with the **Hermes Autonomous AI Agent** via the **Model Context Protocol (MCP)**:

```mermaid
flowchart LR
    USER[Verification Engineer] -->|Runs Commands| CLI[Unified CLI: vlsi]
    USER -->|Conversational Chat| HERMES[Hermes AI Agent: vlsi agent]
    HERMES -->|FastMCP stdio| MCP_SERVER[VLSI MCP Server: vlsi_mcp.py]
    
    subgraph Verification_Engines[EDA Engines & VIPs]
        VERILATOR[Verilator 5.052: 2-state compiled]
        ICARUS[Icarus Verilog 13.0: 4-state event]
        COCOTB[Cocotb 2.1: Python Testbenches]
        AXI_VIP[cocotbext-axi: AMBA AXI4-Stream VIP]
        SVA[IEEE 1800 SVA: Concurrent Assertions]
        YOSYS_SAT[Yosys SAT: JasperGold Formal Prover]
        YOSYS_LEC[Yosys Miter: Conformal LEC Equivalence]
        Z3[Z3 SMT Prover: Constrained Stimulus]
    end

    MCP_SERVER --> Verification_Engines
    CLI --> Verification_Engines
    Verification_Engines --> ARTIFACTS[VCD Waves, Coverage DB, UCDB HTML Dashboard]
```

---

## ⚡ Quickstart in 60 Seconds

### 1. Run the Complete Verification Pipeline
To execute all simulation tests, AXI-Stream VIP, formal LEC proofs, mutation grading, and dashboard generation in one single turnkey pass:
```bash
vlsi run
```

### 2. Launch the Autonomous AI Verification Engineer
To start an interactive reasoning session where the AI agent diagnoses bugs, inspects waveforms, and writes fixes:
```bash
vlsi agent
```

### 3. Open the Interactive Tapeout Signoff Dashboard
```bash
vlsi dashboard
```
Open `demo_fifo/tapeout_dashboard.html` in any web browser to view the radial closure gauges, vPlan requirements matrix, and test status.

---

## 🖥️ Unified CLI Interface (`vlsi`)

The `vlsi` command is installed globally in `~/.local/bin/vlsi` and can be invoked from any directory:

```bash
vlsi <command> [options]
```

### Command Reference Table

| Command | Subcommands / Options | Purpose & Description |
| :--- | :--- | :--- |
| `vlsi help` | `-h`, `--help` | Displays colorized interactive menu, cheatsheet, and examples |
| `vlsi run` | `vlsi demo` | Executes full end-to-end verification demo suite |
| `vlsi sv` | `run`, `compile` | Runs pure SystemVerilog IEEE 1800 Layered OOP Testbench (Interface, Class, Covergroup, SVA) |
| `vlsi gen-sv` | `<module_name>` | Scaffolds complete 12-file pure SystemVerilog layered OOP testbench suite |
| `vlsi sim` | `fifo`, `axis`, `icarus` | Runs targeted hardware simulation (Verilator or Icarus) |
| `vlsi formal` | — | Runs JasperGold-equivalent SAT temporal induction formal proof |
| `vlsi lec` | — | Runs Cadence Conformal-equivalent Logic Equivalence Check |
| `vlsi mutate` | — | Runs automated fault injection & mutation resilience grading |
| `vlsi dashboard` | `ucdb` | Generates and exports the interactive UCDB HTML dashboard |
| `vlsi heal` | — | Executes master closed-loop autonomous self-healing loop |
| `vlsi agent` | `chat` | Launches Hermes AI Verification Agent in interactive chat mode |
| `vlsi test-mcp` | `mcp` | Tests FastMCP connectivity and audits discovered tools |
| `vlsi manual` | `doc`, `docs` | Displays this User Manual directly in terminal |
| `vlsi update-manual`| `sync-docs` | Auto-syncs `USER_MANUAL.md` with registered tools in `vlsi_mcp.py` |

---

## 🤖 Hermes AI Agent Integration & Conversational Prompts

Hermes interacts with the verification environment through the `vlsi_tools` FastMCP server. When running `vlsi agent` (or `hermes chat`), you can converse naturally using these high-leverage prompts:

### Example Prompts for Hermes:

1. **Bug Hunting & Waveform Diagnosis**:
   > *"There is a failure in `demo_fifo/`. Run the simulation, parse the failure timestamp, and inspect `dump.vcd` around that cycle. Tell me whether it is an RTL bug or a testbench bug."*

2. **Sequential Logic Equivalence Checking (LEC)**:
   > *"I just patched `fifo.sv`. Run `check_logic_equivalence` against the golden reference to prove mathematically that no unintended side-effects were introduced."*

3. **Mutation Testing & Testbench Resilience**:
   > *"Run mutation testing with 5 synthetic hardware faults. Did any mutants survive? If so, tell me what coverage hole exists in `test_fifo.py`."*

4. **AMBA AXI4-Stream VIP Verification**:
   > *"Run the AXI4-Stream VIP packet burst testbench on `axis_fifo.sv`. Verify backpressure handling and tlast framing."*

5. **Closed-Loop Self-Healing**:
   > *"Execute the autonomous heal loop. Run regressions, prove formal invariants, audit the vPlan, and generate the tapeout signoff dashboard."*

---

<!-- TOOL_CATALOG_START -->
## 🧰 Live Registered MCP Tool Catalog

*Auto-generated from `vlsi_mcp.py` (22 tools discovered)*

| # | Tool Name | Commercial EDA Equivalent | Function Summary |
|---|---|---|---|
| 1 | [`inspect_vcd_waveform`](#inspect_vcd_waveform) | **Verdi / SimVision** | Parses a .vcd waveform file using vcdvcd and returns a clean, compact list of |
| 2 | [`parse_verilator_log`](#parse_verilator_log) | **Build Diagnostic Filter** | Filters noisy Verilator/Icarus compile and Cocotb simulation logs to extract only |
| 3 | [`check_coverage_summary`](#check_coverage_summary) | **Verilator Code Coverage** | Runs verilator_coverage on a coverage.dat file and generates a structured summary |
| 4 | [`compare_waveforms`](#compare_waveforms) | **Cadence WaveMiner** | Cadence WaveMiner Equivalent: |
| 5 | [`run_regression_suite`](#run_regression_suite) | **Cadence AutoTriage** | Cadence AutoTriage Equivalent: |
| 6 | [`solve_constraints`](#solve_constraints) | **Cadence Xcelium ML / SystemVerilog** | Cadence Xcelium ML / SystemVerilog Constraint Solver Equivalent: |
| 7 | [`run_formal_check`](#run_formal_check) | **Cadence JasperGold** | Cadence JasperGold Equivalent: |
| 8 | [`run_multi_simulator_check`](#run_multi_simulator_check) | **Multi-Vendor Simulators** | Executes cross-simulator verification across BOTH Verilator (2-state compiled) |
| 9 | [`generate_edaplayground_bundle`](#generate_edaplayground_bundle) | **EDA Playground Export** | Generates a standardized EDA Playground deployment bundle from local RTL and Cocotb testbenches. |
| 10 | [`verify_golden_scoreboard`](#verify_golden_scoreboard) | **Scoreboard / Transaction Queue** | Parses transactions from a VCD waveform into a golden Python FIFO queue model. |
| 11 | [`analyze_functional_coverage`](#analyze_functional_coverage) | **Cocotb Functional Coverage** | Parses a functional coverage database generated by cocotb-coverage. |
| 12 | [`audit_vplan_traceability`](#audit_vplan_traceability) | **Siemens Questa Verification IQ** | Verification Plan (vPlan) Traceability Engine: |
| 13 | [`verify_csr_registers`](#verify_csr_registers) | **UVM RAL Engine** | Register Abstraction Layer (RAL) Engine: |
| 14 | [`analyze_cdc_paths`](#analyze_cdc_paths) | **Conformal CDC Structural Lint** | Clock Domain Crossing (CDC) Structural Checker: |
| 15 | [`check_logic_equivalence`](#check_logic_equivalence) | **Cadence Conformal LEC / Formality** | Formal Logic Equivalence Checking (LEC - Cadence Conformal / Synopsys Formality Equivalent): |
| 16 | [`run_mutation_testing`](#run_mutation_testing) | **Cadence Verisium Fault / Certitude** | Automated Fault Injection & Mutation Testing (Cadence Verisium Fault / Synopsys Certitude Equivalent): |
| 17 | [`generate_unified_ucdb_dashboard`](#generate_unified_ucdb_dashboard) | **Cadence IMC / Verisium / Verdi** | Unified Coverage Database (UCDB) & Interactive Signoff Dashboard (Cadence IMC / Verisium / Verdi Equivalent): |
| 18 | [`run_autonomous_heal_loop`](#run_autonomous_heal_loop) | **Autonomous Verification Agent** | Master Autonomous Self-Healing & Signoff Loop: |
| 19 | [`run_sv_testbench`](#run_sv_testbench) | **Synopsys VCS / Cadence Xcelium Native SV** | Pure SystemVerilog IEEE 1800 Layered OOP Testbench Runner. |
| 20 | [`generate_sv_layered_tb`](#generate_sv_layered_tb) | **UVM/SV OOP Testbench Generator** | IEEE 1800 Layered OOP Testbench Scaffolder & Code Generator. |
| 21 | [`get_vlsi_help`](#get_vlsi_help) | **Interactive User Help Assistant** | Interactive User Help and Manual Navigator: |
| 22 | [`update_user_manual`](#update_user_manual) | **Documentation Synchronizer** | Documentation Auto-Synchronizer: |

### Detailed Tool Specifications

#### `inspect_vcd_waveform`

**Signature:** `inspect_vcd_waveform(vcd_path: str, failure_time_ns: int, window_ns: int) -> str`

```text
Parses a .vcd waveform file using vcdvcd and returns a clean, compact list of
signal transitions within the time window [failure_time_ns - window_ns, failure_time_ns + window_ns].
```

#### `parse_verilator_log`

**Signature:** `parse_verilator_log(log_text: str) -> str`

```text
Filters noisy Verilator/Icarus compile and Cocotb simulation logs to extract only
critical diagnostics: syntax errors, lint warnings, assertion failures,
simulation timestamps, and test execution summaries.
```

#### `check_coverage_summary`

**Signature:** `check_coverage_summary(coverage_dat_path: str) -> str`

```text
Runs verilator_coverage on a coverage.dat file and generates a structured summary
of overall functional/line coverage metrics and specific uncovered RTL lines.
```

#### `compare_waveforms`

**Signature:** `compare_waveforms(golden_vcd_path: str, failing_vcd_path: str, ignore_clocks: bool) -> str`

```text
Cadence WaveMiner Equivalent:
Compares a passing (golden) VCD against a failing VCD to find the EARLIEST
temporal divergence cycle and identify the primary root-cause signal.
```

#### `run_regression_suite`

**Signature:** `run_regression_suite(test_dir: str, seeds: list[int], sim: str) -> str`

```text
Cadence AutoTriage Equivalent:
Runs a multi-seed randomized regression suite and automatically clusters
failing tests into distinct root causes based on stack traces and failure signatures.
```

#### `solve_constraints`

**Signature:** `solve_constraints(variables: dict, constraints: list[str], count: int) -> str`

```text
Cadence Xcelium ML / SystemVerilog Constraint Solver Equivalent:
Uses the Z3 SMT Theorem Prover to solve complex hardware constraints
(ranges, bitvectors, alignments, and mutual exclusion) to generate valid stimulus.

Args:
    variables: Dict mapping var name to spec:
               e.g. {"burst_len": [1, 16], "addr": [0, 1024], "is_write": "bool"}
    constraints: List of constraint strings:
               e.g. ["addr % 4 == 0", "burst_len >= 4", "burst_len <= 8"]
    count: Number of diverse solutions to generate.
```

#### `run_formal_check`

**Signature:** `run_formal_check(sv_source_path: str, top_module: str, property_check: str) -> str`

```text
Cadence JasperGold Equivalent:
Executes formal verification using the Yosys SAT temporal induction engine.
Mathematically proves whether a safety invariant holds across ALL reachable states,
or generates a counterexample state if violated.

Args:
    sv_source_path: Path to SystemVerilog file.
    top_module: Name of top-level module (default: 'fifo').
    property_check: Property in format '<sig> == <val>' or '<sig> = <val>' (e.g. 'full == 0').
```

#### `run_multi_simulator_check`

**Signature:** `run_multi_simulator_check(test_dir: str) -> str`

```text
Executes cross-simulator verification across BOTH Verilator (2-state compiled)
and Icarus Verilog (4-state event-driven) — the same core engines featured on EDA Playground.
```

#### `generate_edaplayground_bundle`

**Signature:** `generate_edaplayground_bundle(design_path: str, testbench_path: str, output_dir: str, top_module: str) -> str`

```text
Generates a standardized EDA Playground deployment bundle from local RTL and Cocotb testbenches.
```

#### `verify_golden_scoreboard`

**Signature:** `verify_golden_scoreboard(vcd_path: str, wr_data_sig: str, rd_data_sig: str, wr_en_sig: str, rd_en_sig: str, clk_sig: str) -> str`

```text
Parses transactions from a VCD waveform into a golden Python FIFO queue model.
Checks data ordering, detects data corruption, and flags dropped words.
```

#### `analyze_functional_coverage`

**Signature:** `analyze_functional_coverage(coverage_yaml_path: str) -> str`

```text
Parses a functional coverage database generated by cocotb-coverage.
Computes overall functional coverage (FCov) percentage, per-coverpoint stats,
and lists all uncovered corner-case bins to guide test generation.
```

#### `audit_vplan_traceability`

**Signature:** `audit_vplan_traceability(vplan_path: str, test_results_xml: str, fcov_yaml_path: str) -> str`

```text
Verification Plan (vPlan) Traceability Engine:
Correlates high-level architectural requirements from a vPlan against actual test execution
results (results.xml) and functional coverage (functional_coverage.yml).
Computes an executive tapeout signoff readiness score.
```

#### `verify_csr_registers`

**Signature:** `verify_csr_registers(reg_map_path: str) -> str`

```text
Register Abstraction Layer (RAL) Engine:
Validates memory-mapped register definitions (offsets, widths, reset values, and
access policies RW, RO, W1C). Detects address collisions and generates ready-to-run
Python test sequences for automated CSR verification.
```

#### `analyze_cdc_paths`

**Signature:** `analyze_cdc_paths(sv_source_path: str, top_module: str) -> str`

```text
Clock Domain Crossing (CDC) Structural Checker:
Inspects clock domains and registers in the SystemVerilog design using Yosys.
Identifies asynchronous clock boundaries, reset schemes, and flags unsafe cross-domain nets.
```

#### `check_logic_equivalence`

**Signature:** `check_logic_equivalence(golden_rtl_path: str, revised_rtl_path: str, top_module: str) -> str`

```text
Formal Logic Equivalence Checking (LEC - Cadence Conformal / Synopsys Formality Equivalent):
Uses Yosys formal miter circuit and sequential equivalence proving (equiv_make, equiv_simple, equiv_induct, equiv_status)
to prove whether a revised/repaired RTL is 100% mathematically equivalent to the golden RTL across all reachable states.
Pinpoints exact divergent nets, bit indices, and registers if differences exist.
```

#### `run_mutation_testing`

**Signature:** `run_mutation_testing(sv_source_path: str, test_dir: str, max_mutations: int) -> str`

```text
Automated Fault Injection & Mutation Testing (Cadence Verisium Fault / Synopsys Certitude Equivalent):
Systematically injects synthetic bugs (off-by-one, stuck-at pointers, inverted resets, corrupted flags)
into the design and runs the verification suite against each mutant.
Determines whether the testbench/SVA assertions successfully KILL the mutant or if the mutant SURVIVES (revealing coverage holes).
Computes the formal Mutation Score (%) and reports test suite blind spots.
```

#### `generate_unified_ucdb_dashboard`

**Signature:** `generate_unified_ucdb_dashboard(test_dir: str, output_html_path: str) -> str`

```text
Unified Coverage Database (UCDB) & Interactive Signoff Dashboard (Cadence IMC / Verisium / Verdi Equivalent):
Merges Code Coverage (Verilator line/toggle), Functional Coverage (cocotb-coverage covergroups/crosses),
SVA Assertion results, Regression Pass/Fail metrics (results.xml), and Verification Plan (vplan.yaml)
into a standalone, executive-ready HTML dashboard with CSS badges, progress bars, and tapeout readiness metrics.
```

#### `run_autonomous_heal_loop`

**Signature:** `run_autonomous_heal_loop(design_dir: str, top_module: str) -> str`

```text
Master Autonomous Self-Healing & Signoff Loop:
Executes the full end-to-end closed-loop verification pipeline:
1. Executes multi-simulator regression across Verilator and Icarus.
2. If clean: runs formal induction verification, computes mutation score, audits vPlan, and generates UCDB dashboard.
3. If failing: extracts failure timestamp, inspects VCD waveform, triages root cause, validates fixes with LEC,
   and re-runs multi-simulator regression until 100% tapeout signoff is achieved.
```

#### `run_sv_testbench`

**Signature:** `run_sv_testbench(tb_dir: str, target: str, timeout_sec: int) -> str`

```text
Pure SystemVerilog IEEE 1800 Layered OOP Testbench Runner.
Commercial EDA Equivalent: Synopsys VCS / Cadence Xcelium native SystemVerilog simulator.
Compiles and executes native SystemVerilog OOP testbenches (Interface with Clocking Blocks,
Transaction, Generator, Driver, Monitor with Covergroups, Scoreboard with Queues, Environment, SVA Assertions).
Returns execution status, data integrity scoreboard metrics, assertion results, and functional coverage closure.
```

#### `generate_sv_layered_tb`

**Signature:** `generate_sv_layered_tb(module_name: str, clock_name: str, reset_name: str, data_width: int, output_dir: str) -> str`

```text
IEEE 1800 Layered OOP Testbench Scaffolder & Code Generator.
Commercial EDA Equivalent: Synopsys / Cadence UVM/SV Testbench Generator.
Automatically generates a production-grade, IEEE 1800-2017 SystemVerilog OOP testbench suite:
- Interface with Clocking Blocks & Modports (<module>_if.sv)
- Constrained-Random Transaction class (<module>_transaction.sv)
- Functional Covergroup & Coverpoint class (<module>_coverage.sv)
- Mailbox Stimulus Generator (<module>_generator.sv)
- Synchronous Virtual Interface Driver (<module>_driver.sv)
- Passive Monitor with Coverage Hook (<module>_monitor.sv)
- Golden Reference Model & Order Scoreboard (<module>_scoreboard.sv)
- Phase Coordinating Environment (<module>_env.sv)
- Top Test Class (<module>_test.sv)
- Package Container (<module>_pkg.sv)
- Top Testbench with Clock, Reset, Waveform Dump & SVA Bind (<module>_tb_top.sv)
- Multi-target Verilator Makefile
```

#### `get_vlsi_help`

**Signature:** `get_vlsi_help(topic: str) -> str`

```text
Interactive User Help and Manual Navigator:
Provides immediate guidance and cheat-sheets for using the VLSI verification agent, CLI commands, simulators, and formal engines.
Topics: 'cli', 'simulation', 'formal', 'lec', 'mutation', 'axi', 'dashboard', 'self-heal', 'tools', 'all'.
```

#### `update_user_manual`

**Signature:** `update_user_manual(manual_path: str) -> str`

```text
Documentation Auto-Synchronizer:
Inspects all registered MCP tools in vlsi_mcp.py via AST analysis, extracts signatures and docstrings,
and updates USER_MANUAL.md to ensure the manual is 100% up-to-date with every project upgrade.
```

<!-- TOOL_CATALOG_END -->

---

## 📖 Verification Tutorials & Step-by-Step Walkthroughs

### Tutorial 1: Simulating Synchronous FIFO with Verilator & SVA
1. Change directory to `demo_fifo/`:
   ```bash
   cd ~/vlsi-dv-agent/demo_fifo
   ```
2. Run simulation with Verilator:
   ```bash
   make SIM=verilator
   ```
3. Observe compiled SystemVerilog Assertions (SVA) checking reset polarity, pointer boundaries, and full/empty flags on every active clock cycle.

---

### Tutorial 2: AMBA AXI4-Stream Protocol VIP Verification
1. Run the AXI4-Stream VIP suite:
   ```bash
   vlsi sim axis
   ```
2. Cocotb drives randomized transactions via `cocotbext.axi.AxiStreamSource` and samples outputs via `AxiStreamSink`.
3. Verifies zero packet data corruption, backpressure stalls when full, and `tlast` packet boundary preservation.

---

### Tutorial 3: Running Formal Equivalence Checking (LEC)
1. Run LEC between golden reference and current model:
   ```bash
   vlsi lec
   ```
2. Yosys builds an equivalence miter circuit across all 151 internal state registers and memory arrays.
3. Proves 100% sequential equivalence or flags divergent signal bit indices.

---

### Tutorial 4: Mutation Testing (Fault Grading)
1. Run fault injection:
   ```bash
   vlsi mutate
   ```
2. Injects 5 realistic synthetic hardware bugs:
   - Off-by-one capacity limit (`count == DEPTH - 1`)
   - Inverted reset polarity (`if (rst_n)`)
   - Empty flag corruption (`count == 1`)
   - Stuck write pointer (`wr_ptr <= wr_ptr`)
   - Stuck read pointer (`rd_ptr <= rd_ptr`)
3. Confirms whether the testbench and SVA assertions **KILL** 100% of the mutants.

---

### Tutorial 5: Autonomous Closed-Loop Self-Healing
1. Execute the turnkey autonomous orchestrator:
   ```bash
   vlsi heal
   ```
2. The agent executes multi-simulator cross-checking, formal induction invariant verification, mutation grading, vPlan auditing, and HTML signoff dashboard export in a single command.

---

## 🔄 Maintenance & Auto-Updating Documentation

This project enforces strict documentation synchronization: **Every time a new tool is added to `vlsi_mcp.py`, the user manual is automatically updated!**

### How to Add a New Tool:
1. Open `~/vlsi-dv-agent/vlsi_mcp.py`.
2. Decorate your Python function with `@mcp.tool()`:
   ```python
   @mcp.tool()
   def verify_power_domains(upf_path: str) -> str:
       """
       Low-Power & UPF Domain Checker:
       Validates power gating isolation cells and level shifters.
       """
       # implementation ...
       return "Power domains verified."
   ```
3. Run the synchronization command:
   ```bash
   vlsi update-manual
   ```
4. `USER_MANUAL.md` will automatically discover the new tool via AST analysis, extract its signature, update the tool table, and generate its detailed specification!

---

## ❓ Troubleshooting & Frequently Asked Questions (FAQ)

### Q: Why do we use Python 3.14 instead of Python 3.15?
**A**: Cocotb 2.1 currently pins Python support to `<= 3.14`. Python 3.14 (`/opt/homebrew/bin/python3.14`) is installed and configured as the default interpreter for all simulation scripts and the MCP server.

### Q: How do I view VCD waveform files graphically?
**A**: Open `demo_fifo/dump.vcd` using any open-source or commercial waveform viewer:
- **GTKWave**: `gtkwave demo_fifo/dump.vcd`
- **Surfer**: `surfer demo_fifo/dump.vcd`
- Or use the MCP tool `inspect_vcd_waveform` or `compare_waveforms` for automated text analysis.

### Q: Can I run simulations with Icarus Verilog instead of Verilator?
**A**: Yes! Simply run:
```bash
vlsi sim icarus
```
Icarus performs full 4-state event simulation (`0`, `1`, `X`, `Z`) to detect uninitialized register bugs and race conditions.
