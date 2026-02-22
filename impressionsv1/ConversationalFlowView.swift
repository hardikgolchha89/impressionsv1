//
//  ConversationalFlowView.swift
//  impressionsv1
//
//  Chat-style Q&A: occasion → group size → companions
//  Answered replies appear as right-aligned olive green pills.
//  Next question appears as a left-aligned white bubble with avatar.
//

import SwiftUI

// MARK: - Question definitions

private struct ConvQuestion {
    let key: String
    let text: String
    let emoji: String
    let chips: [String]
}

private let questions: [ConvQuestion] = [
    ConvQuestion(key: "occasion",   text: "What brought you here?",   emoji: "🎯",
                 chips: ["Date night","Family dinner","Work lunch","Friends hangout","Solo meal","Celebration","Quick bite","Business meeting"]),
    ConvQuestion(key: "groupSize",  text: "How many of you were there?", emoji: "👥",
                 chips: ["Just me","2 people","3-4 people","5-6 people","7+ people"]),
    ConvQuestion(key: "companions", text: "Who did you go with?",      emoji: "🧑",
                 chips: ["Partner","Family","Old friends","Work colleagues","New people","Solo"]),
]

// MARK: - View

struct ConversationalFlowView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var answers: [String: String] = [:]  // key → chosen chip

    private var answeredCount: Int { answers.count }
    private var allDone: Bool { answeredCount == questions.count }

    private var place: Place { coordinator.data.place ?? Place(id: "", name: "the place", location: nil, cuisine: nil) }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appCream.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Top bar ────────────────────────────────────────────
                HStack {
                    Button { coordinator.goBack() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appBrown)
                            .frame(width: 44, height: 44)
                    }

                    Text("NEW IMPRESSION")
                        .font(.custom("HKGrotesk-SemiBold", size: 11))
                        .foregroundColor(.appBrown.opacity(0.5))
                        .kerning(0.8)

                    Spacer()

                    Text("2/4")
                        .font(.custom("HKGrotesk-Regular", size: 13))
                        .foregroundColor(.appBrown.opacity(0.45))
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)

                // Progress bar
                ConvProgressBar(filled: 2, total: 4)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 16)

                // Place title
                VStack(alignment: .leading, spacing: 2) {
                    Text(place.name)
                        .font(.custom("HKGrotesk-Bold", size: 24))
                        .foregroundColor(.appBrown)
                    Text("\(place.location ?? "") · \(place.cuisine ?? "")")
                        .font(.custom("HKGrotesk-Regular", size: 13))
                        .foregroundColor(.appBrown.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                // ── Chat scroll ────────────────────────────────────────
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(0..<questions.count, id: \.self) { i in
                                let q = questions[i]
                                let isVisible = i <= answeredCount

                                if isVisible {
                                    // Bot question bubble
                                    BotBubble(text: q.text, emoji: q.emoji)
                                        .id("q_\(i)")

                                    // If answered → show answer pill
                                    if let ans = answers[q.key] {
                                        AnswerPill(text: ans)
                                    } else if i == answeredCount {
                                        // Current question chips
                                        ChipGrid(chips: q.chips) { chip in
                                            withAnimation(.spring(duration: 0.3)) {
                                                answers[q.key] = chip
                                            }
                                            // Scroll to next question after brief pause
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                                withAnimation {
                                                    proxy.scrollTo("q_\(i+1)", anchor: .top)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // All done message
                            if allDone {
                                BotBubble(text: "Perfect. Now let's build your impression", emoji: "🌟")
                                    .id("q_\(questions.count)")
                                    .transition(.opacity.combined(with: .move(edge: .leading)))
                            }

                            Color.clear.frame(height: 100) // bottom padding for button
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    }
                    .onChange(of: answeredCount) { _, _ in
                        withAnimation {
                            proxy.scrollTo("q_\(answeredCount)", anchor: .center)
                        }
                    }
                }
            }

            // ── Bottom CTA ─────────────────────────────────────────────
            VStack(spacing: 0) {
                if allDone {
                    Button {
                        coordinator.completeConversational(
                            occasion:   answers["occasion"]   ?? "",
                            groupSize:  answers["groupSize"]  ?? "",
                            companions: answers["companions"] ?? ""
                        )
                    } label: {
                        Text("Build my impression →")
                    }
                    .primaryButton()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Text("Answer to continue...")
                        .font(.custom("HKGrotesk-Regular", size: 15))
                        .foregroundColor(.appBrown.opacity(0.35))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.appGreige.opacity(0.4))
                }
            }
            .animation(.spring(duration: 0.35), value: allDone)
        }
    }
}

// MARK: - Sub-components

private struct ConvProgressBar: View {
    let filled: Int; let total: Int
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(i < filled ? Color.appOlive : (i == filled ? Color.appAmber : Color.appGreige))
                    .frame(height: 4)
            }
        }
    }
}

private struct BotBubble: View {
    let text: String; let emoji: String
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.appCrimson)
                    .frame(width: 34, height: 34)
                Image(systemName: "fork.knife")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
            }
            HStack(spacing: 4) {
                Text(text)
                    .font(.custom("HKGrotesk-Regular", size: 15))
                    .foregroundColor(.appBrown)
                Text(emoji)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            Spacer()
        }
    }
}

private struct AnswerPill: View {
    let text: String
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .font(.custom("HKGrotesk-SemiBold", size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.appOlive)
                .clipShape(Capsule())
        }
    }
}

private struct ChipGrid: View {
    let chips: [String]
    let onSelect: (String) -> Void
    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(chips, id: \.self) { chip in
                Button(chip) { onSelect(chip) }
                    .font(.custom("HKGrotesk-Regular", size: 14))
                    .foregroundColor(.appBrown)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                    .buttonStyle(.plain)
            }
        }
        .padding(.leading, 44) // indent under avatar
    }
}
