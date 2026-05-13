import SwiftUI
import MapKit
import UserNotifications

struct SmartPlanJourneyView: View {
    let plan: SmartPlanResult
    let startLocation: String
    let finalDestination: String
    let deadline: Date

    @State private var notificationStatusMessage: String?
    @State private var notificationScheduled: Bool = false

    private var adjustedDeadline: Date {
        let now = Date()

        if deadline <= now {
            return Calendar.current.date(byAdding: .day, value: 1, to: deadline) ?? deadline
        }

        return deadline
    }

    private var latestLeaveTimeFromMidpoint: Date {
        Calendar.current.date(
            byAdding: .minute,
            value: -plan.secondLegRoute.travelTimeMinutes,
            to: adjustedDeadline
        ) ?? adjustedDeadline
    }

    private var notificationTime: Date {
        Calendar.current.date(
            byAdding: .minute,
            value: -15,
            to: latestLeaveTimeFromMidpoint
        ) ?? latestLeaveTimeFromMidpoint
    }

    private var formattedDeadline: String {
        formatTime(adjustedDeadline)
    }

    private var formattedLeaveTime: String {
        formatTime(latestLeaveTimeFromMidpoint)
    }

    private var formattedNotificationTime: String {
        formatTime(notificationTime)
    }

    private var mapRegion: MKCoordinateRegion {
        let midpointCoordinate = CLLocationCoordinate2D(
            latitude: plan.midpoint.coordinate.latitude,
            longitude: plan.midpoint.coordinate.longitude
        )

        let finalCoordinate = CLLocationCoordinate2D(
            latitude: plan.secondLegRoute.destination.coordinate.latitude,
            longitude: plan.secondLegRoute.destination.coordinate.longitude
        )

        let centerLatitude = (midpointCoordinate.latitude + finalCoordinate.latitude) / 2
        let centerLongitude = (midpointCoordinate.longitude + finalCoordinate.longitude) / 2

        let latitudeDelta = max(abs(midpointCoordinate.latitude - finalCoordinate.latitude) * 3, 0.08)
        let longitudeDelta = max(abs(midpointCoordinate.longitude - finalCoordinate.longitude) * 3, 0.08)

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: centerLatitude,
                longitude: centerLongitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: latitudeDelta,
                longitudeDelta: longitudeDelta
            )
        )
    }

    private var mapItems: [SmartPlanMapItem] {
        [
            SmartPlanMapItem(
                title: "Midpoint",
                subtitle: plan.midpoint.name,
                coordinate: CLLocationCoordinate2D(
                    latitude: plan.midpoint.coordinate.latitude,
                    longitude: plan.midpoint.coordinate.longitude
                )
            ),
            SmartPlanMapItem(
                title: "Final",
                subtitle: plan.secondLegRoute.destination.name,
                coordinate: CLLocationCoordinate2D(
                    latitude: plan.secondLegRoute.destination.coordinate.latitude,
                    longitude: plan.secondLegRoute.destination.coordinate.longitude
                )
            )
        ]
    }

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.13)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    mapSection
                    timelineSection
                    reminderSection
                    routeBreakdownSection
                    finalDestinationSection
                }
                .padding(24)
            }
        }
        .navigationTitle("Smart Journey")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("JOURNEY STARTED")
                .font(.system(size: 11, weight: .bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color(red: 0.6, green: 0.4, blue: 1.0))
                .foregroundStyle(.white)
                .clipShape(Capsule())

            Text("Go to \(plan.midpoint.name)")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            Text("Start from \(startLocation), enjoy your midpoint, then leave by \(formattedLeaveTime) to reach \(finalDestination) by \(formattedDeadline).")
                .font(.subheadline)
                .foregroundStyle(.gray)

            HStack(spacing: 10) {
                SmartJourneyStatBox(
                    iconName: "location.fill",
                    title: "Now go to",
                    value: plan.midpoint.name
                )

                SmartJourneyStatBox(
                    iconName: "clock.fill",
                    title: "First leg",
                    value: plan.firstLegRoute.formattedTravelTime
                )
            }
        }
        .padding(18)
        .background(Color(red: 0.1, green: 0.13, blue: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Map to final destination")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Map(coordinateRegion: .constant(mapRegion), annotationItems: mapItems) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    VStack(spacing: 4) {
                        Image(systemName: item.title == "Final" ? "flag.checkered.circle.fill" : "mappin.circle.fill")
                            .font(.title2)
                            .foregroundStyle(item.title == "Final" ? .green : Color(red: 0.6, green: 0.4, blue: 1.0))

                        Text(item.title)
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                    }
                }
            }
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Text("This MVP map shows the midpoint and final destination. Full live route drawing can be added later with route geometry/API support.")
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timing plan")
                .font(.title3.bold())
                .foregroundStyle(.white)

            SmartTimelineRow(
                iconName: "figure.walk",
                title: "Start now",
                detail: "Head from \(startLocation) to \(plan.midpoint.name).",
                timeText: plan.firstLegRoute.formattedTravelTime
            )

            SmartTimelineRow(
                iconName: "cup.and.saucer.fill",
                title: "Enjoy midpoint",
                detail: "You have roughly \(plan.formattedRemainingTime) of flexible time before needing to leave.",
                timeText: plan.formattedRemainingTime
            )

            SmartTimelineRow(
                iconName: "bell.fill",
                title: "Reminder",
                detail: "The app can remind you 15 minutes before leaving.",
                timeText: formattedNotificationTime
            )

            SmartTimelineRow(
                iconName: "tram.fill",
                title: "Leave midpoint",
                detail: "Leave \(plan.midpoint.name) for \(finalDestination).",
                timeText: formattedLeaveTime
            )

            SmartTimelineRow(
                iconName: "flag.checkered",
                title: "Arrive final destination",
                detail: "Target arrival at \(finalDestination).",
                timeText: formattedDeadline
            )
        }
        .padding(18)
        .background(Color(red: 0.1, green: 0.13, blue: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Leaving reminder")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text("Schedule a notification for \(formattedNotificationTime), which is 15 minutes before you should leave the midpoint.")
                .font(.subheadline)
                .foregroundStyle(.gray)

            Button {
                scheduleLeaveReminder()
            } label: {
                HStack {
                    Image(systemName: notificationScheduled ? "checkmark.circle.fill" : "bell.badge.fill")

                    Text(notificationScheduled ? "Reminder Scheduled" : "Set 15-Minute Reminder")
                        .font(.system(size: 16, weight: .bold))

                    Spacer()
                }
                .padding(16)
                .background(notificationScheduled ? Color.green.opacity(0.25) : Color(red: 0.6, green: 0.4, blue: 1.0))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)

            if let notificationStatusMessage {
                Text(notificationStatusMessage)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding(18)
        .background(Color(red: 0.1, green: 0.13, blue: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var routeBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Route breakdown")
                .font(.title3.bold())
                .foregroundStyle(.white)

            SmartJourneyRouteCard(
                title: "First leg: Start to midpoint",
                fromName: plan.firstLegRoute.steps.first?.fromName ?? startLocation,
                toName: plan.midpoint.name,
                route: plan.firstLegRoute
            )

            SmartJourneyRouteCard(
                title: "Second leg: Midpoint to final",
                fromName: plan.midpoint.name,
                toName: plan.secondLegRoute.destination.name,
                route: plan.secondLegRoute
            )
        }
    }

    private var finalDestinationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Final destination")
                .font(.title3.bold())
                .foregroundStyle(.white)

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "flag.checkered.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)

                VStack(alignment: .leading, spacing: 4) {
                    Text(finalDestination)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("Leave the midpoint by \(formattedLeaveTime) to stay on track.")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }

                Spacer()
            }
            .padding(18)
            .background(Color(red: 0.1, green: 0.13, blue: 0.2))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }

    private func scheduleLeaveReminder() {
        let now = Date()

        guard notificationTime > now else {
            notificationStatusMessage = "The reminder time has already passed. Choose a later arrival time to schedule a reminder."
            notificationScheduled = false
            return
        }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { allowed, error in
            if let error {
                DispatchQueue.main.async {
                    notificationStatusMessage = "Could not request notification permission: \(error.localizedDescription)"
                    notificationScheduled = false
                }
                return
            }

            guard allowed else {
                DispatchQueue.main.async {
                    notificationStatusMessage = "Notification permission was not allowed. You can still use the leaving time shown on this screen."
                    notificationScheduled = false
                }
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "Time to get ready to leave"
            content.body = "Leave \(plan.midpoint.name) by \(formattedLeaveTime) to reach \(finalDestination) on time."
            content.sound = .default

            let interval = notificationTime.timeIntervalSince(now)
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: max(interval, 1),
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "smart-plan-leave-\(plan.id.uuidString)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error {
                        notificationStatusMessage = "Could not schedule reminder: \(error.localizedDescription)"
                        notificationScheduled = false
                    } else {
                        notificationStatusMessage = "Reminder set for \(formattedNotificationTime)."
                        notificationScheduled = true
                    }
                }
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

private struct SmartPlanMapItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
}

private struct SmartJourneyStatBox: View {
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
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(red: 0.12, green: 0.16, blue: 0.24))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct SmartTimelineRow: View {
    let iconName: String
    let title: String
    let detail: String
    let timeText: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.subheadline)
                .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            Text(timeText)
                .font(.caption.bold())
                .foregroundStyle(.white)
        }
        .padding(.vertical, 4)
    }
}

private struct SmartJourneyRouteCard: View {
    let title: String
    let fromName: String
    let toName: String
    let route: RouteResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: route.primaryTransportMode.iconName)
                    .font(.title3)
                    .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("\(fromName) → \(toName)")
                        .font(.caption)
                        .foregroundStyle(.gray)

                    Text("\(route.formattedTravelTime) • \(route.formattedCost) • \(route.primaryTransportMode.displayName)")
                        .font(.caption.bold())
                        .foregroundStyle(Color(red: 0.75, green: 0.62, blue: 1.0))
                }

                Spacer()
            }

            if !route.steps.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(route.steps) { step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(step.order)")
                                .font(.caption2.bold())
                                .foregroundStyle(.black)
                                .frame(width: 22, height: 22)
                                .background(Color(red: 0.75, green: 0.62, blue: 1.0))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(step.instruction)
                                    .font(.caption)
                                    .foregroundStyle(.white)

                                Text("\(step.durationMinutes) min")
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                            }

                            Spacer()
                        }
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(18)
        .background(Color(red: 0.1, green: 0.13, blue: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    NavigationStack {
        SmartPlanInputView()
    }
}
