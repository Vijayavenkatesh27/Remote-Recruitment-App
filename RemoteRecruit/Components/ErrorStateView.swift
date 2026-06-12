import SwiftUI

struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(RemoteRecruitTheme.orange)
            Text("Could not load jobs")
                .font(.title3.weight(.bold))
                .foregroundStyle(RemoteRecruitTheme.navy)
            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(action: retry) {
                Label("Retry", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .tint(RemoteRecruitTheme.cyan)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
        .glassCard(cornerRadius: 12, opacity: 0.12)
    }
}
