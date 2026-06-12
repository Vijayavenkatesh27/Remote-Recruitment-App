import Foundation

protocol FallbackJobProvider {
    func loadJobs() throws -> [Job]
}

final class BundleFallbackJobProvider: FallbackJobProvider {
    private let fileName: String
    private let bundle: Bundle

    init(fileName: String, bundle: Bundle = .main) {
        self.fileName = fileName
        self.bundle = bundle
    }

    func loadJobs() throws -> [Job] {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Job].self, from: data)
    }
}
