//
//  PromptAnswerView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI

// MARK: - View
struct PromptAnswerView: View {
    let prompt: Prompt
    let answeredCount: Int
    let existingAnswer: String?
    let onAnswerSaved: (String) -> Void
    /// When provided, used instead of dismiss() for back/discard. Also skips dismiss() after submit.
    /// Use for CreateImpressionFlowView where dismiss() would close the entire sheet.
    var onBack: (() -> Void)? = nil
    
    @State private var answerText: String = ""
    @State private var showDiscardAlert: Bool = false
    @FocusState private var isTextEditorFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    private var canSubmit: Bool {
        answerText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                HStack {
                    // Back button
                    Button(action: {
                        handleBackButton()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    // Progress indicator
                    Text("\(answeredCount)/5")
                        .font(AppFont.bodySmall)
                        .foregroundColor(.textSecondary)
                        .padding(.trailing, Spacing.md)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)
                
                ScrollView {
                    VStack(spacing: Spacing.md) {
                        // Prompt Display Card
                        PromptDisplayCard(prompt: prompt)
                            .padding(.horizontal, Spacing.md)
                            .padding(.top, Spacing.md)
                        
                        // Answer Input Area
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $answerText)
                                .font(AppFont.body)
                                .foregroundColor(.textPrimary)
                                .autocapitalization(.sentences)
                                .keyboardType(.default)
                                .focused($isTextEditorFocused)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 200)
                                .padding(Spacing.md)
                                .background(Color.cardBackground)
                                .cornerRadius(CornerRadius.large)
                            
                            // Placeholder text
                            if answerText.isEmpty {
                                Text("Your answer...")
                                    .font(AppFont.body)
                                    .foregroundColor(.textTertiary)
                                    .padding(.horizontal, Spacing.md + 4)
                                    .padding(.vertical, Spacing.md + 8)
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                        
                        // Bottom spacing for submit button
                        Spacer()
                            .frame(height: 100)
                    }
                }
                
                // Submit Button - Fixed at bottom
                VStack {
                    Button(action: {
                        handleSubmit()
                    }) {
                        Text("Submit Answer")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryButton()
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.md)
                    .disabled(!canSubmit)
                    .opacity(canSubmit ? 1.0 : 0.5)
                }
                .background(Color.appBackground)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            answerText = existingAnswer ?? ""
            // Auto-focus text editor
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextEditorFocused = true
            }
        }
        .alert("Discard answer?", isPresented: $showDiscardAlert) {
            Button("Discard", role: .destructive) {
                if let onBack = onBack {
                    onBack()
                } else {
                    dismiss()
                }
            }
            Button("Keep Writing", role: .cancel) { }
        }
    }
    
    // MARK: - Helper Methods
    private func handleBackButton() {
        let trimmedAnswer = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedAnswer.isEmpty {
            // No text entered, just go back
            if let onBack = onBack {
                onBack()
            } else {
                dismiss()
            }
        } else {
            // Text exists, show discard alert
            showDiscardAlert = true
        }
    }
    
    private func handleSubmit() {
        let trimmedAnswer = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedAnswer.count >= 10 {
            onAnswerSaved(trimmedAnswer)
            // When onBack is provided (creation flow), coordinator drives the view switch—don't dismiss
            if onBack == nil {
                dismiss()
            }
        }
    }
}

// MARK: - Prompt Display Card Component
struct PromptDisplayCard: View {
    let prompt: Prompt
    
    var body: some View {
        RoundedRectangle(cornerRadius: CornerRadius.large)
            .fill(prompt.category.color.color)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.large)
                    .stroke(Color.white, lineWidth: 1.5)
            )
            .shadow(
                color: AppShadow.cardMedium.color,
                radius: AppShadow.cardMedium.radius,
                x: AppShadow.cardMedium.x,
                y: AppShadow.cardMedium.y
            )
            .overlay(
                Text(prompt.question)
                    .font(AppFont.body)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Spacing.md)
                , alignment: .leading
            )
            .frame(minHeight: 60)
    }
}

#Preview {
    PromptAnswerView(
        prompt: Prompt(
            question: "What did you notice that most people wouldn't?",
            category: .craftDetails
        ),
        answeredCount: 2,
        existingAnswer: nil as String?,
        onAnswerSaved: { _ in }
    )
}
