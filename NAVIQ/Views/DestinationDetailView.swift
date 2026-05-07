import SwiftUI

struct DestinationDetailView: View {
    let route: RouteResult

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.13).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    statPillsSection
                    costTimeSummarySection
                    routeBreakdownSection
                    startTripButton
                }
                .padding()
            }
        }
        .navigationTitle(route.destination.name)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: route.destination.category.iconName)
                    .font(.title2)
                    .foregroundStyle(.blue)

                Text(route.destination.category.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                Spacer()

                Text(route.isLiveData ? "NSW API" : "Mock")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(route.isLiveData ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                    .foregroundStyle(route.isLiveData ? .green : .orange)
                    .clipShape(Capsule())
            }

            Text(route.destination.name)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text(route.destination.shortDescription)
                .font(.body)
                .foregroundStyle(.white)

            Label(route.destination.streetAddress, systemImage: "mappin.and.ellipse")
                .font(.subheadline)
                .foregroundStyle(.white)

            tagRow
        }
    }

    private var tagRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(route.destination.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.12, green: 0.16, blue: 0.24))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Stat pills

    private var statPillsSection: some View {
        HStack(spacing: 10) {
            DetailStatPill(
                title: "Time",
                value: route.formattedTravelTime,
                iconName: "clock.fill"
            )

            DetailStatPill(
                title: "Cost",
                value: route.formattedCost,
                iconName: "dollarsign.circle.fill"
            )

            DetailStatPill(
                title: "Mode",
                value: route.primaryTransportMode.displayName,
                iconName: route.primaryTransportMode.iconName
            )
        }
    }

    // MARK: - Summary

    private var costTimeSummarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cost and time summary")
                .font(.headline)
                .foregroundStyle(.white)

            HStack {
                SummaryLine(label: "Estimated travel time", value: route.formattedTravelTime).foregroundStyle(.white)
                Spacer()
            }

            HStack {
                SummaryLine(label: "Estimated transport cost", value: route.formattedCost).foregroundStyle(.white)
                Spacer()
            }

            HStack {
                SummaryLine(label: "Route steps", value: "\(route.steps.count)").foregroundStyle(.white)
                Spacer()
            }
        }
        .padding()
        .background(Color(red: 0.12, green: 0.16, blue: 0.24))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Route breakdown

    private var routeBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Route breakdown")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(route.steps) { step in
                RouteStepRow(step: step)
            }
        }
    }

    // MARK: - Start trip

    private var startTripButton: some View {
        NavigationLink {
            RouteScreenView(route: route)
        } label: {
            HStack {
                Image(systemName: "location.fill")
                Text("Start Trip")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.top, 6)
    }
}

private struct DetailStatPill: View {
    let title: String
    let value: String
    let iconName: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(.blue)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(title)
                .font(.caption)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(red: 0.12, green: 0.16, blue: 0.24))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct SummaryLine: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
        }
    }
}

private struct RouteStepRow: View {
    let step: RouteStep

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 6) {
                Text("\(step.order)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(Color.blue)
                    .clipShape(Circle())

                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 2)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: step.mode.iconName)
                        .foregroundStyle(.blue)

                    Text(step.mode.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.gray)

                    if let lineName = step.lineName {
                        Text(lineName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(red: 0.12, green: 0.16, blue: 0.24))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }

                Text(step.instruction)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                Text("\(step.fromName) → \(step.toName)")
                    .font(.caption)
                    .foregroundStyle(.white)

                Text("\(step.durationMinutes) min")
                    .font(.caption)
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 12)
        }
    }
}

#Preview {
    NavigationStack {
        DestinationDetailView(route: MockData.allRoutes[6])
    }
}
