import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        SearchContentView(viewModel: viewModel)
    }
}

private struct SearchContentView: View {
    @ObservedObject var viewModel: SearchViewModel
    @State private var searchText = ""
    @State private var selectedJob: Job?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    searchHeader
                    if shouldShowSuggestions {
                        suggestions
                    }
                    filters
                    results
                }
                .padding()
                .padding(.bottom, 28)
            }
            .background(AppBackground())
            .toolbar(.hidden, for: .navigationBar)
            .task { await viewModel.loadInitialJobs() }
            .navigationDestination(item: $selectedJob) { JobDetailsView(job: $0) }
        }
    }

    private var searchHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Search Jobs")
                .font(.largeTitle.weight(.black))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.secondary)
                TextField("Title, company, skill, location", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .submitLabel(.search)
                    .onSubmit {
                        viewModel.updateQuery(searchText, debounce: false)
                        viewModel.submitSearch(searchText)
                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        Task { await viewModel.clearQuery() }
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
        .padding(.top, 8)
        .onChange(of: searchText) { _, newValue in
            viewModel.updateQuery(newValue)
        }
    }

    private var suggestions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Suggestions")
                .font(.headline)
                .foregroundStyle(.primary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    let chips = viewModel.suggestions
                    ForEach(Array(chips.prefix(8)), id: \.self) { suggestion in
                        Button {
                            searchText = suggestion
                            viewModel.updateQuery(suggestion, debounce: false)
                            viewModel.submitSearch(suggestion)
                        } label: {
                            Label(suggestion, systemImage: "magnifyingglass")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.primary.opacity(0.84))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 8)
                        .background(RemoteRecruitTheme.elevatedSurface, in: Capsule())
                        .overlay {
                            Capsule().stroke(Color(.separator).opacity(0.16))
                        }
                    }
                }
            }
        }
    }

    private var shouldShowSuggestions: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !viewModel.suggestions.isEmpty
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach([JobFilter.all, .remote, .hybrid, .fullTime, .contract]) { filter in
                    Button {
                        viewModel.setFilter(filter)
                        Haptics.selection()
                    } label: {
                        let isSelected = viewModel.selectedFilter == filter
                        Label(filter.rawValue, systemImage: filter.icon)
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 11)
                            .padding(.vertical, 8)
                            .background(isSelected ? RemoteRecruitTheme.blue : RemoteRecruitTheme.elevatedSurface, in: Capsule())
                            .foregroundStyle(isSelected ? .white : RemoteRecruitTheme.navy.opacity(0.78))
                            .overlay {
                                Capsule().stroke(isSelected ? RemoteRecruitTheme.blue : Color(.separator).opacity(0.16))
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder private var results: some View {
        switch viewModel.state {
        case .idle:
            EmptyStateView(systemImage: "sparkle.magnifyingglass", title: "Find your next remote role", message: "Search by keyword, location, company, or technology.")
        case .loading:
            ForEach(0..<4, id: \.self) { _ in SkeletonJobCardView() }
        case .empty:
            EmptyStateView(systemImage: "tray", title: "No matches", message: "Try a broader keyword or another technology.")
        case .failed(let message):
            ErrorStateView(message: message) {}
        case .success:
            if viewModel.visibleResults.isEmpty {
                EmptyStateView(systemImage: "line.3.horizontal.decrease.circle", title: "No jobs for this filter", message: "Try All or another work type to see more roles.")
            } else {
                ForEach(viewModel.visibleResults) { job in
                    JobCardView(
                        job: job,
                        isSaved: viewModel.savedIDs.contains(job.id),
                        onSave: { viewModel.toggleSaved(job) },
                        onOpen: { selectedJob = job }
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}
