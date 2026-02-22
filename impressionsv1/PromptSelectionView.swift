//
//  PromptSelectionView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI

// MARK: - Data Model
struct Prompt: Identifiable, Equatable, Hashable {
    let id: UUID
    let question: String
    let category: PromptCategory

    init(id: UUID = UUID(), question: String, category: PromptCategory) {
        self.id = id
        self.question = question
        self.category = category
    }
}

// MARK: - Media Attachment
enum MediaType: String {
    case image
    case video
    case audio
}

struct MediaAttachment: Identifiable {
    let id: UUID
    let type: MediaType
    let data: Data
    let fileName: String
    let fileSize: Int  // bytes

    init(id: UUID = UUID(), type: MediaType, data: Data, fileName: String) {
        self.id = id
        self.type = type
        self.data = data
        self.fileName = fileName
        self.fileSize = data.count
    }

    /// 2 MB limit
    static let maxFileSize = 2 * 1024 * 1024

    var isOverSizeLimit: Bool {
        fileSize > Self.maxFileSize
    }

    var formattedSize: String {
        let kb = Double(fileSize) / 1024
        if kb < 1024 {
            return String(format: "%.0f KB", kb)
        }
        return String(format: "%.1f MB", kb / 1024)
    }
}

struct PromptAnswer {
    let promptId: UUID
    let question: String
    let answerText: String
    let attachments: [MediaAttachment]
    let timestamp: Date

    init(promptId: UUID, question: String, answerText: String, attachments: [MediaAttachment] = [], timestamp: Date = Date()) {
        self.promptId = promptId
        self.question = question
        self.answerText = answerText
        self.attachments = attachments
        self.timestamp = timestamp
    }
}

// MARK: - Category Color Scheme

struct CategoryScheme {
    let outerBg: Color       // pastel tint — the "outer box" background / frame
    let innerBg: Color       // vivid saturated — the "inner box" fill
    let tabAccent: Color     // underline accent on selected tab
    let shadow: Color        // drop shadow tint
}

extension PromptCategory {
    var scheme: CategoryScheme {
        switch self {
        case .craftDetails:
            return CategoryScheme(
                outerBg:    Color(hex: "F0D060"),   // warm pastel amber
                innerBg:    Color(hex: "C88000"),   // deep burnt amber
                tabAccent:  Color(hex: "F0C040"),
                shadow:     Color(hex: "C88000").opacity(0.45)
            )
        case .service:
            return CategoryScheme(
                outerBg:    Color(hex: "F0B0C8"),   // soft pink-lavender
                innerBg:    Color(hex: "C03080"),   // vivid magenta-pink
                tabAccent:  Color(hex: "E040A0"),
                shadow:     Color(hex: "C03080").opacity(0.45)
            )
        case .expectations:
            return CategoryScheme(
                outerBg:    Color(hex: "90DDB0"),   // bright pastel mint
                innerBg:    Color(hex: "107840"),   // deep forest green
                tabAccent:  Color(hex: "30C060"),
                shadow:     Color(hex: "107840").opacity(0.45)
            )
        case .social:
            return CategoryScheme(
                outerBg:    Color(hex: "90C8F0"),   // bright pastel sky blue
                innerBg:    Color(hex: "1050A0"),   // deep royal blue
                tabAccent:  Color(hex: "3080E0"),
                shadow:     Color(hex: "1050A0").opacity(0.45)
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
        answeredPrompts.count >= 3
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
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
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
                        .padding(.top, 4)
                    }

                    // Subtle separator line beneath tabs
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)
                }
                .padding(.bottom, 20)

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
                    Text(answeredPrompts.count < 3
                         ? "Minimum 3 prompts required (\(answeredPrompts.count) done)"
                         : "\(answeredPrompts.count) prompts answered ✓")
                        .font(.system(size: 13))
                        .foregroundColor(answeredPrompts.count < 3
                            ? Color.white.opacity(0.4)
                            : Color(hex: "6BCB77").opacity(0.9))

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
            VStack(spacing: 6) {
                Text(category.rawValue)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : Color.white.opacity(0.35))

                // Underline indicator
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(isSelected ? category.scheme.tabAccent : Color.clear)
                    .frame(height: 2)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 2)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.2, dampingFraction: 0.75), value: isSelected)
    }
}

// MARK: - Prompt Card

struct PromptCard: View {
    let prompt: Prompt
    let isAnswered: Bool
    let onTap: () -> Void

    private var scheme: CategoryScheme { prompt.category.scheme }

    // Thickness of the pastel outer frame visible between outer and inner box
    private let frameWidth: CGFloat = 8

    var body: some View {
        ZStack(alignment: .topTrailing) {

            // ── OUTER BOX: pastel tint — forms the visible "frame" around the inner box ──
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(scheme.outerBg)
                .shadow(color: scheme.shadow, radius: 14, x: 0, y: 8)

            // ── INNER BOX: vivid saturated fill, inset by frameWidth ──
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(scheme.innerBg)
                .overlay(
                    // Grain texture for depth
                    GrainTextureView(opacity: isAnswered ? 0.06 : 0.12)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                )
                // Top-edge light shimmer
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.30), Color.white.opacity(0.0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .padding(frameWidth)

            // ── QUESTION TEXT: always white on vivid inner box ──
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text(prompt.question)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                Spacer()
            }
            .padding(frameWidth + 10)   // clear the frame + comfortable margin

            // ── ANSWERED CHECKMARK ──
            if isAnswered {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 26, height: 26)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(frameWidth + 2)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .animation(.spring(response: 0.2, dampingFraction: 0.65), value: isAnswered)
    }
}

#Preview {
    PromptSelectionView(coordinator: CreateImpressionCoordinator())
}
