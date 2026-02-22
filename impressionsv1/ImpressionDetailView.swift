//
//  ImpressionDetailView.swift
//  impressionsv1
//
//  Full impression view — redesigned to match feed_and_impressions design files.
//  Layout: place header → author+tags → order receipt → widget cards → footer CTA
//

import SwiftUI

// MARK: - Data Model

struct ImpressionDetail: Identifiable {
    let id: String
    let authorName: String
    let authorId: String
    let timeAgo: String
    let title: String
    let placeName: String
    let placeLocation: String?
    let companions: String
    let occasion: String
    let groupSize: String?
    let priceRange: String?
    let cardColor: ImpressionCardColor
    let coverPhotoPath: String?
    let widgets: [Widget]
    let creditCount: Int

    init(
        id: String = UUID().uuidString,
        authorName: String,
        authorId: String = "",
        timeAgo: String,
        title: String,
        placeName: String,
        placeLocation: String? = nil,
        companions: String,
        occasion: String,
        groupSize: String? = nil,
        priceRange: String? = nil,
        cardColor: ImpressionCardColor,
        coverPhotoPath: String? = nil,
        widgets: [Widget],
        creditCount: Int = 0
    ) {
        self.id = id
        self.authorName = authorName
        self.authorId = authorId
        self.timeAgo = timeAgo
        self.title = title
        self.placeName = placeName
        self.placeLocation = placeLocation
        self.companions = companions
        self.occasion = occasion
        self.groupSize = groupSize
        self.priceRange = priceRange
        self.cardColor = cardColor
        self.coverPhotoPath = coverPhotoPath
        self.widgets = widgets
        self.creditCount = creditCount
    }

    init(from impression: Impression) {
        self.id = impression.id
        self.authorName = impression.author.name
        self.authorId = impression.author.id
        self.timeAgo = impression.timeAgo
        self.title = impression.title
        self.placeName = impression.placeName
        self.placeLocation = nil
        self.companions = impression.companions
        self.occasion = impression.occasion
        self.groupSize = nil
        self.priceRange = impression.priceRange
        self.cardColor = impression.cardColor
        self.coverPhotoPath = impression.coverPhotoPath
        self.widgets = impression.allWidgets
        self.creditCount = impression.creditCount
    }
}

// MARK: - Widget card colour palette (same as feed card)

private let detailWidgetColors: [Color] = [
    Color(hex: "3D9B7A"),
    Color(hex: "E8A020"),
    Color(hex: "E05C7A"),
    Color(hex: "6B5BB8"),
    Color(hex: "4A6320"),
    Color(hex: "8B1A1A"),
]

private func detailWidgetColor(index: Int) -> Color {
    detailWidgetColors[index % detailWidgetColors.count]
}

// MARK: - ImpressionDetailView

struct ImpressionDetailView: View {
    let impression: ImpressionDetail
    @Environment(UserManager.self) private var userManager
    @Environment(RecommendationStore.self) private var store
    @Environment(HotlistStore.self) private var hotlist
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showShareCopied = false

    private var isOwnImpression: Bool {
        impression.authorId == userManager.currentUser?.id
    }

    private var hasCredited: Bool { store.creditedIds.contains(impression.id) }
    private var creditCount: Int {
        impression.creditCount + (hasCredited ? 1 : 0)
    }

    // Separate order widgets from prompt/impression widgets
    private var orderWidgets: [Widget] {
        impression.widgets.filter {
            if case .orderList = $0.type { return true }
            if case .foodGrid = $0.type { return true }
            return false
        }
    }
    private var impressionWidgets: [Widget] {
        impression.widgets.filter {
            if case .orderList = $0.type { return false }
            if case .foodGrid = $0.type { return false }
            return true
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appCream.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    placeHeader
                    authorAndTagsSection
                    if !orderWidgets.isEmpty { orderSection }
                    if !impressionWidgets.isEmpty { impressionSection }
                    tookItBanner
                    Spacer().frame(height: 100) // space for bottom bar
                }
            }

            // Floating bottom action bar
            bottomActionBar
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appBrown)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                }
            }
        }
    }

    // MARK: - Place Header

    private var placeHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover image or gradient placeholder
            ZStack(alignment: .bottomLeading) {
                if let coverPath = impression.coverPhotoPath,
                   !coverPath.isEmpty,
                   let uiImage = UIImage(contentsOfFile: coverPath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()
                } else {
                    // Gradient placeholder — will be replaced with place photo
                    LinearGradient(
                        colors: [Color.appOlive.opacity(0.6), Color.appForestGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                }

                // Place name overlay on image
                VStack(alignment: .leading, spacing: 4) {
                    Text(impression.placeName)
                        .font(.custom("HKGrotesk-Bold", size: 26))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 4, y: 2)

                    if let loc = impression.placeLocation {
                        Text(loc)
                            .font(.custom("HKGrotesk-Regular", size: 13))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.45)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }

    // MARK: - Author + Tags

    private var authorAndTagsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Author row
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.appOlive.opacity(0.15))
                        .frame(width: 38, height: 38)
                    Text(String(impression.authorName.prefix(1)).uppercased())
                        .font(.custom("HKGrotesk-SemiBold", size: 16))
                        .foregroundColor(.appOlive)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(impression.authorName)
                        .font(.custom("HKGrotesk-SemiBold", size: 14))
                        .foregroundColor(.appBrown)
                    Text("@\(impression.authorName.lowercased().replacingOccurrences(of: " ", with: "")) · \(impression.timeAgo) ago")
                        .font(.custom("HKGrotesk-Regular", size: 11))
                        .foregroundColor(.appBrown.opacity(0.5))
                }
                Spacer()
            }

            // Tags: occasion, companions, groupSize
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    TagPill(text: impression.occasion, color: Color(hex: "4CAF8A"))
                    TagPill(text: impression.companions, color: Color.appBrown.opacity(0.12), textColor: .appBrown)
                    if let groupSize = impression.groupSize {
                        TagPill(text: groupSize, color: Color.appBrown.opacity(0.12), textColor: .appBrown)
                    }
                    if let price = impression.priceRange {
                        TagPill(text: price, color: Color(hex: "E05C7A"))
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
    }

    // MARK: - Order Section

    private var orderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("WHAT THEY ORDERED")
                    .font(.custom("HKGrotesk-SemiBold", size: 10))
                    .foregroundColor(.appBrown.opacity(0.5))
                    .kerning(0.8)
            } icon: {
                Image(systemName: "fork.knife")
                    .font(.system(size: 11))
                    .foregroundColor(.appBrown.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            ForEach(orderWidgets) { widget in
                orderReceiptCard(widget: widget)
                    .padding(.horizontal, 16)
            }
        }
        .background(Color.appCream)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func orderReceiptCard(widget: Widget) -> some View {
        switch widget.type {
        case .orderList(let o):
            VStack(alignment: .leading, spacing: 0) {
                // "ORDER RECEIPT" micro-label
                Text("ORDER RECEIPT")
                    .font(.custom("HKGrotesk-SemiBold", size: 9))
                    .foregroundColor(.appBrown.opacity(0.45))
                    .kerning(1.0)
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 6)

                // Restaurant name as bold italic heading — matches design
                Text(impression.placeName)
                    .font(.custom("HKGrotesk-Bold", size: 18))
                    .foregroundColor(.appBrown)
                    .italic()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)

                Rectangle()
                    .fill(Color.appBrown.opacity(0.1))
                    .frame(height: 1)
                    .padding(.horizontal, 16)

                let allItems = o.leftColumnItems + o.rightColumnItems
                ForEach(Array(allItems.enumerated()), id: \.offset) { _, item in
                    Text(item.name)
                        .font(.custom("HKGrotesk-Regular", size: 15))
                        .foregroundColor(.appBrown)
                        .italic()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                }
                Spacer().frame(height: 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "F0DFA0")) // warm amber-parchment matching design
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

        case .foodGrid(let f):
            VStack(alignment: .leading, spacing: 0) {
                Text("ORDER RECEIPT")
                    .font(.custom("HKGrotesk-SemiBold", size: 9))
                    .foregroundColor(.appBrown.opacity(0.45))
                    .kerning(1.0)
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 6)

                Text(impression.placeName)
                    .font(.custom("HKGrotesk-Bold", size: 18))
                    .foregroundColor(.appBrown)
                    .italic()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)

                Rectangle()
                    .fill(Color.appBrown.opacity(0.1))
                    .frame(height: 1)
                    .padding(.horizontal, 16)

                ForEach(Array(f.items.enumerated()), id: \.offset) { _, item in
                    Text(item.name)
                        .font(.custom("HKGrotesk-Regular", size: 15))
                        .foregroundColor(.appBrown)
                        .italic()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                }
                Spacer().frame(height: 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "F0DFA0"))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

        default:
            EmptyView()
        }
    }

    // MARK: - Impression Section (prompt widgets)

    private var impressionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("THEIR IMPRESSION")
                    .font(.custom("HKGrotesk-SemiBold", size: 10))
                    .foregroundColor(.appBrown.opacity(0.5))
                    .kerning(0.8)
            } icon: {
                Image(systemName: "quote.bubble")
                    .font(.system(size: 11))
                    .foregroundColor(.appBrown.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // 2-column grid of prompt cards
            let cols = stride(from: 0, to: impressionWidgets.count, by: 2).map {
                Array(impressionWidgets[$0..<min($0 + 2, impressionWidgets.count)])
            }

            ForEach(Array(cols.enumerated()), id: \.offset) { rowIdx, pair in
                HStack(spacing: 10) {
                    ForEach(Array(pair.enumerated()), id: \.offset) { colIdx, widget in
                        detailWidgetCard(
                            widget: widget,
                            color: detailWidgetColor(index: rowIdx * 2 + colIdx)
                        )
                    }
                    if pair.count == 1 {
                        Color.clear.frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.appCream)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func detailWidgetCard(widget: Widget, color: Color) -> some View {
        let (title, body) = widgetContent(widget)
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.custom("HKGrotesk-SemiBold", size: 9))
                .foregroundColor(.white.opacity(0.7))
                .kerning(0.5)
                .lineLimit(2)

            Text(body)
                .font(.custom("HKGrotesk-Regular", size: 14))
                .foregroundColor(.white)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            // Photo caption if applicable
            if case .photo(let p) = widget.type, let cap = p.caption, !cap.isEmpty {
                Text(cap)
                    .font(.custom("HKGrotesk-Light", size: 11))
                    .foregroundColor(.white.opacity(0.7))
                    .italic()
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func widgetContent(_ widget: Widget) -> (title: String, body: String) {
        switch widget.type {
        case .quote(let q): return (q.prompt, q.answer)
        case .info(let i): return (i.title ?? "Detail", i.content)
        case .photo(let p): return ("Photo", p.caption ?? "")
        case .orderList(let o):
            let items = (o.leftColumnItems + o.rightColumnItems).map(\.name).joined(separator: "\n")
            return (o.title, items)
        case .foodGrid(let f):
            return ("What they ordered", f.items.map(\.name).joined(separator: "\n"))
        case .map(let m): return ("Location", "\(m.placeName)\n\(m.address)")
        case .pairing(let p): return ("Pairs well with", "\(p.placeName)\n\(p.location)")
        }
    }

    // MARK: - "Took It" Banner

    private var tookItBanner: some View {
        Group {
            if !isOwnImpression {
                HStack(spacing: 10) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 16))
                        .foregroundColor(.appAmber)
                    Text("\(creditCount) people have taken this recommendation. Did you?")
                        .font(.custom("HKGrotesk-Regular", size: 13))
                        .foregroundColor(.appBrown)
                    Spacer()
                }
                .padding(16)
                .background(Color.appOffWhite)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
    }

    // MARK: - Bottom Action Bar

    private var bottomActionBar: some View {
        HStack(spacing: 10) {
            // ✓ Credit pill
            if !isOwnImpression {
                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        store.toggleCredit(
                            for: impression.id,
                            impressionTitle: impression.title,
                            placeName: impression.placeName,
                            authorId: impression.authorId,
                            currentUserId: userManager.currentUser?.id ?? "",
                            context: modelContext,
                            creditorName: userManager.currentUser?.name
                        )
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: hasCredited ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 15, weight: .semibold))
                        Text("\(creditCount)")
                            .font(.custom("HKGrotesk-SemiBold", size: 14))
                    }
                    .foregroundColor(hasCredited ? .white : .appBrown)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(hasCredited ? Color(hex: "3D9B7A") : Color.appOffWhite)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(hasCredited ? Color.clear : Color.appGreige, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            // Share pill — network/share icon + count, toggles to "Copied!"
            Button {
                showShareCopied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    showShareCopied = false
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .medium))
                    Text(showShareCopied ? "Copied!" : "\(impression.creditCount + 12)")
                        .font(.custom("HKGrotesk-Regular", size: 14))
                }
                .foregroundColor(showShareCopied ? .appAmber : .appBrown)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.appOffWhite)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(showShareCopied ? Color.appAmber : Color.appGreige, lineWidth: 1))
                .animation(.easeInOut(duration: 0.2), value: showShareCopied)
            }
            .buttonStyle(.plain)

            Spacer()

            // Hotlist bookmark
            HotlistButton(impressionId: impression.id)
                .frame(width: 42, height: 42)
                .background(Color.appOffWhite)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.appGreige, lineWidth: 1))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.06), radius: 10, y: -4)
        )
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ImpressionDetailView(impression: ImpressionDetail(from: MockData.allImpressions[0]))
    }
}
