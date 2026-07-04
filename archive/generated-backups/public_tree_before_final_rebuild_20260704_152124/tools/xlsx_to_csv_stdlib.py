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
