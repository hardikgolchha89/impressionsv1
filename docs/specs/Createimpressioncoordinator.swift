//
//  CreateImpressionCoordinator.swift
//  Impressions
//
//  Manages the creation flow for new impressions
//

import SwiftUI

// MARK: - Flow Steps
enum CreateFlowStep: Equatable {
    case placeSelection
    case mealSelection
    case companionsSelection
    case timeSelection
    case vibeSelection
    case foodOrder
    case photoUpload
    case promptSelection
    case promptAnswer(prompt: Prompt)
    case coverPhotoSelection
    case titleCustomization
    case publishSummary
}

// MARK: - Collected Data Model
struct ImpressionData {
    var place: Place?
    var meal: MealType?
    var companions: Set<CompanionType> = []
    var time: TimeOfDay?
    var vibe: VibeType?
    var dishes: [String] = []
    var photos: [UIImage] = []
    var answeredPrompts: [UUID: PromptAnswer] = [:]
    var coverPhoto: UIImage?
    var title: String = ""
}

// MARK: - Coordinator
class CreateImpressionCoordinator: ObservableObject {
    @Published var currentStep: CreateFlowStep = .placeSelection
    @Published var data = ImpressionData()
    @Published var navigationPath: [CreateFlowStep] = []
    
    // MARK: - Navigation Methods
    
    func start() {
        currentStep = .placeSelection
        navigationPath = []
        data = ImpressionData() // Reset data
    }
    
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
            if let lastStep = navigationPath.last {
                currentStep = lastStep
            } else {
                currentStep = .placeSelection
            }
        }
    }
    
    // MARK: - Step Completion Methods
    
    func completePlace(place: Place) {
        data.place = place
        advance(to: .mealSelection)
    }
    
    func completeMeal(meal: MealType) {
        data.meal = meal
        advance(to: .companionsSelection)
    }
    
    func completeCompanions(companions: Set<CompanionType>) {
        data.companions = companions
        advance(to: .timeSelection)
    }
    
    func completeTime(time: TimeOfDay) {
        data.time = time
        advance(to: .vibeSelection)
    }
    
    func completeVibe(vibe: VibeType) {
        data.vibe = vibe
        advance(to: .foodOrder)
    }
    
    func completeFoodOrder(dishes: [String]) {
        data.dishes = dishes
        advance(to: .photoUpload)
    }
    
    func completePhotoUpload(photos: [UIImage]) {
        data.photos = photos
        advance(to: .promptSelection)
    }
    
    func selectPromptToAnswer(prompt: Prompt) {
        advance(to: .promptAnswer(prompt: prompt))
    }
    
    func completePromptAnswer(prompt: Prompt, answer: PromptAnswer) {
        data.answeredPrompts[prompt.id] = answer
        
        // Go back to prompt selection
        advance(to: .promptSelection)
    }
    
    func completePromptSelection() {
        // User has answered 3-5 prompts, move to cover photo
        advance(to: .coverPhotoSelection)
    }
    
    func completeCoverPhoto(photo: UIImage) {
        data.coverPhoto = photo
        
        // Auto-generate title
        if let place = data.place,
           let meal = data.meal {
            let companionText = data.companions.first?.rawValue.lowercased() ?? "friends"
            data.title = "\(meal.rawValue) with \(companionText) at \(place.name), \(place.location ?? "")"
        }
        
        advance(to: .titleCustomization)
    }
    
    func completeTitle(title: String) {
        data.title = title
        advance(to: .publishSummary)
    }
    
    func publish() {
        // Save impression (mock for now)
        print("Publishing impression:")
        print("- Place: \(data.place?.name ?? "N/A")")
        print("- Title: \(data.title)")
        print("- Prompts answered: \(data.answeredPrompts.count)")
        
        // TODO: Navigate to feed or show success
        // For now, just reset
        start()
    }
    
    // MARK: - Private Helpers
    
    private func advance(to step: CreateFlowStep) {
        navigationPath.append(currentStep)
        currentStep = step
    }
    
    // MARK: - Computed Properties
    
    var canContinueToPublish: Bool {
        return data.answeredPrompts.count >= 3 && data.answeredPrompts.count <= 5
    }
}
