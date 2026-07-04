# FINAL_REPAIR_AND_PRESERVE_FULL_SMPS_REPO.ps1
# Run from anywhere.
#
# This script repairs the Git repo copy by pulling the full original Drive download
# from Downloads into the Git repo, preserving raw files, adding viewable folder
# summaries, and optionally exporting XLSX -> CSV if Excel automation works.
#
# It DOES NOT delete anything.
# It DOES NOT move anything out of the original folder.
# It copies raw material into archive/ and organized folders.
#
# Default paths match your current setup:
#   Original source: C:\Users\Jonathan\Downloads\5V-1A SMPS -20260704T141105Z-3-001\5V-1A SMPS
#   Git repo:        C:\Git\5V-1A SMPS
#
# Run:
#   powershell -ExecutionPolicy Bypass -File .\FINAL_REPAIR_AND_PRESERVE_FULL_SMPS_REPO.ps1

$ErrorActionPreference = "Continue"

$SourceRoot = "C:\Users\Jonathan\Downloads\5V-1A SMPS -20260704T141105Z-3-001\5V-1A SMPS"
$RepoRoot   = "C:\Git\5V-1A SMPS"

Write-Host ""
Write-Host "FINAL SMPS REPO REPAIR / PRESERVE SCRIPT" -ForegroundColor Cyan
Write-Host "Source: $SourceRoot" -ForegroundColor Cyan
Write-Host "Repo:   $RepoRoot" -ForegroundColor Cyan
Write-Host "Copy-only. No deletions." -ForegroundColor Cyan
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

function Sanitize-FileName {
    param([string]$Name)
    $clean = $Name -replace '[\\\/\:\*\?\"\<\>\|]', '_'
    $clean = $clean -replace '\s+', '_'
    return $clean
}

function Export-XlsxToCsvSafe {
    param([string]$XlsxPath)

    if (-not (Test-Path -LiteralPath $XlsxPath)) { return }

    $fullXlsx = (Resolve-Path -LiteralPath $XlsxPath).Path
    $dir = Split-Path -Path $fullXlsx -Parent
    $base = [System.IO.Path]::GetFileNameWithoutExtension($fullXlsx)
    $exportDir = Join-Path $dir ($base + "_csv")
    New-Folder $exportDir

    $excel = $null
    $workbook = $null

    try {
        $excel = New-Object -ComObject Excel.Application
        $excel.Visible = $false
        $excel.DisplayAlerts = $false
        $excel.EnableEvents = $false

        $workbook = $excel.Workbooks.Open($fullXlsx, $null, $true)

        foreach ($sheet in $workbook.Worksheets) {
            $sheetName = Sanitize-FileName $sheet.Name
            $csvPath = Join-Path $exportDir ($sheetName + ".csv")

            $sheet.Copy()
            $tempWorkbook = $excel.ActiveWorkbook
            $tempWorkbook.SaveAs($csvPath, 6) # xlCSV
            $tempWorkbook.Close($false)

            Write-Host "CSV export: $csvPath" -ForegroundColor Green
        }

        $workbook.Close($false)
        $excel.Quit()
    }
    catch {
        Write-Host "CSV export failed for: $XlsxPath" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    finally {
        try { if ($workbook -ne $null) { $workbook.Close($false) | Out-Null } } catch {}
        try { if ($excel -ne $null) { $excel.Quit() | Out-Null } } catch {}
    }
}

function Convert-HeicToJpgIfPossible {
    param([string]$HeicPath)

    if (-not (Test-Path -LiteralPath $HeicPath)) { return }

    $magick = Get-Command magick -ErrorAction SilentlyContinue
    if ($null -eq $magick) {
        return
    }

    $dir = Split-Path -Path $HeicPath -Parent
    $base = [System.IO.Path]::GetFileNameWithoutExtension($HeicPath)
    $jpg = Join-Path $dir ($base + ".jpg")

    if (Test-Path -LiteralPath $jpg) { return }

    try {
        & magick "$HeicPath" "$jpg"
        if (Test-Path -LiteralPath $jpg) {
            Write-Host "HEIC -> JPG: $jpg" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "HEIC conversion failed: $HeicPath" -ForegroundColor DarkYellow
    }
}

# ------------------------------------------------------------
# Validate paths
# ------------------------------------------------------------

if (-not (Test-Path -LiteralPath $SourceRoot)) {
    Write-Host "ERROR: SourceRoot does not exist:" -ForegroundColor Red
    Write-Host $SourceRoot -ForegroundColor Red
    Write-Host "Edit `$SourceRoot at the top of this script, then rerun." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path -LiteralPath $RepoRoot)) {
    Write-Host "RepoRoot did not exist. Creating it." -ForegroundColor DarkYellow
    New-Folder $RepoRoot
}

Set-Location -LiteralPath $RepoRoot

# ------------------------------------------------------------
# Create full folder structure
# ------------------------------------------------------------

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

# ------------------------------------------------------------
# Preserve FULL original source
# ------------------------------------------------------------

Copy-DirContentsIfExists (Join-Path $SourceRoot "Appendix") (Join-Path $RepoRoot "archive\original-appendix")

# Preserve every loose top-level file from original root
Get-ChildItem -LiteralPath $SourceRoot -File | ForEach-Object {
    Copy-FileIfExists $_.FullName (Join-Path $RepoRoot ("archive\original-root\" + $_.Name))
}

# ------------------------------------------------------------
# Copy known top-level files into organized destinations
# ------------------------------------------------------------

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

# ------------------------------------------------------------
# Copy organized files from Appendix into clean structure
# ------------------------------------------------------------

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

# ------------------------------------------------------------
# CSV exports for XLSX files in organized folders
# ------------------------------------------------------------

Write-Host ""
Write-Host "Exporting XLSX files to CSV if Excel automation is available..." -ForegroundColor Cyan

Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Filter "*.xlsx" |
    Where-Object {
        $_.FullName -notmatch "\\\.git\\" -and
        $_.FullName -notmatch "\\archive\\original-appendix\\" -and
        $_.FullName -notmatch "\\archive\\original-root\\"
    } |
    ForEach-Object {
        Export-XlsxToCsvSafe $_.FullName
    }

# ------------------------------------------------------------
# HEIC -> JPG if ImageMagick is installed
# ------------------------------------------------------------

Write-Host ""
Write-Host "Converting HEIC to JPG if ImageMagick is installed..." -ForegroundColor Cyan

if ($null -eq (Get-Command magick -ErrorAction SilentlyContinue)) {
    Write-Host "ImageMagick not found. HEIC originals remain preserved. To convert later:" -ForegroundColor DarkYellow
    Write-Host "winget install ImageMagick.ImageMagick" -ForegroundColor DarkYellow
}
else {
    Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Include "*.heic","*.HEIC","*.heif","*.HEIF" |
        Where-Object {
            $_.FullName -notmatch "\\\.git\\" -and
            $_.FullName -notmatch "\\archive\\original-appendix\\" -and
            $_.FullName -notmatch "\\archive\\original-root\\"
        } |
        ForEach-Object {
            Convert-HeicToJpgIfPossible $_.FullName
        }
}

# ------------------------------------------------------------
# README files and indexes
# ------------------------------------------------------------

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
"## Files",
"",
"| File | Description |",
"|---|---|",
"| transformer_design_analysis.pdf | Final transformer characterization and electrical design summary. |",
"| bobbin_fit_estimation.pdf | Bobbin winding-fit calculation for split primary, TIW secondary, auxiliary winding, and insulation stackup. |",
"| matlab_results.docx | Raw MATLAB calculation output. GitHub may require download. |",
"| matlab_script.docx | Raw MATLAB script document. GitHub may require download. |",
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
"| Coupling factor | about 0.989 to 0.991 |",
"| Estimated primary peak current | about 0.206 A |",
"| Total bobbin radial build | about 2.177 mm |"
)

Write-TextFile (Join-Path $RepoRoot "hardware\bom\README.md") @(
"# BOM and Assembly Files",
"",
"This folder contains bill-of-materials and assembly-order spreadsheets for the PCB and dead-bug prototype.",
"",
"CSV export folders are generated next to each workbook when Excel automation succeeds.",
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
"This folder contains bench-validation artifacts for the offline flyback SMPS.",
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

# CSV index
$csvFiles = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Filter "*.csv" |
    Where-Object { $_.FullName -notmatch "\\\.git\\" } |
    Sort-Object FullName

$csvLines = @()
$csvLines += "# GitHub-Viewable CSV Exports"
$csvLines += ""
$csvLines += "CSV exports generated from Excel files. Raw XLSX files are preserved."
$csvLines += ""
$csvLines += "| CSV File |"
$csvLines += "|---|"
foreach ($f in $csvFiles) {
    $rel = $f.FullName.Substring($RepoRoot.Length + 1).Replace("\", "/")
    $csvLines += "| [$rel]($rel) |"
}
if ($csvFiles.Count -eq 0) { $csvLines += "| No CSV exports found. |" }
Write-TextFile (Join-Path $RepoRoot "docs\csv_exports_index.md") $csvLines

# Image index
$imageFiles = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Include "*.jpg","*.jpeg","*.png","*.webp" |
    Where-Object { $_.FullName -notmatch "\\\.git\\" } |
    Sort-Object FullName

$imgLines = @()
$imgLines += "# GitHub-Viewable Image Index"
$imgLines += ""
$imgLines += "Index of browser-viewable image files. HEIC originals are preserved where present."
$imgLines += ""
$imgLines += "| Image | Path |"
$imgLines += "|---|---|"
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

# .gitignore and .gitattributes
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
Write-Host "FINAL REPAIR COMPLETE." -ForegroundColor Green
Write-Host ""
Write-Host "Now run these commands:" -ForegroundColor Cyan
Write-Host "cd `"$RepoRoot`""
Write-Host "git status --untracked-files=all"
Write-Host "git add README.md .gitignore .gitattributes LICENSE docs hardware validation tools archive"
Write-Host 'git commit -m "Repair repo archive and add viewable assets"'
Write-Host "git push"
