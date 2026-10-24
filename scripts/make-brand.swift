// Ohio Eats brand: the app icon (Nick's pick 2026-10-24, concept B of scripts/icon-concepts.swift: a Cincinnati three-way from above, on
// chocolate), in the shared Eats Ranked style (../state-prompts/ICON-STYLE.md). Usage, from oh-eats/: swift scripts/make-brand.swift
// -> OhioEats/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png, the website's icons (docs/icon-512.png, icon-192.png,
// apple-touch-icon.png, favicon-32.png) and share image (docs/og.png).
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func rgb(_ hex: UInt32) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
}
let CHOC: UInt32 = 0x3B2314, PB: UInt32 = 0xD9A45B

/// A Cincinnati three-way seen from above: an oval plate, a ring of spaghetti, the chili, and a mound of finely shredded cheddar with a
/// few shreds drawn as short strokes. 6 colours with the background. Same drawing as icon-concepts.swift threeway(), with the stroke
/// width scaled so the small website icons keep its proportions.
func threeway(_ c: CGContext, _ s: CGFloat) {
    let PLATE: UInt32 = 0xFFFFFF, PASTA: UInt32 = 0xF1D58E, CHILI: UInt32 = 0x6E2A16, CHEESE: UInt32 = 0xF6B21B, SHRED: UInt32 = 0xD8890F
    let cx = 0.5 * s, cy = 0.485 * s
    func oval(_ w: CGFloat, _ h: CGFloat, _ hex: UInt32, dy: CGFloat = 0) {
        c.setFillColor(rgb(hex)); c.fillEllipse(in: CGRect(x: cx - w * s / 2, y: cy + dy * s - h * s / 2, width: w * s, height: h * s))
    }
    oval(0.73, 0.52, PLATE)
    oval(0.60, 0.40, PASTA)
    oval(0.50, 0.32, CHILI)
    oval(0.38, 0.24, CHEESE, dy: 0.012)
    c.setStrokeColor(rgb(SHRED)); c.setLineWidth(34.0 / 1024 * s); c.setLineCap(.round)
    for (x, y, dx, dy) in [(-0.10, 0.05, 0.06, 0.02), (0.02, 0.07, 0.06, -0.02), (0.10, 0.02, 0.05, 0.03), (-0.12, -0.03, 0.06, -0.02),
                           (-0.02, -0.01, 0.06, 0.025), (0.07, -0.06, 0.06, -0.015)] as [(CGFloat, CGFloat, CGFloat, CGFloat)] {
        c.move(to: CGPoint(x: cx + x * s, y: cy + y * s)); c.addLine(to: CGPoint(x: cx + (x + dx) * s, y: cy + (y + dy) * s))
    }
    c.strokePath()
}

func save(_ ctx: CGContext, _ path: String) {
    let d = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(d, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(d) else { fatalError("could not write \(path)") }
    print("wrote", path)
}

func render(_ n: Int, _ path: String) {
    let ctx = CGContext(data: nil, width: n, height: n, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setShouldAntialias(true)
    ctx.setFillColor(rgb(CHOC)); ctx.fill(CGRect(x: 0, y: 0, width: n, height: n))
    threeway(ctx, CGFloat(n))
    save(ctx, path)
}
render(1024, "OhioEats/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png")
try? FileManager.default.createDirectory(atPath: "docs", withIntermediateDirectories: true)
for (n, name) in [(512, "icon-512.png"), (192, "icon-192.png"), (180, "apple-touch-icon.png"), (32, "favicon-32.png")] {
    render(n, "docs/" + name)
}

/// The share image (1200 x 630): chocolate, the three-way at the left, the name and tagline at the right, and the flag's swallowtail
/// burgee along the bottom in the palette (peanut-butter and white stripes, a chocolate-edged hoist triangle, the notch at the fly).
func og(_ path: String) {
    let W = 1200, H = 630
    let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setShouldAntialias(true)
    ctx.setFillColor(rgb(CHOC)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    for i in 0..<5 { ctx.setFillColor(rgb(i % 2 == 0 ? PB : 0xFFFFFF)); ctx.fill(CGRect(x: 0, y: CGFloat(i) * 9, width: CGFloat(W), height: 9)) }
    ctx.setFillColor(rgb(CHOC))   // the swallowtail notch at the fly, and the hoist triangle
    ctx.move(to: CGPoint(x: CGFloat(W), y: 0)); ctx.addLine(to: CGPoint(x: CGFloat(W) - 60, y: 22.5)); ctx.addLine(to: CGPoint(x: CGFloat(W), y: 45)); ctx.fillPath()
    ctx.setFillColor(rgb(0x6B4226))
    ctx.move(to: CGPoint(x: 0, y: 0)); ctx.addLine(to: CGPoint(x: 140, y: 22.5)); ctx.addLine(to: CGPoint(x: 0, y: 45)); ctx.fillPath()
    ctx.saveGState(); ctx.translateBy(x: 10, y: 50); threeway(ctx, 560); ctx.restoreGState()
    let ns = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = ns
    let title = NSFont(name: "AvenirNextCondensed-Heavy", size: 120) ?? NSFont.boldSystemFont(ofSize: 110)
    let sub = NSFont(name: "AvenirNextCondensed-DemiBold", size: 46) ?? NSFont.boldSystemFont(ofSize: 42)
    NSAttributedString(string: "OHIO EATS", attributes: [.font: title, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 580, y: 330))
    NSAttributedString(string: "CHILI, PIEROGI & PIZZA", attributes: [.font: sub, .foregroundColor: NSColor(srgbRed: 0.85, green: 0.64, blue: 0.36, alpha: 1)]).draw(at: NSPoint(x: 584, y: 270))
    NSGraphicsContext.restoreGraphicsState()
    save(ctx, path)
}
og("docs/og.png")
