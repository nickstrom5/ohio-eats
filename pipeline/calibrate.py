"""How often is a map listing a real, licensed food business? Measured against official lists -> data/oh/calibration*.json

Adapted from mi-eats/pipeline/calibrate.py. Ohio has no statewide food-license list, so the test runs inside the two cities whose
health departments publish every licensed place in bulk:
- Columbus (with Worthington, which Columbus Public Health also serves): every permitted food service and retail food facility.
  Listings are tested inside the two cities' limits (Overture locality outlines), not by mailing town: "Columbus" mailing addresses
  reach into townships Franklin County Public Health serves.
- Cincinnati: every live Cincinnati Health Department food license, listings inside the city limits.
A match is the same business name nearby, or the same street address with a distinctive name word in common. Bars that serve no food
hold no food license, so "bar" listings undercount a little.
"""
import json
import numpy as np, pandas as pd
from shapely.geometry import shape, Point
from shapely.prepared import prep
from common import OH
from listings_util import official_match

o = pd.read_pickle(f"{OH}/stage1.pkl")
F = pd.read_pickle(f"{OH}/official.pkl")
from shapely import STRtree
_CN = json.load(open(f"{OH}/oh_counties_detail.geojson"))
_NAMES = list(_CN)
_GEOMS = [shape(_CN[n]).buffer(0.0003) for n in _NAMES]
_TREE = STRtree(_GEOMS)


def county_of(la, lo):
    if la != la:
        return None
    p = Point(lo, la)
    for i in _TREE.query(p):
        if _GEOMS[i].contains(p):
            return _NAMES[i]
    return None


o["county"] = [county_of(la, lo) for la, lo in zip(o.lat, o.lon)]
F["county"] = [county_of(la, lo) or (c if isinstance(c, str) and c else None)
               for la, lo, c in zip(F.lat, F.lon, F.get("county", pd.Series([None] * len(F))))]
_CITY = json.load(open(f"{OH}/cities_detail.geojson"))
_CP = {n: prep(shape(g).buffer(0.0005)) for n, g in _CITY.items()}


def in_city(names, la, lo):
    return la == la and any(_CP[n].contains(Point(lo, la)) for n in names)


o["city_area"] = [("Columbus" if in_city(["Columbus", "Worthington"], la, lo) else "Cincinnati" if in_city(["Cincinnati"], la, lo) else None)
                  for la, lo in zip(o.lat, o.lon)]
o.to_pickle(f"{OH}/stage1.pkl")
F.to_pickle(f"{OH}/official.pkl")
base = ~o.j_junk & ~o.j_outside
print("listings with a county:", int(o.county.notna().sum()), "of", len(o), "| inside Columbus/Worthington:", int((o.city_area == "Columbus").sum()),
      "| inside Cincinnati:", int((o.city_area == "Cincinnati").sum()))


def groups(L, app=False):
    s = L.src.fillna("none")
    if app:
        conf = L.confidence.fillna(0)
        return np.select([L.ov_closed | L.j_closedname, (s == "meta") & (conf >= 0.95), (s == "meta") & (conf >= 0.9),
                          s.isin(["AllThePlaces", "DAC"]), (s == "BrightQuery") & (conf >= 0.95), s == "meta"],
                         ["closed per Overture/name", "meta_high", "meta_mid", "brand_feed", "bq_high", "meta_low"], "other_sources")
    return np.select([L.closed21, L.ov_closed, (s == "meta") & L.in21, s == "meta", s.isin(["AllThePlaces", "DAC"]) & L.in21,
                      s.isin(["AllThePlaces", "DAC"]), L.in21, s == "Foursquare", s == "BrightQuery", s == "Microsoft"],
                     ["Google 2021 says closed", "Overture says closed", "Meta + open in Google 2021", "Meta only",
                      "brand feed + Google 2021", "brand feed only", "Foursquare/BrightQuery/Microsoft + Google 2021",
                      "Foursquare only", "BrightQuery only", "Microsoft only"], "other")


AREAS = {"Columbus": ("col", F.jur.eq("col") & F.active), "Cincinnati": ("cin", F.jur.eq("cin") & F.active)}
res, app = {}, {}
for label, (own, sel) in AREAS.items():
    L = o[base & (o.city_area == label)].reset_index(drop=True)
    R = F[sel & F.lat.notna()].reset_index(drop=True)
    m = official_match(L, R)
    L["hit"] = L.index.map(lambda i: i in m)
    L["hit_food"] = L.index.map(lambda i: i in m and R.kind.iat[m[i]] in ("restaurant", "bar", "brewery", "food"))
    for mode, store in ((False, res), (True, app)):
        L["grp"] = groups(L, mode)
        t = L.groupby("grp").agg(n=("id", "size"), official=("hit", "mean"), food=("hit_food", "mean")).sort_values("n", ascending=False)
        print(f"\n== {label} ({'app grouping' if mode else 'web grouping'}): {len(L)} listings, {len(R)} official records")
        print(t.assign(official=(t.official * 100).round(1), food=(t.food * 100).round(1)).to_string())
        store[label] = {"listings": int(len(L)), "official_records": int(len(R)),
                        "groups": {g: {"n": int(r.n), "official": round(float(r.official), 3), "food": round(float(r.food), 3)} for g, r in t.iterrows()}}
    # the other direction: how many of the city's licensed places to eat do the (cleaned, open) map listings hold?
    keepish = ~(L.ov_closed | L.j_closedname | L.closed21)
    got = set(R.biz.iloc[[m[i] for i in L.index[keepish] if i in m]])
    Rr = R[R.kind.isin(["restaurant", "bar", "food"])].drop_duplicates("biz")
    cover = float(np.mean([b in got for b in Rr.biz])) if len(Rr) else None
    print(f"{label}: licensed food businesses found among open map listings: {cover*100:.1f}% of {len(Rr)}")
    res[label]["coverage"] = round(cover, 3)
    res[label]["official_food"] = int(len(Rr))

# per county: map listings that pass the first cleaning, and where inspection results can be read
PER = o[base].groupby("county").agg(listings=("id", "size"))
json.dump({"areas": res, "per_county": {c: {k: (round(float(v), 3) if isinstance(v, float) else int(v)) for k, v in r.items() if v == v}
                                          for c, r in PER.iterrows()},
           "unplaced_official_records": int(F.lat.isna().sum())},
          open(f"{OH}/calibration.json", "w"), indent=1)
json.dump(app, open(f"{OH}/calibration_app.json", "w"), indent=1)
