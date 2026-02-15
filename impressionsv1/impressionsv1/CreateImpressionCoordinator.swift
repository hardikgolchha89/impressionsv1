//
//  CreateImpressionCoordinator.swift
//  Impressions
//
//  Manages the creation flow for new impressions
//

import SwiftUI
import SwiftData
import Combine

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
    @Published var data: ImpressionData = ImpressionData()
    @Published var navigationPath: [CreateFlowStep] = []

    // Dependencies (injected)
    var userManager: UserManager?
    var modelContext: ModelContext?
    var onPublishComplete: (() -> Void)?

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
    
    func completePromptAnswer(promptId: UUID, question: String, answerText: String) {
        let answer = PromptAnswer(
            promptId: promptId,
            question: question,
            answerText: answerText,
            timestamp: Date()
        )
        data.answeredPrompts[promptId] = answer

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
        print("🔵 publish() called")
        print("   - userManager: \(userManager != nil ? "✅" : "❌")")
        print("   - currentUser: \(userManager?.currentUser != nil ? "✅" : "❌")")
        print("   - modelContext: \(modelContext != nil ? "✅" : "❌")")

        guard let userManager = userManager,
              let currentUser = userManager.currentUser,
              let context = modelContext else {
            print("❌ Error: UserManager or ModelContext not available")
            print("   - Missing: userManager=\(userManager == nil), currentUser=\(userManager?.currentUser == nil), context=\(modelContext == nil)")
            return
        }

        // Build impression using ImpressionBuilder
        let impression = ImpressionBuilder.buildImpression(
            from: data,
            author: currentUser
        )

        // Insert into SwiftData
        // Note: We need to manually insert child objects because SwiftData doesn't
        // auto-cascade on insert (only on delete with deleteRule: .cascade)
        context.insert(impression)

        // Insert all child widgets
        impression.photoWidgets?.forEach { context.insert($0) }
        impression.quoteWidgets?.forEach { context.insert($0) }
        impression.infoWidgets?.forEach { context.insert($0) }
        impression.mapWidgets?.forEach { context.insert($0) }

        // Insert food grid widgets and their nested items
        impression.foodGridWidgets?.forEach { foodGrid in
            context.insert(foodGrid)
            foodGrid.items?.forEach { context.insert($0) }
        }

        // Insert order list widgets and their nested items
        impression.orderListWidgets?.forEach { orderList in
            context.insert(orderList)
            orderList.allItems?.forEach { context.insert($0) }
        }

        do {
            print("🔵 Saving to SwiftData...")
            try context.save()
            print("✅ SwiftData save successful")
            print("✅ Successfully published impression: \(data.title)")
            print("   - Place: \(data.place?.name ?? "N/A")")
            print("   - Prompts answered: \(data.answeredPrompts.count)")
            print("   - Photos: \(data.photos.count)")

            // CRITICAL: Reset state BEFORE calling completion to prevent race condition
            // This ensures coordinator state is clean when ContentView's @Query re-fetches
            print("🔵 Resetting coordinator state before callback")
            self.start()

            // Now notify completion and dismiss sheet
            print("🔵 Calling onPublishComplete callback...")
            onPublishComplete?()
        } catch {
            print("❌ Failed to save impression:")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Details: \(nsError.userInfo)")
            }
        }
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
