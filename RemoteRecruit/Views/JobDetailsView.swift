import SwiftUI

struct JobDetailsView: View {
    let job: Job
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var tabBarVisibility: TabBarVisibilityController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(job.title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(RemoteRecruitTheme.navy)
                    Text(job.company)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    HStack {
                        Badge(text: job.location, icon: "mappin.and.ellipse")
                        Badge(text: job.employmentType, icon: "clock")
                    }
                }
                .padding()
                .glassCard(cornerRadius: 12, opacity: 0.12)

                salaryPanel(job.salary ?? SalaryInsight.estimate(for: job.title, tags: job.tags))

                section("Description", text: job.description)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Skills and Requirements")
                        .font(.headline)
                        .foregroundStyle(RemoteRecruitTheme.navy)
                    FlowLayout(items: job.skills)
                }
                .padding()
                .glassCard(cornerRadius: 12, opacity: 0.10)

                if let url = job.url {
                    Button {
                        openURL(url)
                    } label: {
                        Label("Apply on original site", systemImage: "arrow.up.right.square")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(RemoteRecruitTheme.cyan)
                    .controlSize(.large)
                }
            }
            .padding()
        }
        .background(AppBackground())
        .navigationTitle("Job Details")
        .navigationBarTitleDisplayMode(.inline)
        .remoteRecruitNavigationStyle()
        .onAppear {
            tabBarVisibility.isHidden = true
        }
        .onDisappear {
            tabBarVisibility.isHidden = false
        }
    }

    private func section(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(RemoteRecruitTheme.navy)
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .glassCard(cornerRadius: 12, opacity: 0.10)
    }

    private func salaryPanel(_ salary: String) -> some View {
        HStack {
            Image(systemName: "dollarsign.circle.fill")
                .font(.title2)
                .foregroundStyle(RemoteRecruitTheme.green)
            VStack(alignment: .leading) {
                Text("Salary insight")
                    .font(.headline)
                    .foregroundStyle(RemoteRecruitTheme.navy)
                Text(salary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(RemoteRecruitTheme.green.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(RemoteRecruitTheme.green.opacity(0.18))
        }
    }
}

struct FlowLayout: View {
    let items: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.primary.opacity(0.84))
                    .background(RemoteRecruitTheme.elevatedSurface, in: Capsule())
                    .overlay {
                        Capsule().stroke(RemoteRecruitTheme.cyan.opacity(0.16))
                    }
            }
        }
    }
}
