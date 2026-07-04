# MATLAB Script

Source file: `MATLAB Script.docx`

## Extracted Text

% Flyback Transformer Calculation Script

clear; clc;

%% =========================

% USER INPUTS

% ==========================

% Output

Vo      = 5.0;          % Output voltage (V)

Io      = 1.0;          % Output current (A)

Iolp    = 1.2;          % Overload output current (A), optional check

VF      = 0.7;          % Output diode forward drop (V)

% Input

Vac_min = 110;          % Minimum AC input voltage (RMS)

Vac_max = 130;          % Maximum AC input voltage (RMS)

f_ac    = 60.0;         % Line frequency (Hz)

eta     = 0.72;         % Estimated efficiency

% Switching

fsw     = 132e3;        % Switching frequency (Hz)

% Transformer / core

Ae      = 96.6e-6;      % Effective core area (m^2)  [96.6 mm^2]

le      = 36.5e-3;      % Effective magnetic path length (m)

mu_r    = 2000;         % Relative permeability of ungapped ferrite

mu_0    = 4*pi*1e-7;    % Vacuum permeability (H/m)

% Existing winding design

Lp      = 2.476e-3;     % Measured primary inductance (H)

Np      = 119;          % Primary turns

Ns      = 5;            % Secondary turns

Nvcc    = 5;            % Bias winding turns (edit as needed)

% Optional target

Bsat    = 0.35;         % Conservative ferrite saturation flux density (T)

%% =========================

% DERIVED INPUT VALUES

% ==========================

Po          = Vo * Io;                  % Output power (W)

Pin         = Po / eta;                 % Input power estimate (W)

Vdc_min_pk  = Vac_min * sqrt(2);        % Peak rectified line, no ripple model

Vdc_max_pk  = Vac_max * sqrt(2);

% For a first-pass flyback estimate, the rectified DC bus seen by the converter

% is approximated as the peak of the line.

Vbulk_min   = Vdc_min_pk;

Vbulk_max   = Vdc_max_pk;

% Turns ratios

n_sp = Ns / Np;                         % Secondary / primary

n_ps = Np / Ns;                         % Primary / secondary

% Secondary flyback voltage

Vsec_fly = Vo + VF;                     % Voltage on secondary during flyback interval

% Reflected voltage on primary

Vref_pri = n_ps * Vsec_fly;             % Critical correction

%% =========================

% DUTY CYCLE

% ==========================

% Ideal CCM/DCM boundary style estimate:

% D = Vref / (Vref + Vin)

D_min_line = Vref_pri / (Vref_pri + Vbulk_max);

D_max_line = Vref_pri / (Vref_pri + Vbulk_min);

Ton_max = D_max_line / fsw;

Ton_min = D_min_line / fsw;

%% =========================

% PRIMARY PEAK CURRENT

% ==========================

% For DCM / energy-transfer estimate:

% Pin = 0.5 * Lp * Ipk^2 * fsw

Ipk = sqrt((2 * Pin) / (Lp * fsw));

% Approximate RMS primary current in DCM triangular pulse

Iprms = Ipk * sqrt(D_max_line / 3);

% Approximate peak secondary current during flyback

Isec_pk = Ipk * n_ps;

% Approximate secondary RMS current in DCM triangular pulse

% Uses conduction fraction (1-D)

Isrms = Isec_pk * sqrt((1 - D_max_line) / 3);

%% =========================

% FLUX DENSITY SWING

% ==========================

% Correct flyback flux swing equation:

% DeltaB = (Lp * Ipk) / (Np * Ae)

DeltaB = (Lp * Ipk) / (Np * Ae);

% Peak flux from volt-seconds should match closely:

DeltaB_vs = (Vbulk_min * Ton_max) / (Np * Ae);

%% =========================

% AL VALUE

% ==========================

AL_calc = Lp / (Np^2);                  % H / turn^2

%% =========================

% AIR GAP ESTIMATE

% ==========================

% Rearranged magnetic circuit formula:

% L = N^2 / (Rm_core + Rm_gap)

% Approximation for single dominant gap:

% lg = mu0*N^2*Ae/L - le/mur

lg = ((mu_0 * Np^2 * Ae) / Lp) - (le / mu_r);  % meters

%% =========================

% AUX WINDING ESTIMATE

% ==========================

% Ideal unloaded auxiliary winding voltage during flyback

Vaux_ideal = Vsec_fly * (Nvcc / Ns);

%% =========================

% OUTPUT

% ==========================

fprintf('---Flyback Transformer Key Calculations ---\n\n');

fprintf('Output power, Po:                  %.2f W\n', Po);

fprintf('Estimated input power, Pin:        %.2f W\n\n', Pin);

fprintf('Minimum bulk DC voltage:           %.2f V\n', Vbulk_min);

fprintf('Maximum bulk DC voltage:           %.2f V\n\n', Vbulk_max);

fprintf('Turns ratio Ns/Np:                 %.5f\n', n_sp);

fprintf('Turns ratio Np/Ns:                 %.5f\n', n_ps);

fprintf('Secondary flyback voltage:         %.2f V\n', Vsec_fly);

fprintf('Reflected primary voltage:         %.2f V\n\n', Vref_pri);

fprintf('Estimated duty cycle @ low line:   %.2f %%\n', D_max_line * 100);

fprintf('Estimated duty cycle @ high line:  %.2f %%\n', D_min_line * 100);

fprintf('Maximum on-time:                   %.3f us\n\n', Ton_max * 1e6);

fprintf('Primary peak current:              %.3f A\n', Ipk);

fprintf('Primary RMS current:               %.3f A\n', Iprms);

fprintf('Secondary peak current:            %.3f A\n', Isec_pk);

fprintf('Secondary RMS current:             %.3f A\n\n', Isrms);

fprintf('Estimated DeltaB from L*I/N/Ae:    %.4f T\n', DeltaB);

fprintf('Estimated DeltaB from V*t/N/Ae:    %.4f T\n', DeltaB_vs);

fprintf('DeltaB / Bsat:                     %.1f %%\n\n', 100 * DeltaB / Bsat);

fprintf('Calculated AL value:               %.2f nH/T^2\n', AL_calc * 1e9);

fprintf('Estimated total air gap:           %.3f mm\n\n', lg * 1e3);

fprintf('Estimated ideal aux voltage:       %.2f V\n', Vaux_ideal);

%% =========================

% SANITY WARNINGS

% ==========================

fprintf('\n--- Sanity Checks ---\n');

if D_max_line > 0.5

fprintf('Warning: Duty cycle exceeds 50%% at low line.\n');

end

if DeltaB > 0.2

fprintf('Warning: DeltaB is getting high for a conservative ferrite design.\n');

end

if lg < 0

fprintf('Warning: Calculated air gap is negative. Check Ae, le, Lp, and turns.\n');

end

