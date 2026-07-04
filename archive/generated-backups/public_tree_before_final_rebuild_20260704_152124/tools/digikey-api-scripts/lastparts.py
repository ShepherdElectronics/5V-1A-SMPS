import requests
import pandas as pd
import time

# ────────────────────────────────────────────────
# 🔐 Your Digi-Key API credentials
CLIENT_ID = "TvjMp2WpSHKeXi1CnMKC4MhpRYIZkUnZcZ1GDzfndaEziLMj"
CLIENT_SECRET = "XGjlKKlr8Way6QavQSc0UDvKp76WePsSh4eCU0BJs30GSUvFSUOK4Kc9S6m1prTx"

TOKEN_URL = "https://api.digikey.com/v1/oauth2/token"
SEARCH_URL = "https://api.digikey.com/products/v4/search/keyword"
# ────────────────────────────────────────────────


def get_token():
    r = requests.post(
        TOKEN_URL,
        auth=(CLIENT_ID, CLIENT_SECRET),
        data={"grant_type": "client_credentials"},
    )
    r.raise_for_status()
    print("✅ got token")
    return r.json()["access_token"]


def dk_headers(token: str) -> dict:
    return {
        "Authorization": f"Bearer {token}",
        "X-DIGIKEY-Client-Id": CLIENT_ID,
        "X-DIGIKEY-Locale-Site": "US",
        "X-DIGIKEY-Locale-Language": "en",
        "X-DIGIKEY-Locale-Currency": "USD",
        "Content-Type": "application/json",
        "accept": "application/json",
    }


def keyword_search(token: str, kw: str, limit: int = 10) -> dict:
    body = {"Keywords": kw, "Limit": limit}
    r = requests.post(SEARCH_URL, headers=dk_headers(token), json=body)
    if r.status_code != 200:
        return {}
    return r.json()


def split_multi(s: str):
    return [chunk.strip() for chunk in s.replace("–", "-").split("/") if chunk.strip()]


# ────────────────────────────────────────────────
# PARTS TO LOOK UP (infra + bleeders + MOV/NTC + snubber resistors)
# ────────────────────────────────────────────────
PARTS = [
    {
        "Category": "Wire / Bus",
        "Needed?": "Yes",
        "DNP": "No",
        "Why": "For solid bus connections and low-resistance rails.",
        "Manufacturer (spec)": "Alpha Wire / Belden / Generic",
        "MPN (spec)": "-",
        "Description": "20–22 AWG tinned copper hookup wire, short spool (≤ 50 ft)",
        "Voltage (spec)": "300 V",
        "Value (spec)": "20–22 AWG, 25–50 ft",
    },
    {
        "Category": "0.1in Header 2-pin TH",
        "Needed?": "Yes",
        "DNP": "No",
        "Why": "For clean 2-pin test/scope/jumper connections on perf/deadbug.",
        "Manufacturer (spec)": "Harwin / Samtec / TE Connectivity / Wurth",
        "MPN (spec)": "-",
        "Description": "2-position 2.54 mm vertical through-hole header",
        "Voltage (spec)": "-",
        "Value (spec)": "2-pin, 2.54 mm pitch",
    },
    {
        "Category": "0.1in Header 3-pin TH",
        "Needed?": "Yes",
        "DNP": "No",
        "Why": "For 3-pin test headers (sense, scope, jumpers).",
        "Manufacturer (spec)": "Harwin / Samtec / TE Connectivity / Wurth",
        "MPN (spec)": "-",
        "Description": "3-position 2.54 mm vertical through-hole header",
        "Voltage (spec)": "-",
        "Value (spec)": "3-pin, 2.54 mm pitch",
    },
    {
        "Category": "PE Ring Lug + Screw",
        "Needed?": "Optional",
        "DNP": "Yes",
        "Why": "For earth connection if Y-cap or metal heatsink is used.",
        "Manufacturer (spec)": "Keystone / Panduit / Wurth",
        "MPN (spec)": "-",
        "Description": "Ring lug + matching screw (#6/#8 or M4)",
        "Voltage (spec)": "-",
        "Value (spec)": "Ring lug",
    },
    # ── DC Bus Bleeders ───────────────────────
    {
        "Category": "DC Bus Bleeder 820k",
        "Needed?": "Optional",
        "DNP": "No",
        "Why": "Dedicated bleeder so 400 V bus always discharges.",
        "Manufacturer (spec)": "Vishay",
        "MPN (spec)": "MRS25000C8203FCT00",
        "Description": "0.6 W 820 kΩ metal film resistor, axial (MRS25)",
        "Voltage (spec)": "400 V bus",
        "Value (spec)": "820 kΩ, 0.6 W",
    },
    {
        "Category": "DC Bus Bleeder 1M",
        "Needed?": "Optional",
        "DNP": "No",
        "Why": "Alternate bleeder value (slower discharge, less heat).",
        "Manufacturer (spec)": "Vishay",
        "MPN (spec)": "MRS25000C1004FCT00",
        "Description": "0.6 W 1 MΩ metal film resistor, axial (MRS25)",
        "Voltage (spec)": "400 V bus",
        "Value (spec)": "1 MΩ, 0.6 W",
    },
    # ── MOV / NTC Alternates ──────────────────
    {
        "Category": "MOV Alt 250 VAC",
        "Needed?": "Optional",
        "DNP": "Yes",
        "Why": "Alternate MOV for harsh mains / 240 VAC regions.",
        "Manufacturer (spec)": "TDK / Panasonic",
        "MPN (spec)": "ERZV14D391",
        "Description": "14 mm MOV, 390 V varistor, 250 VAC class",
        "Voltage (spec)": "250 VAC",
        "Value (spec)": "ERZ-V14D391",
    },
    {
        "Category": "NTC Alt 5D-11",
        "Needed?": "Optional",
        "DNP": "Yes",
        "Why": "Larger body 5 Ω NTC if bulk capacitance is increased.",
        "Manufacturer (spec)": "Cantherm",
        "MPN (spec)": "MF72-005D11",
        "Description": "Inrush current limiter, 5 Ω, 11 mm disc",
        "Voltage (spec)": "AC mains",
        "Value (spec)": "5D-11, 5 Ω",
    },
    # ── Snubber / General 0.5 W Resistors (value-based) ──
    {
        "Category": "Snubber R 0.47",
        "Needed?": "Optional",
        "DNP": "No",
        "Why": "Low-value resistor for snubber / surge experiments (~0.5–2 W axial).",
        "Manufacturer (spec)": "TE Connectivity / Vishay",
        "MPN (spec)": "-",  # we select by value/type
        "Description": "0.47 ohm metal film axial resistor",
        "Voltage (spec)": "-",
        "Value (spec)": "0.47 Ω",
    },
    {
        "Category": "Snubber R 1.0",
        "Needed?": "Optional",
        "DNP": "No",
        "Why": "1 Ω general-purpose / snubber resistor, ~0.5–1 W axial.",
        "Manufacturer (spec)": "Vishay Beyschlag/Draloric/BC Components",
        "MPN (spec)": "-",
        "Description": "MRS25 1 ohm metal film axial",
        "Voltage (spec)": "-",
        "Value (spec)": "1.0 Ω",
    },
    {
        "Category": "Snubber R 2.2",
        "Needed?": "Optional",
        "DNP": "No",
        "Why": "2.2 Ω snubber resistor (MRS25 style).",
        "Manufacturer (spec)": "Vishay Beyschlag/Draloric/BC Components",
        "MPN (spec)": "-",
        "Description": "Vishay MRS25 2R2 metal film axial",
        "Voltage (spec)": "-",
        "Value (spec)": "2.2 Ω",
    },
    {
        "Category": "Snubber R 3.3",
        "Needed?": "Optional",
        "DNP": "No",
        "Why": "3.3 Ω snubber resistor (MRS25 style).",
        "Manufacturer (spec)": "Vishay Beyschlag/Draloric/BC Components",
        "MPN (spec)": "-",
        "Description": "Vishay MRS25 3R3 metal film axial",
        "Voltage (spec)": "-",
        "Value (spec)": "3.3 Ω",
    },
    {
        "Category": "Snubber R 4.7",
        "Needed?": "Optional",
        "DNP": "No",
        "Why": "4.7 Ω snubber resistor (MRS25 style).",
        "Manufacturer (spec)": "Vishay Beyschlag/Draloric/BC Components",
        "MPN (spec)": "-",
        "Description": "Vishay MRS25 4R7 metal film axial",
        "Voltage (spec)": "-",
        "Value (spec)": "4.7 Ω",
    },
]

# ── explicit snubber targets & match patterns ──

SNUBBER_TARGET_OHMS = {
    "Snubber R 0.47": 0.47,
    "Snubber R 1.0": 1.0,
    "Snubber R 2.2": 2.2,
    "Snubber R 3.3": 3.3,
    "Snubber R 4.7": 4.7,
}

SNUBBER_PATTERNS = {
    0.47: ["0.47 ohm", "0.47Ω", "0r47", "470m ohm", "470mΩ"],
    1.0:  ["1.0 ohm", "1 ohm", "1Ω", "1r0"],
    2.2:  ["2.2 ohm", "2.2Ω", "2r2"],
    3.3:  ["3.3 ohm", "3.3Ω", "3r3"],
    4.7:  ["4.7 ohm", "4.7Ω", "4r7"],
}


def pick_best_product(products, mpn_choices, manu_choices):
    mpn_lower = [m.lower() for m in mpn_choices]
    manu_lower = [m.lower() for m in manu_choices]

    # 1) exact MPN
    for p in products:
        if p["ManufacturerProductNumber"].lower() in mpn_lower:
            return p
    # 2) preferred manufacturer
    for p in products:
        if any(m in p["Manufacturer"]["Name"].lower() for m in manu_lower):
            return p
    # 3) fallback
    return products[0] if products else None


def filter_snubber_by_resistance(category: str, products: list) -> list:
    """
    For snubber resistors, only keep products that clearly match the target ohmic value.
    If nothing matches, return the original list so we don't totally fail the part.
    """
    target = SNUBBER_TARGET_OHMS.get(category)
    if target is None or not products:
        return products

    patterns = [p.lower() for p in SNUBBER_PATTERNS.get(target, [])]
    if not patterns:
        return products

    filtered = []
    for p in products:
        desc = p.get("Description", {}).get("ProductDescription", "")
        mpn = p.get("ManufacturerProductNumber", "")
        family = p.get("Family", {}).get("Name", "")
        text = f"{desc} {mpn} {family}".lower()

        if any(pat in text for pat in patterns):
            filtered.append(p)

    # If we found at least one clearly-correct value, use those.
    # Otherwise just leave it unfiltered (so you at least get something).
    return filtered or products


def lookup_all():
    token = get_token()
    rows = []

    for part in PARTS:
        cat = part["Category"]
        needed = part["Needed?"]
        dnp = part["DNP"]
        why = part["Why"]
        manu_spec = part["Manufacturer (spec)"]
        mpn_spec = part["MPN (spec)"]
        desc = part["Description"]
        v_spec = part["Voltage (spec)"]
        val_spec = part["Value (spec)"]

        print(f"\n🔍 {cat} – {desc}")

        manu_choices = split_multi(manu_spec)
        mpn_choices = split_multi(mpn_spec) if mpn_spec != "-" else []

        queries = []

        # base MPN tries (for parts where we trust MPN)
        for m in mpn_choices:
            queries.append(m)
        for m in mpn_choices:
            for manu in manu_choices:
                queries.append(f"{manu} {m}")

        # generic description first
        queries.append(desc)

        # refined category-specific hints
        if cat == "Wire / Bus":
            queries.extend([
                "22 awg tinned copper hookup wire 25 ft",
                "20 awg tinned copper hookup wire 25 ft",
                "Alpha Wire 3050 22 AWG 25 ft",
                "UL1007 22 AWG tinned hook-up wire 25 ft",
            ])
        elif cat == "0.1in Header 2-pin TH":
            queries.extend([
                "2 pin header 2.54 mm through hole vertical",
                "2 position header 0.1in TH vertical",
                "Harwin M20-9990245 2 pin",
                "Samtec TSW-102 through hole header",
            ])
        elif cat == "0.1in Header 3-pin TH":
            queries.extend([
                "3 pin header 2.54 mm through hole vertical",
                "3 position header 0.1in TH vertical",
                "Harwin M20-9990345 3 pin",
                "Samtec TSW-103 through hole header",
            ])
        elif "Bleeder" in cat:
            queries.extend([
                f"{val_spec} metal film resistor axial 0.6W",
                "MRS25 0.6W metal film resistor",
            ])
        elif "MOV" in cat:
            queries.extend([
                "14mm MOV 390V varistor 250VAC",
                "ERZ-V14D391 varistor",
            ])
        elif "NTC" in cat:
            queries.extend([
                "MF72 5D-11 5 ohm NTC inrush",
                "inrush current limiter 5D-11 5R",
            ])
        elif cat.startswith("Snubber R"):
            val_token = val_spec.split()[0]   # "0.47", "1.0", "2.2", etc.
            r_code = val_token.replace(".", "R")
            queries.extend([
                f"{val_token} ohm metal film resistor 0.6W axial",
                f"{val_token} ohm 0.5W resistor axial",
                f"{r_code} metal film axial resistor",
                f"Vishay MRS25 {r_code}",
            ])

        found = False
        for q in queries:
            data = keyword_search(token, q, limit=20)
            products = data.get("Products", [])
            if not products:
                time.sleep(0.25)
                continue

            # extra filtering for snubber resistors so we don't get 221Ω etc.
            if cat.startswith("Snubber R"):
                products = filter_snubber_by_resistance(cat, products)

            chosen = pick_best_product(products, mpn_choices, manu_choices)
            if chosen:
                rows.append({
                    "Category": cat,
                    "Needed?": needed,
                    "DNP": dnp,
                    "Why": why,
                    "Manufacturer (spec)": manu_spec,
                    "Manufacturer (found)": chosen["Manufacturer"]["Name"],
                    "MPN (spec)": mpn_spec,
                    "MPN (found)": chosen["ManufacturerProductNumber"],
                    "Description (found)": chosen["Description"]["ProductDescription"],
                    "Voltage (spec)": v_spec,
                    "Value (spec)": val_spec,
                    "Price (1x)": chosen.get("UnitPrice", ""),
                    "URL": chosen["ProductUrl"],
                    "Query Used": q,
                })
                print(f"✅ {chosen['ManufacturerProductNumber']}  ← {q}")
                found = True
                break

            time.sleep(0.25)

        if not found:
            rows.append({
                "Category": cat,
                "Needed?": needed,
                "DNP": dnp,
                "Why": why,
                "Manufacturer (spec)": manu_spec,
                "Manufacturer (found)": "",
                "MPN (spec)": mpn_spec,
                "MPN (found)": "",
                "Description (found)": "",
                "Voltage (spec)": v_spec,
                "Value (spec)": val_spec,
                "Price (1x)": "",
                "URL": "",
                "Query Used": "all queries failed",
            })
            print(f"❌ not found for {cat}")

    df = pd.DataFrame(rows)
    df.to_excel("digikey_bom_infra_parts_v3.xlsx", index=False)
    print("\n📁 Saved to digikey_bom_infra_parts_v3.xlsx")


if __name__ == "__main__":
    lookup_all()