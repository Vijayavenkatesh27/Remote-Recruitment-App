import Combine
import XCTest
@testable import RemoteRecruit

@MainActor
final class ViewModelTests: XCTestCase {
    func testHomeViewModelLoadsAndFiltersJobs() async {
        let repository = StubJobRepository(jobs: [.iosEngineer, .contractDesigner])
        let savedStore = InMemorySavedJobsStore()
        let viewModel = HomeViewModel(repository: repository, savedStore: savedStore)

        await viewModel.refresh()
        viewModel.setFilter(.remote)

        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(viewModel.visibleJobs.map(\.id), ["ios"])
    }

    func testSearchViewModelSearchesSavesHistoryAndBuildsRelevantSuggestions() async {
        let repository = StubJobRepository(jobs: [.iosEngineer, .backendEngineer])
        let historyStore = InMemorySearchHistoryStore()
        let savedStore = InMemorySavedJobsStore()
        let viewModel = SearchViewModel(repository: repository, historyStore: historyStore, savedStore: savedStore)

        viewModel.updateQuery("ios developer", debounce: false)
        await waitUntil { viewModel.query == "ios developer" }
        viewModel.submitSearch()

        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(viewModel.visibleResults.map(\.id), ["ios"])
        XCTAssertEqual(viewModel.recentSearches.first, "ios developer")
        XCTAssertTrue(viewModel.suggestions.contains { $0.localizedCaseInsensitiveContains("ios developer") })
    }

    func testSearchViewModelClearQueryRestoresAllJobs() async {
        let repository = StubJobRepository(jobs: [.iosEngineer, .backendEngineer])
        let viewModel = SearchViewModel(
            repository: repository,
            historyStore: InMemorySearchHistoryStore(),
            savedStore: InMemorySavedJobsStore()
        )

        viewModel.updateQuery("ios developer", debounce: false)
        await waitUntil { viewModel.visibleResults.map(\.id) == ["ios"] }

        await viewModel.clearQuery()

        XCTAssertTrue(viewModel.query.isEmpty)
        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(viewModel.visibleResults.map(\.id), ["ios", "backend"])
    }

    private func waitUntil(_ condition: @escaping @MainActor () -> Bool) async {
        for _ in 0..<20 where !condition() {
            await Task.yield()
        }
    }
}

private final class StubJobRepository: JobRepositoryProtocol {
    private let jobs: [Job]

    init(jobs: [Job]) {
        self.jobs = jobs
    }

    func fetchJobs(request: JobSearchRequest) async throws -> [Job] {
        let query = request.query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return jobs }
        return jobs.filter { JobSearchMatcher.matches($0, query: query) }
    }
}

private final class InMemorySearchHistoryStore: SearchHistoryStoreProtocol {
    private var searches: [String] = []

    func recentSearches() -> [String] {
        searches
    }

    func save(_ query: String) {
        searches = SearchHistoryPolicy.updatedSearches(searches, adding: query)
    }

    func clear() {
        searches = []
    }
}

private final class InMemorySavedJobsStore: SavedJobsStoreProtocol {
    private let subject: CurrentValueSubject<[Job], Never>
    private var jobs: [Job]

    init(initialJobs: [Job] = []) {
        self.jobs = initialJobs
        self.subject = CurrentValueSubject(initialJobs)
    }

    var savedJobsPublisher: AnyPublisher<[Job], Never> {
        subject.eraseToAnyPublisher()
    }

    func fetchSavedJobs() throws -> [Job] {
        jobs
    }

    func isSaved(_ job: Job) throws -> Bool {
        jobs.contains { $0.id == job.id }
    }

    func toggle(_ job: Job) throws {
        if let index = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs.remove(at: index)
        } else {
            jobs.insert(job, at: 0)
        }
        subject.send(jobs)
    }

    func delete(_ job: Job) throws {
        jobs.removeAll { $0.id == job.id }
        subject.send(jobs)
    }

    func clear() throws {
        jobs = []
        subject.send(jobs)
    }
}

private extension Job {
    static let iosEngineer = Job(
        id: "ios",
        title: "Senior iOS Developer",
        company: "Northstar Remote",
        location: "Remote",
        employmentType: "Full-Time",
        salary: "$120k - $170k",
        description: "Build SwiftUI job discovery features.",
        skills: ["SwiftUI", "iOS"],
        url: nil,
        tags: ["Remote", "SwiftUI"],
        matchScore: 90
    )

    static let backendEngineer = Job(
        id: "backend",
        title: "Backend Engineer",
        company: "CloudWorks",
        location: "New York",
        employmentType: "Full-Time",
        salary: "$110k - $150k",
        description: "Build cloud APIs.",
        skills: ["Cloud", "API"],
        url: nil,
        tags: ["Backend"],
        matchScore: 70
    )

    static let contractDesigner = Job(
        id: "designer",
        title: "Product Designer",
        company: "DesignOps",
        location: "Hybrid",
        employmentType: "Contract",
        salary: "$80k - $120k",
        description: "Design recruiter workflows.",
        skills: ["Product Design"],
        url: nil,
        tags: ["Hybrid", "Contract"],
        matchScore: 60
    )
}
