//
//  WidgetGridLayout.swift
//  impressionsv1
//
//  Grid layout system for arranging widgets in a 2-column grid.
//  Supports 1x1, 2x1, 1x2, 2x2 cell sizes with automatic packing.
//

import SwiftUI

// MARK: - Grid Size

enum WidgetGridSize: String, Codable, CaseIterable, Identifiable {
    case oneByOne = "1x1"   // 1 column, 1 row (half width, short)
    case twoByOne = "2x1"   // 2 columns, 1 row (full width, short)
    case oneByTwo = "1x2"   // 1 column, 2 rows (half width, tall)
    case twoByTwo = "2x2"   // 2 columns, 2 rows (full width, tall)

    var id: String { rawValue }

    var columnSpan: Int {
        switch self {
        case .oneByOne, .oneByTwo: return 1
        case .twoByOne, .twoByTwo: return 2
        }
    }

    var rowSpan: Int {
        switch self {
        case .oneByOne, .twoByOne: return 1
        case .oneByTwo, .twoByTwo: return 2
        }
    }

    var displayLabel: String {
        switch self {
        case .oneByOne: return "Small"
        case .twoByOne: return "Wide"
        case .oneByTwo: return "Tall"
        case .twoByTwo: return "Large"
        }
    }
}

// MARK: - Default Grid Size per Widget Type

extension WidgetType {
    var defaultGridSize: WidgetGridSize {
        switch self {
        case .quote:     return .oneByOne
        case .photo:     return .oneByOne
        case .info:      return .oneByOne
        case .map:       return .oneByOne
        case .pairing:   return .twoByOne
        case .foodGrid:  return .twoByOne
        case .orderList: return .twoByOne
        }
    }

    /// Short label for display in arrangement view
    var displayLabel: String {
        switch self {
        case .quote:     return "Quote"
        case .photo:     return "Photo"
        case .info:      return "Info"
        case .map:       return "Map"
        case .pairing:   return "Pairing"
        case .foodGrid:  return "Food Grid"
        case .orderList: return "Order List"
        }
    }

    /// SF Symbol for display
    var iconName: String {
        switch self {
        case .quote:     return "quote.opening"
        case .photo:     return "photo"
        case .info:      return "info.circle"
        case .map:       return "mappin.circle"
        case .pairing:   return "arrow.triangle.branch"
        case .foodGrid:  return "square.grid.2x2"
        case .orderList: return "list.bullet"
        }
    }
}

// MARK: - Grid Placement (computed by layout engine)

struct WidgetGridPlacement: Identifiable {
    let id: String          // matches widget id
    let widget: Widget
    let gridSize: WidgetGridSize
    let column: Int         // 0 or 1
    let row: Int            // computed row index
}

// MARK: - Layout Engine

struct WidgetGridLayoutEngine {

    /// Computes grid placements for the given widgets.
    /// Packs widgets top-to-bottom, left-to-right into a 2-column grid.
    static func layout(widgets: [Widget]) -> [WidgetGridPlacement] {
        var occupied: [[Bool]] = []  // [row][col]
        var placements: [WidgetGridPlacement] = []

        for widget in widgets {
            let size = widget.gridSize
            let position = findNextAvailable(
                columnSpan: size.columnSpan,
                rowSpan: size.rowSpan,
                occupied: &occupied
            )

            // Mark cells as occupied
            for r in position.row ..< (position.row + size.rowSpan) {
                for c in position.col ..< (position.col + size.columnSpan) {
                    occupied[r][c] = true
                }
            }

            placements.append(WidgetGridPlacement(
                id: widget.id,
                widget: widget,
                gridSize: size,
                column: position.col,
                row: position.row
            ))
        }

        return placements
    }

    /// Total number of rows used by the placements
    static func totalRows(for placements: [WidgetGridPlacement]) -> Int {
        guard !placements.isEmpty else { return 0 }
        return placements.map { $0.row + $0.gridSize.rowSpan }.max() ?? 0
    }

    // MARK: Private

    private static func findNextAvailable(
        columnSpan: Int,
        rowSpan: Int,
        occupied: inout [[Bool]]
    ) -> (row: Int, col: Int) {

        func ensureRows(_ count: Int) {
            while occupied.count < count {
                occupied.append([false, false])
            }
        }

        var row = 0
        while true {
            ensureRows(row + rowSpan)

            let maxCol = 2 - columnSpan  // 0 for 2-wide, 0 or 1 for 1-wide
            for col in 0 ... maxCol {
                var fits = true
                for r in row ..< (row + rowSpan) {
                    for c in col ..< (col + columnSpan) {
                        if occupied[r][c] { fits = false; break }
                    }
                    if !fits { break }
                }
                if fits {
                    return (row, col)
                }
            }
            row += 1
        }
    }
}

// MARK: - Grid Rendering Helper

/// Computes dimensions and position for a widget placement given cell size and spacing.
struct GridCellMetrics {
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    let spacing: CGFloat

    init(totalWidth: CGFloat, spacing: CGFloat = 12) {
        self.spacing = spacing
        self.cellWidth = (totalWidth - spacing) / 2.0
        self.cellHeight = cellWidth * 0.85  // slightly shorter than wide — more compact
    }

    func frame(for placement: WidgetGridPlacement) -> CGSize {
        let w = CGFloat(placement.gridSize.columnSpan) * cellWidth
            + CGFloat(placement.gridSize.columnSpan - 1) * spacing
        let h = CGFloat(placement.gridSize.rowSpan) * cellHeight
            + CGFloat(placement.gridSize.rowSpan - 1) * spacing
        return CGSize(width: w, height: h)
    }

    func offset(for placement: WidgetGridPlacement) -> CGSize {
        let x = CGFloat(placement.column) * (cellWidth + spacing)
        let y = CGFloat(placement.row) * (cellHeight + spacing)
        return CGSize(width: x, height: y)
    }

    func totalHeight(for placements: [WidgetGridPlacement]) -> CGFloat {
        let rows = WidgetGridLayoutEngine.totalRows(for: placements)
        guard rows > 0 else { return 0 }
        return CGFloat(rows) * cellHeight + CGFloat(rows - 1) * spacing
    }
}
