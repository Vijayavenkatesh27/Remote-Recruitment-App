import Foundation

enum JobFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case remote = "Remote"
    case hybrid = "Hybrid"
    case fullTime = "Full-Time"
    case partTime = "Part-Time"
    case contract = "Contract"
    case tech = "Tech"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: "square.grid.2x2"
        case .remote: "house.lodge"
        case .hybrid: "building.2"
        case .fullTime: "clock.fill"
        case .partTime: "clock"
        case .contract: "doc.text"
        case .tech: "cpu"
        }
    }

    func matches(_ job: Job) -> Bool {
        let text = ([job.title, job.company, job.location, job.employmentType, job.description] + job.skills + job.tags)
            .joined(separator: " ")
            .lowercased()

        switch self {
        case .all:
            return true
        case .remote:
            return text.contains("remote")
        case .hybrid:
            return text.contains("hybrid")
        case .fullTime:
            return text.contains("full-time")
                || text.contains("full time")
                || text.contains("full_time")
                || text.contains("permanent")
                || text.contains("employee")
        case .partTime:
            return text.contains("part-time") || text.contains("part time") || text.contains("part_time")
        case .contract:
            return text.contains("contract") || text.contains("freelance") || text.contains("temporary")
        case .tech:
            return TrendingKeyword.all.contains { text.contains($0) }
        }
    }
}
