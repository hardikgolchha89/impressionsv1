//
//  Models.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 12/02/26.
//

import SwiftUI

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
    
    init(id: String = UUID().uuidString, type: WidgetType) {
        self.id = id
        self.type = type
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
