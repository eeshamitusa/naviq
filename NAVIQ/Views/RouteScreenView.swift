import SwiftUI
import MapKit

struct RouteScreenView: View {
    let route: RouteResult

    @Environment(\.dismiss) private var dismiss
    @State private var currentStepIndex: Int = 0

    private var progress: Double {
        guard !route.steps.isEmpty else { return 0 }
        return Double(currentStepIndex + 1) / Double(route.steps.count)
    }

    private var currentStep: RouteStep? {
        guard route.steps.indices.contains(currentStepIndex) else { return nil }
        return route.steps[currentStepIndex]
    }

    private var isFinalStep: Bool {
        currentStepIndex >= route.steps.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            mapOrPlaceholder
                .frame(height: 300)
                .overlay(alignment: .topLeading) {
                    dataSourceBadge
                        .padding()
                }

            VStack(alignment: .leading, spacing: 18) {
                progressSection
                nextStepCard
                routeControls
                homeButton
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
        }
        .navigationTitle("Route")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Map / fallback

    private var mapOrPlaceholder: some View {
        RouteMapPreview(route: route)
    }

    private var dataSourceBadge: some View {
        Text(route.isLiveData ? "Live NSW API route" : "Mock fallback route")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.thinMaterial)
            .clipShape(Capsule())
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Trip progress")
                    .font(.headline)

                Spacer()

                Text("Step \(min(currentStepIndex + 1, route.steps.count)) of \(route.steps.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: progress)
                .progressViewStyle(.linear)
        }
    }

    // MARK: - Next step

    private var nextStepCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Next step")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            if let step = currentStep {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: step.mode.iconName)
                        .font(.title2)
                        .foregroundStyle(.blue)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(step.instruction)
                            .font(.headline)

                        Text("\(step.fromName) → \(step.toName)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("About \(step.durationMinutes) min")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("No route steps available.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Controls

    private var routeControls: some View {
        HStack(spacing: 12) {
            Button {
                if currentStepIndex > 0 {
                    currentStepIndex -= 1
                }
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(currentStepIndex == 0)

            Button {
                if isFinalStep {
                    dismiss()
                } else {
                    currentStepIndex += 1
                }
            } label: {
                Label(isFinalStep ? "Finish" : "Next", systemImage: isFinalStep ? "checkmark" : "chevron.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var homeButton: some View {
        Button {
            dismiss()
        } label: {
            Label("Home", systemImage: "house.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .foregroundStyle(.primary)
    }
}

private struct RouteMapPreview: View {
    let route: RouteResult
    
    @State private var cameraPosition: MapCameraPosition
    
    init(route: RouteResult) {
        self.route = route
        
        let region = MKCoordinateRegion(
            center: route.destination.coordinate.clLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
        )
        
        _cameraPosition = State(initialValue: .region(region))
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Map(position: $cameraPosition) {
                Marker(
                    route.destination.name,
                    coordinate: route.destination.coordinate.clLocation
                )
                .tint(.blue)
            }
            .mapStyle(.standard)
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            
            destinationCard
                .padding()
        }
    }
    
    private var destinationCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(route.destination.name)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text(route.destination.streetAddress)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            HStack(spacing: 10) {
                Label("\(route.travelTimeMinutes) min", systemImage: "clock")
                Label(route.formattedCost, systemImage: "dollarsign.circle")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.blue)
        }
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }
}

private struct RoutePlaceholderMap: View {
    let route: RouteResult

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.18), Color.purple.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 16) {
                Image(systemName: "map.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.blue)

                Text("Route to \(route.destination.name)")
                    .font(.title3.weight(.bold))

                Text("MapKit fallback view with route steps below.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        RouteScreenView(route: MockData.allRoutes[6])
    }
}
