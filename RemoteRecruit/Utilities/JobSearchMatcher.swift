import Foundation

enum JobSearchMatcher {
    static func matches(_ job: Job, query: String) -> Bool {
        let queryTokens = baseTokens(from: query)
        guard !queryTokens.isEmpty else { return true }

        let jobTokens = normalizedTokens(from: searchableText(for: job))
        if queryTokens.count == 1 {
            return !queryTokens.isDisjoint(with: jobTokens)
        }
        return queryTokens.allSatisfy { jobTokens.contains($0) }
    }

    static func score(_ job: Job, query: String) -> Int {
        let queryTokens = normalizedTokens(from: query)
        guard !queryTokens.isEmpty else { return 0 }

        let jobTokens = normalizedTokens(from: searchableText(for: job))
        return queryTokens.filter { jobTokens.contains($0) }.count
    }

    static func normalizedTokens(from value: String) -> Set<String> {
        let rawTokens = baseTokens(from: value)

        return Set(rawTokens.flatMap { token -> [String] in
            switch token {
            case "developer", "dev", "developers":
                return [token, "developer", "engineer"]
            case "engineer", "engineering", "engineers":
                return [token, "engineer", "developer"]
            case "ios":
                return [token, "swift", "swiftui", "mobile"]
            case "android", "andorid":
                return [token, "kotlin", "mobile"]
            case "remote":
                return [token, "work"]
            default:
                return [token]
            }
        })
    }

    static func baseTokens(from value: String) -> Set<String> {
        Set(
            value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 1 }
            .map { token in
                switch token {
                case "developers":
                    return "developer"
                case "engineers", "engineering":
                    return "engineer"
                case "andorid":
                    return "android"
                default:
                    return token
                }
            }
        )
    }

    private static func searchableText(for job: Job) -> String {
        ([job.title, job.company, job.location, job.employmentType, job.description] + job.skills + job.tags)
            .joined(separator: " ")
    }
}
