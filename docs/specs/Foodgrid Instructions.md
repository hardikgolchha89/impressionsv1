# Food Grid Widget - Build Instructions

## What You're Building
A widget that displays ordered food items in a horizontal scrollable grid.

---

## File to Create
**Filename:** `FoodGridWidget.swift`

---

## Widget Appearance

### Overall Structure
```
┌─────────────────────────────────────────┐
│  GREEN BACKGROUND                       │
│                                         │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐   │
│  │    │ │    │ │    │ │    │ │    │ → │ (scrollable)
│  └────┘ └────┘ └────┘ └────┘ └────┘   │
│  Name1  Name2  Name3  Name4  Name5     │
│                                         │
└─────────────────────────────────────────┘
```

---

## Detailed Specifications

### Container
**Background:** Color.appGreen (#6BCB77)
**Corner radius:** 12px (CornerRadius.widget)
**Padding:** 16px all sides
**Height:** Auto (based on content, ~120px total)

---

### Scrollable Content
**Layout:** Horizontal ScrollView

**Scroll settings:**
- Horizontal only
- Hide scroll indicators
- Bounce enabled
- Content padding: 4px vertical (keeps items from edges)

**Content layout:**
- HStack with items
- Spacing between items: 12px (Spacing.md)

---

### Food Item (Individual)
**Each item in the scroll:**

**Layout:** VStack

**Top - Food Icon/Image:**
- Size: 60x60px square
- Background: White with 20% opacity
- Corner radius: 8px
- Content: SF Symbol "fork.knife" for now (placeholder)
- Icon size: 24pt
- Icon color: White

**Bottom - Food Name:**
- Text alignment: Center
- Font: System, 12pt, medium
- Color: White
- Max lines: 2
- Line limit: Truncate with ellipsis
- Width: Same as icon (60px)
- Top padding from icon: 6px

---

## Data Model

### FoodItem struct
**Properties:**
- `id: String` (for identification)
- `name: String` (display name)
- `imageName: String?` (optional, for later)

### Widget accepts:
- `items: [FoodItem]` (array of food items)

---

## Layout Measurements

**Container:**
- Background: Green
- Corner radius: 12px
- Padding: 16px all sides

**Scroll Content:**
- Horizontal spacing: 12px between items
- Vertical padding: 4px

**Each Item:**
- Icon size: 60x60px
- Icon corner radius: 8px
- Text width: 60px (matches icon)
- Gap between icon and text: 6px
- Text: 12pt medium, white, center-aligned

**Total item width:** ~60px (icon/text same width)
**Total item height:** ~86px (60px icon + 6px gap + 20px text)

---

## Sample Data for Preview

Create 6 sample items:
1. "Plain Podi Ghee Dosa"
2. "Scrambled Eggs"
3. "Canteen Rasgulla"
4. "Butter Sada Dosa"
5. "Filter Coffee"
6. "Masala Dosa"

---

## Visual Example

```
Green Container (rounded, 16px padding)
├── Horizontal Scroll
    ├── Item 1
    │   ├── [60x60 white box with fork.knife icon]
    │   └── "Plain Podi Ghee Dosa" (white text)
    │
    ├── Item 2
    │   ├── [60x60 white box with fork.knife icon]
    │   └── "Scrambled Eggs" (white text)
    │
    └── ... (6 items total)
```

---

## Implementation Notes

1. **Use ScrollView with horizontal axis**
   - `.scrollIndicators(.hidden)`
   - Wrap content in HStack

2. **Each item is a VStack**
   - Icon on top
   - Text below
   - Both centered

3. **Icon placeholder**
   - Use RoundedRectangle with white/opacity background
   - Overlay with SF Symbol
   - Actual images come later

4. **Text truncation**
   - `.lineLimit(2)`
   - `.multilineTextAlignment(.center)`
   - Fixed width matching icon

5. **Widget is reusable**
   - Accepts array of FoodItem
   - Can show any number of items
   - Scrolls if more than fit on screen

---

## Where This Widget Goes

**Replace the green placeholder in DetailView:**

Current:
```
"Food items grid" placeholder
```

New:
```swift
FoodGridWidget(items: [
    FoodItem(id: "1", name: "Plain Podi Ghee Dosa", imageName: nil),
    FoodItem(id: "2", name: "Scrambled Eggs", imageName: nil),
    // ... etc
])
```

---

## Success Criteria

When done, you should see:
- Green rounded container
- Horizontal scroll of food items
- Each item: white square icon + name below
- White text on green background
- Smooth horizontal scrolling
- 6 items visible/scrollable
- Items properly spaced

---

## Cursor Prompt

Copy this into Cursor:

```
Create FoodGridWidget.swift following FOODGRID_INSTRUCTIONS.md

Requirements:
- Green container with rounded corners
- Horizontal scrollable list of food items
- Each item: icon square + name text below
- White text and icons on green background
- FoodItem data model
- Sample data for 6 items
- Use design system constants
- Preview showing the widget
```

---

## After Building This Widget

**Update ImpressionDetailView:**

Replace the green "Food items grid" placeholder with actual FoodGridWidget component.

Pass sample data of 6 food items.

This widget becomes the first real widget in your detail view.
