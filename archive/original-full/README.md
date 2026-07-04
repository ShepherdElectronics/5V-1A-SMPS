# README

Source file: `README.docx`

## Extracted Text

# Offline Flyback SMPS (Custom Transformer)

Bench-validated offline flyback switch-mode power supply using a **custom hand-wound RM10/I transformer** and a **Power Integrations TinySwitch (TNY285)** controller.

Designed and built from first principles, with emphasis on **correct magnetics design, drain-stress control, and measurement-verified operation** prior to PCB layout.

Deadbug prototype used for unrestricted probing and bring-up. Final cleanup, Middlebrook loop injection, and efficiency optimization will be performed on a **4-layer PCB**.

Input

- 120 VAC → ~170 VDC bulk

Output (bench prototype)

- Load: **22 Ohm for ~ 200 mA**

- Output voltage: **~4.94 V**

- Output ripple/noise pk-pk (deadbug): **~1.56 Vp-p**

*(50× probe, bench wiring; for ease, ripple will be reduced on PCB via gnd plane, and snubber & filter iteration)*

Transformer (measured, assembled)

- Saturation: **16% of Bmax at 5W**, estimated 48W limit

- Lm: **2.476 mH**

- Ls: **26.64 µH**

- Laux: **26.77 µH**

- Turns ratio (Np/Ns): **~9.64**

- Leakage inductance: **~53 µH**

- Coupling factor: **~0.989**

- Hi-pot: **~1.5 kVAC / 60 s**

Drain–source stress

- Drain Vp-p: **~298–308 V**

- Ringing amplitude: **~98 Vp-p**

- Ringing frequency: **~339–392 kHz**

- Peak drain voltage: **344 V (max)**

Status

- Bench validation complete

- Board assembled & currently validating

Now that I am comfortable designing medium-frequency magnetics, I will propose far more marketable work with a smaller, cheaper transformer and a final PSU that resembles a commercial 5W block. The one I designed was oversized out of personal conviction to ensure success, not sales.

