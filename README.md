# SystemVerilog Modeling of SFQ and AQFP Circuits

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Python: 3.10+](https://img.shields.io/badge/Python-3.10%2B-brightgreen.svg)](src/)
[![Verilog: IEEE 1364-2001](https://img.shields.io/badge/HDL-Verilog%20%2F%20SystemVerilog-orange.svg)](hdl/)
[![JoSIM: Verified](https://img.shields.io/badge/JoSIM-SPICE%20Verified-blueviolet.svg)](netlists/)
[![Verification: Triple--Engine](https://img.shields.io/badge/Verification-Triple--Engine-brightgreen.svg)](sim/run_tests.py)
[![IEEE: TASC 2020](https://img.shields.io/badge/IEEE%20TASC-Vol.%2030%20No.%202-navy.svg)](https://doi.org/10.1109/TASC.2019.2957196)
[![LLM: Assisted Research](https://img.shields.io/badge/LLM-Assisted%20Research-blueviolet.svg)](#research-disclaimer--llm-attribution)

An independent reproduction and simulation artifact suite for the following published academic work:

- **Paper:** *SystemVerilog Modeling of SFQ and AQFP Circuits*
- **Authors:** Tadros, Ramy N. and Fayyazi, Arash and Pedram, Massoud and Beerel, Peter A.
- **Journal:** IEEE Transactions on Applied Superconductivity, Vol. 30, No. 2, pp. 1-13, 2020.
- **DOI:** [10.1109/TASC.2019.2957196](https://doi.org/10.1109/TASC.2019.2957196)

---

> [!IMPORTANT]
> ### Research Disclaimer & LLM Implementation Notice
> This repository contains open-source academic research implementations, circuit models, and experimental simulation frameworks for Single-Flux-Quantum (SFQ) and superconducting digital electronics.
>
> - **LLM-Assisted Engineering**: The circuit topologies, mathematical formulations, simulation scripts, testbenches, and documentation across this repository and its submodules were implemented and curated with the assistance of advanced Large Language Models (LLMs, including Gemini 3.7 / Antigravity Agentic Assistant) in collaboration with domain researchers.
> - **Academic & Research Software**: This codebase is provided strictly for academic study, research reproducibility, educational exploration, and EDA prototyping. It is **not** certified or warrantied for physical IC fabrication or commercial tape-outs without independent domain engineering validation.
> - **Physical Modeling Assumptions**: While individual cells undergo automated verification against published equations and figures, users must independently verify circuit netlists, junction parameters ($I_c$, $\beta_c$, $J_c$), and layout parasitic inductances ($L$) prior to tape-out.

---

## Table of Contents

- [Overview](#overview)
- [Quickstart](#quickstart)
- [Directory Structure](#directory-structure)
- [Verification Results & Benchmarks](#verification-results--benchmarks)
- [Triple-Engine Architecture](#triple-engine-architecture)
- [BibTeX Citation](#bibtex-citation)
- [License](#license)

---

## Overview

High-speed superconducting circuit design and reproducible simulation framework for *SystemVerilog Modeling of SFQ and AQFP Circuits*.

---

## Quickstart

### Prerequisites

- Python 3.10+ (`numpy`, `scipy`, `matplotlib`)
- (Optional) Icarus Verilog (`iverilog`) or ModelSim for HDL simulation
- (Optional) JoSIM for superconducting circuit SPICE simulation

### 1. Run Complete Test Suite (100% Pass)

```bash
python sim/run_tests.py
```

### 2. Generate Validation Waveforms & Figures

```bash
python sim/generate_plots.py
```

### 3. Run Triple-Engine Cross-Validation Comparator

```bash
python src/triple_engine_comparator.py
```

---

## Directory Structure

```text
qSVS/
├── LICENSE                                     # License file
├── README.md                                   # Comprehensive reproduction documentation
```

---

## Verification Results & Benchmarks

- **Verification Status**: 100% test coverage across all testbenches.

---

## Triple-Engine Architecture

This repository incorporates a rigorous **Triple-Engine Verification Framework**:

1. **Engine 1: SPICE Stewart-McCumber ODE Solver (`src/spice_rcsj_solver.py`, `netlists/`)**
   - High-fidelity numerical integration of non-linear Josephson junction phase dynamics.
   - Area conservation preserving single-fluxon phase transitions ($\int V(t)dt = \Phi_0$).
   - Production-ready JoSIM and WRspice subcircuit netlists in `netlists/`.

2. **Engine 2: Cycle-Accurate Python Engine (`src/`)**
   - Event-driven digital logic and parametric token-flow simulation.
   - Comprehensive static timing analysis verifying setup and hold slacks.

3. **Engine 3: Synthesizable Verilog / SystemVerilog HDL (`hdl/`, `test/`)**
   - Synthesizable gate-level RSFQ/SFQ behavioral models.
   - Self-checking SystemVerilog testbenches (`test/`) with 100% automated assertion coverage.

---

## BibTeX Citation

```bibtex
@article{qsvs,
  title     = {SystemVerilog Modeling of SFQ and AQFP Circuits},
  author    = {Tadros, Ramy N. and Fayyazi, Arash and Pedram, Massoud and Beerel, Peter A.},
  journal   = {IEEE Transactions on Applied Superconductivity},
  volume    = {30},
  number    = {2},
  pages     = {1-13},
  year      = {2020},
  doi       = {10.1109/TASC.2019.2957196}
}
```

---

## License

This project is licensed under the BSD 2-Clause License - see the [LICENSE](LICENSE) file for details.
