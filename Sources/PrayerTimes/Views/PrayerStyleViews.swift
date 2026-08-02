import SwiftUI

struct PrayerListRow: View {
    let prayer: Prayer
    let time: String
    let isActive: Bool
    let remaining: TimeInterval?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: prayer.systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isActive ? Color.accentColor : Color.secondary)
                .frame(width: 18)

            Text(prayer.localizedName)
                .font(.system(size: isActive ? 13 : 12, weight: isActive ? .semibold : .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isActive, let remaining {
                Text(remaining.countdownText)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.accentColor)
            }

            Text(time)
                .font(.system(size: isActive ? 13 : 12, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(isActive ? .primary : .secondary)
        }
        .padding(.horizontal, 8)
        .frame(minHeight: 32)
        .background {
            if isActive {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor.opacity(0.12))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isActive)
    }
}

struct PrayerSimpleTile: View {
    let prayer: Prayer
    let time: String
    let isActive: Bool
    let remaining: TimeInterval?

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: prayer.systemImage)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isActive ? Color.accentColor : Color.secondary)

            Text(prayer.localizedName)
                .font(.system(size: 9, weight: isActive ? .semibold : .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .foregroundStyle(isActive ? .primary : .secondary)

            Text(time)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(isActive ? .primary : .secondary)

            if isActive, let remaining {
                Text(remaining.countdownText)
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.accentColor)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .padding(.horizontal, 1)
        .background {
            if isActive {
                Color.accentColor.opacity(0.12)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isActive)
    }
}

struct PrayerTilesRow: View {
    let today: DayTimes
    let isPrayerActive: (Prayer) -> Bool
    let activeRemaining: (Prayer) -> TimeInterval?

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(Prayer.allCases.enumerated()), id: \.element.id) { index, prayer in
                if index > 0 {
                    Divider()
                }

                PrayerSimpleTile(
                    prayer: prayer,
                    time: today.times.time(for: prayer),
                    isActive: isPrayerActive(prayer),
                    remaining: activeRemaining(prayer)
                )
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct PrayerGridCell: View {
    let prayer: Prayer
    let time: String
    let isActive: Bool
    let remaining: TimeInterval?

    private var palette: SkyPalette {
        SkyPalette.palette(for: prayer)
    }

    var body: some View {
        ZStack {
            SkyScene(prayer: prayer, animate: isActive)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(spacing: 4) {
                Image(systemName: prayer.systemImage)
                    .font(.system(size: isActive ? 20 : 16, weight: .semibold))

                Text(prayer.localizedName)
                    .font(.system(size: isActive ? 12 : 11, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(time)
                    .font(.system(size: isActive ? 14 : 12, weight: .bold, design: .rounded))
                    .monospacedDigit()

                if isActive, let remaining {
                    Text(remaining.countdownText)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
            }
            .foregroundStyle(palette.textInk)
            .shadow(color: palette.textShadow, radius: 2, x: 0, y: 1)
            .padding(8)
        }
        .aspectRatio(1, contentMode: .fit)
        .opacity(isActive ? 1 : 0.45)
        .saturation(isActive ? 1 : 0.6)
        .overlay {
            if isActive {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(palette.textInk.opacity(0.65), lineWidth: 1.5)
                    .shadow(color: palette.textInk.opacity(0.35), radius: 6)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isActive)
    }
}
