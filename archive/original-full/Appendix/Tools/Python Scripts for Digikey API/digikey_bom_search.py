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
]
# ────────────────────────────────────────────────


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

        for m in mpn_choices:
            queries.append(m)
        for m in mpn_choices:
            for manu in manu_choices:
                queries.append(f"{manu} {m}")
        queries.append(desc)

        # refined category-specific searches
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
        elif cat == "PE Ring Lug + Screw":
            queries.extend([
                "ring tongue terminal #6 stud",
                "ring lug #8 stud insulated",
                "Keystone ring terminal",
                "ground lug with screw",
            ])

        found = False
        for q in queries:
            data = keyword_search(token, q, limit=10)
            products = data.get("Products", [])
            if not products:
                time.sleep(0.25)
                continue

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
            print("❌ not found")

    df = pd.DataFrame(rows)
    df.to_excel("digikey_bom_infra_parts_v3.xlsx", index=False)
    print("\n📁 Saved to digikey_bom_infra_parts_v3.xlsx")


if __name__ == "__main__":
    lookup_all()