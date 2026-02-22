//
//  FeedCardView.swift
//  impressionsv1
//
//  Feed card (quick view) — redesigned to match feed_and_impressions design files.
//  Tapping the place row opens the full impression. Bottom row: credit + share + "Full view →"
//

import SwiftUI

// MARK: - Widget card colours (matches design: teal, yellow, pink, purple/blue)
private let widgetCardColors: [Color] = [
    Color(hex: "3D9B7A"),  // teal
    Color(hex: "E8A020"),  // amber/yellow
    Color(hex: "E05C7A"),  // pink/rose
    Color(hex: "6B5BB8"),  // purple
    Color(hex: "4A6320"),  // forest green
    Color(hex: "8B1A1A"),  // crimson
]

private func widgetColor(index: Int) -> Color {
    widgetCardColors[index % widgetCardColors.count]
}

// MARK: - FeedCardView

struct FeedCardView: View {
    let impression: Impression
    @State private var showDetail = false
    @Environment(UserManager.self) private var userManager
    @Environment(RecommendationStore.self) private var store
    @Environment(HotlistStore.self) private var hotlist
    @Environment(\.modelContext) private var modelContext

    private var isOwnImpression: Bool {
        impression.author.id == userManager.currentUser?.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Author row ─────────────────────────────────────────
            authorRow
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

            // ── Place row (tapping opens full impression) ──────────
            Button { showDetail = true } label: {
                placeRow
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // ── Tags row ───────────────────────────────────────────
            tagsRow
                .padding(.horizontal, 16)
                .padding(.bottom, 14)

            // ── 2×2 Widget grid preview ────────────────────────────
            if !impression.previewWidgets.isEmpty {
                widgetGrid
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
            }

            // ── Bottom action row ──────────────────────────────────
            bottomRow
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .navigationDestination(isPresented: $showDetail) {
            ImpressionDetailView(impression: ImpressionDetail(from: impression))
        }
    }

    // MARK: - Author Row

    private var authorRow: some View {
        HStack(spacing: 10) {
            // Avatar circle
            ZStack {
                Circle()
                    .fill(isOwnImpression ? Color.appCrimson.opacity(0.15) : Color.appOlive.opacity(0.15))
                    .frame(width: 36, height: 36)
                Text(String(impression.author.name.prefix(1)).uppercased())
                    .font(.custom("HKGrotesk-SemiBold", size: 15))
                    .foregroundColor(isOwnImpression ? .appCrimson : .appOlive)
            }

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 5) {
                    Text(impression.author.name)
                        .font(.custom("HKGrotesk-SemiBold", size: 14))
                        .foregroundColor(.appBrown)
                    if isOwnImpression {
                        Text("YOU")
                            .font(.custom("HKGrotesk-Bold", size: 9))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.appCrimson)
                            .clipShape(Capsule())
                    }
                }
                Text("@\(impression.author.name.lowercased().replacingOccurrences(of: " ", with: "")) · \(impression.timeAgo) ago")
                    .font(.custom("HKGrotesk-Regular", size: 11))
                    .foregroundColor(.appBrown.opacity(0.5))
            }

            Spacer()

            // Hotlist (bookmark) button
            HotlistButton(impressionId: impression.id)
        }
    }

    // MARK: - Place Row

    private var placeRow: some View {
        HStack(spacing: 12) {
            // Place image placeholder (square, rounded) — will be Google Maps image
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.appOlive.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.appOlive.opacity(0.6))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(impression.placeName)
                    .font(.custom("HKGrotesk-Bold", size: 16))
                    .foregroundColor(.appBrown)
                    .lineLimit(1)

                if let location = impression.placeLocation {
                    Text(location)
                        .font(.custom("HKGrotesk-Regular", size: 12))
                        .foregroundColor(.appBrown.opacity(0.55))
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.appGreige)
        }
    }

    // MARK: - Tags Row

    private var tagsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                TagPill(text: impression.occasion, color: Color(hex: "4CAF8A"))
                TagPill(text: impression.companions, color: Color.appBrown.opacity(0.12), textColor: .appBrown)
                if let price = impression.priceRange {
                    TagPill(text: price, color: Color(hex: "E05C7A"))
                }
            }
        }
    }

    // MARK: - 2×2 Widget Grid

    private var widgetGrid: some View {
        let widgets = Array(impression.allWidgets.prefix(4))
        let pairs = stride(from: 0, to: widgets.count, by: 2).map {
            Array(widgets[$0..<min($0 + 2, widgets.count)])
        }

        return VStack(spacing: 6) {
            ForEach(Array(pairs.enumerated()), id: \.offset) { rowIdx, pair in
                HStack(spacing: 6) {
                    ForEach(Array(pair.enumerated()), id: \.offset) { colIdx, widget in
                        widgetPreviewCard(
                            widget: widget,
                            color: widgetColor(index: rowIdx * 2 + colIdx)
                        )
                    }
                    // If odd widget in last row, fill with empty
                    if pair.count == 1 {
                        Color.clear.frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func widgetPreviewCard(widget: Widget, color: Color) -> some View {
        let (title, body) = widgetContent(widget)
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.custom("HKGrotesk-SemiBold", size: 9))
                .foregroundColor(.white.opacity(0.75))
                .kerning(0.5)
                .lineLimit(1)

            Text(body)
                .font(.custom("HKGrotesk-Regular", size: 13))
                .foregroundColor(.white)
                .lineLimit(3)
                .lineSpacing(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func widgetContent(_ widget: Widget) -> (title: String, body: String) {
        switch widget.type {
        case .quote(let q): return (q.prompt, q.answer)
        case .info(let i): return (i.title ?? "Detail", i.content)
        case .photo(let p): return ("Photo", p.caption ?? "Tap to view")
        case .orderList(let o):
            let items = (o.leftColumnItems + o.rightColumnItems).map(\.name).joined(separator: ", ")
            return (o.title, items)
        case .foodGrid(let f):
            return ("What they ordered", f.items.prefix(3).map(\.name).joined(separator: ", "))
        case .map(let m): return ("Location", m.placeName)
        case .pairing(let p): return ("Pairs well with", p.placeName)
        }
    }

    // MARK: - Bottom Row

    private var bottomRow: some View {
        HStack(spacing: 8) {
            // Credit (✓ N) pill
            let creditCount = store.creditCount(for: impression.id, baseline: impression.creditCount)
            let hasCredited = store.creditedIds.contains(impression.id)

            Button {
                if !isOwnImpression {
                    store.toggleCredit(
                        for: impression.id,
                        impressionTitle: impression.title,
                        placeName: impression.placeName,
                        authorId: impression.author.id,
                        currentUserId: userManager.currentUser?.id ?? "",
                        context: modelContext,
                        creditorName: userManager.currentUser?.name
                    )
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: hasCredited ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.system(size: 14, weight: .semibold))
                    Text("\(creditCount)")
                        .font(.custom("HKGrotesk-SemiBold", size: 13))
                }
                .foregroundColor(hasCredited ? .white : .appBrown)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(hasCredited ? Color(hex: "3D9B7A") : Color.appOffWhite)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(hasCredited ? Color.clear : Color.appGreige, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(isOwnImpression)

            // Share pill — share network icon + count
            Button {
                // Share action
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 12, weight: .medium))
                    Text("\(impression.creditCount + 19)") // placeholder share count
                        .font(.custom("HKGrotesk-Regular", size: 13))
                }
                .foregroundColor(.appBrown)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.appOffWhite)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.appGreige, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()

            // "View Impression →" button (matches design label)
            Button { showDetail = true } label: {
                Text("View Impression →")
                    .font(.custom("HKGrotesk-SemiBold", size: 13))
                    .foregroundColor(.appBrown)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.appOffWhite)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.appGreige, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Tag Pill

struct TagPill: View {
    let text: String
    var color: Color
    var textColor: Color = .white

    var body: some View {
        Text(text)
            .font(.custom("HKGrotesk-Regular", size: 12))
            .foregroundColor(textColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color)
            .clipShape(Capsule())
    }
}

// MARK: - Hotlist Button

struct HotlistButton: View {
    let impressionId: String
    @Environment(HotlistStore.self) private var hotlist

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.25)) {
                hotlist.toggle(impressionId)
            }
        } label: {
            Image(systemName: hotlist.isSaved(impressionId) ? "bookmark.fill" : "bookmark")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(hotlist.isSaved(impressionId) ? .appCrimson : .appGreige)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Impression.placeLocation helper

extension Impression {
    // Extracts location from placeName if it contains a comma
    // e.g. "The Bombay Canteen, Lower Parel" → "Lower Parel"
    // For now returns nil — location will come from the Place struct in future
    var placeLocation: String? { nil }
}

// MARK: - RecommendationStore credit count helper

extension RecommendationStore {
    func creditCount(for impressionId: String, baseline: Int) -> Int {
        let delta = creditedIds.contains(impressionId) ? 1 : 0
        return baseline + delta
    }
}
