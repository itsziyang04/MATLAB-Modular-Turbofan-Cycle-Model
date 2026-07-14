function [T_exit_stag, P_exit_stag, comp_work] = compressor_stage(T_in_stag, P_in_stag, PR, eta_comp, Cp_air, gamma_air)
% COMPRESSOR_STAGE - General compressor stage model (used for LPC and HPC)
%
% Inputs:
%   T_in_stag  - inlet stagnation temperature (K)
%   P_in_stag  - inlet stagnation pressure (Pa)
%   PR         - stage pressure ratio
%   eta_comp   - isentropic efficiency of this compressor stage
%   Cp_air     - specific heat of air (J/kg-K)
%   gamma_air  - ratio of specific heats
%
% Outputs:
%   T_exit_stag, P_exit_stag - exit stagnation conditions
%   comp_work                - specific work input required (J/kg)

% Ideal (isentropic) exit temperature
T_exit_ideal = T_in_stag * (PR)^((gamma_air-1)/gamma_air);

% Actual exit temperature, accounting for compressor inefficiency
T_exit_actual = T_in_stag + (T_exit_ideal - T_in_stag) / eta_comp;

% Exit pressure
P_exit_actual = P_in_stag * PR;

% Work required per unit mass flow
comp_work = Cp_air * (T_exit_actual - T_in_stag);

% Assign outputs
T_exit_stag = T_exit_actual;
P_exit_stag = P_exit_actual;

end