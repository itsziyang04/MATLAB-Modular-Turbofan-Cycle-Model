clear;
clc;
close all;

%% Find project folder and add functions folder
project_folder = fileparts(mfilename('fullpath'));
addpath(fullfile(project_folder, 'functions'));

%% Load engine definition
engine = load_engine("CFM56-7B");
%% Design-point condition
design_alt = 35000;                  % ft
design_Mach = 0.8;
design_TIT = engine.TIT_design;      % 1481 K for V2527-A5

[design_thrust, design_TSFC, ~] = ...
    run_cycle(engine, design_alt, design_Mach, design_TIT);
%% Validation check
[thrust_check, TSFC_check, ~] = ...
    run_cycle(engine, 35000, 0.8, engine.TIT_design);

fprintf('--- %s Validation Check ---\n', engine.name);
fprintf('Thrust: %.2f lbf\n', thrust_check);
fprintf('TSFC: %.4f lb/(lbf hr)\n', TSFC_check);

model_OPR = engine.FPR * engine.PR_LPC * engine.PR_HPC;

fprintf('Model OPR: %.2f\n', model_OPR);
fprintf('Published OPR: %.2f\n', engine.OPR_published);

%% Sweep 1: Altitude
alt_range = 10000:2000:41000;

Mach_fixed = 0.8;
TIT_fixed = engine.TIT_design;

thrust_alt = zeros(size(alt_range));
TSFC_alt = zeros(size(alt_range));

for i = 1:length(alt_range)

    [thrust_alt(i), TSFC_alt(i), ~] = ...
        run_cycle( ...
            engine, ...
            alt_range(i), ...
            Mach_fixed, ...
            TIT_fixed);

end

figure;

%% Thrust vs altitude
subplot(2,1,1);

plot(alt_range, thrust_alt, '-o', ...
    'DisplayName', 'Model sweep');

hold on;

plot(design_alt, design_thrust, 'p', ...
    'MarkerSize', 12, ...
    'MarkerFaceColor', 'r', ...
    'MarkerEdgeColor', 'r', ...
    'DisplayName', 'Design point');

xlabel('Altitude (ft)');
ylabel('Thrust (lbf)');
title('Thrust vs Altitude');

xticks(10000:5000:40000);
xtickformat('%,.0f');

legend('Location', 'best');
grid on;
hold off;

%% TSFC vs altitude
subplot(2,1,2);

plot(alt_range, TSFC_alt, '-o', ...
    'DisplayName', 'Model sweep');

hold on;

plot(design_alt, design_TSFC, 'p', ...
    'MarkerSize', 12, ...
    'MarkerFaceColor', 'r', ...
    'MarkerEdgeColor', 'r', ...
    'DisplayName', 'Design point');

xlabel('Altitude (ft)');
ylabel('TSFC [lb/(lbf hr)]');
title('TSFC vs Altitude');

xticks(10000:5000:40000);
xtickformat('%,.0f');

legend('Location', 'best');
grid on;
hold off;

%% Sweep 2: Mach number
Mach_range = 0.5:0.05:0.85;
alt_fixed = 35000;

thrust_mach = zeros(size(Mach_range));
TSFC_mach = zeros(size(Mach_range));

for i = 1:length(Mach_range)

    [thrust_mach(i), TSFC_mach(i), ~] = ...
        run_cycle( ...
            engine, ...
            alt_fixed, ...
            Mach_range(i), ...
            TIT_fixed);

end

figure;

%% Thrust vs Mach
subplot(2,1,1);

plot(Mach_range, thrust_mach, '-o', ...
    'DisplayName', 'Model sweep');

hold on;

plot(design_Mach, design_thrust, 'p', ...
    'MarkerSize', 12, ...
    'MarkerFaceColor', 'r', ...
    'MarkerEdgeColor', 'r', ...
    'DisplayName', 'Design point');

xlabel('Mach number');
ylabel('Thrust (lbf)');
title('Thrust vs Mach Number');

legend('Location', 'best');
grid on;
hold off;

%% TSFC vs Mach
subplot(2,1,2);

plot(Mach_range, TSFC_mach, '-o', ...
    'DisplayName', 'Model sweep');

hold on;

plot(design_Mach, design_TSFC, 'p', ...
    'MarkerSize', 12, ...
    'MarkerFaceColor', 'r', ...
    'MarkerEdgeColor', 'r', ...
    'DisplayName', 'Design point');

xlabel('Mach number');
ylabel('TSFC [lb/(lbf hr)]');
title('TSFC vs Mach Number');

legend('Location', 'best');
grid on;
hold off;

%% Sweep 3: Turbine inlet temperature
TIT_range = 1400:50:1750;

thrust_TIT = zeros(size(TIT_range));
TSFC_TIT = zeros(size(TIT_range));

for i = 1:length(TIT_range)

    [thrust_TIT(i), TSFC_TIT(i), ~] = ...
        run_cycle( ...
            engine, ...
            alt_fixed, ...
            Mach_fixed, ...
            TIT_range(i));

end

figure;

%% Thrust vs TIT
subplot(2,1,1);

plot(TIT_range, thrust_TIT, '-o', ...
    'DisplayName', 'Model sweep');

hold on;

plot(design_TIT, design_thrust, 'p', ...
    'MarkerSize', 12, ...
    'MarkerFaceColor', 'r', ...
    'MarkerEdgeColor', 'r', ...
    'DisplayName', 'Design point');

xlabel('TIT (K)');
ylabel('Thrust (lbf)');
title('Thrust vs Turbine Inlet Temperature');

legend('Location', 'best');
grid on;
hold off;

%% TSFC vs TIT
subplot(2,1,2);

plot(TIT_range, TSFC_TIT, '-o', ...
    'DisplayName', 'Model sweep');

hold on;

plot(design_TIT, design_TSFC, 'p', ...
    'MarkerSize', 12, ...
    'MarkerFaceColor', 'r', ...
    'MarkerEdgeColor', 'r', ...
    'DisplayName', 'Design point');

xlabel('TIT (K)');
ylabel('TSFC [lb/(lbf hr)]');
title('TSFC vs Turbine Inlet Temperature');

legend('Location', 'best');
grid on;
hold off;