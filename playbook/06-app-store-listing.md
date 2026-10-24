# App Store listing (ASO)

Written by `scripts/make-listing.py` from `site-numbers.json` (2026-10-24); re-run it after every data refresh, never hand-edit.
The machine copy is `app-store/listing.json` (read by `../scripts/asc_listing.py` once Nick creates the App Store Connect record and
adds `"com.ohioeats.ios": "oh-eats"` to its FOLDERS). The URLs assume ohio.eatsranked.com is live; until Nick's CNAME
resolves, use https://nickstrom5.github.io/ohio-eats/.

## Name (30 max)
`Ohio Eats: Restaurants` (22)

## Subtitle (30 max)
`Chili, Pierogi & Pizza` (22)

Together they index: ohio, eats, restaurants, chili, pierogi, pizza. Home Screen name: Ohio Eats.

## Keywords (100 max)
`cincinnati,columbus,cleveland,dayton,toledo,akron,amish,goetta,walleye,perch,food guide,buckeye` (95)

- No word repeats the name or subtitle; no trademarks (no Skyline, Gold Star, Graeter's or LaRosa's; "buckeye" is the state's nickname and tree, not the team), no "best", "top" or "#1".
- Towns are the biggest win; Canton, Youngstown, Sandusky, Parma and Berlin didn't fit. Rotate them in after a month of App Store Connect
  search-term data. Apple's public search can't be used for this research (itunes.apple.com's robots.txt blocks Claude).

## Promotional text (170 max, editable any time without review)
`6 Cincinnati chili parlors, 15 Ohio pizzerias and Amish Country kitchens, each checked by hand. Plus 25,000+ Ohio restaurants near you.` (135)

## Description (2849 of 4,000)
```
Ohio's restaurants, from a three-way at a neighborhood chili parlor to a square-cut pie in Dayton.

Ohio Eats is a free guide to eating in Ohio: 6 Cincinnati chili parlors, 15 pizzerias for Ohio's own pizza styles, 6 Amish Country restaurants and Cleveland's pierogi, Lake Erie perch, Barberton chicken and Toledo's Hungarian hot dogs, all checked by hand, plus 25,356 restaurants, cafés, bars and bakeries in 881 towns, from Cincinnati, Columbus and Cleveland to Toledo, Dayton and Akron. 3,377 of them are on Columbus's or Cincinnati's official food lists. No account, no ads.

OHIO GUIDES
• Cincinnati Chili: three-ways, four-ways and cheese coneys at neighborhood parlors.
• Ohio Pizza Styles: Columbus thin crust, Dayton's square-cut pies, Ohio Valley squares and Brier Hill pizza.
• Amish Country: homestyle cooking and bakeries in Holmes and Geauga counties.
• Pierogi & Cleveland Plates, Lake Erie Perch & Walleye, Barberton Chicken, Hungarian Hot Dogs and Goetta.
• Award winners: 13 James Beard semifinalists, finalists and America's Classics.
• Cincinnati Inspections: the Cincinnati Health Department's own result for 860 places, word for word with the violations cited. Columbus places show Columbus Public Health's own permit status.

FIND IT FAST
• Sort by distance, or browse the map by guide.
• Search by name, town, street or dish: "goetta cincinnati", "pizza dayton".
• Filter by town or cuisine, or hide chains.
• Save places, and find hand-checked places from iPhone search (Spotlight).

LIVE DETAILS FROM APPLE MAPS
Tap "Ratings, hours & photos" on any place to open Apple Maps' own place card, with current hours, photos, ratings and directions.

HOW THE LISTS ARE BUILT
Every guide place was checked by hand in October 2026: a page names it for the food (local news, Ohio Magazine, a tourism board or the place's own site), and a 2025 or 2026 source shows it's open. The rest come from Overture Maps open data, checked against Columbus's and Cincinnati's official lists where they exist. Website links are checked too. Nothing is ranked by star ratings, and the app computes no grades.

PRIVATE BY DESIGN
No account, no tracking, no ads. Your location, if you share it, only sorts lists on your device. Saved places stay on your device.

Places open and close, so check before you go. Spot a mistake? Email nick@eatsranked.com.

An independent app, not affiliated with any restaurant, chain or government agency (including the State of Ohio, the Ohio Department of Health, the City of Cincinnati, the Cincinnati Health Department, the City of Columbus and Columbus Public Health), or with the James Beard Foundation. James Beard Foundation and James Beard Award are trademarks of the James Beard Foundation. Place data from Overture Maps Foundation (CDLA Permissive 2.0) and others; sources and licenses are on the About tab.
```

## What's New (1.0)
`First release: Cincinnati chili, Ohio pizza styles, Amish Country, pierogi and 25,000+ Ohio restaurants.`

## Screenshots
Framed by `scripts/appstore-screenshots.py`: `app-store/iphone/` (8, 1320x2868, the 6.9" slot) and `app-store/ipad/` (6, 2064x2752, the
13" slot). Upload one file at a time in file order and check the order after a reload. No negative board and no place whose latest
Cincinnati result is "Not In Compliance" (or Columbus status "Under Enforcement" or "Closed for Violation") appears in any image.

## Category and age rating
Primary Food & Drink, secondary Travel. Age rating: alcohol references "Infrequent" (bars, taverns) → 13+; everything else None/No.
Pricing $0.00, available in the United States. Content rights: yes, third-party content, with the rights (open data, public records,
Apple's place card). Untick "Sign-in required".

## App Review
Reply and recording script: `13-app-review-reply.md`. Put the reply in App Review Information → Notes from the start.
