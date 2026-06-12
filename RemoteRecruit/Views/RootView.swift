import Combine
import SwiftData
import SwiftUI

struct RootView: View {
    @StateObject private var settings = SettingsViewModel()
    @StateObject private var tabBarVisibility = TabBarVisibilityController()
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var searchViewModel: SearchViewModel
    @StateObject private var savedJobsViewModel: SavedJobsViewModel
    @State private var showLaunch = true
    @State private var selectedTab: AppTab = .discover
    @State private var visitedTabs: Set<AppTab> = [.discover]

    private let appContainer: AppContainer

    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        _homeViewModel = StateObject(
            wrappedValue: HomeViewModel(
                repository: appContainer.jobRepository,
                savedStore: appContainer.savedJobsStore
            )
        )
        _searchViewModel = StateObject(
            wrappedValue: SearchViewModel(
                repository: appContainer.jobRepository,
                historyStore: appContainer.searchHistoryStore,
                savedStore: appContainer.savedJobsStore
            )
        )
        _savedJobsViewModel = StateObject(
            wrappedValue: SavedJobsViewModel(store: appContainer.savedJobsStore)
        )
    }

    var body: some View {
        ZStack {
            mainTabs
                .opacity(showLaunch ? 0 : 1)
            if showLaunch {
                LaunchView()
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .environment(\.appContainer, appContainer)
        .environmentObject(settings)
        .environmentObject(tabBarVisibility)
        .preferredColorScheme(settings.colorScheme)
        .task {
            try? await Task.sleep(for: .seconds(1.15))
            withAnimation(.spring(response: 0.55, dampingFraction: 0.88)) {
                showLaunch = false
            }
        }
    }

    private var mainTabs: some View {
        tabContent
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !tabBarVisibility.isHidden {
                    CustomTabBar(
                        selectedTab: Binding(
                            get: { selectedTab },
                            set: { tab in
                                visitedTabs.insert(tab)
                                selectedTab = tab
                            }
                        )
                    )
                    .padding(.horizontal, 22)
                    .padding(.top, 6)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.snappy(duration: 0.2), value: tabBarVisibility.isHidden)
    }

    private var tabContent: some View {
        ZStack {
            HomeView(viewModel: homeViewModel)
                .tabVisibility(.discover, selectedTab: selectedTab)

            if visitedTabs.contains(.search) {
                SearchView(viewModel: searchViewModel)
                    .tabVisibility(.search, selectedTab: selectedTab)
            }

            if visitedTabs.contains(.saved) {
                SavedJobsView(viewModel: savedJobsViewModel) {
                    visitedTabs.insert(.discover)
                    selectedTab = .discover
                }
                .tabVisibility(.saved, selectedTab: selectedTab)
            }

            if visitedTabs.contains(.profile) {
                ProfileSettingsView()
                    .tabVisibility(.profile, selectedTab: selectedTab)
            }
        }
    }
}

@MainActor
final class TabBarVisibilityController: ObservableObject {
    @Published var isHidden = false
}

private enum AppTab: Hashable {
    case discover
    case search
    case saved
    case profile

    var title: String {
        switch self {
        case .discover: "Discover"
        case .search: "Search"
        case .saved: "Saved"
        case .profile: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .discover: "sparkle.magnifyingglass"
        case .search: "magnifyingglass"
        case .saved: "bookmark.fill"
        case .profile: "person.crop.circle.fill"
        }
    }
}

private struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    private let tabs: [AppTab] = [.discover, .search, .saved, .profile]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(tabs, id: \.self) { tab in
                Button {
                    guard selectedTab != tab else {
                        return
                    }
                    selectedTab = tab
                    Haptics.selection()
                } label: {
                    let isSelected = selectedTab == tab
                    VStack(spacing: 3) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22, weight: .semibold))
                        Text(tab.title)
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(isSelected ? RemoteRecruitTheme.blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(RemoteRecruitTheme.blue.opacity(0.12))
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
            }
        }
        .padding(5)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule()
                .stroke(Color(.separator).opacity(0.18))
        }
        .shadow(color: Color.black.opacity(0.08), radius: 14, y: 6)
        .animation(.snappy(duration: 0.18), value: selectedTab)
    }
}

private extension View {
    func tabVisibility(_ tab: AppTab, selectedTab: AppTab) -> some View {
        opacity(selectedTab == tab ? 1 : 0)
            .allowsHitTesting(selectedTab == tab)
            .accessibilityHidden(selectedTab != tab)
    }
}

struct LaunchView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.01, green: 0.03, blue: 0.13),
                    Color(red: 0.03, green: 0.07, blue: 0.25),
                    Color(red: 0.09, green: 0.05, blue: 0.28)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            LaunchMapDots()
                .opacity(0.42)
                .offset(y: -130)

            VStack {
                Spacer(minLength: 70)

                BrandMark(size: 150, showsBadge: true)

                VStack(spacing: 8) {
                    HStack(spacing: 0) {
                        Text("Remote")
                            .foregroundStyle(.white)
                        Text("Recruit")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.34, green: 0.47, blue: 1.0), Color(red: 0.75, green: 0.22, blue: 1.0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                        .font(.system(.largeTitle, design: .rounded).weight(.black))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text("Find Jobs. Build Your Future.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.78))
                }
                .padding(.top, 10)

                Spacer()

                LaunchSkylineScene()
                    .frame(height: 210)
                    .padding(.bottom, 28)

                VStack(spacing: 12) {
                    ProgressView(value: 0.72)
                        .tint(Color(red: 0.0, green: 0.82, blue: 1.0))
                        .frame(width: 190)
                    Text("Loading your opportunities...")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.76))
                }
                .padding(.bottom, 42)
            }
            .padding(.horizontal, 28)
        }
    }
}

private struct LaunchSkylineScene: View {
    private let buildings: [LaunchBuilding] = [
        .init(width: 16, height: 58, style: .flat),
        .init(width: 24, height: 94, style: .spire),
        .init(width: 18, height: 70, style: .flat),
        .init(width: 30, height: 124, style: .slant),
        .init(width: 18, height: 82, style: .spire),
        .init(width: 26, height: 112, style: .flat),
        .init(width: 16, height: 62, style: .flat),
        .init(width: 34, height: 146, style: .spire),
        .init(width: 22, height: 96, style: .slant),
        .init(width: 16, height: 66, style: .flat),
        .init(width: 28, height: 118, style: .spire)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.49, blue: 0.18).opacity(0.7),
                    Color(red: 0.55, green: 0.19, blue: 1.0).opacity(0.42),
                    .clear
                ],
                center: .bottom,
                startRadius: 6,
                endRadius: 180
            )
            .frame(width: 300, height: 180)
            .offset(y: 26)

            HStack(alignment: .bottom, spacing: 5) {
                ForEach(buildings) { building in
                    LaunchBuildingView(building: building)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 4)

            VStack(spacing: 8) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.55),
                                Color(red: 0.53, green: 0.2, blue: 1.0).opacity(0.35),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 1)

                ForEach(0..<4, id: \.self) { index in
                    Capsule()
                        .fill(Color.cyan.opacity(0.16 - Double(index) * 0.025))
                        .frame(width: CGFloat(250 - index * 38), height: 2)
                }
            }
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.03, green: 0.06, blue: 0.22).opacity(0.2),
                        Color(red: 0.01, green: 0.02, blue: 0.1).opacity(0.92)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .offset(y: 28)

            LaunchSearchPlatform()
                .offset(y: 16)
        }
        .clipped()
        .accessibilityHidden(true)
    }
}

private struct LaunchBuilding: Identifiable {
    enum Style {
        case flat
        case spire
        case slant
    }

    let id = UUID()
    let width: CGFloat
    let height: CGFloat
    let style: Style
}

private struct LaunchBuildingView: View {
    let building: LaunchBuilding

    var body: some View {
        VStack(spacing: 0) {
            switch building.style {
            case .flat:
                EmptyView()
            case .spire:
                Triangle()
                    .fill(Color(red: 0.22, green: 0.27, blue: 0.78))
                    .frame(width: building.width * 0.78, height: 18)
            case .slant:
                SlantedRoof()
                    .fill(Color(red: 0.2, green: 0.25, blue: 0.72))
                    .frame(width: building.width, height: 16)
            }

            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.18, green: 0.19, blue: 0.62),
                            Color(red: 0.03, green: 0.04, blue: 0.18)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    LaunchWindows(width: building.width, height: building.height)
                }
                .frame(width: building.width, height: building.height)
        }
        .shadow(color: .cyan.opacity(0.14), radius: 8, x: 0, y: 0)
    }
}

private struct LaunchWindows: View {
    let width: CGFloat
    let height: CGFloat

    private var rows: Int {
        max(3, Int(height / 18))
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<max(1, Int(width / 9)), id: \.self) { column in
                        RoundedRectangle(cornerRadius: 1, style: .continuous)
                            .fill((row + column).isMultiple(of: 3) ? Color.cyan.opacity(0.72) : Color.white.opacity(0.12))
                            .frame(width: 2.4, height: 5)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 10)
    }
}

private struct LaunchSearchPlatform: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.11))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.55), Color.purple.opacity(0.44)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .frame(width: 176, height: 72)
                .rotation3DEffect(.degrees(58), axis: (x: 1, y: 0, z: 0))

            Image(systemName: "magnifyingglass")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, Color.cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .cyan.opacity(0.5), radius: 12, x: 0, y: 5)
                .offset(x: 72, y: -2)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct SlantedRoof: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct LaunchMapDots: View {
    var body: some View {
        Canvas { context, size in
            let color = Color.cyan.opacity(0.55)
            for row in 0..<28 {
                for col in 0..<54 {
                    let x = CGFloat(col) * size.width / 54
                    let y = CGFloat(row) * size.height / 28
                    let wave = sin(CGFloat(col) * 0.32) + cos(CGFloat(row) * 0.44)
                    guard wave > -0.2 else { continue }
                    let rect = CGRect(x: x, y: y, width: 2.2, height: 2.2)
                    context.fill(Path(ellipseIn: rect), with: .color(color))
                }
            }
        }
        .frame(height: 220)
    }
}

struct AppBackground: View {
    var body: some View {
        RemoteRecruitScreenBackground()
    }
}
