"""Official records for Ohio -> one table of licensed / inspected food businesses.

Ohio has no statewide food-license list and no statewide inspection data: about 110 local health districts license and inspect
under the Ohio Uniform Food Safety Code (OAC 3717-1). Two publish in bulk (see playbook/12-sources.md):
- "cin": Cincinnati Health Department, "Cincinnati Food Safety Program" (data.cincinnati-oh.gov rg6p-b3h3, Public Domain, daily):
         one row per cited violation (or per visit with none), with the license number, business name, address and a point. A license
         is live when its latest status is "Issued" (the City's current system, 2024 on). City of Cincinnati only.
- "col": Columbus Public Health, "Restaurant & Market Health Inspections" (maps2.columbus.gov Schemas/Health/MapServer/3, CC0,
         nightly): every permitted food service and retail food facility in its jurisdiction (the City of Columbus and Worthington),
         with the business type, risk level and the City's own status ("Standards Met", "Under Enforcement", "Closed for Violation").

load() returns: jur, lic (our id), name, keys (name keys), addr, city, zip, num, street, lat, lon, kind, active, ltype, status.
kind: restaurant | bar | brewery | retail | venue | food | other.
"""
import os, re, json
import numpy as np, pandas as pd
from common import norm_name, RAW, name_sim, _stems, GENERIC, canon_city

OFF = os.path.join(RAW, "official")
DIRS = {"N": "N", "S": "S", "E": "E", "W": "W", "NORTH": "N", "SOUTH": "S", "EAST": "E", "WEST": "W"}
TYPES = set("ST STREET AVE AV AVENUE BLVD BOULEVARD RD ROAD DR DRIVE LN LANE CT COURT PL PLACE PKWY PARKWAY TER TRL TRAIL WAY HWY CIR "
            "CIRCLE PLZ SQ MALL BND PASS XING RUN ROW WALK RDG LOOP FWY FREEWAY EXPY EXPRESSWAY".split())


def road(a):
    """One spelling for numbered roads: 'STATE ROUTE 7' = 'SR 7' = 'ST RT 7' = 'OH-7' = 'OHIO 7'; 'US HIGHWAY 42' = 'US-42' = 'US 42';
    'INTERSTATE 71' = 'I-71' = 'I 71'; 'COUNTY ROAD 20' = 'CO RD 20' = 'CR 20'; 'TOWNSHIP ROAD 123' = 'TWP RD 123' = 'TR 123'."""
    a = re.sub(r"(\d)\s*&\s*(\d)", r"\1-\2", a.upper())
    a = re.sub(r"\b(US|SR|OH|CR|TR|I)-(\w)", r"\1 \2", a)
    a = re.sub(r"\b(?:INTERSTATE(?: HIGHWAY| HWY)?|IH|I H)\s*(?=\d)", "I ", a)
    a = re.sub(r"\b(?:US|U S)\s+(?:HIGHWAY|HWY|ROUTE|RTE|RT)\b", "US", a)
    a = re.sub(r"\b(?:STATE (?:ROUTE|RTE|RT|HIGHWAY|HWY|ROAD|RD)|ST (?:ROUTE|RTE|RT)|OHIO (?:ROUTE|HIGHWAY|HWY|STATE ROUTE)|OH|OHIO|SR|ST RT)\b(?=\s*\d)", "SR", a)
    a = re.sub(r"\b(?:COUNTY (?:HIGHWAY|HWY|ROAD|RD)|CO RD|CO HWY|CTY (?:HWY|RD)|CR)\b(?=\s*\d)", "CR", a)
    a = re.sub(r"\b(?:TOWNSHIP (?:HIGHWAY|HWY|ROAD|RD)|TWP (?:HWY|RD)|TWP|TR|T R)\b(?=\s*\d)", "TR", a)
    a = re.sub(r"\bHIGHWAY\b", "HWY", a)
    return re.sub(r"\b(US|SR|CR|TR|HWY|I) (\w+)\s*-\s*\w+", r"\1 \2", a)


ORD = {"FIRST": "1ST", "SECOND": "2ND", "THIRD": "3RD", "FOURTH": "4TH", "FIFTH": "5TH", "SIXTH": "6TH", "SEVENTH": "7TH",
       "EIGHTH": "8TH", "NINTH": "9TH", "TENTH": "10TH", "ELEVENTH": "11TH", "TWELFTH": "12TH"}


def street_key(a):
    """'2505 Monroe St' -> ('2505', 'MONROE'); '1000 OSAGE STREET' -> ('1000', 'OSAGE'); 'E Jefferson Ave' keeps 'JEFFERSON'."""
    if not isinstance(a, str):
        return None, None
    a = re.sub(r"[.,#]", " ", road(a))
    m = re.match(r"^\s*(\d+)[A-Z]?(?:\s*-\s*\d+[A-Z]?)?\s+(.*)$", a)
    if not m:
        return None, None
    words = [w for w in m.group(2).split() if w]
    if len(words) > 1 and words[0] in DIRS:
        words = words[1:]
    core = []
    for w in words:
        if w in TYPES and core:
            break
        core.append(w)
    core = [ORD.get(w, w) for w in core]
    return m.group(1), " ".join(core[:3]) or None


def street_compat(a, b):
    """Same street, or one is a whole-word prefix of the other (a record that truncates "1206 CENTAUR" = Centaur Village Dr)."""
    if not isinstance(a, str) or not isinstance(b, str) or not a or not b:
        return False
    return a == b or a.startswith(b + " ") or b.startswith(a + " ")


def street_nums(a):
    """'157-159 W Main St' -> {'157', '159'}; '2505 Monroe St' -> {'2505'}."""
    if not isinstance(a, str):
        return set()
    a = road(a)
    m = re.match(r"^\s*(\d+)[A-Z]?(?:\s*-\s*(\d+)[A-Z]?)?\s", a.upper() + " ")
    if not m:
        return set()
    lo = int(m.group(1)); hi = int(m.group(2)) if m.group(2) else lo
    if hi < lo:   # "1500-02"
        hi = int(str(lo)[: len(str(lo)) - len(m.group(2))] + m.group(2)) if m.group(2) else lo
    return {str(x) for x in range(lo, hi + 1, 2 if (hi - lo) % 2 == 0 else 1)} if 0 <= hi - lo <= 12 else {str(lo)}


def _names(*vals):
    out = []
    for v in vals:
        if not isinstance(v, str):
            continue
        v = re.sub(r"\s*\((?:MOBILE|MOBILE UNIT|COMMISSARY|CATERING|SPECIAL EVENT|SPEC EVENT|TEMP(?:ORARY)? EVENT|CP|INSIDE [^)]*)\)\s*$", "", v, flags=re.I)
        for part in re.split(r"\s*/\s*|\s+\bdba\b\s+|\s+&\s+(?=[A-Z][a-z])|\s*\(\s*|\s*\)\s*", v, flags=re.I):
            k = norm_name(re.sub(r"\b(?:LLC|INC|CORP|CORPORATION|LTD|CO)\b\.?", "", part, flags=re.I))
            if k and k not in out:
                out.append(k)
    return out


ONPREM = ("restaurant", "bar", "brewery")
CIN_DATE = "2026-10-24"   # Cincinnati Food Safety Program fetched (rows updated 2026-10-23; daily)
COL_DATE = "2026-10-24"   # Columbus Public Health facilities fetched (nightly)
# Records through: the fetch date minus 10 days (Cincinnati's last week of visits is still being entered: 10/16-10/22 hold 11-91 rows
# a day against 50-150 before)
CIN_THROUGH = "2026-10-14"


def _zip(z):
    z = re.sub(r"\D", "", str(z or ""))
    return z[:5] if len(z) >= 5 else ""


OTHER = re.compile(r"\((?:MOBILE|MOBILE UNIT|COMMISSARY|CATERING|SPECIAL EVENT|TEMP(?:ORARY)? EVENT)\)|\b(?:SCHOOLS?|ELEMENTARY|ELEM|MIDDLE SCHOOL|"
                   r"HIGH SCHOOL|ACADEMY|PRESCHOOL|CHILDCARE|CHILD CARE|CHILD DEVELOPMENT|DAYCARE|DAY CARE|HEADSTART|HEAD START|HOSPITAL|JAIL|"
                   r"DETENTION|CORRECTIONAL|JUV COURT|YOUTH CTR|FOOD BANK|SENIOR|NURSING|MOBILE|FOOD TRUCK|CATERING|CATERER|COMMISSARY|"
                   r"CONCESSIONS?|BOOSTERS?|PTA|PTO|BOARD OF EDUCATION|PUBLIC SCHOOLS|LITTLE LEAGUE|ATHLETIC ASSOCIATION|SNACK SHACK|CAMP|"
                   r"PORTABLE|STAND \d+|FRATERNITY|SORORITY|APARTMENTS?|APTS|RECREATION CENTER|REC CENTER|BOAT RAMP|SWIM CLUB|POOL)\b", re.I)


def _row(jur, lic, name, addr, city, z, la, lo, kind, active=True, ltype=None, holder=None, county=None, lhd=None, status=None):
    num, st = street_key(addr)
    if OTHER.search(name or ""):
        kind = "other"
    return {"jur": jur, "lic": lic, "name": name, "dba": name, "holder": holder, "keys": _names(name), "addr": addr, "city": city,
            "zip": _zip(z), "num": num, "street": st, "lat": la, "lon": lo, "kind": kind, "active": active, "ltype": ltype,
            "county": county, "lhd": lhd, "status": status}


def _cin_raw():
    d = pd.read_csv(f"{OFF}/cinci_food_safety.csv", dtype=str, low_memory=False)
    d["d"] = pd.to_datetime(d.ACTION_DATE, format="%m/%d/%Y %I:%M:%S %p", errors="coerce").dt.strftime("%Y-%m-%d")
    return d


def load_cincinnati(d=None):
    """One row per license number: its latest name, address, point and status. Live = latest status "Issued"."""
    d = _cin_raw() if d is None else d
    last = d.sort_values(["d", "ACTION_SEQUENCE"]).groupby("LICENSE_NO").tail(1)
    rows = []
    for _, r in last.iterrows():
        la = float(r.LATITUDE) if isinstance(r.LATITUDE, str) and r.LATITUDE else np.nan
        lo = float(r.LONGITUDE) if isinstance(r.LONGITUDE, str) and r.LONGITUDE else np.nan
        name = re.sub(r'^"|"$', "", r.BUSINESS_NAME.strip() if isinstance(r.BUSINESS_NAME, str) else "")
        rows.append(_row("cin", r.LICENSE_NO, name, r.ADDRESS.strip() if isinstance(r.ADDRESS, str) else "", "Cincinnati", r.POSTAL_CODE, la, lo, "food",
                         active=r.LICENSE_STATUS == "Issued" and r.d >= "2024-06-01", ltype="Food license",
                         county="Hamilton County", lhd="Cincinnati Health Department", status=r.LICENSE_STATUS))
    return pd.DataFrame(rows)


# Columbus Public Health business types (BUS_TYPE_DESCR) -> kind
COL_KIND = {"RESTAURANT": "restaurant", "BAR": "bar", "CARRYOUT": "food", "PIZZA SHOP": "restaurant", "COFFEE SHOP": "food", "BAKERY": "food",
            "PRIVATE CLUB": "venue", "HOTEL": "venue", "GROCERY STORE": "retail", "MICROMARKET": "retail", "GAS STATION": "retail",
            "RETAIL SHOP": "retail", "TOBACCO RETAILER": "retail", "VENDING @ FACILITY": "retail"}


def load_columbus():
    d = json.load(open(f"{OFF}/columbus_facilities.json"))
    rows = []
    for f in d["features"]:
        a, g = f["attributes"], f.get("geometry") or {}
        t = (a.get("BUS_TYPE_DESCR") or "").strip()
        rows.append(_row("col", "COL-" + a["PERMIT_ID"], (a.get("BUSINESS_NAME") or "").strip(), (a.get("SITE_ADDRESS") or "").strip(),
                         canon_city(a.get("CITY")), a.get("ZIP"), g.get("y", np.nan), g.get("x", np.nan), COL_KIND.get(t, "other"),
                         active=True, ltype=t.title() if t else None, county=None, lhd="Columbus Public Health",
                         status=a.get("STATUS_DESCRIP")))
        rows[-1]["facility"] = a.get("FACILITY_ID")
        rows[-1]["web_link"] = a.get("WEB_LINK")
        rows[-1]["risk"] = a.get("RISK_LEVEL")
        if (a.get("FACILITY_NAME") or "").strip() and a["FACILITY_NAME"].strip() != rows[-1]["name"]:
            rows[-1]["keys"] = _names(rows[-1]["name"], a["FACILITY_NAME"])
    return pd.DataFrame(rows)


def load():
    df = pd.concat([load_cincinnati(), load_columbus()], ignore_index=True)
    # one business can hold several records (Columbus: one permit per operation at a casino or stadium): same address and a name in common
    df["biz"] = np.arange(len(df))
    town = df.city.fillna("").str.upper().str.strip()
    for num, g in df[df.num.notna() & df.street.notna()].groupby("num"):
        idx = list(g.index)
        if len(idx) < 2 or len(idx) > 400:
            continue
        for x in range(len(idx)):
            for y in range(x + 1, len(idx)):
                a, b = idx[x], idx[y]
                if not street_compat(df.at[a, "street"], df.at[b, "street"]):
                    continue
                if not ((df.at[a, "zip"] and df.at[a, "zip"] == df.at[b, "zip"]) or (town[a] and town[a] == town[b])):
                    continue
                ka, kb = df.at[a, "keys"], df.at[b, "keys"]
                if not ka or not kb:
                    continue
                if any(name_sim(p, q) >= 85 or ((_stems(p) - GENERIC) & (_stems(q) - GENERIC)) for p in ka for q in kb):
                    old, new = df.at[b, "biz"], df.at[a, "biz"]
                    df.loc[df.biz == old, "biz"] = new
    return df


# ---------------------------------------------------------------- Cincinnati inspections: the City's own result, never recomputed
# Since the City's 2024 system change each row is one violation cited on one visit (ACTION_SEQUENCE), and ACTION_STATUS is that visit's
# result: "Approved - No Violations", "Approved - Minor Violations", "Approved - Violations Abated" (a follow-up that found the earlier
# violations corrected) or "Not In Compliance" (violations needing a follow-up). Before 2024 the field held each violation's own state
# (Abated / Not Abated) and no result, so those visits aren't shown. RECORDNUM_INSP groups a routine inspection's visits.
CIN_RESULTS = ["Approved - No Violations", "Approved - Minor Violations", "Approved - Violations Abated", "Not In Compliance"]


def cincinnati_visits(d=None):
    """One row per visit with a published result: license, date, inspection type and subtype, the City's result and the number of
    violations cited on that visit. Oldest first; nothing after CIN_THROUGH."""
    d = _cin_raw() if d is None else d
    d = d[d.ACTION_STATUS.isin(CIN_RESULTS) & d.d.notna() & (d.d <= CIN_THROUGH)]
    g = d.groupby(["LICENSE_NO", "ACTION_SEQUENCE"]).agg(d=("d", "first"), res=("ACTION_STATUS", lambda x: x.mode().iat[0]),
                                                         typ=("INSP_TYPE", "first"), sub=("INSP_SUBTYPE", "first"),
                                                         insp=("RECORDNUM_INSP", "first"), n=("CODE", lambda x: x.dropna().nunique()),
                                                         codes=("CODE", lambda x: sorted(set(x.dropna()))))
    g = g.reset_index().rename(columns={"LICENSE_NO": "lic"})
    g["seq"] = pd.to_numeric(g.ACTION_SEQUENCE, errors="coerce")
    return g.sort_values(["lic", "d", "seq"]).reset_index(drop=True)
