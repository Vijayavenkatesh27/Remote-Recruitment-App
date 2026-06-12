import Foundation

struct Endpoint {
    let path: String
    var queryItems: [URLQueryItem] = []
    var method: String = "GET"

    static func jobs(page: Int) -> Endpoint {
        Endpoint(path: "/api/job-board-api", queryItems: [URLQueryItem(name: "page", value: "\(page)")])
    }

    func makeRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.arbeitnow.com"
        components.path = path
        components.queryItems = queryItems
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 16
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
