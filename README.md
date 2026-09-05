# Wireless Power Transfer Modeling in MATLAB

A MATLAB steady-state model of a coupled-coil wireless power transfer (WPT) system using complex impedances and phasor-domain calculations.

**Technologies:** MATLAB · Circuit Modeling · Complex Impedance · Parameter Analysis · Data Visualization

## Project Overview

The model calculates compensation parameters, branch currents, input/output power, and model efficiency for a coupled-coil WPT circuit. It also explores how operating frequency and magnetic coupling affect system behavior.

## Main Functions

- Compensation-capacitance calculation.
- Primary/secondary branch-current analysis.
- Input and load-power calculation.
- Model-efficiency calculation.
- Frequency-response sweep.
- Coupling-coefficient sweep.
- Reconstructed sinusoidal waveform visualization from phasor results.

## Files

| File | Purpose |
| --- | --- |
| `WirelessPowerSystem.m` | Main model class and plotting methods |
| `main_wireless_power.m` | Runs model studies and visualizations |
| `calculate_parameters.m` | Standalone parameter calculation and workspace export |

## Run

Make the repository the MATLAB current folder and run:

```matlab
main_wireless_power
```

For direct numerical inspection:

```matlab
wpt = WirelessPowerSystem();
[P_in, P_out, efficiency_percent] = wpt.calculatePower();
```

## Engineering Scope

This is a steady-state circuit model intended for parameter analysis and visualization. The public repository does not represent a complete switching-converter, control-loop, thermal, or experimentally validated hardware implementation.

The frequency and coupling studies are useful for understanding sensitivity to operating conditions and compensation choices before higher-fidelity simulation or experimental work.

## Portfolio

See the [Engineering Portfolio](https://github.com/chengmiao2005/FPGAfinalproject/blob/main/docs/PORTFOLIO.md) for a concise overview of related projects.
