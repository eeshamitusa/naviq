import SwiftUI

@MainActor
struct ExploreResultsView: View {

    @StateObject private var viewModel: ExploreViewModel

    let startLocationName: String
    let userTimeMinutes: Int
    let budget: Double
    let selectedTransport: String

    init(
        startLocationName: String,
        userTimeMinutes: Int,
        budget: Double,
        selectedTransport: String
    ) {
        self.startLocationName = startLocationName
        self.userTimeMinutes = userTimeMinutes
        self.budget = budget
        self.selectedTransport = selectedTransport
        _viewModel = StateObject(wrappedValue: ExploreViewModel())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor

                VStack(spacing: 0) {
                    statusSection
                    contentSection
                }
            }
            .navigationTitle("Explore")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await loadRoutes()
            }
        }
    }

    // MARK: - Main Content

    private var contentSection: some View {
        Group {
            if viewModel.isLoading {
                loadingSection
            } else if let errorMessage = viewModel.errorMessage {
                errorSection(errorMessage)
            } else if destinationGroups.isEmpty {
                emptySection
            } else {
                resultsList(groups: destinationGroups)
            }
        }
    }

    private var destinationGroups: [DestinationGroup] {
        var groups: [DestinationGroup] = []

        if !viewModel.quickTripRoutes.isEmpty {
            groups.append(
                DestinationGroup(
                    title: "Quick Trips",
                    routes: viewModel.quickTripRoutes,
                    bestRoutePick: viewModel.quickTripBestRoute
                )
            )
        }

        if !viewModel.bestLeisureRoutes.isEmpty {
            groups.append(
                DestinationGroup(
                    title: "Best Leisure",
                    routes: viewModel.bestLeisureRoutes,
                    bestRoutePick: viewModel.bestLeisureRoutePick
                )
            )
        }

        if !viewModel.longerTripRoutes.isEmpty {
            groups.append(
                DestinationGroup(
                    title: "Longer Trips",
                    routes: viewModel.longerTripRoutes,
                    bestRoutePick: viewModel.longerTripBestRoute
                )
            )
        }

        if !viewModel.dayTripRoutes.isEmpty {
            groups.append(
                DestinationGroup(
                    title: "Day Trips",
                    routes: viewModel.dayTripRoutes,
                    bestRoutePick: viewModel.dayTripBestRoute
                )
            )
        }

        return groups
    }

    private var backgroundColor: some View {
        Color(red: 0.07, green: 0.09, blue: 0.13)
            .ignoresSafeArea()
    }

    // MARK: - Status Section

    private var statusSection: some View {
        HStack(spacing: 12) {
            if viewModel.isLoading {
                ProgressView()
            }

            Text(statusMessage)
                .font(.caption)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(red: 0.07, green: 0.09, blue: 0.13))
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

        if hasLiveData {
            return "Showing NSW API route results."
        } else {
            return "Showing mock fallback route results."
        }
    }

    // MARK: - Results List

    private func resultsList(groups: [DestinationGroup]) -> some View {
        List {
            ForEach(groups, id: \.title) { group in
                resultSection(group)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(red: 0.07, green: 0.09, blue: 0.13))
    }

    private func resultSection(_ group: DestinationGroup) -> some View {
        Section {
            ForEach(group.routes, id: \.destination.name) { route in
                resultRow(
                    route: route,
                    bestRoutePick: group.bestRoutePick
                )
            }
        } header: {
            sectionHeader(title: group.title)
        }
        .listRowBackground(Color.clear)
    }

    private func resultRow(
        route: RouteResult,
        bestRoutePick: RouteResult?
    ) -> some View {
        let isBestPick = bestRoutePick?.destination.name == route.destination.name

        return NavigationLink {
            DestinationDetailView(route: route)
        } label: {
            RouteResultRow(
                route: route,
                isBestPick: isBestPick
            )
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(
            EdgeInsets(
                top: 4,
                leading: 16,
                bottom: 4,
                trailing: 16
            )
        )
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
            .foregroundStyle(.white)
            .font(.system(size: 13, weight: .bold))
            .textCase(nil)
    }

    // MARK: - Loading / Empty / Error

    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Finding destinations that match your time and budget...")
                .font(.subheadline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptySection: some View {
        VStack(spacing: 16) {
            Image(systemName: "map")
                .font(.largeTitle)
                .foregroundStyle(.white)

            Text("No matching destinations")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Try increasing your available time or budget.")
                .font(.subheadline)
                .foregroundStyle(.white)
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
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white)
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
            budget: budget,
            selectedTransport: selectedTransport
        )
    }
}

// MARK: - Route Result Row

private struct RouteResultRow: View {
    let route: RouteResult
    let isBestPick: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            bestPickBadge

            HStack(alignment: .top) {
                routeTextSection

                Spacer()

                routeCostSection
            }
        }
        .padding(16)
        .background(cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(cardBorder)
    }

    private var bestPickBadge: some View {
        Group {
            if isBestPick {
                Text("BEST PICK")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.2, green: 0.6, blue: 1.0))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var routeTextSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(route.destination.name)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            Text(route.primaryTransportMode.displayName)
                .font(.caption)
                .foregroundStyle(.gray)

            HStack(spacing: 4) {
                ForEach(Array(route.destination.tags.prefix(2)), id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        }
    }

    private var routeCostSection: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(route.formattedCost)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.green)

            Text(route.formattedTravelTime)
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }

    private var cardBackgroundColor: Color {
        if isBestPick {
            return Color(red: 0.1, green: 0.18, blue: 0.28)
        } else {
            return Color(red: 0.1, green: 0.13, blue: 0.19)
        }
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(
                isBestPick
                    ? Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.5)
                    : Color.clear,
                lineWidth: 1
            )
    }
}

#Preview {
    ExploreResultsView(
        startLocationName: "Darling Harbour",
        userTimeMinutes: 120,
        budget: 20.00,
        selectedTransport: "Any"
    )
}
