# FeedCardView Component - Build Instructions

## What You're Building
A reusable SwiftUI card component that displays impression previews in the feed.

---

## File to Create
**Filename:** `FeedCardView.swift`

---

## Component Structure

### Layout Hierarchy (Top to Bottom)
```
Card Container (pink or blue background)
└── VStack (24px padding all sides)
    ├── Author Header
    │   ├── Avatar (36x36 circle)
    │   ├── Name + Timestamp (stacked)
    │   └── [16px gap below]
    ├── Title
    │   └── [16px gap below]
    ├── Metadata Section
    │   ├── Row 1: Location icon + text
    │   ├── Row 2: People icon + text [4px gap]
    │   ├── Row 3: Calendar icon + text [4px gap]
    │   └── [16px gap below]
    ├── Photos
    │   ├── Photo 1 (square)
    │   ├── [12px gap]
    │   ├── Photo 2 (square)
    │   └── [16px gap below]
    └── Read Post Button (centered)
```

---

## Detailed Specifications

### Author Header Section
- **Layout:** Horizontal stack
- **Gap between avatar and text:** 8px (Spacing.sm)
- **Avatar:**
  - Size: 36x36 pixels
  - Shape: Circle
  - Background: Gray with 30% opacity
  - Content: First letter of author name (placeholder)
  - Text color: White
  - Font: AppFont.author()
- **Name + Timestamp:**
  - Layout: Vertical stack
  - Gap between name and timestamp: 2px
  - Name font: AppFont.author()
  - Name color: Color.appDarkText
  - Timestamp font: AppFont.timestamp()
  - Timestamp color: Color.appGrayText

### Title Section
- **Font:** AppFont.title()
- **Color:** Color.appDarkText
- **Max lines:** 3
- **Line limit:** Truncate with ellipsis

### Metadata Section
- **Layout:** Vertical stack of 3 rows
- **Gap between rows:** 4px (Spacing.xs)
- **Each row contains:**
  - SF Symbol icon (13pt)
  - 8px gap (Spacing.sm)
  - Text using AppFont.metadata()
  - Both icon and text in Color.appDarkText

**Row 1 - Location:**
- Icon: `mappin.circle.fill`
- Text: Place name + location

**Row 2 - Companions:**
- Icon: `person.2.fill`
- Text: Who they went with

**Row 3 - Occasion:**
- Icon: `calendar`
- Text: Type of visit

### Photos Section
- **Layout:** Horizontal stack
- **Gap between photos:** 12px (Spacing.md)
- **Each photo:**
  - Aspect ratio: 1:1 (square)
  - Corner radius: 12px (CornerRadius.image)
  - For now: Gray rectangle with 20% opacity
  - Placeholder: "photo" SF Symbol icon in gray
- **Show:** Maximum 2 photos from the array

### Read Post Button
- **Layout:** Horizontal stack, centered
- **Contents:**
  - Text: "Read Post"
  - 6px gap
  - Icon: `arrow.right` SF Symbol
- **Text font:** AppFont.button()
- **Text color:** Color.appDarkText
- **Icon size:** 12pt, semibold weight
- **Icon color:** Color.appDarkText
- **Alignment:** Centered horizontally within card

### Card Container
- **Background color:** 
  - Either Color.appPink or Color.appBlue
  - Determined by cardColor parameter
- **Corner radius:** 16px (CornerRadius.card)
- **Padding:** 24px all sides (Spacing.xxl)
- **Shadow:**
  - Color: Black at 5% opacity
  - Radius: 4px blur
  - X offset: 0
  - Y offset: 2px

---

## Data Model Requirements

### Create a struct called `ImpressionPreview`
**Properties needed:**
- `id: UUID` (for Identifiable)
- `authorName: String`
- `timeAgo: String`
- `title: String`
- `placeName: String`
- `companions: String`
- `occasion: String`
- `photos: [String]` (array of photo identifiers)
- `cardColor: CardColor` (enum)

### Create an enum called `CardColor`
**Cases:**
- `pink`
- `blue`

---

## Preview Requirements

Create a preview showing:

**Card 1 (Pink):**
- Author: "Hardik G"
- Time: "12d ago"
- Title: "Life Changing Dinner at The Bombay Canteen after ages"
- Place: "The Bombay Canteen, Lower Parel"
- Companions: "Table for 5"
- Occasion: "First Date"
- Photos: ["photo1", "photo2"]
- Color: Pink

**Card 2 (Blue):**
- Author: "Taashi T"
- Time: "5d ago"
- Title: "Amazing brunch spot in Bandra"
- Place: "Cafe Zoe, Bandra"
- Companions: "Solo"
- Occasion: "Weekend Brunch"
- Photos: ["photo1", "photo2"]
- Color: Blue

**Preview layout:**
- ScrollView containing both cards
- 16px spacing between cards (Spacing.lg)
- 16px padding around the scroll content (Spacing.lg)
- Background: Light gray (#F5F5F5)

---

## Constants to Use

All these should reference the DesignSystem file:

**Spacing:**
- `Spacing.xs` = 4px
- `Spacing.sm` = 8px
- `Spacing.md` = 12px
- `Spacing.lg` = 16px
- `Spacing.xxl` = 24px

**Corner Radius:**
- `CornerRadius.card` = 16px
- `CornerRadius.image` = 12px

**Fonts:**
- `AppFont.title()`
- `AppFont.author()`
- `AppFont.timestamp()`
- `AppFont.metadata()`
- `AppFont.button()`

**Colors:**
- `Color.appPink`
- `Color.appBlue`
- `Color.appDarkText`
- `Color.appGrayText`

---

## Implementation Notes

1. Create metadata rows as a separate helper view for reusability
2. Use `.prefix(2)` to show only first 2 photos
3. Avatar should show first character of author name
4. All spacing must use Spacing constants
5. All fonts must use AppFont functions
6. All colors must use Color.app* constants
7. Card should be reusable - don't hardcode any content

---

## Success Criteria

When done, you should be able to:
- See preview showing 2 cards (1 pink, 1 blue)
- All spacing matches the specifications
- Text is readable and properly styled
- Photos show as gray placeholders
- Card backgrounds are correct colors
- No hardcoded values (all use design system constants)

---

## Cursor Prompt

Copy this into Cursor:

```
Create FeedCardView.swift following FEEDCARD_INSTRUCTIONS.md

Requirements:
- SwiftUI view component
- Accept ImpressionPreview data model
- Use all constants from DesignSystem.swift
- Match exact spacing and styling specifications
- Include preview with 2 sample cards
- Create helper view for metadata rows
- All measurements use design system constants
```
