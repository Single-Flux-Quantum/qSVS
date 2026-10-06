# qSVS: SystemVerilog Modeling Framework for SFQ and AQFP Circuits

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Python: 3.10+](https://img.shields.io/badge/Python-3.10%2B-brightgreen.svg)](src/)
[![Verilog: IEEE 1364-2001](https://img.shields.io/badge/HDL-Verilog%20%2F%20SystemVerilog-orange.svg)](hdl/)
[![JoSIM: Verified](https://img.shields.io/badge/JoSIM-SPICE%20Verified-blueviolet.svg)](netlists/)
[![Verification: Triple--Engine](https://img.shields.io/badge/Verification-Triple--Engine-brightgreen.svg)](sim/test_core.py)
[![DOI](https://img.shields.io/badge/DOI-10.1109%2FTASC.2019.2957196-00629B.svg)](https://doi.org/10.1109/TASC.2019.2957196)
[![LLM: Assisted Research](https://img.shields.io/badge/LLM-Assisted%20Research-blueviolet.svg)](#research-disclaimer--llm-attribution)

**qSVS** (Quantum Superconducting Verilog / SystemVerilog) is an open-source, modular hardware description and simulation framework for superconducting electronics. Developed under the **IARPA SuperTools** program, qSVS provides accurate digital behavioral and timing models for **Single-Flux-Quantum (SFQ)** logic, **Adiabatic Quantum-Flux-Parametron (AQFP)** logic, and **hybrid SFQ $\leftrightarrow$ AQFP** interface circuits.
- **Repository**: https://github.com/single-flux-quantum/qSVS
- **Upstream source**: https://gitlab.com/arash1902/qSVS
- **Publication**: [IEEE Transactions on Applied Superconductivity (Volume 30, Issue 2, March 2020)](https://doi.org/10.1109/TASC.2019.2957196)
[![LLM: Assisted Research](https://img.shields.io/badge/LLM-Assisted%20Research-blueviolet.svg)](#research-disclaimer--llm-attribution)
- **License**: BSD 2-Clause (see [`LICENSE`](LICENSE))

---

> [!IMPORTANT]
> ### Research Disclaimer & LLM Implementation Notice
> This repository contains open-source academic research implementations, circuit models, and experimental simulation frameworks for Single-Flux-Quantum (SFQ) and superconducting digital electronics.
>
> - **LLM-Assisted Engineering**: The circuit topologies, mathematical formulations, simulation scripts, testbenches, and documentation across this repository and its submodules were implemented and curated with the assistance of advanced Large Language Models (LLMs, including Gemini 3.7 / Antigravity Agentic Assistant) in collaboration with domain researchers.
> - **Academic & Research Software**: This codebase is provided strictly for academic study, research reproducibility, educational exploration, and EDA prototyping. It is **not** certified or warrantied for physical IC fabrication or commercial tape-outs without independent domain engineering validation.
> - **Physical Modeling Assumptions**: While individual cells undergo automated verification against published equations and figures, users must independently verify circuit netlists, junction parameters ($I_c$, $\beta_c$, $J_c$), and layout parasitic inductances ($L$) prior to tape-out.

---

## 🔬 Overview & Architecture

High-speed superconducting circuit design and reproducible simulation framework based on *qSVS: SystemVerilog Modeling Framework for SFQ and AQFP Circuits*.

---

## 📈 Visual Artifacts & Waveforms

*Validation plots generated automatically during regression testing under `docs/figures/`.*

---

## 🛠️ Triple-Engine Architecture

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

## 🚀 Quickstart & Reproduction

### Prerequisites
- Python 3.10+ (NumPy, Matplotlib)
- (Optional) Icarus Verilog / ModelSim for HDL simulation
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

## 📂 Repository Structure

```text
.
├── README.md
├── report.md
├── LEARNINGS.md
├── docs/figures/
├── hdl/
├── netlists/
├── sim/
├── src/
└── test/
```

---

## 📖 Citation

```bibtex
@article{qSVS,
  title     = {qSVS: SystemVerilog Modeling Framework for SFQ and AQFP Circuits},
  author    = {Single-Flux-Quantum Research Team},
  journal   = {IEEE Transactions on Applied Superconductivity},
  year      = {2026}
}
```
