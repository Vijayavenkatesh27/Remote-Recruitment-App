import Combine
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: AppTheme = .system
    @AppStorage("candidateName") var candidateName = "Vijaya Venkatesh"
    @AppStorage("preferredRole") var preferredRole = "Senior iOS Engineer"
    @AppStorage("preferredLocation") var preferredLocation = "Remote - United States"
    @AppStorage("preferredWorkMode") var preferredWorkMode = WorkMode.remote.rawValue
    @AppStorage("preferredEmploymentType") var preferredEmploymentType = EmploymentType.fullTime.rawValue
    @AppStorage("availability") var availability = Availability.twoWeeks.rawValue
    @AppStorage("expectedSalary") var expectedSalary = "USD $130k - $170k"
    @AppStorage("workAuthorization") var workAuthorization = WorkAuthorization.authorized.rawValue
    @AppStorage("preferredTimeZone") var preferredTimeZone = TimeZonePreference.usOverlap.rawValue
    @AppStorage("isOpenToWork") var isOpenToWork = true
    @AppStorage("jobAlertsEnabled") var jobAlertsEnabled = true
    @AppStorage("profileVisibleToRecruiters") var profileVisibleToRecruiters = true
    @AppStorage("resumeStatus") var resumeStatus = "Ready"

    init() {
        migrateLegacyProfileDefaults()
    }

    var colorScheme: ColorScheme? {
        switch selectedTheme {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }

    var profileCompletion: Double {
        let values = [
            candidateName,
            preferredRole,
            preferredLocation,
            preferredWorkMode,
            preferredEmploymentType,
            availability,
            expectedSalary,
            workAuthorization,
            preferredTimeZone,
            resumeStatus
        ]
        let completedFields = values.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
        let openToWorkField = isOpenToWork ? 1 : 0
        return Double(completedFields + openToWorkField) / 11.0
    }

    private func migrateLegacyProfileDefaults() {
        if preferredRole == "iOS / SwiftUI Engineer" {
            preferredRole = "Senior iOS Engineer"
        }
        if preferredLocation == "United States, Remote" {
            preferredLocation = "Remote - United States"
        }
        if expectedSalary == "$120k - $160k" {
            expectedSalary = "USD $130k - $170k"
        }
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }
}

enum WorkMode: String, CaseIterable, Identifiable {
    case remote = "Remote"
    case hybrid = "Hybrid"
    case onsite = "On-site"

    var id: String { rawValue }
}

enum EmploymentType: String, CaseIterable, Identifiable {
    case fullTime = "Full-time"
    case contract = "Contract"
    case partTime = "Part-time"

    var id: String { rawValue }
}

enum Availability: String, CaseIterable, Identifiable {
    case immediate = "Immediate"
    case twoWeeks = "2 weeks"
    case oneMonth = "1 month"

    var id: String { rawValue }
}

enum WorkAuthorization: String, CaseIterable, Identifiable {
    case authorized = "US work authorized"
    case sponsorship = "Needs sponsorship"
    case contractor = "US contractor"

    var id: String { rawValue }
}

enum TimeZonePreference: String, CaseIterable, Identifiable {
    case usOverlap = "US time zones"
    case eastern = "Eastern Time"
    case central = "Central Time"
    case mountain = "Mountain Time"
    case pacific = "Pacific Time"

    var id: String { rawValue }
}
