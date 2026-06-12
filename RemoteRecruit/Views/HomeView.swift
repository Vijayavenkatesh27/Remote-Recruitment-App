import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        HomeContentView(viewModel: viewModel)
    }
}

private struct HomeContentView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var selectedJob: Job?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    header
                    content
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 28)
            }
            .background(AppBackground())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .task { await viewModel.load() }
            .refreshable { await viewModel.refresh() }
            .navigationDestination(item: $selectedJob) { job in
                JobDetailsView(job: job)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            topBar
            HomeSearchBar(text: $viewModel.searchText)
            filterChips
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            BrandMark(size: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text("RemoteRecruit")
                    .font(.title3.weight(.black))
                    .foregroundStyle(RemoteRecruitTheme.navy)
                Text("Recruiter job discovery")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Label("Live", systemImage: "dot.radiowaves.left.and.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(RemoteRecruitTheme.green)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(RemoteRecruitTheme.green.opacity(0.14), in: Capsule())
                .overlay {
                    Capsule().stroke(RemoteRecruitTheme.green.opacity(0.18))
                }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                ForEach([JobFilter.all, .remote, .hybrid, .fullTime, .contract]) { filter in
                    Button {
                        viewModel.setFilter(filter)
                        Haptics.selection()
                    } label: {
                        let isSelected = viewModel.selectedFilter == filter
                        Label(filter.rawValue, systemImage: filter.icon)
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .foregroundStyle(isSelected ? .white : RemoteRecruitTheme.navy.opacity(0.78))
                            .background(isSelected ? RemoteRecruitTheme.blue : RemoteRecruitTheme.elevatedSurface, in: Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(isSelected ? RemoteRecruitTheme.blue : Color(.separator).opacity(0.16))
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .loading:
            ForEach(0..<5, id: \.self) { _ in SkeletonJobCardView() }
        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.refresh() }
            }
        case .empty:
            EmptyStateView(systemImage: "briefcase", title: "No roles found", message: "Refresh to fetch fresh opportunities.")
        default:
            sectionHeader(title: viewModel.selectedFilter == .all ? "Trending Jobs" : "\(viewModel.selectedFilter.rawValue) Jobs")
            if viewModel.visibleJobs.isEmpty {
                EmptyStateView(systemImage: "magnifyingglass", title: "No matching jobs", message: "Try a different keyword or filter.")
            } else {
                ForEach(viewModel.visibleJobs) { job in
                    JobCardView(
                        job: job,
                        isSaved: viewModel.savedIDs.contains(job.id),
                        onSave: { viewModel.toggleSaved(job) },
                        onOpen: { selectedJob = job }
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 8))
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .task {
                        await viewModel.loadMoreIfNeeded(currentJob: job)
                    }
                }
            }
        }
    }

    private func sectionHeader(title: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.weight(.black))
                .foregroundStyle(RemoteRecruitTheme.navy)
            Spacer()
        }
        .padding(.top, 2)
    }
}

private struct HomeSearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.headline.weight(.semibold))
                .foregroundStyle(RemoteRecruitTheme.cyan)
            TextField("Search title, company, or location", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .submitLabel(.search)
            if !text.isEmpty {
                Button {
                    withAnimation(.snappy) {
                        text = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard(cornerRadius: 12, opacity: 0.11)
    }
}
