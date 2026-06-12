import Foundation
import SwiftData

@Model
final class SavedJobEntity {
    @Attribute(.unique) var id: String
    var title: String
    var company: String
    var location: String
    var employmentType: String
    var salary: String?
    var jobDescription: String
    var skills: [String]
    var urlString: String?
    var tags: [String]
    var savedAt: Date

    init(job: Job) {
        self.id = job.id
        self.title = job.title
        self.company = job.company
        self.location = job.location
        self.employmentType = job.employmentType
        self.salary = job.salary
        self.jobDescription = job.description
        self.skills = job.skills
        self.urlString = job.url?.absoluteString
        self.tags = job.tags
        self.savedAt = Date()
    }

    var job: Job {
        Job(
            id: id,
            title: title,
            company: company,
            location: location,
            employmentType: employmentType,
            salary: salary,
            description: jobDescription,
            skills: skills,
            url: urlString.flatMap(URL.init(string:)),
            tags: tags,
            matchScore: 88
        )
    }
}
