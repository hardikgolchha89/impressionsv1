//
//  ImpressionDetailView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 08/02/26.
//

import SwiftUI

// MARK: - Data Model
struct ImpressionDetail: Identifiable {
    let id: String
    let authorName: String
    let timeAgo: String
    let title: String
    let placeName: String
    let companions: String
    let occasion: String
    let priceRange: String?
    let cardColor: ImpressionCardColor
    let coverPhotoPath: String?
    let widgets: [Widget]

    init(
        id: String = UUID().uuidString,
        authorName: String,
        timeAgo: String,
        title: String,
        placeName: String,
        companions: String,
        occasion: String,
        priceRange: String? = nil,
        cardColor: ImpressionCardColor,
        coverPhotoPath: String? = nil,
        widgets: [Widget]
    ) {
        self.id = id
        self.authorName = authorName
        self.timeAgo = timeAgo
        self.title = title
        self.placeName = placeName
        self.companions = companions
        self.occasion = occasion
        self.priceRange = priceRange
        self.cardColor = cardColor
        self.coverPhotoPath = coverPhotoPath
        self.widgets = widgets
    }

    // Convert from Impression
    init(from impression: Impression) {
        self.id = impression.id
        self.authorName = impression.author.name
        self.timeAgo = impression.timeAgo
        self.title = impression.title
        self.placeName = impression.placeName
        self.companions = impression.companions
        self.occasion = impression.occasion
        self.priceRange = impression.priceRange
        self.cardColor = impression.cardColor
        self.coverPhotoPath = impression.coverPhotoPath
        self.widgets = impression.allWidgets
    }
}

// MARK: - Main View
struct ImpressionDetailView: View {
    let impression: ImpressionDetail
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image
                if let coverPath = impression.coverPhotoPath,
                   !coverPath.isEmpty,
                   let uiImage = UIImage(contentsOfFile: coverPath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                        .clipped()
                } else {
                    // Placeholder when no cover photo
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))

                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 400)
                }
                
                // Content Container
                VStack(alignment: .leading, spacing: 0) {
                    // Title
                    Text(impression.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.appDarkText)
                        .lineLimit(nil)
                        .padding(.bottom, Spacing.lg)
                    
                    // Author Header with Actions
                    HStack {
                        // Author info (left side)
                        HStack(spacing: Spacing.sm) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 40)
                                
                                Text(String(impression.authorName.prefix(1)).uppercased())
                                    .font(AppFont.author())
                                    .foregroundColor(.white)
                            }
                            
                            // Name + Timestamp
                            VStack(alignment: .leading, spacing: 2) {
                                Text(impression.authorName)
                                    .font(AppFont.author())
                                    .foregroundColor(.appDarkText)
                                
                                Text(impression.timeAgo)
                                    .font(AppFont.timestamp())
                                    .foregroundColor(.appGrayText)
                            }
                        }
                        
                        Spacer()
                        
                        // Action icons (right side)
                        HStack(spacing: Spacing.md) {
                            // Share icon
                            Button(action: {
                                // Placeholder action
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 22))
                                    .foregroundColor(.appDarkText)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.plain)
                            
                            // Recommend icon
                            Button(action: {
                                // Placeholder action
                            }) {
                                Image(systemName: "star.circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(.appDarkText)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, Spacing.lg)
                    
                    // Metadata Section
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        MetadataRow(icon: "mappin.circle.fill", text: impression.placeName)
                        MetadataRow(icon: "person.2.fill", text: impression.companions)
                        MetadataRow(icon: "calendar", text: impression.occasion)
                    }
                    .padding(.bottom, Spacing.xl)
                    
                    // Widgets Grid - Dynamic Rendering
                    renderWidgets()
                        .padding(.bottom, 40)
                }
                .padding(Spacing.xxl)
                .background(impression.cardColor.color)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .cornerRadius(24)
                .offset(y: -20)
            }
        }
        .background(Color(hex: "F5F5F5"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Widget Rendering Functions
    
    /// Group widgets into rows (pairing consecutive half-width widgets)
    private var widgetRows: [[Widget]] {
        var rows: [[Widget]] = []
        var index = 0
        let widgetCount = impression.widgets.count
        
        while index < widgetCount {
            let currentWidget = impression.widgets[index]
            
            // Check if current widget is half-width and if there's a next widget that's also half-width
            if isHalfWidthWidget(currentWidget.type) && 
               index + 1 < widgetCount && 
               isHalfWidthWidget(impression.widgets[index + 1].type) {
                // Group two half-width widgets together
                rows.append([currentWidget, impression.widgets[index + 1]])
                index += 2
            } else {
                // Single widget (full or half width alone)
                rows.append([currentWidget])
                index += 1
            }
        }
        
        return rows
    }
    
    /// Renders all widgets with smart layout logic
    @ViewBuilder
    private func renderWidgets() -> some View {
        VStack(spacing: Spacing.md) {
            ForEach(Array(widgetRows.enumerated()), id: \.offset) { _, row in
                if row.count == 2 {
                    // Two half-width widgets side by side
                    HStack(alignment: .top, spacing: Spacing.md) {
                        renderWidget(row[0])
                            .frame(maxWidth: .infinity)
                        
                        renderWidget(row[1])
                            .frame(maxWidth: .infinity)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                } else {
                    // Single widget (full or half width alone)
                    renderWidget(row[0])
                }
            }
        }
    }
    
    /// Determines if a widget type should be half-width
    private func isHalfWidthWidget(_ widgetType: WidgetType) -> Bool {
        switch widgetType {
        case .quote, .photo, .info, .map:
            return true
        case .foodGrid, .orderList, .pairing:
            return false
        }
    }
    
    /// Renders a single widget based on its type
    @ViewBuilder
    private func renderWidget(_ widget: Widget) -> some View {
        switch widget.type {
        case .foodGrid(let foodGridData):
            FoodGridWidget(items: foodGridData.items)
            
        case .quote(let quoteData):
            QuoteWidget(quote: quoteData)
            
        case .orderList(let orderListData):
            OrderListWidget(
                title: orderListData.title,
                leftColumnItems: orderListData.leftColumnItems,
                rightColumnItems: orderListData.rightColumnItems
            )
            
        case .photo(let photoData):
            PhotoWidget(photo: photoData)
            
        case .pairing(let pairingWidgetData):
            PairingWidget(pairing: pairingWidgetData)
            
        case .info(let infoData):
            InfoWidget(info: infoData)
            
        case .map(let mapData):
            MapWidget(map: mapData)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ImpressionDetailView(impression: ImpressionDetail(from: MockData.allImpressions[0]))
    }
}
