# Wireless Power Transfer Modeling in MATLAB

A coupled-coil wireless-power model using complex impedances and steady-state phasors. The scripts calculate compensation capacitances and branch currents, then explore frequency response and coupling changes. 无线供电稳态建模与参数扫描项目。

**Focus:** circuit modeling · complex impedance · parameter sweeps · MATLAB visualization

## Model and files

| File | Role |
| --- | --- |
| [WirelessPowerSystem.m](WirelessPowerSystem.m) | Model class: capacitances, impedances, currents, power, and plots |
| [main_wireless_power.m](main_wireless_power.m) | Runs the model and frequency/coupling studies |
| [calculate_parameters.m](calculate_parameters.m) | Standalone parameter calculation and workspace export |

The secondary branch combines its coil impedance with a parallel capacitor/load branch. The input current includes the primary compensation-capacitor current. The model calculates load power from `abs(IL)^2 * RL` and input power from the real part of voltage times conjugate input current.

| Default parameter | Value |
| --- | --- |
| Source voltage parameter | 100 V |
| Operating frequency | 100 kHz |
| Primary and secondary inductance | 100 µH each |
| Mutual inductance | 50 µH |
| Primary and secondary resistance | 0.1 Ω each |
| Load resistance | 10 Ω |

These are model inputs, not measured hardware specifications.

## Run

Download or clone the repository, make it the MATLAB current folder, and run:

```matlab
main_wireless_power
```

The script calls frequency-response plots, reconstructed sinusoidal waveforms, and a coupling-coefficient sweep. It uses MATLAB graphics features including `yyaxis` and `sgtitle`. A Simulink model is not required for this script; no `.slx` file is included.

For numerical inspection without plots:

```matlab
wpt = WirelessPowerSystem();
[P_in, P_out, efficiency_percent] = wpt.calculatePower();
```

To populate the workspace with the separate parameter script:

```matlab
calculate_parameters
```

## Interpretation and limits

- The frequency sweep keeps compensation capacitances fixed. The coupling sweep recalculates them at each coupling value, so it represents retuning.
- Time-domain curves are sinusoids reconstructed from phasors, not switching transients. The current source uses phasor magnitudes directly as waveform peaks, while its power equations correspond to an RMS convention. Resolve that convention before comparing average waveform power with the numerical power output.
- Inverter, rectifier, thermal, control-loop, and nonlinear magnetic behavior are not represented. The compensation formula is part of the coursework model and has not been verified against a physical circuit here.
- MATLAB execution and experimental validation are not claimed by this repository organization. The maintenance update fixes the efficiency-plot marker, which previously used the first return value (input power) instead of the third return value (efficiency).

[Project portfolio](https://github.com/chengmiao2005/FPGAfinalproject/blob/main/docs/PORTFOLIO.md) · [File map](docs/FILE_MAP.md)

[Validation record](docs/VALIDATION.md)
