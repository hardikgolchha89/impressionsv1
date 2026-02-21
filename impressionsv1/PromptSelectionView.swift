//
//  PromptSelectionView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI

// MARK: - Data Model
struct Prompt: Identifiable, Equatable {
    let id: UUID
    let question: String
    let category: PromptCategory

    init(id: UUID = UUID(), question: String, category: PromptCategory) {
        self.id = id
        self.question = question
        self.category = category
    }
}

struct PromptAnswer {
    let promptId: UUID
    let question: String
    let answerText: String
    let timestamp: Date

    init(promptId: UUID, question: String, answerText: String, timestamp: Date = Date()) {
        self.promptId = promptId
        self.question = question
        self.answerText = answerText
        self.timestamp = timestamp
    }
}

// MARK: - Category Color Scheme

struct CategoryScheme {
    let outerBg: Color       // lighter tint — the "outer box" background
    let innerBg: Color       // saturated — the "inner box" fill
    let border: Color        // border between outer and inner
    let textColor: Color     // question text
    let tabSelected: Color   // tab pill fill when selected
    let tabText: Color       // tab text when selected
    let shadow: Color        // drop shadow tint
}

extension PromptCategory {
    var scheme: CategoryScheme {
        switch self {
        case .craftDetails:
            return CategoryScheme(
                outerBg:     Color(hex: "F5E6A3"),   // light warm yellow
                innerBg:     Color(hex: "EDD040"),   // saturated yellow
                border:      Color(hex: "C9A800").opacity(0.5),
                textColor:   Color(hex: "3D2E00"),
                tabSelected: Color(hex: "EDD040"),
                tabText:     Color(hex: "3D2E00"),
                shadow:      Color(hex: "C9A800").opacity(0.35)
            )
        case .service:
            return CategoryScheme(
                outerBg:     Color(hex: "FAD4D4"),   // light warm pink
                innerBg:     Color(hex: "F4A0A0"),   // saturated rose
                border:      Color(hex: "C96060").opacity(0.4),
                textColor:   Color(hex: "4A1515"),
                tabSelected: Color(hex: "F4A0A0"),
                tabText:     Color(hex: "4A1515"),
                shadow:      Color(hex: "C96060").opacity(0.3)
            )
        case .expectations:
            return CategoryScheme(
                outerBg:     Color(hex: "C8EDD0"),   // light sage green
                innerBg:     Color(hex: "6BCB77"),   // saturated green
                border:      Color(hex: "3A8A44").opacity(0.4),
                textColor:   Color(hex: "0F3015"),
                tabSelected: Color(hex: "6BCB77"),
                tabText:     Color(hex: "0F3015"),
                shadow:      Color(hex: "3A8A44").opacity(0.3)
            )
        case .social:
            return CategoryScheme(
                outerBg:     Color(hex: "BEE0F5"),   // light sky blue
                innerBg:     Color(hex: "6AB8E8"),   // saturated blue
                border:      Color(hex: "2A6A9E").opacity(0.4),
                textColor:   Color(hex: "0A2540"),
                tabSelected: Color(hex: "6AB8E8"),
                tabText:     Color(hex: "0A2540"),
                shadow:      Color(hex: "2A6A9E").opacity(0.3)
            )
        }
    }
}

// MARK: - View
struct PromptSelectionView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var selectedTab: PromptCategory = .craftDetails
    @State private var selectedPromptForAnswer: Prompt? = nil
    @State private var showAnswerView = false

    private var answeredPrompts: [UUID: PromptAnswer] {
        coordinator.data.answeredPrompts
    }

    private let allPrompts: [Prompt] = [
        Prompt(question: "What did you notice that most people wouldn't?", category: .craftDetails),
        Prompt(question: "Did they do anything technical really well or really poorly?", category: .craftDetails),
        Prompt(question: "Was there anything about the quality of basics that stood out?", category: .craftDetails),
        Prompt(question: "What would a regular at this place know to ask for or avoid?", category: .craftDetails),

        Prompt(question: "How did they greet you and get you seated?", category: .service),
        Prompt(question: "Did the staff explain the menu or just take your order?", category: .service),
        Prompt(question: "How was the pacing?", category: .service),
        Prompt(question: "Did they notice things without you asking?", category: .service),
        Prompt(question: "How did they present the bill and handle payment?", category: .service),

        Prompt(question: "What did you order for the table?", category: .expectations),
        Prompt(question: "This would pair well with", category: .expectations),
        Prompt(question: "What were your expectations going in?", category: .expectations),
        Prompt(question: "Did it meet or exceed your expectations?", category: .expectations),

        Prompt(question: "Who would you confidently bring here vs who would you NOT bring here?", category: .social),
        Prompt(question: "Would you suggest this place to impress someone?", category: .social),
        Prompt(question: "Can you have a proper conversation here?", category: .social),
        Prompt(question: "Is this a place for a first date?", category: .social)
    ]

    private var currentPrompts: [Prompt] {
        allPrompts.filter { $0.category == selectedTab }
    }

    private var canContinue: Bool {
        answeredPrompts.count >= 3 && answeredPrompts.count <= 5
    }

    private func isAnswered(_ promptId: UUID) -> Bool {
        answeredPrompts[promptId] != nil
    }

    var body: some View {
        ZStack {
            Color(hex: "131313").ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                HStack {
                    Button(action: { coordinator.goBack() }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "232323"))
                                .overlay(Circle().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                                .frame(width: 36, height: 36)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    Spacer()
                    Text("Pick your prompts")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)

                // MARK: Tab Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PromptCategory.allCases, id: \.self) { category in
                            PromptTabButton(
                                category: category,
                                isSelected: selectedTab == category
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    selectedTab = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                }
                .padding(.bottom, 16)

                // MARK: Cards Grid
                ScrollView(showsIndicators: false) {
                    let columns = [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ]

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(currentPrompts) { prompt in
                            PromptCard(
                                prompt: prompt,
                                isAnswered: isAnswered(prompt.id)
                            ) {
                                coordinator.selectPromptToAnswer(prompt: prompt)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 100)
                }

                // MARK: Bottom
                VStack(spacing: 10) {
                    Text("\(answeredPrompts.count)/5 prompts answered")
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.4))

                    Button(action: { coordinator.completePromptSelection() }) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(canContinue ? .black : Color.white.opacity(0.3))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(canContinue ? Color.white : Color(hex: "242424"))
                                    GrainTextureView(opacity: 0.04)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .strokeBorder(
                                            canContinue ? Color.clear : Color.white.opacity(0.08),
                                            lineWidth: 1
                                        )
                                }
                            )
                    }
                    .disabled(!canContinue)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 32)
                .padding(.top, 8)
                .background(Color(hex: "131313"))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Tab Button

struct PromptTabButton: View {
    let category: PromptCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(category.rawValue)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? category.scheme.tabText : Color.white.opacity(0.4))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 50, style: .continuous)
                            .fill(isSelected ? category.scheme.tabSelected : Color(hex: "222222"))

                        if !isSelected {
                            RoundedRectangle(cornerRadius: 50, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Prompt Card

struct PromptCard: View {
    let prompt: Prompt
    let isAnswered: Bool
    let onTap: () -> Void

    private var scheme: CategoryScheme { prompt.category.scheme }

    // Outer border thickness — the "thick frame" between outer and inner box
    private let borderWidth: CGFloat = 5

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // ── OUTER BOX (lighter tint bg + thick colored border) ──
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(scheme.outerBg)
                .overlay(
                    // Thick inner border (the "box over box" gap)
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(scheme.innerBg, lineWidth: borderWidth)
                )
                .shadow(
                    color: scheme.shadow,
                    radius: 12, x: 0, y: 6
                )

            // ── INNER BOX (saturated fill, inset by borderWidth) ──
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(scheme.innerBg)
                .overlay(
                    // Grain on inner box
                    GrainTextureView(opacity: isAnswered ? 0.04 : 0.08)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                )
                // Top-light edge shimmer
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.25), Color.white.opacity(0.0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .padding(borderWidth)

            // ── QUESTION TEXT (on inner box) ──
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text(prompt.question)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(scheme.textColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(borderWidth + 12)  // inset past the border + comfortable margin

            // ── ANSWERED CHECKMARK ──
            if isAnswered {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(10)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .scaleEffect(1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.65), value: isAnswered)
    }
}

#Preview {
    PromptSelectionView(coordinator: CreateImpressionCoordinator())
}
