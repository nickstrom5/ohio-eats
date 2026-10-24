// Ohio Eats icon concepts, Eats Ranked style v1 (../state-prompts/ICON-STYLE.md): one flat, level, centred food on a plain
// background. Usage: swift scripts/icon-concepts.swift <outdir> -> oh-A-buckeye.png, oh-B-threeway.png, oh-C-pierogi.png (1024)
// Backgrounds follow the two palettes offered to Nick: the buckeye candy on its own peanut butter #D9A45B (chocolate on it is
// 6.6:1), the three-way on flag red #B31942, the pierogi on flag navy #0A3161. CoreGraphics y is up.
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func rgb(_ hex: UInt32) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
}
let PB: UInt32 = 0xD9A45B, RED: UInt32 = 0xB31942, NAVY: UInt32 = 0x0A3161

/// A: a buckeye candy: a peanut-butter ball dipped in chocolate, its round "eye" of bare peanut butter on the upper face (the look
/// of the buckeye nut the candy is named for) with the toothpick hole from dipping. 4 colours.
func buckeye(_ c: CGContext, _ s: CGFloat) {
    let CHOC: UInt32 = 0x3B2314, PBTOP: UInt32 = 0xEBC384
    let r = 0.35 * s, ry = 0.32 * s, cx = 0.5 * s, cy = 0.485 * s   // a little squat: it sits on its flat base
    c.setFillColor(rgb(CHOC)); c.fillEllipse(in: CGRect(x: cx - r, y: cy - ry, width: 2 * r, height: 2 * ry))
    c.setFillColor(rgb(PBTOP)); c.fillEllipse(in: CGRect(x: cx - 0.205 * s, y: cy + 0.075 * s, width: 0.41 * s, height: 0.20 * s))
    c.setFillColor(rgb(CHOC)); c.fillEllipse(in: CGRect(x: cx - 22, y: cy + 0.175 * s - 22, width: 44, height: 44))   // toothpick hole
}

/// B: a Cincinnati three-way seen from above: an oval plate, a ring of spaghetti, the chili, and a mound of finely shredded cheddar
/// with a few shreds drawn as short strokes. 6 colours with the background.
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
    c.setStrokeColor(rgb(SHRED)); c.setLineWidth(34); c.setLineCap(.round)
    for (x, y, dx, dy) in [(-0.10, 0.05, 0.06, 0.02), (0.02, 0.07, 0.06, -0.02), (0.10, 0.02, 0.05, 0.03), (-0.12, -0.03, 0.06, -0.02),
                           (-0.02, -0.01, 0.06, 0.025), (0.07, -0.06, 0.06, -0.015)] as [(CGFloat, CGFloat, CGFloat, CGFloat)] {
        c.move(to: CGPoint(x: cx + x * s, y: cy + y * s)); c.addLine(to: CGPoint(x: cx + (x + dx) * s, y: cy + (y + dy) * s))
    }
    c.strokePath()
}

/// C: two pan-fried pierogi, front elevation: half-moons lying on their flat sides, the front one overlapping the back one with a
/// background-colour gap, each with a lighter top plane, a golden pan-fried underside and four crimp folds on the rim. 4 colours.
func pierogi(_ c: CGContext, _ s: CGFloat) {
    let DOUGH: UInt32 = 0xF2D9A0, TOP: UInt32 = 0xFFF4D8, GOLD: UInt32 = 0xE2B565
    func half(_ cx: CGFloat, _ base: CGFloat, _ rx: CGFloat, _ ry: CGFloat) -> CGPath {
        let p = CGMutablePath()
        p.move(to: CGPoint(x: cx - rx, y: base))
        p.addCurve(to: CGPoint(x: cx, y: base + ry), control1: CGPoint(x: cx - rx, y: base + ry * 0.72), control2: CGPoint(x: cx - rx * 0.56, y: base + ry))
        p.addCurve(to: CGPoint(x: cx + rx, y: base), control1: CGPoint(x: cx + rx * 0.56, y: base + ry), control2: CGPoint(x: cx + rx, y: base + ry * 0.72))
        p.closeSubpath(); return p
    }
    func one(_ cx: CGFloat, _ base: CGFloat, _ rx: CGFloat, _ ry: CGFloat, gap: Bool) {
        let p = half(cx, base, rx, ry)
        if gap {   // R7 ring in the background colour where the front pierogi overlaps the back one
            c.setStrokeColor(rgb(NAVY)); c.setLineWidth(28); c.setLineJoin(.round); c.addPath(p); c.strokePath()
        }
        c.setFillColor(rgb(DOUGH)); c.addPath(p); c.fillPath()
        c.saveGState(); c.addPath(p); c.clip()
        c.setFillColor(rgb(TOP)); c.fill(CGRect(x: 0, y: base + ry * 0.58, width: s, height: s))     // lighter top plane
        c.setFillColor(rgb(GOLD)); c.fill(CGRect(x: 0, y: 0, width: s, height: base + ry * 0.22))     // pan-fried underside
        c.restoreGState()
        c.setStrokeColor(rgb(GOLD)); c.setLineWidth(34); c.setLineCap(.round)
        for t in [0.2, 0.4, 0.6, 0.8] {                                              // crimp folds on the rim, slanted along it
            let a = Double.pi * (1 - t)
            let x = cx + CGFloat(cos(a)) * (rx - 0.032 * s), y = base + CGFloat(sin(a)) * (ry - 0.032 * s)
            let tx = CGFloat(-sin(a)) * rx, ty = CGFloat(cos(a)) * ry, n = hypot(tx, ty)
            let ux = tx / n, uy = ty / n, k: CGFloat = 0.7071
            let dx = (ux * k - uy * k) * 16, dy = (ux * k + uy * k) * 16
            c.move(to: CGPoint(x: x - dx, y: y - dy)); c.addLine(to: CGPoint(x: x + dx, y: y + dy))
        }
        c.strokePath()
    }
    one(0.385 * s, 0.39 * s, 0.245 * s, 0.30 * s, gap: false)    // back
    one(0.605 * s, 0.30 * s, 0.255 * s, 0.31 * s, gap: true)     // front
}

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
func render(_ name: String, _ bg: UInt32, _ f: (CGContext, CGFloat) -> Void) {
    let ctx = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setShouldAntialias(true); ctx.setFillColor(rgb(bg)); ctx.fill(CGRect(x: 0, y: 0, width: 1024, height: 1024))
    f(ctx, 1024)
    let d = CGImageDestinationCreateWithURL(URL(fileURLWithPath: out + "/" + name) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(d, ctx.makeImage()!, nil); CGImageDestinationFinalize(d)
}
render("oh-A-buckeye.png", PB, buckeye); render("oh-B-threeway.png", RED, threeway); render("oh-C-pierogi.png", NAVY, pierogi)
render("oh-B2-threeway-chocolate.png", 0x3B2314, threeway)   // the three-way on the chosen palette's chocolate
print("ok")
