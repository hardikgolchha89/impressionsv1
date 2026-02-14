//
//  TimeSelectionView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI

// MARK: - Data Model
enum TimeOfDay: String, CaseIterable, Identifiable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case night = "Night"
    case others = "Others"
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue
    }
}

// MARK: - View
struct TimeSelectionView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var selectedTime: TimeOfDay? = nil
    
    // Grid columns configuration (3 columns)
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]
    
    // Create array with 5 time types + 1 empty slot for 3x2 grid (6 total)
    private var gridItems: [TimeOfDay?] {
        var items: [TimeOfDay?] = TimeOfDay.allCases
        // Add 1 empty slot to make 6 total (3x2 grid)
        items.append(nil)
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
                    Text("When did you go?")
                        .font(AppFont.title2)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // Balance spacing
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)
                
                // Time Grid - Centered vertically
                Spacer()
                
                LazyVGrid(columns: columns, spacing: Spacing.sm) {
                    ForEach(Array(gridItems.enumerated()), id: \.offset) { index, timeOfDay in
                        if let timeOfDay = timeOfDay {
                            TimeCard(
                                timeOfDay: timeOfDay,
                                isSelected: selectedTime == timeOfDay
                            ) {
                                // Single-select: selecting new time deselects previous
                                if selectedTime == timeOfDay {
                                    selectedTime = nil
                                } else {
                                    selectedTime = timeOfDay
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
                    if let time = selectedTime {
                        Button(action: {
                            coordinator.completeTime(time: time)
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

// MARK: - Time Card Component
struct TimeCard: View {
    let timeOfDay: TimeOfDay
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
            
            // Time period name centered
            Text(timeOfDay.displayName)
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
    TimeSelectionView(coordinator: CreateImpressionCoordinator())
}
