//
//  SplashScreenView.swift
//  NAVIQ
//
//  Created by Aneet Kaur on 7/5/2026.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.0

    var body: some View {
        if isActive {
            HomeView()
        } else {
            ZStack {
                Color(red: 0.07, green: 0.09, blue: 0.13).ignoresSafeArea()

                VStack(spacing: 12) {
                    Image(systemName: "location.north.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color(red: 0.2, green: 0.6, blue: 1.0))

                    Text("NAVIQ")
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(.white)

                    Text("Reverse Navigation")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.8)) {
                        opacity = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 0.6)) {
                            opacity = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}
