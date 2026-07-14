function [T4_stag, P4_stag, fuel_air_ratio] = combustor(T3_stag, P3_stag, TIT, pressure_loss_frac, Cp_gas, LHV_fuel, eta_combustor)
% COMBUSTOR - Models fuel addition and combustion process
%
% Inputs:
%   T3_stag           - compressor exit stagnation temp (K)
%   P3_stag           - compressor exit stagnation pressure (Pa)
%   TIT               - turbine inlet temperature, target T4 (K) [ASSUMED]
%   pressure_loss_frac- fractional pressure loss across combustor (e.g. 0.03)
%   Cp_gas            - specific heat of combustion gas (J/kg-K, higher than cold air)
%   LHV_fuel          - lower heating value of fuel (J/kg)
%   eta_combustor     - combustion efficiency (typically 0.98-0.99)
%
% Outputs:
%   T4_stag        - combustor exit stagnation temp (K) = TIT
%   P4_stag        - combustor exit stagnation pressure (Pa)
%   fuel_air_ratio - fuel-to-air mass ratio (f)

% Exit temperature is simply the design TIT
T4_stag = TIT;

% Pressure drop across combustor
P4_stag = P3_stag * (1 - pressure_loss_frac);

% Energy balance to find fuel-air ratio:
% f * LHV * eta_combustor = (1+f) * Cp_gas * (T4 - T3)
% Simplified (f is small, so 1+f ~ 1 for first-pass estimate):
fuel_air_ratio = (Cp_gas * (T4_stag - T3_stag)) / (LHV_fuel * eta_combustor - Cp_gas * (T4_stag - T3_stag));

end