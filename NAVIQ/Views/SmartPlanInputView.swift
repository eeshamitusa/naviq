import SwiftUI
import MapKit

struct SmartPlanInputView: View {
    @State private var currentLocation: String = ""
    @State private var finalDestination: String = ""
    @State private var deadline: Date = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var budgetText: String = "75"
    @State private var selectedTransport: String = "Any"
    @State private var finalSuggestions: [MKMapItem] = []
    @State private var isFinalValid: Bool = false
    @State private var isSearching: Bool = false

    let transportOptions = ["Any", "Train", "Bus", "Ferry"]

    let knownLocations = [
        "Circular Quay", "Bondi Beach", "Manly", "Newtown", "Chatswood",
        "Parramatta", "Darling Harbour", "Barangaroo", "The Rocks", "Cronulla",
        "Watsons Bay", "Taronga Zoo Sydney", "Mosman", "Sydney Olympic Park",
        "Katoomba", "Central Station", "UTS Broadway", "Coogee Beach",
        "Surry Hills", "Glebe", "Rhodes", "Strathfield", "Hornsby",
        "Penrith", "Liverpool"
    ]

    var currentSuggestions: [String] {
        guard currentLocation.count >= 2 else { return [] }
        return knownLocations.filter {
            $0.lowercased().contains(currentLocation.lowercased())
        }
    }

    var isCurrentValid: Bool {
        knownLocations.contains(where: {
            $0.lowercased() == currentLocation.lowercased()
        })
    }

    var isFormValid: Bool {
        isCurrentValid && isFinalValid
    }

    func searchPlaces() async {
        let trimmed = finalDestination.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            finalSuggestions = []
            return
        }

        isSearching = true

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed + " Sydney NSW"
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093),
            span: MKCoordinateSpan(latitudeDelta: 1.5, longitudeDelta: 1.5)
        )
        request.resultTypes = [.pointOfInterest, .address]

        do {
            let results = try await MKLocalSearch(request: request).start()
            finalSuggestions = Array(results.mapItems.prefix(3))
        } catch {
            finalSuggestions = []
        }

        isSearching = false
    }

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.13).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Badge + title
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

                        Text("We'll find midpoints you can visit along the way.")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }

                    // Journey banner
                    HStack(spacing: 0) {
                        Text("Start")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.15, green: 0.2, blue: 0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Image(systemName: "arrow.right")
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 8)

                        Text("Midpoint?")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.2, green: 0.15, blue: 0.35))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Image(systemName: "arrow.right")
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 8)

                        Text("Final")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.15, green: 0.2, blue: 0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(12)
                    .background(Color(red: 0.1, green: 0.13, blue: 0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Current location
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CURRENT LOCATION")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
                            .tracking(1.2)

                        HStack(spacing: 12) {
                            Image(systemName: "location.circle.fill")
                                .foregroundStyle(Color(red: 0.6, green: 0.4, blue: 1.0))
                            TextField("", text: $currentLocation,
                                prompt: Text("Type your location...")
                                    .foregroundColor(Color(red: 0.5, green: 0.55, blue: 0.7)))
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .tint(.white)
                        }
                        .padding(16)
                        .background(Color(red: 0.12, green: 0.16, blue: 0.24))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Current location suggestions
                        if !currentSuggestions.isEmpty && !isCurrentValid {
                            VStack(spacing: 0) {
                                ForEach(currentSuggestions, id: \.self) { suggestion in
                                    Button {
                                        currentLocation = suggestion
                                    } label: {
                                        HStack {
                                            Image(systemName: "location.circle.fill")
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
                                    Divider().background(Color.gray.opacity(0.3))
                                }
                            }
                            .background(Color(red: 0.12, green: 0.16, blue: 0.24))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Final destination
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FINAL DESTINATION")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
                            .tracking(1.2)

                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(Color(red: 0.6, green: 0.4, blue: 1.0))
                            TextField("", text: $finalDestination,
                                prompt: Text("e.g. Parramatta, Westmead...")
                                    .foregroundColor(Color(red: 0.5, green: 0.55, blue: 0.7)))
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .tint(.white)
                                .onChange(of: finalDestination) { _ in
                                    isFinalValid = false
                                    finalSuggestions = []
                                    Task {
                                        try? await Task.sleep(nanoseconds: 500_000_000)
                                        await searchPlaces()
                                    }
                                }

                            if isSearching {
                                ProgressView().scaleEffect(0.7)
                            } else if isFinalValid {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding(16)
                        .background(Color(red: 0.12, green: 0.16, blue: 0.24))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Apple Maps suggestions — max 3
                        if !finalSuggestions.isEmpty && !isFinalValid {
                            VStack(spacing: 0) {
                                ForEach(finalSuggestions, id: \.self) { item in
                                    Button {
                                        finalDestination = item.name ?? finalDestination
                                        isFinalValid = true
                                        finalSuggestions = []
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "mappin.circle.fill")
                                                .foregroundStyle(Color(red: 0.6, green: 0.4, blue: 1.0))
                                                .font(.caption)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(item.name ?? "Unknown")
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundStyle(.white)
                                                if let suburb = item.placemark.locality {
                                                    Text(suburb)
                                                        .font(.caption)
                                                        .foregroundStyle(.gray)
                                                }
                                            }
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                    }
                                    Divider().background(Color.gray.opacity(0.3))
                                }
                            }
                            .background(Color(red: 0.12, green: 0.16, blue: 0.24))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Deadline + Budget
                    HStack(alignment: .top, spacing: 12) {
                        // Deadline
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DEADLINE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
                                .tracking(1.2)

                            HStack {
                                DatePicker("", selection: $deadline,
                                    displayedComponents: .hourAndMinute)
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
                        .frame(maxWidth: .infinity)

                        // Budget
                        VStack(alignment: .leading, spacing: 8) {
                            Text("BUDGET")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
                                .tracking(1.2)

                            HStack(spacing: 10) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.title3)
                                TextField("", text: $budgetText,
                                    prompt: Text("e.g. 75")
                                        .foregroundColor(Color(red: 0.5, green: 0.55, blue: 0.7)))
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .tint(.white)
                                    .keyboardType(.numberPad)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.12, green: 0.16, blue: 0.24))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Transport
                    VStack(alignment: .leading, spacing: 10) {
                        Text("TRANSPORT")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
                            .tracking(1.2)

                        HStack(spacing: 8) {
                            ForEach(transportOptions, id: \.self) { option in
                                Button {
                                    selectedTransport = option
                                } label: {
                                    Text(option)
                                        .font(.system(size: 14, weight: .medium))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(selectedTransport == option
                                            ? Color(red: 0.6, green: 0.4, blue: 1.0)
                                            : Color(red: 0.12, green: 0.16, blue: 0.24))
                                        .foregroundStyle(.white)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    // CTA button
                    NavigationLink(destination: SmartPlanResultsView(
                        startLocation: currentLocation,
                        finalDestination: finalDestination,
                        deadline: deadline,
                        budgetText: budgetText,
                        selectedTransport: selectedTransport
                    )) {
                        HStack {
                            Text("Find Midpoint Destinations")
                                .font(.system(size: 17, weight: .bold))
                            Text("→")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(18)
                        .background(isFormValid
                            ? Color(red: 0.6, green: 0.4, blue: 1.0)
                            : Color(red: 0.3, green: 0.2, blue: 0.5))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .disabled(!isFormValid)
                    .padding(.top, 8)
                }
                .padding(24)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        SmartPlanInputView()
    }
}
