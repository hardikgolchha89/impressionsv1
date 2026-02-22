//
//  OnboardingCoordinator.swift
//  impressionsv1
//

import SwiftUI
import SwiftData

// MARK: - Steps

enum OnboardingStep: Int, CaseIterable {
    case signUp          // 1 — name + phone
    case otp             // 2 — 6-digit verify
    case tastePicker     // 3 — pick 5 restaurants + 5 vibes FIRST so we know which place to use
    case firstImpression // 4 — write 3 answers about their #1 picked restaurant
    case findPeople      // 5 — contacts / skip
    case welcome         // 6 — completion card

    /// Which segment of the progress bar is filled (0-based index out of 5)
    var progressFilled: Int { rawValue }
    static let totalSegments = 5
}

// MARK: - First Impression Question data

struct FirstImpressionQuestion {
    let prompt: String
    let sampleAnswer: String
}

let firstImpressionQuestions: [FirstImpressionQuestion] = [
    FirstImpressionQuestion(
        prompt: "What did you notice that most people wouldn't?",
        sampleAnswer: "They quietly swap the music playlist around 9 PM — from upbeat to something moodier. Nobody announces it. The whole room just shifts."
    ),
    FirstImpressionQuestion(
        prompt: "What would you tell a friend before they go?",
        sampleAnswer: ""   // no sample shown — user writes first
    ),
    FirstImpressionQuestion(
        prompt: "One thing that made you think 'okay, they actually care here'?",
        sampleAnswer: ""
    )
]

// MARK: - Coordinator

@Observable
final class OnboardingCoordinator {
    var step: OnboardingStep = .signUp

    // Sign-up data
    var name: String = ""
    var phone: String = ""

    // First impression answers
    var firstImpressionAnswers: [Int: String] = [:]   // question index → answer
    var currentQuestionIndex: Int = 0

    // Taste picker
    var selectedRestaurants: Set<String> = []
    var selectedVibes: Set<String> = []

    /// The order in which restaurants were picked, so we know which was first
    var restaurantPickOrder: [String] = []

    /// The first restaurant the user picked — used as the subject of FirstImpressionView.
    /// Falls back to "The Bombay Canteen" if somehow nothing selected yet.
    var firstPickedRestaurant: String {
        restaurantPickOrder.first ?? "The Bombay Canteen"
    }

    var onComplete: (() -> Void)?

    // MARK: Navigation

    func advance() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch step {
            case .signUp:          step = .otp
            case .otp:             step = .tastePicker
            case .tastePicker:     step = .firstImpression
            case .firstImpression: step = .findPeople
            case .findPeople:      step = .welcome
            case .welcome:         onComplete?()
            }
        }
    }

    func goBack() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch step {
            case .otp:             step = .signUp
            case .tastePicker:     step = .otp
            case .firstImpression: step = .tastePicker
            default:               break
            }
        }
    }
}
