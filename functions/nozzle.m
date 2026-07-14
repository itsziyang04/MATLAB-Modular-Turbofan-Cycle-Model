function [V_exit, T_exit, P_exit, choked] = nozzle(T_in_stag, P_in_stag, P_ambient, Cp_gas, gamma_gas, eta_nozzle)
% NOZZLE - Models expansion through a convergent nozzle, checks for choking
%
% Inputs:
%   T_in_stag   - nozzle inlet stagnation temp (K)
%   P_in_stag   - nozzle inlet stagnation pressure (Pa)
%   P_ambient   - ambient static pressure at altitude (Pa)
%   Cp_gas      - specific heat of the gas (J/kg-K)
%   gamma_gas   - ratio of specific heats
%   eta_nozzle  - nozzle efficiency (typically 0.97-0.98)
%
% Outputs:
%   V_exit  - exit velocity (m/s)
%   T_exit  - exit static temp (K)
%   P_exit  - exit static pressure (Pa) - equals P_ambient if unchoked
%   choked  - true/false, whether the nozzle is choked

% Critical pressure ratio for choking
critical_PR = (2/(gamma_gas+1))^(gamma_gas/(gamma_gas-1));
PR_available = P_ambient / P_in_stag;

if PR_available <= critical_PR
    % Nozzle is choked - exit velocity = local speed of sound
    choked = true;
    T_exit = T_in_stag * (2/(gamma_gas+1));
    P_exit = P_in_stag * critical_PR;
    V_exit = sqrt(gamma_gas * 287 * T_exit);  % 287 = specific gas constant for air, J/kg-K
else
    % Nozzle is unchoked - fully expands to ambient pressure
    choked = false;
    P_exit = P_ambient;
    T_exit_ideal = T_in_stag * (P_exit/P_in_stag)^((gamma_gas-1)/gamma_gas);
    T_exit = T_in_stag - eta_nozzle * (T_in_stag - T_exit_ideal);
    V_exit = sqrt(2 * Cp_gas * (T_in_stag - T_exit));
end

end