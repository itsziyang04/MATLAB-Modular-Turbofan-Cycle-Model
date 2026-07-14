function engine = load_engine(engine_name)
%LOAD_ENGINE Returns the parameters for a selected turbofan engine.
%
% Example:
%   engine = load_engine("CFM56-7B");
%
% The returned variable "engine" is a MATLAB structure.
% Individual values are accessed using dot notation:
%   engine.BPR
%   engine.FPR
%   engine.fan_diameter

% Convert the supplied name to uppercase so that the function accepts
% variations such as "cfm56-7b", "CFM56-7B", or "Cfm56-7B".
engine_name = upper(string(engine_name));

switch engine_name

    case "CFM56-7B"

        %% Engine identification
        engine.name = "CFM56-7B";

        %% Published or externally sourced engine parameters
        engine.BPR = 5.1;
        engine.OPR_published = 32.8;
        engine.fan_diameter = 1.549;      % m

        %% Assumed design-point cycle parameters
        engine.FPR = 1.6;
        engine.PR_LPC = 1.5;
        engine.PR_HPC = 13.7;
        engine.TIT_design = 1700;         % K

        %% Component efficiencies
        engine.eta_fan = 0.90;
        engine.eta_LPC = 0.88;
        engine.eta_HPC = 0.85;
        engine.eta_HPT = 0.90;
        engine.eta_LPT = 0.90;

        engine.mech_eff_HP = 0.99;
        engine.mech_eff_LP = 0.99;
        engine.eta_combustor = 0.99;
        engine.eta_nozzle_core = 0.98;
        engine.eta_nozzle_bypass = 0.98;

        %% Combustor and fuel assumptions
        engine.combustor_pressure_loss = 0.03;
        engine.LHV_fuel = 43e6;           % J/kg

        %% Thermodynamic gas properties
        engine.gamma_air = 1.4;
        engine.Cp_air = 1005;             % J/(kg K)

        engine.gamma_gas = 1.33;
        engine.Cp_gas = 1150;             % J/(kg K)

        engine.capture_Mach_points = [0.6, 0.85];
        engine.capture_ratio_points = [0.700, 0.645];
        engine.capture_scale = 1.0;

    case "V2527-A5"

        %% Engine identification
        engine.name = "V2527-A5";

        %% Published engine parameters
        engine.BPR = 4.8;
        engine.OPR_published = 27.2;
        engine.FPR = 1.6;
        engine.fan_diameter = 63.5 * 0.0254;   % 1.6129 m

        engine.thrust_cruise_published = 5200; % lbf
        engine.TSFC_cruise_published = 0.570;  % lb/(lbf hr)

        %% Assumed compressor pressure-ratio split
        engine.PR_LPC = 1.5;
        engine.PR_HPC = ...
            engine.OPR_published / ...
            (engine.FPR * engine.PR_LPC);

        %% Initial assumed design TIT
        engine.TIT_design = 1700;              % K, initial estimate

        %% Component efficiencies
        engine.eta_fan = 0.90;
        engine.eta_LPC = 0.88;
        engine.eta_HPC = 0.85;
        engine.eta_HPT = 0.90;
        engine.eta_LPT = 0.90;

        engine.mech_eff_HP = 0.99;
        engine.mech_eff_LP = 0.99;
        engine.eta_combustor = 0.99;
        engine.eta_nozzle_core = 0.98;
        engine.eta_nozzle_bypass = 0.98;

        %% Combustor and fuel assumptions
        engine.combustor_pressure_loss = 0.03;
        engine.LHV_fuel = 43e6;

        %% Gas properties
        engine.gamma_air = 1.4;
        engine.Cp_air = 1005;

        engine.gamma_gas = 1.33;
        engine.Cp_gas = 1150;

        engine.capture_Mach_points = [0.6, 0.85];
        engine.capture_ratio_points = [0.700, 0.645];
        engine.TIT_design = 1481;       % K, calibrated to published cruise TSFC
        engine.capture_scale = 0.8440;  % calibrated to published cruise thrust
    otherwise
        error('Unknown engine "%s". Available engine: CFM56-7B.', ...
            engine_name);

end
end