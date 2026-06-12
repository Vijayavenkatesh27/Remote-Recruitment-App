import Combine
import Foundation
import SwiftData

protocol SavedJobsStoreProtocol {
    var savedJobsPublisher: AnyPublisher<[Job], Never> { get }

    func fetchSavedJobs() throws -> [Job]
    func isSaved(_ job: Job) throws -> Bool
    func toggle(_ job: Job) throws
    func delete(_ job: Job) throws
    func clear() throws
}

@MainActor
final class SwiftDataSavedJobsStore: SavedJobsStoreProtocol {
    private let modelContext: ModelContext
    private let defaults: UserDefaults
    private let cacheKey = "cachedSavedJobs"
    private let persistenceQueue = DispatchQueue(label: "com.remoterecruit.savedjobs.persistence", qos: .utility)
    private let subject: CurrentValueSubject<[Job], Never>
    private var pendingPersistenceWorkItem: DispatchWorkItem?
    private var cachedJobs: [Job]

    init(modelContext: ModelContext, defaults: UserDefaults = .standard) {
        self.modelContext = modelContext
        self.defaults = defaults
        let loadedJobs: [Job]
        let shouldPersistCache: Bool
        if let data = defaults.data(forKey: cacheKey),
           let jobs = try? JSONDecoder().decode([Job].self, from: data) {
            loadedJobs = jobs
            shouldPersistCache = false
        } else {
            let descriptor = FetchDescriptor<SavedJobEntity>(sortBy: [SortDescriptor(\.savedAt, order: .reverse)])
            loadedJobs = (try? modelContext.fetch(descriptor).map(\.job)) ?? []
            shouldPersistCache = true
        }
        self.cachedJobs = loadedJobs
        self.subject = CurrentValueSubject(loadedJobs)
        if shouldPersistCache {
            persistCache()
        }
    }

    var savedJobsPublisher: AnyPublisher<[Job], Never> {
        subject.eraseToAnyPublisher()
    }

    func fetchSavedJobs() throws -> [Job] {
        cachedJobs
    }

    func isSaved(_ job: Job) throws -> Bool {
        cachedJobs.contains { $0.id == job.id }
    }

    func toggle(_ job: Job) throws {
        if let index = cachedJobs.firstIndex(where: { $0.id == job.id }) {
            cachedJobs.remove(at: index)
        } else {
            cachedJobs.insert(job, at: 0)
        }
        publishAndPersist()
    }

    func delete(_ job: Job) throws {
        cachedJobs.removeAll { $0.id == job.id }
        publishAndPersist()
    }

    func clear() throws {
        cachedJobs = []
        publishAndPersist()
    }

    private func publishAndPersist() {
        subject.send(cachedJobs)
        persistCache()
    }

    private func persistCache() {
        pendingPersistenceWorkItem?.cancel()
        let jobs = cachedJobs
        let defaults = defaults
        let cacheKey = cacheKey
        let workItem = DispatchWorkItem {
            guard let data = try? JSONEncoder().encode(jobs) else { return }
            defaults.set(data, forKey: cacheKey)
        }
        pendingPersistenceWorkItem = workItem
        persistenceQueue.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }
}
