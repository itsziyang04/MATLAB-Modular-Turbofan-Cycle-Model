function [T2_stag, P2_stag, T13_stag, P13_stag, fan_work] = fan_compression(T0_stag, P0_stag, FPR, eta_fan, Cp_air, gamma_air)
% FAN_COMPRESSION - Models compression across the fan stage
%
% Inputs:
%   T0_stag  - inlet stagnation temperature (K)
%   P0_stag  - inlet stagnation pressure (Pa)
%   FPR      - fan pressure ratio (assumed 1.6 for CFM56-7B class engine)
%   eta_fan  - fan isentropic efficiency (assumed 0.90)
%   Cp_air   - specific heat of air (J/kg-K)
%   gamma_air- ratio of specific heats
%
% Outputs:
%   T2_stag, P2_stag   - core stream exit conditions (Station 2/2.5 inlet)
%   T13_stag, P13_stag - bypass stream exit conditions (Station 13)
%   fan_work           - specific work done by fan (J/kg)

% Ideal (isentropic) exit temperature
T_exit_ideal = T0_stag * (FPR)^((gamma_air-1)/gamma_air);

% Actual exit temperature, accounting for fan inefficiency
T_exit_actual = T0_stag + (T_exit_ideal - T0_stag) / eta_fan;

% Exit pressure (same for both streams, single fan stage)
P_exit = P0_stag * FPR;

% Fan work per unit mass flow
fan_work = Cp_air * (T_exit_actual - T0_stag);

% Assign outputs (core and bypass exit fan at same conditions)
T2_stag = T_exit_actual;
P2_stag = P_exit;
T13_stag = T_exit_actual;
P13_stag = P_exit;

end