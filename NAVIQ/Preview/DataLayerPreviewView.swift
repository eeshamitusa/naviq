//
//  DataLayerPreviewView.swift
//  NAVIQ
//
//  Debug view to verify the data layer works correctly.
//  This is NOT Aneet's production UI — it's a temporary preview for Seungmin's data layer.
//

import SwiftUI

struct DataLayerPreviewView: View {

    @State private var availableMinutes: Double = 60
    @State private var budgetDollars: Double = 10
    @State private var routes: [RouteResult] = []
    @State private var isLoading = false

    private let service: TransportServiceProtocol = TransportService(useMockOnly: true)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                inputSection
                Divider()
                statsSection
                Divider()
                resultsList
            }
            .navigationTitle("Data Layer Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await reload() }
    }

    // MARK: - Input Controls

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Origin: UTS Tower")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Time available: \(Int(availableMinutes)) min")
                    .font(.caption)
                Slider(value: $availableMinutes, in: 5...150, step: 5) {
                    Text("Time")
                }
                .onChange(of: availableMinutes) { _, _ in
                    Task { await reload() }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Budget: $\(Int(budgetDollars))")
                    .font(.caption)
                Slider(value: $budgetDollars, in: 0...20, step: 1) {
                    Text("Budget")
                }
                .onChange(of: budgetDollars) { _, _ in
                    Task { await reload() }
                }
            }
        }
        .padding()
    }

    // MARK: - Stats Bar

    private var statsSection: some View {
        HStack(spacing: 20) {
            StatBadge(label: "Found", value: "\(routes.count)/30")
            StatBadge(label: "Quick", value: "\(quickCount)")
            StatBadge(label: "Leisure", value: "\(leisureCount)")
            StatBadge(label: "Longer", value: "\(longerCount)")
            StatBadge(label: "Day Trip", value: "\(dayTripCount)")
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
    }

    private var quickCount: Int   { routes.filter { $0.travelTimeMinutes <= 30 }.count }
    private var leisureCount: Int { routes.filter { $0.travelTimeMinutes > 30 && $0.travelTimeMinutes <= 60 }.count }
    private var longerCount: Int  { routes.filter { $0.travelTimeMinutes > 60 && $0.travelTimeMinutes <= 90 }.count }
    private var dayTripCount: Int { routes.filter { $0.travelTimeMinutes > 90 }.count }

    // MARK: - Results List

    private var resultsList: some View {
        Group {
            if isLoading {
                ProgressView("Loading routes...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if routes.isEmpty {
                ContentUnavailableView(
                    "No matches",
                    systemImage: "magnifyingglass",
                    description: Text("Try increasing the time or budget.")
                )
            } else {
                List(routes.sorted { $0.travelTimeMinutes < $1.travelTimeMinutes }) { route in
                    RoutePreviewRow(route: route)
                }
                .listStyle(.plain)
            }
        }
    }

    // MARK: - Logic

    private func reload() async {
        isLoading = true
        let input = ExploreInput(
            originName: "UTS Tower",
            originCoordinate: MockData.mockOrigin,
            availableTimeMinutes: Int(availableMinutes),
            budgetAUD: budgetDollars
        )
        let result = await service.searchRoutes(input: input)
        await MainActor.run {
            routes = result
            isLoading = false
        }
    }
}

// MARK: - Sub Views

private struct StatBadge: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

private struct RoutePreviewRow: View {
    let route: RouteResult

    var body: some View {
        HStack(spacing: 12) {
            // Category + transport icons
            VStack(spacing: 6) {
                Image(systemName: route.destination.category.iconName)
                    .font(.title2)
                    .foregroundStyle(.blue)
                Image(systemName: route.primaryTransportMode.iconName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 36)

            // Name + tags
            VStack(alignment: .leading, spacing: 4) {
                Text(route.destination.name)
                    .font(.headline)

                HStack(spacing: 4) {
                    ForEach(route.destination.tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                }

                Text(route.destination.category.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Time + cost
            VStack(alignment: .trailing, spacing: 4) {
                Text(route.formattedTravelTime)
                    .font(.subheadline.bold())
                Text(route.formattedCost)
                    .font(.caption)
                    .foregroundStyle(route.costAUD == 0 ? .green : .secondary)

                if route.steps.count > 1 {
                    Text("\(route.steps.count) steps")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview("Data Layer Preview") {
    DataLayerPreviewView()
}
