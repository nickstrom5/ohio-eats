import SwiftUI

struct AboutView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("OHIO EATS").displayFont(32).foregroundStyle(Theme.green)
                    Text("A free guide to \(model.restaurantCount.formatted()) Ohio restaurants, with hand-checked lists of Ohio's own food (Cincinnati chili parlors, goetta, pierogi and Cleveland's Eastern European plates, Ohio's pizza styles, Barberton chicken, Hungarian hot dogs, Lake Erie perch and walleye, Amish Country dining rooms, the oldest places), James Beard honors, and the Cincinnati Health Department's and Columbus Public Health's own inspection results. No account, no ads, no tracking.")
                        .font(.subheadline).foregroundStyle(Theme.ink2)
                    Text("Ohio Eats is an independent app by Nicholas Soderstrom. It is not affiliated with, endorsed by or operated by the State of Ohio, the Ohio Department of Health, the Ohio Division of Liquor Control, any local health district, the City of Cincinnati, the Cincinnati Health Department, the City of Columbus, Columbus Public Health, The Ohio State University, the James Beard Foundation, Apple, or any restaurant or chain. Other names are trademarks of their owners.")
                        .font(.footnote).foregroundStyle(Theme.muted)
                }
                .padding(.vertical, 4)
            }
            Section("How the lists are built") {
                Text("The food lists (chili parlors, goetta, pierogi and Cleveland plates, pizza styles, Barberton chicken, Hungarian hot dogs, perch and walleye, Amish Country) and the oldest-places list are hand-checked: each place was checked against a 2025 or 2026 source (the place's own website or menu, local news or an official tourism listing), with the address checked. Founding years mean the year it opened at this address.")
                Text("Honors are James Beard Foundation awards and nominations, plus America's Classics. Ohio has no MICHELIN Guide.")
                Text("Places start from open map listings (Overture Maps). Ohio has no statewide list of licensed restaurants, so the listings were checked inside Columbus and Cincinnati, the two cities that publish every licensed place: high-confidence listings matched the city's own list \(rate("meta_high")) of the time, and the app keeps the kinds that proved reliable statewide. Places matched to a Columbus Public Health permit or a live Cincinnati food license are marked official, and licensed restaurants the map data missed there are added. Adult clubs are left out. Website links are checked, and any that no longer belong to the place are left out.")
                Text("Inspection results are the cities' own. Cincinnati: the result of each visit, word for word (\u{201C}Approved - Minor Violations\u{201D}, \u{201C}Not In Compliance\u{201D} …), with the violations cited. Columbus: each place's current status (\u{201C}Standards Met\u{201D}, \u{201C}Under Enforcement\u{201D}, \u{201C}Closed for Violation\u{201D}). Ohio's other health districts don't publish results in bulk, and Ohio has no statewide grade, so this app computes none.")
                Text("Ratings, reviews, hours and photos are Apple Maps' own, shown live in Apple's place card. This app doesn't store or rank by them.")
            }
            .font(.subheadline).foregroundStyle(Theme.ink2)
            Section("Sources") {
                source("Cincinnati Health Department", "Cincinnati Food Safety Program (data.cincinnati-oh.gov), published by the City of Cincinnati in the public domain and refreshed daily: licenses, inspections and violations of the Ohio Uniform Food Safety Code. Visits through \(DayFormat.text(model.inspectionsThrough["cin"]) ?? ""), shown as published; modified for use in this app. For a license's official status, ask the Cincinnati Health Department.", Links.cincinnatiInspections.absoluteString)
                source("Columbus Public Health", "Restaurant & Market Health Inspections (maps2.columbus.gov), City of Columbus, Public Health Department. \u{201C}This data is dedicated to the public domain under the Creative Commons Universal License (CC0).\u{201D} Permits and statuses read \(DayFormat.text(model.inspectionsThrough["col"]) ?? ""); the City updates the layer nightly.", Links.columbusInspections.absoluteString)
                source("Overture Maps Foundation", "Restaurant listings and websites come from Overture Maps Foundation places data (overturemaps.org)\(model.overtureRelease.map { ", release \($0)" } ?? ""), filtered and reformatted for this app.\n• Data from Meta, Microsoft, DAC and BrightQuery. Available under CDLA Permissive 2.0.\n• Data from Foursquare. \(foursquareCopyright) Available under Apache 2.0. Foursquare data was transformed to the Overture schema; this app further filtered and reformatted it. See the NOTICE below.\n• Data from AllThePlaces. Available under CC0 1.0.", "https://overturemaps.org")
                source("Honors", "James Beard Foundation awards, finalists and America's Classics are reported as facts and checked by hand against the official announcements. James Beard Foundation and James Beard Award are trademarks of the James Beard Foundation. Other names belong to their owners.", "https://www.jamesbeard.org/awards")
                source("Maps", "Maps, place cards and directions by Apple Maps.", nil)
            }
            Section("Licenses") {
                NavigationLink("Community Data License Agreement – Permissive 2.0") { LicenseText(file: "CDLA-Permissive-2.0", title: "CDLA Permissive 2.0") }
                NavigationLink("Apache License 2.0") { LicenseText(file: "Apache-2.0", title: "Apache License 2.0") }
                NavigationLink("Foursquare OS Places NOTICE") { LicenseText(file: "Foursquare-NOTICE", title: "Foursquare NOTICE") }
            }
            Section("Privacy") {
                Text("The app collects nothing. Your location, if you allow it, only sorts lists by distance and shows where you are on the map, on this device. Saved places stay on this device.")
                    .font(.subheadline).foregroundStyle(Theme.ink2)
                Link("Privacy policy", destination: Links.privacy)
                Link("Terms of use", destination: Links.terms)
            }
            Section("Help") {
                Link("Report a missing or closed place", destination: Links.correctionEmail)
                Link("Email \(Links.supportEmail)", destination: URL(string: "mailto:\(Links.supportEmail)")!)
                Link("Website", destination: Links.site)
                Text("Data as of \(DayFormat.text(model.generated) ?? model.generated). Places open and close; check before you go. Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")")
                    .font(.footnote).foregroundStyle(Theme.muted)
            }
        }
        .navigationTitle("About")
        .tint(Theme.green)
    }

    /// the copyright line exactly as the bundled Foursquare NOTICE has it, so the two can't disagree
    private var foursquareCopyright: String {
        guard let url = Bundle.main.url(forResource: "Foursquare-NOTICE", withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8),
              let line = text.split(separator: "\n").first(where: { $0.hasPrefix("©") }) else { return "© Foursquare Labs, Inc. All rights reserved." }
        return line.trimmingCharacters(in: .whitespaces)
    }

    private func rate(_ group: String) -> String {
        let v = model.calibration.areas.values.compactMap { $0.groups[group]?.official }.map { Int(($0 * 100).rounded()) }.sorted()
        guard let lo = v.first, let hi = v.last else { return "most" }
        return lo == hi ? "\(lo)%" : "\(lo)–\(hi)%"
    }

    @ViewBuilder
    private func source(_ name: String, _ detail: String, _ url: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if let url, let u = URL(string: url) { Link(name, destination: u).font(.subheadline.weight(.semibold)) }
            else { Text(name).font(.subheadline.weight(.semibold)) }
            Text(detail).font(.caption).foregroundStyle(Theme.muted)
        }
    }
}

/// A bundled license text (Resources/Licenses), reflowed rather than shown as raw 80-column lines.
struct LicenseText: View {
    let file: String
    let title: String

    var body: some View {
        ScrollView {
            Text(text).font(.footnote).foregroundStyle(Theme.ink).textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading).padding()
        }
        .inlineTitle(title)
    }

    private var text: String {
        guard let url = Bundle.main.url(forResource: file, withExtension: "txt"),
              let raw = try? String(contentsOf: url, encoding: .utf8) else { return "License text missing." }
        // join hard-wrapped lines into paragraphs; keep blank lines and list items as breaks
        var out: [String] = []
        for para in raw.components(separatedBy: "\n\n") {
            let lines = para.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
            var joined = ""
            for l in lines where !l.isEmpty {
                let startsItem = l.hasPrefix("–") || l.hasPrefix("-") || l.range(of: #"^\(?[a-z0-9]{1,3}[.)]\s"#, options: .regularExpression) != nil
                joined += joined.isEmpty ? l : (startsItem ? "\n" + l : " " + l)
            }
            if !joined.isEmpty { out.append(joined) }
        }
        return out.joined(separator: "\n\n")
    }
}
