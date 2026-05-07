//
//  SmartPlanResults.swift
//  NAVIQ
//
//  Created by Aneet Kaur on 7/5/2026.
//

import SwiftUI

struct SmartPlanResultsView: View {
    let startLocation: String
    let finalDestination: String
    let deadline: Date
    let budgetText: String
    let selectedTransport: String

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.13).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "hammer.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color(red: 0.6, green: 0.4, blue: 1.0))
                Text("Midpoint Results")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("Coming soon")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
        }
        .navigationTitle("Midpoints")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        SmartPlanResultsView(
            startLocation: "Darling Harbour",
            finalDestination: "Parramatta",
            deadline: Date(),
            budgetText: "75",
            selectedTransport: "Any"
        )
    }
}
