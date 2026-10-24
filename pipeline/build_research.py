"""Writes data/research/app/*.json (hand-checked Ohio guides), data/research/jbf.json and data/research/closed.json from the compact
lists below.

Every entry needs two things, both on robots-checked hosts (check_sources.py):
- a page that names it for the guide (any date: a tourism board, Ohio Magazine, local press, the place's own site), and
- 2025-26 evidence that it operates: a dated 2025-26 page ("dated"), its own live site showing current hours or ordering when we
  fetched it ("site", recorded with the fetch date), or, in Cincinnati, a City inspection visit in 2025 or 2026 ("city").
The address comes from the official record or map listing we already hold for that name in that town (site/ohio.json), never from
memory; a name that isn't found once in its town is left out and listed in data/research/app/LEADS.md. A founding year is set only
when a source says the place opened at this address; a brand's or a family's founding year goes in the note.
Usage: ../.venv/bin/python build_research.py   (then ohio.py)"""
import json, os, re
ROOT = os.path.join(os.path.dirname(__file__), "..")
R = os.path.join(ROOT, "data", "research")
os.makedirs(f"{R}/app", exist_ok=True)
d = json.load(open(os.path.join(ROOT, "site", "ohio.json")))
C, M = d["cols"], d["meta"]
INSP = {sp[0]: sp for sp in d["sparse"]["insp"]}
norm = lambda s: re.sub(r"\s+", " ", re.sub(r"[^a-z0-9 ]", " ", (s or "").lower().replace("'", "").replace("’", ""))).strip()
FETCHED = "2026-10-24"   # the day the places' own sites were read

CIN = "https://data.cincinnati-oh.gov/Thriving-Neighborhoods/Cincinnati-Food-Safety-Program/rg6p-b3h3"
WCPO_CHILI = "https://www.wcpo.com/news/insider/top-9-cincinnati-chili-parlors"            # undated
CB_CHILI = "https://www.citybeat.com/food-drink/20-cincinnati-style-chili-parlors-you-should-have-tried-by-now-12699366/"   # Feb 2022
OM_30 = "https://www.ohiomagazine.com/food-drink/article/30-famous-ohio-food-spots"         # Mar/Apr 2023
OM_HUNG = "https://ohiomagazine.com/food-drink/article/how-toledo-invented-the-hungarian-hot-dog"   # Jul/Aug 2026
OM_OLD = "https://www.ohiomagazine.com/food-drink/article/eat-at-12-of-ohios-oldest-restaurants"   # Mar/Apr 2026
OM_PIZZA = "https://www.ohiomagazine.com/food-drink/article/3-ohio-pizza-styles-and-where-to-get-them"   # Mar/Apr 2022
OM_AMISH = "https://www.ohiomagazine.com/food-drink/article/12-restaurants-to-try-in-ohio-s-amish-country"
DHG = "https://dhgroup.com/"   # Dutchman Hospitality Group: its 2026 site lists its Amish Country restaurants
N5_PIEROGI = "https://www.news5cleveland.com/lifestyle/food/national-pierogi-day-where-to-eat-the-best-pierogi-in-cleveland"   # undated
SI_PERCH = "https://www.shoresandislands.com/blog/post/top-8-places-to-enjoy-perch-in-ohios-lake-erie-shores-islands/"   # Jul 2014
DATED = {OM_HUNG, OM_OLD}

# guide -> rows of (name as the source writes it, town, street number, note, founded (at this address), founded note,
#                   [sources], evidence: "dated" | "site" | "city")
GUIDES = {
 "cincinnati chili": [
  ("Camp Washington Chili", "Cincinnati", "3005", "Open around the clock six days a week (closed Sundays), on the corner of Hopple and Colerain since 1940 per its own site; a James Beard Regional (America's) Classic.",
   None, None, [WCPO_CHILI, OM_30, "https://www.campwashingtonchili.com/"], "site"),
  ("Price Hill Chili", "Cincinnati", "4920", "A west side institution since 1962 (its own site), with breakfast, goetta included, served all day.", None, None,
   [WCPO_CHILI, "https://www.pricehillchili.com/"], "site"),
  ("Pleasant Ridge Chili", "Cincinnati", "6032", "Family-run neighborhood parlor on Montgomery Road; cash only.", None, None, [WCPO_CHILI, "https://www.pleasantridgechili.com/"], "city"),
  ("Blue Jay Restaurant", "Cincinnati", "4154", "Northside diner and chili parlor on Hamilton Avenue.", None, None, [CB_CHILI], "city"),
  ("Blue Ash Chili Original", "Blue Ash", "9565", "The original Blue Ash Chili, known for its six-way and its oversized chili challenge.", None, None,
   [WCPO_CHILI, "https://www.blueashchili.com/"], "site"),
  ("Blue Ash Chili", "Springdale", "11711", "Blue Ash Chili's Tri-County location.", None, None, [CB_CHILI, "https://www.blueashchili.com/"], "site"),
 ],
 "goetta": [
  ("Price Hill Chili", "Cincinnati", "4920", "Goetta, eggs, home fries and French toast, served all day (its own site).", None, None, ["https://www.pricehillchili.com/"], "site"),
 ],
 "eastern european": [
  ("Slyman's Restaurant", "Cleveland", "3106", "Cleveland's corned beef institution on St. Clair Avenue (Ohio Magazine: since 1964); weekdays only.", None, None,
   [OM_30, "https://www.slymans.com/"], "site"),
  ("Rudy's Strudel & Bakery", "Parma", "5580", "Parma bakery making its own pierogi, strudel and kolachi since 1948 (its own site).", None, None,
   [N5_PIEROGI, "https://www.rudysstrudel.com/"], "site"),
  ("Corbo's Bakery", "Cleveland", "12210", "Little Italy bakery (since 1958, its own site) known for Cleveland's strawberry-and-custard cassata cake.", None, None,
   ["https://corbosbakery.net/"], "site"),
 ],
 "barberton chicken": [
  ("Belgrade Gardens", "Barberton", "401", "Where Barberton chicken began: “Famous Chicken Dinners Since 1933” (its own site), with hot rice, coleslaw and fries.", None, None,
   [OM_30, "http://belgradegardenschicken.com/"], "site"),
  ("Hopocan Gardens", "Norton", "4396", "Barberton-style chicken with hot rice on the Barberton–Norton line.", None, None, ["https://hopocangardens.com/"], "site"),
 ],
 "hungarian": [
  ("Tony Packo's", "Toledo", "1902", "The original Tony Packo's in Toledo's Birmingham neighborhood, home of the Hungarian hot dog.", 1932,
   "Ohio Magazine (Jul/Aug 2026) calls 1902 Front St. the original location; Est. 1932 (Ohio Magazine, Mar/Apr 2026).", [OM_HUNG, OM_OLD, "https://www.tonypackos.com/"], "dated"),
  ("Tony Packo's", "Sylvania", "5822", "Tony Packo's Sylvania location on Alexis Road.", None, None, ["https://www.tonypackos.com/"], "site"),
 ],
 "lake erie perch": [
  ("Brennan's Fish House", "Grand River", "102", "Fresh lake walleye and yellow perch, 50 feet from the Grand River.", None, None, ["https://www.brennansfishhouse.com/"], "site"),
  ("Dock's Beach House Restaurant", "Port Clinton", "252", "Beachfront spot serving fresh-caught Lake Erie perch and walleye.", None, None, [SI_PERCH, "https://docksbeachhouse.com/"], "site"),
  ("Hidden Beach Bar", "Lakeside Marblehead", "530", "Seasonal harborside bar with a Lake Erie perch sandwich on a brioche bun.", None, None,
   ["https://www.hiddenbeachbar.com/"], "site"),
 ],
 "amish": [
  ("Der Dutchman", "Walnut Creek", "4967", "Homestyle Amish cooking and broasted chicken in the heart of Holmes County.", None, None, [OM_30, DHG], "site"),
  ("Dutch Valley Restaurant", "Sugarcreek", "1343", "Homestyle meals and a bakery from the Dutchman Hospitality Group.", None, None, [DHG], "site"),
  ("Berlin Farmstead", "Berlin", "4757", "Farm-style Amish Country cooking in Berlin.", None, None, [DHG], "site"),
  ("Boyd & Wurthmann Restaurant", "Berlin", "4819", "Berlin's homestyle counter-and-dining-room restaurant (since 1938, its own site).", None, None, ["https://boydandwurthmann.com/"], "site"),
  ("Mary Yoder's Amish Kitchen", "Middlefield", "14743", "Old-fashioned Amish cooking in Geauga County's Amish settlement.", None, None, ["https://www.maryyodersamishkitchen.com/"], "site"),
  ("Amish Door", "Wilmot", "1210", "Began in 1977 as a 48-seat restaurant; a daily buffet and bakery (its own site).", None, None, ["https://www.amishdoor.com/"], "site"),
 ],
 "ohio pizza": [
  ("Marion's Piazza", None, None, "Thin-crust, square-cut “Dayton-style” pizza (its own menu), established 1965.", None, None, ["https://www.marionspiazza.com/"], "site"),
  ("Rubino's Pizza", "Columbus", "2643", "Columbus-style thin crust in Bexley since 1954 (its own site); cash only.", None, None, [OM_PIZZA, "https://www.rubinosofbexley.com/"], "site"),
  ("Terita's Pizza", "Columbus", "3905", "North End Columbus-style pizza for over 60 years (its own site).", None, None, [OM_PIZZA, "https://teritas.com/"], "site"),
  ("Iggy's Pizza", "Toronto", "1332", "Ohio Valley-style square slices (its own site).", None, None, [OM_PIZZA, "https://www.iggyspizza.com/"], "site"),
  ("Wedgewood Fernando's Pizza", None, None, "Youngstown-area pizzeria Ohio Magazine names for Brier Hill-style pizza.", None, None, [OM_PIZZA, "https://www.wedgewoodpizza.com/"], "site"),
 ],
}
# kinds as ohio.py's tag rules read them
KIND = {"cincinnati chili": "cincinnati chili", "goetta": "goetta", "eastern european": "eastern european", "barberton chicken": "barberton chicken",
        "hungarian": "hungarian hot dog", "lake erie perch": "lake erie perch", "amish": "amish", "ohio pizza": "ohio pizza"}
# a chain the guide lists everywhere it's found in our data (its own site lists the locations)
EVERY = {"Marion's Piazza", "Wedgewood Fernando's Pizza"}

JBF_2025 = "https://www.jamesbeard.org/stories/the-2025-james-beard-award-semifinalists"
JBF_2026 = "https://www.jamesbeard.org/stories/james-beard-award-semifinalists-2026"
CN_2026 = "https://www.columbusnavigator.com/?p=71370"   # Apr 6, 2026: the 2026 finalists
JBF = [
 ("Cordelia", "Cleveland", None, ["Best Chef: Great Lakes finalist 2026 (Vinnie Cimino)", "Best Chef: Great Lakes semifinalist 2025"], [JBF_2026, CN_2026, JBF_2025]),
 ("Sudova", "Cincinnati", None, ["Best Chef: Great Lakes finalist 2026 (Sarah Dworak)"], [JBF_2026, CN_2026]),
 ("Nolia Kitchen", "Cincinnati", None, ["Best Chef: Great Lakes finalist 2026 (Jeffery Harris)"], [JBF_2026, CN_2026]),
 ("Kiki", "Cincinnati", None, ["Best Chef: Great Lakes semifinalist 2026 (Hideki Harada)"], [JBF_2026]),
 ("Longfellow", "Cincinnati", None, ["Outstanding Professional in Cocktail Service semifinalist 2025 and 2026 (Mike Stankovich)"], [JBF_2026, JBF_2025]),
 ("Mallorca", "Cleveland", None, ["Outstanding Hospitality semifinalist 2026"], [JBF_2026]),
 ("Dan The Baker", "Columbus", None, ["Outstanding Bakery semifinalist 2025 and 2026"], [JBF_2026, JBF_2025]),
 ("The Aperture", "Cincinnati", None, ["Emerging Chef semifinalist 2025 (Jordan Anthony-Brown)"], [JBF_2025]),
 ("Larder", "Cleveland", None, ["Best Chef: Great Lakes semifinalist 2025 (Jeremy Umansky)", "Outstanding Pastry Chef or Baker semifinalist 2025 (Alexandra La Valle)"], [JBF_2025]),
 ("Law Bird", "Columbus", None, ["Outstanding Bar semifinalist 2025"], [JBF_2025]),
 ("Wildweed", "Cincinnati", None, ["Best Chef: Great Lakes semifinalist 2025 (David Jackman)"], [JBF_2025]),
 ("Agni", "Columbus", None, ["Best Chef: Great Lakes semifinalist 2025 (Avishar Barua)"], [JBF_2025]),
 ("Amba", "Cleveland", None, ["Outstanding Restaurateur semifinalist 2025 (Douglas Katz and Todd Thompson, Edgewater Hospitality)"], [JBF_2025]),
 ("Zhug", "Cleveland Heights", None, ["Outstanding Restaurateur semifinalist 2025 (Douglas Katz and Todd Thompson, Edgewater Hospitality)"], [JBF_2025]),
 ("Kiln", "Cleveland", None, ["Outstanding Restaurateur semifinalist 2025 (Douglas Katz and Todd Thompson, Edgewater Hospitality)"], [JBF_2025]),
 ("Camp Washington Chili", "Cincinnati", "3005", ["America's Classics (Regional Classics award)"], ["https://www.campwashingtonchili.com/"]),
]

# verified closed (with a source we may use): they come off the list whatever the map data says
CLOSED = [
 {"name": "Sokolowski's University Inn", "city": "Cleveland", "address": "1201 University Rd", "match_names": ["SOKOLOWSKIS UNIVERSITY INN"],
  "note": "Closed in 2020; the family retired and sold the building (James Beard America's Classic 2014).",
  "sources": ["https://www.news5cleveland.com/news/local-news/oh-cuyahoga/breathing-new-life-into-the-old-sokolowskis-restaurant-site-in-cleveland"]},
]


def find(name, town, num):
    k = norm(name)
    hits = [i for i, n in enumerate(C["name"]) if (town is None or (C["city"][i] is not None and M["cities"][C["city"][i]] == town))
            and (norm(n) == k or norm(n).startswith(k + " ") or k.startswith(norm(n) + " ") or norm(n).replace(" ", "") == k.replace(" ", ""))]
    if num:
        hits = [i for i in hits if (C["addr"][i] or "").split(" ")[0] == num]
    return hits


def evidence_ok(ev, srcs, i):
    if ev == "dated":
        return any(s in DATED for s in srcs)
    if ev == "site":
        return True   # its own site, read on FETCHED, showed current hours or ordering
    insp = INSP.get(i)   # "city": a Cincinnati visit in 2025 or 2026
    return bool(insp) and insp[7] == 0 and (insp[3] or "") >= "2025-01-01"


leads, n_out = [], {}
for kind, rows in GUIDES.items():
    out = []
    for name, town, num, note, founded, fnote, srcs, ev in rows:
        hits = find(name, town, num)
        if len(hits) > 1 and name not in EVERY:
            lic = [i for i in hits if C["tier"][i] == 2]
            hits = lic if len(lic) == 1 else hits
        if not hits or (len(hits) > 1 and name not in EVERY):
            leads.append(f"- {kind}: {name} ({town or 'every location'}{', ' + num if num else ''}) — {len(hits)} matches in our data; not added"); continue
        for i in hits:
            if not evidence_ok(ev, srcs, i):
                leads.append(f"- {kind}: {name} ({town}) — no 2025-26 evidence it operates ({ev}); not added"); continue
            city = M["cities"][C["city"][i]]
            out.append({"name": C["name"][i], "address": C["addr"][i], "city": city, "zip": str(C["zip"][i]) if C["zip"][i] else None,
                        "kinds": [KIND[kind]], "dishes": [], "note": note, "founded": founded, "founded_note": fnote, "website": None,
                        "open": True, "evidence_date": FETCHED if ev == "site" else ("2026" if ev == "dated" else "2025-26 City inspection"),
                        "sources": srcs + ([CIN] if ev == "city" else []), "match_names": [name.upper()] if norm(name) != norm(C["name"][i]) else []})
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
               "sources": src, "match_names": [name.upper()]})
json.dump(jb, open(f"{R}/jbf.json", "w"), indent=1, ensure_ascii=False)
json.dump(CLOSED, open(f"{R}/closed.json", "w"), indent=1, ensure_ascii=False)
open(f"{R}/app/LEADS.md", "w").write("# Ohio research leads (not yet verified)\n\nWritten by pipeline/build_research.py.\n\n" + "\n".join(leads) + """

## Not yet checked (the session's web tools hit their limit on 2026-10-24)
- Oldest places from Ohio Magazine's “Eat at 15 of Ohio's Oldest Restaurants” (Mar/Apr 2026): The Golden Lamb (Lebanon, 1803), Arnold's
  (Cincinnati, 1861), Bun's (Delaware, 1864), Ringside Cafe (Columbus, 1897), Bender's Tavern (Canton, 1902), The Saratoga (Warren, 1916),
  Guarino's (Cleveland, 1918), Kewpee (Lima, 1928), White Oaks (Westlake, 1928), TAT (Columbus, 1929), Ye Olde Trail Tavern (Yellow
  Springs, 1827). Each needs a source saying it opened at its current address before a founding year is shown. Sunrise Inn (Warren, 1929):
  its site robots-blocks Claude. Spread Eagle (1837) and The Spot (1907) moved or closed in between: no founding year.
- Goetta: Sugar n' Spice, Taste of Belgium, Sleepy Bee Cafe, Half Day Cafe, Camp Washington's 513-Way (CityBeat roundups, older): need a
  2025-26 page naming the goetta dish. Glier's and Eckerlin Meats are makers, not restaurants.
- Cleveland plates: Pierogi Palace (West Side Market, Willoughby), Banter (Polish Boy), Seti's Polish Boys, Mt. Pleasant Bar-B-Q, Presti's
  (cassata isn't on its site), Baraona's, Jukebox, Prosperity Social Club. Perla Pierogies is a shop with no seating.
- Perch: Jolly Roger Seafood House (Port Clinton; its site doesn't answer), New Sandusky Fish Co., Lemmy's, The Village Pump (Kelleys Island),
  The Seafood Restaurant (Sylvania), Flat Iron Cafe and Pickle Bill's (perch not on their pages). Goat Soup and Whiskey's domain now
  redirects to an unrelated site: added to the website blocklist.
- Ohio Valley pizza: DiCarlo's (Steubenville original; its page had no content), Ray's (Wintersville). Brier Hill: Avalon Downtown, MVR.
  Columbus style: Massey's (original 1949 on Livingston Ave.; Whitehall shop), Tommy's.
- Barberton: White House Chicken, Village Inn Chicken (Milich's successor), Terrace Gardens: not in our data under those names.
- Chili: Chili Time (St. Bernard) and Empress Chili (Bridgetown; its other shop is in Alexandria, Ky.) aren't in our data. Skyline and
  Gold Star are chains: brand facts only, no hand-checked locations.
- Sokolowski's University Inn (Cleveland, America's Classic 2014) closed in 2020.
""")
print(n_out, "| James Beard:", len(jb), "| leads:", len(leads))
