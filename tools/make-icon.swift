// Generates Resources/AppIcon.icns. Run: swift tools/make-icon.swift
import AppKit

func color(_ hex: UInt32, _ a: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}

func render(_ px: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                               isPlanar: false, colorSpaceName: .deviceRGB,
                               bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = NSSize(width: px, height: px)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext
    let s = CGFloat(px) / 1024
    ctx.scaleBy(x: s, y: s)

    // Tile with drop shadow
    let body = NSRect(x: 100, y: 100, width: 824, height: 824)
    let tile = NSBezierPath(roundedRect: body, xRadius: 185, yRadius: 185)
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = color(0x000000, 0.35)
    shadow.shadowOffset = NSSize(width: 0, height: -12)
    shadow.shadowBlurRadius = 24
    shadow.set()
    color(0x2A313B).setFill()
    tile.fill()
    NSGraphicsContext.restoreGraphicsState()

    // Slate gradient (top lighter -> bottom darker)
    NSGradient(starting: color(0x434D5A), ending: color(0x222830))!.draw(in: tile, angle: -90)

    // Subtle inner border
    color(0xFFFFFF, 0.10).setStroke()
    let inner = NSBezierPath(roundedRect: body.insetBy(dx: 3, dy: 3), xRadius: 182, yRadius: 182)
    inner.lineWidth = 6
    inner.stroke()

    // Chalk text lines (top to bottom)
    let chalk = color(0xE8EDF4, 0.92)
    let lines: [(y: CGFloat, w: CGFloat)] = [(655, 430), (555, 520), (455, 340)]
    for l in lines {
        chalk.setFill()
        NSBezierPath(roundedRect: NSRect(x: 235, y: l.y, width: l.w, height: 38),
                     xRadius: 19, yRadius: 19).fill()
    }
    // Last short line + teal cursor
    chalk.setFill()
    NSBezierPath(roundedRect: NSRect(x: 235, y: 355, width: 190, height: 38),
                 xRadius: 19, yRadius: 19).fill()
    color(0x5EEAD4).setFill()
    NSBezierPath(roundedRect: NSRect(x: 452, y: 331, width: 30, height: 86),
                 xRadius: 10, yRadius: 10).fill()

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let fm = FileManager.default
let iconset = "build/AppIcon.iconset"
try? fm.removeItem(atPath: iconset)
try! fm.createDirectory(atPath: iconset, withIntermediateDirectories: true)
let sizes: [(name: String, px: Int)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32), ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256), ("icon_256x256", 256),
    ("icon_256x256@2x", 512), ("icon_512x512", 512), ("icon_512x512@2x", 1024),
]
for (name, px) in sizes {
    try! render(px).write(to: URL(fileURLWithPath: "\(iconset)/\(name).png"))
}
print("iconset written")
