import Combine
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [Job] = [] {
        didSet { updateVisibleResults() }
    }
    @Published private(set) var visibleResults: [Job] = []
    @Published private(set) var state: AppLoadState = .idle
    @Published private(set) var suggestions: [String] = []
    @Published private(set) var recentSearches: [String] = []
    @Published private(set) var savedIDs: Set<String> = []
    @Published private(set) var selectedFilter: JobFilter = .all

    private let repository: JobRepositoryProtocol
    private let historyStore: SearchHistoryStoreProtocol
    private let savedStore: SavedJobsStoreProtocol
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?

    init(repository: JobRepositoryProtocol, historyStore: SearchHistoryStoreProtocol, savedStore: SavedJobsStoreProtocol) {
        self.repository = repository
        self.historyStore = historyStore
        self.savedStore = savedStore
        recentSearches = historyStore.recentSearches()
        suggestions = Self.defaultSuggestions
        bindSavedJobs()
        reloadSavedIDs()
    }

    func setFilter(_ filter: JobFilter) {
        guard selectedFilter != filter else { return }
        selectedFilter = filter
        updateVisibleResults()
    }

    func submitSearch(_ value: String? = nil) {
        let text = value ?? query
        historyStore.save(text)
        recentSearches = historyStore.recentSearches()
    }

    func updateQuery(_ text: String, debounce: Bool = true) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            if debounce {
                try? await Task.sleep(for: .milliseconds(320))
            }
            guard !Task.isCancelled else { return }
            await self?.applyQuery(text)
        }
    }

    func clearHistory() {
        historyStore.clear()
        recentSearches = []
    }

    func loadInitialJobs() async {
        guard query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        state = .loading
        do {
            let jobs = try await repository.fetchJobs(request: JobSearchRequest())
            results = jobs
            state = jobs.isEmpty ? .empty : .success
            reloadSavedIDs()
        } catch {
            state = .failed(error.localizedDescription)
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

    private func applyQuery(_ text: String) async {
        guard query != text else { return }
        query = text
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        suggestions = makeSuggestions(for: trimmed)
        guard !trimmed.isEmpty else {
            await loadInitialJobs()
            return
        }
        state = .loading
        do {
            let jobs = try await repository.fetchJobs(request: JobSearchRequest(query: trimmed))
            results = jobs
            state = jobs.isEmpty ? .empty : .success
            reloadSavedIDs()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private func makeSuggestions(for text: String) -> [String] {
        let defaults = Self.defaultSuggestions
        guard !text.isEmpty else { return defaults }

        let normalizedText = normalizedSuggestionText(from: text)
        let queryTokens = JobSearchMatcher.baseTokens(from: normalizedText)
        let matchingJobTitles = results
            .filter { JobSearchMatcher.matches($0, query: normalizedText) }
            .map(\.title)

        let filteredDefaults = defaults.filter { suggestion in
            suggestion.localizedCaseInsensitiveContains(normalizedText)
                || JobSearchMatcher.baseTokens(from: suggestion).isSuperset(of: queryTokens)
        }
        let filteredHistory = recentSearches.filter {
            $0.localizedCaseInsensitiveContains(normalizedText)
                || JobSearchMatcher.baseTokens(from: $0).isSuperset(of: queryTokens)
        }

        return uniqueSuggestions(
            generatedSuggestions(for: normalizedText) + matchingJobTitles + filteredDefaults + filteredHistory
        )
        .prefix(8)
        .map { $0 }
    }

    private func reloadSavedIDs() {
        savedIDs = Set((try? savedStore.fetchSavedJobs().map(\.id)) ?? [])
    }

    private func updateVisibleResults() {
        visibleResults = results.filter { selectedFilter.matches($0) }
    }

    private func bindSavedJobs() {
        savedStore.savedJobsPublisher
            .sink { [weak self] jobs in
                self?.savedIDs = Set(jobs.map(\.id))
            }
            .store(in: &cancellables)
    }

    private static let defaultSuggestions = [
        "Software Engineer",
        "iOS Developer",
        "SwiftUI Engineer",
        "Remote iOS",
        "Mobile Engineer",
        "Android Developer",
        "AI Engineer"
    ]

    private func generatedSuggestions(for text: String) -> [String] {
        guard !text.isEmpty else { return [] }
        let title = text.capitalized
        if JobSearchMatcher.baseTokens(from: text).count <= 1 {
            return [title]
        }
        return [
            title,
            "Remote \(title)",
            "Senior \(title)",
            "\(title) Full-Time",
            "\(title) Contract"
        ]
    }

    private func normalizedSuggestionText(from text: String) -> String {
        let words = text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .map { word in
                switch word {
                case "engineers":
                    return "engineer"
                case "developers":
                    return "developer"
                case "andorid":
                    return "android"
                default:
                    return word
                }
            }
        return words.joined(separator: " ")
    }

    private func uniqueSuggestions(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.compactMap { value in
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let key = trimmed.lowercased()
            guard seen.insert(key).inserted else { return nil }
            return trimmed
        }
    }
}
