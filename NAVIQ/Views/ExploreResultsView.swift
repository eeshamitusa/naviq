import SwiftUI

struct ExploreResultsView: View {

    @StateObject private var viewModel = ExploreViewModel()

    private let startLocationName = "Darling Harbour"
    private let userTimeMinutes = 120
    private let budget = 20.00

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                statusSection

                if viewModel.isLoading {
                    loadingSection
                } else if let errorMessage = viewModel.errorMessage {
                    errorSection(errorMessage)
                } else if viewModel.groupedResults().isEmpty {
                    emptySection
                } else {
                    resultsList
                }
            }
            .navigationTitle("Explore")
            .task {
                await loadRoutes()
            }
        }
    }

    // MARK: - Status Section

    private var statusSection: some View {
        HStack(spacing: 12) {
            if viewModel.isLoading {
                ProgressView()
            }

            Text(statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
    }

    private var statusMessage: String {
        if viewModel.isLoading {
            return "Loading routes..."
        }

        let allRoutes = viewModel.quickTripRoutes
            + viewModel.bestLeisureRoutes
            + viewModel.longerTripRoutes
            + viewModel.dayTripRoutes

        if allRoutes.isEmpty {
            return "No route data loaded yet."
        }

        let hasLiveData = allRoutes.contains { route in
            route.isLiveData
        }

        return hasLiveData
            ? "Showing NSW API route results."
            : "Showing mock fallback route results."
    }

    // MARK: - Results List

    private var resultsList: some View {
        List {
            ForEach(viewModel.groupedResults()) { group in
                Section {
                    ForEach(group.routes) { route in
                        NavigationLink {
                            DestinationDetailView(route: route)
                        } label: {
                            RouteResultRow(
                                route: route,
                                isBestPick: group.bestRoutePick?.id == route.id
                            )
                        }
                    }
                } header: {
                    Text(group.title)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Loading / Empty / Error

    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Finding destinations that match your time and budget...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptySection: some View {
        VStack(spacing: 16) {
            Image(systemName: "map")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No matching destinations")
                .font(.headline)

            Text("Try increasing your available time or budget.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await loadRoutes()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorSection(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text("Something went wrong")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                Task {
                    await loadRoutes()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Load

    private func loadRoutes() async {
        await viewModel.findReachableDestinations(
            startLocationName: startLocationName,
            userTimeMinutes: userTimeMinutes,
            budget: budget
        )
    }
}

// MARK: - Route Result Row

private struct RouteResultRow: View {

    let route: RouteResult
    let isBestPick: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerSection
            statPillsSection
            highlightsSection
            dataSourceSection
        }
        .padding(.vertical, 6)
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(route.destination.name)
                    .font(.headline)

                Text(route.destination.streetAddress)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            if isBestPick {
                Text("Best Pick")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.15))
                    .foregroundStyle(.purple)
                    .clipShape(Capsule())
            }
        }
    }

    private var statPillsSection: some View {
        HStack(spacing: 8) {
            SmallStatPill(
                icon: "clock",
                text: route.formattedTravelTime
            )

            SmallStatPill(
                icon: "dollarsign.circle",
                text: route.formattedCost
            )

            SmallStatPill(
                icon: route.primaryTransportMode.iconName,
                text: route.primaryTransportMode.displayName
            )
        }
    }

    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(route.destination.tags.prefix(2), id: \.self) { tag in
                Text("• \(tag)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var dataSourceSection: some View {
        Text(route.isLiveData ? "NSW API result" : "Mock fallback result")
            .font(.caption2)
            .foregroundStyle(route.isLiveData ? .green : .secondary)
    }
}

// MARK: - Small Stat Pill

private struct SmallStatPill: View {

    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}

#Preview {
    ExploreResultsView()
}
