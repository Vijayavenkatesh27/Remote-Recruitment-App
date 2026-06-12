import XCTest
@testable import RemoteRecruit

final class BusinessLogicTests: XCTestCase {
    func testMatchScorerRewardsRelevantKeywords() {
        let strong = MatchScorer.score(query: "iOS SwiftUI remote", jobTitle: "Senior iOS SwiftUI Engineer", company: "Orbit", tags: ["Remote", "Swift"])
        let weak = MatchScorer.score(query: "iOS SwiftUI remote", jobTitle: "Backend PHP Developer", company: "Legacy", tags: ["Onsite"])

        XCTAssertGreaterThan(strong, weak)
        XCTAssertGreaterThanOrEqual(strong, 80)
    }

    func testSalaryInsightUsesSeniorityAndTechnologySignals() {
        XCTAssertEqual(SalaryInsight.estimate(for: "Senior iOS Engineer", tags: ["SwiftUI"]), "$120k - $170k")
        XCTAssertEqual(SalaryInsight.estimate(for: "Junior Designer", tags: []), "$55k - $85k")
        XCTAssertEqual(SalaryInsight.estimate(for: "Product Manager", tags: []), "$80k - $125k")
    }

    func testSkillExtractorFallsBackWhenNoKnownSkillsExist() {
        let skills = SkillExtractor.skills(from: "Own delivery and communicate clearly across remote teams.")

        XCTAssertEqual(skills, ["Communication", "Remote Collaboration", "Ownership"])
    }

    func testSearchHistoryDeduplicatesAndLimitsResults() {
        var searches: [String] = []

        for query in ["iOS", "Cloud", "AI", "Flutter", "DevOps", "Design", "Data", "Security", "iOS", "  "] {
            searches = SearchHistoryPolicy.updatedSearches(searches, adding: query)
        }

        XCTAssertEqual(searches.first, "iOS")
        XCTAssertEqual(searches.filter { $0 == "iOS" }.count, 1)
        XCTAssertLessThanOrEqual(searches.count, 8)
    }

    func testJobFilterMatchesRemoteAndTechRoles() {
        let remoteTechJob = Job(
            id: "filter-test",
            title: "Cloud iOS Engineer",
            company: "Acme",
            location: "Remote",
            employmentType: "Full-Time",
            salary: "$100k - $140k",
            description: "Build cloud mobile tools.",
            skills: ["iOS", "Cloud"],
            url: nil,
            tags: ["Swift", "Cloud"],
            matchScore: 90
        )

        XCTAssertTrue(JobFilter.remote.matches(remoteTechJob))
        XCTAssertTrue(JobFilter.tech.matches(remoteTechJob))
        XCTAssertTrue(JobFilter.fullTime.matches(remoteTechJob))
    }

    func testJobFilterHandlesCommonApiEmploymentValues() {
        let fullTimeJob = Job.preview.withEmploymentType("full_time")
        let permanentJob = Job.preview.withEmploymentType("Permanent")
        let contractJob = Job.preview.withEmploymentType("Freelance Contract")

        XCTAssertTrue(JobFilter.fullTime.matches(fullTimeJob))
        XCTAssertTrue(JobFilter.fullTime.matches(permanentJob))
        XCTAssertTrue(JobFilter.contract.matches(contractJob))
    }

    func testSearchMatcherHandlesDeveloperEngineerSynonyms() {
        let iosJob = Job.preview.withTitle("Senior iOS Engineer")
        let androidJob = Job.preview.withTitle("Android Developer")
        let softwareJob = Job.preview.withTitle("Software Engineer")
        let backendJob = Job.preview.withTitle("Backend Engineer")

        XCTAssertTrue(JobSearchMatcher.matches(iosJob, query: "ios developer"))
        XCTAssertTrue(JobSearchMatcher.matches(androidJob, query: "android engineer"))
        XCTAssertTrue(JobSearchMatcher.matches(softwareJob, query: "software engineers"))
        XCTAssertFalse(JobSearchMatcher.matches(backendJob, query: "software engineers"))
    }
}

private extension Job {
    func withEmploymentType(_ employmentType: String) -> Job {
        Job(
            id: id,
            title: title,
            company: company,
            location: location,
            employmentType: employmentType,
            salary: salary,
            description: description,
            skills: skills,
            url: url,
            tags: tags,
            matchScore: matchScore
        )
    }

    func withTitle(_ title: String) -> Job {
        Job(
            id: id,
            title: title,
            company: company,
            location: location,
            employmentType: employmentType,
            salary: salary,
            description: description,
            skills: skills,
            url: url,
            tags: tags,
            matchScore: matchScore
        )
    }
}
