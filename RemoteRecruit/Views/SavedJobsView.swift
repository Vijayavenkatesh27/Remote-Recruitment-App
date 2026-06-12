import SwiftUI

struct SavedJobsView: View {
    @ObservedObject var viewModel: SavedJobsViewModel
    var browseJobs: () -> Void = {}

    var body: some View {
        SavedJobsContentView(viewModel: viewModel, browseJobs: browseJobs)
    }
}

private struct SavedJobsContentView: View {
    @ObservedObject var viewModel: SavedJobsViewModel
    @State private var selectedJob: Job?
    var browseJobs: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    savedHeader
                    content
                }
                .padding()
                .padding(.bottom, 28)
            }
            .background(AppBackground())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedJob) { JobDetailsView(job: $0) }
            .onAppear { viewModel.load() }
        }
    }

    private var savedHeader: some View {
        HStack(alignment: .center) {
            Text("Saved Jobs")
                .font(.largeTitle.weight(.black))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Spacer()

            if !viewModel.jobs.isEmpty {
                Button {
                    viewModel.clear()
                } label: {
                    Label("Clear", systemImage: "trash")
                        .font(.caption.weight(.bold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(RemoteRecruitTheme.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(RemoteRecruitTheme.elevatedSurface, in: Capsule())
                .overlay {
                    Capsule().stroke(Color(.separator).opacity(0.16))
                }
            }
        }
        .padding(.top, 8)
    }

    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .empty:
            EmptyStateView(
                systemImage: "bookmark",
                title: "No saved jobs",
                message: "Save roles you want to compare, revisit, or apply to later.",
                actionTitle: "Browse Jobs",
                action: browseJobs
            )
        case .failed(let message):
            ErrorStateView(message: message) { viewModel.load() }
        default:
            ForEach(viewModel.jobs) { job in
                JobCardView(
                    job: job,
                    isSaved: true,
                    onSave: {
                        withAnimation(.snappy) {
                            viewModel.delete(job)
                        }
                    },
                    onOpen: { selectedJob = job }
                )
                .contentShape(RoundedRectangle(cornerRadius: 8))
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }
}
