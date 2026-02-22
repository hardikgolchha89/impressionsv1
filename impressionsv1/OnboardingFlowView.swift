//
//  OnboardingFlowView.swift
//  impressionsv1
//

import SwiftUI
import SwiftData

struct OnboardingFlowView: View {
    @State private var coordinator = OnboardingCoordinator()
    @Environment(UserManager.self) private var userManager
    @Environment(\.modelContext) private var modelContext

    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.appCream.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar — shown for all steps except welcome
                if coordinator.step != .welcome {
                    OnboardingProgressBar(
                        filled: coordinator.step.progressFilled,
                        total: OnboardingStep.totalSegments
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 4)
                }

                // Screen content
                Group {
                    switch coordinator.step {
                    case .signUp:
                        SignUpView(coordinator: coordinator)
                    case .otp:
                        OTPView(coordinator: coordinator)
                    case .tastePicker:
                        TastePickerView(coordinator: coordinator)
                    case .firstImpression:
                        FirstImpressionView(coordinator: coordinator)
                    case .findPeople:
                        FindPeopleView(coordinator: coordinator)
                    case .welcome:
                        OnboardingWelcomeView(coordinator: coordinator)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(coordinator.step)
            }
        }
        .onAppear {
            coordinator.onComplete = {
                userManager.completeOnboarding()
                onComplete()
            }
        }
    }
}

// MARK: - Progress Bar

struct OnboardingProgressBar: View {
    let filled: Int
    let total: Int

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<total, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(i < filled ? Color.appOlive : Color(hex: "C8C0B0"))
                    .frame(height: 4)
            }
        }
    }
}
