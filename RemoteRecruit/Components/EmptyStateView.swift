import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(RemoteRecruitTheme.brandGradient)
                .symbolEffect(.pulse)
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(RemoteRecruitTheme.navy)
            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .tint(RemoteRecruitTheme.cyan)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding(20)
        .glassCard(cornerRadius: 12, opacity: 0.12)
    }
}
