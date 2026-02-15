//
//  PriceRangeSelectionView.swift
//  impressionsv1
//
//  Price range selection step in create impression flow
//

import SwiftUI

// MARK: - Data Model
enum PriceRange: String, CaseIterable, Identifiable {
    case budget = "₹"
    case affordable = "₹₹"
    case moderate = "₹₹₹"
    case expensive = "₹₹₹₹"

    var id: String { rawValue }

    var displayName: String {
        rawValue
    }

    var description: String {
        switch self {
        case .budget: return "Budget friendly"
        case .affordable: return "Affordable"
        case .moderate: return "Moderate"
        case .expensive: return "Fine dining"
        }
    }
}

// MARK: - View
struct PriceRangeSelectionView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var selectedPriceRange: PriceRange? = nil

    // Grid columns configuration (2 columns for price range)
    private let columns = [
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
                    Text("What's the price range?")
                        .font(AppFont.title2)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    // Balance spacing
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)

                // Price Range Grid - Centered vertically
                Spacer()

                LazyVGrid(columns: columns, spacing: Spacing.sm) {
                    ForEach(PriceRange.allCases) { priceRange in
                        PriceRangeCard(
                            priceRange: priceRange,
                            isSelected: selectedPriceRange == priceRange
                        ) {
                            selectedPriceRange = priceRange
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)

                Spacer()

                // Continue Button
                VStack {
                    if let priceRange = selectedPriceRange {
                        Button(action: {
                            coordinator.completePriceRange(priceRange: priceRange)
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

// MARK: - Price Range Card Component
struct PriceRangeCard: View {
    let priceRange: PriceRange
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Card content
            VStack(spacing: Spacing.sm) {
                // Price symbols
                Text(priceRange.displayName)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.textPrimary)

                // Description
                Text(priceRange.description)
                    .font(AppFont.bodySmall)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xl)
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.large)

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
    PriceRangeSelectionView(coordinator: CreateImpressionCoordinator())
}
