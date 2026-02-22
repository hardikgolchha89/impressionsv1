//
//  Models.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 12/02/26.
//

import SwiftUI
import SwiftData
import Foundation

// MARK: - Place (used in create flow + Google Places)

struct Place: Identifiable, Equatable {
    var id: String
    var name: String
    var location: String?
    var cuisine: String?
    // Google Places extras (optional)
    var googlePlaceId: String?
    var imageURL: String?
    var photoURL: URL?

    // Convenience init for static / seeded places
    init(id: String = UUID().uuidString, name: String, location: String? = nil, cuisine: String? = nil,
         googlePlaceId: String? = nil, imageURL: String? = nil, photoURL: URL? = nil) {
        self.id            = id
        self.name          = name
        self.location      = location
        self.cuisine       = cuisine
        self.googlePlaceId = googlePlaceId
        self.imageURL      = imageURL
        self.photoURL      = photoURL
    }
}

// MARK: - Impression Card Color (avoids conflict with DesignSystem.CardColor)
enum ImpressionCardColor {
    case pink
    case blue
    
    var color: Color {
        switch self {
        case .pink: return .appPink
        case .blue: return .appBlue
        }
    }
}

// MARK: - Author
struct Author: Identifiable {
    let id: String
    let name: String
    let profileImageUrl: String?
    
    init(id: String = UUID().uuidString, name: String, profileImageUrl: String? = nil) {
        self.id = id
        self.name = name
        self.profileImageUrl = profileImageUrl
    }
}

// MARK: - Widget Type
enum WidgetType {
    case photo(PhotoData)
    case quote(QuoteData)
    case info(InfoData)
    case map(MapData)
    case pairing(PairingWidgetData)
    case orderList(OrderListData)
    case foodGrid(FoodGridData)
}

// MARK: - Widget (wrapper for any widget type)
struct Widget: Identifiable {
    let id: String
    let type: WidgetType
    let gridSize: WidgetGridSize

    init(id: String = UUID().uuidString, type: WidgetType, gridSize: WidgetGridSize? = nil) {
        self.id = id
        self.type = type
        self.gridSize = gridSize ?? type.defaultGridSize
    }
}

// MARK: - Impression
struct Impression: Identifiable {
    let id: String
    let author: Author
    let timeAgo: String
    let title: String
    let placeName: String
    let companions: String
    let occasion: String
    let priceRange: String?  // e.g., "₹₹", "₹₹₹"
    let cardColor: ImpressionCardColor
    let previewWidgets: [Widget]  // First 2 widgets to show in feed card
    let allWidgets: [Widget]      // All widgets for detail view
    
    init(
        id: String = UUID().uuidString,
        author: Author,
        timeAgo: String,
        title: String,
        placeName: String,
        companions: String,
        occasion: String,
        priceRange: String? = nil,
        cardColor: ImpressionCardColor,
        previewWidgets: [Widget],
        allWidgets: [Widget]
    ) {
        self.id = id
        self.author = author
        self.timeAgo = timeAgo
        self.title = title
        self.placeName = placeName
        self.companions = companions
        self.occasion = occasion
        self.priceRange = priceRange
        self.cardColor = cardColor
        self.previewWidgets = previewWidgets
        self.allWidgets = allWidgets
    }
}

// MARK: - SwiftData Models

/// Author model for SwiftData persistence
@Model
final class AuthorModel {
    @Attribute(.unique) var id: String
    var name: String
    var profileImageUrl: String?
    var phoneNumber: String?
    /// Whether this user has completed the onboarding flow
    var isOnboarded: Bool

    @Relationship(deleteRule: .cascade, inverse: \ImpressionModel.author)
    var impressions: [ImpressionModel]?

    init(id: String = UUID().uuidString, name: String, profileImageUrl: String? = nil, phoneNumber: String? = nil, isOnboarded: Bool = false) {
        self.id = id
        self.name = name
        self.profileImageUrl = profileImageUrl
        self.phoneNumber = phoneNumber
        self.isOnboarded = isOnboarded
        self.impressions = []
    }

    /// Convert to struct for use in views
    var asStruct: Author {
        Author(id: id, name: name, profileImageUrl: profileImageUrl)
    }
}

/// Photo widget data model
@Model
final class PhotoDataModel {
    @Attribute(.unique) var id: String
    var imageUrl: String?
    var caption: String?
    var sortOrder: Int
    var gridSizeRawValue: String?

    @Relationship(inverse: \ImpressionModel.photoWidgets)
    var impression: ImpressionModel?

    init(id: String = UUID().uuidString, imageUrl: String? = nil, caption: String? = nil, sortOrder: Int = 0, gridSizeRawValue: String? = nil) {
        self.id = id
        self.imageUrl = imageUrl
        self.caption = caption
        self.sortOrder = sortOrder
        self.gridSizeRawValue = gridSizeRawValue
    }
}

/// Quote widget data model
@Model
final class QuoteDataModel {
    @Attribute(.unique) var id: String
    var prompt: String
    var answer: String
    var sortOrder: Int
    var gridSizeRawValue: String?

    @Relationship(inverse: \ImpressionModel.quoteWidgets)
    var impression: ImpressionModel?

    init(id: String = UUID().uuidString, prompt: String, answer: String, sortOrder: Int = 0, gridSizeRawValue: String? = nil) {
        self.id = id
        self.prompt = prompt
        self.answer = answer
        self.sortOrder = sortOrder
        self.gridSizeRawValue = gridSizeRawValue
    }
}

/// Info widget data model
@Model
final class InfoDataModel {
    @Attribute(.unique) var id: String
    var title: String?
    var content: String
    var icon: String?
    var sortOrder: Int
    var gridSizeRawValue: String?

    @Relationship(inverse: \ImpressionModel.infoWidgets)
    var impression: ImpressionModel?

    init(id: String = UUID().uuidString, title: String? = nil, content: String, icon: String? = nil, sortOrder: Int = 0, gridSizeRawValue: String? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.icon = icon
        self.sortOrder = sortOrder
        self.gridSizeRawValue = gridSizeRawValue
    }
}

/// Map widget data model
@Model
final class MapDataModel {
    @Attribute(.unique) var id: String
    var placeName: String
    var address: String
    var latitude: Double?
    var longitude: Double?
    var sortOrder: Int
    var gridSizeRawValue: String?

    @Relationship(inverse: \ImpressionModel.mapWidgets)
    var impression: ImpressionModel?

    init(id: String = UUID().uuidString, placeName: String, address: String, latitude: Double? = nil, longitude: Double? = nil, sortOrder: Int = 0, gridSizeRawValue: String? = nil) {
        self.id = id
        self.placeName = placeName
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.sortOrder = sortOrder
        self.gridSizeRawValue = gridSizeRawValue
    }
}

/// Food item model for FoodGrid widget
@Model
final class FoodItemModel {
    @Attribute(.unique) var id: String
    var name: String
    var imageName: String?

    @Relationship(inverse: \FoodGridDataModel.items)
    var foodGrid: FoodGridDataModel?

    init(id: String = UUID().uuidString, name: String, imageName: String? = nil) {
        self.id = id
        self.name = name
        self.imageName = imageName
    }
}

/// Food grid widget data model
@Model
final class FoodGridDataModel {
    @Attribute(.unique) var id: String
    var sortOrder: Int
    var gridSizeRawValue: String?

    @Relationship(deleteRule: .cascade)
    var items: [FoodItemModel]?

    @Relationship(inverse: \ImpressionModel.foodGridWidgets)
    var impression: ImpressionModel?

    init(id: String = UUID().uuidString, items: [FoodItemModel] = [], sortOrder: Int = 0, gridSizeRawValue: String? = nil) {
        self.id = id
        self.items = items
        self.sortOrder = sortOrder
        self.gridSizeRawValue = gridSizeRawValue
    }
}

/// Order item model for OrderList widget
@Model
final class OrderItemModel {
    @Attribute(.unique) var id: String
    var name: String
    var column: String // "left" or "right"

    @Relationship(inverse: \OrderListDataModel.allItems)
    var orderList: OrderListDataModel?

    init(id: String = UUID().uuidString, name: String, column: String = "left") {
        self.id = id
        self.name = name
        self.column = column
    }
}

/// Order list widget data model
@Model
final class OrderListDataModel {
    @Attribute(.unique) var id: String
    var title: String
    var sortOrder: Int
    var gridSizeRawValue: String?

    @Relationship(deleteRule: .cascade)
    var allItems: [OrderItemModel]?

    @Relationship(inverse: \ImpressionModel.orderListWidgets)
    var impression: ImpressionModel?

    init(id: String = UUID().uuidString, title: String, allItems: [OrderItemModel] = [], sortOrder: Int = 0, gridSizeRawValue: String? = nil) {
        self.id = id
        self.title = title
        self.allItems = allItems
        self.sortOrder = sortOrder
        self.gridSizeRawValue = gridSizeRawValue
    }

    /// Get items for left column
    var leftColumnItems: [OrderItemModel] {
        allItems?.filter { $0.column == "left" } ?? []
    }

    /// Get items for right column
    var rightColumnItems: [OrderItemModel] {
        allItems?.filter { $0.column == "right" } ?? []
    }
}

/// Pairing widget data model
@Model
final class PairingDataModel {
    @Attribute(.unique) var id: String
    var placeName: String
    var location: String
    var imageUrl: String?
    var sortOrder: Int
    var gridSizeRawValue: String?

    @Relationship(inverse: \ImpressionModel.pairingWidgets)
    var impression: ImpressionModel?

    init(id: String = UUID().uuidString, placeName: String, location: String, imageUrl: String? = nil, sortOrder: Int = 0, gridSizeRawValue: String? = nil) {
        self.id = id
        self.placeName = placeName
        self.location = location
        self.imageUrl = imageUrl
        self.sortOrder = sortOrder
        self.gridSizeRawValue = gridSizeRawValue
    }
}

/// Impression model for SwiftData persistence
@Model
final class ImpressionModel {
    @Attribute(.unique) var id: String
    var createdAt: Date
    var title: String
    var placeName: String
    var companions: String
    var occasion: String
    var priceRange: String?
    var cardColorRawValue: String // "pink" or "blue"

    @Relationship(deleteRule: .nullify)
    var author: AuthorModel?

    @Relationship(deleteRule: .cascade)
    var photoWidgets: [PhotoDataModel]?

    @Relationship(deleteRule: .cascade)
    var quoteWidgets: [QuoteDataModel]?

    @Relationship(deleteRule: .cascade)
    var infoWidgets: [InfoDataModel]?

    @Relationship(deleteRule: .cascade)
    var mapWidgets: [MapDataModel]?

    @Relationship(deleteRule: .cascade)
    var foodGridWidgets: [FoodGridDataModel]?

    @Relationship(deleteRule: .cascade)
    var orderListWidgets: [OrderListDataModel]?

    @Relationship(deleteRule: .cascade)
    var pairingWidgets: [PairingDataModel]?

    init(
        id: String = UUID().uuidString,
        createdAt: Date = Date(),
        title: String,
        placeName: String,
        companions: String,
        occasion: String,
        priceRange: String? = nil,
        cardColorRawValue: String = "pink",
        author: AuthorModel? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.placeName = placeName
        self.companions = companions
        self.occasion = occasion
        self.priceRange = priceRange
        self.cardColorRawValue = cardColorRawValue
        self.author = author
        self.photoWidgets = []
        self.quoteWidgets = []
        self.infoWidgets = []
        self.mapWidgets = []
        self.foodGridWidgets = []
        self.orderListWidgets = []
        self.pairingWidgets = []
    }

    /// Computed property for card color
    var cardColor: ImpressionCardColor {
        cardColorRawValue == "blue" ? .blue : .pink
    }

    /// Computed time ago string
    var timeAgo: String {
        let now = Date()
        let interval = now.timeIntervalSince(createdAt)

        let days = Int(interval / 86400)
        if days > 0 {
            return "\(days)d"
        }

        let hours = Int(interval / 3600)
        if hours > 0 {
            return "\(hours)h"
        }

        let minutes = Int(interval / 60)
        if minutes > 0 {
            return "\(minutes)m"
        }

        return "now"
    }

    /// Get all widgets sorted by sortOrder for preview (first 2)
    var previewWidgets: [Widget] {
        Array(allWidgets.prefix(2))
    }

    /// Get all widgets sorted by sortOrder, with grid sizes
    var allWidgets: [Widget] {
        // Collect (Widget, sortOrder) tuples so we can actually sort
        var entries: [(widget: Widget, sortOrder: Int)] = []

        photoWidgets?.forEach { model in
            let data = PhotoData(id: model.id, imageUrl: model.imageUrl, caption: model.caption)
            let gs = model.gridSizeRawValue.flatMap { WidgetGridSize(rawValue: $0) }
            entries.append((Widget(id: model.id, type: .photo(data), gridSize: gs), model.sortOrder))
        }

        quoteWidgets?.forEach { model in
            let data = QuoteData(id: model.id, prompt: model.prompt, answer: model.answer)
            let gs = model.gridSizeRawValue.flatMap { WidgetGridSize(rawValue: $0) }
            entries.append((Widget(id: model.id, type: .quote(data), gridSize: gs), model.sortOrder))
        }

        infoWidgets?.forEach { model in
            let data = InfoData(id: model.id, title: model.title, content: model.content, icon: model.icon)
            let gs = model.gridSizeRawValue.flatMap { WidgetGridSize(rawValue: $0) }
            entries.append((Widget(id: model.id, type: .info(data), gridSize: gs), model.sortOrder))
        }

        mapWidgets?.forEach { model in
            let data = MapData(id: model.id, placeName: model.placeName, address: model.address, latitude: model.latitude, longitude: model.longitude)
            let gs = model.gridSizeRawValue.flatMap { WidgetGridSize(rawValue: $0) }
            entries.append((Widget(id: model.id, type: .map(data), gridSize: gs), model.sortOrder))
        }

        foodGridWidgets?.forEach { model in
            let items = model.items?.map { FoodItem(id: $0.id, name: $0.name, imageName: $0.imageName) } ?? []
            let data = FoodGridData(id: model.id, items: items)
            let gs = model.gridSizeRawValue.flatMap { WidgetGridSize(rawValue: $0) }
            entries.append((Widget(id: model.id, type: .foodGrid(data), gridSize: gs), model.sortOrder))
        }

        orderListWidgets?.forEach { model in
            let leftItems = model.leftColumnItems.map { OrderItem(id: $0.id, name: $0.name) }
            let rightItems = model.rightColumnItems.map { OrderItem(id: $0.id, name: $0.name) }
            let data = OrderListData(id: model.id, title: model.title, leftColumnItems: leftItems, rightColumnItems: rightItems)
            let gs = model.gridSizeRawValue.flatMap { WidgetGridSize(rawValue: $0) }
            entries.append((Widget(id: model.id, type: .orderList(data), gridSize: gs), model.sortOrder))
        }

        pairingWidgets?.forEach { model in
            let data = PairingWidgetData(id: model.id, placeName: model.placeName, location: model.location, imageUrl: model.imageUrl)
            let gs = model.gridSizeRawValue.flatMap { WidgetGridSize(rawValue: $0) }
            entries.append((Widget(id: model.id, type: .pairing(data), gridSize: gs), model.sortOrder))
        }

        // Sort by sortOrder and return just the widgets
        return entries.sorted { $0.sortOrder < $1.sortOrder }.map(\.widget)
    }

    /// Convert to struct for use in views
    var asStruct: Impression {
        Impression(
            id: id,
            author: author?.asStruct ?? Author(id: "unknown", name: "Unknown"),
            timeAgo: timeAgo,
            title: title,
            placeName: placeName,
            companions: companions,
            occasion: occasion,
            priceRange: priceRange,
            cardColor: cardColor,
            previewWidgets: previewWidgets,
            allWidgets: allWidgets
        )
    }
}
