# SPI Slave with Single Port RAM — RTL Design & Verification

## Overview

This project implements an **SPI slave interface with an integrated single-port RAM** using **Verilog HDL**. The design allows an SPI master to write to and read from a 256-byte on-chip memory using a simple 2-bit command protocol, including the SPI shift-register/FSM interface, a single-port RAM with independent write/read addressing, and a top-level wrapper connecting the two.

The design was verified using a **self-checking testbench in QuestaSim** and taken through the **Vivado FPGA design flow**, including elaboration, synthesis, implementation, timing analysis, and linting. Three FSM encoding styles (Gray, Sequential, One-Hot) were also compared for timing performance.

---

## Project Structure

```text
SPI_Slave_RAM/
│
├── RTL/
│   ├── SPI.v
│   ├── RAM.v
│   └── Wrapper.v
│
├── Testbench/
│   └── tb.v
│
├── Simulation/
│   └── sim.do
│
└── README.md
```

### RTL Files

**`SPI.v`**

SPI slave module. Implements the command FSM (`IDLE`, `CHK_CMD`, `WRITE`, `READ_ADD`, `READ_DATA`), the MOSI shift register, and the MISO output shift logic.

**`RAM.v`**

Single-port RAM module (256 x 8). Decodes a 10-bit command word into write-address load, data write, read-address load, and data read operations.

**`Wrapper.v`**

Top-level module instantiating and connecting the `SPI` and `RAM` modules.

**`tb.v`**

Self-checking testbench used to verify write-address, write-data, read-address, and read-data operations end-to-end through MOSI/MISO.

**`sim.do`**

QuestaSim DO file used to compile, simulate, add waveform groups, and run the simulation.

---

## Command Protocol

Each transaction is a 10-bit word shifted MSB-first on `MOSI`. The top 2 bits select the operation:

| `din[9:8]` | Operation     
| ---------- | -------------- 
| `00`       | Set write address 
| `01`       | Write data     
| `10`       | Set read address  
| `11`       | Read data      

---

## Verification

The design was verified using a **self-checking Verilog testbench** in QuestaSim.

The testbench terminates with:

```text
ALL TESTS PASSED SUCCESSFULLY!
```

confirming that all directed verification cases passed successfully.

---

## QuestaSim Simulation

The project includes a QuestaSim DO file that:

1. Creates the simulation library
2. Compiles the Verilog source files
3. Starts the testbench
4. Adds formatted waveform signals (`clk`, `rst_n`, `MOSI`, `SS_n`, `MISO`, `rx_data`, `tx_data`, `rx_valid`, `tx_valid`)
5. Runs the simulation
6. Automatically zooms the waveform

The simulation verified all four write/read operations without logical errors.

---

## Vivado Design Flow

The design was taken through the following FPGA design flow:

```text
Verilog RTL
    │
    ▼
Elaboration
    │
    ▼
Synthesis
    │
    ▼
Implementation
    │
    ▼
Timing / Utilization Analysis
```

The project includes:

* Elaboration schematic
* Synthesis schematic
* Implementation results
* Utilization report
* Timing report
* Messages showing no critical errors
* Linting results

The project uses a **100 MHz clock constraint** on the Basys 3 clock pin `W5`, with `MOSI`, `SS_n`, `MISO`, and `rst_n` mapped to onboard switches, buttons, and LEDs.

---

## FSM Encoding Comparison

Three state encodings were synthesized and compared for timing performance:

| Encoding    | Worst Setup Slack (WNS) |
| ----------- | -----------------------: |
| Gray        |                  1.297 ns |
| Sequential  |                  0.991 ns |
| **One-Hot** |             **1.874 ns** |

One-hot encoding produced the best slack and was selected as the final implementation, giving the highest achievable operating frequency.

---

## Linting

The RTL was linted using the default methodology and goals.

**Result:** One informational warning (`always_signal_assign_large` in the SPI module — an always block with more signal assignments than the style-check threshold). No errors were reported.

---

## Tools Used

* **Verilog HDL** — RTL design
* **QuestaSim** — Functional simulation and verification
* **Vivado** — Elaboration, synthesis, implementation, timing and utilization analysis
* **XDC** — Timing and FPGA constraints (Basys 3, `xc7a35ticpg236-1L`)

---
