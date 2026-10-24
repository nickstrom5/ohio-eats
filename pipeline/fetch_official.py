"""Official Ohio records -> data/raw/official/ (git-ignored). Every host was robots-checked first (check_sources.py).

- Cincinnati Health Department "Cincinnati Food Safety Program" (data.cincinnati-oh.gov rg6p-b3h3, Public Domain, daily):
  the portal's own CSV download, one row per violation (or per inspection with none).
- Columbus Public Health "Restaurant & Market Health Inspections" (maps2.columbus.gov Schemas/Health/MapServer/3, CC0, nightly):
  one row per permitted facility, paged through the layer's query endpoint (2,000 per page).
"""
import json, os, sys, time
import requests

OUT = os.path.join(os.path.dirname(__file__), "..", "data", "raw", "official")
UA = {"User-Agent": "OhioEatsSourceCheck/1.0 (+nick@eatsranked.com)"}
os.makedirs(OUT, exist_ok=True)


def cincinnati():
    r = requests.get("https://data.cincinnati-oh.gov/api/views/rg6p-b3h3/rows.csv?accessType=DOWNLOAD", headers=UA, timeout=600)
    r.raise_for_status()
    open(f"{OUT}/cinci_food_safety.csv", "wb").write(r.content)
    print("cincinnati bytes", len(r.content))


def columbus():
    url = "https://maps2.columbus.gov/arcgis/rest/services/Schemas/Health/MapServer/3/query"
    feats, off = [], 0
    while True:
        r = requests.get(url, params={"where": "1=1", "outFields": "*", "outSR": 4326, "f": "json", "resultOffset": off,
                                      "resultRecordCount": 2000, "orderByFields": "OBJECTID"}, headers=UA, timeout=120)
        r.raise_for_status()
        d = r.json()
        got = d.get("features", [])
        feats += got
        if not got or not d.get("exceededTransferLimit"):
            break
        off += len(got)
        time.sleep(1)
    json.dump({"fetched": time.strftime("%Y-%m-%d"), "features": feats}, open(f"{OUT}/columbus_facilities.json", "w"))
    print("columbus facilities", len(feats))


if __name__ == "__main__":
    which = sys.argv[1:] or ["cincinnati", "columbus"]
    for w in which:
        globals()[w]()
