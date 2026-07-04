# Build guide

Source file: `Build guide.docx`

## Extracted Text

Middlebrook Loop Injection Box – Detailed Build Guide

This document describes how to build a reusable Middlebrook loop-injection box for control-loop measurement of SMPS and analog feedback systems. The box allows injection of a small AC signal into a feedback loop and measurement of loop gain using two oscilloscope channels.

Bill of Materials (BOM)

Qty | Item | Manufacturer | Part Number | Purpose
1 | RF Transformer | Mini‑Circuits | T‑626‑KK81+ | Injection isolation transformer
1 | Fixed Attenuator | Mini‑Circuits | HAT‑20A+ | Limits generator signal amplitude
1 | Precision Resistor | Yageo | 49.9 Ω 1% | Injection resistor
1 | Optional Resistor | Vishay | 100 Ω | Alternate injection resistor
3 | Panel BNC Connectors | Amphenol RF | 31‑221‑RFX | Signal connectors
1 | Aluminum Enclosure | Hammond | 1590B | Shielded housing
1 | Hook‑up Wire | CNC Tech | 22 AWG | Internal wiring
1 | Proto Board (optional) | Generic | — | Mount transformer and resistor
4 | Machine Screws | Generic | 4‑40 | Mount hardware

System Overview

The injector inserts a small AC signal into a feedback loop while the system is operating. Two oscilloscope channels measure the voltage on both sides of the injection resistor. The loop gain is calculated using:T(jω) = − V2 / V1

Front Panel Layout

Install three BNC connectors on the front panel labeled:INJECT – Function generator inputV1 – Oscilloscope Channel 1V2 – Oscilloscope Channel 2

Internal Circuit

Signal path:Function Generator → Attenuator → Transformer Primary → Transformer Secondary → Injection Resistor → Loop Break Point

Detailed Assembly Steps

1. Mark the enclosure front panel and drill three holes for BNC connectors spaced ~1.25 inches apart.

2. Install the three BNC connectors and tighten mounting nuts securely.

3. Mount the RF transformer on a small proto board to prevent lead fatigue.

4. Connect the center pin of the INJECT BNC to the input of the 20 dB attenuator.

5. Connect the attenuator output to one primary winding of the RF transformer.

6. Connect the other side of the transformer primary to ground (BNC shield).

7. Connect one transformer secondary lead to the 49.9 Ω injection resistor.

8. The other side of the resistor becomes the loop injection node (connects to DUT feedback loop).

9. Wire the V1 BNC center pin to the transformer side of the resistor.

10. Wire the V2 BNC center pin to the DUT side of the resistor.

11. Connect all BNC shields together and bond them to the metal enclosure.

12. Verify continuity with a multimeter before closing the enclosure.

Typical Measurement Procedure

1. Break the feedback loop at the error amplifier output.2. Insert the injector box at the break point.3. Connect the function generator to INJECT.4. Connect oscilloscope CH1 to V1 and CH2 to V2.5. Set generator amplitude to 10–50 mVpp.6. Sweep frequency from 10 Hz to ~300 kHz.7. Compute loop gain using −V2/V1.

Safety Notes

Only use this injector on low‑voltage control loops.Do NOT inject signals into high‑voltage nodes such as primary MOSFET drain or DC bus.Always use isolated probes when working on offline power supplies.

