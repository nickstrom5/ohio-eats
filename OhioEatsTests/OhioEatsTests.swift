import XCTest
import CoreLocation
@testable import OhioEats

@MainActor
final class OhioEatsTests: XCTestCase {

    /// A tiny core file and two region detail files with the same shape as Resources/places.json and Resources/detail-*.json.
    private func sampleModel() async throws -> AppModel {
        let json = """
        {"v":1,"generated":"2026-10-24","overture_release":"2026-10-21.0","cin_live_licenses":2340,"col_permits":5188,
         "inspections_through":{"cin":"2026-10-14","col":"2026-10-24"},
         "cities":["Cincinnati","Columbus","Toledo","Barberton","Parma","St. Clairsville"],
         "cuisines":["Cincinnati Chili","Pizza","German & European","Chicken & Wings","American & Other","Bar & Pub"],
         "brands":["Skyline Chili"],"counties":["Hamilton County","Franklin County","Lucas County","Summit County","Cuyahoga County","Belmont County"],
         "regions":["Cleveland & Northeast","Akron, Canton & Youngstown","Toledo & Northwest","Lake Erie & North Central","Columbus & Central","Dayton & Miami Valley","Cincinnati & Southwest","Southeast & Appalachian Ohio"],
         "srcs":["official","meta","AllThePlaces","DAC","research"],
         "results":["Approved - No Violations","Approved - Minor Violations","Approved - Violations Abated","Not In Compliance","Standards Met","Under Enforcement","Closed for Violation"],
         "itypes":["Complaint","Routine · Critical Control Point","Routine · Standard Inspection"],
         "count":10,"count_restaurants":9,
         "calibration":{"Columbus":{"listings":5024,"groups":{"meta_high":{"n":1989,"official":0.845}}},"Cincinnati":{"groups":{"meta_high":{"n":716,"official":0.852}}}},
         "places":[
          {"id":"a","n":"Camp Washington Chili","c":0,"co":0,"rg":6,"cu":0,"t":2,"s":1,"hc":1,"g":257,"f":1940,"a":"3005 Colerain Ave","z":"45225","la":39.1307,"lo":-84.5377,
           "h":1,"jbf":"America's Classics (example)","ip":60,"dish":"three-way; cheese coney","in":[0,1,4,"2026-05-08"]},
          {"id":"b","n":"Goetta House","c":0,"co":0,"rg":6,"cu":4,"t":1,"s":1,"hc":1,"g":2,"a":"100 Main St","la":39.11,"lo":-84.51},
          {"id":"c","n":"Skyline Chili","c":0,"co":0,"rg":6,"cu":0,"t":2,"s":0,"b":0,"ch":120,"la":39.105,"lo":-84.515,"in":[0,3,9,"2026-08-05"]},
          {"id":"d","n":"Some Grill","c":0,"co":0,"rg":6,"cu":4,"t":0,"s":1,"a":"200 Vine St","la":39.104,"lo":-84.513,"in":[0,3,12,"2026-02-11"]},
          {"id":"e","n":"Speedway","c":0,"co":0,"rg":6,"cu":4,"t":1,"s":1,"v":1,"la":39.12,"lo":-84.52},
          {"id":"f","n":"Tony Packo's","c":2,"co":2,"rg":2,"cu":2,"t":1,"s":1,"hc":1,"g":32,"a":"1902 Front St","la":41.6413,"lo":-83.5094},
          {"id":"g","n":"Pierogi Kitchen","c":4,"co":4,"rg":0,"cu":2,"t":1,"s":1,"hc":1,"g":4,"a":"5000 Ridge Rd","la":41.40,"lo":-81.73},
          {"id":"h","n":"Columbus Tavern","c":1,"co":1,"rg":4,"cu":5,"t":2,"s":1,"la":39.96,"lo":-83.0,"in":[1,4,0,"2026-10-24"]},
          {"id":"i","n":"Corner Carryout","c":1,"co":1,"rg":4,"cu":4,"t":2,"s":0,"la":39.97,"lo":-82.98,"in":[1,5,0,"2026-10-24"]},
          {"id":"j","n":"Belmont Diner","c":5,"co":5,"rg":7,"cu":4,"t":1,"s":1,"la":40.08,"lo":-80.9}
         ]}
        """
        let cincy = """
        {"a":{"lic":[["Cincinnati food license","CIN-HEFD-000417","Cincinnati Health Department"]],
              "ph":"(513) 541-0061","w":"campwashingtonchili.com","in":{"n":3,"h":[["2026-05-08",1,4,1],["2025-11-25",0,0,1],["2024-11-12",2,0,2],["2024-11-05",3,8,1]]}},
         "c":{"w":"javascript:alert(1)","in":{"n":1,"h":[["2026-08-05",3,9,1]]}},
         "d":{"in":{"n":2,"h":[["2026-02-11",3,12,2]]}}}
        """
        let columbus = """
        {"h":{"lic":[["Columbus Public Health permit","PT0000014","Restaurant · risk level 3"]]}}
        """
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("oh-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent("places.json")
        try json.data(using: .utf8)!.write(to: url)
        try cincy.data(using: .utf8)!.write(to: dir.appendingPathComponent("detail-cincinnati-southwest.json"))
        try columbus.data(using: .utf8)!.write(to: dir.appendingPathComponent("detail-columbus-central.json"))
        let model = AppModel(defaults: UserDefaults(suiteName: "test-\(UUID().uuidString)")!)
        await model.load(from: url, detailFolder: dir)
        XCTAssertTrue(model.isLoaded, model.loadError ?? "")
        return model
    }

    func testDecodesAndHidesNonRestaurantsByDefault() async throws {
        let m = try await sampleModel()
        XCTAssertEqual(m.places.count, 10)
        XCTAssertEqual(m.restaurantCount, 9)
        XCTAssertFalse(m.list(.all, sort: .name, search: "", here: nil).contains { $0.name == "Speedway" }, "a gas-station counter is hidden by default")
        m.filters.includeNonRestaurants = true
        XCTAssertTrue(m.list(.all, sort: .name, search: "", here: nil).contains { $0.name == "Speedway" })
    }

    func testGuidesListOnlyWhatTheyPromise() async throws {
        let m = try await sampleModel()
        XCTAssertEqual(m.list(.chili, sort: .name, search: "", here: nil).map(\.name), ["Camp Washington Chili"], "the chain parlor isn't hand-checked")
        XCTAssertEqual(m.list(.goetta, sort: .name, search: "", here: nil).map(\.name), ["Goetta House"])
        XCTAssertEqual(m.list(.hungarian, sort: .name, search: "", here: nil).map(\.name), ["Tony Packo's"])
        XCTAssertEqual(m.list(.pierogi, sort: .name, search: "", here: nil).map(\.name), ["Pierogi Kitchen"])
        XCTAssertEqual(m.list(.oldest, sort: .oldest, search: "", here: nil).map(\.name), ["Camp Washington Chili"])
        XCTAssertEqual(m.list(.honors, sort: .iconic, search: "", here: nil).map(\.name), ["Camp Washington Chili"])
        XCTAssertEqual(m.count(.perch), 0)
    }

    func testInspectionResultsAreTheCitysOwn() async throws {
        let m = try await sampleModel()
        let worst = m.list(.inspections, sort: .lowestScore, search: "", here: nil)
        XCTAssertEqual(worst.map(\.name), ["Some Grill", "Skyline Chili", "Camp Washington Chili"], "Not In Compliance first, most violations first; Cincinnati only")
        let t = try XCTUnwrap(worst.first?.inspection)
        XCTAssertEqual(t.city, .cincinnati); XCTAssertEqual(t.score, 12); XCTAssertEqual(m.band(t.band).label, "Not In Compliance")
        XCTAssertTrue(m.band(t.band).isLow)
        XCTAssertEqual(m.list(.inspections, sort: .highestScore, search: "", here: nil).first?.name, "Camp Washington Chili")
        XCTAssertEqual(m.band(1).label, "Approved - Minor Violations", "the City's own words")
        XCTAssertFalse(m.band(1).isLow)
        XCTAssertEqual(m.list(.inspections, sort: .recent, search: "", here: nil).first?.name, "Skyline Chili")
        // Columbus: the City's status, not in the Cincinnati guide; "Under Enforcement" reads as not passing
        XCTAssertEqual(m.place(id: "h")?.inspection?.city, .columbus)
        XCTAssertEqual(m.band(4).label, "Standards Met"); XCTAssertFalse(m.band(4).isLow)
        XCTAssertTrue(m.band(5).isLow, "Under Enforcement"); XCTAssertTrue(m.band(6).isLow, "Closed for Violation")
        XCTAssertFalse(worst.contains { $0.inspection?.city == .columbus })
    }

    func testDatesAreCalendarDays() {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        let d = DayFormat.date("2026-06-16")!
        XCTAssertEqual(utc.dateComponents([.year, .month, .day], from: d), DateComponents(year: 2026, month: 6, day: 16))
        XCTAssertTrue(DayFormat.monthYear("2025-09-01")!.contains("2025"))
        XCTAssertNil(DayFormat.date("2026-13-01"))
        XCTAssertEqual(DayFormat.text("soon"), "soon", "a value that isn't a date is shown as it is")
    }

    func testRegionDetailsLoadOnDemand() async throws {
        let m = try await sampleModel()
        let v = await m.detail(for: m.place(id: "a")!)
        XCTAssertEqual(v?.licenses.first?.source, "Cincinnati food license")
        XCTAssertEqual(v?.licenses.first?.id, "CIN-HEFD-000417")
        XCTAssertEqual(v?.website?.absoluteString, "https://campwashingtonchili.com", "a bare host gets https://")
        XCTAssertEqual(v?.inspection?.visits.count, 4)
        XCTAssertEqual(v?.inspection?.visits.last?.score, 8, "the violations cited on a visit are the City's")
        XCTAssertEqual(m.visitType(v?.inspection?.visits.first?.t ?? -1), "Routine · Critical Control Point")
        let sky = await m.detail(for: m.place(id: "c")!)
        XCTAssertNil(sky?.website, "a javascript: link never becomes a website button")
        let tavern = await m.detail(for: m.place(id: "h")!)
        XCTAssertEqual(tavern?.licenses.first?.source, "Columbus Public Health permit", "the Columbus file is read on its own")
        XCTAssertEqual(AppModel.regionSlug("Akron, Canton & Youngstown"), "akron-canton-youngstown")
        XCTAssertEqual(AppModel.regionSlug("Southeast & Appalachian Ohio"), "southeast-appalachian-ohio")
        let missing = await m.detail(for: m.place(id: "g")!)
        XCTAssertNil(missing, "a region with no detail file reads as no detail, not a crash")
    }

    func testSearchWordStartsTownsAndGuides() async throws {
        let m = try await sampleModel()
        XCTAssertEqual(m.list(.all, sort: .name, search: "camp wash", here: nil).map(\.name), ["Camp Washington Chili"])
        XCTAssertEqual(m.list(.all, sort: .name, search: "toledo", here: nil).map(\.name), ["Tony Packo's"], "a town narrows to it")
        XCTAssertEqual(m.list(.all, sort: .name, search: "cheese coney", here: nil).map(\.name), ["Camp Washington Chili"], "a dish finds who serves it")
        XCTAssertEqual(m.list(.all, sort: .name, search: "🍕", here: nil), [], "an emoji finds nothing, not everything")
        XCTAssertEqual(m.list(.all, sort: .name, search: "hungarian hot dogs", here: nil).map(\.name), ["Tony Packo's"], "a guide phrase means the guide")
        XCTAssertEqual(m.list(.all, sort: .name, search: "three way", here: nil).map(\.name), ["Camp Washington Chili"], "the chili guide, not every chili")
        XCTAssertEqual(m.list(.all, sort: .name, search: "saint clairsville", here: nil).map(\.name), ["Belmont Diner"], "St. and Saint are one town")
    }

    func testOutsideOhioUsesTheOutline() {
        func inside(_ la: Double, _ lo: Double) -> Bool { OhioOutline.contains(CLLocationCoordinate2D(latitude: la, longitude: lo)) }
        XCTAssertTrue(inside(39.10, -84.51), "Cincinnati"); XCTAssertTrue(inside(39.96, -83.00), "Columbus"); XCTAssertTrue(inside(41.50, -81.69), "Cleveland")
        XCTAssertTrue(inside(41.65, -83.54), "Toledo"); XCTAssertTrue(inside(39.42, -81.45), "Marietta"); XCTAssertTrue(inside(41.65, -82.81), "Put-in-Bay")
        XCTAssertTrue(inside(41.95, -80.55), "Conneaut"); XCTAssertTrue(inside(40.62, -80.58), "East Liverpool")
        XCTAssertFalse(inside(42.33, -83.05), "Detroit"); XCTAssertFalse(inside(40.44, -79.99), "Pittsburgh"); XCTAssertFalse(inside(42.13, -80.08), "Erie, Pa.")
        XCTAssertFalse(inside(41.08, -85.14), "Fort Wayne, Ind."); XCTAssertFalse(inside(38.05, -84.50), "Lexington, Ky."); XCTAssertFalse(inside(38.35, -81.63), "Charleston, W.Va.")
        XCTAssertFalse(inside(37.33, -122.03), "Cupertino")
    }

    func testMatchRatesComeFromTheCityLists() async throws {
        let m = try await sampleModel()
        XCTAssertNil(m.matchRate(for: m.place(id: "a")!), "an official record needs no listing rate")
        XCTAssertEqual(m.matchRate(for: m.place(id: "b")!), "85%")
    }

    func testBundledData() async throws {
        let m = AppModel(defaults: UserDefaults(suiteName: "bundle-\(UUID().uuidString)")!)
        await m.load()
        XCTAssertTrue(m.isLoaded, m.loadError ?? "")
        XCTAssertGreaterThan(m.restaurantCount, 20_000)
        XCTAssertGreaterThan(m.count(.inspections), 800)
        XCTAssertGreaterThan(m.licensedCount, 2_500, "restaurants matched to a Columbus permit or a Cincinnati license")
        XCTAssertEqual(Set(m.places.map(\.id)).count, m.places.count, "ids are unique")
        for g in Guide.allCases where g.tag != nil {
            XCTAssertTrue(m.places.filter(g.includes).allSatisfy(\.handChecked), "\(g.title) lists only hand-checked places")
        }
        // each city's results sit on its own places: Cincinnati's in Hamilton County, Columbus's in Franklin, Delaware or Fairfield
        XCTAssertTrue(m.places.allSatisfy { p in p.inspection.map { $0.score >= 0 && ($0.city == .cincinnati ? p.county == "Hamilton County"
                      : ["Franklin County", "Delaware County", "Fairfield County"].contains(p.county ?? "")) } ?? true },
                      "inspection results only on the publishing city's places")
        XCTAssertTrue(m.places.allSatisfy { $0.inspection?.city != .columbus || $0.inspection?.score == 0 }, "Columbus publishes no counts")
        XCTAssertTrue(m.places.allSatisfy { $0.michelin == .none }, "Ohio has no MICHELIN Guide")
        // no Google-derived data: the data file has no rating, review or price fields at all
        let raw = try String(contentsOf: Bundle.main.url(forResource: "places", withExtension: "json")!, encoding: .utf8)
        for key in ["\"rating\"", "\"reviews\"", "\"price\"", "\"gmap_id\""] { XCTAssertFalse(raw.contains(key), "\(key) must not ship") }
    }

    /// App Store rule: no screenshot shows a place whose latest result reads as not passing.
    func testScreenshotPicksPass() async throws {
        let m = AppModel(defaults: UserDefaults(suiteName: "shots-\(UUID().uuidString)")!)
        await m.load()
        for (n, town) in [ScreenshotMode.chiliPick, ScreenshotMode.toledoPick, ScreenshotMode.barbertonPick] {
            let p = try XCTUnwrap(m.places.first { $0.name == n && $0.city == town }, "\(n) is in the data")
            XCTAssertFalse(p.inspection.map { m.band($0.band).isLow } ?? false, "\(n)'s latest result doesn't pass")
        }
    }

    /// Stable ids: md5(name + ~100 m cell)[:12], never a row number; every bundled region detail file decodes and its ids are core ids.
    func testIdsAndBundledDetailFiles() async throws {
        let m = AppModel(defaults: UserDefaults(suiteName: "ids-\(UUID().uuidString)")!)
        await m.load()
        XCTAssertTrue(m.places.allSatisfy { $0.id.count >= 12 && $0.id.prefix(12).allSatisfy(\.isHexDigit) && $0.id.dropFirst(12).allSatisfy { $0 == "x" } })
        let ids = Set(m.places.map(\.id))
        var licensed = 0
        for region in Set(m.places.compactMap(\.region)) {
            let url = try XCTUnwrap(Bundle.main.url(forResource: "detail-" + AppModel.regionSlug(region), withExtension: "json"), region)
            let d = try JSONDecoder().decode([String: PlaceDetail].self, from: Data(contentsOf: url))
            XCTAssertTrue(Set(d.keys).isSubset(of: ids), "\(region) detail ids are core ids")
            licensed += d.values.filter { $0.licenses.contains { ["Cincinnati food license", "Columbus Public Health permit"].contains($0.source) } }.count
        }
        XCTAssertGreaterThan(licensed, 2_500, "licensed places carry their city license or permit")
    }

    func testBundledDataGuards() async throws {
        let m = AppModel(defaults: UserDefaults(suiteName: "guards-\(UUID().uuidString)")!)
        await m.load()
        XCTAssertTrue(m.isLoaded, m.loadError ?? "")
        XCTAssertEqual(DataGuards.adultVenues(m.places), [], "no strip club under its name")
        XCTAssertEqual(DataGuards.badWebsites(try DataGuards.bundledLinks(m.places)), [], "no directory, Google or news page as a restaurant's website")
        XCTAssertEqual(DataGuards.badNames(m.places), [], "no visible name ending in \u{201C} the\u{201D} or \u{201C} of\u{201D}, or just \u{201C}The\u{201D}")
        XCTAssertEqual(DataGuards.legalNames(m.places), [], "no license holder entity name (\u{201C}… LLC\u{201D}) shown as a place's name")
        XCTAssertEqual(DataGuards.nonRestaurants(m.places), [], "no nail salon, senior home, gun store or gas station among the restaurants")
    }

    /// Each guard above fires on a copy of the bundled data broken the way QA found it elsewhere: a guard that can't fail guards nothing.
    func testGuardsCatchABrokenCopy() async throws {
        let raw = try Data(contentsOf: Bundle.main.url(forResource: "places", withExtension: "json")!)
        var file = try XCTUnwrap(JSONSerialization.jsonObject(with: raw) as? [String: Any])
        var places = try XCTUnwrap(file["places"] as? [[String: Any]])
        let idx = places.indices.filter { places[$0]["v"] == nil }.prefix(6).map { $0 }
        places[idx[2]]["n"] = "Larry Flynt's Hustler Club"
        places[idx[3]]["n"] = "Kitchen the"
        places[idx[4]]["n"] = "BUCKEYE HOSPITALITY GROUP LLC"
        places[idx[5]]["n"] = "Tipsy Nails & Spa"
        file["places"] = places
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("places-broken.json")
        try JSONSerialization.data(withJSONObject: file).write(to: url)
        let m = AppModel(defaults: UserDefaults(suiteName: "broken-\(UUID().uuidString)")!)
        await m.load(from: url)
        XCTAssertTrue(m.isLoaded, m.loadError ?? "")
        let id = idx.map { places[$0]["id"] as? String }
        func caught(_ found: [String], _ i: Int, _ what: String) {
            XCTAssertTrue(found.contains { $0.contains("[\(id[i] ?? "?")]") }, "the guard missed \(what)")
        }
        let links = [(name: "A", id: "x1", url: "https://www.yelp.com/biz/some-place"), (name: "B", id: "x2", url: "https://www.cincinnati.com/story/entertainment/dining/"),
                     (name: "C", id: "x3", url: "https://smart.com/menu")]
        XCTAssertEqual(DataGuards.badWebsites(links).count, 2, "the guard catches a Yelp page and a news story, and not smart.com")
        caught(DataGuards.adultVenues(m.places), 2, "a strip club")
        caught(DataGuards.badNames(m.places), 3, "\u{201C}Kitchen the\u{201D}")
        caught(DataGuards.legalNames(m.places), 4, "a license holder's entity name")
        caught(DataGuards.nonRestaurants(m.places), 5, "a nail salon shown as a restaurant")
    }
}

/// Checks on the bundled data, written as functions so testGuardsCatchABrokenCopy can prove each one fires.
enum DataGuards {
    /// directories, Google and news sites: matched on the link's host, so "smart.com" isn't "rt.com"
    static let badHosts = #"^https?://([^/?#]*\.)?(yelp\.com|business\.site|google\.com|groupon\.com|yellowpages\.com|tripadvisor\.com|dispatch\.com|cincinnati\.com|cleveland\.com|toledoblade\.com|daytondailynews\.com|beaconjournal\.com|wcpo\.com|clevescene\.com|eater\.com|rt\.com)([:/?#]|$)"#

    static func badWebsites(_ links: [(name: String, id: String, url: String)]) -> [String] {
        links.compactMap { l in
            guard l.url.range(of: badHosts, options: [.regularExpression, .caseInsensitive]) != nil else { return nil }
            return "\(l.name) [\(l.id)]: \(l.url)"
        }
    }

    /// every website link in the bundled region detail files, with its place's name
    static func bundledLinks(_ places: [Place]) throws -> [(name: String, id: String, url: String)] {
        let names = Dictionary(places.map { ($0.id, $0.name) }, uniquingKeysWith: { a, _ in a })
        var out: [(name: String, id: String, url: String)] = []
        for region in Set(places.compactMap(\.region)) {
            guard let url = Bundle.main.url(forResource: "detail-" + AppModel.regionSlug(region), withExtension: "json") else { continue }
            for (id, d) in try JSONDecoder().decode([String: PlaceDetail].self, from: Data(contentsOf: url)) {
                if let w = d.website?.absoluteString { out.append((names[id] ?? "?", id, w)) }
            }
        }
        return out
    }

    static let adultNames = #"gentlem[ae]n['’]?s club|strip club|exotic dancer|\bmen['’]?s club|rick['’]?s cabaret|xtc cabaret|baby dolls|spearmint rhino|bikini bar|pt['’]?s showclub|showgirls|centerfolds|treasures? gentlem|deja ?vu showgirls|hustler club|penthouse club"#

    /// every license key in the bundled region detail files, by place id
    static func bundledLicenses(_ places: [Place]) throws -> [String: [String]] {
        var out: [String: [String]] = [:]
        for region in Set(places.compactMap(\.region)) {
            guard let url = Bundle.main.url(forResource: "detail-" + AppModel.regionSlug(region), withExtension: "json") else { continue }
            for (id, d) in try JSONDecoder().decode([String: PlaceDetail].self, from: Data(contentsOf: url)) where !d.licenses.isEmpty {
                out[id] = d.licenses.compactMap(\.id)
            }
        }
        return out
    }

    static func adultVenues(_ places: [Place]) -> [String] {
        places.filter { $0.name.range(of: adultNames, options: [.regularExpression, .caseInsensitive]) != nil }.map { "\($0.name) [\($0.id)]" }
    }

    /// a name cut off after "the" or "of" ("Kitchen the", "Wines of") or nothing but "The", among the places shown by default
    static func badNames(_ places: [Place]) -> [String] {
        places.filter { p in
            let n = p.name.trimmingCharacters(in: .whitespaces).lowercased()
            return !p.isVenue && (n.hasSuffix(" the") || n.hasSuffix(" of") || n == "the")
        }.map { "\($0.name) [\($0.id)]" }
    }

    /// a license holder is never shown; a business name that's still a legal entity shouldn't be either
    static let legalSuffix = #"\b(llc|l\.l\.c|inc|corp|corporation)\.?$"#

    static func legalNames(_ places: [Place]) -> [String] {
        places.filter { !$0.isVenue && $0.name.range(of: legalSuffix, options: [.regularExpression, .caseInsensitive]) != nil }
            .map { "\($0.name) [\($0.id)]" }
    }

    /// businesses that aren't places to eat, among the places shown by default
    static let nonRestaurantNames = #"\bnails?\b|assisted living|gun (?:club|range|shop|store)|shooting range|firearms|petroleum|\bauto (?:repair|parts)\b"#

    static func nonRestaurants(_ places: [Place]) -> [String] {
        places.filter { !$0.isVenue && $0.name.range(of: nonRestaurantNames, options: [.regularExpression, .caseInsensitive]) != nil }
            .map { "\($0.name) [\($0.id)]" }
    }
}

/// pipeline/website_blocklist.json (hacked, taken-over, expired or another business's sites, confirmed by hand in the link sweeps):
/// no link on it may ship in any field of any JSON file the app bundles. The 2026-10-19 QA found the export had only filtered the
/// website field, or nothing, so hijacked links were still in the bundle. Read from the repo, so a new entry needs no code change.
final class LinkBlocklistTests: XCTestCase {
    func testNoBlocklistedLinkInBundledData() throws {
        let entries = try LinkBlocklist.entries()
        XCTAssertFalse(entries.isEmpty, "the blocklist is missing or empty")
        let files = LinkBlocklist.bundledJSON()
        XCTAssertFalse(files.isEmpty, "no bundled JSON found")
        var hits: [String] = []
        for url in files {
            let text = try String(contentsOf: url, encoding: .utf8)
            hits += LinkBlocklist.hits(in: text, entries).map { "\(url.lastPathComponent): \($0)" }
        }
        XCTAssertEqual(hits, [], "blocklisted links in the app's bundled data")
    }

    /// The guard fires on a copy of the bundled data broken three ways: a blocklisted domain, its subdomain, and a "url" entry.
    func testBlocklistGuardCatchesABrokenCopy() throws {
        let entries = try LinkBlocklist.entries()
        let file = try XCTUnwrap(LinkBlocklist.bundledJSON().max { (try? $0.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) ?? 0 < (try? $1.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) ?? 0 })
        let text = try String(contentsOf: file, encoding: .utf8)
        let domain = try XCTUnwrap(entries.first { ($0["match"] as? String ?? "domain") == "domain" }?["domain"] as? String)
        let fake: [[String: Any]] = entries + [["match": "url", "url": "https://example.org/hacked-page"]]
        let before = LinkBlocklist.hits(in: text, fake).count
        let broken = text + "{\"w\":\"https://www.\(domain)/menu\"}{\"src\":\"http://shop.\(domain)/\"}{\"w\":\"https://example.org/hacked-page/\"}"
        XCTAssertEqual(LinkBlocklist.hits(in: broken, fake).count, before + 3, "a domain, a subdomain and a url entry are all caught")
        XCTAssertEqual(LinkBlocklist.hits(in: "{\"w\":\"https://not\(domain)/\"}", entries), [], "a host that only ends with the domain's letters isn't it")
    }
}

enum LinkBlocklist {
    static func entries() throws -> [[String: Any]] {
        let url = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("pipeline/website_blocklist.json")
        return try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [[String: Any]])
    }

    /// every .json file in the app bundle, subfolders included
    static func bundledJSON() -> [URL] {
        let root = Bundle.main.bundleURL
        let all = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)?.allObjects as? [URL] ?? []
        return all.filter { $0.pathExtension == "json" && !$0.path.contains("/PlugIns/") }
    }

    private static func host(_ u: URLComponents) -> String {
        var h = (u.host ?? "").lowercased()
        if h.hasSuffix(".") { h.removeLast() }
        return h.hasPrefix("www.") ? String(h.dropFirst(4)) : h
    }

    private static func trimmedPath(_ p: String) -> String { p.hasSuffix("/") ? String(p.dropLast()) : p }

    /// the links in a JSON text that an entry covers: a "domain" entry its domain and subdomains, a "url" entry that page only
    static func hits(in text: String, _ entries: [[String: Any]]) -> [String] {
        let t = text.replacingOccurrences(of: "\\/", with: "/")
        let rx = try! NSRegularExpression(pattern: #"https?://[^"\s\\]+"#, options: [.caseInsensitive])
        return rx.matches(in: t, range: NSRange(t.startIndex..., in: t)).compactMap { m -> String? in
            let s = String(t[Range(m.range, in: t)!])
            guard let u = URLComponents(string: s) else { return nil }
            let h = host(u)
            for e in entries {
                if (e["match"] as? String ?? "domain") == "url" {
                    guard let v = URLComponents(string: e["url"] as? String ?? "") else { continue }
                    if !h.isEmpty && h == host(v) && trimmedPath(u.path) == trimmedPath(v.path) { return s }
                } else {
                    var d = (e["domain"] as? String ?? "").lowercased()
                    if let r = d.range(of: "://") { d = String(d[r.upperBound...]) }
                    d = String(d.split(separator: "/").first ?? "")
                    if d.hasPrefix("www.") { d = String(d.dropFirst(4)) }
                    if !d.isEmpty && (h == d || h.hasSuffix("." + d)) { return s }
                }
            }
            return nil
        }
    }
}

/// QA 2026-10-19, P1 3a: the support address is nick@eatsranked.com (Nick, 2026-10-12). The old Gmail address must not come back
/// anywhere in the app's source or bundled files.
final class SupportEmailTests: XCTestCase {
    func testSupportEmailIsEatsRanked() {
        XCTAssertEqual(Links.supportEmail, "nick@eatsranked.com")
    }

    func testNoGmailInAppSource() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("OhioEats")
        XCTAssertGreaterThan(SupportEmailScan.textFiles(under: root).count, 5, "the app's source folder wasn't found")
        XCTAssertEqual(SupportEmailScan.hits(under: root), [], "the app's source still has a Gmail address")
    }

    /// The guard fires on a broken copy: a folder with one planted Gmail address.
    func testGmailGuardCatchesABrokenCopy() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir.appendingPathComponent("App"), withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        try "static let supportEmail = \"someone@GMAIL.com\"\n".write(to: dir.appendingPathComponent("App/Links.swift"), atomically: true, encoding: .utf8)
        try "{\"ok\": \"nick@eatsranked.com\"}".write(to: dir.appendingPathComponent("App/data.json"), atomically: true, encoding: .utf8)
        XCTAssertEqual(SupportEmailScan.hits(under: dir), ["App/Links.swift"])
    }
}

enum SupportEmailScan {
    static let textExtensions: Set<String> = ["swift", "plist", "json", "strings", "xcstrings", "xcprivacy", "md", "txt", "html", "entitlements"]

    static func textFiles(under root: URL) -> [URL] {
        let all = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)?.allObjects as? [URL] ?? []
        return all.filter { textExtensions.contains($0.pathExtension.lowercased()) }
    }

    /// paths (relative to root) of text files that mention gmail.com, in any case
    static func hits(under root: URL) -> [String] {
        let base = root.resolvingSymlinksInPath().path + "/"
        return textFiles(under: root).compactMap { url in
            guard let text = try? String(contentsOf: url, encoding: .utf8),
                  text.range(of: "gmail.com", options: .caseInsensitive) != nil else { return nil }
            return url.resolvingSymlinksInPath().path.replacingOccurrences(of: base, with: "")
        }.sorted()
    }
}

/// QA 2026-10-19, P1 #13: outbound links ship without tracking tags (ref=google, referrer=google_food_ordering, cn_channel, utm_* …).
/// pipeline/tracking_params.py strips them in the export; these are the same rules.
final class TrackingParamTests: XCTestCase {
    func testNoTrackingParametersInBundledLinks() throws {
        let files = TrackingParams.bundledJSON()
        XCTAssertFalse(files.isEmpty, "no bundled JSON found")
        var hits: [String] = []
        for url in files {
            let text = try String(contentsOf: url, encoding: .utf8)
            hits += TrackingParams.tracked(in: text).map { "\(url.lastPathComponent): \($0)" }
        }
        XCTAssertEqual(hits, [], "links with tracking parameters in the app's bundled data")
    }

    /// The guard fires on a broken copy (four kinds of tracking tag, one in escaped JSON) and leaves a store's own parameters alone.
    func testTrackingGuardCatchesABrokenCopy() {
        let broken = #"[{"w":"https:\/\/places.example.com\/menu?ref=google"},{"w":"https://a.example/?utm_source=gmb&store=4"},"#
            + #"{"w":"https://b.example/x?referrer=google_food_ordering"},{"w":"https://c.example/order/1?cn_channel=cn_google"}]"#
        XCTAssertEqual(TrackingParams.tracked(in: broken).count, 4)
        let clean = #"[{"w":"https://order.example.com/menu?restaurantId=51&location=7"},{"w":"https://shop.example.com/?cid=12&ref=gs"}]"#
        XCTAssertEqual(TrackingParams.tracked(in: clean), [])
    }
}

enum TrackingParams {
    /// tracking by name, whatever the value
    static let keys = try! NSRegularExpression(pattern: #"^(?:utm[_-].*|gclid|gbraid|wbraid|dclid|fbclid|msclkid|mc_cid|mc_eid|_ga|_gl|igsh|"#
        + #"igshid|mibextid|srsltid|cn_channel|y_source|rwg_token|olonwp|ost_redirect_attribution|cmpid|yext_?.*)$"#, options: [.caseInsensitive])
    /// tracking only with these values
    static let values: [String: String] = ["ref": #"^(?:google|gmb|gbp|yext|bookmarks)\b"#, "referrer": "^google",
                                           "source": #"^(?:google|gmb|gbp|yext)\b"#, "cid": "^RF:YXT", "cmp": "^OKC-"]

    /// every .json file in the app bundle, subfolders included
    static func bundledJSON() -> [URL] {
        let all = FileManager.default.enumerator(at: Bundle.main.bundleURL, includingPropertiesForKeys: nil)?.allObjects as? [URL] ?? []
        return all.filter { $0.pathExtension == "json" && !$0.path.contains("/PlugIns/") }
    }

    static func isTracking(_ key: String, _ value: String) -> Bool {
        let k = key.trimmingCharacters(in: .whitespaces)
        if keys.firstMatch(in: k, range: NSRange(k.startIndex..., in: k)) != nil { return true }
        guard let pattern = values[k.lowercased()] else { return false }
        return value.trimmingCharacters(in: .whitespaces).range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    /// links in a JSON text whose query carries a tracking parameter
    static func tracked(in text: String) -> [String] {
        let t = text.replacingOccurrences(of: "\\/", with: "/")
        let rx = try! NSRegularExpression(pattern: #"https?://[^\s"'<>\\]+"#)
        return rx.matches(in: t, range: NSRange(t.startIndex..., in: t)).compactMap { m -> String? in
            let s = String(t[Range(m.range, in: t)!])
            guard let q = s.split(separator: "?", maxSplits: 1).dropFirst().first else { return nil }
            let query = q.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false).first ?? ""
            for part in query.split(separator: "&") {
                let kv = part.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
                let k = String(kv[0]).replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? String(kv[0])
                let v = kv.count > 1 ? (String(kv[1]).replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? String(kv[1])) : ""
                if isTracking(k, v) { return s }
            }
            return nil
        }
    }
}
