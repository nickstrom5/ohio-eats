"""Writes data/research/app/*.json (hand-checked Michigan guides) and data/research/jbf.json from the compact lists below.

Each entry cites the 2025-26 page that names it (robots-checked host: check_sources.py). The address comes from the official record or
map listing we already hold for that name in that town (site/ohio.json), never from memory; a name that isn't found once in its
town is left out and listed in data/research/app/LEADS.md. Where the press page is undated, the place's active MDARD food-service
license (read 2026-10-22) or, in Detroit, a 2025-26 routine inspection is the evidence it's operating; places with neither stay out.
Usage: ../.venv/bin/python build_research.py   (then michigan.py)"""
import json, os, re
ROOT = os.path.join(os.path.dirname(__file__), "..")
R = os.path.join(ROOT, "data", "research")
d = json.load(open(os.path.join(ROOT, "site", "ohio.json")))
C, M = d["cols"], d["meta"]
INSP = {sp[0]: sp for sp in d["sparse"]["insp"]}
norm = lambda s: re.sub(r"\s+", " ", re.sub(r"[^a-z0-9 ]", " ", (s or "").lower().replace("'", "").replace("’", ""))).strip()

MDARD = "https://www.arcgis.com/home/item.html?id=f6232e1305d444f7a649b5defaa5f861"
DET = "https://data.detroitmi.gov/datasets/restaurant-inspections"
VD_CONEY = "https://visitdetroit.com/inside-the-d/coney-island/"
DD_PIZZA = "https://www.deadlinedetroit.com/articles/32857/metro_times_ranks_25_detroit-style_pizzas_with_loui_s_being_1"
UP_PASTY = "https://www.uptravel.com/things-to-do/arts-history-and-culture/pasties/"
WXYZ_PACZKI = "https://www.wxyz.com/news/paczki-day-2026-where-you-can-get-paczki-in-metro-detroit"
VD_DEARBORN = "https://visitdetroit.com/inside-the-d/destination-dearborn/"
UP_FOODS = "https://www.uptravel.com/blog/post/unique-foods/"   # dated Jul. 01, 2025 on the page

# (name as the source writes it, town, [street number the source gives, if any], kinds, dishes, note, founded, founded_note, source)
GUIDES = {
 "coney": [
  ("American Coney Island", "Detroit", "114", "Next door to Lafayette on W. Lafayette Blvd.; known for its homemade, slightly spicier chili and the bigger dining room.", 1917, "Visit Detroit: open since 1917."),
  ("Lafayette Coney Island", "Detroit", "118", "The other half of downtown's side-by-side coney rivalry, with a meatier chili.", None, None),
  ("Duly's Place", "Detroit", "5458", "Southwest Detroit coney island on W. Vernor Hwy.", None, None),
  ("Coney Man", "Detroit", "3031", None, None, None),
  ("Coney Town", "Detroit", "200", None, None, None),
  ("Detroit One Coney Island", "Detroit", "3433", None, None, None),
  ("Main Street Grill & Coney Island", "Detroit", "1985", None, None, None),
  ("Olympic Grill", "Detroit", "119", None, None, None),
  ("Woodward Coney Island", "Detroit", "616", None, None, None),
  ("Zeff's Coney Island", "Detroit", "2469", None, None, None),
 ],
 "detroit-style pizza": [
  ("Loui's Pizza", "Hazel Park", "23141", "Ranked first of 25 Detroit-style pizzas in Metro Times' February 2025 list.", None, None),
  ("Michigan & Trumbull", "Detroit", "1331", None, None, None),
  ("Cloverleaf Bar & Restaurant", "Eastpointe", "24443", None, None, None),
  ("Buddy's Pizza", "Detroit", "17125", "The Conant Street original of the square-pizza chain.", None, None),
  ("Z's Villa", "Detroit", "42", None, None, None),
  ("Grandma Bob's Pizza", "Detroit", "2135", None, None, None),
 ],
 "pasty": [
  ("Dobber's Pasties", "Iron Mountain", "1402", None, None, None),
  ("Hiawatha Pasties", "Naubinway", None, None, None, None),
  ("Joe's Pasty Shop", "Ironwood", "116", None, None, None),
  ("Lehto's Pasties", "St. Ignace", "1983", None, None, None),
  ("Muldoons Pasties & Gifts", "Munising", "1246", None, None, None),
  ("Roy's Pasties and Bakery", "Houghton", "305", None, None, None),
 ],
 "paczki": [
  ("New Palace Bakery", "Hamtramck", "9833", "Hamtramck's best-known pączki line on Fat Tuesday.", None, None),
  ("The Family Donut Shop", "Hamtramck", "11300", None, None, None),
  ("Chene Modern Bakery", "Detroit", "17041", None, None, None),
  ("The Looney Baker", "Livonia", "13931", None, None, None),
  ("Tringali's Bakery", "Warren", "29100", None, None, None),
  ("GM Paris Bakery", "Livonia", "28418", None, None, None),
  ("Knapp's Donut Shop", "Rochester", "500", None, None, None),
  ("Donut Villa", "Detroit", "5875", None, None, None),
  ("Apple Fritter Donut Shop", "Ferndale", "741", None, None, None),
  ("Donut Kastle", "Taylor", "24555", None, None, None),
  ("Tasty Boy Donuts", "Flat Rock", "28345", None, None, None),
  ("Avon Donuts", "Pontiac", "45324", None, None, None),
  ("Donut Cutter", "Berkley", "28173", None, None, None),
 ],
 "fish fry": [   # Great Lakes fish (whitefish, smoked fish, fish and chips); the page's fish markets aren't places to eat in our data
  ("Cap'n Ron's Fish 'N' Chips", "Munising", "1336", "Fish baskets, sandwiches and smoked fish dip.", None, None),
  ("Four Suns Fish & Chips", "Hancock", "49813", "Fish and chips in the Keweenaw.", None, None),
  ("Thill and Sons Fish House", "Marquette", "250", "Marquette's fish house.", None, None),
 ],
 "middle eastern": [
  ("Al Ameer", "Dearborn", "12710", "Lebanese; a James Beard America's Classic (2016).", None, None),
  ("Sheeba Restaurant", "Dearborn", None, "Yemeni.", None, None),
  ("Shatila Bakery", "Dearborn", "14300", "Middle Eastern pastries.", None, None),
  ("Masri Sweets", "Dearborn", "5755", "Baklava and Palestinian kunafa.", None, None),
  ("Lebon Sweets", "Dearborn", None, "Lebanese desserts.", None, None),
  ("Malek Al Kabob", "Dearborn", None, "Kabobs and shawarma.", None, None),
  ("Al Tayyeb", "Dearborn", None, "Lebanese breakfast.", None, None),
  ("Shamiat", "Dearborn", None, "Syrian-inspired.", None, None),
  ("House of Sesame", "Dearborn", None, "Lebanese kaak bread.", None, None),
  ("Sana'a", "Dearborn", None, "Yemeni.", None, None),
  ("Dearborn Meat Market", "Dearborn", None, "Middle Eastern grilled meats.", None, None),
  ("Qahwa House", "Dearborn", None, "Yemeni coffee and tea.", None, None),
  ("Bayt Al Mocha", "Dearborn", None, "Yemeni coffee.", None, None),
  ("Haraz", "Dearborn", None, "Yemeni coffee house.", None, None),
  ("Dellah Coffee & Brunch House", "Dearborn", None, "Yemeni and American brunch.", None, None),
 ],
}
SRC = {"coney": VD_CONEY, "detroit-style pizza": DD_PIZZA, "pasty": UP_PASTY, "paczki": WXYZ_PACZKI, "middle eastern": VD_DEARBORN, "fish fry": UP_FOODS}
DATED = {DD_PIZZA, WXYZ_PACZKI, UP_FOODS}   # pages dated 2025-26 on their face; the others are current (c) 2026 tourism pages, undated

JBF = [  # (name, town, honors, source)
 ("Al Ameer", "Dearborn", "12710", ["America's Classics 2016"], "https://archive.jamesbeard.org/blog/2016-americas-classic-al-ameer-restaurant"),
 ("Zehnder's of Frankenmuth", "Frankenmuth", "730", ["America's Classics 2020"], "https://www.jamesbeard.org/stories/2020-americas-classics"),
 ("The Cooks' House", "Traverse City", "115", ["Best Chef: Great Lakes finalist 2025 (Jennifer Blakeslee and Eric Patterson)"], "https://www.jamesbeard.org/stories/2025-james-beard-awards-restaurant-and-chef-nominees"),
 ("Selden Standard", "Detroit", "3921", ["Outstanding Restaurant semifinalist 2025"], "https://www.jamesbeard.org/stories/the-2025-james-beard-award-semifinalists"),
 ("Vecino", "Detroit", "4100", ["Best New Restaurant semifinalist 2025"], "https://www.jamesbeard.org/stories/the-2025-james-beard-award-semifinalists"),
 ("Baobab Fare", "Detroit", "6568", ["Outstanding Hospitality semifinalist 2025"], "https://www.jamesbeard.org/stories/the-2025-james-beard-award-semifinalists"),
 ("BARDA Detroit", "Detroit", "4842", ["Best Chef: Great Lakes semifinalist 2025 and 2026 (Javier Bardauil)"], "https://www.jamesbeard.org/stories/the-2025-james-beard-award-semifinalists"),
 ("Pennyroyal Cafe & Provisions", "Saugatuck", "3319", ["Best Chef: Great Lakes semifinalist 2025 (Missy Corey)"], "https://www.jamesbeard.org/stories/the-2025-james-beard-award-semifinalists"),
 ("Miss Kim", "Ann Arbor", "415", ["Best Chef: Great Lakes semifinalist 2025 (Ji Hye Kim)"], "https://www.jamesbeard.org/stories/the-2025-james-beard-award-semifinalists"),
 ("Ladder 4 Wine Bar", "Detroit", "3396", ["Best Chef: Great Lakes semifinalist 2025 and 2026 (John Yelinek)"], "https://www.jamesbeard.org/stories/the-2025-james-beard-award-semifinalists"),
 ("Modern Bird", "Traverse City", "541", ["Best Chef: Great Lakes semifinalist 2026 (Andy Elliott and Emily Stewart)"], "https://www.wxyz.com/news/several-michigan-chefs-restaurants-names-james-beard-award-semifinalists"),
 ("PostBoy", "New Buffalo", "207", ["Best Chef: Great Lakes semifinalist 2026 (James Galbraith)"], "https://www.wxyz.com/news/several-michigan-chefs-restaurants-names-james-beard-award-semifinalists"),
 ("Echelon Kitchen and Bar", "Ann Arbor", "200", ["Best New Restaurant semifinalist 2026"], "https://www.wxyz.com/news/several-michigan-chefs-restaurants-names-james-beard-award-semifinalists"),
]


def find(name, town, num):
    k = norm(name)
    hits = [i for i, n in enumerate(C["name"]) if C["city"][i] is not None and M["cities"][C["city"][i]] == town
            and (norm(n) == k or norm(n).startswith(k + " ") or k.startswith(norm(n) + " ") or norm(n).replace(" ", "") == k.replace(" ", ""))]
    if num:
        hits = [i for i in hits if (C["addr"][i] or "").split(" ")[0].lstrip("GW") == num]
    return hits


def add_one(out, kind, name, town, note, founded, fnote, i):
    official = C["tier"][i] == 2
    insp = INSP.get(i)
    live = official or (insp and (insp[3] or "") >= "2025-01-01") or SRC[kind] in DATED
    if not live:
        leads.append(f"- {kind}: {name} ({town}) — undated source and no active license matched; not added"); return
    srcs = [SRC[kind]] + ([MDARD] if official else []) + ([DET] if insp else [])
    out.append({"name": C["name"][i], "address": C["addr"][i], "city": town, "zip": str(C["zip"][i]) if C["zip"][i] else None,
                "kinds": [kind], "dishes": [], "note": note, "founded": founded, "founded_note": fnote, "website": None, "open": True,
                "evidence_date": "2026-10", "sources": srcs, "match_names": [name.upper()] if norm(name) != norm(C["name"][i]) else []})


# street addresses as the dated page prints them, for places the map data lacks
ADDR = {"Chene Modern Bakery": "17041 W Warren Ave", "Tringali's Bakery": "29100 Schoenherr Rd"}

leads, n_out = [], {}
for kind, rows in GUIDES.items():
    out = []
    for name, town, num, note, founded, fnote in rows:
        hits = find(name, town, num)
        if len(hits) > 1:   # one business, several licensed branches in the town (Sheeba, Haraz): every licensed one
            lic = [i for i in hits if C["tier"][i] == 2]
            hits = lic if lic else hits
        if not hits and SRC[kind] in DATED and isinstance(num, str) and name in ADDR:
            # a dated 2025-26 page with a street address, for a place the map data lacks: placed from that address (michigan.py geocodes it)
            out.append({"name": name, "address": ADDR[name], "city": town, "zip": None, "kinds": [kind], "dishes": [], "note": note,
                        "founded": founded, "founded_note": fnote, "website": None, "open": True, "evidence_date": "2026-10",
                        "sources": [SRC[kind]], "match_names": []})
            continue
        if len(hits) != 1 and not (len(hits) > 1 and all(C["tier"][i] == 2 for i in hits)):
            leads.append(f"- {kind}: {name} ({town}{', ' + num if num else ''}) — {len(hits)} matches in our data; not added"); continue
        for i in hits:
            add_one(out, kind, name, town, note, founded, fnote, i)
    fn = re.sub(r"[^a-z]+", "_", kind).strip("_")
    json.dump(out, open(f"{R}/app/{fn}.json", "w"), indent=1, ensure_ascii=False)
    n_out[kind] = len(out)
jb = []
for name, town, num, honors, src in JBF:
    hits = find(name, town, num)
    if len(hits) != 1:
        leads.append(f"- James Beard: {name} ({town}) — {len(hits)} matches; not added"); continue
    i = hits[0]
    jb.append({"name": C["name"][i], "address": C["addr"][i], "city": town, "zip": None, "honors": honors, "open": True,
               "sources": [src] + ([MDARD] if C["tier"][i] == 2 else []), "match_names": [name.upper()]})
json.dump(jb, open(f"{R}/jbf.json", "w"), indent=1, ensure_ascii=False)
open(f"{R}/app/LEADS.md", "w").write("# Michigan research leads (not yet verified)\n\nWritten by pipeline/build_research.py.\n\n" + "\n".join(leads) + """

## Not started
- Great Lakes fish: 3 places (UP Travel, Jul 2025). Its fish markets (Gustafson's and King's in Moran, Manley's in St. Ignace, Peterson's in
  Hancock) aren't in our data as places to eat, and the page gives no addresses. Lenten fish fries are parish/VFW events, not restaurants.
  Supper clubs (Alice's in Iron River, Whistle Stop in Menominee: UP Travel listings, undated; Nutini's in Hancock) need a dated source.
- Flint-style coneys (Angelo's, Starlite, Koegel's): no 2025-26 page on a usable host yet.
- hourdetroit.com answers Claude's fetcher with 403 (2026-10-23): treat it as blocked, like Metro Times. UP Travel's "since 1946" for Joe's
  Pasty Shop is from a 2021 page, too old for the 2025-26 rule.
- Oldest places beyond American Coney Island (1917): Buddy's (1946 at Conant), Joe's Pasty Shop (1946), Lehto's (1947), Zehnder's (1929):
  each needs a source that says it opened at this address.
- Elephant & Co. (Detroit, Metro Times #5 pizza 2025): not in our data; Bar Chenin (James Beard Best New Bar finalist 2026) is inside
  the Siren Hotel and not in our data as its own place.
""")
print(n_out, "| James Beard:", len(jb), "| leads:", len(leads))
