import Foundation

protocol SearchHistoryStoreProtocol {
    func recentSearches() -> [String]
    func save(_ query: String)
    func clear()
}

enum SearchHistoryPolicy {
    static func updatedSearches(_ searches: [String], adding query: String, limit: Int = 8) -> [String] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return searches }

        var updated = searches.filter { $0.caseInsensitiveCompare(trimmed) != .orderedSame }
        updated.insert(trimmed, at: 0)
        return Array(updated.prefix(limit))
    }
}

final class UserDefaultsSearchHistoryStore: SearchHistoryStoreProtocol {
    private let defaults: UserDefaults
    private let key: String
    private let limit: Int

    init(defaults: UserDefaults = .standard, key: String = "recentSearches", limit: Int = 8) {
        self.defaults = defaults
        self.key = key
        self.limit = limit
    }

    func recentSearches() -> [String] {
        defaults.stringArray(forKey: key) ?? []
    }

    func save(_ query: String) {
        let searches = SearchHistoryPolicy.updatedSearches(recentSearches(), adding: query, limit: limit)
        defaults.set(searches, forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
