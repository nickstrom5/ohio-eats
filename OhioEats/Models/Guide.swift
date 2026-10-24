import Foundation
import CoreLocation

/// The lists the app is built around. Each is a filter plus an order; none uses ratings (the app only publishes data it may).
enum Guide: String, CaseIterable, Identifiable, Hashable {
    case chili, goetta, pierogi, ohioPizza, barberton, hungarian, perch, amish, honors, oldest, inspections, nearMe, all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chili: "Cincinnati Chili"
        case .goetta: "Goetta"
        case .pierogi: "Pierogi & Cleveland Plates"
        case .ohioPizza: "Ohio Pizza Styles"
        case .barberton: "Barberton Chicken"
        case .hungarian: "Hungarian Hot Dogs"
        case .perch: "Lake Erie Perch & Walleye"
        case .amish: "Amish Country"
        case .honors: "James Beard Honors"
        case .oldest: "Oldest Places"
        case .inspections: "Cincinnati Inspections"
        case .nearMe: "Near Me"
        case .all: "All Restaurants"
        }
    }

    var subtitle: String {
        switch self {
        case .chili: "Hand-checked chili parlors: three-ways, four-ways and cheese coneys"
        case .goetta: "Hand-checked goetta, Cincinnati's pork, beef and oat breakfast"
        case .pierogi: "Hand-checked pierogi, corned beef and cassata cake"
        case .ohioPizza: "Hand-checked tavern-cut, Dayton, Ohio Valley and Brier Hill pizza"
        case .barberton: "Hand-checked Serbian-style fried chicken with hot rice"
        case .hungarian: "Hand-checked Toledo Hungarian hot dogs"
        case .perch: "Hand-checked yellow perch and walleye on the Lake Erie shore"
        case .amish: "Hand-checked Amish-style home cooking in Amish Country"
        case .honors: "James Beard winners, finalists and America's Classics"
        case .oldest: "Founding years checked at the same address, oldest first"
        case .inspections: "The Cincinnati Health Department's own results"
        case .nearMe: "Everything around you, closest first"
        case .all: "Restaurants, cafés, bars and bakeries statewide"
        }
    }

    var systemImage: String {
        switch self {
        case .chili: "flame"
        case .goetta: "frying.pan"
        case .pierogi: "fork.knife.circle"
        case .ohioPizza: "square.grid.2x2"
        case .barberton: "takeoutbag.and.cup.and.straw"
        case .hungarian: "takeoutbag.and.cup.and.straw"
        case .perch: "fish"
        case .amish: "house"
        case .honors: "star.circle"
        case .oldest: "clock.arrow.circlepath"
        case .inspections: "checkmark.seal"
        case .nearMe: "location"
        case .all: "fork.knife"
        }
    }

    /// The hand-checked Ohio guides get the accent card on Home.
    var isOhio: Bool { tag != nil }

    /// Guides whose order is a ranking worth numbering.
    var isRanked: Bool { [.oldest].contains(self) }

    var sortOptions: [SortOrder] {
        switch self {
        case .chili, .goetta, .pierogi, .ohioPizza, .barberton, .hungarian, .perch, .amish: [.featured, .nearest, .name]
        case .honors: [.iconic, .nearest]
        case .oldest: [.oldest]
        case .inspections: [.recent, .highestScore, .lowestScore, .nearest]
        case .nearMe: [.nearest]
        case .all: [.name, .nearest]
        }
    }

    var defaultSort: SortOrder { sortOptions[0] }

    /// The tag behind a hand-checked guide.
    var tag: PlaceTags? {
        switch self {
        case .chili: .chili
        case .goetta: .goetta
        case .pierogi: .pierogi
        case .ohioPizza: .ohioPizza
        case .barberton: .barberton
        case .hungarian: .hungarian
        case .perch: .perch
        case .amish: .amish
        default: nil
        }
    }

    func includes(_ p: Place) -> Bool {
        if let tag {   // the guides that promise "hand-checked" list only places checked open with a 2025–26 source
            return p.handChecked && p.tags.contains(tag)
        }
        switch self {
        case .honors: return p.jamesBeard != nil
        case .oldest: return p.founded != nil && p.tags.contains(.oldest)
        // Cincinnati only: Columbus publishes a status without dates or counts, shown on each Columbus place instead
        case .inspections: return p.inspection?.city == .cincinnati
        default: return true
        }
    }
}

enum SortOrder: String, CaseIterable, Identifiable {
    case featured, nearest, oldest, name, iconic, recent, highestScore, lowestScore
    var id: String { rawValue }
    var label: String {
        switch self {
        case .featured: "Featured first"
        case .nearest: "Nearest"
        case .oldest: "Oldest first"
        case .name: "A to Z"
        case .iconic: "America's Classics, then winners"
        case .recent: "Latest inspection first"
        case .highestScore: "Approved, fewest violations"
        case .lowestScore: "Not In Compliance first"
        }
    }
}

/// Filters shared by every list. Search text lives with each list.
struct Filters: Equatable, Codable {
    var town: String?
    var cuisine: String?
    var hideChains = false
    var confirmedOnly = false
    var includeNonRestaurants = false
    // no MICHELIN filter: Ohio has no MICHELIN Guide (BIB-GOURMAND-FILTER.md applies only where there's MICHELIN data)

    var activeCount: Int {
        [town != nil, cuisine != nil, hideChains, confirmedOnly, includeNonRestaurants].filter { $0 }.count
    }

    func allows(_ p: Place) -> Bool {
        if !includeNonRestaurants && p.isVenue { return false }
        if let town, p.city != town { return false }
        if let cuisine, p.cuisine != cuisine { return false }
        if hideChains && p.isChain { return false }
        if confirmedOnly && p.tier == .listing { return false }
        return true
    }
}

extension Filters {
    /// Filters saved by an older build may lack a key: read what's there instead of dropping them all.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(town: try c.decodeIfPresent(String.self, forKey: .town),
                  cuisine: try c.decodeIfPresent(String.self, forKey: .cuisine),
                  hideChains: try c.decodeIfPresent(Bool.self, forKey: .hideChains) ?? false,
                  confirmedOnly: try c.decodeIfPresent(Bool.self, forKey: .confirmedOnly) ?? false,
                  includeNonRestaurants: try c.decodeIfPresent(Bool.self, forKey: .includeNonRestaurants) ?? false)
    }
}

enum Ranking {
    /// the result indexes that read as not passing ("Not In Compliance", "Under Enforcement", "Closed for Violation"); set at load
    nonisolated(unsafe) static var lowBands: Set<Int> = [3, 5, 6]

    static func sort(_ places: [Place], by order: SortOrder, from here: CLLocation?) -> [Place] {
        // Keys come from fields made once at load: a localized compare, or a new CLLocation per comparison, made a 16,000-place
        // sort take most of a second (AR-13). sortKey is the normalized name, so case, accents and punctuation don't change the order.
        func name(_ a: Place, _ b: Place) -> Bool { a.sortKey != b.sortKey ? a.sortKey < b.sortKey : a.id < b.id }
        switch order {
        case .nearest where here != nil:
            // each distance once, not four times per comparison
            let from = here!
            return places.map { p in (p, p.location.map { $0.distance(from: from) } ?? .greatestFiniteMagnitude) }
                .sorted { $0.1 != $1.1 ? $0.1 < $1.1 : name($0.0, $1.0) }
                .map(\.0)
        case .featured, .nearest:
            // honored places first, then verified founding year, then name
            return places.sorted {
                let a = $0.iconicPoints ?? -1, b = $1.iconicPoints ?? -1
                if a != b { return a > b }
                let fa = $0.founded ?? 9999, fb = $1.founded ?? 9999
                return fa != fb ? fa < fb : name($0, $1)
            }
        case .oldest:
            return places.sorted { ($0.founded ?? 9999) != ($1.founded ?? 9999) ? ($0.founded ?? 9999) < ($1.founded ?? 9999) : name($0, $1) }
        case .name:
            return places.sorted(by: name)
        case .iconic:
            // an order anyone can check: the James Beard honor (America's Classic, winner, finalist, semifinalist), then name
            func jb(_ p: Place) -> Int { p.honorFlags & 1 != 0 ? 4 : p.honorFlags & 2 != 0 ? 3 : p.honorFlags & 4 != 0 ? 2 : p.honorFlags & 8 != 0 ? 1 : 0 }
            return places.sorted {
                if jb($0) != jb($1) { return jb($0) > jb($1) }
                return name($0, $1)
            }
        case .recent:
            return places.sorted {
                let a = $0.inspection?.d ?? "", b = $1.inspection?.d ?? ""
                return a != b ? a > b : name($0, $1)
            }
        case .highestScore, .lowestScore:
            // the City's own latest result (approved before not), then the violations cited (fewer is better); places without
            // a record go last either way
            let best = order == .highestScore
            func key(_ p: Place) -> Int? { p.inspection.map { (lowBands.contains($0.band) ? 1000 : 0) + $0.score } }
            return places.sorted {
                let a = key($0), b = key($1)
                if (a == nil) != (b == nil) { return a != nil }
                let x = a ?? 0, y = b ?? 0
                if x != y { return best ? x < y : x > y }
                // "Approved - No Violations" before "Minor Violations" before "Violations Abated" (the data's order)
                let ba = $0.inspection?.band ?? 0, bb = $1.inspection?.band ?? 0
                if ba != bb { return best ? ba < bb : ba > bb }
                let da = $0.inspection?.d ?? "", db = $1.inspection?.d ?? ""
                return da != db ? da > db : name($0, $1)
            }
        }
    }
}
