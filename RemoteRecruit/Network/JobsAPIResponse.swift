import Foundation

struct JobsAPIResponse: Decodable {
    let data: [ArbeitnowJobDTO]
}

struct ArbeitnowJobDTO: Decodable {
    let slug: String?
    let title: String?
    let companyName: String?
    let location: String?
    let remote: Bool?
    let jobTypes: [String]?
    let tags: [String]?
    let description: String?
    let url: URL?

    enum CodingKeys: String, CodingKey {
        case slug
        case title
        case companyName = "company_name"
        case location
        case remote
        case jobTypes = "job_types"
        case tags
        case description
        case url
    }

    func toJob(matchQuery: String) -> Job {
        let cleanDescription = (description ?? "No description provided.")
            .replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let employment = jobTypes?.first?.capitalized ?? (remote == true ? "Remote" : "Full-Time")
        let skillTags = Array((tags ?? []).prefix(6))
        return Job(
            id: slug ?? UUID().uuidString,
            title: title ?? "Untitled Role",
            company: companyName ?? "Unknown Company",
            location: remote == true ? "Remote" : (location ?? "Not specified"),
            employmentType: employment,
            salary: SalaryInsight.estimate(for: title ?? "", tags: tags ?? []),
            description: cleanDescription,
            skills: skillTags.isEmpty ? SkillExtractor.skills(from: cleanDescription) : skillTags,
            url: url,
            tags: tags ?? [],
            matchScore: MatchScorer.score(query: matchQuery, jobTitle: title ?? "", company: companyName ?? "", tags: tags ?? [])
        )
    }
}
