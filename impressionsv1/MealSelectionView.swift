//
//  MealSelectionView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI

// MARK: - Data Model
enum MealType: String, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case brunch = "Brunch"
    case lunch = "Lunch"
    case coffee = "Coffee"
    case dinner = "Dinner"
    case others = "Others"
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue
    }
}

// MARK: - View
struct MealSelectionView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var selectedMeal: MealType? = nil
    
    // Grid columns configuration (3 columns)
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                HStack {
                    // Back button
                    Button(action: {
                        coordinator.goBack()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    // Title
                    Text("What meal was this?")
                        .font(AppFont.title2)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // Balance spacing
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)
                
                // Meal Grid - Centered vertically
                Spacer()
                
                LazyVGrid(columns: columns, spacing: Spacing.sm) {
                    ForEach(MealType.allCases) { mealType in
                        MealCard(
                            mealType: mealType,
                            isSelected: selectedMeal == mealType
                        ) {
                            // Single-select: selecting new meal deselects previous
                            selectedMeal = mealType
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                
                Spacer()
                
                // Continue Button (reserve space to prevent grid shift)
                VStack {
                    if let meal = selectedMeal {
                        Button(action: {
                            coordinator.completeMeal(meal: meal)
                        }) {
                            Text("Continue")
                                .frame(maxWidth: .infinity)
                        }
                        .primaryButton()
                        .padding(.horizontal, Spacing.md)
                        .padding(.bottom, Spacing.md)
                        .transition(.opacity)
                    } else {
                        // Invisible spacer to maintain layout
                        Color.clear
                            .frame(height: 60)
                            .padding(.bottom, Spacing.md)
                    }
                }
                .background(Color.appBackground)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Meal Card Component
struct MealCard: View {
    let mealType: MealType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background image with dimming and gradient overlay
            ZStack(alignment: .bottom) {
                // Dimmed background image
                Image(systemName: "fork.knife")
                    .font(.system(size: 40))
                    .foregroundColor(.textSecondary)
                    .opacity(0.3)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.cardBackground)
                
                // Dark gradient overlay from bottom
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.7)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(CornerRadius.large)
            
            // Meal name centered
            Text(mealType.displayName)
                .font(AppFont.bodyBold)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Selection checkmark
            if isSelected {
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.small)
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(8)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    MealSelectionView(coordinator: CreateImpressionCoordinator())
}
