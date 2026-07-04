# Offline Flyback SMPS - Custom Transformer

Bench-validated offline flyback switch-mode power supply using a custom hand-wound RM10/I transformer and a Power Integrations TNY285 TinySwitch controller.

This repository is organized for GitHub viewing: CSVs, Markdown, PDFs, and JPG images are first-class. Raw DOCX/XLSX/HEIC originals are preserved under `archive/`.

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
- Preserved original Drive-style project archive under `archive/`
- Added isolation transformer and Middlebrook injector as first-class tools

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

- `hardware/` - schematic, BOM CSVs, PCB images, and transformer files
- `validation/` - dead-bug photos, output captures, drain waveforms, and measurement CSVs
- `tools/` - isolation transformer, Middlebrook injector, and supporting scripts
- `docs/` - notes and generated indexes
- `archive/` - preserved original source files and backup copies

## Spreadsheet Format

Public folders use CSV files as the spreadsheet format because CSVs are browser-viewable, searchable, diffable, and lightweight on GitHub. Raw XLSX originals are preserved only under `archive/`.

## Safety Notice

This project involves offline mains voltage and isolated switch-mode power supply design. The files are provided for portfolio and educational documentation only. Mains-powered circuits can be lethal. Use proper isolation, fusing, grounding, probing technique, and supervision where appropriate.
