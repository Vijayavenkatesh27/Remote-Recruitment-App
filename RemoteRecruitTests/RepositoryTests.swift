import XCTest
@testable import RemoteRecruit

final class RepositoryTests: XCTestCase {
    func testRepositoryFiltersFallbackJobsWhenNetworkFails() async throws {
        let repository = RemoteJobRepository(
            apiClient: FailingAPIClient(),
            fallbackProvider: StaticFallbackProvider(jobs: [
                Job(id: "1", title: "iOS Engineer", company: "A", location: "Remote", employmentType: "Full-Time", salary: nil, description: "SwiftUI", skills: ["SwiftUI"], url: nil, tags: ["iOS"], matchScore: 0),
                Job(id: "2", title: "Backend Engineer", company: "B", location: "Remote", employmentType: "Full-Time", salary: nil, description: "Go", skills: ["Go"], url: nil, tags: ["Backend"], matchScore: 0)
            ])
        )

        let jobs = try await repository.fetchJobs(request: JobSearchRequest(query: "iOS"))

        XCTAssertEqual(jobs.map(\.id), ["1"])
        XCTAssertGreaterThan(jobs[0].matchScore, 50)
    }
}

private struct FailingAPIClient: APIClientProtocol {
    func send<T>(_ endpoint: Endpoint) async throws -> T where T: Decodable {
        throw APIError.invalidResponse
    }
}

private struct StaticFallbackProvider: FallbackJobProvider {
    let jobs: [Job]

    func loadJobs() throws -> [Job] {
        jobs
    }
}
