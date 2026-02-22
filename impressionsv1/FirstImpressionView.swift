//
//  FirstImpressionView.swift
//  impressionsv1
//
//  Onboarding Step 4: Write your first impression about the restaurant you picked first.
//  The example card always shows The Bombay Canteen as the reference, but the user
//  writes about their own #1 pick from TastePickerView.
//

import SwiftUI

private struct Question {
    let prompt: String
    let sampleAnswer: String? // nil = no sample shown for this question
}

private let questions: [Question] = [
    Question(
        prompt: "What did you notice that most people wouldn't?",
        sampleAnswer: "They quietly swap the music playlist around 9 PM — from upbeat to something moodier. Nobody announces it. The whole room just shifts."
    ),
    Question(
        prompt: "What would you tell a friend before they go?",
        sampleAnswer: nil
    ),
    Question(
        prompt: "One thing that made you think 'okay, they actually care here'?",
        sampleAnswer: nil
    )
]

struct FirstImpressionView: View {
    @Bindable var coordinator: OnboardingCoordinator
    @FocusState private var textFocused: Bool
    @State private var showSample = false

    // The restaurant the user is writing about — their first pick
    private var placeName: String { coordinator.firstPickedRestaurant }
    private var placeEmoji: String { "🍽️" }

    private var qi: Int { coordinator.currentQuestionIndex }
    private var question: Question { questions[qi] }
    private var currentAnswer: Binding<String> {
        Binding(
            get: { coordinator.firstImpressionAnswers[qi] ?? "" },
            set: { coordinator.firstImpressionAnswers[qi] = $0 }
        )
    }
    private var canAdvance: Bool {
        (coordinator.firstImpressionAnswers[qi] ?? "").trimmingCharacters(in: .whitespaces).count >= 3
    }
    private var isLast: Bool { qi == questions.count - 1 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // ── Place pill + title ─────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    // "YOUR FIRST IMPRESSION" pill
                    Text("YOUR FIRST IMPRESSION")
                        .font(.custom("HKGrotesk-SemiBold", size: 10))
                        .foregroundColor(.appOlive)
                        .kerning(0.8)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(Color.appOlive.opacity(0.12))
                        )

                    HStack(spacing: 6) {
                        Text(placeName)
                            .font(.custom("HKGrotesk-Bold", size: 26))
                            .foregroundColor(.appCrimson)
                        Text(placeEmoji)
                            .font(.system(size: 22))
                    }

                    Text("Answer \(qi + 1) of \(questions.count) — here's how others answered")
                        .font(.custom("HKGrotesk-Regular", size: 13))
                        .foregroundColor(.appBrown.opacity(0.6))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)

                // ── Example card (amber) — always The Bombay Canteen as reference ──
                // Show on Q1 (where sample is non-nil) or on demand for Q2+
                if let sample = question.sampleAnswer, !sample.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Text("↔ HOW SOMEONE ANSWERED ABOUT")
                                .font(.custom("HKGrotesk-SemiBold", size: 10))
                                .foregroundColor(.white.opacity(0.75))
                                .kerning(0.6)
                            Text("The Bombay Canteen")
                                .font(.custom("HKGrotesk-Bold", size: 10))
                                .foregroundColor(.white.opacity(0.9))
                                .kerning(0.4)
                        }

                        Text(question.prompt)
                            .font(.custom("HKGrotesk-Regular", size: 13))
                            .foregroundColor(.white.opacity(0.85))

                        Text(sample)
                            .font(.custom("HKGrotesk-Bold", size: 16))
                            .foregroundColor(.white)
                            .lineSpacing(3)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.appAmber)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                } else {
                    // "See how others answered" toggle for Q2+
                    Button {
                        withAnimation(.spring(duration: 0.3)) { showSample.toggle() }
                    } label: {
                        HStack(spacing: 4) {
                            Text("↔")
                                .font(.system(size: 12))
                            Text("See how others answered")
                                .font(.custom("HKGrotesk-Regular", size: 13))
                        }
                        .foregroundColor(.appBrown.opacity(0.5))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, showSample ? 12 : 20)

                    if showSample {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What they said about a different question at The Bombay Canteen:")
                                .font(.custom("HKGrotesk-Light", size: 12))
                                .foregroundColor(.white.opacity(0.75))
                            Text(questions[0].sampleAnswer ?? "")
                                .font(.custom("HKGrotesk-SemiBold", size: 14))
                                .foregroundColor(.white)
                                .lineSpacing(2)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.appAmber)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                // ── User text area ────────────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 5) {
                        Text("✏")
                            .font(.system(size: 12))
                        Text("NOW YOUR TURN")
                            .font(.custom("HKGrotesk-SemiBold", size: 10))
                            .foregroundColor(.appBrown.opacity(0.55))
                            .kerning(0.8)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(question.prompt)
                            .font(.custom("HKGrotesk-Regular", size: 14))
                            .foregroundColor(.appBrown)

                        ZStack(alignment: .topLeading) {
                            if currentAnswer.wrappedValue.isEmpty {
                                Text("Write about \(placeName)...")
                                    .font(.custom("HKGrotesk-Light", size: 14))
                                    .foregroundColor(.appBrown.opacity(0.35))
                                    .padding(.top, 2)
                            }
                            TextEditor(text: currentAnswer)
                                .font(.custom("HKGrotesk-Regular", size: 14))
                                .foregroundColor(.appBrown)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(minHeight: 80)
                                .focused($textFocused)
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.appOffWhite)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(
                                        style: StrokeStyle(lineWidth: 1.5, dash: [5, 3])
                                    )
                                    .foregroundColor(Color.appOlive.opacity(0.45))
                            )
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // ── Progress dots ─────────────────────────────────────
                HStack(spacing: 6) {
                    ForEach(0..<questions.count, id: \.self) { i in
                        Capsule()
                            .fill(i == qi ? Color.appCrimson : (i < qi ? Color.appOlive : Color.appGreige))
                            .frame(width: i == qi ? 20 : 8, height: 8)
                            .animation(.spring(duration: 0.3), value: qi)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // ── CTA ───────────────────────────────────────────────
                VStack(spacing: 10) {
                    Button {
                        guard canAdvance else { return }
                        textFocused = false
                        if isLast {
                            coordinator.advance()
                        } else {
                            withAnimation(.spring(duration: 0.3)) {
                                coordinator.currentQuestionIndex += 1
                                showSample = false
                            }
                        }
                    } label: {
                        Text(isLast ? "Done →" : "Next question →")
                    }
                    .if(canAdvance) { $0.primaryButton() }
                    .if(!canAdvance) { $0.inactiveButton() }
                    .disabled(!canAdvance)
                    .animation(.easeInOut(duration: 0.2), value: canAdvance)
                    .padding(.horizontal, 20)

                    if !isLast {
                        Button {
                            textFocused = false
                            withAnimation(.spring(duration: 0.3)) {
                                coordinator.currentQuestionIndex += 1
                                showSample = false
                            }
                        } label: {
                            Text("Skip this one")
                                .font(.custom("HKGrotesk-Regular", size: 13))
                                .foregroundColor(.appBrown.opacity(0.5))
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
