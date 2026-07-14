clear;
clc;
close all;

project_folder = fileparts(mfilename('fullpath'));
addpath(fullfile(project_folder, 'functions'));

%% CFM56-7B
engine_CFM = load_engine("V2527-A5");

[thrust_CFM, TSFC_CFM, ~] = ...
    run_cycle( ...
    engine_CFM, ...
    35000, ...
    0.8, ...
    engine_CFM.TIT_design);

fprintf('--- %s ---\n', engine_CFM.name);
fprintf('Model thrust: %.2f lbf\n', thrust_CFM);
fprintf('Model TSFC: %.4f lb/(lbf hr)\n\n', TSFC_CFM);

%% V2527-A5
engine_V2500 = load_engine("V2527-A5");

[thrust_V2500, TSFC_V2500, ~] = ...
    run_cycle( ...
    engine_V2500, ...
    35000, ...
    0.8, ...
    engine_V2500.TIT_design);

fprintf('--- %s ---\n', engine_V2500.name);
fprintf('Model thrust: %.2f lbf\n', thrust_V2500);
fprintf('Published thrust: %.2f lbf\n', ...
    engine_V2500.thrust_cruise_published);

fprintf('Model TSFC: %.4f lb/(lbf hr)\n', TSFC_V2500);
fprintf('Published TSFC: %.4f lb/(lbf hr)\n', ...
    engine_V2500.TSFC_cruise_published);

%% V2527-A5 TIT investigation
TIT_test = 1450:1:1500;

thrust_test = zeros(size(TIT_test));
TSFC_test = zeros(size(TIT_test));

thrust_error = zeros(size(TIT_test));
TSFC_error = zeros(size(TIT_test));
combined_error = zeros(size(TIT_test));

for i = 1:length(TIT_test)

    [thrust_test(i), TSFC_test(i), ~] = ...
        run_cycle( ...
        engine_V2500, ...
        35000, ...
        0.8, ...
        TIT_test(i));

    thrust_error(i) = ...
        100 * ...
        (thrust_test(i) - ...
        engine_V2500.thrust_cruise_published) / ...
        engine_V2500.thrust_cruise_published;

    TSFC_error(i) = ...
        100 * ...
        (TSFC_test(i) - ...
        engine_V2500.TSFC_cruise_published) / ...
        engine_V2500.TSFC_cruise_published;

    combined_error(i) = ...
        sqrt( ...
        thrust_error(i)^2 + ...
        TSFC_error(i)^2);
end

%% Find TIT that gives the closest TSFC
TSFC_absolute_error = abs( ...
    TSFC_test - engine_V2500.TSFC_cruise_published);

[minimum_TSFC_error, best_TSFC_index] = ...
    min(TSFC_absolute_error);

best_TSFC_TIT = TIT_test(best_TSFC_index);

fprintf('\n--- TIT Selected Using TSFC ---\n');
fprintf('Selected TIT: %.0f K\n', best_TSFC_TIT);

fprintf('Model TSFC: %.4f lb/(lbf hr)\n', ...
    TSFC_test(best_TSFC_index));

fprintf('Published TSFC: %.4f lb/(lbf hr)\n', ...
    engine_V2500.TSFC_cruise_published);

fprintf('Model thrust at selected TIT: %.2f lbf\n', ...
    thrust_test(best_TSFC_index));

fprintf('Published thrust: %.2f lbf\n', ...
    engine_V2500.thrust_cruise_published);

capture_correction = ...
    engine_V2500.thrust_cruise_published / ...
    thrust_test(best_TSFC_index);

final_capture_scale = ...
    engine_V2500.capture_scale * capture_correction;

fprintf('Additional capture correction: %.4f\n', ...
    capture_correction);

fprintf('Final absolute capture scale: %.4f\n', ...
    final_capture_scale);

%% Plot the investigation
figure;

subplot(2,1,1);
plot(TIT_test, thrust_test, '-o');
yline(engine_V2500.thrust_cruise_published, '--');
xlabel('TIT (K)');
ylabel('Thrust (lbf)');
title('V2527-A5 Cruise Thrust vs TIT');
legend('Model', 'Published benchmark');
grid on;

subplot(2,1,2);
plot(TIT_test, TSFC_test, '-o');
yline(engine_V2500.TSFC_cruise_published, '--');
xlabel('TIT (K)');
ylabel('TSFC [lb/(lbf hr)]');
title('V2527-A5 Cruise TSFC vs TIT');
legend('Model', 'Published benchmark');
grid on;