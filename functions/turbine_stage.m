function [T_exit_stag, P_exit_stag, PR_turbine] = turbine_stage(T_in_stag, P_in_stag, work_required, eta_turbine, mech_eff, Cp_gas, gamma_gas)
% TURBINE_STAGE - Models turbine expansion, sized to meet a required work output
%
% Inputs:
%   T_in_stag      - inlet stagnation temp (K)
%   P_in_stag      - inlet stagnation pressure (Pa)
%   work_required  - work the turbine must supply to its shaft (J/kg) [from compressor(s)]
%   eta_turbine    - turbine isentropic efficiency
%   mech_eff       - mechanical efficiency of the shaft (accounts for bearing/friction losses)
%   Cp_gas         - specific heat of hot gas (J/kg-K)
%   gamma_gas      - ratio of specific heats for hot gas
%
% Outputs:
%   T_exit_stag  - turbine exit stagnation temp (K)
%   P_exit_stag  - turbine exit stagnation pressure (Pa)
%   PR_turbine   - resulting turbine pressure ratio (calculated, not assumed)

% Turbine must supply slightly more work than required, to cover mechanical losses
actual_turbine_work = work_required / mech_eff;

% Actual temperature drop across turbine (energy balance)
delta_T_actual = actual_turbine_work / Cp_gas;
T_exit_stag = T_in_stag - delta_T_actual;

% Ideal (isentropic) temperature drop, back-calculated from actual using efficiency
delta_T_ideal = delta_T_actual / eta_turbine;
T_exit_ideal = T_in_stag - delta_T_ideal;

% Turbine pressure ratio from isentropic relation
PR_turbine = (T_exit_ideal / T_in_stag)^(gamma_gas/(gamma_gas-1));

% Exit pressure
P_exit_stag = P_in_stag * PR_turbine;

end