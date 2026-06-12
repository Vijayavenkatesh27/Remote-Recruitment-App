import SwiftData
import SwiftUI

@MainActor
final class AppContainer {
    let jobRepository: JobRepositoryProtocol
    let savedJobsStore: SavedJobsStoreProtocol
    let searchHistoryStore: SearchHistoryStoreProtocol

    init(modelContext: ModelContext) {
        let client = URLSessionAPIClient()
        let fallback = BundleFallbackJobProvider(fileName: "fallbackJobs")
        let savedStore = SwiftDataSavedJobsStore(modelContext: modelContext)
        _ = try? savedStore.fetchSavedJobs()
        self.jobRepository = RemoteJobRepository(apiClient: client, fallbackProvider: fallback)
        self.savedJobsStore = savedStore
        self.searchHistoryStore = UserDefaultsSearchHistoryStore()
    }
}

private struct AppContainerKey: EnvironmentKey {
    @MainActor static var defaultValue: AppContainer = {
        let schema = Schema([SavedJobEntity.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: configuration)
        return AppContainer(modelContext: ModelContext(container))
    }()
}

extension EnvironmentValues {
    var appContainer: AppContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}
