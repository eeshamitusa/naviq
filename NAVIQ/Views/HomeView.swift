import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.09, blue: 0.13)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("NAVIQ")
                            .font(.system(size: 42, weight: .black))
                            .foregroundStyle(.white)
                        Text("Reverse Navigation · Sydney")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 24)

                    // Hero question card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("THE QUESTION WE ANSWER")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 0.4, green: 0.8, blue: 1.0))
                            .tracking(1.2)

                        Text("Given my ")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        + Text("time")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color(red: 0.4, green: 0.8, blue: 1.0))
                        + Text(", ")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        + Text("budget")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color(red: 0.4, green: 0.8, blue: 1.0))
                        + Text(" & location — where can I ")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        + Text("go?")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color(red: 0.4, green: 0.8, blue: 1.0))
                    }
                    .padding(20)
                    .background(Color(red: 0.1, green: 0.14, blue: 0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 24)
                    .padding(.top, 28)

                    // Choose a mode label
                    Text("CHOOSE A MODE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.gray)
                        .tracking(1.2)
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                        .padding(.bottom, 12)

                    // Explore card
                    NavigationLink(destination: ExploreInputView()) {
                        HomeModeCard(
                            badge: "EXPLORE",
                            badgeColor: Color(red: 0.2, green: 0.6, blue: 1.0),
                            title: "Explore Mode",
                            description: "Set time + budget. See every destination you can reach from here right now."
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)

                    // Smart Plan card
                    NavigationLink(destination: SmartPlanInputView()) {
                        HomeModeCard(
                            badge: "SMART PLAN",
                            badgeColor: Color(red: 0.6, green: 0.4, blue: 1.0),
                            title: "Smart Planning",
                            description: "Have a final destination? Find places to visit in between, within your budget and deadline."
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

private struct HomeModeCard: View {
    let badge: String
    let badgeColor: Color
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(badge)
                .font(.system(size: 11, weight: .bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(badgeColor)
                .foregroundStyle(.white)
                .clipShape(Capsule())

            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            HStack {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
                    .font(.caption)
            }
        }
        .padding(20)
        .background(Color(red: 0.1, green: 0.14, blue: 0.22))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HomeView()
}
