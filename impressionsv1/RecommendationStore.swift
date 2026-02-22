//
//  RecommendationStore.swift
//  impressionsv1
//
//  Tracks which impressions the current user has credited ("This sent me").
//  Lives as an @Observable singleton injected via SwiftUI environment.
//  Credits are persisted to the ImpressionModel's creditCount in SwiftData.
//

import SwiftUI
import SwiftData

// MARK: - Notification Model

struct CreditNotification: Identifiable {
    let id = UUID()
    let message: String
}

// MARK: - Recommendation Store

@Observable
final class RecommendationStore {

    // MARK: State

    /// Set of impression IDs that the current user has credited this session.
    /// Persisted in UserDefaults so credits survive app restarts.
    private(set) var creditedIds: Set<String>

    /// Queued notification banner to show to the impression owner.
    var pendingNotification: CreditNotification?

    // MARK: Init

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: "creditedImpressionIds") ?? []
        self.creditedIds = Set(saved)
    }

    // MARK: Public API

    func isCredited(_ impressionId: String) -> Bool {
        creditedIds.contains(impressionId)
    }

    /// Toggles credit for an impression.
    /// - Parameters:
    ///   - impression: The impression being credited/uncredited.
    ///   - currentUserId: The ID of the current user — prevents self-crediting.
    ///   - context: SwiftData model context to persist the updated creditCount.
    ///   - authorName: Used in the notification copy (or nil for anonymous).
    func toggleCredit(
        for impressionId: String,
        impressionTitle: String,
        placeName: String,
        authorId: String,
        currentUserId: String,
        context: ModelContext,
        creditorName: String?
    ) {
        // Cannot credit own impression
        guard authorId != currentUserId else { return }

        if creditedIds.contains(impressionId) {
            // Undo credit
            creditedIds.remove(impressionId)
            persist(impressionId: impressionId, delta: -1, context: context)
        } else {
            // Give credit
            creditedIds.insert(impressionId)
            persist(impressionId: impressionId, delta: +1, context: context)

            // Fire notification for the owner (simulated in-app)
            let copy: String
            if let name = creditorName, !name.isEmpty, name != "You" {
                copy = "\(name) took your rec for \(placeName)."
            } else {
                copy = "Someone visited \(placeName) because of your impression."
            }
            pendingNotification = CreditNotification(message: copy)
        }

        // Persist credited set to UserDefaults
        UserDefaults.standard.set(Array(creditedIds), forKey: "creditedImpressionIds")
    }

    /// Total credits received across ALL impressions by the given author.
    /// Queried live from SwiftData — used for the profile recommendation score.
    func totalCreditsReceived(authorId: String, context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<ImpressionModel>()
        guard let all = try? context.fetch(descriptor) else { return 0 }
        return all
            .filter { $0.author?.id == authorId }
            .map { $0.creditCount }
            .reduce(0, +)
    }

    /// Per-place breakdown of credits for the profile page.
    func creditsPerPlace(authorId: String, context: ModelContext) -> [(placeName: String, count: Int)] {
        let descriptor = FetchDescriptor<ImpressionModel>()
        guard let all = try? context.fetch(descriptor) else { return [] }
        return all
            .filter { $0.author?.id == authorId && $0.creditCount > 0 }
            .map { ($0.placeName, $0.creditCount) }
            .sorted { $0.1 > $1.1 }
    }

    // MARK: Private

    private func persist(impressionId: String, delta: Int, context: ModelContext) {
        let descriptor = FetchDescriptor<ImpressionModel>(
            predicate: #Predicate { $0.id == impressionId }
        )
        guard let model = try? context.fetch(descriptor).first else { return }
        model.creditCount = max(0, model.creditCount + delta)
        try? context.save()
    }
}
