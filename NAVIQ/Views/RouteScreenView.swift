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
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.13).ignoresSafeArea()
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
        }
        .navigationTitle("Route")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
                    .foregroundStyle(.white)

                Spacer()

                Text("Step \(min(currentStepIndex + 1, route.steps.count)) of \(route.steps.count)")
                    .font(.caption)
                    .foregroundStyle(.gray)
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
                .foregroundStyle(.gray)

            if let step = currentStep {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: step.mode.iconName)
                        .font(.title2)
                        .foregroundStyle(.blue)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(step.instruction)
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text("\(step.fromName) → \(step.toName)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)

                        Text("About \(step.durationMinutes) min")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
            } else {
                Text("No route steps available.")
                    .foregroundStyle(.gray)
            }
        }
        .padding()
        .background(Color(red: 0.12, green: 0.16, blue: 0.24))
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
                    .frame(maxWidth: .infinity).foregroundStyle(.white)
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
                .background(Color(red: 0.12, green: 0.16, blue: 0.24))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .foregroundStyle(.white)
    }
}

private struct RouteMapPreview: View {
    let route: RouteResult

    private var mapCamera: MapCameraPosition {
        .region(
            MKCoordinateRegion(
                center: route.destination.coordinate.clLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
            )
        )
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            Map(initialPosition: mapCamera) {
                Marker(route.destination.name, coordinate: route.destination.coordinate.clLocation)
            }
        } else {
            RoutePlaceholderMap(route: route)
        }
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
