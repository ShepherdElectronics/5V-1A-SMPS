# Offline Flyback SMPS - Custom Transformer

Bench-validated offline flyback switch-mode power supply using a custom hand-wound RM10/I transformer and a Power Integrations TNY285 TinySwitch controller.

This project documents the design, prototyping, measurement, and PCB transition of an isolated 120 VAC to 5 V flyback supply.

## Bench Validation Images

### Dead-bug Prototype

![Dead-bug flyback prototype](validation/deadbug-images/deadbug_annotated.jpg)

### Output Waveform

![Output waveform under load](validation/output-waveforms/output_4p94v_22ohm_load.jpg)

### Drain Waveform

![Drain waveform](validation/drain-waveforms/drain_stress_waveform.jpg)

## Project Highlights

- Designed and hand-wound custom RM10/I flyback transformer
- Built and debugged offline flyback prototype from first principles
- Verified about 4.94 V output under a 22 ohm load
- Measured transformer magnetics, leakage, coupling, and drain stress
- Captured drain waveform behavior and output waveform behavior
- Created PCB schematic, BOM, assembly order, and validation artifacts
- Preserved original Drive-style project archive under archive/

## Electrical Summary

| Item | Value |
|---|---:|
| Input | 120 VAC nominal |
| Bulk bus | about 170 VDC |
| Controller | Power Integrations TNY285PG |
| Transformer | Custom hand-wound RM10/I |
| Bench load | 22 ohm |
| Bench output | about 4.94 V |
| Bench output current | about 200 mA |
| Dead-bug ripple/noise | about 1.56 Vp-p |
| Peak drain voltage observed | about 344 V max |

## Viewable Asset Indexes

- [CSV file index](docs/csv_exports_index.md)
- [Image index](docs/image_index.md)
- [Full file index](docs/full_file_index.md)

## Repository Structure

- hardware/ - schematic, BOM, PCB images, and transformer design files
- validation/ - dead-bug photos, output captures, and drain waveform evidence
- tools/ - Middlebrook injector and supporting scripts
- docs/ - notes, indexes, and generated summaries
- archive/ - preserved original root files and original full source tree

## Safety Notice

This project involves offline mains voltage and isolated switch-mode power supply design. The files are provided for portfolio and educational documentation only. Mains-powered circuits can be lethal. Use proper isolation, fusing, grounding, probing technique, and supervision where appropriate.

## Spreadsheet Format

Public folders use CSV files as the primary spreadsheet format because CSVs are browser-viewable, diffable, searchable, and lightweight on GitHub. Raw XLSX originals are preserved under rchive/ for traceability.

