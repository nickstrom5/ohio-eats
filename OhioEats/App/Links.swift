import Foundation

/// Every outside link the app opens, in one place. Each official page was checked to render in a browser (2026-10-24).
/// The site is GitHub Pages at the project address until ohio.eatsranked.com resolves (Nick adds a Cloudflare CNAME
/// ohio -> nickstrom5.github.io, DNS only; then scripts/make-site.py sets CUSTOM_DOMAIN). GitHub forwards these github.io
/// addresses to the custom domain once it's set, so a build with them keeps working.
enum Links {
    static let site = URL(string: "https://nickstrom5.github.io/ohio-eats/")!
    /// The app's data updates: scripts/publish_app_data.py writes docs/data/app/ (OTA-DATA.md).
    static let appData = URL(string: site.absoluteString + "data/app/")!
    static let privacy = URL(string: "https://nickstrom5.github.io/ohio-eats/privacy.html")!
    static let terms = URL(string: "https://nickstrom5.github.io/ohio-eats/terms.html")!
    /// the Cincinnati Health Department's inspections (the portal's dataset page) and Columbus Public Health's permit layer
    static let cincinnatiInspections = URL(string: "https://data.cincinnati-oh.gov/Thriving-Neighborhoods/Cincinnati-Food-Safety-Program/rg6p-b3h3")!
    static let columbusInspections = URL(string: "https://www.arcgis.com/home/item.html?id=948d9672209948bda747b609dbeff5b3")!
    static let supportEmail = "nick@eatsranked.com"
    static var correctionEmail: URL {
        URL(string: "mailto:\(supportEmail)?subject=Ohio%20Eats%20correction")!
    }

    // MARK: Share

    /// The web app. It opens a place's panel from the hash, explore/#p=<id> (readHash in scripts/explore.js), using the app's ids.
    static let explore = URL(string: site.absoluteString + "explore/")!

    /// Whether the web app lists the place: make-site.py's rule (restaurants only; the venues the app hides by default, such as
    /// stadium stands and gas-station counters, stay out).
    static func onWeb(_ place: Place) -> Bool { !place.isVenue }

    /// What Share sends: the place's own page in the web app, never an Apple Maps or Google link (Apple Maps has its own button).
    /// The id is escaped the way the page's encodeURIComponent would escape it. A place the web app leaves out gets the web app's
    /// front page, never a #p= link that opens nothing (a unit test checks the ids against docs/data).
    static func share(_ place: Place) -> URL {
        guard onWeb(place), let id = place.id.addingPercentEncoding(withAllowedCharacters: uriComponent),
              let url = URL(string: explore.absoluteString + "#p=" + id) else { return explore }
        return url
    }

    /// The text that goes with the link: the place, its town and the app. No street address, which Messages turns into a Maps link.
    static func shareMessage(_ place: Place) -> String {
        [place.name, place.city ?? ""].filter { !$0.isEmpty }.joined(separator: ", ") + ", on Ohio Eats"
    }

    /// What encodeURIComponent leaves as is.
    private static let uriComponent = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.!~*'()")
}
