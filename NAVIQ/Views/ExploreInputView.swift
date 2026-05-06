import SwiftUI

struct ExploreInputView: View {
    @State private var startLocation: String = "Darling Harbour"
    @State private var timeHours: Double = 2
    @State private var budget: Double = 40
    @State private var selectedTransport: String = "Any"

    let transportOptions = ["Any", "Train", "Bus", "Ferry", "Walk"]

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.13)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Badge + title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("EXPLORE MODE")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.2, green: 0.6, blue: 1.0))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())

                        Text("Set your constraints")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)

                        Text("We'll find every place you can reach.")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }

                    // Starting point
                    VStack(alignment: .leading, spacing: 8) {
                        Text("STARTING POINT")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 0.4, green: 0.8, blue: 1.0))
                            .tracking(1.2)

                        HStack(spacing: 12) {
                            Image(systemName: "location.circle.fill")
                                .foregroundStyle(Color(red: 0.2, green: 0.7, blue: 0.9))
                            VStack(alignment: .leading, spacing: 2) {
                                TextField("", text: $startLocation)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text("Sydney NSW")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding(16)
                        .background(Color(red: 0.12, green: 0.16, blue: 0.24))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Time + Budget row
                    HStack(spacing: 12) {
                        // Time
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TIME")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color(red: 0.4, green: 0.8, blue: 1.0))
                                .tracking(1.2)

                            HStack(spacing: 10) {
                                Image(systemName: "power.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.title3)
                                Text("\(Int(timeHours)) hr")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(red: 0.12, green: 0.16, blue: 0.24))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            Slider(value: $timeHours, in: 1...8, step: 0.5)
                                .tint(Color(red: 0.2, green: 0.6, blue: 1.0))
                        }
                        .frame(maxWidth: .infinity)

                        // Budget
                        VStack(alignment: .leading, spacing: 8) {
                            Text("BUDGET")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color(red: 0.4, green: 0.8, blue: 1.0))
                                .tracking(1.2)

                            HStack(spacing: 10) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.title3)
                                Text("AUD \(Int(budget))")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(red: 0.12, green: 0.16, blue: 0.24))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            Slider(value: $budget, in: 5...150, step: 5)
                                .tint(.yellow)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Transport
                    VStack(alignment: .leading, spacing: 10) {
                        Text("TRANSPORT")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 0.4, green: 0.8, blue: 1.0))
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
                                            ? Color(red: 0.2, green: 0.6, blue: 1.0)
                                            : Color(red: 0.12, green: 0.16, blue: 0.24))
                                        .foregroundStyle(.white)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    // CTA button
                    NavigationLink(destination: ExploreResultsView(
                        startLocationName: startLocation,
                        userTimeMinutes: Int(timeHours * 60),
                        budget: budget
                    )) {
                        HStack {
                            Text("Show Reachable Destinations")
                                .font(.system(size: 17, weight: .bold))
                            Text("→")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(18)
                        .background(Color(red: 0.2, green: 0.6, blue: 1.0))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
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
        ExploreInputView()
    }
}
