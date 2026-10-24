import SwiftUI
import UIKit
import CoreText

/// Buckeye-candy palette (Nick's pick, 2026-10-24), light only: chocolate #3B2314 (15:1 on white) for titles, tint and accents;
/// peanut butter #D9A45B only ever as a fill under chocolate text (6.6:1), never as text on white (2.2:1); milk chocolate #6B4226
/// (8.6:1) for links; caramel #8A5A33 (white text 5.9:1) for the hand-checked pins and swipe actions. No team or college colors
/// (Browns/Bengals, Guardians/Reds and Ohio State loyalties split the state). The names `green`/`gold`/`red` are kept from
/// Wisconsin Eats so the shared views read the same: here `green` is chocolate, `gold` peanut butter and `red` caramel.
enum Theme {
    static let green = Color(hex: 0x3B2314)      // chocolate: titles, tint, primary text accents, cards under white text
    static let green2 = Color(hex: 0x6B4226)     // milk chocolate: links
    static let gold = Color(hex: 0xD9A45B)       // peanut butter: fills under chocolate text (guide cards, top ranks)
    static let goldSoft = Color(hex: 0xF6E7CF)
    static let lime = Color(hex: 0xD9A45B)       // peanut butter stripes in the burgee band, fills only
    static let limeSoft = Color(hex: 0xF6E7CF)
    static let sand = Color(hex: 0xFBF6EF)
    static let red = Color(hex: 0x8A5A33)        // caramel: hand-checked pins, chips under white text, swipe actions
    static let ink = Color(hex: 0x24160C)
    static let ink2 = Color(hex: 0x3B2314)
    static let muted = Color(hex: 0x6B5646)
    static let surface = Color.white
    static let surface2 = Color(hex: 0xFAF5EE)
    static let surface3 = Color(hex: 0xF1E6D6)
    static let rule = Color(hex: 0xEADFD2)
    static let rule2 = Color(hex: 0xCDB9A3)
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}

/// A small uppercase label: "STONE CRAB", "1 MICHELIN STAR".
struct Chip: View {
    enum Style { case gold, green, red, plain, dashed }
    let text: String
    var style: Style = .plain

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(0.4)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .foregroundStyle(style == .green || style == .red ? Color.white : style == .dashed ? Theme.muted : style == .gold ? Theme.ink : Theme.green)
            .background {
                RoundedRectangle(cornerRadius: 5).fill(style == .gold ? Theme.goldSoft : style == .green ? Theme.green : style == .red ? Theme.red
                                                       : style == .dashed ? .clear : Theme.surface2)
            }
            .overlay {
                if style == .dashed { RoundedRectangle(cornerRadius: 5).strokeBorder(Theme.rule2, style: StrokeStyle(lineWidth: 1, dash: [3, 2])) }
            }
            .accessibilityLabel(text)
    }
}

/// The city's own inspection result, as published: "Cincinnati · Approved - Minor Violations · 4 violations", "Columbus · Standards
/// Met". Ohio has no statewide grade and the app computes none.
struct BandBadge: View {
    let city: InspectionCity
    let band: InspectionBand
    var score: Int? = nil
    var large = false

    private var count: Int? { city == .cincinnati ? score : nil }   // Columbus publishes no counts

    var body: some View {
        Text(([city.name, band.label] + (count.map { ["\($0) violation\($0 == 1 ? "" : "s")"] } ?? [])).joined(separator: " · ").uppercased())
            .font(large ? .footnote.weight(.heavy) : .caption2.weight(.heavy))
            .tracking(0.4)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, large ? 10 : 7).padding(.vertical, large ? 6 : 3)
            .foregroundStyle(band.ink)
            .background(RoundedRectangle(cornerRadius: 6).fill(band.fill))
            .accessibilityLabel("\(city.name) inspection: \(band.label)" + (count.map { ", \($0) violations cited" } ?? ""))
    }
}

/// Ohio Eats' lettering: the system face drawn compressed and heavy for titles and guide names (like a chili parlor's sign), and the
/// system monospaced face for numbers, dates and small labels. No bundled fonts.
struct DisplayFont: ViewModifier {
    let size: CGFloat
    var weight: Font.Weight = .black
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content.font(.system(size: size * min(scale, 1.6), weight: weight).width(.compressed))
    }
}

/// Numbers, dates and small labels in the system monospaced face, scaled like DisplayFont.
struct MonoFont: ViewModifier {
    let size: CGFloat
    var weight: Font.Weight = .semibold
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content.font(.system(size: size * min(scale, 1.6), weight: weight, design: .monospaced))
    }
}

extension View {
    func displayFont(_ size: CGFloat, weight: Font.Weight = .black) -> some View {
        modifier(DisplayFont(size: size, weight: weight))
    }

    func monoFont(_ size: CGFloat, weight: Font.Weight = .semibold) -> some View {
        modifier(MonoFont(size: size, weight: weight))
    }
}

/// The state flag's swallowtail burgee as a pennant band under the Home title (Nick's pick, 2026-10-24), in the buckeye palette:
/// five peanut-butter and white stripes ending in the swallowtail notch, a chocolate triangle at the hoist. No stars, circle or seal.
struct Stripes: View {
    var height: CGFloat = 6

    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 0) {
                ForEach(0..<5) { i in Rectangle().fill(i % 2 == 0 ? Theme.lime : Color.white).frame(height: height * 0.7) }
            }
            .clipShape(Swallowtail())
            Hoist().fill(Theme.green).frame(width: height * 9)
        }
        .frame(height: height * 3.5)
        .accessibilityHidden(true)
    }

    /// the band with a V cut into its fly end
    private struct Swallowtail: Shape {
        func path(in r: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: r.minX, y: r.minY)); p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
            p.addLine(to: CGPoint(x: r.maxX - r.height * 1.4, y: r.midY)); p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
            p.addLine(to: CGPoint(x: r.minX, y: r.maxY)); p.closeSubpath()
            return p
        }
    }

    /// the triangle at the hoist, its point toward the fly
    private struct Hoist: Shape {
        func path(in r: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: r.minX, y: r.minY)); p.addLine(to: CGPoint(x: r.maxX, y: r.midY)); p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
            p.closeSubpath()
            return p
        }
    }
}

extension View {
    /// An inline navigation title in the display type. UINavigationBar.appearance() didn't reach every SwiftUI bar on iOS 27
    /// (the Map title went from compressed blue to plain black after a push and pop; place titles were always plain), so the
    /// title is our own view in the bar. The navigation title is still set, for the back button and VoiceOver.
    func inlineTitle(_ title: String) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title).displayFont(19, weight: .heavy).foregroundStyle(Theme.green)
                        .lineLimit(1).minimumScaleFactor(0.7)
                        .accessibilityAddTraits(.isHeader)
                }
            }
    }
}
