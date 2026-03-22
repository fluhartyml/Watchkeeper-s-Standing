//
//  SkeuomorphicSampler.swift
//  Watchkeeper's Standing
//
//  Standalone test view — not wired into the app.
//  To preview: change Watchkeeper_s_StandingApp to show SkeuomorphicSampler() instead of ContentView()
//  Or just use the #Preview at the bottom.
//

import SwiftUI

struct SkeuomorphicSampler: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Skeuomorphic Sampler")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                // MARK: - Parchment Paper
                parchmentSample

                // MARK: - Rope Divider
                ropeDividerSample

                // MARK: - Aged Log Entry
                agedLogEntrySample

                // MARK: - Stitched Border
                stitchedBorderSample

                // MARK: - Compass Rose
                compassRoseSample

                // MARK: - Full Panel Mockup
                fullPanelMockup

                // MARK: - Chain Link Header
                chainLinkHeaderSample

                // MARK: - Jute Twine Divider
                juteTwineSample

                // MARK: - Coffee Stained Map
                coffeeStainedMapSample

                // MARK: - Coffee Ring Stain
                coffeeRingStainSample

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
    }

    // MARK: - Parchment Paper Background

    private var parchmentSample: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Parchment Paper")

            ZStack {
                // Base parchment color
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.96, green: 0.94, blue: 0.89))

                // Subtle noise texture via canvas
                Canvas { context, size in
                    for _ in 0..<300 {
                        let x = CGFloat.random(in: 0...size.width)
                        let y = CGFloat.random(in: 0...size.height)
                        let opacity = Double.random(in: 0.02...0.08)
                        let dotSize = CGFloat.random(in: 1...3)
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: dotSize, height: dotSize)),
                            with: .color(Color.brown.opacity(opacity))
                        )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Aged edge vignette
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.brown.opacity(0.3),
                                Color.brown.opacity(0.1),
                                Color.brown.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )

                Text("The watchkeeper's standing record.\nEvery hour accounted for.")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color(red: 0.25, green: 0.2, blue: 0.15))
                    .padding(20)
            }
            .frame(height: 120)
        }
    }

    // MARK: - Rope Divider

    private var ropeDividerSample: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Rope Divider")

            RopeDivider()
                .frame(height: 12)
                .padding(.horizontal, 20)

            RopeDivider(color: Color(red: 0.6, green: 0.5, blue: 0.35))
                .frame(height: 16)
                .padding(.horizontal, 20)
        }
    }

    // MARK: - Aged Log Entry Line

    private var agedLogEntrySample: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Aged Log Entry")

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.96, green: 0.94, blue: 0.89))

                VStack(spacing: 0) {
                    ForEach(8..<16, id: \.self) { hour in
                        HStack(spacing: 8) {
                            Text(String(format: "%02d", hour))
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(Color(red: 0.5, green: 0.45, blue: 0.38))
                                .frame(width: 24, alignment: .trailing)

                            Rectangle()
                                .fill(Color.brown.opacity(0.15))
                                .frame(width: 1)

                            if hour == 10 {
                                Text("Morning watch — clear skies, steady heading")
                                    .font(.system(.caption, design: .serif))
                                    .foregroundStyle(Color(red: 0.25, green: 0.2, blue: 0.15))
                                    .lineLimit(1)
                            } else if hour == 14 {
                                Text("Afternoon — changed course bearing 270")
                                    .font(.system(.caption, design: .serif))
                                    .foregroundStyle(Color(red: 0.25, green: 0.2, blue: 0.15))
                                    .lineLimit(1)
                            }

                            Spacer()
                        }
                        .frame(height: 28)

                        if hour < 15 {
                            Rectangle()
                                .fill(Color.brown.opacity(0.08))
                                .frame(height: 1)
                        }
                    }
                }
                .padding(12)
            }
            .frame(height: 240)
        }
    }

    // MARK: - Stitched Border

    private var stitchedBorderSample: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Stitched Border")

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.35, green: 0.25, blue: 0.18))

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.96, green: 0.94, blue: 0.89))
                    .padding(6)

                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.35))
                    .padding(8)

                Text("Leather bound, hand stitched")
                    .font(.system(.body, design: .serif))
                    .italic()
                    .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.18))
            }
            .frame(height: 80)
        }
    }

    // MARK: - Compass Rose

    private var compassRoseSample: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Compass Rose (Map Overlay)")

            ZStack {
                Circle()
                    .fill(Color(red: 0.96, green: 0.94, blue: 0.89).opacity(0.9))
                    .frame(width: 120, height: 120)

                // Outer ring
                Circle()
                    .strokeBorder(Color.brown.opacity(0.4), lineWidth: 2)
                    .frame(width: 110, height: 110)

                // Cardinal directions
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let radius: CGFloat = 45

                    // Draw cardinal lines
                    let directions: [(CGFloat, String)] = [
                        (0, "N"), (.pi / 2, "E"), (.pi, "S"), (.pi * 1.5, "W")
                    ]

                    for (angle, _) in directions {
                        var path = Path()
                        let adjusted = angle - .pi / 2
                        path.move(to: center)
                        path.addLine(to: CGPoint(
                            x: center.x + cos(adjusted) * radius,
                            y: center.y + sin(adjusted) * radius
                        ))
                        context.stroke(path, with: .color(Color.brown.opacity(0.5)), lineWidth: 1.5)
                    }

                    // Draw intercardinal lines
                    let interCardinals: [CGFloat] = [.pi / 4, .pi * 3 / 4, .pi * 5 / 4, .pi * 7 / 4]
                    for angle in interCardinals {
                        var path = Path()
                        let adjusted = angle - .pi / 2
                        path.move(to: center)
                        path.addLine(to: CGPoint(
                            x: center.x + cos(adjusted) * (radius * 0.6),
                            y: center.y + sin(adjusted) * (radius * 0.6)
                        ))
                        context.stroke(path, with: .color(Color.brown.opacity(0.3)), lineWidth: 1)
                    }
                }
                .frame(width: 120, height: 120)

                // N marker
                VStack {
                    Text("N")
                        .font(.system(size: 12, weight: .bold, design: .serif))
                        .foregroundStyle(Color(red: 0.7, green: 0.15, blue: 0.1))
                    Spacer()
                }
                .frame(height: 100)

                // S marker
                VStack {
                    Spacer()
                    Text("S")
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundStyle(Color.brown.opacity(0.6))
                }
                .frame(height: 100)

                // E marker
                HStack {
                    Spacer()
                    Text("E")
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundStyle(Color.brown.opacity(0.6))
                }
                .frame(width: 100)

                // W marker
                HStack {
                    Text("W")
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundStyle(Color.brown.opacity(0.6))
                    Spacer()
                }
                .frame(width: 100)

                // Center dot
                Circle()
                    .fill(Color.brown.opacity(0.5))
                    .frame(width: 6, height: 6)
            }
            .frame(height: 140)
        }
    }

    // MARK: - Full Panel Mockup

    private var fullPanelMockup: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Full Panel Mockup — Log")

            ZStack {
                // Leather outer
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.35, green: 0.25, blue: 0.18))

                // Parchment inner
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.96, green: 0.94, blue: 0.89))
                    .padding(5)

                // Stitch line
                RoundedRectangle(cornerRadius: 9)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                    .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.35).opacity(0.6))
                    .padding(7)

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Image(systemName: "text.justify.left")
                            .foregroundStyle(Color(red: 0.5, green: 0.45, blue: 0.38))
                        Text("LOG")
                            .font(.system(.caption, design: .serif))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(red: 0.5, green: 0.45, blue: 0.38))
                            .tracking(2)

                        Text("24H")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color(red: 0.5, green: 0.45, blue: 0.38))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(
                                Capsule()
                                    .fill(Color.brown.opacity(0.1))
                            )

                        Spacer()

                        Text("14:22")
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(red: 0.7, green: 0.15, blue: 0.1))

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)

                    RopeDivider(color: Color(red: 0.6, green: 0.5, blue: 0.35).opacity(0.4))
                        .frame(height: 8)
                        .padding(.horizontal, 12)

                    // Log lines
                    VStack(spacing: 0) {
                        ForEach(12..<18, id: \.self) { hour in
                            HStack(spacing: 8) {
                                Text(String(format: "%02d", hour))
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(
                                        hour == 14
                                            ? Color(red: 0.7, green: 0.15, blue: 0.1)
                                            : Color(red: 0.5, green: 0.45, blue: 0.38)
                                    )
                                    .fontWeight(hour == 14 ? .bold : .regular)
                                    .frame(width: 24, alignment: .trailing)

                                Rectangle()
                                    .fill(Color.brown.opacity(0.12))
                                    .frame(width: 1)

                                if hour == 13 {
                                    Text("Lunch with the crew")
                                        .font(.system(.caption, design: .serif))
                                        .foregroundStyle(Color(red: 0.25, green: 0.2, blue: 0.15))
                                }

                                Spacer()
                            }
                            .frame(height: 30)
                            .overlay(alignment: .bottom) {
                                if hour == 14 {
                                    Rectangle()
                                        .fill(Color(red: 0.7, green: 0.15, blue: 0.1))
                                        .frame(height: 1.5)
                                        .offset(y: -8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                    Spacer()
                }
                .padding(5)
            }
            .frame(height: 280)
        }
    }

    // MARK: - Chain Link Header

    private var chainLinkHeaderSample: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Chain Link Header")

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.17))

                VStack(spacing: 0) {
                    // Chain link header bar
                    ZStack {
                        // Chain background
                        ChainLinkBar()
                            .frame(height: 32)

                        HStack {
                            Image(systemName: "map")
                                .foregroundStyle(Color(red: 0.85, green: 0.8, blue: 0.7))
                            Text("MAP")
                                .font(.system(.caption, design: .serif))
                                .fontWeight(.bold)
                                .foregroundStyle(Color(red: 0.85, green: 0.8, blue: 0.7))
                                .tracking(3)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    }

                    Spacer()

                    // Second example
                    ZStack {
                        ChainLinkBar()
                            .frame(height: 32)

                        HStack {
                            Image(systemName: "text.justify.left")
                                .foregroundStyle(Color(red: 0.85, green: 0.8, blue: 0.7))
                            Text("LOG")
                                .font(.system(.caption, design: .serif))
                                .fontWeight(.bold)
                                .foregroundStyle(Color(red: 0.85, green: 0.8, blue: 0.7))
                                .tracking(3)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    }

                    Spacer()

                    // Third example
                    ZStack {
                        ChainLinkBar()
                            .frame(height: 32)

                        HStack {
                            Image(systemName: "calendar")
                                .foregroundStyle(Color(red: 0.85, green: 0.8, blue: 0.7))
                            Text("CALENDAR")
                                .font(.system(.caption, design: .serif))
                                .fontWeight(.bold)
                                .foregroundStyle(Color(red: 0.85, green: 0.8, blue: 0.7))
                                .tracking(3)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    }

                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .frame(height: 180)
        }
    }

    // MARK: - Jute Twine Divider

    private var juteTwineSample: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Jute Twine (vs Rope)")

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.96, green: 0.94, blue: 0.89))

                VStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("Heavy Rope (panel dividers)")
                            .font(.system(.caption2, design: .serif))
                            .foregroundStyle(Color.brown.opacity(0.6))
                        RopeDivider(color: Color(red: 0.55, green: 0.45, blue: 0.3))
                            .frame(height: 12)
                            .padding(.horizontal, 20)
                    }

                    VStack(spacing: 4) {
                        Text("Jute Twine (between entries)")
                            .font(.system(.caption2, design: .serif))
                            .foregroundStyle(Color.brown.opacity(0.6))
                        JuteTwine()
                            .frame(height: 4)
                            .padding(.horizontal, 20)
                    }

                    VStack(spacing: 4) {
                        Text("Fine Jute (subtle separator)")
                            .font(.system(.caption2, design: .serif))
                            .foregroundStyle(Color.brown.opacity(0.6))
                        JuteTwine(thickness: 0.8, color: Color(red: 0.65, green: 0.55, blue: 0.4).opacity(0.5))
                            .frame(height: 3)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(16)
            }
            .frame(height: 180)
        }
    }

    // MARK: - Coffee Stained Map

    private var coffeeStainedMapSample: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Coffee Stained Navigator's Chart")

            ZStack {
                // Base aged paper — warmer, more yellowed
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.92, green: 0.88, blue: 0.78))

                // Water/coffee damage blotches
                Canvas { context, size in
                    // Large coffee stains
                    let stains: [(CGFloat, CGFloat, CGFloat, Double)] = [
                        (size.width * 0.3, size.height * 0.4, 60, 0.08),
                        (size.width * 0.7, size.height * 0.6, 45, 0.06),
                        (size.width * 0.15, size.height * 0.7, 35, 0.07),
                        (size.width * 0.8, size.height * 0.25, 50, 0.05),
                        (size.width * 0.5, size.height * 0.2, 40, 0.09),
                    ]

                    for (x, y, radius, opacity) in stains {
                        // Outer ring (coffee ring effect)
                        let ringPath = Path(ellipseIn: CGRect(
                            x: x - radius, y: y - radius,
                            width: radius * 2, height: radius * 2
                        ))
                        context.stroke(
                            ringPath,
                            with: .color(Color(red: 0.45, green: 0.3, blue: 0.15).opacity(opacity * 1.5)),
                            lineWidth: 3
                        )

                        // Inner fill (lighter)
                        let fillPath = Path(ellipseIn: CGRect(
                            x: x - radius + 3, y: y - radius + 3,
                            width: (radius - 3) * 2, height: (radius - 3) * 2
                        ))
                        context.fill(
                            fillPath,
                            with: .color(Color(red: 0.55, green: 0.4, blue: 0.2).opacity(opacity * 0.5))
                        )
                    }

                    // Small spatter dots
                    for _ in 0..<80 {
                        let x = CGFloat.random(in: 0...size.width)
                        let y = CGFloat.random(in: 0...size.height)
                        let dotSize = CGFloat.random(in: 1...4)
                        let opacity = Double.random(in: 0.03...0.1)
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: dotSize, height: dotSize)),
                            with: .color(Color(red: 0.5, green: 0.35, blue: 0.2).opacity(opacity))
                        )
                    }

                    // Aged foxing spots
                    for _ in 0..<20 {
                        let x = CGFloat.random(in: 0...size.width)
                        let y = CGFloat.random(in: 0...size.height)
                        let dotSize = CGFloat.random(in: 3...8)
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: dotSize, height: dotSize)),
                            with: .color(Color(red: 0.6, green: 0.45, blue: 0.25).opacity(0.06))
                        )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Edge darkening
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.brown.opacity(0.4),
                                Color.brown.opacity(0.15),
                                Color.brown.opacity(0.35),
                                Color.brown.opacity(0.2),
                                Color.brown.opacity(0.4),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 5
                    )

                // Placeholder text
                VStack {
                    Text("NAVIGATOR'S CHART")
                        .font(.system(.caption, design: .serif))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(red: 0.4, green: 0.3, blue: 0.2))
                        .tracking(3)
                        .padding(.top, 12)

                    Spacer()

                    Text("— MapKit renders here —")
                        .font(.system(.caption2, design: .serif))
                        .italic()
                        .foregroundStyle(Color(red: 0.5, green: 0.4, blue: 0.3).opacity(0.6))

                    Spacer()
                }
            }
            .frame(height: 200)
        }
    }

    // MARK: - Coffee Ring Stain

    private var coffeeRingStainSample: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Coffee Ring Stain (detail)")

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.96, green: 0.94, blue: 0.89))

                Canvas { context, size in
                    let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                    let radius: CGFloat = 40

                    // Multiple overlapping rings for realism
                    for i in 0..<5 {
                        let offsetX = CGFloat.random(in: -3...3)
                        let offsetY = CGFloat.random(in: -3...3)
                        let ringCenter = CGPoint(x: center.x + offsetX, y: center.y + offsetY)
                        let r = radius + CGFloat(i) * 1.5
                        let opacity = 0.12 - Double(i) * 0.02

                        let path = Path(ellipseIn: CGRect(
                            x: ringCenter.x - r, y: ringCenter.y - r,
                            width: r * 2, height: r * 2
                        ))
                        context.stroke(
                            path,
                            with: .color(Color(red: 0.45, green: 0.3, blue: 0.15).opacity(opacity)),
                            lineWidth: 2.5 - CGFloat(i) * 0.3
                        )
                    }

                    // Inner pool (very faint)
                    let poolPath = Path(ellipseIn: CGRect(
                        x: center.x - radius + 8, y: center.y - radius + 8,
                        width: (radius - 8) * 2, height: (radius - 8) * 2
                    ))
                    context.fill(
                        poolPath,
                        with: .color(Color(red: 0.55, green: 0.4, blue: 0.2).opacity(0.03))
                    )

                    // Drip trail
                    var dripPath = Path()
                    dripPath.move(to: CGPoint(x: center.x + radius - 5, y: center.y + 10))
                    dripPath.addQuadCurve(
                        to: CGPoint(x: center.x + radius + 20, y: center.y + 40),
                        control: CGPoint(x: center.x + radius + 5, y: center.y + 25)
                    )
                    context.stroke(
                        dripPath,
                        with: .color(Color(red: 0.45, green: 0.3, blue: 0.15).opacity(0.08)),
                        lineWidth: 3
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Text("Someone set their mug down on the logbook.")
                    .font(.system(.caption2, design: .serif))
                    .italic()
                    .foregroundStyle(Color.brown.opacity(0.4))
                    .offset(y: 55)
            }
            .frame(height: 160)
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .tracking(1)
    }
}

// MARK: - Rope Divider Shape

struct RopeDivider: View {
    var color: Color = Color(red: 0.55, green: 0.45, blue: 0.3)

    var body: some View {
        Canvas { context, size in
            let y = size.height / 2
            let amplitude: CGFloat = size.height * 0.3
            let wavelength: CGFloat = 12

            // First strand
            var path1 = Path()
            path1.move(to: CGPoint(x: 0, y: y))
            var x: CGFloat = 0
            while x <= size.width {
                let nextX = x + wavelength / 2
                let controlY = y + (Int(x / (wavelength / 2)) % 2 == 0 ? amplitude : -amplitude)
                path1.addQuadCurve(
                    to: CGPoint(x: nextX, y: y),
                    control: CGPoint(x: x + wavelength / 4, y: controlY)
                )
                x = nextX
            }
            context.stroke(path1, with: .color(color), lineWidth: 2)

            // Second strand (offset)
            var path2 = Path()
            path2.move(to: CGPoint(x: 0, y: y))
            x = 0
            while x <= size.width {
                let nextX = x + wavelength / 2
                let controlY = y + (Int(x / (wavelength / 2)) % 2 == 0 ? -amplitude : amplitude)
                path2.addQuadCurve(
                    to: CGPoint(x: nextX, y: y),
                    control: CGPoint(x: x + wavelength / 4, y: controlY)
                )
                x = nextX
            }
            context.stroke(path2, with: .color(color.opacity(0.7)), lineWidth: 1.5)
        }
    }
}

// MARK: - Chain Link Bar

struct ChainLinkBar: View {
    var linkColor: Color = Color(red: 0.55, green: 0.5, blue: 0.45)

    var body: some View {
        Canvas { context, size in
            let linkWidth: CGFloat = 18
            let linkHeight: CGFloat = 10
            let spacing: CGFloat = 4
            let y = size.height / 2
            var x: CGFloat = 4

            var isHorizontal = true
            while x < size.width - linkWidth {
                let rect: CGRect
                if isHorizontal {
                    rect = CGRect(
                        x: x,
                        y: y - linkHeight / 2,
                        width: linkWidth,
                        height: linkHeight
                    )
                } else {
                    rect = CGRect(
                        x: x + (linkWidth - linkHeight) / 2,
                        y: y - linkWidth / 2 + 2,
                        width: linkHeight,
                        height: linkWidth - 4
                    )
                }

                let path = Path(roundedRect: rect, cornerRadius: linkHeight / 2)

                // Link shadow
                context.stroke(
                    path,
                    with: .color(Color.black.opacity(0.3)),
                    lineWidth: 3.5
                )

                // Link body
                context.stroke(
                    path,
                    with: .color(linkColor),
                    lineWidth: 2.5
                )

                // Highlight
                context.stroke(
                    path,
                    with: .color(Color.white.opacity(0.15)),
                    lineWidth: 1
                )

                x += isHorizontal ? linkWidth - spacing : linkHeight + spacing
                isHorizontal.toggle()
            }
        }
    }
}

// MARK: - Jute Twine

struct JuteTwine: View {
    var thickness: CGFloat = 1.2
    var color: Color = Color(red: 0.6, green: 0.5, blue: 0.35)

    var body: some View {
        Canvas { context, size in
            let y = size.height / 2
            let amplitude: CGFloat = size.height * 0.2
            let wavelength: CGFloat = 6

            // Single thin strand with slight wobble
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            var x: CGFloat = 0
            while x <= size.width {
                let nextX = x + wavelength / 2
                let controlY = y + (Int(x / (wavelength / 2)) % 2 == 0 ? amplitude : -amplitude)
                path.addQuadCurve(
                    to: CGPoint(x: nextX, y: y),
                    control: CGPoint(x: x + wavelength / 4, y: controlY)
                )
                x = nextX
            }
            context.stroke(path, with: .color(color), lineWidth: thickness)

            // Faint second fiber
            var path2 = Path()
            path2.move(to: CGPoint(x: 0, y: y + 0.5))
            x = 0
            while x <= size.width {
                let nextX = x + wavelength / 2
                let controlY = y + (Int(x / (wavelength / 2)) % 2 == 0 ? -amplitude * 0.7 : amplitude * 0.7)
                path2.addQuadCurve(
                    to: CGPoint(x: nextX, y: y + 0.5),
                    control: CGPoint(x: x + wavelength / 4, y: controlY + 0.5)
                )
                x = nextX
            }
            context.stroke(path2, with: .color(color.opacity(0.4)), lineWidth: thickness * 0.6)
        }
    }
}

#Preview {
    SkeuomorphicSampler()
        .frame(width: 400, height: 1600)
}
