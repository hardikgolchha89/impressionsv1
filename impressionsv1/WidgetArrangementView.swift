//
//  WidgetArrangementView.swift
//  impressionsv1
//
//  Widget arrangement step in the creation flow.
//  Up/down arrows to reorder. Live grid preview updates as order changes.
//

import SwiftUI

struct WidgetArrangementView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @State private var items: [WidgetArrangementItem] = []
    @State private var availableWidth: CGFloat = 350

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button(action: { coordinator.goBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("Arrange Widgets")
                        .font(AppFont.title2)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Live grid preview
                        gridPreview
                            .padding(.horizontal, Spacing.md)
                            .padding(.top, Spacing.md)

                        // Divider label
                        HStack(spacing: Spacing.sm) {
                            Rectangle().fill(Color.appBorder).frame(height: 1)
                            Text("Reorder")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.textTertiary)
                                .fixedSize()
                            Rectangle().fill(Color.appBorder).frame(height: 1)
                        }
                        .padding(.horizontal, Spacing.lg)

                        // Reorderable list
                        reorderList
                            .padding(.horizontal, Spacing.md)
                            .padding(.bottom, 100)
                    }
                }

                // MARK: - Continue Button
                VStack {
                    Button(action: {
                        coordinator.completeArrangement(widgets: items)
                    }) {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryButton()
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.md)
                }
                .background(Color.appBackground)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { items = coordinator.data.arrangedWidgets }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { availableWidth = geo.size.width }
            }
        )
    }

    // MARK: - Grid Preview

    @ViewBuilder
    private var gridPreview: some View {
        let previewWidgets = items.map { item in
            Widget(id: item.id, type: previewWidgetType(for: item), gridSize: item.gridSize)
        }
        let placements = WidgetGridLayoutEngine.layout(widgets: previewWidgets)
        let previewWidth = availableWidth - (Spacing.md * 2)

        GeometryReader { geo in
            let metrics = GridCellMetrics(totalWidth: geo.size.width)
            ZStack(alignment: .topLeading) {
                ForEach(Array(placements.enumerated()), id: \.element.id) { index, placement in
                    let size = metrics.frame(for: placement)
                    let pos  = metrics.offset(for: placement)
                    let tilt = tiltAngle(col: placement.column, row: placement.row)

                    previewWidgetView(for: placement.widget)
                        .frame(width: size.width, height: size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .rotationEffect(.degrees(tilt))
                        .offset(x: pos.width, y: pos.height)
                }
            }
            .frame(width: geo.size.width,
                   height: GridCellMetrics(totalWidth: geo.size.width).totalHeight(for: placements),
                   alignment: .topLeading)
        }
        .frame(height: {
            guard previewWidth > 0 else { return 200 }
            let m = GridCellMetrics(totalWidth: previewWidth)
            return m.totalHeight(for: WidgetGridLayoutEngine.layout(widgets: previewWidgets))
        }())
    }

    /// Renders the real widget view for each type in the arrangement preview
    @ViewBuilder
    private func previewWidgetView(for widget: Widget) -> some View {
        switch widget.type {
        case .photo(let d):
            PhotoWidget(photo: d)
        case .quote(let d):
            QuoteWidget(quote: d)
        case .info(let d):
            InfoWidget(info: d)
        case .map(let d):
            MapWidget(map: d)
        case .foodGrid(let d):
            FoodGridWidget(items: d.items)
        case .orderList(let d):
            OrderListWidget(title: d.title, leftColumnItems: d.leftColumnItems, rightColumnItems: d.rightColumnItems)
        case .pairing(let d):
            PairingWidget(pairing: d)
        }
    }

    /// Builds a real WidgetType populated with preview content for the arrangement item
    private func previewWidgetType(for item: WidgetArrangementItem) -> WidgetType {
        if item.widgetKey.hasPrefix("photo") {
            return .photo(PhotoData(id: item.id, imageUrl: nil, caption: nil))
        } else if item.widgetKey.hasPrefix("quote") {
            let parts = item.label.dropFirst("Quote: ".count)
            return .quote(QuoteData(id: item.id, prompt: String(parts), answer: ""))
        } else if item.widgetKey.hasPrefix("map") {
            let name = item.label.replacingOccurrences(of: "Map: ", with: "")
            return .map(MapData(id: item.id, placeName: name, address: ""))
        } else if item.widgetKey.hasPrefix("food") {
            return .foodGrid(FoodGridData(id: item.id, items: []))
        } else if item.widgetKey.hasPrefix("order") {
            return .orderList(OrderListData(id: item.id, title: item.label, leftColumnItems: [], rightColumnItems: []))
        } else {
            // info_vibe, info_time, etc.
            let parts = item.label.split(separator: ":", maxSplits: 1)
            let title = parts.count > 0 ? String(parts[0]).trimmingCharacters(in: .whitespaces) : ""
            let content = parts.count > 1 ? String(parts[1]).trimmingCharacters(in: .whitespaces) : ""
            return .info(InfoData(id: item.id, title: title, content: content))
        }
    }

    /// Alternating tilt: even (col+row) cells tilt slightly left, odd tilt slightly right
    private func tiltAngle(col: Int, row: Int) -> Double {
        (col + row) % 2 == 0 ? -1.5 : 1.5
    }

    private func previewColor(for item: WidgetArrangementItem?) -> Color {
        guard let item else { return Color.gray.opacity(0.3) }
        if item.widgetKey.hasPrefix("photo")  { return Color(hex: "6B8E8E") }
        if item.widgetKey.hasPrefix("quote")  { return Color(hex: "8B6B8E") }
        if item.widgetKey.hasPrefix("info")   { return Color(hex: "8E8B6B") }
        if item.widgetKey.hasPrefix("map")    { return Color.appBlue }
        if item.widgetKey.hasPrefix("food") || item.widgetKey.hasPrefix("order") { return Color(hex: "6B8E6B") }
        return Color.gray.opacity(0.4)
    }

    // MARK: - Reorder List (up/down arrows, no drag)

    @ViewBuilder
    private var reorderList: some View {
        VStack(spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                HStack(spacing: Spacing.sm) {
                    // Color dot
                    Circle()
                        .fill(previewColor(for: item))
                        .frame(width: 10, height: 10)

                    // Widget icon
                    Image(systemName: item.iconName)
                        .font(.system(size: 15))
                        .foregroundColor(previewColor(for: item))
                        .frame(width: 24)

                    // Label
                    Text(item.label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)

                    Spacer()

                    // Up / Down arrows
                    HStack(spacing: 4) {
                        Button(action: { moveUp(index: index) }) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(index == 0 ? Color.textTertiary.opacity(0.3) : .textTertiary)
                                .frame(width: 32, height: 32)
                                .background(Color.appBorder.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        }
                        .disabled(index == 0)

                        Button(action: { moveDown(index: index) }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(index == items.count - 1 ? Color.textTertiary.opacity(0.3) : .textTertiary)
                                .frame(width: 32, height: 32)
                                .background(Color.appBorder.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        }
                        .disabled(index == items.count - 1)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.cardBackground)
                )
            }
        }
    }

    // MARK: - Helpers

    private func moveUp(index: Int) {
        guard index > 0 else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            items.swapAt(index, index - 1)
        }
    }

    private func moveDown(index: Int) {
        guard index < items.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            items.swapAt(index, index + 1)
        }
    }
}

// MARK: - Preview
#Preview {
    let coordinator = CreateImpressionCoordinator()
    coordinator.data.arrangedWidgets = [
        WidgetArrangementItem(id: "photo_0",   label: "Photo 1",              iconName: "photo",          gridSize: .oneByOne, sortOrder: 0, widgetKey: "photo_0"),
        WidgetArrangementItem(id: "photo_1",   label: "Photo 2",              iconName: "photo",          gridSize: .oneByOne, sortOrder: 1, widgetKey: "photo_1"),
        WidgetArrangementItem(id: "quote_1",   label: "Quote: What did you love?", iconName: "quote.opening", gridSize: .oneByOne, sortOrder: 2, widgetKey: "quote_1"),
        WidgetArrangementItem(id: "info_vibe", label: "Vibe: Romantic",       iconName: "info.circle",    gridSize: .oneByOne, sortOrder: 3, widgetKey: "info_vibe"),
        WidgetArrangementItem(id: "map_place", label: "Map: Bombay Canteen",  iconName: "mappin.circle",  gridSize: .oneByOne, sortOrder: 4, widgetKey: "map_place"),
        WidgetArrangementItem(id: "foodgrid",  label: "Food Grid (4 items)",  iconName: "square.grid.2x2", gridSize: .twoByOne, sortOrder: 5, widgetKey: "foodgrid"),
    ]
    return WidgetArrangementView(coordinator: coordinator)
}
