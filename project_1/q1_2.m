%% Q1.2 — Vt/S from Id–Vg families + DIBL + Ioff  (Wn=Wp=32 → 3.84um, L=60nm)
clear; clc;

% ==== Inputs (family CSVs exported from ViVA with "All sweeps") ====
nm_idvg = 'nmos32_vgs_id.csv';   % expect pairs like: VGS (vds_n=0.20), ID (vds_n=0.20), ...
pm_idvg = 'pmos32_vgs_id.csv';   % expect pairs like: VSG (vsd_p=0.20), ID (vsd_p=0.20), ...

% ==== Tech / extraction settings ====
L  = 60e-9;            % L not used for Vt here (absolute-current rule)
W  = 3.84e-6;          % 32 units → 3.84 µm
Vlow_req  = 0.20;      % desired low drain bias
Vhigh_req = 1.00;      % desired high drain bias
Icc_per_um = 0.1e-6;   % 0.1 µA/µm constant-current rule (textbook)
IccA = Icc_per_um * (W/1e-6);   % absolute current target in A

% ==== Analyze NMOS ====
fprintf('== nMOS (Id–Vg family) ==\n');
Rn = analyze_idvg_family(nm_idvg,IccA,Vlow_req,Vhigh_req);
disp(Rn.Table);
fprintf('NMOS: DIBL = %.1f mV/V (VDS=%.2f→%.2f), Ioff@VGS=0, VDS=%.2fV = %.3g A\n\n', ...
    Rn.DIBL_mV_per_V, Rn.Vlow_eff, Rn.Vhigh_eff, Rn.Vhigh_eff, abs(Rn.Ioff));

% ==== Analyze PMOS ====
fprintf('== pMOS (Id–Vg family) ==\n');
Rp = analyze_idvg_family(pm_idvg,IccA,Vlow_req,Vhigh_req);
disp(Rp.Table);
fprintf('PMOS: DIBL = %.1f mV/V (VSD=%.2f→%.2f), Ioff@VSG=0, VSD=%.2fV = %.3g A\n', ...
    Rp.DIBL_mV_per_V, Rp.Vlow_eff, Rp.Vhigh_eff, Rp.Vhigh_eff, abs(Rp.Ioff));


%% ======================= Helpers =======================

function R = analyze_idvg_family(csvFile, IccA, Vlow_req, Vhigh_req)
% Reads a family Id–Vg CSV (multiple VDS/VSD), computes:
%   - Vt (constant-current, absolute target IccA) vs VDS
%   - S (mV/dec) vs VDS
%   - DIBL (mV/V) between requested low/high biases (using the actual nearest)
%   - Ioff = |Id| at Vg=0 for the high-bias curve
%
% dev ∈ {'nmos','pmos'}; for pMOS we use |Id| and VSG on x, VSD as "VDS".

    T = readtable(csvFile,'VariableNamingRule','preserve');
    cols = T.Properties.VariableNames;

    % ---- Collect (VDS, Vg, Id) curves from paired columns ----
    curves = struct('Vds',{},'Vg',{},'Id',{});
    for k = 1:2:numel(cols)
        if k+1 > numel(cols), break; end
        xh = cols{k}; yh = cols{k+1};

        % try to parse a drain-bias tag from the X header "(...=value)"
        vtok = parse_vds_from_header(xh);
        if isempty(vtok), continue; end
        vds = str2double(vtok);

        % pull numeric vectors, force column shape, clip to common length
        Vg = T{:, xh};  Id = T{:, yh};
        Vg = Vg(:);  Id = Id(:);
        n  = min(numel(Vg), numel(Id));
        Vg = Vg(1:n);  Id = Id(1:n);

        % drop NaNs/Infs uniformly
        good = isfinite(Vg) & isfinite(Id);
        Vg = Vg(good);  Id = Id(good);
        if numel(Vg) < 4, continue; end

        curves(end+1) = struct('Vds',vds,'Vg',Vg,'Id',Id); %#ok<AGROW>
    end
    assert(~isempty(curves), 'No VDS-tagged sweeps found in %s', csvFile);

    % ---- Compute Vt & S per VDS ----
    VDS_list = [curves.Vds]';
    Vt = nan(size(VDS_list));
    S  = nan(size(VDS_list));
    for i = 1:numel(curves)
        [Vt(i), S(i)] = vt_S_from_vectors(curves(i).Vg, curves(i).Id, IccA);
    end

    % ---- Choose effective low/high biases and compute DIBL ----
    [~, il] = min(abs(VDS_list - Vlow_req));
    [~, ih] = min(abs(VDS_list - Vhigh_req));
    Vlow_eff  = VDS_list(il);
    Vhigh_eff = VDS_list(ih);
    DIBL_mV_per_V = 1e3 * (Vt(il) - Vt(ih)) / max(Vhigh_eff - Vlow_eff, eps);

    % ---- Ioff at Vg=0 from the high-bias curve ----
    Ioff = interp1_safe(curves(ih).Vg, curves(ih).Id, 0);

    % ---- Pretty output table (sorted by VDS) ----
    [VDS_sorted, ord] = sort(VDS_list);
    R.Table = table(VDS_sorted, Vt(ord), S(ord), ...
        'VariableNames', {'VDS','Vt','S_mVdec'});

    % ---- Return extras ----
    R.DIBL_mV_per_V = DIBL_mV_per_V;
    R.Ioff          = Ioff;
    R.Vlow_eff      = Vlow_eff;
    R.Vhigh_eff     = Vhigh_eff;
end

function tok = parse_vds_from_header(hdr)
% Extract the numeric bias value from header tokens like:
% "(vds=...)", "(vds_n=...)", "(vsd_p=...)", "(VDS=...)" etc.
    tok = [];
    % try a few common patterns
    pats = { ...
        '\((?:vd[sd](?:_[np])?|vsd_p|vds_n|VDS|VSD)\s*=\s*([-\d\.eE]+)\)', ...
        '\[(?:vd[sd](?:_[np])?|vsd_p|vds_n|VDS|VSD)\s*=\s*([-\d\.eE]+)\]', ...
    };
    for p = 1:numel(pats)
        m = regexp(hdr, pats{p}, 'tokens','once');
        if ~isempty(m), tok = m{1}; return; end
    end
end

function [Vt, S_mVdec] = vt_S_from_vectors(Vg, Id, IccA)
% Constant-current Vt using absolute current target (A), and
% subthreshold slope S (mV/dec) from a robust 1-decade window.

    Vg = Vg(:); Id = abs(Id(:));
    n  = min(numel(Vg), numel(Id));
    Vg = Vg(1:n); Id = Id(1:n);

    % === Vt (constant-current) ===
    good = isfinite(Vg) & isfinite(Id) & (Id > 0);
    Vg_c = Vg(good); Id_c = Id(good);
    [Id_s, idx] = sort(Id_c); Vg_s = Vg_c(idx);

    if isempty(Id_s)
        Vt = NaN; S_mVdec = NaN; return;
    end
    Imin = max(min(Id_s), 1e-15); Imax = max(Id_s);
    Icc_eff = IccA;
    if ~(IccA > Imin && IccA < Imax)
        % keep target inside span (~30% up the log range)
        Icc_eff = 10^(log10(Imin) + 0.3*(log10(Imax)-log10(Imin)));
    end
    Vt = interp1(Id_s, Vg_s, Icc_eff, 'linear','extrap');

    % === S (mV/dec) ===
    pos = isfinite(Id) & (Id > 0) & isfinite(Vg);
    lg = log10(Id(pos)); Vp = Vg(pos);
    if numel(lg) < 4, S_mVdec = NaN; return; end
    lo = prctile(lg, 20);
    hi = min(lo + 1.0, max(lg) - 0.05);
    win = (lg >= lo) & (lg <= hi);
    if nnz(win) < 4
        hi = min(lo + 1.5, max(lg));
        win = (lg >= lo) & (lg <= hi);
    end
    if nnz(win) < 4, S_mVdec = NaN; return; end
    p = polyfit(Vp(win), lg(win), 1);
    S_mVdec = 1e3 * (1/p(1));
end

function y0 = interp1_safe(x, y, x0)
% Safe linear interpolation/extrapolation for possibly non-monotonic x.
    x = x(:); y = y(:);
    good = isfinite(x) & isfinite(y);
    x = x(good); y = y(good);
    if numel(x) < 2
        y0 = NaN; return;
    end
    % sort by x to keep interp1 happy
    [xs, idx] = sort(x);
    ys = y(idx);
    y0 = interp1(xs, ys, x0, 'linear', 'extrap');
end



%% Q1.2 — Fit velocity-sat + CLM and overlay (nMOS & pMOS, W=32)
nmos_iv = 'nmos32_iv.csv';        % Id–VDS family (W=32)
pmos_iv = 'pmos32_vds_id.csv';    % |Id|–VSD family (W=32)

fit_overlay_device(nmos_iv, 'nmos');
fit_overlay_device(pmos_iv, 'pmos');

%% -------- helper --------
function fit_overlay_device(csvFile, dev)
    T = readtable(csvFile,'VariableNamingRule','preserve');
    cols = T.Properties.VariableNames; pairs = reshape(1:numel(cols),2,[])';

    % Collect all curves present in the file
    D = struct('Vg',{},'V',{},'I',{});
    for k = 1:size(pairs,1)
        xh = cols{pairs(k,1)}; yh = cols{pairs(k,2)};
        % parse "(vgs=...)" "(vgs_n=...)" "(vsg_p=...)" etc.
        tok = regexp(xh,'\((?:vg[sd](?:_[np])?|vs[gd](?:_[np])?)\s*=\s*([-\d\.eE]+)\)','tokens','once');
        if isempty(tok), continue; end
        Vg = str2double(tok{1});
        V  = T.(xh);
        I  = T.(yh);
        if startsWith(lower(dev),'pmos'), I = -I; end   % plot |Id| for pMOS
        D(end+1).Vg = Vg; D(end).V = V; D(end).I = I; %#ok<AGROW>
    end
    if isempty(D), error('No IV curves found in %s', csvFile); end

    % Model (shared parameters across curves):
    % I = K*(max(VG−VT,0))^alpha * (VDS/(VDS+Vsat)) * (1 + lambda*VDS)
    theta0 = [1e-3, 1.2, 0.38, 0.10, 0.05];   % [K alpha VT Vsat lambda]
    lb     = [1e-6, 0.8, 0.10, 1e-3, 0.00];
    ub     = [1e-1, 2.0, 0.80, 0.50, 0.20];
    opts   = optimoptions('lsqnonlin','Display','off','MaxIter',1000);

    res = @(th) cell2mat(arrayfun(@(s) iv_model(th,s.Vg,s.V)-s.I, D, 'uni',0));
    theta = lsqnonlin(res, theta0, lb, ub, opts);
    K=theta(1); a=theta(2); VT=theta(3); Vs=theta(4); lam=theta(5);
    fprintf('%s fit (%s): K=%.3g  alpha=%.2f  VT=%.3f  Vsat=%.3f  lambda=%.3f 1/V\n', ...
        upper(dev), csvFile, K, a, VT, Vs, lam);

    % Overlay
    figure('Color','w'); hold on;
    for k = 1:numel(D)
        plot(D(k).V, D(k).I, 'o', 'MarkerSize', 3, ...
            'DisplayName', sprintf('Sim Vg=%.2f', D(k).Vg));
        plot(D(k).V, iv_model(theta, D(k).Vg, D(k).V), '-', 'LineWidth', 1.5, ...
            'DisplayName', sprintf('Fit Vg=%.2f', D(k).Vg));
    end
    grid on;
    if startsWith(lower(dev),'pmos'), xlabel('VSD (V)'); else, xlabel('VDS (V)'); end
    ylabel('I_D (A)'); title(sprintf('%s — Sim vs Fit (W=32)', upper(dev)));
    legend('Location','bestoutside');

    function I = iv_model(th, Vg, Vd)
        K=th(1); alpha=th(2); VT=th(3); Vsat=th(4); lambda=th(5);
        Vov = max(Vg - VT, 0);
        I = K .* (Vov.^alpha) .* (Vd./(Vd+Vsat+eps)) .* (1 + lambda.*Vd);
    end
end
