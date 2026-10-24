# Ohio sources (checked 2026-10-24)

Every host was checked with `pipeline/check_sources.py` (RFC 9309 robots matcher, honest UA `OhioEatsSourceCheck/1.0`) before its
first data request. Raw files: `data/raw/official/` (git-ignored). Fetcher: `pipeline/fetch_official.py`.

Ohio has **no statewide food-license list, no statewide inspection data and no official grade**. Local health districts license and
inspect under the Ohio Uniform Food Safety Code (OAC 3717-1); ODH trains and surveys them. Two cities publish in bulk.

## Used

| Source | What | Terms | Cadence | Coverage | Fields used |
|---|---|---|---|---|---|
| **Cincinnati Health Department, "Cincinnati Food Safety Program"**: data.cincinnati-oh.gov Socrata `rg6p-b3h3`, the portal's own CSV download (`/api/views/rg6p-b3h3/rows.csv`); robots: usable | 346,403 rows, 2012 → 2026-10-22; one row per cited violation, or per visit with none. 6,964 license numbers, **2,340 live** (latest status "Issued", City's 2024 system). Data dictionary attached (one page; no definitions of statuses) | **Public Domain** (attribution City of Cincinnati) | daily (rows updated 2026-10-23) | City of Cincinnati only | LICENSE_NO, BUSINESS_NAME, ADDRESS, POSTAL_CODE, LAT/LON (158 live licenses lack a point; 127 placed on Overture address points), LICENSE_STATUS, RECORDNUM_INSP (groups a routine inspection's visits), INSP_TYPE / INSP_SUBTYPE, ACTION_DATE, ACTION_SEQUENCE (one visit), ACTION_STATUS, CODE. **Phone never shown.** |
| **Columbus Public Health, "Restaurant & Market Health Inspections"**: maps2.columbus.gov `Schemas/Health/MapServer/3` (ArcGIS item 948d9672209948bda747b609dbeff5b3), paged query; robots: usable | **5,188 permits** (4,845 facilities): restaurants 2,234, bars 268, carryouts 205, pizza shops 128, coffee shops 58, bakeries 62, plus day cares, schools, groceries, gas stations, micro-markets, hotels, clubs | **CC0** (public domain dedication) | "updated nightly" | City of Columbus and Worthington (CPH's jurisdiction) | PERMIT_ID, BUSINESS_NAME / FACILITY_NAME, SITE_ADDRESS, CITY, ZIP, BUS_TYPE_DESCR (kind), RISK_LEVEL, STATUS_DESCRIP (the City's own status: Standards Met 5,180, Under Enforcement 5, Closed for Violation 2, No Status 1), WEB_LINK (decadeonline.com history, see below), point. **PERMIT_ENTERED_DATE is not used: 677 permits carry 2001-03-16, an import stamp.** Phone never shown. |
| Overture Maps places **2026-10-21.0** | statewide base: 49,621 eating/drinking listings with region OH | CDLA-Permissive-2.0 / Apache-2.0 (+ Foursquare NOTICE) | monthly | statewide | as in other states |
| Overture divisions (state, 88 counties, Columbus/Worthington/Cincinnati city limits), address points (5.54M in OH) | outlines, county assignment, calibration areas, placing records | ODbL (OSM-derived) for divisions: leaderboard only; attribute or don't ship in the app | | | |
| UCSD Google Local 2021 (`meta-Ohio.json.gz`, mcauleylab.ucsd.edu: no robots.txt) | ratings, reviews, price, 2021 closures: **web leaderboard only, never the app** | research dataset | frozen Sep 2021 | 32,029 food listings | |

### How the official results are shown (never a grade of ours)
- **Cincinnati.** Since the City's 2024 system change (first visits with a result: 2024-03-12) each visit (ACTION_SEQUENCE) carries the
  City's own result in ACTION_STATUS: "Approved - No Violations" (3,231 visits), "Approved - Minor Violations" (6,323), "Approved -
  Violations Abated" (694, a follow-up that found earlier violations fixed) or "Not In Compliance" (1,565). Before 2024 the same field held
  each violation's state ("Abated", "Not Abated", "Abated On-Site") and only "CLOS-NO - No Violations Found" was a result, so those
  visits aren't shown. A place shows its latest routine inspection (RECORDNUM_INSP): the result of its latest visit, the date of that
  visit, and the number of distinct code sections cited on its first visit. Complaint visits stay in the history only. The dataset
  doesn't mark violations critical or non-critical, so we never say "critical". **Records through 2026-10-14** (fetch 2026-10-24 minus
  10 days: the last week's visits are still being entered, 11–91 rows a day against 50–150 before).
- **Columbus.** The City's own status per permit, as of the day we read the layer. No inspection dates or counts are published in bulk.
  Each permit's `WEB_LINK` points to `decadeonline.com/insp.phtml?agency=COL&record_id=…`. From this Mac's scripts the host never answered
  (connection timeout, also for robots.txt), so **the link isn't shown until it's checked in a browser**; crawling it needs Nick's yes.

## Checked, not usable (no bulk data, or blocked)

| Source | Verdict |
|---|---|
| inspections.myhealthdepartment.com (53 Ohio districts per the prompt: Cuyahoga suburbs /ccbh, Summit /scph, Toledo-Lucas, Stark, Canton, Lorain, Lake, Medina, Butler, Clermont, Delaware, Licking …) | robots.txt answers with a **bot check**: not usable. Per-place lookups by hand only. |
| Franklin County Public Health (myfcph.org/food-inspection-reports) | Page says: platform changed May 2025; reports 5/9/2025–5/19/2026 **records request only**; newer ones on ODH's Accela (aca-prod.accela.com/FRANKLINCPH, search only); older ones on HealthSpace. No bulk data. |
| Public Health – Dayton & Montgomery County (inspections.phdmc.org) | own search site; robots.txt `Crawl-delay: 10`. Search only; **crawling needs Nick's yes**. |
| Cleveland Department of Public Health | data.clevelandohio.gov holds "Public Health Complaints" only (complaints, not inspections); no inspection results online. A records request needs Nick's yes. |
| Hamilton County Public Health (outside Cincinnati) | changing platforms (HealthSpace, Accela, a myhealthdepartment page): search only. |
| Ohio Division of Liquor Control, "Searchable Liquor Control Information" (Power BI "All permits") | the page says exporting is no longer available: not scraped. A public-records request is outward-facing (Nick). **"Serves alcohol" is unknown, not "no".** |
| Property values: Hamilton (CAGIS 24faaf8c…) and Cuyahoga (84693e5d…) parcels | no explicit license: **no building-value board**. |
| MICHELIN (guide.michelin.com) | bot check (empty 202). The prompt's 2026-09-27 check found no selected restaurants in Cleveland, Cincinnati or Columbus: **no MICHELIN data, no Bib Gourmand filter**; recheck by hand in a browser before launch. |
| BLS QCEW (data.bls.gov/cew) | bot check. The prompt's figure (24,976 private NAICS 722 establishments in 2025; 21,189 restaurants, 2,012 bars) is quoted from the prompt, not re-checked. |
| Census County Business Patterns API (api.census.gov) | now redirects to `missing_key.html` (a key is required): not used. |

## Calibration (2026-10-24, `data/oh/calibration.json`, `calibration_app.json`)

No statewide list, so listings are tested inside the two cities' limits (Overture locality outlines; mailing towns would mix in
township areas Franklin County Public Health serves). Share of cleaned listings matched to the city's official list:

| Listing group | Columbus (with Worthington) | Cincinnati |
|---|---|---|
| Meta + open in Google 2021 | **84.8%** of 1,573 | **83.4%** of 577 |
| Meta only | 44.8% of 1,330 | 44.5% of 521 |
| Chain store lists only | 66.2% of 77 | 78.6% of 14 |
| Foursquare / BrightQuery / Microsoft + Google 2021 | 20.3% of 497 | 20.2% of 198 |
| Microsoft only | 29.9% of 201 | 32.7% of 55 |
| Foursquare only | **17.8%** of 388 | **11.0%** of 163 |
| BrightQuery only | 12.7% of 472 | 12.7% of 173 |
| Google 2021 says closed | 5.2% of 213 | 3.2% of 94 |
| App grouping: Meta ≥0.95 | 84.5% of 1,989 | 85.2% of 716 |
| App grouping: Meta 0.90–0.95 | 35.0% of 411 | 37.2% of 172 |
| App grouping: Meta <0.90 | 21.5% of 522 | 18.1% of 216 |

The rates match Chicago (Meta + Google open 74%, Foursquare-only 5–14%) and Michigan (77% / 6.6%), so the playbook's keep rules stand:
web = Meta and chain feeds, minus Google-closed; app = Meta ≥0.95, Meta 0.90–0.95 with a website, chain feeds, licensed, hand-checked.

Coverage the other way: the open map listings held **71.1% of Columbus's 2,806** permitted restaurants, bars, carryouts, coffee shops and
bakeries, and **45.1% of Cincinnati's 1,715** live licenses not flagged as schools/other (that list also holds groceries, gas stations and
stadium stands, and gives no business type). Plainly named restaurants among the rest were added from the lists (716 rows: Columbus
restaurant/bar permits regardless of name; carryouts, coffee shops, bakeries and Cincinnati licenses only with a food word in the name).

### Per county (top 12 of 88; all in calibration.json `per_county`)

| County | Map listings (first cleaning) | Restaurants in the web build | Inspection results |
|---|---|---|---|
| Cuyahoga | 6,464 | 3,520 | Suburbs: CCBH search page (bot check); Cleveland: none online |
| Franklin | 6,458 | 4,275 | Columbus & Worthington: City status in bulk; suburbs: FCPH search (Accela) |
| Hamilton | 4,226 | 2,596 | **Cincinnati: bulk results**; rest: HCPH search |
| Summit | 2,414 | 1,401 | search page |
| Montgomery | 2,165 | 1,341 | search site (inspections.phdmc.org) |
| Lucas | 1,977 | 1,188 | search page |
| Stark | 1,576 | 995 | search page |
| Butler | 1,531 | 942 | search page |
| Mahoning | 1,112 | 678 | no bulk data |
| Lake | 1,108 | 629 | search page |
| Lorain | 1,089 | 681 | search page |
| Delaware | 975 | 632 | search page; Columbus's sliver: City status |

## First build (web, 2026-10-24)

32,200 places, **31,086 restaurants**, 962 towns. 3,379 official (matched to a Columbus permit or a Cincinnati license, or added from
them), 15,993 in two sources, 11,714 one source. 920 Cincinnati places carry the City's latest routine result (634 Approved - Minor
Violations, 157 Approved - No Violations, 108 Approved - Violations Abated, 21 Not In Compliance); 2,669 Columbus places carry the City's
status (2,665 Standards Met, 3 Under Enforcement, 1 Closed for Violation). 9 adult clubs removed (5 by Overture's adult category).
Against the prompt's BLS figure (24,976 NAICS 722 establishments incl. caterers and food trucks), 31,086 is high: map listings include
places BLS counts elsewhere (coffee counters inside stores, bars without payroll in 722, closures since). The app build is stricter.
