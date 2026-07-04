# FINAL_ALL_IN_ONE_REBUILD_NO_HANG.ps1
# Run from anywhere.
#
# This is the actual final all-in-one rebuild script.
# It:
#   1) Copies the full original project from Downloads into C:\Git\5V-1A SMPS
#   2) Preserves the full original Appendix tree under archive/original-appendix
#   3) Preserves loose root files under archive/original-root
#   4) Rebuilds the clean hardware/validation/tools/docs structure
#   5) Exports XLSX -> CSV using Python stdlib only. NO EXCEL COM. NO HANG.
#   6) Builds docs/csv_exports_index.md and docs/image_index.md
#   7) Rewrites README.md with image embeds and index links
#
# It deletes nothing.
#
# Run:
# powershell -ExecutionPolicy Bypass -File .\FINAL_ALL_IN_ONE_REBUILD_NO_HANG.ps1

$ErrorActionPreference = "Continue"

$SourceRoot = "C:\Users\Jonathan\Downloads\5V-1A SMPS -20260704T141105Z-3-001\5V-1A SMPS"
$RepoRoot   = "C:\Git\5V-1A SMPS"

Write-Host ""
Write-Host "FINAL ALL-IN-ONE SMPS REBUILD - NO HANG" -ForegroundColor Cyan
Write-Host "Source: $SourceRoot" -ForegroundColor Cyan
Write-Host "Repo:   $RepoRoot" -ForegroundColor Cyan
Write-Host "Copy-only. No deletions. No Excel COM." -ForegroundColor Cyan
Write-Host ""

function New-Folder {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
        Write-Host "Created: $Path"
    }
}

function Copy-FileIfExists {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (Test-Path -LiteralPath $Source) {
        $destDir = Split-Path -Path $Destination -Parent
        if ($destDir) { New-Folder $destDir }
        Copy-Item -LiteralPath $Source -Destination $Destination -Force
        Write-Host "Copied: $Source -> $Destination" -ForegroundColor Green
    }
    else {
        Write-Host "Skipped file, not found: $Source" -ForegroundColor DarkYellow
    }
}

function Copy-DirContentsIfExists {
    param(
        [string]$SourceDir,
        [string]$DestinationDir
    )

    if (Test-Path -LiteralPath $SourceDir) {
        New-Folder $DestinationDir
        Copy-Item -LiteralPath (Join-Path $SourceDir "*") -Destination $DestinationDir -Recurse -Force
        Write-Host "Copied directory contents: $SourceDir -> $DestinationDir" -ForegroundColor Green
    }
    else {
        Write-Host "Skipped directory, not found: $SourceDir" -ForegroundColor DarkYellow
    }
}

function Write-TextFile {
    param(
        [string]$Path,
        [string[]]$Lines
    )

    $dir = Split-Path -Path $Path -Parent
    if ($dir) { New-Folder $dir }
    $Lines | Set-Content -Path $Path -Encoding UTF8
    Write-Host "Wrote: $Path" -ForegroundColor Green
}

function Get-PythonCommand {
    $py = Get-Command py -ErrorAction SilentlyContinue
    if ($null -ne $py) { return "py" }

    $python = Get-Command python -ErrorAction SilentlyContinue
    if ($null -ne $python) { return "python" }

    return $null
}

function Sanitize-FileName {
    param([string]$Name)
    $clean = $Name -replace '[\\\/\:\*\?\"\<\>\|]', '_'
    $clean = $clean -replace '\s+', '_'
    return $clean
}

# Validate source
if (-not (Test-Path -LiteralPath $SourceRoot)) {
    Write-Host "ERROR: Source folder not found:" -ForegroundColor Red
    Write-Host $SourceRoot -ForegroundColor Red
    Write-Host "Edit SourceRoot at the top of this script if your download folder moved." -ForegroundColor Red
    exit 1
}

New-Folder $RepoRoot
Set-Location -LiteralPath $RepoRoot

# Folder structure
$folders = @(
    "archive",
    "archive\original-root",
    "archive\original-appendix",
    "docs",
    "docs\build-guides",
    "docs\design-notes",
    "docs\design-notes\ai-assisted",
    "docs\safety",
    "docs\standards",
    "hardware",
    "hardware\schematic",
    "hardware\bom",
    "hardware\pcb-images",
    "hardware\transformer",
    "hardware\transformer\bom",
    "hardware\transformer\calculations",
    "hardware\transformer\construction",
    "hardware\transformer\measurements",
    "hardware\transformer\hi-pot",
    "validation",
    "validation\deadbug-images",
    "validation\drain-waveforms",
    "validation\output-waveforms",
    "validation\scope-images",
    "tools",
    "tools\middlebrook-injector",
    "tools\middlebrook-injector\images",
    "tools\middlebrook-injector\waveforms",
    "tools\digikey-api-scripts"
)

foreach ($folder in $folders) {
    New-Folder (Join-Path $RepoRoot $folder)
}

# Preserve full source
Copy-DirContentsIfExists (Join-Path $SourceRoot "Appendix") (Join-Path $RepoRoot "archive\original-appendix")

Get-ChildItem -LiteralPath $SourceRoot -File | ForEach-Object {
    Copy-FileIfExists $_.FullName (Join-Path $RepoRoot ("archive\original-root\" + $_.Name))
}

# Top-level known files
Copy-FileIfExists (Join-Path $SourceRoot "README.docx") (Join-Path $RepoRoot "docs\design-notes\original_project_summary.docx")
Copy-FileIfExists (Join-Path $SourceRoot "Build guide.docx") (Join-Path $RepoRoot "docs\build-guides\build_guide_root.docx")
Copy-FileIfExists (Join-Path $SourceRoot "Schematic.pdf") (Join-Path $RepoRoot "hardware\schematic\isolated_mains_to_5v1a_schematic.pdf")

Copy-FileIfExists (Join-Path $SourceRoot "BoM.xlsx") (Join-Path $RepoRoot "hardware\bom\pcb_bom.xlsx")
Copy-FileIfExists (Join-Path $SourceRoot "Assembly Order.xlsx") (Join-Path $RepoRoot "hardware\bom\pcb_assembly_order.xlsx")
Copy-FileIfExists (Join-Path $SourceRoot "Dead-bug BoM.xlsx") (Join-Path $RepoRoot "hardware\bom\deadbug_bom.xlsx")
Copy-FileIfExists (Join-Path $SourceRoot "Dead-bug DRAIN.xlsx") (Join-Path $RepoRoot "hardware\bom\deadbug_drain_measurements.xlsx")

Copy-FileIfExists (Join-Path $SourceRoot "IMG_9821.JPEG") (Join-Path $RepoRoot "validation\output-waveforms\output_4p94v_22ohm_load.jpg")
Copy-FileIfExists (Join-Path $SourceRoot "Drain.JPEG") (Join-Path $RepoRoot "validation\drain-waveforms\drain_stress_waveform.jpg")
Copy-FileIfExists (Join-Path $SourceRoot "ANNOTATED.JPEG") (Join-Path $RepoRoot "validation\deadbug-images\deadbug_annotated.jpg")
Copy-FileIfExists (Join-Path $SourceRoot "Copy of ANNOTATED.JPEG") (Join-Path $RepoRoot "validation\deadbug-images\deadbug_annotated_copy.jpg")
Copy-FileIfExists (Join-Path $SourceRoot "IMG_0134.JPEG") (Join-Path $RepoRoot "validation\deadbug-images\deadbug_prototype_01.jpg")

Copy-FileIfExists (Join-Path $SourceRoot "Sine from function generator.jpg") (Join-Path $RepoRoot "tools\middlebrook-injector\waveforms\function_generator_sine.jpg")
Copy-FileIfExists (Join-Path $SourceRoot "Sine from injector box.jpg") (Join-Path $RepoRoot "tools\middlebrook-injector\waveforms\injector_box_sine_output.jpg")

# Transformer loose top-level files, if present
Copy-FileIfExists (Join-Path $SourceRoot "Transformer Design Analysis.pdf") (Join-Path $RepoRoot "hardware\transformer\calculations\transformer_design_analysis.pdf")
Copy-FileIfExists (Join-Path $SourceRoot "Transformer BOM.xlsx") (Join-Path $RepoRoot "hardware\transformer\bom\transformer_bom.xlsx")
Copy-FileIfExists (Join-Path $SourceRoot "Bobbin Fit Estimation.pdf") (Join-Path $RepoRoot "hardware\transformer\calculations\bobbin_fit_estimation.pdf")
Copy-FileIfExists (Join-Path $SourceRoot "MATLAB Results.docx") (Join-Path $RepoRoot "hardware\transformer\calculations\matlab_results.docx")
Copy-FileIfExists (Join-Path $SourceRoot "MATLAB Script.docx") (Join-Path $RepoRoot "hardware\transformer\calculations\matlab_script.docx")
Copy-FileIfExists (Join-Path $SourceRoot "Saturation.xlsx") (Join-Path $RepoRoot "hardware\transformer\calculations\saturation.xlsx")
Copy-FileIfExists (Join-Path $SourceRoot "Transformer_Design_Plan.xlsx") (Join-Path $RepoRoot "hardware\transformer\construction\transformer_design_plan.xlsx")
Copy-FileIfExists (Join-Path $SourceRoot "2kV_Hi-pot.MP4") (Join-Path $RepoRoot "hardware\transformer\hi-pot\2kv_hi_pot_test.mp4")

# Middlebrook Injector
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Tools\Middlebrook Injector\Build guide.docx") (Join-Path $RepoRoot "tools\middlebrook-injector\build-guide.docx")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Tools\Middlebrook Injector\Box.HEIC") (Join-Path $RepoRoot "tools\middlebrook-injector\images\box.heic")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Tools\Middlebrook Injector\Box2.HEIC") (Join-Path $RepoRoot "tools\middlebrook-injector\images\box_2.heic")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Tools\Middlebrook Injector\IMG_1681.HEIC") (Join-Path $RepoRoot "tools\middlebrook-injector\images\injector_internal_01.heic")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Tools\Middlebrook Injector\IMG_1682.HEIC") (Join-Path $RepoRoot "tools\middlebrook-injector\images\injector_internal_02.heic")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Tools\Middlebrook Injector\Sine from function generator.jpg") (Join-Path $RepoRoot "tools\middlebrook-injector\waveforms\function_generator_sine.jpg")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Tools\Middlebrook Injector\Sine from injector box.jpg") (Join-Path $RepoRoot "tools\middlebrook-injector\waveforms\injector_box_sine_output.jpg")

# Digikey API scripts
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Tools\Python Scripts for Digikey API\digikey_bom_search.py") (Join-Path $RepoRoot "tools\digikey-api-scripts\digikey_bom_search.py")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Tools\Python Scripts for Digikey API\lastparts.py") (Join-Path $RepoRoot "tools\digikey-api-scripts\lastparts.py")

# PCB images
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\PCB\PCB Images\IMG_2271.HEIC") (Join-Path $RepoRoot "hardware\pcb-images\pcb_01.heic")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\PCB\PCB Images\IMG_2272.HEIC") (Join-Path $RepoRoot "hardware\pcb-images\pcb_02.heic")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\PCB\PCB Images\IMG_2273.HEIC") (Join-Path $RepoRoot "hardware\pcb-images\pcb_03.heic")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\PCB\PCB Images\IMG_2275.HEIC") (Join-Path $RepoRoot "hardware\pcb-images\pcb_04.heic")

# Dead-bug images
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Dead-bug\Dead-bug images\Copy of ANNOTATED.JPEG") (Join-Path $RepoRoot "validation\deadbug-images\deadbug_annotated.jpg")

$deadbugNames = @("IMG_0134","IMG_0135","IMG_0136","IMG_0137","IMG_0138","IMG_0139","IMG_0141","IMG_0142","IMG_0143","IMG_0144")
$i = 1
foreach ($name in $deadbugNames) {
    $dest = "validation\deadbug-images\deadbug_prototype_{0:D2}.jpg" -f $i
    Copy-FileIfExists (Join-Path $SourceRoot ("Appendix\Design\Dead-bug\Dead-bug images\" + $name + ".JPEG")) (Join-Path $RepoRoot $dest)
    $i++
}
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Dead-bug\Dead-bug images\ISO.JPEG") (Join-Path $RepoRoot "validation\deadbug-images\isolation_transformer_box.jpg")

# Drain waveforms
$drainNames = @("IMG_9779","IMG_9780","IMG_9782","IMG_9783","IMG_9784","IMG_9785","IMG_9786","IMG_9787","IMG_9788","IMG_9789","IMG_9790","IMG_9791")
$i = 1
foreach ($name in $drainNames) {
    $dest = "validation\drain-waveforms\drain_waveform_{0:D2}.jpg" -f $i
    Copy-FileIfExists (Join-Path $SourceRoot ("Appendix\Design\Dead-bug\Scope Images\Drain Waveforms\" + $name + ".JPEG")) (Join-Path $RepoRoot $dest)
    $i++
}

# Transformer from Appendix
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Transformer\Transformer BOM.xlsx") (Join-Path $RepoRoot "hardware\transformer\bom\transformer_bom.xlsx")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Transformer\Transformer Design Analysis.pdf") (Join-Path $RepoRoot "hardware\transformer\calculations\transformer_design_analysis.pdf")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Transformer\Calculations\Bobbin Fit Estimation.pdf") (Join-Path $RepoRoot "hardware\transformer\calculations\bobbin_fit_estimation.pdf")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Transformer\Calculations\MATLAB Results.docx") (Join-Path $RepoRoot "hardware\transformer\calculations\matlab_results.docx")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Transformer\Calculations\MATLAB Script.docx") (Join-Path $RepoRoot "hardware\transformer\calculations\matlab_script.docx")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Transformer\Calculations\Saturation.xlsx") (Join-Path $RepoRoot "hardware\transformer\calculations\saturation.xlsx")

Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Transformer\Construction Notes and Test Photos\Transformer_Design_Plan.xlsx") (Join-Path $RepoRoot "hardware\transformer\construction\transformer_design_plan.xlsx")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Transformer\Construction Notes and Test Photos\Transformer_Pin.JPEG") (Join-Path $RepoRoot "hardware\transformer\construction\transformer_pinout.jpg")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Transformer\Construction Notes and Test Photos\Kapton_tape_gapped_transformer.JPEG") (Join-Path $RepoRoot "hardware\transformer\construction\kapton_tape_gapped_transformer.jpg")
foreach ($n in 0..4) {
    $srcName = "Insulation{0:D2}.JPEG" -f $n
    $destName = "hardware\transformer\construction\insulation_layer_{0:D2}.jpg" -f $n
    Copy-FileIfExists (Join-Path $SourceRoot ("Appendix\Design\Transformer\Construction Notes and Test Photos\" + $srcName)) (Join-Path $RepoRoot $destName)
}
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Transformer\Construction Notes and Test Photos\Primary_Inductance.JPEG") (Join-Path $RepoRoot "hardware\transformer\measurements\primary_inductance_measurement.jpg")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Transformer\Construction Notes and Test Photos\Leakage_Inductance.JPEG") (Join-Path $RepoRoot "hardware\transformer\measurements\leakage_inductance_measurement.jpg")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Transformer\Construction Notes and Test Photos\72Turn_Resistance.JPEG") (Join-Path $RepoRoot "hardware\transformer\measurements\primary_resistance_72turn_measurement.jpg")
Copy-FileIfExists (Join-Path $SourceRoot "Appendix\Design\Transformer\Construction Notes and Test Photos\2kV_Hi-pot.MP4") (Join-Path $RepoRoot "hardware\transformer\hi-pot\2kv_hi_pot_test.mp4")

# AI-assisted notes
$aiDir = Join-Path $SourceRoot "Appendix\Tools\Notes\AI-Generated PDFs"
if (Test-Path -LiteralPath $aiDir) {
    Get-ChildItem -LiteralPath $aiDir -File | ForEach-Object {
        $clean = Sanitize-FileName $_.Name
        Copy-FileIfExists $_.FullName (Join-Path $RepoRoot ("docs\design-notes\ai-assisted\" + $clean))
    }
}

# XLSX -> CSV using Python stdlib helper
$PythonCmd = Get-PythonCommand
if ($null -eq $PythonCmd) {
    Write-Host "Python not found. Skipping CSV export. Install Python and rerun for CSV exports." -ForegroundColor DarkYellow
}
else {
    New-Folder (Join-Path $RepoRoot "tools")
    $helperPath = Join-Path $RepoRoot "tools\xlsx_to_csv_stdlib.py"

$helper = @'
import csv
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

NS_MAIN = "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}"

def col_to_index(cell_ref):
    m = re.match(r"([A-Z]+)", cell_ref or "")
    if not m:
        return 0
    idx = 0
    for ch in m.group(1):
        idx = idx * 26 + (ord(ch) - ord("A") + 1)
    return idx - 1

def safe_name(name):
    name = re.sub(r'[\\/:*?"<>|]', "_", name)
    name = re.sub(r"\s+", "_", name.strip())
    return name or "Sheet"

def read_shared_strings(z):
    path = "xl/sharedStrings.xml"
    if path not in z.namelist():
        return []
    root = ET.fromstring(z.read(path))
    out = []
    for si in root.findall(NS_MAIN + "si"):
        parts = []
        for t in si.iter(NS_MAIN + "t"):
            parts.append(t.text or "")
        out.append("".join(parts))
    return out

def read_workbook_sheets(z):
    wb_path = "xl/workbook.xml"
    rels_path = "xl/_rels/workbook.xml.rels"
    if wb_path not in z.namelist() or rels_path not in z.namelist():
        return []

    wb_root = ET.fromstring(z.read(wb_path))
    rel_root = ET.fromstring(z.read(rels_path))

    rel_map = {}
    for rel in rel_root:
        rid = rel.attrib.get("Id")
        target = rel.attrib.get("Target")
        if rid and target:
            if not target.startswith("xl/"):
                target = "xl/" + target.lstrip("/")
            rel_map[rid] = target

    sheets = []
    for sheet in wb_root.findall(".//" + NS_MAIN + "sheet"):
        name = sheet.attrib.get("name", "Sheet")
        rid = sheet.attrib.get("{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id")
        target = rel_map.get(rid)
        if target:
            sheets.append((name, target))
    return sheets

def cell_value(cell, shared_strings):
    t = cell.attrib.get("t")
    v = cell.find(NS_MAIN + "v")
    inline = cell.find(NS_MAIN + "is")

    if t == "inlineStr" and inline is not None:
        return "".join([(x.text or "") for x in inline.iter(NS_MAIN + "t")])

    if v is None:
        return ""

    raw = v.text or ""

    if t == "s":
        try:
            idx = int(raw)
            return shared_strings[idx] if 0 <= idx < len(shared_strings) else raw
        except Exception:
            return raw
    if t == "b":
        return "TRUE" if raw == "1" else "FALSE"
    return raw

def export_sheet(z, sheet_xml_path, shared_strings, csv_path):
    root = ET.fromstring(z.read(sheet_xml_path))
    rows_out = []
    max_col = 0

    for row in root.findall(".//" + NS_MAIN + "row"):
        values = []
        for c in row.findall(NS_MAIN + "c"):
            col_idx = col_to_index(c.attrib.get("r", ""))
            while len(values) <= col_idx:
                values.append("")
            values[col_idx] = cell_value(c, shared_strings)
            max_col = max(max_col, col_idx + 1)
        rows_out.append(values)

    with open(csv_path, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.writer(f)
        for row in rows_out:
            writer.writerow(row + [""] * (max_col - len(row)))

def export_workbook(xlsx_path):
    xlsx = Path(xlsx_path)
    out_dir = Path(str(xlsx.with_suffix("")) + "_csv")
    out_dir.mkdir(parents=True, exist_ok=True)

    with zipfile.ZipFile(xlsx, "r") as z:
        shared_strings = read_shared_strings(z)
        sheets = read_workbook_sheets(z)
        count = 0
        for sheet_name, sheet_path in sheets:
            if sheet_path not in z.namelist():
                continue
            csv_path = out_dir / (safe_name(sheet_name) + ".csv")
            export_sheet(z, sheet_path, shared_strings, csv_path)
            print(f"CSV {csv_path}")
            count += 1
        print(f"DONE {xlsx} sheets={count}")

def main():
    for arg in sys.argv[1:]:
        try:
            export_workbook(arg)
        except Exception as e:
            print(f"ERROR {arg}: {e}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
'@

    $helper | Set-Content -Path $helperPath -Encoding UTF8
    Write-Host "Wrote XLSX helper: $helperPath" -ForegroundColor Green

    $xlsxFiles = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Filter "*.xlsx" |
        Where-Object { $_.FullName -notmatch "\\\.git\\" } |
        Sort-Object FullName

    foreach ($file in $xlsxFiles) {
        Write-Host "CSV export from XLSX: $($file.FullName)" -ForegroundColor Cyan
        & $PythonCmd $helperPath $file.FullName
    }
}

# Optional HEIC conversion with ImageMagick only
if ($null -eq (Get-Command magick -ErrorAction SilentlyContinue)) {
    Write-Host "ImageMagick not found; HEIC originals preserved. Install with: winget install ImageMagick.ImageMagick" -ForegroundColor DarkYellow
}
else {
    Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Include "*.heic","*.HEIC","*.heif","*.HEIF" |
        Where-Object { $_.FullName -notmatch "\\\.git\\" } |
        ForEach-Object {
            $dir = Split-Path -Path $_.FullName -Parent
            $base = [System.IO.Path]::GetFileNameWithoutExtension($_.FullName)
            $jpg = Join-Path $dir ($base + ".jpg")
            if (-not (Test-Path -LiteralPath $jpg)) {
                & magick "$($_.FullName)" "$jpg"
                if (Test-Path -LiteralPath $jpg) {
                    Write-Host "HEIC to JPG: $jpg" -ForegroundColor Green
                }
            }
        }
}

# Folder READMEs
Write-TextFile (Join-Path $RepoRoot "hardware\transformer\README.md") @(
"# Custom Flyback Transformer",
"",
"This folder contains the design, construction, measurements, BOM, and hi-pot evidence for the custom RM10/I transformer used in the offline flyback SMPS.",
"",
"## Folder Map",
"",
"| Folder | Description |",
"|---|---|",
"| bom/ | Transformer BOM and CSV exports if generated. |",
"| calculations/ | Transformer design analysis, bobbin fit, MATLAB results, and saturation checks. |",
"| construction/ | Construction notes, pinout, insulation photos, winding/gapping photos. |",
"| measurements/ | Primary inductance, leakage inductance, and winding resistance measurement photos. |",
"| hi-pot/ | 2 kV hi-pot test video. |",
"",
"## Key Measurements",
"",
"| Parameter | Value |",
"|---|---:|",
"| Primary magnetizing inductance | 2.476 mH |",
"| Secondary inductance | 26.64 uH |",
"| Auxiliary inductance | 26.77 uH |",
"| Conservative leakage inductance | about 53.10 uH |",
"| Coupling factor | about 0.989 to 0.991 |"
)

Write-TextFile (Join-Path $RepoRoot "hardware\transformer\calculations\README.md") @(
"# Transformer Calculations",
"",
"This folder contains design and verification calculations for the custom RM10/I flyback transformer.",
"",
"| File | Description |",
"|---|---|",
"| transformer_design_analysis.pdf | Final transformer characterization and electrical design summary. |",
"| bobbin_fit_estimation.pdf | Bobbin winding-fit calculation. |",
"| matlab_results.docx | Raw MATLAB calculation output. |",
"| matlab_script.docx | Raw MATLAB script document. |",
"| saturation.xlsx | Raw saturation spreadsheet. |",
"| saturation_csv/ | CSV exports if generated. |",
"",
"## Key Results",
"",
"| Parameter | Value |",
"|---|---:|",
"| Output power target | 5 W |",
"| Switching frequency | about 132 kHz |",
"| Primary turns | 119 turns |",
"| Measured primary magnetizing inductance | 2.476 mH |",
"| Secondary inductance | 26.64 uH |",
"| Auxiliary inductance | 26.77 uH |",
"| Conservative leakage inductance | about 53.10 uH |",
"| Estimated primary peak current | about 0.206 A |",
"| Total bobbin radial build | about 2.177 mm |"
)

Write-TextFile (Join-Path $RepoRoot "hardware\bom\README.md") @(
"# BOM and Assembly Files",
"",
"Bill-of-materials and assembly-order spreadsheets for the PCB and dead-bug prototype. CSV export folders are generated next to each workbook when possible.",
"",
"| File | Description |",
"|---|---|",
"| pcb_bom.xlsx | PCB bill of materials. |",
"| pcb_assembly_order.xlsx | PCB assembly order spreadsheet. |",
"| deadbug_bom.xlsx | Dead-bug prototype BOM. |",
"| deadbug_drain_measurements.xlsx | Drain waveform / measurement spreadsheet. |"
)

Write-TextFile (Join-Path $RepoRoot "validation\README.md") @(
"# Validation Evidence",
"",
"| Folder | Description |",
"|---|---|",
"| deadbug-images/ | Dead-bug prototype photos. |",
"| drain-waveforms/ | Drain-node oscilloscope captures. |",
"| output-waveforms/ | Output waveform captures under load. |",
"| scope-images/ | Additional oscilloscope images. |"
)

Write-TextFile (Join-Path $RepoRoot "tools\middlebrook-injector\README.md") @(
"# Middlebrook Loop-Injection Box",
"",
"This folder documents the reusable Middlebrook loop-injection box used for future SMPS feedback-loop measurement.",
"",
"The injector allows a small AC signal to be inserted into a low-voltage feedback loop while two oscilloscope channels measure the response on either side of the injection resistor.",
"",
"Safety: this injector is for low-voltage control loops only, not high-voltage drain or DC-bus nodes."
)

# Indexes
$csvFiles = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Filter "*.csv" |
    Where-Object { $_.FullName -notmatch "\\\.git\\" } |
    Sort-Object FullName

$csvLines = @("# GitHub-Viewable CSV Exports","","CSV exports generated from Excel files. Raw XLSX files are preserved.","","| CSV File |","|---|")
foreach ($f in $csvFiles) {
    $rel = $f.FullName.Substring($RepoRoot.Length + 1).Replace("\", "/")
    $csvLines += "| [$rel]($rel) |"
}
if ($csvFiles.Count -eq 0) { $csvLines += "| No CSV exports found. |" }
Write-TextFile (Join-Path $RepoRoot "docs\csv_exports_index.md") $csvLines

$imageFiles = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Include "*.jpg","*.jpeg","*.png","*.webp" |
    Where-Object { $_.FullName -notmatch "\\\.git\\" } |
    Sort-Object FullName

$imgLines = @("# GitHub-Viewable Image Index","","Index of browser-viewable image files. HEIC originals are preserved where present.","","| Image | Path |","|---|---|")
foreach ($f in $imageFiles) {
    $rel = $f.FullName.Substring($RepoRoot.Length + 1).Replace("\", "/")
    $imgLines += "| ![]($rel) | [$rel]($rel) |"
}
if ($imageFiles.Count -eq 0) { $imgLines += "| No images found. | |" }
Write-TextFile (Join-Path $RepoRoot "docs\image_index.md") $imgLines

# Top README
$topReadme = @(
"# Offline Flyback SMPS - Custom Transformer",
"",
"Bench-validated offline flyback switch-mode power supply using a custom hand-wound RM10/I transformer and a Power Integrations TNY285 TinySwitch controller.",
"",
"This project documents the design, prototyping, measurement, and PCB transition of an isolated 120 VAC to 5 V flyback supply.",
"",
"## Bench Validation Images",
"",
"### Dead-bug Prototype",
"",
"![Dead-bug flyback prototype](validation/deadbug-images/deadbug_annotated.jpg)",
"",
"### Output Waveform",
"",
"![Output waveform under load](validation/output-waveforms/output_4p94v_22ohm_load.jpg)",
"",
"### Drain Waveform",
"",
"![Drain waveform](validation/drain-waveforms/drain_stress_waveform.jpg)",
"",
"## Project Highlights",
"",
"- Designed and hand-wound custom RM10/I flyback transformer",
"- Built and debugged offline flyback prototype from first principles",
"- Verified about 4.94 V output under a 22 ohm load",
"- Measured transformer magnetics, leakage, coupling, and drain stress",
"- Captured drain waveform behavior and output waveform behavior",
"- Created PCB schematic, BOM, assembly order, and validation artifacts",
"- Preserved original Drive-style project archive under archive/",
"",
"## Electrical Summary",
"",
"| Item | Value |",
"|---|---:|",
"| Input | 120 VAC nominal |",
"| Bulk bus | about 170 VDC |",
"| Controller | Power Integrations TNY285PG |",
"| Transformer | Custom hand-wound RM10/I |",
"| Bench load | 22 ohm |",
"| Bench output | about 4.94 V |",
"| Bench output current | about 200 mA |",
"| Dead-bug ripple/noise | about 1.56 Vp-p |",
"| Peak drain voltage observed | about 344 V max |",
"",
"## Viewable Asset Indexes",
"",
"- [CSV exports index](docs/csv_exports_index.md)",
"- [Image index](docs/image_index.md)",
"",
"## Repository Structure",
"",
"- hardware/ - schematic, BOM, PCB images, and transformer design files",
"- validation/ - dead-bug photos, output captures, and drain waveform evidence",
"- tools/ - Middlebrook injector and supporting scripts",
"- docs/ - notes, indexes, and generated summaries",
"- archive/ - preserved original root files and original Appendix tree",
"",
"## Safety Notice",
"",
"This project involves offline mains voltage and isolated switch-mode power supply design. The files are provided for portfolio and educational documentation only. Mains-powered circuits can be lethal. Use proper isolation, fusing, grounding, probing technique, and supervision where appropriate."
)
Write-TextFile (Join-Path $RepoRoot "README.md") $topReadme

Write-TextFile (Join-Path $RepoRoot ".gitignore") @(
"# Windows",
"Thumbs.db",
"desktop.ini",
"",
"# Office temporary files",
"~$*.docx",
"~$*.xlsx",
"*.tmp",
"",
"# Python",
"__pycache__/",
"*.pyc",
".venv/",
".env",
"",
"# Archives / temporary exports",
"*.zip",
"*.rar",
"*.7z",
"",
"# Logs / backups",
"*.log",
"*.bak"
)

Write-TextFile (Join-Path $RepoRoot ".gitattributes") @(
"* text=auto",
"",
"*.pdf binary",
"*.docx binary",
"*.xlsx binary",
"*.png binary",
"*.jpg binary",
"*.jpeg binary",
"*.JPG binary",
"*.JPEG binary",
"*.heic binary",
"*.HEIC binary",
"*.mp4 binary",
"*.MP4 binary",
"*.zip binary"
)

Write-TextFile (Join-Path $RepoRoot "LICENSE") @(
"Portfolio / Educational Use Notice",
"",
"This repository is provided for portfolio and educational documentation purposes.",
"",
"The design files, measurements, notes, and supporting materials are shared as examples of engineering work and are not certified, warranted, or approved for production use.",
"",
"Offline mains-powered circuits can be lethal. Anyone using, modifying, or reproducing any part of this project is responsible for their own safety, compliance, testing, and regulatory obligations."
)

Write-Host ""
Write-Host "ALL-IN-ONE REBUILD COMPLETE." -ForegroundColor Green
Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "cd `"$RepoRoot`""
Write-Host "git status --untracked-files=all"
Write-Host "git add README.md .gitignore .gitattributes LICENSE docs hardware validation tools archive"
Write-Host 'git commit -m "Rebuild complete repo with full archive and viewable assets"'
Write-Host "git push"
