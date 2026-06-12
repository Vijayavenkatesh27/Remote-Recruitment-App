import Foundation

enum MatchScorer {
    static func score(query: String, jobTitle: String, company: String, tags: [String]) -> Int {
        let queryTokens = tokens(from: query)
        guard !queryTokens.isEmpty else {
            let trendBoost = tags.contains { TrendingKeyword.all.contains($0.lowercased()) } ? 14 : 0
            return min(98, 70 + trendBoost)
        }

        let haystack = tokens(from: "\(jobTitle) \(company) \(tags.joined(separator: " "))")
        let matched = queryTokens.filter { haystack.contains($0) }.count
        let ratio = Double(matched) / Double(queryTokens.count)
        return max(35, min(99, Int(52 + ratio * 47)))
    }

    private static func tokens(from value: String) -> Set<String> {
        Set(value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 1 })
    }
}

enum TrendingKeyword {
    static let all: Set<String> = ["ai", "ios", "swift", "flutter", "cloud", "devops", "kubernetes", "data"]
}
