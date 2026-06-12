import Foundation

protocol JobRepositoryProtocol {
    func fetchJobs(request: JobSearchRequest) async throws -> [Job]
}

final class RemoteJobRepository: JobRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let fallbackProvider: FallbackJobProvider

    init(apiClient: APIClientProtocol, fallbackProvider: FallbackJobProvider) {
        self.apiClient = apiClient
        self.fallbackProvider = fallbackProvider
    }

    func fetchJobs(request: JobSearchRequest) async throws -> [Job] {
        do {
            let response: JobsAPIResponse = try await apiClient.send(.jobs(page: request.page))
            let jobs = response.data.map { $0.toJob(matchQuery: request.query) }
            let filteredJobs = filter(jobs, query: request.query)
            if !request.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, filteredJobs.isEmpty {
                return try fallbackJobs(matching: request.query)
            }
            return filteredJobs
        } catch {
            return try fallbackJobs(matching: request.query)
        }
    }

    private func filter(_ jobs: [Job], query: String) -> [Job] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return jobs }
        return jobs.filter {
            JobSearchMatcher.matches($0, query: trimmed)
        }
        .sorted {
            let left = JobSearchMatcher.score($0, query: trimmed)
            let right = JobSearchMatcher.score($1, query: trimmed)
            return left == right ? $0.title < $1.title : left > right
        }
    }

    private func fallbackJobs(matching query: String) throws -> [Job] {
        let fallbackJobs = try fallbackProvider.loadJobs()
        let rankedJobs = fallbackJobs.map { job in
            var copy = job
            copy.matchScore = MatchScorer.score(query: query, jobTitle: job.title, company: job.company, tags: job.tags)
            return copy
        }
        let filteredJobs = filter(rankedJobs, query: query)
        return filteredJobs.isEmpty ? rankedJobs : filteredJobs
    }
}
