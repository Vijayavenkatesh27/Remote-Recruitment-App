import Combine
import Foundation

final class PreviewRepository: JobRepositoryProtocol {
    func fetchJobs(request: JobSearchRequest) async throws -> [Job] {
        [Job.preview]
    }
}

@MainActor
final class PreviewSavedJobsStore: SavedJobsStoreProtocol {
    private let subject = CurrentValueSubject<[Job], Never>([])
    private var jobs: [Job] = []

    var savedJobsPublisher: AnyPublisher<[Job], Never> {
        subject.eraseToAnyPublisher()
    }

    func fetchSavedJobs() throws -> [Job] { jobs }
    func isSaved(_ job: Job) throws -> Bool { jobs.contains(where: { $0.id == job.id }) }
    func toggle(_ job: Job) throws {
        if try isSaved(job) {
            try delete(job)
        } else {
            jobs.append(job)
            subject.send(jobs)
        }
    }
    func delete(_ job: Job) throws {
        jobs.removeAll { $0.id == job.id }
        subject.send(jobs)
    }
    func clear() throws {
        jobs.removeAll()
        subject.send(jobs)
    }
}
