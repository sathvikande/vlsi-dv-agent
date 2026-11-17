# EDA Playground Deployment Bundle

Ready-to-run bundle for [EDA Playground](https://www.edaplayground.com/).

### Instructions for EDA Playground:
1. Open https://www.edaplayground.com/
2. In the Left Navigation Menu:
   - **Testbench Language**: Select **Python / Cocotb**
   - **Top class / module**: Enter `fifo`
   - **Tools & Simulators**: Select **Icarus Verilog** (or **Aldec Riviera-PRO**)
   - **Run options**: Enter `-g2012`
   - Check the box: **Open EPWave after run**
3. In the Web Editor Panes:
   - Paste contents of `edaplayground_bundle/testbench.py` into the **Left (Testbench)** tab.
   - Paste contents of `edaplayground_bundle/design.sv` into the **Right (Design)** tab.
4. Click **Run** (Ctrl+Enter) in the browser toolbar!
