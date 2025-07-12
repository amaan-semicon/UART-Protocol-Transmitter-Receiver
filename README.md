# UART-Protocol-Transmitter-Receiver
Verilog-based UART Transmitter and Receiver with FSM architecture, baud rate generator, and testbench simulation.
# UART Protocol Transmitter and Receiver (with FIFO & RAM) – Verilog

This project implements a complete **Universal Asynchronous Receiver-Transmitter (UART)** system using **Verilog HDL**, featuring FIFO buffering, RAM-based storage, and FSM-driven TX/RX modules for serial communication. The system is synthesizable and verified through simulation.

---

## 📂 Modules Included

- `UART_TX.v` – Transmitter module (FSM-based)
- `UART_RX.v` – Receiver module (FSM-based)
- `baud_rate_generator.v` – Baud tick signal generator
- `FIFO.v` – First-In-First-Out buffer
- `random_access_memory.v` – Simple RAM module
- `Universal_Asynchronous_Transmitter_Receiver.v` – Top-level integration
- `testbench_uart.v` – Testbench to simulate UART communication *(to be added)*

---

## 📌 Project Description

This project simulates a **real-world UART communication pipeline** designed in Verilog. It features bidirectional data transmission with support for **data buffering** using FIFO and **persistent storage** using RAM. The design is modular, FSM-driven, and ideal for use in **FPGA, SoC, or embedded systems**.

### 🔁 UART Transmitter (`UART_TX.v`)
- FSM-driven serial data transmitter.
- Sends 8-bit parallel data with framing (1 start + 1 stop bit).
- Works with baud tick for correct timing.

### 🔂 UART Receiver (`UART_RX.v`)
- FSM that detects start bit, samples 8-bit data, verifies stop bit.
- Outputs parallel data to FIFO buffer.
- Handles asynchronous reception with internal sampling.

### 🕓 Baud Rate Generator (`baud_rate_generator.v`)
- Generates baud tick signals for synchronous TX and RX operation.
- Configurable divider for different standard UART rates.

### 📥 FIFO Buffer (`FIFO.v`)
- Temporary data holding buffer between RX → RAM or RAM → TX.
- Prevents overflow and underflow with `full` and `empty` flags.
- Ideal for handling communication timing mismatches.

### 💾 Random Access Memory (`random_access_memory.v`)
- Simple dual-port RAM for storing received UART data.
- Acts as simulation memory for logging/storing received bytes.

### 🧩 Top-Level Integration (`Universal_Asynchronous_Transmitter_Receiver.v`)
- Connects all submodules into a functional UART system.
- Supports full RX → FIFO → RAM write and RAM → FIFO → TX readback.
- Includes reset control and flow management between stages.

---

## ⚙️ Key Features

- Full UART pipeline: **Serial RX → FIFO → RAM → FIFO → TX**
- FSM-based clean modular design
- Baud rate configurable via generator
- Synthesizable and simulation-ready
- Buffer protection via FIFO
- Suitable for **SoC**, **ASIC**, or **FPGA** implementation

---

## 🧪 Simulation Plan

- Full testbench to verify:
  - RX sampling accuracy
  - TX serial output frame structure
  - FIFO overflow/underflow conditions
  - Data loopback through memory
- Waveform analysis using ModelSim/Vivado

---

## 📊 Diagrams *(to be added)*

> Place the following in the repo under `/assets/` and link them in the README once available.

- 📡 `block_diagram.png` – High-level data flow
- 🔁 `tx_fsm.png` – Transmitter FSM state diagram
- 🔂 `rx_fsm.png` – Receiver FSM state diagram

---

## 🛠 Tools Used

- Verilog HDL (Design)
- ModelSim / Vivado (Simulation)
- GTKWave (Waveform viewer)
- VS Code + Icarus Verilog (optional)

---

## 📁 How to Run

```bash
# Step 1: Compile all Verilog files
vlog *.v

# Step 2: Run simulation
vsim work.testbench_uart

# Step 3: View waveforms
add wave *
run -all
