//
//  CreateImpressionFlowView.swift
//  Impressions
//
//  Main container view for the create impression flow
//

import SwiftUI
import SwiftData

struct CreateImpressionFlowView: View {
    @StateObject private var coordinator = CreateImpressionCoordinator()
    @Environment(UserManager.self) private var userManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                // Switch between screens based on current step
                Group {
                    switch coordinator.currentStep {
                    case .placeSelection:
                        PlaceSelectionView(coordinator: coordinator)
                        
                    case .mealSelection:
                        MealSelectionView(coordinator: coordinator)
                        
                    case .companionsSelection:
                        CompanionsSelectionView(coordinator: coordinator)
                        
                    case .timeSelection:
                        TimeSelectionView(coordinator: coordinator)
                        
                    case .vibeSelection:
                        VibeSelectionView(coordinator: coordinator)
                        
                    case .foodOrder:
                        FoodOrderView(coordinator: coordinator)
                        
                    case .photoUpload:
                        PhotoUploadView(coordinator: coordinator)
                        
                    case .promptSelection:
                        PromptSelectionView(coordinator: coordinator)
                        
                    case .promptAnswer(let prompt):
                        PromptAnswerView(
                            prompt: prompt,
                            answeredCount: coordinator.data.answeredPrompts.count,
                            existingAnswer: coordinator.data.answeredPrompts[prompt.id]?.answerText,
                            onAnswerSaved: { answerText in
                                coordinator.completePromptAnswer(
                                    promptId: prompt.id,
                                    question: prompt.question,
                                    answerText: answerText
                                )
                            },
                            onBack: { coordinator.goBack() }
                        )
                        
                    case .coverPhotoSelection:
                        CoverPhotoSelectionView(coordinator: coordinator)
                        
                    case .titleCustomization:
                        TitleCustomizationView(coordinator: coordinator)
                        
                    case .publishSummary:
                        PublishSummaryView(coordinator: coordinator)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                coordinator.userManager = userManager
                coordinator.modelContext = modelContext
                coordinator.onPublishComplete = {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    CreateImpressionFlowView()
}
