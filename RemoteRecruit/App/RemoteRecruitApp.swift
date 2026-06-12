import SwiftData
import SwiftUI
import UIKit

@main
@MainActor
struct RemoteRecruitApp: App {
    private let modelContainer: ModelContainer
    private let appContainer: AppContainer

    init() {
        Self.configureTabBarAppearance()

        do {
            let container = try ModelContainer(for: SavedJobEntity.self)
            modelContainer = container
            appContainer = AppContainer(modelContext: container.mainContext)
        } catch {
            fatalError("Unable to create local store: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(appContainer: appContainer)
                .modelContainer(modelContainer)
                .onAppear {
                    Haptics.prepare()
                }
        }
    }

    private static func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.shadowColor = UIColor.separator.withAlphaComponent(0.18)

        let selected = UIColor(RemoteRecruitTheme.blue)
        let normal = UIColor.secondaryLabel

        [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance].forEach { itemAppearance in
            itemAppearance.selected.iconColor = selected
            itemAppearance.selected.titleTextAttributes = [
                .foregroundColor: selected,
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
            ]
            itemAppearance.normal.iconColor = normal
            itemAppearance.normal.titleTextAttributes = [
                .foregroundColor: normal,
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
            ]
        }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = false
    }
}
