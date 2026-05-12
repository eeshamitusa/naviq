import SwiftUI

struct SmartPlanResultsView: View {
    let startLocation: String
    let finalDestination: String
    let deadline: Date
    let budgetText: String
    let selectedTransport: String

    @StateObject private var viewModel = SmartPlanViewModel()

    private var budgetAUD: Double {
        let cleanedText = budgetText
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "AUD", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return Double(cleanedText) ?? 0
    }

    private var formattedDeadline: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: deadline)
    }

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.13)
                .ignoresSafeArea()

            if viewModel.isLoading {
                loadingView
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection

                        if let errorMessage = viewModel.errorMessage {
                            emptyStateView(message: errorMessage)
                        }

                        if let bestPlan = viewModel.bestPlan {
                            bestPlanSection(bestPlan)
                        }

                        if !viewModel.results.isEmpty {
                            allPlansSection
                        }
                    }
                    .padding(24)
                }
            }
        }
        .navigationTitle("Smart Plans")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await viewModel.findSmartPlans(
                currentLocationName: startLocation,
                finalDestinationName: finalDestination,
                totalBudget: budgetAUD,
                mustArriveTime: deadline,
                selectedTransport: selectedTransport
            )
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color(red: 0.6, green: 0.4, blue: 1.0))
                .scaleEffect(1.4)

            Text("Finding smart midpoint plans...")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Checking what fits before \(formattedDeadline)")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .padding()
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SMART PLANNING RESULTS")
                .font(.system(size: 11, weight: .bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color(red: 0.6, green: 0.4, blue: 1.0))
                .foregroundStyle(.white)
                .clipShape(Capsule())

            Text("Midpoints you can visit")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            Text("\(startLocation) → Midpoint → \(finalDestination)")
                .font(.subheadline)
                .foregroundStyle(.gray)

            HStack(spacing: 10) {
                SmartPlanSummaryPill(
                    iconName: "clock.fill",
                    title: "Arrive by",
                    value: formattedDeadline
                )

                SmartPlanSummaryPill(
                    iconName: "dollarsign.circle.fill",
                    title: "Budget",
                    value: String(format: "AUD %.2f", budgetAUD)
                )
            }

            SmartPlanSummaryPill(
                iconName: "tram.fill",
                title: "Transport",
                value: selectedTransport
            )
        }
        .padding(18)
        .background(Color(red: 0.1, green: 0.13, blue: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func bestPlanSection(_ plan: SmartPlanResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Best Smart Plan")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Spacer()

                Text("BEST PICK")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.yellow.opacity(0.9))
                    .foregroundStyle(.black)
                    .clipShape(Capsule())
            }

            NavigationLink {
                SmartPlanJourneyView(
                    plan: plan,
                    startLocation: startLocation,
                    finalDestination: finalDestination,
                    deadline: deadline
                )
            } label: {
                SmartPlanCard(plan: plan, isBestPick: true)
            }
            .buttonStyle(.plain)
        }
    }

    private var allPlansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Midpoint Options")
                .font(.title3.bold())
                .foregroundStyle(.white)

            ForEach(viewModel.results) { plan in
                NavigationLink {
                    SmartPlanJourneyView(
                        plan: plan,
                        startLocation: startLocation,
                        finalDestination: finalDestination,
                        deadline: deadline
                    )
                } label: {
                    SmartPlanCard(
                        plan: plan,
                        isBestPick: plan.id == viewModel.bestPlan?.id
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(Color(red: 0.6, green: 0.4, blue: 1.0))

            Text("No smart plan found")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)

            Text("For the demo, try Darling Harbour → Parramatta, budget 75, transport Any, and a later arrival time.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(red: 0.1, green: 0.13, blue: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct SmartPlanCard: View {
    let plan: SmartPlanResult
    let isBestPick: Bool

    private var feasibilityColor: Color {
        if plan.feasibilityLabel == "Yes" {
            return .green
        } else if plan.feasibilityLabel == "Risky" {
            return .orange
        } else {
            return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            topRow

            HStack(spacing: 10) {
                SmartPlanStatBox(
                    iconName: "clock.fill",
                    title: "Total time",
                    value: plan.formattedTotalTime
                )

                SmartPlanStatBox(
                    iconName: "dollarsign.circle.fill",
                    title: "Total cost",
                    value: plan.formattedTotalCost
                )
            }

            HStack(spacing: 10) {
                SmartPlanStatBox(
                    iconName: "hourglass.bottomhalf.filled",
                    title: "Free time at midpoint",
                    value: plan.formattedRemainingTime
                )

                SmartPlanStatBox(
                    iconName: "banknote.fill",
                    title: "Budget left",
                    value: plan.formattedRemainingBudget
                )
            }

            routeBreakdown

            Text("Tap to start this smart journey.")
                .font(.caption.bold())
                .foregroundStyle(Color(red: 0.75, green: 0.62, blue: 1.0))

            if !plan.midpoint.tags.isEmpty {
                tagSection
            }

            Text(plan.feasibilityExplanation)
                .font(.caption)
                .foregroundStyle(.gray)

            if isBestPick {
                Text("Recommended because it gives the strongest balance of time buffer, budget buffer, and destination value.")
                    .font(.caption)
                    .foregroundStyle(Color(red: 0.75, green: 0.62, blue: 1.0))
            }
        }
        .padding(18)
        .background(Color(red: 0.1, green: 0.13, blue: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isBestPick ? Color(red: 0.6, green: 0.4, blue: 1.0) : Color.white.opacity(0.06),
                    lineWidth: isBestPick ? 1.5 : 1
                )
        )
    }

    private var topRow: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.2))
                    .frame(width: 46, height: 46)

                Image(systemName: "mappin.and.ellipse")
                    .font(.title3)
                    .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(plan.midpoint.name)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(plan.midpoint.shortDescription)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(2)
            }

            Spacer()

            Text(plan.feasibilityLabel)
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(feasibilityColor.opacity(0.18))
                .foregroundStyle(feasibilityColor)
                .clipShape(Capsule())
        }
    }

    private var routeBreakdown: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Route breakdown")
                .font(.subheadline.bold())
                .foregroundStyle(.white)

            SmartPlanRouteLegRow(
                title: "Start to midpoint",
                fromName: plan.firstLegRoute.steps.first?.fromName ?? "Start",
                toName: plan.midpoint.name,
                modeIcon: plan.firstLegRoute.primaryTransportMode.iconName,
                modeName: plan.firstLegRoute.primaryTransportMode.displayName,
                time: plan.firstLegRoute.formattedTravelTime,
                cost: plan.firstLegRoute.formattedCost
            )

            SmartPlanRouteLegRow(
                title: "Midpoint to final",
                fromName: plan.midpoint.name,
                toName: plan.secondLegRoute.destination.name,
                modeIcon: plan.secondLegRoute.primaryTransportMode.iconName,
                modeName: plan.secondLegRoute.primaryTransportMode.displayName,
                time: plan.secondLegRoute.formattedTravelTime,
                cost: plan.secondLegRoute.formattedCost
            )
        }
        .padding(14)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var tagSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(plan.midpoint.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.18))
                        .foregroundStyle(Color(red: 0.78, green: 0.67, blue: 1.0))
                        .clipShape(Capsule())
                }
            }
        }
    }
}

private struct SmartPlanSummaryPill: View {
    let iconName: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.gray)

                Text(value)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.12, green: 0.16, blue: 0.24))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct SmartPlanStatBox: View {
    let iconName: String
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: iconName)
                .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))

            Text(title)
                .font(.caption2)
                .foregroundStyle(.gray)

            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(red: 0.12, green: 0.16, blue: 0.24))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct SmartPlanRouteLegRow: View {
    let title: String
    let fromName: String
    let toName: String
    let modeIcon: String
    let modeName: String
    let time: String
    let cost: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: modeIcon)
                .font(.subheadline)
                .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.white)

                Text("\(fromName) → \(toName)")
                    .font(.caption)
                    .foregroundStyle(.gray)

                Text("\(modeName) • \(time) • \(cost)")
                    .font(.caption2)
                    .foregroundStyle(.gray.opacity(0.9))
            }

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        SmartPlanResultsView(
            startLocation: "Darling Harbour",
            finalDestination: "Parramatta",
            deadline: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date(),
            budgetText: "75",
            selectedTransport: "Any"
        )
    }
}
