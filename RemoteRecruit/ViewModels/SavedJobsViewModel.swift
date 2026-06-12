import Combine
import Foundation

@MainActor
final class SavedJobsViewModel: ObservableObject {
    @Published private(set) var jobs: [Job] = []
    @Published private(set) var state: AppLoadState = .idle

    private let store: SavedJobsStoreProtocol
    private var cancellables = Set<AnyCancellable>()

    init(store: SavedJobsStoreProtocol) {
        self.store = store
        bindSavedJobs()
    }

    func load() {
        do {
            jobs = try store.fetchSavedJobs()
            state = jobs.isEmpty ? .empty : .success
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func delete(_ job: Job) {
        let previousJobs = jobs
        jobs.removeAll { $0.id == job.id }
        state = jobs.isEmpty ? .empty : .success

        do {
            try store.delete(job)
            Haptics.selection()
        } catch {
            jobs = previousJobs
            state = .failed(error.localizedDescription)
        }
    }

    func clear() {
        let previousJobs = jobs
        jobs = []
        state = .empty

        do {
            try store.clear()
        } catch {
            jobs = previousJobs
            state = .failed(error.localizedDescription)
        }
    }

    private func bindSavedJobs() {
        store.savedJobsPublisher
            .sink { [weak self] jobs in
                self?.jobs = jobs
                self?.state = jobs.isEmpty ? .empty : .success
            }
            .store(in: &cancellables)
    }
}
