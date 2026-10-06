# qSVS: SystemVerilog Modeling Framework for SFQ and AQFP Circuits

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Standard: SystemVerilog](https://img.shields.io/badge/Standard-IEEE%201800--2017-00599C.svg)](https://standards.ieee.org/standard/1800-2017.html)
[![Standard: SDF](https://img.shields.io/badge/Timing-IEEE%201497--2001%20(SDF)-orange.svg)](https://standards.ieee.org/standard/1497-2001.html)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-3776ab.svg)](https://www.python.org/downloads/)
[![DOI](https://img.shields.io/badge/DOI-10.1109%2FTASC.2019.2957196-00629B.svg)](https://doi.org/10.1109/TASC.2019.2957196)

**qSVS** (Quantum Superconducting Verilog / SystemVerilog) is an open-source, modular hardware description and simulation framework for superconducting electronics. Developed under the **IARPA SuperTools** program, qSVS provides accurate digital behavioral and timing models for **Single-Flux-Quantum (SFQ)** logic, **Adiabatic Quantum-Flux-Parametron (AQFP)** logic, and **hybrid SFQ $\leftrightarrow$ AQFP** interface circuits.

- **Repository**: https://github.com/single-flux-quantum/qSVS
- **Upstream source**: https://gitlab.com/arash1902/qSVS
- **Publication**: [IEEE Transactions on Applied Superconductivity (Volume 30, Issue 2, March 2020)](https://doi.org/10.1109/TASC.2019.2957196)
- **License**: BSD 2-Clause (see [`LICENSE`](LICENSE))

---

## Table of contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Project Layout](#project-layout)
- [Library Reference](#library-reference)
  - [SFQ Library (`SFQLib/`)](#sfq-library-sfqlib)
  - [AQFP Library (`AQFPLib/`)](#aqfp-library-aqfplib)
  - [Hybrid SFQ/AQFP Interfaces (`AQFP.SFQInterfaces/`)](#hybrid-sfqaqfp-interfaces-aqfpsfqinterfaces)
- [Quick Start & Simulation](#quick-start--simulation)
  - [Prerequisites](#prerequisites)
  - [Compiling and Running Simulation](#compiling-and-running-simulation)
- [SDF Back-Annotation Workflow](#sdf-back-annotation-workflow)
- [Publication & Citation](#publication--citation)
- [Acknowledgments](#acknowledgments)
- [License](#license)

---

## Overview

Digital superconducting circuits operate using physics distinct from conventional CMOS:
1. **SFQ circuits** communicate via picosecond voltage transients ($\int V dt = \Phi_0 \approx 2.07\text{ mV}\cdot\text{ps}$). Clocked gates perform **Destructive Read-Out (DRO)**, resetting internal state upon evaluation.
2. **AQFP circuits** operate using multi-phase AC excitation currents and 3-level polarities (idle, positive flux, negative flux).
3. **Interconnect delays** (Passive Transmission Lines and Josephson Transmission Lines) are comparable to gate delays, necessitating precise **Standard Delay Format (SDF)** back-annotation.

qSVS encapsulates these physical phenomena inside standard **IEEE 1800-2017 SystemVerilog Interfaces**, bridging low-level analog solvers (WRspice, JSIM, PSCAN2) with industry-standard digital EDA toolchains (Cadence, Siemens/Mentor, Synopsys, Xilinx, and open-source simulators).

---

## Key Features

- **Pulse-Event DRO Mechanics**: Native `send()` and `receive()` tasks modeling discrete single-flux-quantum arrival, storage (`isStored`), and destructive consumption (`isReceived`).
- **4-State AQFP Logic Model**: Dedicated enumerated datatype `logicAQFP` supporting `q1` (+ current / '1'), `q0` (- current / '0'), `qZ` (idle / unexcited), and `qX` (unknown state).
- **Multi-Phase AC Clock Tracking**: Built-in clock phase evaluators tracking multi-phase sinusoidal excitation currents and DC flux bias offsets.
- **SDF Back-Annotation**: Fully compatible with IEEE 1497-2001 SDF timing checks (`$setup`, `$hold`, `IOPATH` gate delays, and `INTERCONNECT` wiring delays).
- **Hybrid Domain Bridging**: Bidirectional inductive- and SQUID-coupled converters (`SFQ2AQFP` and `AQFP2SFQ`).
- **High Scalability**: Verified on large superconducting benchmark netlists exceeding 30,000 gates with 100% digital bit-level fidelity against JSIM/SPICE.

---

## Project Layout

```text
qSVS/
├── LICENSE                        # BSD 2-Clause License
├── README.md                      # Project documentation and usage guide
├── SFQLib/
│   ├── SFQ_aux.sv                 # Core SFQ interface, timing checks, specify delay modules
│   └── SFQ_library.sv             # Standard RSFQ cell library (AND, OR, XOR, DFF, NDRO, JTL, etc.)
├── AQFPLib/
│   ├── AQFP_aux.sv                # 4-state logic definitions, AC clock phase trackers, specify helpers
│   └── AQFP_library.sv            # Standard AQFP gate library (MAJ, BUF, SPLIT, NOT, etc.)
├── AQFP.SFQInterfaces/
│   └── AQFP_SFQ_interfaces.sv     # Bidirectional SFQ-to-AQFP and AQFP-to-SFQ interface cells
└── SDFTranslation/
    ├── SDFTranslator.py           # Python utility translating standard SDF files for qSVS back-annotation
    └── Example/
        ├── KSA4_routing.sdf       # Input standard SDF routing delay file
        └── KSA4_routing_qSVS.sdf  # Translated SDF file ready for qSVS simulation
```

---

## Library Reference

### SFQ Library (`SFQLib/`)

The SFQ library utilizes the `SFQ` interface defined in [`SFQLib/SFQ_aux.sv`](SFQLib/SFQ_aux.sv):

| Module | Description | Ports / Parameters |
| :--- | :--- | :--- |
| `SFQ` | Core SystemVerilog interface | Modports `tx`, `rx`; Tasks `send()`, `receive()`; Functions `isReceived()`, `isStored()` |
| `SFQand2` | Clocked SFQ 2-input AND gate | `SFQ clkin, in1, in2, out` |
| `SFQor2` | Clocked SFQ 2-input OR gate | `SFQ clkin, in1, in2, out` |
| `SFQxor` | Clocked SFQ 2-input XOR gate | `SFQ clkin, in1, in2, out` |
| `SFQinv` | Clocked SFQ Inverter (NOT) | `SFQ clkin, in, out` |
| `SFQdff` | Destructive Read-Out D Flip-Flop | `SFQ clkin, in, out` |
| `SFQndro` | Non-Destructive Read-Out DFF | `SFQ clkin, in, set, reset, out` |
| `SFQsplit` | 1-to-2 Pulse Splitter | `SFQ in, out1, out2` |
| `SFQcb` | Confluence Buffer (Merger / OR) | `SFQ in1, in2, out` |
| `SFQjtl` | Josephson Transmission Line | `SFQ in, out` |

### AQFP Library (`AQFPLib/`)

The AQFP library uses 4-valued state logic and 4-phase AC clock tracking in [`AQFPLib/AQFP_aux.sv`](AQFPLib/AQFP_aux.sv):

| Component | Description | Values / Functions |
| :--- | :--- | :--- |
| `logicAQFP` | Enumerated 4-state data type | `q1` (Logic 1), `q0` (Logic 0), `qZ` (Idle), `qX` (Unknown) |
| `clkAQFP` | AC excitation clock interface | Tracks excitation `xio` and DC bias `dcio` |
| `AQFPclockPhase` | Phase extraction module | Computes local phase (`phase1` .. `phase4`) from current directions |
| `AQFPmaj3` | 3-input AQFP Majority gate | $Y = \text{Maj3}(A, B, C)$ |
| `AQFPbuf` | Clocked AQFP buffer / delay | Propagates data across clock phase boundaries |
| `AQFPsplit` | 1-to-2 AQFP Splitter | Fanout buffer driving downstream cells |
| `AQFPinv` | AQFP Inverter | Inverts output current polarity |

### Hybrid SFQ/AQFP Interfaces (`AQFP.SFQInterfaces/`)

Defined in [`AQFP.SFQInterfaces/AQFP_SFQ_interfaces.sv`](AQFP.SFQInterfaces/AQFP_SFQ_interfaces.sv):
* **`SFQ2AQFP`**: Accepts SFQ pulse input and AC clock `clkAQFP`, producing 4-state `ioAQFP` output via inductive SQUID coupling.
* **`AQFP2SFQ`**: Samples AQFP current polarity upon clock trigger and outputs an SFQ pulse into downstream SFQ logic.

---

## Quick Start & Simulation

### Prerequisites
* Any IEEE 1800-2017 compliant SystemVerilog simulator (e.g., **Siemens Questa / ModelSim**, **Cadence Xcelium / NCSim**, **Synopsys VCS**, **Vivado Simulator**, or **Verilator** / **Icarus Verilog**).
* Python 3.8+ (for SDF translation utilities).

### Compiling and Running Simulation

1. **Include macros in top-level testbench (for zero-delay / unannotated simulation)**:
   ```systemverilog
   `define pw     1e-3   // Arbitrary small pulse width
   `define tsetup 1.0    // Setup time (ps)
   `define thold  1.0    // Hold time (ps)
   `define tgate  5.0    // Gate propagation delay (ps)
   ```

2. **Instantiate and connect cells**:
   ```systemverilog
   `include "SFQLib/SFQ_aux.sv"
   `include "SFQLib/SFQ_library.sv"

   module tb_example;
       SFQ clk(), data_in(), data_out();

       // Instantiate a clocked D-Flip-Flop
       SFQdff dff_inst (
           .clkin(clk),
           .in(data_in),
           .out(data_out)
       );

       initial begin
           // Stimulus generation
           #10  data_in.send();
           #20  clk.send();
           #30  $finish;
       end
   endmodule
   ```

3. **Run with your simulator (e.g., ModelSim/Questa)**:
   ```bash
   vlib work
   vlog -sv SFQLib/SFQ_aux.sv SFQLib/SFQ_library.sv tb_example.sv
   vsim -c tb_example -do "run -all; quit"
   ```

---

## SDF Back-Annotation Workflow

To perform post-layout gate-level and interconnect timing simulation:

```text
[ Cadence / Synopsys Layout ] 
           │ (Standard .sdf)
           ▼
[ SDFTranslator.py ] ──► [ Translated .sdf (qSVS format) ]
                                    │
                                    ▼
           [ SystemVerilog Simulator (vsim / ncsim / vcs) + $sdf_annotate ]
```

Run the translation utility:

```bash
# For SFQ circuits (mode 0, default):
python SDFTranslation/SDFTranslator.py -m 0 path/to/circuit.sdf

# For AQFP circuits (mode 1):
python SDFTranslation/SDFTranslator.py -m 1 path/to/circuit.sdf
```

---

## Publication & Citation

If you use qSVS in your research or design workflows, please cite the original TAS publication:

```bibtex
@article{Tadros2020TAS,
  author={Tadros, Ramy N. and Fayyazi, Arash and Pedram, Massoud and Beerel, Peter A.},
  journal={IEEE Transactions on Applied Superconductivity}, 
  title={SystemVerilog Modeling of SFQ and AQFP Circuits}, 
  year={2020},
  volume={30},
  number={2},
  pages={1-13},
  doi={10.1109/TASC.2019.2957196}
}
```

---

## Acknowledgments

The development of qSVS was supported by the **Office of the Director of National Intelligence (ODNI)** and the **Intelligence Advanced Research Projects Activity (IARPA)** under the **SuperTools** program via U.S. Army Research Office (ARO) grant **W911NF-17-1-0120**, and developed at the **SPORT Lab**, University of Southern California (USC).

---

## License

This software is licensed under the **BSD 2-Clause License**. See the [`LICENSE`](LICENSE) file for full copyright and terms.
