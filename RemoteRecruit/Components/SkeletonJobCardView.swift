import SwiftUI

struct SkeletonJobCardView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                RoundedRectangle(cornerRadius: 8).frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 5).frame(height: 14)
                    RoundedRectangle(cornerRadius: 5).frame(width: 150, height: 12)
                }
            }
            RoundedRectangle(cornerRadius: 5).frame(height: 12)
            RoundedRectangle(cornerRadius: 5).frame(width: 210, height: 12)
        }
        .foregroundStyle(Color.secondary.opacity(isAnimating ? 0.18 : 0.08))
        .padding(16)
        .glassCard(cornerRadius: 12, opacity: 0.10)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
