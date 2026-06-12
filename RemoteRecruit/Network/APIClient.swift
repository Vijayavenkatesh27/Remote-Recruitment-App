import Foundation
import OSLog

protocol APIClientProtocol {
    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class URLSessionAPIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger = Logger(subsystem: "RemoteRecruit", category: "network")

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try endpoint.makeRequest()
        logger.info("Requesting \(request.url?.absoluteString ?? "unknown", privacy: .public)")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.statusCode(httpResponse.statusCode)
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}

enum APIError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decoding(Error)

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL), (.invalidResponse, .invalidResponse):
            true
        case let (.statusCode(left), .statusCode(right)):
            left == right
        case (.decoding, .decoding):
            true
        default:
            false
        }
    }

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The jobs endpoint is not configured correctly."
        case .invalidResponse:
            "The server returned an unreadable response."
        case let .statusCode(code):
            "The jobs server returned status \(code)."
        case .decoding:
            "The job data could not be decoded."
        }
    }
}
