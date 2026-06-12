import Foundation

enum SalaryInsight {
    static func estimate(for title: String, tags: [String]) -> String {
        let text = (title + " " + tags.joined(separator: " ")).lowercased()
        if text.contains("senior") || text.contains("lead") {
            return "$120k - $170k"
        }
        if text.contains("ios") || text.contains("swift") || text.contains("cloud") {
            return "$95k - $140k"
        }
        if text.contains("junior") {
            return "$55k - $85k"
        }
        return "$80k - $125k"
    }
}
