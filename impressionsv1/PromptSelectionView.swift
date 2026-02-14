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

// MARK: - View
struct PromptSelectionView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var selectedTab: PromptCategory = .craftDetails
    @State private var selectedPromptForAnswer: Prompt? = nil
    @State private var showAnswerView = false
    
    // Get answered prompts from coordinator
    private var answeredPrompts: [UUID: PromptAnswer] {
        coordinator.data.answeredPrompts
    }
    
    // Sample prompts for each category
    private let allPrompts: [Prompt] = [
        // Craft & Details (Yellow) - Exact questions from spec
        Prompt(question: "What did you notice that most people wouldn't?", category: .craftDetails),
        Prompt(question: "Did they do anything technical really well or really poorly?", category: .craftDetails),
        Prompt(question: "Was there anything about the quality of basics that stood out?", category: .craftDetails),
        Prompt(question: "What would a regular at this place know to ask for or avoid?", category: .craftDetails),
        
        // Service (Pink)
        Prompt(question: "How did they greet you and get you seated?", category: .service),
        Prompt(question: "Did the staff explain the menu or just take your order?", category: .service),
        Prompt(question: "How was the pacing?", category: .service),
        Prompt(question: "Did they notice things without you asking?", category: .service),
        Prompt(question: "How did they present the bill and handle payment?", category: .service),
        
        // Expectations (Green)
        Prompt(question: "What did you order for the table?", category: .expectations),
        Prompt(question: "This would pair well with", category: .expectations),
        Prompt(question: "What were your expectations going in?", category: .expectations),
        Prompt(question: "Did it meet or exceed your expectations?", category: .expectations),
        
        // Social (Blue)
        Prompt(question: "Who would you confidently bring here vs who would you NOT bring here?", category: .social),
        Prompt(question: "Would you suggest this place to impress someone?", category: .social),
        Prompt(question: "Can you have a proper conversation here?", category: .social),
        Prompt(question: "Is this a place for a first date?", category: .social)
    ]
    
    // Filtered prompts for current tab
    private var currentPrompts: [Prompt] {
        allPrompts.filter { $0.category == selectedTab }
    }
    
    // Check if can continue
    private var canContinue: Bool {
        answeredPrompts.count >= 3 && answeredPrompts.count <= 5
    }
    
    // Check if prompt is answered
    private func isAnswered(_ promptId: UUID) -> Bool {
        answeredPrompts[promptId] != nil
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section - Back button only
                HStack {
                    Button(action: {
                        coordinator.goBack()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)
                
                // Tab Bar - starts ~60pt from top
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.xs) { // 8pt spacing between tabs
                            ForEach(PromptCategory.allCases, id: \.self) { category in
                                TabButton(
                                    category: category,
                                    isSelected: selectedTab == category
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedTab = category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 6) // 6pt vertical padding
                    }
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.large)
                            .fill(Color.black.opacity(0.3)) // Semi-transparent black
                    )
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.lg) // ~60pt from top (24 + 16 + 20)
                    .onChange(of: selectedTab) { _ in
                        withAnimation {
                            proxy.scrollTo(selectedTab, anchor: .center)
                        }
                    }
                }
                
                // Prompt Cards List - 2-column grid
                ScrollView {
                    let columns = [
                        GridItem(.flexible(), spacing: Spacing.sm),
                        GridItem(.flexible(), spacing: Spacing.sm)
                    ]
                    
                    LazyVGrid(columns: columns, spacing: Spacing.sm) {
                        ForEach(currentPrompts) { prompt in
                            PromptCard(
                                prompt: prompt,
                                isAnswered: isAnswered(prompt.id)
                            ) {
                                // Navigate to answer view
                                coordinator.selectPromptToAnswer(prompt: prompt)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, 100) // Space for bottom section
                }
                
                // Bottom Section - Fixed at bottom
                VStack(spacing: Spacing.sm) {
                    // Answer Counter
                    Text("\(answeredPrompts.count)/5 prompts answered")
                        .font(AppFont.caption)
                        .foregroundColor(.textSecondary)
                    
                    // Continue Button
                    Button(action: {
                        coordinator.completePromptSelection()
                    }) {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryButton()
                    .padding(.horizontal, Spacing.md)
                    .disabled(!canContinue)
                    .opacity(canContinue ? 1.0 : 0.5)
                }
                .padding(.bottom, Spacing.md)
                .background(Color.appBackground)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let category: PromptCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(category.rawValue)
                .font(isSelected ? AppFont.bodyBold : AppFont.bodySmall)
                .foregroundColor(isSelected ? .black : .textSecondary)
                .padding(.horizontal, Spacing.xs) // 8pt horizontal padding
                .padding(.vertical, 6) // 6pt vertical padding
                .background(
                    isSelected ? category.color.color : Color.clear
                )
                .cornerRadius(CornerRadius.medium)
        }
    }
}

// MARK: - Prompt Card Component
struct PromptCard: View {
    let prompt: Prompt
    let isAnswered: Bool
    let onTap: () -> Void
    
    var body: some View {
        // Square card for 2-column grid
        ZStack(alignment: .topTrailing) {
            // Card background
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .fill(prompt.category.color.color)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.large)
                        .stroke(
                            isAnswered ? Color.white : Color.clear,
                            lineWidth: isAnswered ? 3 : 0
                        )
                )
                .shadow(
                    color: AppShadow.cardMedium.color,
                    radius: AppShadow.cardMedium.radius,
                    x: AppShadow.cardMedium.x,
                    y: AppShadow.cardMedium.y
                )
            
            // Card content - centered text
            VStack {
                Spacer()
                Text(prompt.question)
                    .font(AppFont.bodySmall)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(Spacing.sm)
                Spacer()
            }
            
            // Checkmark badge for answered prompts
            if isAnswered {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(8)
            }
        }
        .aspectRatio(1, contentMode: .fit) // Square aspect ratio
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}


#Preview {
    PromptSelectionView(coordinator: CreateImpressionCoordinator())
}
