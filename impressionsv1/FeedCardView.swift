//
//  FeedCardView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 08/02/26.
//

import SwiftUI

// MARK: - Main View
struct FeedCardView: View {
    let impression: Impression
    
    var body: some View {
        NavigationLink(destination: ImpressionDetailView(
            impression: ImpressionDetail(from: impression)
        )) {
            cardContent
        }
        .buttonStyle(.plain)
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Author Header
            HStack(spacing: Spacing.sm) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 36, height: 36)
                    
                    Text(String(impression.author.name.prefix(1)).uppercased())
                        .font(AppFont.author())
                        .foregroundColor(.white)
                }
                
                // Name + Timestamp
                VStack(alignment: .leading, spacing: 2) {
                    Text(impression.author.name)
                        .font(AppFont.author())
                        .foregroundColor(.appDarkText)
                    
                    Text(impression.timeAgo)
                        .font(AppFont.timestamp())
                        .foregroundColor(.appGrayText)
                }
                
                Spacer()
                
                // Price Range (if available)
                if let priceRange = impression.priceRange {
                    Text(priceRange)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appDarkText)
                }
            }
            .padding(.bottom, Spacing.lg)
            
            // Title
            Text(impression.title)
                .font(AppFont.title())
                .foregroundColor(.appDarkText)
                .lineLimit(3)
                .padding(.bottom, Spacing.lg)
            
            // Metadata Section
            VStack(alignment: .leading, spacing: Spacing.xs) {
                MetadataRow(icon: "mappin.circle.fill", text: impression.placeName)
                MetadataRow(icon: "person.2.fill", text: impression.companions)
                MetadataRow(icon: "calendar", text: impression.occasion)
            }
            .padding(.bottom, Spacing.lg)
            
            // Preview Widgets (first 2)
            if !impression.previewWidgets.isEmpty {
                HStack(spacing: Spacing.md) {
                    ForEach(Array(impression.previewWidgets.prefix(2))) { widget in
                        widgetView(for: widget)
                            .frame(maxWidth: .infinity)
                    }
                    
                    // If there's only 1 widget, add a placeholder for the second slot
                    if impression.previewWidgets.count == 1 {
                        WidgetPlaceholder()
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, Spacing.lg)
            }
            
            // Read Post Button
            HStack(spacing: 6) {
                Text("Read Post")
                    .font(AppFont.button)
                    .foregroundColor(.appDarkText)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.appDarkText)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(Spacing.xxl)
        .background(impression.cardColor.color)
        .cornerRadius(CornerRadius.card)
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 4,
            x: 0,
            y: 2
        )
    }
    
    // MARK: - Widget Rendering
    @ViewBuilder
    private func widgetView(for widget: Widget) -> some View {
        switch widget.type {
        case .photo(let photoData):
            PhotoWidget(photo: photoData)
        case .quote(let quoteData):
            QuoteWidget(quote: quoteData)
        case .info(let infoData):
            InfoWidget(info: infoData)
        case .map(let mapData):
            MapWidget(map: mapData)
        case .pairing(let pairingWidgetData):
            PairingWidget(pairing: pairingWidgetData)
        case .orderList(let orderListData):
            OrderListWidget(
                title: orderListData.title,
                leftColumnItems: orderListData.leftColumnItems,
                rightColumnItems: orderListData.rightColumnItems
            )
        case .foodGrid(let foodGridData):
            FoodGridWidget(items: foodGridData.items)
        }
    }
}

// MARK: - Metadata Row Helper
struct MetadataRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.appDarkText)
            
            Text(text)
                .font(AppFont.metadata())
                .foregroundColor(.appDarkText)
        }
    }
}

// MARK: - Widget Placeholder Helper
struct WidgetPlaceholder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: CornerRadius.widget)
            .fill(Color.gray.opacity(0.2))
            .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            ForEach(MockData.allImpressions.prefix(2)) { impression in
                FeedCardView(impression: impression)
            }
        }
        .padding(Spacing.lg)
    }
    .background(Color(hex: "F5F5F5"))
}

