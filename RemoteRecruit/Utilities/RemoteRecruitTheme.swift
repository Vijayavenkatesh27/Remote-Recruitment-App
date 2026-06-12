import SwiftUI
import UIKit

enum RemoteRecruitTheme {
    static let navy = Color(
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.94, green: 0.96, blue: 1.0, alpha: 1)
                : UIColor(red: 0.05, green: 0.08, blue: 0.18, alpha: 1)
        }
    )
    static let midnight = Color(red: 0.10, green: 0.14, blue: 0.27)
    static let surface = Color(.secondarySystemBackground)
    static let elevatedSurface = Color(.systemBackground)
    static let backgroundTop = Color(
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.04, green: 0.06, blue: 0.11, alpha: 1)
                : UIColor(red: 0.96, green: 0.99, blue: 1.0, alpha: 1)
        }
    )
    static let backgroundBottom = Color(
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.02, green: 0.03, blue: 0.08, alpha: 1)
                : UIColor(red: 0.94, green: 0.95, blue: 0.99, alpha: 1)
        }
    )
    static let cyan = Color(red: 0.0, green: 0.69, blue: 0.82)
    static let blue = Color(red: 0.17, green: 0.43, blue: 0.95)
    static let purple = Color(red: 0.45, green: 0.24, blue: 0.94)
    static let green = Color(red: 0.12, green: 0.62, blue: 0.32)
    static let orange = Color(red: 0.92, green: 0.43, blue: 0.08)

    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [cyan, blue, purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var textGradient: LinearGradient {
        LinearGradient(
            colors: [navy, blue],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct RemoteRecruitScreenBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    RemoteRecruitTheme.backgroundTop,
                    Color(.systemBackground),
                    RemoteRecruitTheme.backgroundBottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                ThemeMapDots()
                    .opacity(0.08)
                    .frame(height: 230)
                    .offset(y: -20)
                Spacer()
            }

            VStack {
                Circle()
                    .fill(RemoteRecruitTheme.cyan.opacity(0.10))
                    .frame(width: 210, height: 210)
                    .blur(radius: 22)
                    .offset(x: -120, y: -80)
                Spacer()
            }

            VStack {
                Spacer()
                RadialGradient(
                    colors: [
                        RemoteRecruitTheme.blue.opacity(0.08),
                        .clear
                    ],
                    center: .bottom,
                    startRadius: 40,
                    endRadius: 320
                )
                .frame(height: 360)
            }
        }
        .ignoresSafeArea()
    }
}

private struct ThemeMapDots: View {
    var body: some View {
        Canvas { context, size in
            let color = RemoteRecruitTheme.cyan.opacity(0.64)
            for row in 0..<28 {
                for col in 0..<54 {
                    let x = CGFloat(col) * size.width / 54
                    let y = CGFloat(row) * size.height / 28
                    let wave = sin(CGFloat(col) * 0.32) + cos(CGFloat(row) * 0.44)
                    guard wave > -0.2 else { continue }
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: 2.2, height: 2.2)),
                        with: .color(color)
                    )
                }
            }
        }
    }
}

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 12
    var opacity: Double = 0.12

    func body(content: Content) -> some View {
        content
            .background(RemoteRecruitTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(.separator).opacity(0.08),
                                RemoteRecruitTheme.cyan.opacity(0.16),
                                Color(.separator).opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: RemoteRecruitTheme.blue.opacity(0.07), radius: 18, x: 0, y: 10)
            .shadow(color: .black.opacity(0.045), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 12, opacity: Double = 0.12) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, opacity: opacity))
    }

    func remoteRecruitNavigationStyle() -> some View {
        self
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(RemoteRecruitTheme.blue)
    }
}
