import Foundation

struct Job: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let title: String
    let company: String
    let location: String
    let employmentType: String
    let salary: String?
    let description: String
    let skills: [String]
    let url: URL?
    let tags: [String]
    var matchScore: Int

    static let preview = Job(
        id: "preview-ios",
        title: "Senior iOS Engineer",
        company: "Orbit Labs",
        location: "Remote",
        employmentType: "Full-Time",
        salary: "$120k - $155k",
        description: "Build polished mobile experiences for global remote teams using SwiftUI and modern architecture.",
        skills: ["SwiftUI", "MVVM", "Async/Await", "Testing"],
        url: URL(string: "https://example.com"),
        tags: ["iOS", "SwiftUI", "Remote"],
        matchScore: 92
    )
}

struct JobSearchRequest: Equatable {
    var query: String = ""
    var page: Int = 1
}
