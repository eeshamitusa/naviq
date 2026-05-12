import SwiftUI

struct SmartPlanInputView: View {
    @State private var currentLocation: String = ""
    @State private var finalDestination: String = ""
    @State private var deadline: Date = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var budgetValue: Double = 75
    @State private var selectedTransport: String = "Any"

    private let transportOptions = ["Any", "Train", "Bus", "Ferry", "Walk"]

    private let knownLocations = [
        "Circular Quay",
        "Bondi Beach",
        "Manly",
        "Newtown",
        "Chatswood",
        "Parramatta",
        "Darling Harbour",
        "Barangaroo",
        "The Rocks",
        "Cronulla",
        "Watsons Bay",
        "Taronga Zoo Sydney",
        "Mosman",
        "Sydney Olympic Park",
        "Katoomba",
        "Central Station",
        "UTS Broadway",
        "Coogee Beach",
        "Surry Hills",
        "Glebe",
        "Rhodes",
        "Strathfield",
        "Hornsby",
        "Penrith",
        "Liverpool"
    ]

    private var currentSuggestions: [String] {
        suggestions(for: currentLocation)
    }

    private var finalSuggestions: [String] {
        suggestions(for: finalDestination)
    }

    private var isCurrentValid: Bool {
        isKnownLocation(currentLocation)
    }

    private var isFinalValid: Bool {
        isKnownLocation(finalDestination)
    }

    private var isDifferentLocation: Bool {
        currentLocation.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() !=
        finalDestination.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var isFormValid: Bool {
        isCurrentValid && isFinalValid && isDifferentLocation && budgetValue > 0
    }

    private var budgetText: String {
        String(Int(budgetValue))
    }

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.13)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    journeyBanner
                    currentLocationSection
                    finalDestinationSection
                    deadlineSection
                    budgetSliderSection
                    transportSection
                    validationHint
                    findButton
                }
                .padding(24)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SMART PLANNING")
                .font(.system(size: 11, weight: .bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color(red: 0.6, green: 0.4, blue: 1.0))
                .foregroundStyle(.white)
                .clipShape(Capsule())

            Text("Plan your journey")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            Text("Find a midpoint you can visit before reaching your final destination on time.")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
    }

    private var journeyBanner: some View {
        HStack(spacing: 8) {
            JourneyStep(title: "Start", isHighlighted: false)

            Image(systemName: "arrow.right")
                .foregroundStyle(.gray)

            JourneyStep(title: "Midpoint?", isHighlighted: true)

            Image(systemName: "arrow.right")
                .foregroundStyle(.gray)

            JourneyStep(title: "Final", isHighlighted: false)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.1, green: 0.13, blue: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var currentLocationSection: some View {
        SmartPlanLocationInputSection(
            title: "CURRENT LOCATION",
            iconName: "location.circle.fill",
            placeholder: "e.g. Darling Harbour",
            text: $currentLocation,
            suggestions: currentSuggestions,
            isValid: isCurrentValid,
            onSelectSuggestion: { suggestion in
                currentLocation = suggestion
            }
        )
    }

    private var finalDestinationSection: some View {
        SmartPlanLocationInputSection(
            title: "FINAL DESTINATION",
            iconName: "mappin.circle.fill",
            placeholder: "e.g. Parramatta",
            text: $finalDestination,
            suggestions: finalSuggestions,
            isValid: isFinalValid,
            onSelectSuggestion: { suggestion in
                finalDestination = suggestion
            }
        )
    }

    private var deadlineSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MUST ARRIVE BY")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
                .tracking(1.2)

            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))

                DatePicker(
                    "",
                    selection: $deadline,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .colorScheme(.dark)

                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.12, green: 0.16, blue: 0.24))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var budgetSliderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TOTAL BUDGET")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
                    .tracking(1.2)

                Spacer()

                Text("AUD \(Int(budgetValue))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 10) {
                Slider(
                    value: $budgetValue,
                    in: 5...150,
                    step: 5
                )
                .tint(Color(red: 0.6, green: 0.4, blue: 1.0))

                HStack {
                    Text("AUD 5")
                    Spacer()
                    Text("AUD 150")
                }
                .font(.caption)
                .foregroundStyle(.gray)
            }
            .padding(16)
            .background(Color(red: 0.12, green: 0.16, blue: 0.24))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var transportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TRANSPORT PREFERENCE")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
                .tracking(1.2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(transportOptions, id: \.self) { option in
                        Button {
                            selectedTransport = option
                        } label: {
                            Text(option)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    selectedTransport == option
                                    ? Color(red: 0.6, green: 0.4, blue: 1.0)
                                    : Color(red: 0.12, green: 0.16, blue: 0.24)
                                )
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var validationHint: some View {
        Group {
            if !currentLocation.isEmpty && !isCurrentValid {
                HintRow(text: "Choose a current location from the suggestions.")
            } else if !finalDestination.isEmpty && !isFinalValid {
                HintRow(text: "Choose a final destination from the supported locations.")
            } else if isCurrentValid && isFinalValid && !isDifferentLocation {
                HintRow(text: "Current location and final destination must be different.")
            }
        }
    }

    private var findButton: some View {
        NavigationLink(
            destination: SmartPlanResultsView(
                startLocation: currentLocation,
                finalDestination: finalDestination,
                deadline: deadline,
                budgetText: budgetText,
                selectedTransport: selectedTransport
            )
        ) {
            HStack {
                Text("Find Midpoint Destinations")
                    .font(.system(size: 17, weight: .bold))

                Text("→")
                    .font(.system(size: 17, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(18)
            .background(
                isFormValid
                ? Color(red: 0.6, green: 0.4, blue: 1.0)
                : Color(red: 0.3, green: 0.2, blue: 0.5)
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(!isFormValid)
        .padding(.top, 8)
    }

    private func suggestions(for text: String) -> [String] {
        let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard cleanedText.count >= 1 else {
            return []
        }

        if isKnownLocation(cleanedText) {
            return []
        }

        return knownLocations
            .filter { location in
                location.lowercased().contains(cleanedText.lowercased())
            }
            .prefix(5)
            .map { $0 }
    }

    private func isKnownLocation(_ text: String) -> Bool {
        knownLocations.contains { location in
            location.lowercased() == text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }
    }
}

private struct JourneyStep: View {
    let title: String
    let isHighlighted: Bool

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(isHighlighted ? Color(red: 0.75, green: 0.62, blue: 1.0) : .white)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background(
                isHighlighted
                ? Color(red: 0.2, green: 0.15, blue: 0.35)
                : Color(red: 0.15, green: 0.2, blue: 0.3)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct SmartPlanLocationInputSection: View {
    let title: String
    let iconName: String
    let placeholder: String
    @Binding var text: String
    let suggestions: [String]
    let isValid: Bool
    let onSelectSuggestion: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
                .tracking(1.2)

            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .foregroundStyle(Color(red: 0.6, green: 0.4, blue: 1.0))

                TextField(
                    "",
                    text: $text,
                    prompt: Text(placeholder)
                        .foregroundColor(Color(red: 0.5, green: 0.55, blue: 0.7))
                )
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .tint(.white)

                if isValid {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            .padding(16)
            .background(Color(red: 0.12, green: 0.16, blue: 0.24))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if !suggestions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button {
                            onSelectSuggestion(suggestion)
                        } label: {
                            HStack {
                                Image(systemName: iconName)
                                    .foregroundStyle(Color(red: 0.6, green: 0.4, blue: 1.0))
                                    .font(.caption)

                                Text(suggestion)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.white)

                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)

                        if suggestion != suggestions.last {
                            Divider()
                                .background(Color.gray.opacity(0.3))
                        }
                    }
                }
                .background(Color(red: 0.12, green: 0.16, blue: 0.24))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

private struct HintRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.orange)

            Text(text)
                .font(.caption)
                .foregroundStyle(.gray)

            Spacer()
        }
        .padding(12)
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        SmartPlanInputView()
    }
}
