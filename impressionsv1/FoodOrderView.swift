//
//  FoodOrderView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI

// MARK: - View
struct FoodOrderView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var dishesText: String = ""
    @FocusState private var isTextEditorFocused: Bool
    
    // Computed property to split into array
    var dishes: [String] {
        dishesText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
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
                        if !dishesText.isEmpty {
                            // TODO: Show alert "Discard changes?"
                        }
                        coordinator.goBack()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    // Title
                    Text("What did you order for the table?")
                        .font(AppFont.title2)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // Balance spacing
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)
                
                // Text Input Area - Centered vertically
                Spacer()
                
                ZStack(alignment: .topLeading) {
                    // Text Editor
                    TextEditor(text: $dishesText)
                        .font(AppFont.body)
                        .foregroundColor(.textPrimary)
                        .textInputAutocapitalization(.words)
                        .keyboardType(.default)
                        .focused($isTextEditorFocused)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 200)
                        .padding(Spacing.md)
                        .background(Color.cardBackground)
                        .cornerRadius(CornerRadius.large)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.large)
                                .stroke(Color.appBorder.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Placeholder text
                    if dishesText.isEmpty {
                        Text("Please write item names (one in each line)")
                            .font(AppFont.body)
                            .foregroundColor(.textTertiary)
                            .padding(.horizontal, Spacing.md + 4)
                            .padding(.vertical, Spacing.md + 8)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, Spacing.md)
                
                Spacer()
                
                // Continue Button
                VStack {
                    Button(action: {
                        coordinator.completeFoodOrder(dishes: dishes)
                    }) {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryButton()
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.md)
                    .disabled(dishesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(dishesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                }
                .background(Color.appBackground)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            isTextEditorFocused = false
        }
    }
}

#Preview {
    FoodOrderView(coordinator: CreateImpressionCoordinator())
}
