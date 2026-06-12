import Foundation

enum SkillExtractor {
    private static let knownSkills = ["SwiftUI", "Swift", "iOS", "Flutter", "React", "AI", "Cloud", "DevOps", "Kubernetes", "Python", "Data", "Security"]

    static func skills(from description: String) -> [String] {
        let lowercased = description.lowercased()
        let skills = knownSkills.filter { lowercased.contains($0.lowercased()) }
        return skills.isEmpty ? ["Communication", "Remote Collaboration", "Ownership"] : Array(skills.prefix(6))
    }
}
