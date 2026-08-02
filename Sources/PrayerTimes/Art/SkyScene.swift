import AppKit
import SwiftUI

struct SkyPalette {
    let top: Color
    let middle: Color
    let bottom: Color
    let sunColor: Color
    let sunY: CGFloat
    let showStars: Bool
    let showMoon: Bool
    let showClouds: Bool
    let glowIntensity: Double
    var textInkOverride: Color? = nil

    private static let darkInk = Color(red: 0.06, green: 0.08, blue: 0.13)

    private var rendersLightText: Bool {
        if let textInkOverride {
            let components = textInkOverride.srgbComponents
            let luminance = Self.relativeLuminance(r: components.r, g: components.g, b: components.b)
            return luminance > 0.5
        }
        return usesLightInk
    }

    var usesLightInk: Bool {
        let colors = [top, middle, bottom]
        var totalR = 0.0
        var totalG = 0.0
        var totalB = 0.0

        for color in colors {
            let components = color.srgbComponents
            totalR += components.r
            totalG += components.g
            totalB += components.b
        }

        let backgroundLuminance = Self.relativeLuminance(
            r: totalR / 3,
            g: totalG / 3,
            b: totalB / 3
        )
        return Self.contrastRatio(l1: 1.0, l2: backgroundLuminance) >= 4.5
    }

    var textInk: Color {
        if let textInkOverride { return textInkOverride }
        return usesLightInk ? .white : Self.darkInk
    }

    var textShadow: Color {
        rendersLightText ? .black.opacity(0.35) : .white.opacity(0.45)
    }

    private static func relativeLuminance(r: Double, g: Double, b: Double) -> Double {
        func linearize(_ component: Double) -> Double {
            component <= 0.03928 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
        }

        let red = linearize(r)
        let green = linearize(g)
        let blue = linearize(b)
        return 0.2126 * red + 0.7152 * green + 0.0722 * blue
    }

    private static func contrastRatio(l1: Double, l2: Double) -> Double {
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    static func palette(for prayer: Prayer) -> SkyPalette {
        switch prayer {
        case .imsak:
            SkyPalette(
                top: Color(red: 0.08, green: 0.10, blue: 0.28),
                middle: Color(red: 0.18, green: 0.24, blue: 0.45),
                bottom: Color(red: 0.45, green: 0.58, blue: 0.78),
                sunColor: .clear,
                sunY: 0.85,
                showStars: true,
                showMoon: true,
                showClouds: false,
                glowIntensity: 0.2
            )
        case .gunes:
            SkyPalette(
                top: Color(red: 0.55, green: 0.72, blue: 0.92),
                middle: Color(red: 0.95, green: 0.72, blue: 0.52),
                bottom: Color(red: 1.0, green: 0.55, blue: 0.30),
                sunColor: Color(red: 1.0, green: 0.85, blue: 0.35),
                sunY: 0.72,
                showStars: false,
                showMoon: false,
                showClouds: false,
                glowIntensity: 0.7,
                textInkOverride: .white
            )
        case .ogle:
            SkyPalette(
                top: Color(red: 0.15, green: 0.45, blue: 0.92),
                middle: Color(red: 0.28, green: 0.62, blue: 0.98),
                bottom: Color(red: 0.45, green: 0.78, blue: 1.0),
                sunColor: Color(red: 1.0, green: 0.95, blue: 0.55),
                sunY: 0.22,
                showStars: false,
                showMoon: false,
                showClouds: true,
                glowIntensity: 1.0,
                textInkOverride: .white
            )
        case .ikindi:
            SkyPalette(
                top: Color(red: 0.55, green: 0.68, blue: 0.92),
                middle: Color(red: 0.98, green: 0.72, blue: 0.38),
                bottom: Color(red: 0.95, green: 0.52, blue: 0.18),
                sunColor: Color(red: 1.0, green: 0.78, blue: 0.25),
                sunY: 0.58,
                showStars: false,
                showMoon: false,
                showClouds: false,
                glowIntensity: 0.85,
                textInkOverride: .white
            )
        case .aksam:
            SkyPalette(
                top: Color(red: 0.25, green: 0.12, blue: 0.45),
                middle: Color(red: 0.85, green: 0.28, blue: 0.35),
                bottom: Color(red: 1.0, green: 0.45, blue: 0.15),
                sunColor: Color(red: 1.0, green: 0.35, blue: 0.12),
                sunY: 0.78,
                showStars: false,
                showMoon: false,
                showClouds: false,
                glowIntensity: 0.6
            )
        case .yatsi:
            SkyPalette(
                top: Color(red: 0.02, green: 0.04, blue: 0.12),
                middle: Color(red: 0.06, green: 0.10, blue: 0.28),
                bottom: Color(red: 0.12, green: 0.18, blue: 0.38),
                sunColor: .clear,
                sunY: 0.85,
                showStars: true,
                showMoon: true,
                showClouds: false,
                glowIntensity: 0.35
            )
        }
    }
}

struct Skyline: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let baseY = rect.maxY
        path.move(to: CGPoint(x: 0, y: baseY))

        let w = rect.width
        let h = rect.height

        path.addLine(to: CGPoint(x: w * 0.08, y: baseY - h * 0.18))
        path.addLine(to: CGPoint(x: w * 0.10, y: baseY - h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.12, y: baseY - h * 0.18))
        path.addLine(to: CGPoint(x: w * 0.18, y: baseY - h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.22, y: baseY - h * 0.42))
        path.addLine(to: CGPoint(x: w * 0.26, y: baseY - h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.34, y: baseY - h * 0.30))
        path.addLine(to: CGPoint(x: w * 0.38, y: baseY))
        path.addLine(to: CGPoint(x: w * 0.46, y: baseY - h * 0.20))
        path.addLine(to: CGPoint(x: w * 0.50, y: baseY - h * 0.50))
        path.addLine(to: CGPoint(x: w * 0.54, y: baseY - h * 0.20))
        path.addLine(to: CGPoint(x: w * 0.62, y: baseY - h * 0.28))
        path.addLine(to: CGPoint(x: w * 0.66, y: baseY - h * 0.48))
        path.addLine(to: CGPoint(x: w * 0.70, y: baseY - h * 0.28))
        path.addLine(to: CGPoint(x: w * 0.78, y: baseY - h * 0.16))
        path.addLine(to: CGPoint(x: w * 0.82, y: baseY - h * 0.38))
        path.addLine(to: CGPoint(x: w * 0.86, y: baseY - h * 0.16))
        path.addLine(to: CGPoint(x: w, y: baseY - h * 0.12))
        path.addLine(to: CGPoint(x: w, y: baseY))
        path.closeSubpath()
        return path
    }
}

struct SkyScene: View {
    let prayer: Prayer
    var animate: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 3600 : 1 / 30, paused: reduceMotion || !animate)) { timeline in
            Canvas { context, size in
                let palette = SkyPalette.palette(for: prayer)
                let phase = timeline.date.timeIntervalSinceReferenceDate

                drawGradient(context: &context, size: size, palette: palette)

                if palette.showStars {
                    drawStars(context: &context, size: size, phase: phase, bright: prayer == .yatsi)
                }

                if palette.showMoon {
                    drawMoon(context: &context, size: size, palette: palette)
                }

                if palette.sunColor != .clear {
                    drawSun(context: &context, size: size, palette: palette, phase: phase)
                }

                if palette.showClouds {
                    drawClouds(context: &context, size: size)
                }

                drawSkyline(context: &context, size: size)
            }
        }
    }

    private func drawGradient(context: inout GraphicsContext, size: CGSize, palette: SkyPalette) {
        let rect = CGRect(origin: .zero, size: size)
        context.fill(
            Path(rect),
            with: .linearGradient(
                Gradient(colors: [palette.top, palette.middle, palette.bottom]),
                startPoint: CGPoint(x: size.width / 2, y: 0),
                endPoint: CGPoint(x: size.width / 2, y: size.height)
            )
        )
    }

    private func drawStars(context: inout GraphicsContext, size: CGSize, phase: Double, bright: Bool) {
        let count = bright ? 28 : 8
        for index in 0..<count {
            let xSeed = Double((index * 73) % 997) / 997.0
            let ySeed = Double((index * 131) % 853) / 853.0
            let x = xSeed * size.width * 0.95 + size.width * 0.02
            let y = ySeed * size.height * 0.55 + size.height * 0.05
            let twinkle = 0.45 + 0.55 * abs(sin(phase * 1.4 + Double(index)))
            let radius = bright ? CGFloat(1.0 + twinkle) : CGFloat(0.8 + twinkle * 0.4)
            let rect = CGRect(x: x, y: y, width: radius, height: radius)
            context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(twinkle * 0.9)))
        }
    }

    private func drawMoon(context: inout GraphicsContext, size: CGSize, palette: SkyPalette) {
        let center = CGPoint(x: size.width * 0.78, y: size.height * palette.sunY)
        let moonRect = CGRect(x: center.x - 10, y: center.y - 10, width: 20, height: 20)
        context.fill(Path(ellipseIn: moonRect), with: .color(.white.opacity(0.9)))

        let shadowRect = CGRect(x: center.x - 6, y: center.y - 11, width: 18, height: 18)
        context.fill(Path(ellipseIn: shadowRect), with: .color(palette.middle.opacity(0.95)))
    }

    private func drawSun(context: inout GraphicsContext, size: CGSize, palette: SkyPalette, phase: Double) {
        let center = CGPoint(x: size.width * 0.72, y: size.height * palette.sunY)
        let glowRadius = 28.0 * palette.glowIntensity
        let glowRect = CGRect(
            x: center.x - glowRadius,
            y: center.y - glowRadius,
            width: glowRadius * 2,
            height: glowRadius * 2
        )
        context.fill(
            Path(ellipseIn: glowRect),
            with: .radialGradient(
                Gradient(colors: [palette.sunColor.opacity(0.55), .clear]),
                center: center,
                startRadius: 0,
                endRadius: glowRadius
            )
        )

        let sunRect = CGRect(x: center.x - 12, y: center.y - 12, width: 24, height: 24)
        context.fill(Path(ellipseIn: sunRect), with: .color(palette.sunColor))

        if prayer == .gunes || prayer == .ikindi {
            let rayCount = 8
            for index in 0..<rayCount {
                let angle = (Double(index) / Double(rayCount)) * .pi * 2 + phase * 0.15
                let inner = 14.0
                let outer = 22.0
                var ray = Path()
                ray.move(to: CGPoint(
                    x: center.x + cos(angle) * inner,
                    y: center.y + sin(angle) * inner
                ))
                ray.addLine(to: CGPoint(
                    x: center.x + cos(angle) * outer,
                    y: center.y + sin(angle) * outer
                ))
                context.stroke(ray, with: .color(palette.sunColor.opacity(0.55)), lineWidth: 2)
            }
        }
    }

    private func drawClouds(context: inout GraphicsContext, size: CGSize) {
        drawCloud(context: &context, center: CGPoint(x: size.width * 0.25, y: size.height * 0.28), scale: 1.0)
    }

    private func drawCloud(context: inout GraphicsContext, center: CGPoint, scale: CGFloat) {
        let color = Color.white.opacity(0.85)
        let base = scale * 10
        let circles: [(CGFloat, CGFloat, CGFloat)] = [
            (-base * 1.2, 0, base),
            (0, -base * 0.3, base * 1.1),
            (base * 1.1, 0, base * 0.95),
            (base * 0.2, base * 0.2, base * 0.8)
        ]
        for (dx, dy, radius) in circles {
            let rect = CGRect(
                x: center.x + dx - radius,
                y: center.y + dy - radius,
                width: radius * 2,
                height: radius * 2
            )
            context.fill(Path(ellipseIn: rect), with: .color(color))
        }
    }

    private func drawSkyline(context: inout GraphicsContext, size: CGSize) {
        let skylineHeight = size.height * 0.22
        let rect = CGRect(x: 0, y: size.height - skylineHeight, width: size.width, height: skylineHeight)
        context.fill(Skyline().path(in: rect), with: .color(.black.opacity(0.28)))
    }
}

private extension Color {
    var srgbComponents: (r: Double, g: Double, b: Double) {
        guard let nsColor = NSColor(self).usingColorSpace(.sRGB) else {
            return (0, 0, 0)
        }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue))
    }
}
