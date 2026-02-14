//
//  ImpressionBuilder.swift
//  impressionsv1
//
//  Converts ImpressionData from create flow to SwiftData ImpressionModel
//

import Foundation
import SwiftUI
import SwiftData

/// Service for building ImpressionModel from create flow data
struct ImpressionBuilder {

    /// Build a complete ImpressionModel from create flow data
    /// - Parameters:
    ///   - data: The collected data from the create flow
    ///   - author: The author creating this impression
    /// - Returns: A complete ImpressionModel ready to be inserted into SwiftData
    static func buildImpression(
        from data: ImpressionData,
        author: AuthorModel
    ) -> ImpressionModel {

        // Create the impression
        let impression = ImpressionModel(
            createdAt: Date(),
            title: data.title,
            placeName: data.place?.name ?? "Unknown Place",
            companions: formatCompanions(data.companions),
            occasion: data.meal?.rawValue ?? "Unknown",
            priceRange: nil, // TODO: Add price range if collected
            cardColorRawValue: randomCardColor(),
            author: author
        )

        // Build and attach all widgets
        var sortOrder = 0

        // 1. Add photo widgets
        let photoWidgets = buildPhotoWidgets(from: data.photos, startingSortOrder: &sortOrder)
        impression.photoWidgets = photoWidgets

        // 2. Add quote widgets (from answered prompts)
        let quoteWidgets = buildQuoteWidgets(from: data.answeredPrompts, startingSortOrder: &sortOrder)
        impression.quoteWidgets = quoteWidgets

        // 3. Add info widgets (vibe, time, etc.)
        let infoWidgets = buildInfoWidgets(from: data, startingSortOrder: &sortOrder)
        impression.infoWidgets = infoWidgets

        // 4. Add map widget (place location)
        if let mapWidget = buildMapWidget(from: data.place, sortOrder: &sortOrder) {
            impression.mapWidgets = [mapWidget]
        }

        // 5. Add food grid or order list widget
        if !data.dishes.isEmpty {
            if data.dishes.count <= 6 {
                // Use food grid for 6 or fewer items
                let foodGridWidget = buildFoodGridWidget(from: data.dishes, sortOrder: &sortOrder)
                impression.foodGridWidgets = [foodGridWidget]
            } else {
                // Use order list for more items
                let orderListWidget = buildOrderListWidget(from: data.dishes, sortOrder: &sortOrder)
                impression.orderListWidgets = [orderListWidget]
            }
        }

        return impression
    }

    // MARK: - Widget Builders

    /// Build photo widgets from uploaded images
    private static func buildPhotoWidgets(
        from photos: [UIImage],
        startingSortOrder: inout Int
    ) -> [PhotoDataModel] {
        return photos.enumerated().map { index, image in
            let widget = PhotoDataModel(
                imageUrl: saveImageAndGetPath(image, index: index),
                caption: nil,
                sortOrder: startingSortOrder
            )
            startingSortOrder += 1
            return widget
        }
    }

    /// Build quote widgets from answered prompts
    private static func buildQuoteWidgets(
        from answeredPrompts: [UUID: PromptAnswer],
        startingSortOrder: inout Int
    ) -> [QuoteDataModel] {

        return answeredPrompts.values.map { answer in
            let widget = QuoteDataModel(
                prompt: answer.question,
                answer: answer.answerText,
                sortOrder: startingSortOrder
            )
            startingSortOrder += 1
            return widget
        }
    }

    /// Build info widgets for metadata (vibe, time, etc.)
    private static func buildInfoWidgets(
        from data: ImpressionData,
        startingSortOrder: inout Int
    ) -> [InfoDataModel] {
        var widgets: [InfoDataModel] = []

        // Vibe info
        if let vibe = data.vibe {
            let widget = InfoDataModel(
                title: "What was the vibe?",
                content: vibe.rawValue,
                sortOrder: startingSortOrder
            )
            startingSortOrder += 1
            widgets.append(widget)
        }

        // Time info
        if let time = data.time {
            let widget = InfoDataModel(
                title: "When did you go?",
                content: time.rawValue,
                sortOrder: startingSortOrder
            )
            startingSortOrder += 1
            widgets.append(widget)
        }

        return widgets
    }

    /// Build map widget from place data
    private static func buildMapWidget(
        from place: Place?,
        sortOrder: inout Int
    ) -> MapDataModel? {
        guard let place = place else { return nil }

        let widget = MapDataModel(
            placeName: place.name,
            address: place.location ?? "",
            latitude: nil,
            longitude: nil,
            sortOrder: sortOrder
        )
        sortOrder += 1
        return widget
    }

    /// Build food grid widget from dishes
    private static func buildFoodGridWidget(
        from dishes: [String],
        sortOrder: inout Int
    ) -> FoodGridDataModel {
        let foodItems = dishes.map { dish in
            FoodItemModel(name: dish)
        }

        let widget = FoodGridDataModel(
            items: foodItems,
            sortOrder: sortOrder
        )
        sortOrder += 1
        return widget
    }

    /// Build order list widget from dishes (for larger lists)
    private static func buildOrderListWidget(
        from dishes: [String],
        sortOrder: inout Int
    ) -> OrderListDataModel {

        // Split dishes into two columns
        let midpoint = (dishes.count + 1) / 2
        let leftItems = dishes.prefix(midpoint).map { dish in
            OrderItemModel(name: dish, column: "left")
        }
        let rightItems = dishes.suffix(from: midpoint).map { dish in
            OrderItemModel(name: dish, column: "right")
        }

        let allItems = Array(leftItems) + Array(rightItems)

        let widget = OrderListDataModel(
            title: "What did you order for the table?",
            allItems: allItems,
            sortOrder: sortOrder
        )
        sortOrder += 1
        return widget
    }

    // MARK: - Helper Methods

    /// Format companions set into a readable string
    private static func formatCompanions(_ companions: Set<CompanionType>) -> String {
        if companions.isEmpty {
            return "Unknown"
        }

        let names = companions.map { $0.rawValue }

        if names.count == 1 {
            return names.first!
        } else if names.count == 2 {
            return names.joined(separator: " & ")
        } else {
            let allButLast = names.dropLast().joined(separator: ", ")
            return "\(allButLast) & \(names.last!)"
        }
    }

    /// Get random card color (alternates between pink and blue)
    private static func randomCardColor() -> String {
        Bool.random() ? "pink" : "blue"
    }

    /// Save UIImage and return a path/identifier
    /// For now, returns a placeholder. In production, would save to Documents directory.
    private static func saveImageAndGetPath(_ image: UIImage, index: Int) -> String {
        // TODO: Implement actual image saving to Documents directory
        // For now, return placeholder
        return "photo_\(index)"
    }
}
