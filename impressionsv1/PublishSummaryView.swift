//
//  PublishSummaryView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI

// MARK: - Data Model
struct SummaryItem {
    let label: String
    let detail: String
    let isComplete: Bool
    let prompts: [String]? // Optional list of prompt questions
}

// MARK: - View
struct PublishSummaryView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var isPublishing: Bool = false
    
    // Summary items from coordinator data
    private var summaryItems: [SummaryItem] {
        let title = coordinator.data.title
        let titleDetail = String(title.prefix(40)) + (title.count > 40 ? "..." : "")
        
        // Get actual prompt questions from coordinator if available
        // For now, use placeholder approach - we'll need to store prompts in coordinator
        let promptQuestionsList: [String] = [
            "What did you notice that most people wouldn't?",
            "Did they do anything technical really well or really poorly?",
            "How did they greet you and get you seated?"
        ]
        
        return [
            SummaryItem(
                label: "Cover photo",
                detail: coordinator.data.coverPhoto != nil ? "Selected" : "None",
                isComplete: coordinator.data.coverPhoto != nil,
                prompts: nil
            ),
            SummaryItem(
                label: "Title",
                detail: title.isEmpty ? "Not set" : titleDetail,
                isComplete: !title.isEmpty,
                prompts: nil
            ),
            SummaryItem(
                label: "Food items",
                detail: coordinator.data.dishes.isEmpty ? "None added" : "\(coordinator.data.dishes.count) dishes listed",
                isComplete: !coordinator.data.dishes.isEmpty,
                prompts: nil
            ),
            SummaryItem(
                label: "Photos",
                detail: coordinator.data.photos.isEmpty ? "No photos" : "\(coordinator.data.photos.count) photo\(coordinator.data.photos.count == 1 ? "" : "s")",
                isComplete: !coordinator.data.photos.isEmpty,
                prompts: nil
            ),
            SummaryItem(
                label: "Questions answered",
                detail: "\(coordinator.data.answeredPrompts.count) prompts",
                isComplete: coordinator.data.answeredPrompts.count >= 3,
                prompts: coordinator.data.answeredPrompts.count >= 3 ? promptQuestionsList : nil
            )
        ]
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
                    Text("Ready to publish?")
                        .font(AppFont.title2)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // Balance spacing
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)
                
                // Summary Cards - Centered vertically
                Spacer()
                
                VStack(spacing: Spacing.sm) {
                    ForEach(Array(summaryItems.enumerated()), id: \.offset) { _, item in
                        SummaryCard(item: item)
                    }
                }
                .padding(.horizontal, Spacing.md)
                
                Spacer()
                
                // Publish Button
                VStack {
                    Button(action: {
                        publishImpression()
                    }) {
                        HStack(spacing: Spacing.sm) {
                            if isPublishing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            }
                            Text(isPublishing ? "Publishing..." : "Publish to Feed")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .primaryButton()
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.md)
                    .disabled(isPublishing)
                    .opacity(isPublishing ? 0.6 : 1.0)
                }
                .background(Color.appBackground)
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Actions
    private func publishImpression() {
        isPublishing = true
        
        // Mock save (replace with real backend later)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isPublishing = false
            coordinator.publish()
        }
    }
}

// MARK: - Summary Card Component
struct SummaryCard: View {
    let item: SummaryItem
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            // Checkmark icon
            Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundColor(item.isComplete ? .green : .textTertiary)
                .padding(.top, 2) // Align with label text
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.label)
                    .font(AppFont.bodySmall)
                    .foregroundColor(.textSecondary)
                
                // Show prompts list if available, otherwise show detail text
                if let prompts = item.prompts {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(prompts.enumerated()), id: \.offset) { index, prompt in
                            HStack(alignment: .top, spacing: 6) {
                                Text("\(index + 1).")
                                    .font(AppFont.caption)
                                    .foregroundColor(.textSecondary)
                                
                                Text(prompt)
                                    .font(AppFont.caption)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    .padding(.leading, Spacing.xs)
                } else {
                    Text(item.detail)
                        .font(AppFont.body)
                        .foregroundColor(.textPrimary)
                }
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.medium)
    }
}

#Preview {
    PublishSummaryView(coordinator: CreateImpressionCoordinator())
}
