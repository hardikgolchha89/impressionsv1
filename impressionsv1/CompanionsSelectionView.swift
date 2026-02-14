//
//  CompanionsSelectionView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI

// MARK: - Data Model
enum CompanionType: String, CaseIterable, Identifiable, Hashable {
    case partner = "Partner"
    case family = "Family"
    case colleagues = "Colleague(s)"
    case solo = "Solo"
    case date = "Date"
    case friends = "Friends"
    case others = "Others"
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue
    }
}

// MARK: - View
struct CompanionsSelectionView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var selectedCompanion: CompanionType? = nil
    
    // Grid columns configuration (3 columns)
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]
    
    // Create array with 7 companion types + 2 empty slots for 3x3 grid
    private var gridItems: [CompanionType?] {
        var items: [CompanionType?] = CompanionType.allCases
        // Add 2 empty slots to make 9 total (3x3 grid)
        items.append(contentsOf: [nil, nil])
        return items
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
                        coordinator.goBack()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    // Title
                    Text("Who were you with?")
                        .font(AppFont.title2)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // Balance spacing
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)
                
                // Companion Grid - Centered vertically
                Spacer()
                
                LazyVGrid(columns: columns, spacing: Spacing.sm) {
                    ForEach(Array(gridItems.enumerated()), id: \.offset) { index, companionType in
                        if let companionType = companionType {
                            CompanionCard(
                                companionType: companionType,
                                isSelected: selectedCompanion == companionType
                            ) {
                                // Single-select: selecting new companion deselects previous
                                if selectedCompanion == companionType {
                                    selectedCompanion = nil
                                } else {
                                    selectedCompanion = companionType
                                }
                            }
                        } else {
                            // Empty slot
                            Color.clear
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                
                Spacer()
                
                // Continue Button (reserve space to prevent grid shift)
                VStack {
                    if let companion = selectedCompanion {
                        Button(action: {
                            coordinator.completeCompanions(companions: [companion])
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
        .navigationBarHidden(true)
    }
}

// MARK: - Companion Card Component
struct CompanionCard: View {
    let companionType: CompanionType
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
            
            // Companion type name centered
            Text(companionType.displayName)
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
    CompanionsSelectionView(coordinator: CreateImpressionCoordinator())
}
