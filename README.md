# Modular MATLAB Turbofan Cycle Model

A station-by-station, zero-dimensional thermodynamic model for analysing
separate-flow high-bypass turbofan engines in MATLAB.

The model was developed as an independent propulsion engineering portfolio
project and applied to:

- CFM56-7B family-level configuration
- IAE V2527-A5

## Key Results

| Engine | Model Thrust | Reference Thrust | Thrust Error | Model TSFC | Reference TSFC |
|---|---:|---:|---:|---:|---:|
| CFM56-7B | 5,994.41 lbf | 5,905 lbf | +1.51% | 0.6343 | 0.671 |
| V2527-A5 | 5,200.24 lbf | 5,200 lbf | +0.005%* | 0.5700 | 0.5700* |

\*The V2527-A5 turbine inlet temperature and inlet-capture scale were
calibrated against the two published performance benchmarks. The result is
therefore a calibrated application rather than an independent validation.

## Model Features

- ISA atmospheric conditions
- Fan, LPC and HPC compression
- Combustor pressure loss and fuel-air ratio
- HPT and LPT shaft-work matching
- Core and bypass nozzle choking checks
- Momentum and pressure thrust
- TSFC calculation
- Altitude, Mach and TIT sensitivity studies
- Multiple engine definitions
- Calibration sensitivity analysis
- Station-by-station cross-engine comparison

## Model Architecture

The cycle uses the station sequence:

`0 → 2 → 13 / 2.5 → 3 → 4 → 4.5 → 5 → 8 / 18`

Engine-specific inputs are stored in `load_engine.m`, while the common
thermodynamic calculations are implemented in `run_cycle.m`.

## Repository Structure

```text
.
├── main.m
├── sweep_main.m
├── validation_main.m
├── functions/
├── results/
└── docs/
