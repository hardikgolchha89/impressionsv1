//
//  CreateImpressionCoordinator.swift
//  impressionsv1
//

import SwiftUI
import SwiftData
import Combine

// MARK: - Flow Steps

enum CreateFlowStep: Equatable, Hashable {
    case placeSelection
    case conversational       // What brought you / how many / who with
    case foodOrder            // What did you order
    case widgetBuilder        // Build your impression (prompts/widgets)
    case preview              // Looking good — preview before publish
    case publishSuccess       // Impression posted!

    // Legacy steps kept so old references compile (unused in new flow)
    case mealSelection
    case companionsSelection
    case priceRangeSelection
    case timeSelection
    case vibeSelection
    case photoUpload
    case promptSelection
    case promptAnswer(prompt: Prompt)
    case coverPhotoSelection
    case titleCustomization
    case widgetArrangement
    case referredBy
    case publishSummary
}

// MARK: - Widget Arrangement Item (kept for ImpressionBuilder compatibility)

struct WidgetArrangementItem: Identifiable, Equatable {
    let id: String
    var label: String
    var iconName: String
    var gridSize: WidgetGridSize
    var sortOrder: Int
    var widgetKey: String

    static func == (lhs: WidgetArrangementItem, rhs: WidgetArrangementItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Widget Answer (new model for widget builder)

struct WidgetAnswer: Identifiable, Equatable {
    let id: UUID
    let category: WidgetCategory
    let question: String
    var answer: String
    var attachments: [MediaAttachment] = []

    static func == (lhs: WidgetAnswer, rhs: WidgetAnswer) -> Bool {
        lhs.id == rhs.id &&
        lhs.category == rhs.category &&
        lhs.question == rhs.question &&
        lhs.answer == rhs.answer
    }
}

enum WidgetCategory: String, CaseIterable {
    case craftAndDetails = "Craft & Details"
    case service         = "Service"
    case expectations    = "Expectations"
    case social          = "Social"

    var color: Color {
        switch self {
        case .craftAndDetails: return Color(hex: "5C6B2E")   // olive
        case .service:         return Color(hex: "4A7A9B")   // slate blue
        case .expectations:    return Color(hex: "2979D4")   // blue
        case .social:          return Color(hex: "3DAA7A")   // teal green
        }
    }
}

// MARK: - Collected Data

struct ImpressionData {
    var place: Place?
    // Conversational answers
    var occasion: String = ""          // "What brought you here"
    var groupSize: String = ""         // "How many of you"
    var companions: String = ""        // "Who did you go with"
    // Food
    var dishes: [String] = []
    // Widget answers
    var widgetAnswers: [WidgetAnswer] = []
    // Legacy fields kept for ImpressionBuilder
    var meal: MealType?
    var companionsSet: Set<CompanionType> = []
    var priceRange: PriceRange?
    var time: TimeOfDay?
    var vibe: VibeType?
    var photos: [UIImage] = []
    var answeredPrompts: [UUID: PromptAnswer] = [:]
    var coverPhoto: UIImage?
    var title: String = ""
    var arrangedWidgets: [WidgetArrangementItem] = []
    var referredImpressionId: String? = nil
}

// MARK: - Coordinator

class CreateImpressionCoordinator: ObservableObject {
    @Published var currentStep: CreateFlowStep = .placeSelection
    @Published var data: ImpressionData = ImpressionData()
    @Published var navigationPath: [CreateFlowStep] = []

    var userManager: UserManager?
    var modelContext: ModelContext?
    var onPublishComplete: (() -> Void)?

    // MARK: Navigation

    func goBack() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
        currentStep = navigationPath.last ?? .placeSelection
    }

    private func advance(to step: CreateFlowStep) {
        navigationPath.append(currentStep)
        currentStep = step
    }

    // MARK: Step completions

    func completePlace(_ place: Place) {
        data.place = place
        advance(to: .conversational)
    }

    func completeConversational(occasion: String, groupSize: String, companions: String) {
        data.occasion   = occasion
        data.groupSize  = groupSize
        data.companions = companions
        // Auto-populate legacy fields so ImpressionBuilder works
        data.title      = "\(occasion) at \(data.place?.name ?? "")"
        advance(to: .foodOrder)
    }

    func completeFoodOrder(dishes: [String]) {
        data.dishes = dishes
        // Also push into legacy field
        advance(to: .widgetBuilder)
    }

    func completeWidgetBuilder(answers: [WidgetAnswer]) {
        data.widgetAnswers = answers
        // Mirror into answeredPrompts for ImpressionBuilder
        data.answeredPrompts = Dictionary(uniqueKeysWithValues: answers.map { wa in
            let pa = PromptAnswer(
                promptId: wa.id,
                question: wa.question,
                answerText: wa.answer,
                attachments: wa.attachments,
                timestamp: Date()
            )
            return (wa.id, pa)
        })
        // Build arrangement items
        data.arrangedWidgets = buildArrangementItems()
        advance(to: .preview)
    }

    func publish() -> Bool {
        guard let userManager, let currentUser = userManager.currentUser,
              let context = modelContext else { return false }

        // Build a minimal title if not set
        if data.title.isEmpty {
            data.title = "\(data.occasion) at \(data.place?.name ?? "Unknown")"
        }

        let impression = ImpressionBuilder.buildImpression(from: data, author: currentUser)

        context.insert(impression)
        impression.photoWidgets?.forEach    { context.insert($0) }
        impression.quoteWidgets?.forEach    { context.insert($0) }
        impression.infoWidgets?.forEach     { context.insert($0) }
        impression.mapWidgets?.forEach      { context.insert($0) }
        impression.pairingWidgets?.forEach  { context.insert($0) }
        impression.foodGridWidgets?.forEach { fg in
            context.insert(fg); fg.items?.forEach { context.insert($0) }
        }
        impression.orderListWidgets?.forEach { ol in
            context.insert(ol); ol.allItems?.forEach { context.insert($0) }
        }

        do {
            try context.save()
            advance(to: .publishSuccess)
            return true
        } catch {
            print("❌ Save failed: \(error)")
            return false
        }
    }

    func finishAndDismiss() {
        onPublishComplete?()
    }

    // MARK: - Arrangement builder (for ImpressionBuilder)

    private func buildArrangementItems() -> [WidgetArrangementItem] {
        var items: [WidgetArrangementItem] = []
        var order = 0

        for (_, answer) in data.answeredPrompts {
            items.append(WidgetArrangementItem(
                id: "quote_\(answer.promptId.uuidString)",
                label: String(answer.question.prefix(30)),
                iconName: "quote.opening",
                gridSize: .oneByOne,
                sortOrder: order,
                widgetKey: "quote_\(answer.promptId.uuidString)"
            ))
            order += 1
        }

        if !data.dishes.isEmpty {
            let key = data.dishes.count <= 6 ? "foodgrid" : "orderlist"
            items.append(WidgetArrangementItem(
                id: key, label: "Order", iconName: "list.bullet",
                gridSize: .twoByOne, sortOrder: order, widgetKey: key
            ))
            order += 1
        }

        if let place = data.place {
            items.append(WidgetArrangementItem(
                id: "map_place", label: "Map: \(place.name)", iconName: "mappin.circle",
                gridSize: .oneByOne, sortOrder: order, widgetKey: "map_place"
            ))
        }

        return items
    }

    // MARK: - Legacy stubs (keep old call sites compiling)

    func completePlace(place: Place)                    { completePlace(place) }
    func completeMeal(meal: MealType)                   { data.meal = meal }
    func completeCompanions(companions: Set<CompanionType>) { data.companionsSet = companions }
    func completePriceRange(priceRange: PriceRange)     { data.priceRange = priceRange }
    func completeTime(time: TimeOfDay)                  { data.time = time }
    func completeVibe(vibe: VibeType)                   { data.vibe = vibe }
    func completePhotoUpload(photos: [UIImage])         { data.photos = photos }
    func selectPromptToAnswer(prompt: Prompt)           {}
    func completePromptAnswer(promptId: UUID, question: String, answerText: String, attachments: [MediaAttachment] = []) {}
    func completePromptSelection()                      {}
    func completeCoverPhoto(photo: UIImage)             { data.coverPhoto = photo }
    func completeTitle(title: String)                   { data.title = title }
    func completeArrangement(widgets: [WidgetArrangementItem]) { data.arrangedWidgets = widgets }
    func completeReferredBy(referredImpressionId: String?) { data.referredImpressionId = referredImpressionId }
    var canContinueToPublish: Bool                      { data.widgetAnswers.count >= 3 }
}
