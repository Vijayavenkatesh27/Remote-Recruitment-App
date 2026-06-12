import SwiftUI

struct ProfileSettingsView: View {
    @Environment(\.appContainer) private var container
    @EnvironmentObject private var settings: SettingsViewModel
    @State private var didClearHistory = false
    @State private var savedCount = 0
    @State private var recentSearchCount = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    candidateHeader
                    activityStrip
                    readinessPanel
                    preferencesPanel
                    appearancePanel
                    privacyPanel
                    appInfoPanel
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .background(AppBackground())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .remoteRecruitNavigationStyle()
            .alert("Search history cleared", isPresented: $didClearHistory) {
                Button("OK", role: .cancel) {}
            }
            .onAppear(perform: refreshCounts)
            .onReceive(container.savedJobsStore.savedJobsPublisher) { jobs in
                savedCount = jobs.count
            }
        }
    }

    private var candidateHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: "person.text.rectangle.fill")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 66, height: 66)
                        .background(
                            LinearGradient(
                                colors: [RemoteRecruitTheme.cyan, RemoteRecruitTheme.blue, RemoteRecruitTheme.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                        )

                    Image(systemName: settings.isOpenToWork ? "checkmark.circle.fill" : "minus.circle.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(settings.isOpenToWork ? RemoteRecruitTheme.green : .secondary)
                        .background(Color(.systemBackground), in: Circle())
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 8) {
                        Text(settings.candidateName)
                            .font(.headline.weight(.black))
                            .foregroundStyle(RemoteRecruitTheme.navy)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                        Spacer(minLength: 8)
                        StatusBadge(text: settings.isOpenToWork ? "Open to work" : "Private", color: settings.isOpenToWork ? .green : .secondary)
                    }

                    Text(settings.preferredRole)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Label(settings.preferredLocation, systemImage: "mappin.and.ellipse")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Label(settings.workAuthorization, systemImage: "checkmark.shield.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Profile strength")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(settings.profileCompletion * 100))% complete")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(RemoteRecruitTheme.cyan)
                }
                ProgressView(value: settings.profileCompletion)
                    .tint(RemoteRecruitTheme.cyan)
            }
        }
        .padding(16)
        .profileCard()
    }

    private var activityStrip: some View {
        HStack(spacing: 10) {
            ProfileMetric(value: "\(savedCount)", title: "Saved jobs", icon: "bookmark.fill", color: RemoteRecruitTheme.cyan)
            ProfileMetric(value: settings.preferredEmploymentType, title: "Job type", icon: "briefcase.fill", color: RemoteRecruitTheme.purple)
            ProfileMetric(value: settings.preferredTimeZone, title: "Availability", icon: "clock.fill", color: RemoteRecruitTheme.orange)
        }
    }

    private var readinessPanel: some View {
        ProfilePanel(title: "Application readiness", icon: "doc.badge.checkmark") {
            ProfileActionRow(
                icon: "doc.text.fill",
                title: "Resume",
                subtitle: "Ready for US technology recruiters.",
                value: settings.resumeStatus,
                tint: RemoteRecruitTheme.cyan
            )
            Divider()
            ProfileActionRow(
                icon: "briefcase.fill",
                title: "Target role",
                subtitle: settings.preferredRole,
                value: settings.preferredEmploymentType,
                tint: RemoteRecruitTheme.purple
            )
            Divider()
            ProfileActionRow(
                icon: "checkmark.shield.fill",
                title: "Work authorization",
                subtitle: "Helps recruiters understand US eligibility.",
                value: settings.workAuthorization,
                tint: RemoteRecruitTheme.blue
            )
            Divider()
            ProfileActionRow(
                icon: "dollarsign.circle.fill",
                title: "Compensation target",
                subtitle: "Private preference shown in USD.",
                value: settings.expectedSalary,
                tint: RemoteRecruitTheme.green
            )
        }
    }

    private var preferencesPanel: some View {
        ProfilePanel(title: "Job preferences", icon: "slider.horizontal.3") {
            PreferenceTextRow(title: "Role focus", icon: "target", value: settings.preferredRole)
            Divider()
            PreferenceMenuRow(
                title: "Work mode",
                icon: "building.2.fill",
                selection: $settings.preferredWorkMode,
                values: WorkMode.allCases.map(\.rawValue)
            )
            Divider()
            PreferenceMenuRow(
                title: "Job type",
                icon: "briefcase.fill",
                selection: $settings.preferredEmploymentType,
                values: EmploymentType.allCases.map(\.rawValue)
            )
            Divider()
            PreferenceTextRow(title: "Location", icon: "location.fill", value: settings.preferredLocation)
            Divider()
            PreferenceMenuRow(
                title: "Time zone",
                icon: "clock.badge.checkmark",
                selection: $settings.preferredTimeZone,
                values: TimeZonePreference.allCases.map(\.rawValue)
            )
            Divider()
            PreferenceMenuRow(
                title: "Availability",
                icon: "calendar.badge.clock",
                selection: $settings.availability,
                values: Availability.allCases.map(\.rawValue)
            )
            Divider()
            PreferenceMenuRow(
                title: "Authorization",
                icon: "checkmark.shield.fill",
                selection: $settings.workAuthorization,
                values: WorkAuthorization.allCases.map(\.rawValue)
            )
            Divider()
            Toggle(isOn: $settings.isOpenToWork) {
                Label("Open to work", systemImage: "person.crop.circle.badge.checkmark")
                    .font(.subheadline.weight(.semibold))
            }
            .tint(RemoteRecruitTheme.cyan)
        }
    }

    private var appearancePanel: some View {
        ProfilePanel(title: "Appearance", icon: "circle.lefthalf.filled") {
            Picker("Appearance", selection: $settings.selectedTheme) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.rawValue).tag(theme)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var privacyPanel: some View {
        ProfilePanel(title: "Privacy and data", icon: "lock.shield.fill") {
            Toggle(isOn: $settings.profileVisibleToRecruiters) {
                Label("Visible to recruiters", systemImage: "eye.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .tint(RemoteRecruitTheme.cyan)

            Divider()

            Toggle(isOn: $settings.jobAlertsEnabled) {
                Label("Job alerts", systemImage: "bell.badge.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .tint(RemoteRecruitTheme.cyan)

            Divider()

            Button {
                container.searchHistoryStore.clear()
                refreshCounts()
                didClearHistory = true
                Haptics.success()
            } label: {
                Label("Clear search history", systemImage: "clock.badge.xmark")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .accessibilityHint("Deletes recent searches stored on this device.")
        }
    }

    private var appInfoPanel: some View {
        ProfilePanel(title: "About RemoteRecruit", icon: "info.circle.fill") {
            ProfileInfoRow(title: "Version", value: appVersion)
            Divider()
            ProfileInfoRow(title: "Market", value: "US remote technology roles")
            Divider()
            ProfileInfoRow(title: "Job data", value: "Public API + offline fallback")
            Divider()
            ProfileInfoRow(title: "Saved jobs", value: "Stored on this device")
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func refreshCounts() {
        savedCount = (try? container.savedJobsStore.fetchSavedJobs().count) ?? 0
        recentSearchCount = container.searchHistoryStore.recentSearches().count
    }
}

private struct ProfileMetric: View {
    let value: String
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
        .profileCard()
    }
}

private struct ProfilePanel<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(RemoteRecruitTheme.navy)
            content
        }
        .padding(16)
        .profileCard()
    }
}

private struct ProfileActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)
            StatusBadge(text: value, color: tint)
                .frame(maxWidth: 150, alignment: .trailing)
        }
    }
}

private struct PreferenceMenuRow: View {
    let title: String
    let icon: String
    @Binding var selection: String
    let values: [String]

    var body: some View {
        HStack(spacing: 12) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            Spacer()
            Menu {
                ForEach(values, id: \.self) { value in
                    Button(value) {
                        selection = value
                        Haptics.selection()
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selection)
                        .font(.subheadline.weight(.bold))
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(RemoteRecruitTheme.cyan)
            }
        }
    }
}

private struct PreferenceTextRow: View {
    let title: String
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
    }
}

private struct ProfileInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer(minLength: 12)
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

private struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.bold))
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(color.opacity(0.14), in: Capsule())
            .overlay {
                Capsule().stroke(color.opacity(0.18))
            }
    }
}

private extension View {
    func profileCard() -> some View {
        self
            .glassCard(cornerRadius: 12, opacity: 0.12)
    }
}
