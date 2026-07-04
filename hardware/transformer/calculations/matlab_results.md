# matlab results

Source file: `matlab_results.docx`

## Extracted Text

---Flyback Transformer Key Calculations ---

Output power, Po:                          5.00 W

Estimated input power, Pin:                6.94 W

Minimum bulk DC voltage:                   155.56 V

Maximum bulk DC voltage:                   183.85 V

Worst-case DC voltage note:                185.00 V

Primary turns, Np:                         119 turns

Measured Lm:                               2.476 mH

Switching frequency:                       132.0 kHz

Turns ratio Ns/Np:                         0.04202

Turns ratio Np/Ns:                         23.80000

Secondary flyback voltage:                 5.70 V

Reflected primary voltage:                 135.66 V

Estimated duty cycle @ low line:           46.58 %

Estimated duty cycle @ high line:          42.46 %

Estimated duty cycle @ 185 VDC:            42.31 %

Target / noted Dmax:                       45.00 %

Maximum on-time @ low line:                3.529 us

Primary peak current:                      0.206 A

Primary RMS current:                       0.081 A

Secondary peak current:                    4.906 A

Secondary RMS current:                     2.070 A

Estimated DeltaB from L*I/(N*Ae):          0.0444 T

Estimated DeltaB from V*t/(N*Ae):          0.0478 T

Calculated Bmax from note formula:         0.0549 T

DeltaB / Bsat(0.35T):                      12.7 %

DeltaB / Bsat(0.40T):                      11.1 %

Bmax(note) / Bsat(0.35T):                  15.7 %

Bmax(note) / Bsat(0.40T):                  13.7 %

Target AL value:                           164.00 nH/T^2

Calculated AL value:                       174.85 nH/T^2

AL error vs target:                        6.61 %

Estimated total air gap:                   0.676 mm

Estimated ideal aux voltage:               5.70 V

Ideal MOSFET drain stress @ low line:      291.22 V

Ideal MOSFET drain stress @ high line:     319.51 V

Ideal MOSFET drain stress @ 185 VDC:       320.66 V

Note: actual peak will be higher due to leakage spike/ringing.

--- Design Summary (from Notes) ---

Primary Turns (Np):                        119

Measured Lm:                               2.476 mH

Vin worst case:                            185.0 VDC

Switching Frequency:                       132.0 kHz

Duty Cycle target (Dmax):                  0.45

Effective Core Area (Ae):                  96.6 mm^2

Core Material:                             3F3 Ferrite

Saturation Flux Density range:             0.35 to 0.40 T

Calculated Bmax (note formula):            0.0549 T

Safety Margin vs 0.35 T Bsat:              15.7 % of Bsat

Target AL:                                 164.0 nH/T^2

Calculated AL:                             174.8 nH/T^2

--- Flyback Transformer Bobbin Fit – Full Explicit Calculations ---

Given Parameters:

Bobbin winding width:                      10.00 mm

Tape thickness:                            0.025 mm

Primary wire OD (32 AWG):                  0.240 mm

Aux wire OD (34 AWG):                      0.200 mm

Secondary TIW OD:                          0.717 mm

Primary turns split:                       75T + 75T

Secondary turns for fit check:             6T

Aux turns for fit check:                   50T

Width Fit Calculations:

Primary (each half):

Turns/layer:                             41

Turns:                                   75

Layers:                                  2

Max width used:                          9.84 mm

Secondary (TIW):

Turns/layer:                             13

Turns:                                   6

Layers:                                  1

Width used:                              4.30 mm

Aux (34 AWG):

Turns/layer:                             50

Turns:                                   50

Layers:                                  1

Width used:                              10.00 mm

Radial Build Calculations (Including All Tape):

Primary half #1 (2 layers + tape):         0.505 mm

Primary-Secondary boundary tape:           0.100 mm

Secondary TIW layer:                       0.717 mm

Tape between secondary and aux:            0.025 mm

Aux layer (34 AWG, 1 layer):               0.200 mm

Tape between aux and primary:              0.025 mm

Secondary-Primary boundary tape:           0.100 mm

Primary half #2 (2 layers + tape):         0.505 mm

Total radial build:                        2.177 mm

Conclusion:

All windings fit within the 10.00 mm bobbin width.

Total radial build including all insulation is 2.177 mm.

--- Sanity Checks ---

>>

