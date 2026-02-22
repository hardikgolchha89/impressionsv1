//
//  OnboardingWelcomeView.swift
//  impressionsv1
//
//  Onboarding final screen — dark green celebration card + auto-advance
//

import SwiftUI

struct OnboardingWelcomeView: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        ZStack {
            Color.appCream.ignoresSafeArea()

            VStack {
                Spacer()

                // ── Green celebration card ─────────────────────────────
                VStack(spacing: 14) {
                    Text("🎉")
                        .font(.system(size: 48))

                    Text("Welcome to The Table!")
                        .font(.custom("HKGrotesk-Bold", size: 24))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Your taste profile is set. Start exploring Mumbai's best spots through people who actually know them.")
                        .font(.custom("HKGrotesk-Light", size: 15))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 36)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.appForestGreen)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)

                Spacer().frame(height: 24)

                Text("Taking you to your feed...")
                    .font(.custom("HKGrotesk-Light", size: 13))
                    .foregroundColor(.appBrown.opacity(0.45))

                Spacer()
            }
        }
        .onAppear {
            // Auto-advance after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                coordinator.advance()
            }
        }
    }
}
