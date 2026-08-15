SPI Slave with Single Port RAM — RTL Design & Verification
Overview

This project implements an SPI slave interface with an integrated single-port RAM using Verilog HDL. The design allows an SPI master to write to and read from a 256-byte on-chip memory using a simple 2-bit command protocol. It includes the SPI shift-register/FSM interface, a single-port RAM with independent write and read addressing, and a top-level wrapper connecting the two.

The design was verified using a self-checking testbench in QuestaSim and taken through the Vivado FPGA design flow, including elaboration, synthesis, implementation, timing analysis, and linting. Three FSM encoding styles (Gray, Sequential, One-Hot) were also compared for timing performance.

Project Structure
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
RTL Files

SPI.v SPI slave module. Implements the command FSM (IDLE, CHK_CMD, WRITE, READ_ADD, READ_DATA), the MOSI shift register, and the MISO output shift logic.

RAM.v Single-port RAM module (256 x 8). Decodes a 10-bit command word into write-address load, data write, read-address load, and data read operations.

Wrapper.v Top-level module instantiating and connecting the SPI and RAM modules.

tb.v Self-checking testbench used to verify write-address, write-data, read-address, and read-data operations end-to-end through MOSI/MISO.

sim.do QuestaSim DO file used to compile, simulate, add waveform groups, and run the simulation.

Command Protocol

Each transaction is a 10-bit word shifted MSB-first on MOSI. The top 2 bits select the operation:

din[9:8]	Operation	Description
00	Set write addr	Loads din[7:0] into write_addr
01	Write data	Writes din[7:0] to mem[write_addr]
10	Set read addr	Loads din[7:0] into read_addr
11	Read data	Latches mem[read_addr] and drives it on MISO
Verification

The design was verified using a self-checking Verilog testbench in QuestaSim.

The testbench verifies:

1. Write Address Write address 0xFF is shifted in and latched.

rx_data = 0xFF  →  PASS

2. Write Data Data 0x7D is shifted in and written to mem[0xFF].

rx_data       = 0x17D  →  PASS
RAM[0xFF]     = 0x7D   →  PASS

3. Read Address Read address 0xFF is shifted in and latched.

rx_data = 0x2FF  →  PASS

4. Read Data Data is read back from mem[0xFF] and shifted out over MISO.

MISO data = 0x7D  →  PASS

The testbench terminates with:

ALL TESTS PASSED SUCCESSFULLY!

confirming that all directed verification cases passed successfully.

QuestaSim Simulation

The project includes a QuestaSim DO file that:

Creates the simulation library
Compiles the Verilog source files
Starts the testbench
Adds formatted waveform signals (clk, rst_n, MOSI, SS_n, MISO, rx_data, tx_data, rx_valid, tx_valid)
Runs the simulation
Automatically zooms the waveform

The simulation verified all four write/read operations without logical errors.

Vivado Design Flow

The design was taken through the following FPGA design flow:

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

The project includes:

Elaboration schematic
Synthesis schematic
Implementation results
Utilization report
Timing report
Messages showing no critical errors
Linting results

The project uses a 100 MHz clock constraint on the Basys 3 clock pin W5, with MOSI, SS_n, MISO, and rst_n mapped to onboard switches, buttons, and LEDs.

FSM Encoding Comparison

Three state encodings were synthesized and compared for timing performance:

Encoding	Worst Setup Slack (WNS)
Gray	1.297 ns
Sequential	0.991 ns
One-Hot	1.874 ns

One-hot encoding produced the best slack and was selected as the final implementation, giving the highest achievable operating frequency.

Final Post-Implementation Results (One-Hot Encoding)

Utilization

Module	Slice LUTs	Slice Registers	Slices
RAM	812	2099	795
SPI	20	43	16
Wrapper (Total)	832	2142	806

Timing

Metric	Value
Worst Setup Slack	1.874 ns
Worst Hold Slack	0.116 ns
Failing Endpoints	0

All user-specified timing constraints are met.

Note: Vivado reports that the RAM's mem_reg cannot be inferred as Block RAM/DRAM and is implemented in distributed slice registers instead. It also flags mem_reg as having both set and reset with the same priority, a potential simulation/synthesis mismatch worth addressing in a future revision.

Linting

The RTL was linted using the default methodology and goals.

Result: One informational warning (always_signal_assign_large in the SPI module — an always block with more signal assignments than the style-check threshold). No errors were reported.

Tools Used
Verilog HDL — RTL design
QuestaSim — Functional simulation and verification
Vivado — Elaboration, synthesis, implementation, timing and utilization analysis
XDC — Timing and FPGA constraints (Basys 3, xc7a35ticpg236-1L)
