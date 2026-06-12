import UIKit

@MainActor
enum Haptics {
    private static let notificationGenerator = UINotificationFeedbackGenerator()
    private static let selectionGenerator = UISelectionFeedbackGenerator()
    private static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    static func prepare() {
        guard !isRunningTests else { return }
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    static func success() {
        guard !isRunningTests else { return }
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    static func selection() {
        guard !isRunningTests else { return }
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }
}
