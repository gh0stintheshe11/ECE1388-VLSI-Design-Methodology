%% Q1.1 — Plot ALL Id–Vd curves (nMOS W=32 + pMOS W=64) on one figure
% Edit filenames if needed:
nmos_csv = 'nmos32_iv.csv';
pmos_csv = 'pmos64_iv.csv';

figure('Color','w'); hold on;

% ---------- nMOS ----------
Tn   = readtable(nmos_csv,'VariableNamingRule','preserve');
cols = Tn.Properties.VariableNames;
pairs = reshape(1:numel(cols),2,[])';

for k = 1:size(pairs,1)
    xh = cols{pairs(k,1)}; yh = cols{pairs(k,2)};
    % parse bias value like "(vgs_n=0.6)" or "(vgs=0.60)"
    tok = regexp(xh,'\((?:vg[sd](?:_[np])?|vs[gd](?:_[np])?)\s*=\s*([-\d\.eE]+)\)','tokens','once');
    if isempty(tok), continue; end
    Vg = str2double(tok{1});
    V  = Tn.(xh);
    I  = Tn.(yh);
    plot(V, I, '-', 'DisplayName', sprintf('nMOS VGS=%.2f', Vg));
end

% ---------- pMOS (plot |Id| vs VSD) ----------
Tp   = readtable(pmos_csv,'VariableNamingRule','preserve');
cols = Tp.Properties.VariableNames;
pairs = reshape(1:numel(cols),2,[])';

for k = 1:size(pairs,1)
    xh = cols{pairs(k,1)}; yh = cols{pairs(k,2)};
    tok = regexp(xh,'\((?:vg[sd](?:_[np])?|vs[gd](?:_[np])?)\s*=\s*([-\d\.eE]+)\)','tokens','once');
    if isempty(tok), continue; end
    Vsg = str2double(tok{1});
    V   = Tp.(xh);
    I   = -Tp.(yh);  % flip sign → |Id|
    plot(V, I, '--', 'DisplayName', sprintf('pMOS VSG=%.2f', Vsg));
end

grid on;
xlabel('V_{D(S)} (V)'); ylabel('I_D (A)');
title('Q1.1 — Overlayed Id–V_{DS} curves (nMOS W=32, pMOS W=64)');
legend('Location','bestoutside');

% --- separate figures ---
%{
figure('Color','w'); hold on;  % nMOS only
for k = 1:size(pairs,1), plot(V, I); end % (replace with the Tn loop above)
title('nMOS — Id–VDS'); xlabel('VDS (V)'); ylabel('ID (A)'); grid on;

figure('Color','w'); hold on;  % pMOS only
for k = 1:size(pairs,1), plot(V, I); end % (replace with the Tp loop above, with I=-Tp.(yh))
title('pMOS — |Id|–VSD'); xlabel('VSD (V)'); ylabel('|ID| (A)'); grid on;
%}
