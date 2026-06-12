import SwiftUI

struct JobCardView: View {
    let job: Job
    let isSaved: Bool
    var onSave: () -> Void
    var onOpen: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    CompanyMark(name: job.company)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(job.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                        Text(job.company)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { onOpen?() }

                Spacer()
                Button {
                    onSave()
                } label: {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.subheadline.weight(.bold))
                        .frame(width: 34, height: 34)
                        .background((isSaved ? RemoteRecruitTheme.blue : Color(.secondarySystemBackground)).opacity(isSaved ? 0.14 : 1), in: Circle())
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
                .foregroundStyle(isSaved ? RemoteRecruitTheme.blue : .secondary)
                .accessibilityLabel(isSaved ? "Unsave job" : "Save job")
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(metadataChips, id: \.text) { chip in
                        Badge(text: chip.text, icon: chip.icon)
                    }
                }
            }

            HStack(spacing: 10) {
                Label(job.location, systemImage: "mappin.and.ellipse")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: 6)
                SalaryBadge(text: job.salary ?? SalaryInsight.estimate(for: job.title, tags: job.tags))
            }
            .contentShape(Rectangle())
            .onTapGesture { onOpen?() }
        }
        .padding(14)
        .glassCard(cornerRadius: 12, opacity: 0.13)
    }

    private var metadataChips: [(text: String, icon: String)] {
        var chips: [(String, String)] = []
        chips.append((normalizedWorkStyle, workStyleIcon))
        chips.append((normalizedEmploymentType, "clock"))
        if let seniority = seniority {
            chips.append((seniority, seniority == "Entry Level" ? "leaf" : "star"))
        }
        return Array(chips.prefix(4))
    }

    private var normalizedWorkStyle: String {
        let location = job.location.lowercased()
        let employment = job.employmentType.lowercased()
        if location.contains("hybrid") || employment.contains("hybrid") { return "Hybrid" }
        if location.contains("remote") || employment.contains("remote") { return "Remote" }
        return job.location.isEmpty ? "On-site" : job.location
    }

    private var workStyleIcon: String {
        normalizedWorkStyle == "Hybrid" ? "building.2" : "house.lodge"
    }

    private var normalizedEmploymentType: String {
        let employment = job.employmentType.lowercased()
        if employment.contains("contract") { return "Contract" }
        if employment.contains("part") { return "Part-Time" }
        return "Full-Time"
    }

    private var seniority: String? {
        let text = ([job.title] + job.tags + job.skills).joined(separator: " ").lowercased()
        if text.contains("intern") || text.contains("junior") || text.contains("entry") {
            return "Entry Level"
        }
        if text.contains("senior") || text.contains("lead") || text.contains("staff") || text.contains("principal") {
            return "Senior"
        }
        return nil
    }
}

private struct CompanyMark: View {
    let name: String

    var body: some View {
        Text(String(name.prefix(1)).uppercased())
            .font(.headline.weight(.black))
            .foregroundStyle(.white)
            .frame(width: 42, height: 42)
            .background(RemoteRecruitTheme.brandGradient)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct Badge: View {
    let text: String
    let icon: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemBackground), in: Capsule())
            .overlay {
                Capsule().stroke(Color.black.opacity(0.06))
            }
            .foregroundStyle(.primary.opacity(0.82))
    }
}

struct SalaryBadge: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "dollarsign.circle.fill")
            .font(.caption.weight(.bold))
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .foregroundStyle(RemoteRecruitTheme.green)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(RemoteRecruitTheme.green.opacity(0.14), in: Capsule())
            .overlay {
                Capsule().stroke(RemoteRecruitTheme.green.opacity(0.18))
            }
    }
}
