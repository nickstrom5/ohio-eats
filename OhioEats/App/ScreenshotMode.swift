import Foundation
import CoreLocation
import UIKit

/// `-screenshot <name>` opens one screen with fixed state for App Store screenshots (scripts/capture-screenshots.sh).
/// Names: home, chili, pizza, amish, pierogi, detail, map, honors, oldest, saved, about.
enum ScreenshotMode {
    /// Debug builds only: an App Store build ignores the launch argument, so no one can reach seeded screens or fake locations.
    static var name: String? {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-screenshot"), i + 1 < args.count else { return nil }
        return args[i + 1]
        #else
        return nil
        #endif
    }
    static var isActive: Bool { name != nil }

    @MainActor
    static func apply(to model: AppModel) {
        guard let name, model.isLoaded else { return }
        model.filters = Filters()
        // downtown Cincinnati (Fountain Square), so "nearest" lists have distances without a permission prompt
        model.screenshotLocation = CLLocation(latitude: 39.1015, longitude: -84.5125)
        // by name and town, ignoring case, so a rebuild with a slightly different casing still finds the place; the hand-checked one first.
        // App Store rule: no screenshot shows a place whose latest result is "Not In Compliance", "Under Enforcement" or "Closed for
        // Violation" (a unit test checks these three picks)
        let pick = { (n: String, town: String?) -> Place? in
            let hits = model.places.filter { $0.name.caseInsensitiveCompare(n) == .orderedSame && (town == nil || $0.city == town) }
            return hits.first(where: \.handChecked) ?? hits.first
        }
        for p in [pick(Self.chiliPick.0, Self.chiliPick.1), pick(Self.toledoPick.0, Self.toledoPick.1), pick(Self.barbertonPick.0, Self.barbertonPick.1)]
            .compactMap({ $0 }) where !model.isSaved(p) {
            model.toggleSaved(p)
        }
        let open = { (g: Guide) in model.tab = .guides; model.selectedGuide = g; model.guidesPath = [.guide(g)] }
        switch name {
        case "chili": open(.chili)
        case "pizza":
            // from the Statehouse, so Columbus's own pizzerias come first and Dayton's Marion's Piazza follows (not six of one name)
            model.screenshotLocation = CLLocation(latitude: 39.9612, longitude: -82.9988)
            open(.ohioPizza)
        case "amish":
            // from Berlin, in the middle of Holmes County's Amish Country
            model.screenshotLocation = CLLocation(latitude: 40.5612, longitude: -81.7943)
            open(.amish)
        case "pierogi":
            // from Public Square, so Cleveland's pierogi kitchens are a short drive
            model.screenshotLocation = CLLocation(latitude: 41.4995, longitude: -81.6937)
            open(.pierogi)
        case "honors": open(.honors)
        case "oldest": open(.oldest)
        case "detail":
            open(.chili)
            if let p = pick(Self.chiliPick.0, Self.chiliPick.1) ?? model.places.first { model.selectedPlace = p; model.guidesPath.append(.place(p)) }
        case "map": model.tab = .map
        case "saved": model.tab = .saved
        case "about": model.tab = .about
        default: model.tab = .guides; model.selectedGuide = nil
        }
        // iPad shows the place column next to every list, so give each shot a place instead of "Pick a place": a different
        // honored or hand-checked one per shot. That column shows the whole visit history, so the iPad's chili parlor is one whose
        // every visit was approved (a unit test checks).
        guard UIDevice.current.userInterfaceIdiom == .pad, model.selectedPlace == nil else { return }
        let place: Place? = switch name {
        case "home", "chili", "map": pick(Self.padChiliPick.0, Self.padChiliPick.1)
        case "pizza": pick(Self.pizzaPick.0, Self.pizzaPick.1)
        case "amish": pick(Self.amishPick.0, Self.amishPick.1)
        case "pierogi": pick(Self.barbertonPick.0, Self.barbertonPick.1)
        case "saved", "oldest", "honors": pick(Self.toledoPick.0, Self.toledoPick.1)
        case "about": nil
        default: pick(Self.chiliPick.0, Self.chiliPick.1)
        }
        model.selectedPlace = place
    }

    /// the places the screenshots open and save (name, town)
    static let chiliPick = ("Camp Washington Chili", "Cincinnati")
    static let toledoPick = ("Tony Packo's", "Toledo")
    static let barbertonPick = ("Belgrade Gardens", "Barberton")
    static let padChiliPick = ("Pleasant Ridge Chili", "Cincinnati")
    static let pizzaPick = ("Terita's Pizza", "Columbus")
    static let amishPick = ("Boyd & Wurthmann Restaurant", "Berlin")
}
