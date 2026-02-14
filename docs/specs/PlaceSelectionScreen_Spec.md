# Screen Spec: Place Selection ("Where did you go?")

## Screen Purpose
First step in creating an impression. User selects which restaurant/place they visited.

---

## Visual Layout

### Header Section
- **Background**: Black (`Color.appBackground`)
- **Back button**: Top-left, chevron left icon, white color
- **Title**: "Where did you go?" 
  - Font: `AppFont.title2`
  - Color: `Color.textPrimary` (white)
  - Position: Top center, below status bar

### Search Bar
- **Position**: Below title, with `Spacing.md` margin
- **Style**: 
  - Background: `Color.cardBackground` (dark gray)
  - Corner radius: `CornerRadius.medium`
  - Height: 44pt
  - Placeholder: "Search" in `Color.textTertiary`
  - Search icon: Left side, magnifying glass
  - Border: None

### Place Grid
- **Layout**: 3 columns
- **Spacing**: `Spacing.sm` between items
- **Padding**: `Spacing.md` on sides

### Place Card (Individual Item)
- **Size**: Square aspect ratio (fills 1/3 width minus spacing)
- **Image**: 
  - Restaurant photo
  - Corner radius: `CornerRadius.large`
  - Aspect ratio: 1:1 (square)
- **Name label**:
  - Position: Centered below image
  - Font: `AppFont.bodySmall`
  - Color: `Color.textPrimary`
  - Max 2 lines, truncated with "..."
- **Selection state**:
  - Unselected: Normal appearance
  - Selected: White checkmark in top-right corner
    - Checkmark background: White rounded square (30x30pt)
    - Checkmark icon: Black
    - Corner radius: `CornerRadius.small`
    - Position: 8pt from top-right edge

### Bottom Section
- **Button**: "Submit New Restaurants Here"
  - Style: `.secondaryButton()`
  - Position: Above bottom safe area
  - Margin: `Spacing.md` from sides and bottom
  - Full width minus margins

---

## User Interactions

1. **Tap place card** → Toggle selection (checkmark appears/disappears)
2. **Tap "Submit New Restaurants"** → Opens form to add missing place
3. **Type in search bar** → Filter visible places by name
4. **Tap back button** → Return to previous screen
5. **After selecting place** → Automatically proceed to next step (or require confirmation)

---

## Data Model

```swift
struct Place: Identifiable {
    let id: UUID
    let name: String
    let imageURL: String
    let location: String? // e.g., "Lower Parel, Mumbai"
    let cuisine: String?  // e.g., "Indian", "Italian"
}
```

---

## Sample Data (for testing)

```swift
let samplePlaces = [
    Place(
        id: UUID(),
        name: "The Bombay Canteen",
        imageURL: "bombay_canteen", // Local asset name
        location: "Lower Parel",
        cuisine: "Indian"
    ),
    Place(
        id: UUID(),
        name: "Lake View Cafe",
        imageURL: "lake_view_cafe",
        location: "Powai",
        cuisine: "Cafe"
    ),
    Place(
        id: UUID(),
        name: "Bastian - At the Top",
        imageURL: "bastian",
        location: "Linking Road",
        cuisine: "Seafood"
    )
    // Add 6-9 more for scrolling
]
```

---

## Technical Notes

### State Management
```swift
@State private var selectedPlace: Place? = nil
@State private var searchText: String = ""
```

### Search Logic
Filter places where `place.name` contains `searchText` (case-insensitive)

### Grid Configuration
```swift
let columns = [
    GridItem(.flexible(), spacing: Spacing.sm),
    GridItem(.flexible(), spacing: Spacing.sm),
    GridItem(.flexible(), spacing: Spacing.sm)
]
```

---

## Design System Usage

- Background: `Color.appBackground`
- Cards: Use custom styling with `.cornerRadius(CornerRadius.large)`
- Text: `AppFont.title2`, `AppFont.bodySmall`
- Spacing: `Spacing.md`, `Spacing.sm`
- Button: `.secondaryButton()`

---

## Accessibility
- All interactive elements should have minimum 44pt tap target
- Place images should have alt text with restaurant name
- Search bar should have clear button when text is present

---

## Edge Cases
- **No results from search**: Show "No places found" message
- **Empty state**: Show prompt to add first place
- **Loading state**: Show skeleton grid while fetching
- **Network images**: Show placeholder while loading

---

## Next Step After This Screen
Navigate to "What meal was this?" screen, passing selected `Place` object
