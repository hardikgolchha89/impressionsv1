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

        // Save cover photo to disk if available
        let coverPath: String? = data.coverPhoto.flatMap { saveCoverPhoto($0) }

        // Create the impression
        let impression = ImpressionModel(
            createdAt: Date(),
            title: data.title,
            placeName: data.place?.name ?? "Unknown Place",
            companions: formatCompanions(data.companions),
            occasion: data.meal?.rawValue ?? "Unknown",
            priceRange: data.priceRange?.rawValue,
            cardColorRawValue: randomCardColor(),
            coverPhotoPath: coverPath,
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
            let savedPath = saveImageAndGetPath(image, index: index)
            print("📸 Photo \(index): saved to \(savedPath)")
            let widget = PhotoDataModel(
                imageUrl: savedPath,
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

    /// Save cover photo to Documents directory and return absolute file path
    private static func saveCoverPhoto(_ image: UIImage) -> String? {
        let filename = "impression_cover_\(UUID().uuidString).jpg"

        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else { return nil }

        let fileURL = documentsDirectory.appendingPathComponent(filename)

        guard let imageData = image.jpegData(compressionQuality: 0.85) else { return nil }

        do {
            try imageData.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Failed to save cover photo: \(error)")
            return nil
        }
    }

    /// Save UIImage to Documents directory and return absolute file path
    private static func saveImageAndGetPath(_ image: UIImage, index: Int) -> String {
        // Generate unique filename using UUID
        let filename = "impression_photo_\(UUID().uuidString).jpg"

        // Get Documents directory
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            print("❌ Could not access Documents directory")
            return ""
        }

        // Create full file URL
        let fileURL = documentsDirectory.appendingPathComponent(filename)

        // Convert UIImage to JPEG data (compress to 0.8 quality for reasonable file size)
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Could not convert image to JPEG data")
            return ""
        }

        // Write to disk
        do {
            try imageData.write(to: fileURL)
            print("✅ Saved image to: \(fileURL.path)")
            return fileURL.path  // Return absolute file path
        } catch {
            print("❌ Failed to save image: \(error)")
            return ""
        }
    }
}
