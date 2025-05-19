%% =============================================================
%  Title: Habitat Suitability Curve Fitting  
%  Author: Francesca Padoan  
%  Institution: École Polytechnique Fédérale de Lausanne (EPFL)  
%  MATLAB Version: 2024b  
%  Date creation: 05 December 2024
%  Last update: 19 May 2025
%  Reference: Padoan et al., 2024 (River Research and Applications)  
%  -------------------------------------------------------------  
%  Objective:  
%  This MATLAB script implements mathematical models to fit  
%  habitat suitability curves published in Padoan et al. (2024).  
%  
%  The script uses water depth and flow velocity suitability tables  
%  for adult and juvenile fish life stages, applying Gaussian  
%  and Gamma distributions to derive best-fit mathematical functions.  
%
%  The fitted curves allow researchers to approximate habitat  
%  preferences based on empirical data and extend their use  
%  to environmental modeling applications.  
%  
%  -------------------------------------------------------------  
%  Usage Notes:  
%  - Ensure the required dataset files are available in the 'Data' folder.  
%  - The script is modular, allowing easy modifications for different datasets.  
%  - Users may adjust fitting parameters to optimize results.  
%
%  -------------------------------------------------------------  
%  Additional Notes:
% - The fitting has been done by using the 'Curve fitter' app. This app has
%   to be installed on matlab to run the code 
%  =============================================================
clc; 
clear; 
close all;

%% ========== Define Weights for Habitat Suitability ==========
Weight = 0.5;  % Standard weight for habitat suitability
WeightOpt = 1; % Increased weight for optimal habitat conditions

%% ==================== ADULT SECTION ==================== 
% This section fits the Habitat suitability Curves from Padoan et. al (2024) 
% for water depth (H) and flow velocity (U) data with mathematical functions. 
% The script assigns weights to various habitat conditions, distinguishing 
% between optimal and acceptable suitability areas. 
% Gaussian and Gamma distribution models are applied providing a mathematical 
% representation of habitat preference trends.

%% ==================== WATER DEPTH  ====================
% Load the water depth suitability data for adults
tab_adult_H = readtable('Data\Water depth_adult_juvenile.xlsx', 'Sheet', 'Adult', 'VariableNamingRule', 'preserve');

% Define the range of water depths based on table data
vec_adult_H = 0:0.1:max(table2array(tab_adult_H(:,2:end)), [], 'all');

% Initialize suitability vector
vec_length_vec_adult05_H = zeros(size(vec_adult_H));

% Compute suitability based on preference ranges
for i_adult = 1:length(vec_adult_H)
    for i_authors = 2:size(tab_adult_H, 1)
        % Check if depth is within the preferred range
        if vec_adult_H(i_adult) >= tab_adult_H{i_authors, 2} && vec_adult_H(i_adult) <= tab_adult_H{i_authors, 3}
            % Check if depth is within the optimal range
            if vec_adult_H(i_adult) >= tab_adult_H{i_authors, 4} && vec_adult_H(i_adult) <= tab_adult_H{i_authors, 5}
                vec_length_vec_adult05_H(i_adult) = vec_length_vec_adult05_H(i_adult) + WeightOpt;
            else
                vec_length_vec_adult05_H(i_adult) = vec_length_vec_adult05_H(i_adult) + Weight;
            end
        elseif vec_adult_H(i_adult) >= tab_adult_H{i_authors, 4} && vec_adult_H(i_adult) <= tab_adult_H{i_authors, 5}
            vec_length_vec_adult05_H(i_adult) = vec_length_vec_adult05_H(i_adult) + WeightOpt;
        end
    end
end

% Normalize suitability vector
HA_05 = vec_length_vec_adult05_H / max(vec_length_vec_adult05_H);

% ========== FIT GAMMA DISTRIBUTION ==========
% Prepare curve data
[xData, yData] = prepareCurveData(vec_adult_H, HA_05);

% Extract data points for Gaussian fitting
a1_xmin = HA_05(find(HA_05 < 0.2, 1));
a1_xmax = HA_05(find(HA_05 < 0.2, 1, 'last'));
b1_xmin = vec_adult_H(find(HA_05 > 0.95, 1));
b1_xmax = vec_adult_H(find(HA_05 > 0.95, 1, 'last'));

% Define Gaussian function type and fitting options
ft = fittype('a1*exp(-((x-b1)/c1)^2)+(1-a1)', 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.Display = 'Off';
opts.Lower = [(a1_xmax + a1_xmin) / 2, b1_xmin, -Inf];
opts.Upper = [1, b1_xmax, Inf];
opts.StartPoint = [(a1_xmax + a1_xmin) / 2, 1, 1];
opts.MaxIter = 1E5;
opts.MaxFunEvals = 1E4;
opts.TolFun = 1E-8;

% Fit the model to data
[Fit_HAnorm, gof_HAnorm] = fit(xData, yData, ft, opts);

% Define symbolic Gaussian model equation for analysis
syms Model_HAnorm(x) a1 b1 c1 x
Model_HAnorm = @(X) subs(str2sym(formula(Fit_HAnorm)), [a1, b1, c1, x], [Fit_HAnorm.a1, Fit_HAnorm.b1, Fit_HAnorm.c1, X]);

%% ==================== FLOW VELOCITY ====================
% Load the water velocity suitability data for adults
tab_adult_V = readtable('Data\Water velocity_adult_juvenile.xlsx', 'Sheet', 'Adult', 'VariableNamingRule', 'preserve');

% Define the range of flow velocities
vec_adult_V = 0:0.1:max(table2array(tab_adult_V(:,2:end)), [], 'all');

% Initialize suitability vector
vec_length_vec_adult05_V = zeros(size(vec_adult_V));

% Compute suitability based on preference ranges
for i_adult = 1:length(vec_adult_V)
    for i_authors = 2:size(tab_adult_V, 1)
        % Check if velocity is within the preferred range
        if vec_adult_V(i_adult) >= tab_adult_V{i_authors, 2} && vec_adult_V(i_adult) <= tab_adult_V{i_authors, 3}
            % Check if velocity is within the optimal range
            if vec_adult_V(i_adult) >= tab_adult_V{i_authors, 4} && vec_adult_V(i_adult) <= tab_adult_V{i_authors, 5}
                vec_length_vec_adult05_V(i_adult) = vec_length_vec_adult05_V(i_adult) + WeightOpt;
            else
                vec_length_vec_adult05_V(i_adult) = vec_length_vec_adult05_V(i_adult) + Weight;
            end
        elseif vec_adult_V(i_adult) >= tab_adult_V{i_authors, 4} && vec_adult_V(i_adult) <= tab_adult_V{i_authors, 5}
            vec_length_vec_adult05_V(i_adult) = vec_length_vec_adult05_V(i_adult) + WeightOpt;
        end
    end
end

% Normalize suitability vector
VA_05 = vec_length_vec_adult05_V / max(vec_length_vec_adult05_V);
VAmin = VA_05(VA_05 >= 0.4);
vec_adult_Vmin = vec_adult_V(VA_05 >= 0.4);

% ========== FIT GAMMA DISTRIBUTION ==========
[xData, yData] = prepareCurveData(vec_adult_Vmin, VAmin);

ft = fittype('((1-d) * (exp(1)/a)^a)*((x+e)/b)^a*exp(-(x+e)/b)+d', 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.DiffMaxChange = 0.0001;
opts.Display = 'Off';
opts.Lower = [1, 0, 0, 0];
opts.Upper = [Inf, Inf, 0.2, 50];
opts.StartPoint = [1, 1, 0.1, 10];
opts.MaxIter = 1E5;
opts.MaxFunEvals = 1E4;
opts.TolFun = 1E-8;

[Fit_VAnorm, gof_VAnorm] = fit(xData, yData, ft, opts);
syms Model_VAnorm(x) a b d e
Model_VAnorm(x) = @(X) subs(str2sym(formula(Fit_VAnorm)), [a, b, d, e], [Fit_VAnorm.a, Fit_VAnorm.b, Fit_VAnorm.d, Fit_VAnorm.e]);

%% ==================== JUVENILE SECTION ====================
% The juvenile section works in exactly the same way as the adult section.
% It applies the same logic to fit the Habitat Suitability Curves, but for a different age class.
% The structure of processing water depth (H) and flow velocity (U) remains unchanged,
% with the only difference being that it uses data specific to juvenile fish.

%% ==================== WATER DEPTH ====================

% Load the juvenile water depth suitability data
tab_juvenile_H = readtable('Data\Water depth_adult_juvenile.xlsx', 'Sheet', 'Juvenile', 'VariableNamingRule', 'preserve');

% Define the range of water depths
vec_juvenile_H = 0:0.1:max(table2array(tab_juvenile_H(:,2:end)), [], 'all');

% Initialize suitability vector
vec_length_vec_juvenile05_H = zeros(size(vec_juvenile_H));

% Compute suitability based on preference ranges
for i_juvenile = 1:length(vec_juvenile_H)
    for i_authors = 2:size(tab_juvenile_H, 1)
        % Check if depth is within the preferred range
        if vec_juvenile_H(i_juvenile) >= tab_juvenile_H{i_authors, 2} && vec_juvenile_H(i_juvenile) <= tab_juvenile_H{i_authors, 3}
            % Check if depth is within the optimal range
            if vec_juvenile_H(i_juvenile) >= tab_juvenile_H{i_authors, 4} && vec_juvenile_H(i_juvenile) <= tab_juvenile_H{i_authors, 5}
                vec_length_vec_juvenile05_H(i_juvenile) = vec_length_vec_juvenile05_H(i_juvenile) + WeightOpt;
            else
                vec_length_vec_juvenile05_H(i_juvenile) = vec_length_vec_juvenile05_H(i_juvenile) + Weight;
            end
        elseif vec_juvenile_H(i_juvenile) >= tab_juvenile_H{i_authors, 4} && vec_juvenile_H(i_juvenile) <= tab_juvenile_H{i_authors, 5}
            vec_length_vec_juvenile05_H(i_juvenile) = vec_length_vec_juvenile05_H(i_juvenile) + WeightOpt;
        end
    end
end

% Normalize suitability vector
HJ_05 = vec_length_vec_juvenile05_H / max(vec_length_vec_juvenile05_H);

% ========== FIT GAUSSIAN DISTRIBUTION ==========
% Prepare curve data
[xData, yData] = prepareCurveData(vec_juvenile_H, HJ_05);

% Extract data points for Gaussian fitting
a1_xmin = HJ_05(find(HJ_05 < 0.2, 1));
a1_xmax = HJ_05(find(HJ_05 < 0.2, 1, 'last'));
b1_xmin = vec_juvenile_H(find(HJ_05 > 0.95, 1));
b1_xmax = vec_juvenile_H(find(HJ_05 > 0.95, 1, 'last'));

% Define Gaussian function type and fitting options
ft = fittype('a1*exp(-((x-b1)/c1)^2)+(1-a1)', 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.Display = 'Off';
opts.Lower = [(a1_xmax + a1_xmin) / 2, b1_xmin, -Inf];
opts.Upper = [1, b1_xmax, Inf];
opts.StartPoint = [(a1_xmax + a1_xmin) / 2, 1, 1];
opts.MaxIter = 1E5;
opts.MaxFunEvals = 1E4;
opts.TolFun = 1E-8;

% Fit the model to data
[Fit_HJnorm, gof_HJnorm] = fit(xData, yData, ft, opts);

% Define symbolic Gaussian model equation for analysis
syms Model_HJnorm(x) a1 b1 c1 x
Model_HJnorm = @(X) subs(str2sym(formula(Fit_HJnorm)), [a1, b1, c1, x], [Fit_HJnorm.a1, Fit_HJnorm.b1, Fit_HJnorm.c1, X]);

%% ==================== FLOW VELOCITY ====================

% Load the juvenile flow velocity suitability data
tab_juvenile_V = readtable('Data\Water velocity_adult_juvenile.xlsx', 'Sheet', 'Juvenile', 'VariableNamingRule', 'preserve');

% Define the range of flow velocities
vec_juvenile_V = 0:0.1:max(table2array(tab_juvenile_V(:,2:end)), [], 'all');

% Initialize suitability vector
vec_length_vec_juvenile05_V = zeros(size(vec_juvenile_V));

% Compute suitability based on preference ranges
for i_juvenile = 1:length(vec_juvenile_V)
    for i_authors = 2:size(tab_juvenile_V, 1)
        % Check if velocity is within the preferred range
        if vec_juvenile_V(i_juvenile) >= tab_juvenile_V{i_authors, 2} && vec_juvenile_V(i_juvenile) <= tab_juvenile_V{i_authors, 3}
            % Check if velocity is within the optimal range
            if vec_juvenile_V(i_juvenile) >= tab_juvenile_V{i_authors, 4} && vec_juvenile_V(i_juvenile) <= tab_juvenile_V{i_authors, 5}
                vec_length_vec_juvenile05_V(i_juvenile) = vec_length_vec_juvenile05_V(i_juvenile) + WeightOpt;
            else
                vec_length_vec_juvenile05_V(i_juvenile) = vec_length_vec_juvenile05_V(i_juvenile) + Weight;
            end
        elseif vec_juvenile_V(i_juvenile) >= tab_juvenile_V{i_authors, 4} && vec_juvenile_V(i_juvenile) <= tab_juvenile_V{i_authors, 5}
            vec_length_vec_juvenile05_V(i_juvenile) = vec_length_vec_juvenile05_V(i_juvenile) + WeightOpt;
        end
    end
end

% Normalize suitability vector
VJ_05 = vec_length_vec_juvenile05_V / max(vec_length_vec_juvenile05_V);
VJmin = VJ_05(VJ_05 >= 0.4);
vec_juvenile_Vmin = vec_juvenile_V(VJ_05 >= 0.4);

% ========== FIT GAMMA DISTRIBUTION ==========
% Prepare curve data
[xData, yData] = prepareCurveData(vec_juvenile_Vmin, VJmin);

ft = fittype('((1-d) * (exp(1)/a)^a)*((x+e)/b)^a*exp(-(x+e)/b)+d', 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.DiffMaxChange = 0.0001;
opts.Display = 'Off';
opts.Lower = [1, 0, 0, 0];
opts.MaxFunEvals = 6000;
opts.MaxIter = 4000;
opts.StartPoint = [1, 1, 0.1, 10];
opts.Upper = [Inf, Inf, 0.1, 50];

[Fit_VJnorm, gof_VJnorm] = fit(xData, yData, ft, opts);
syms Model_VJnorm(x) a b d e
Model_VJnorm(x) = @(X) subs(str2sym(formula(Fit_VJnorm)), [a, b, d, e], [Fit_VJnorm.a, Fit_VJnorm.b, Fit_VJnorm.d, Fit_VJnorm.e]);


%% Create Maximized Figure
H = figure(1); set(H, 'WindowState', 'maximized'); clf; hold on; box on;
sgtitle('Habitat Suitability Curves for Adult and Juvenile Trout', 'Interpreter', 'latex', 'FontSize', 22);

%% Subplot: Water Depth (H) - Adults & Juveniles
subplot(2,2,1); box on; hold on;

% Plot H Adults
plot(vec_adult_H, HA_05, ':r', 'LineWidth', 1.5, 'DisplayName', 'H Adults');
fplot(Model_HAnorm, [0 max(vec_adult_H)], '-r', 'LineWidth', 2, ...
    'DisplayName', ['Fit $R^2$ = ', sprintf('%4.3f', gof_HAnorm.rsquare)]);

% Plot H Juveniles
plot(vec_juvenile_H, HJ_05, ':b', 'LineWidth', 1.5, 'DisplayName', 'H Juveniles');
fplot(Model_HJnorm, [0 max(vec_juvenile_H)], '-b', 'LineWidth', 2, ...
    'DisplayName', ['Fit $R^2$ = ', sprintf('%4.3f', gof_HJnorm.rsquare)]);

% Axis Formatting
xlim([0 max(vec_adult_H)]);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 14);
legend('Interpreter', 'latex', 'FontSize', 16, 'Location', 'northeast');
xlabel('$\mathrm{H}$ [cm]', 'Interpreter', 'latex', 'FontSize', 18);
ylabel('$\mathrm{HSI_H} [-]$', 'Interpreter', 'latex', 'FontSize', 18);

%% Subplot: Flow Velocity (U) - Adults & Juveniles
subplot(2,2,2); box on; hold on;

% **Plot U Adults**
plot(vec_adult_V, VA_05, ':r', 'LineWidth', 1.5, 'DisplayName', 'U Adults');
fplot(Model_VAnorm, [0 max(vec_adult_V)], '-r', 'LineWidth', 2, ...
    'DisplayName', ['Fit $R^2$ = ', sprintf('%4.3f', gof_VAnorm.rsquare)]);

% Plot U Juveniles
plot(vec_juvenile_V, VJ_05, ':b', 'LineWidth', 1.5, 'DisplayName', 'U Juveniles');
fplot(Model_VJnorm, [0 max(vec_juvenile_V)], '-b', 'LineWidth', 2, ...
    'DisplayName', ['Fit $R^2$ = ', sprintf('%4.3f', gof_VJnorm.rsquare)]);

% Axis Formatting
xlim([0 max(vec_juvenile_V)]);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 14);
legend('Interpreter', 'latex', 'FontSize', 16, 'Location', 'southwest');
xlabel('$\mathrm{U}$ [cm/s]', 'Interpreter', 'latex', 'FontSize', 18);
ylabel('$\mathrm{HSI_U} [-]$', 'Interpreter', 'latex', 'FontSize', 18);

%% Annotations for Subplots
annotation(H, 'textbox', [0.08 0.9 0.03 0.03], 'String', 'a)', ...
    'Interpreter', 'latex', 'FontSize', 20, 'FitBoxToText', 'off', 'EdgeColor', 'none');
annotation(H, 'textbox', [0.52 0.9 0.03 0.03], 'String', 'b)', ...
    'Interpreter', 'latex', 'FontSize', 20, 'FitBoxToText', 'off', 'EdgeColor', 'none');

%% Save image
exportgraphics(H,'Figure/Fit_H_U_Adult_Juvenile.png')
