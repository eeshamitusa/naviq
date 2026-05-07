import SwiftUI

struct ExploreResultsView: View {

    @StateObject private var viewModel = ExploreViewModel()

    let startLocationName: String
    let userTimeMinutes: Int
    let budget: Double
    let selectedTransport: String

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.09, blue: 0.13).ignoresSafeArea()
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
                .toolbarColorScheme(.dark, for: .navigationBar)
                .task {
                    await loadRoutes()
                }
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
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                } header: {
                    Text(group.title)
                        .foregroundStyle(.white)
                        .font(.system(size: 13, weight: .bold))
                        .textCase(nil)
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(red: 0.07, green: 0.09, blue: 0.13))
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
            if isBestPick {
                Text("BEST PICK")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.2, green: 0.6, blue: 1.0))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(route.destination.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    Text(route.primaryTransportMode.displayName)
                        .font(.caption)
                        .foregroundStyle(.gray)
                    HStack(spacing: 4) {
                        ForEach(route.destination.tags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(route.formattedCost)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.green)
                    Text(route.formattedTravelTime)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding(16)
        .background(isBestPick
            ? Color(red: 0.1, green: 0.18, blue: 0.28)
            : Color(red: 0.1, green: 0.13, blue: 0.19))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isBestPick
                    ? Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.5)
                    : Color.clear, lineWidth: 1)
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
