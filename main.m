%% main.m - Turbofan Cycle Model - Station 0 Setup
clear; clc;

%% Design point selection: bucket cruise condition
alt_ft = 35000;              % cruise altitude, ft
alt_m = alt_ft * 0.3048;     % convert to meters
Mach = 0.8;                  % cruise Mach number

%% Get atmospheric properties at altitude using Aerospace Toolbox
[T0, a0, P0, rho0] = atmosisa(alt_m);
% T0 = static temperature (K)
% a0 = speed of sound (m/s)
% P0 = static pressure (Pa)
% rho0 = density (kg/m^3)

%% Freestream velocity and stagnation conditions
V0 = Mach * a0;              % freestream velocity, m/s

gamma_air = 1.4;             % ratio of specific heats, cold air
Cp_air = 1005;                % J/(kg-K), cold air

% Stagnation temperature and pressure (isentropic relations)
T0_stag = T0 * (1 + (gamma_air-1)/2 * Mach^2);
P0_stag = P0 * (1 + (gamma_air-1)/2 * Mach^2)^(gamma_air/(gamma_air-1));

%% Display results
fprintf('--- Station 0: Freestream Conditions ---\n');
fprintf('Altitude: %.0f ft (%.0f m)\n', alt_ft, alt_m);
fprintf('Mach: %.2f\n', Mach);
fprintf('Static Temp: %.2f K\n', T0);
fprintf('Static Pressure: %.2f Pa\n', P0);
fprintf('Stagnation Temp: %.2f K\n', T0_stag);
fprintf('Stagnation Pressure: %.2f Pa\n', P0_stag);
fprintf('Freestream Velocity: %.2f m/s\n', V0);

%% Station 2/13: Fan Compression
FPR = 1.6;          % Fan pressure ratio (assumed, CFM56-7B class)
eta_fan = 0.90;      % Fan isentropic efficiency (assumed)

[T2_stag, P2_stag, T13_stag, P13_stag, fan_work] = ...
    fan_compression(T0_stag, P0_stag, FPR, eta_fan, Cp_air, gamma_air);

fprintf('\n--- Station 2/13: Fan Exit Conditions ---\n');
fprintf('Fan Pressure Ratio: %.2f\n', FPR);
fprintf('Core/Bypass Stagnation Temp: %.2f K\n', T2_stag);
fprintf('Core/Bypass Stagnation Pressure: %.2f Pa\n', P2_stag);
fprintf('Fan Specific Work: %.2f J/kg\n', fan_work);

%% Station 2.5: Low Pressure Compressor (LPC)
PR_LPC = 1.5;         % LPC pressure ratio (assumed)
eta_LPC = 0.88;        % LPC isentropic efficiency (assumed)

[T25_stag, P25_stag, LPC_work] = ...
    compressor_stage(T2_stag, P2_stag, PR_LPC, eta_LPC, Cp_air, gamma_air);

fprintf('\n--- Station 2.5: LPC Exit Conditions ---\n');
fprintf('LPC Pressure Ratio: %.2f\n', PR_LPC);
fprintf('LPC Exit Stagnation Temp: %.2f K\n', T25_stag);
fprintf('LPC Exit Stagnation Pressure: %.2f Pa\n', P25_stag);
fprintf('LPC Specific Work: %.2f J/kg\n', LPC_work);

%% Station 3: High Pressure Compressor (HPC)
PR_HPC = 13.7;         % HPC pressure ratio (assumed, to hit OPR = 32.8 total)
eta_HPC = 0.85;         % HPC isentropic efficiency (assumed, slightly lower - more stages/complexity)

[T3_stag, P3_stag, HPC_work] = ...
    compressor_stage(T25_stag, P25_stag, PR_HPC, eta_HPC, Cp_air, gamma_air);

fprintf('\n--- Station 3: HPC Exit Conditions ---\n');
fprintf('HPC Pressure Ratio: %.2f\n', PR_HPC);
fprintf('HPC Exit Stagnation Temp: %.2f K\n', T3_stag);
fprintf('HPC Exit Stagnation Pressure: %.2f Pa\n', P3_stag);
fprintf('HPC Specific Work: %.2f J/kg\n', HPC_work);

%% Sanity check: total OPR achieved
OPR_achieved = P3_stag / P0_stag;
fprintf('\n--- Overall Pressure Ratio Check ---\n');
fprintf('Target OPR (published): 32.80\n');
fprintf('Achieved OPR (model): %.2f\n', OPR_achieved);
%% Station 4: Combustor
TIT = 1700;                  % Turbine inlet temp (K) [ASSUMED - not published for CFM56-7B]
pressure_loss_frac = 0.03;   % 3% pressure loss (typical)
Cp_gas = 1150;                % J/(kg-K), hot combustion gas (higher than cold air)
LHV_fuel = 43e6;              % J/kg, Jet-A lower heating value
eta_combustor = 0.99;         % combustion efficiency

[T4_stag, P4_stag, f] = ...
    combustor(T3_stag, P3_stag, TIT, pressure_loss_frac, Cp_gas, LHV_fuel, eta_combustor);

fprintf('\n--- Station 4: Combustor Exit Conditions ---\n');
fprintf('Turbine Inlet Temp (assumed TIT): %.2f K\n', T4_stag);
fprintf('Combustor Exit Pressure: %.2f Pa\n', P4_stag);
fprintf('Fuel-Air Ratio: %.5f\n', f);
%% Station 4.5: High Pressure Turbine (HPT) - drives HPC
eta_HPT = 0.90;        % HPT isentropic efficiency (assumed)
mech_eff_HP = 0.99;     % HP shaft mechanical efficiency (assumed)
gamma_gas = 1.33;       % ratio of specific heats, hot combustion gas (lower than cold air)

[T45_stag, P45_stag, PR_HPT] = ...
    turbine_stage(T4_stag, P4_stag, HPC_work, eta_HPT, mech_eff_HP, Cp_gas, gamma_gas);

fprintf('\n--- Station 4.5: HPT Exit Conditions ---\n');
fprintf('HPT Pressure Ratio (calculated): %.4f\n', PR_HPT);
fprintf('HPT Exit Stagnation Temp: %.2f K\n', T45_stag);
fprintf('HPT Exit Stagnation Pressure: %.2f Pa\n', P45_stag);

%% Station 5: Low Pressure Turbine (LPT) - drives LPC + Fan
eta_LPT = 0.90;         % LPT isentropic efficiency (assumed)
mech_eff_LP = 0.99;      % LP shaft mechanical efficiency (assumed)

LPT_work_required = LPC_work + fan_work;   % LPT must drive both LPC and Fan

[T5_stag, P5_stag, PR_LPT] = ...
    turbine_stage(T45_stag, P45_stag, LPT_work_required, eta_LPT, mech_eff_LP, Cp_gas, gamma_gas);

fprintf('\n--- Station 5: LPT Exit Conditions ---\n');
fprintf('LPT Pressure Ratio (calculated): %.4f\n', PR_LPT);
fprintf('LPT Exit Stagnation Temp: %.2f K\n', T5_stag);
fprintf('LPT Exit Stagnation Pressure: %.2f Pa\n', P5_stag);
%% Core Nozzle (Station 8) - uses LPT exit gas
eta_nozzle_core = 0.98;

[V8, T8, P8, choked_core] = ...
    nozzle(T5_stag, P5_stag, P0, Cp_gas, gamma_gas, eta_nozzle_core);

fprintf('\n--- Core Nozzle (Station 8) ---\n');
fprintf('Choked?: %d\n', choked_core);
fprintf('Exit Velocity: %.2f m/s\n', V8);
fprintf('Exit Temp: %.2f K\n', T8);
fprintf('Exit Pressure: %.2f Pa\n', P8);

%% Bypass Nozzle (Station 18) - uses fan bypass air (Station 13)
eta_nozzle_bypass = 0.98;
gamma_air_hot = 1.4;   % bypass air is cold, use cold-air gamma/Cp, not combustion gas

[V18, T18, P18, choked_bypass] = ...
    nozzle(T13_stag, P13_stag, P0, Cp_air, gamma_air_hot, eta_nozzle_bypass);

fprintf('\n--- Bypass Nozzle (Station 18) ---\n');
fprintf('Choked?: %d\n', choked_bypass);
fprintf('Exit Velocity: %.2f m/s\n', V18);
fprintf('Exit Temp: %.2f K\n', T18);
fprintf('Exit Pressure: %.2f Pa\n', P18);
%% Thrust and TSFC Calculation
BPR = 5.1;                  % published bypass ratio
fan_diameter = 1.549;       % m, published CFM56-7B fan diameter (61 in)

% Mass flow - Mach-dependent inlet capture ratio [cited: NASA TN, 0.700 at M0.6 to 0.645 at M0.85]
inlet_mass_flow_ratio = interp1([0.6, 0.85], [0.700, 0.645], Mach, 'linear', 'extrap');
A_fan = pi/4 * fan_diameter^2;
mdot_total = inlet_mass_flow_ratio * rho0 * A_fan * V0;
mdot_core = mdot_total / (1 + BPR);
mdot_bypass = mdot_total * BPR / (1 + BPR);
mdot_fuel = mdot_core * f;

% Thrust - momentum + pressure terms (accounts for choked nozzles)
F_core_mom = (mdot_core + mdot_fuel) * V8 - mdot_core * V0;
F_bypass_mom = mdot_bypass * V18 - mdot_bypass * V0;

rho8 = P8 / (287 * T8);
A8 = (mdot_core + mdot_fuel) / (rho8 * V8);
F_pressure_core = (P8 - P0) * A8;

rho18 = P18 / (287 * T18);
A18 = mdot_bypass / (rho18 * V18);
F_pressure_bypass = (P18 - P0) * A18;

F_total = F_core_mom + F_pressure_core + F_bypass_mom + F_pressure_bypass;

% TSFC
F_total_lbf = F_total * 0.2248;
mdot_fuel_lbhr = mdot_fuel * 3600 * 2.2046;
TSFC = mdot_fuel_lbhr / F_total_lbf;

fprintf('\n--- Thrust and TSFC Results ---\n');
fprintf('Core Mass Flow: %.2f kg/s\n', mdot_core);
fprintf('Bypass Mass Flow: %.2f kg/s\n', mdot_bypass);
fprintf('Fuel Mass Flow: %.4f kg/s\n', mdot_fuel);
fprintf('Total Thrust: %.2f N (%.2f lbf)\n', F_total, F_total_lbf);
fprintf('TSFC: %.4f lb/(lbf-hr)\n', TSFC);