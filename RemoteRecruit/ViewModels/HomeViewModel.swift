import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var jobs: [Job] = [] {
        didSet { updateVisibleJobs() }
    }
    @Published private(set) var visibleJobs: [Job] = []
    @Published private(set) var state: AppLoadState = .idle
    @Published private(set) var savedIDs: Set<String> = []
    @Published private(set) var selectedFilter: JobFilter = .all
    @Published var searchText = "" {
        didSet { updateVisibleJobs() }
    }

    private let repository: JobRepositoryProtocol
    private let savedStore: SavedJobsStoreProtocol
    private var cancellables = Set<AnyCancellable>()
    private var page = 1
    private var isFetching = false

    init(repository: JobRepositoryProtocol, savedStore: SavedJobsStoreProtocol) {
        self.repository = repository
        self.savedStore = savedStore
        bindSavedJobs()
        reloadSavedIDs()
    }

    func setFilter(_ filter: JobFilter) {
        guard selectedFilter != filter else { return }
        selectedFilter = filter
        updateVisibleJobs()
    }

    private func updateVisibleJobs() {
        visibleJobs = jobs
            .filter { selectedFilter.matches($0) }
            .filter { job in
                let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !query.isEmpty else { return true }
                return [job.title, job.company, job.location, job.employmentType, job.tags.joined(separator: " ")]
                    .joined(separator: " ")
                    .localizedCaseInsensitiveContains(query)
            }
            .sorted {
                let leftPriority = techPriority(for: $0)
                let rightPriority = techPriority(for: $1)
                if leftPriority == rightPriority {
                    return $0.title < $1.title
                }
                return leftPriority > rightPriority
            }
    }

    func load() async {
        guard jobs.isEmpty else { return }
        await refresh()
    }

    func refresh() async {
        page = 1
        state = .loading
        do {
            let fetched = try await repository.fetchJobs(request: JobSearchRequest(page: page))
            jobs = fetched
            state = fetched.isEmpty ? .empty : .success
            reloadSavedIDs()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func loadMoreIfNeeded(currentJob: Job) async {
        guard currentJob.id == jobs.last?.id, !isFetching else { return }
        isFetching = true
        page += 1
        defer { isFetching = false }
        if let more = try? await repository.fetchJobs(request: JobSearchRequest(page: page)) {
            jobs.append(contentsOf: more)
        }
    }

    func toggleSaved(_ job: Job) {
        let wasSaved = savedIDs.contains(job.id)
        if wasSaved {
            savedIDs.remove(job.id)
        } else {
            savedIDs.insert(job.id)
        }
        Haptics.success()

        do {
            try savedStore.toggle(job)
        } catch {
            if wasSaved {
                savedIDs.insert(job.id)
            } else {
                savedIDs.remove(job.id)
            }
            state = .failed(error.localizedDescription)
        }
    }

    private func reloadSavedIDs() {
        savedIDs = Set((try? savedStore.fetchSavedJobs().map(\.id)) ?? [])
    }

    private func bindSavedJobs() {
        savedStore.savedJobsPublisher
            .sink { [weak self] jobs in
                self?.savedIDs = Set(jobs.map(\.id))
            }
            .store(in: &cancellables)
    }

    private func techPriority(for job: Job) -> Int {
        let text = ([job.title, job.description] + job.skills + job.tags).joined(separator: " ").lowercased()
        let priorityTerms = ["ios", "swiftui", "mobile", "backend", "ai", "product designer", "swift", "cloud", "devops"]
        return priorityTerms.reduce(0) { score, term in
            score + (text.contains(term) ? 1 : 0)
        }
    }
}
