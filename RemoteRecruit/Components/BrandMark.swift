import SwiftUI

struct BrandMark: View {
    var size: CGFloat = 44
    var showsBadge = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.02, green: 0.05, blue: 0.18),
                                Color(red: 0.04, green: 0.09, blue: 0.28),
                                Color(red: 0.12, green: 0.10, blue: 0.36)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(alignment: .topLeading) {
                        Circle()
                            .fill(.cyan.opacity(0.18))
                            .frame(width: size * 0.82, height: size * 0.82)
                            .offset(x: -size * 0.35, y: -size * 0.38)
                    }

                Text("R")
                    .font(.system(size: size * 0.76, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.82, blue: 1.0),
                                Color(red: 0.31, green: 0.42, blue: 1.0),
                                Color(red: 0.73, green: 0.20, blue: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.35), radius: size * 0.08, x: 0, y: size * 0.04)
                    .offset(x: -size * 0.02, y: size * 0.04)

                BriefcaseGlyph()
                    .stroke(.white, style: StrokeStyle(lineWidth: max(1.7, size * 0.045), lineCap: .round, lineJoin: .round))
                    .frame(width: size * 0.28, height: size * 0.22)
                    .background(
                        RoundedRectangle(cornerRadius: size * 0.06, style: .continuous)
                            .fill(Color(red: 0.02, green: 0.05, blue: 0.18).opacity(0.72))
                            .frame(width: size * 0.38, height: size * 0.32)
                    )
                    .offset(x: size * 0.03, y: -size * 0.05)
            }
            .frame(width: size, height: size)
            .shadow(color: .indigo.opacity(0.26), radius: size * 0.18, x: 0, y: size * 0.1)

            if showsBadge {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.0, green: 0.82, blue: 1.0), Color(red: 0.72, green: 0.19, blue: 1.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size * 0.26, height: size * 0.26)
                    .overlay {
                        Image(systemName: "sparkle")
                            .font(.system(size: size * 0.12, weight: .black))
                            .foregroundStyle(.white)
                    }
                    .overlay {
                        Circle().stroke(RemoteRecruitTheme.navy, lineWidth: max(2, size * 0.035))
                    }
                    .offset(x: size * 0.03, y: size * 0.03)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct BriefcaseGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let body = CGRect(
            x: rect.minX + rect.width * 0.08,
            y: rect.minY + rect.height * 0.28,
            width: rect.width * 0.84,
            height: rect.height * 0.58
        )
        path.addRoundedRect(in: body, cornerSize: CGSize(width: rect.width * 0.1, height: rect.width * 0.1))
        path.move(to: CGPoint(x: rect.midX - rect.width * 0.18, y: rect.minY + rect.height * 0.3))
        path.addLine(to: CGPoint(x: rect.midX - rect.width * 0.18, y: rect.minY + rect.height * 0.16))
        path.addLine(to: CGPoint(x: rect.midX + rect.width * 0.18, y: rect.minY + rect.height * 0.16))
        path.addLine(to: CGPoint(x: rect.midX + rect.width * 0.18, y: rect.minY + rect.height * 0.3))
        path.move(to: CGPoint(x: body.minX, y: body.midY))
        path.addLine(to: CGPoint(x: body.maxX, y: body.midY))
        path.move(to: CGPoint(x: rect.midX, y: body.midY - rect.height * 0.05))
        path.addLine(to: CGPoint(x: rect.midX, y: body.midY + rect.height * 0.05))
        return path
    }
}
