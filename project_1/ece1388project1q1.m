%% ECE1388 Project 1 – NMOS & PMOS IV Characteristics
% Author: [Your Name]
% Date: [Date]
% This script loads Cadence simulation results (CSV) and compares them with
% analytical MOSFET equations.

clear; clc; close all;

%% ===== PARAMETERS (replace with values from project instructions) =====
mu_n = 300e-4;      % Electron mobility (m^2/Vs) (example, adjust per notes)
mu_p = 120e-4;      % Hole mobility (m^2/Vs) (example, adjust per notes)
Cox  = 2.3e-2;      % Oxide capacitance per unit area (F/m^2), replace!
Vth_n = 0.4;        % NMOS threshold voltage (V), replace!
Vth_p = -0.4;       % PMOS threshold voltage (V), replace!

L = 60e-9;          % Channel length (m)
Wn = 3.84e-6;       % NMOS effective width (32 fingers × 0.12um)
Wp = 7.68e-6;       % PMOS effective width (64 fingers × 0.12um)

%% ===== LOAD SIMULATION DATA =====
nmos = readmatrix('nmos_iv.csv');
pmos = readmatrix('pmos_iv.csv');

numPairs_n = size(nmos,2)/2;  % number of Vgs sweeps
numPairs_p = size(pmos,2)/2;

colors = lines(max(numPairs_n,numPairs_p));

%% ===== PLOT NMOS (Simulation) =====
figure; hold on; grid on;
for k = 1:numPairs_n
    vds = nmos(:,2*(k-1)+1);
    ids = nmos(:,2*(k-1)+2);
    plot(vds, -ids, 'LineWidth', 1.5, 'Color', colors(k,:)); % -ids flips sign
end
xlabel('V_{DS} (V)'); ylabel('I_D (A)');
title('NMOS I_D–V_{DS} (Simulation)');
legend(arrayfun(@(x) sprintf('V_{GS}=%.1f V', 0.2*(x-1)), 1:numPairs_n, 'UniformOutput', false));

%% ===== PLOT NMOS (Theory) =====
figure; hold on; grid on;
for k = 1:numPairs_n
    Vgs = 0.2*(k-1);
    Id = zeros(size(vds));
    for i = 1:length(vds)
        Vds = vds(i);
        if Vds <= (Vgs - Vth_n)
            Id(i) = mu_n*Cox*(Wn/L)*((Vgs-Vth_n)*Vds - 0.5*Vds^2);
        else
            Id(i) = 0.5*mu_n*Cox*(Wn/L)*(Vgs-Vth_n)^2;
        end
    end
    plot(vds, Id, '--', 'LineWidth', 1.5, 'Color', colors(k,:));
end
xlabel('V_{DS} (V)'); ylabel('I_D (A)');
title('NMOS I_D–V_{DS} (Analytical Model)');
legend(arrayfun(@(x) sprintf('V_{GS}=%.1f V', 0.2*(x-1)), 1:numPairs_n, 'UniformOutput', false));

%% ===== PLOT PMOS (Simulation) =====
figure; hold on; grid on;
for k = 1:numPairs_p
    vds = pmos(:,2*(k-1)+1);
    ids = pmos(:,2*(k-1)+2);
    plot(vds, -ids, 'LineWidth', 1.5, 'Color', colors(k,:)); % -ids flips sign
end
xlabel('V_{SD} (V)'); ylabel('I_D (A)');
title('PMOS I_D–V_{SD} (Simulation)');
legend(arrayfun(@(x) sprintf('V_{SG}=%.1f V', 0.2*(x-1)), 1:numPairs_p, 'UniformOutput', false));

%% ===== PLOT PMOS (Theory) =====
figure; hold on; grid on;
for k = 1:numPairs_p
    Vsg = -0.2*(k-1); % sweep in negative
    Id = zeros(size(vds));
    for i = 1:length(vds)
        Vsd = vds(i);
        if Vsd <= (Vsg - Vth_p)
            Id(i) = mu_p*Cox*(Wp/L)*((Vsg-Vth_p)*Vsd - 0.5*Vsd^2);
        else
            Id(i) = 0.5*mu_p*Cox*(Wp/L)*(Vsg-Vth_p)^2;
        end
    end
    plot(vds, -Id, '--', 'LineWidth', 1.5, 'Color', colors(k,:)); % flip sign for upward
end
xlabel('V_{SD} (V)'); ylabel('I_D (A)');
title('PMOS I_D–V_{SD} (Analytical Model)');
legend(arrayfun(@(x) sprintf('V_{SG}=%.1f V', -0.2*(x-1)), 1:numPairs_p, 'UniformOutput', false));
