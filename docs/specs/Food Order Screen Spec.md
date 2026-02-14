# Screen Spec: Food Order Input ("What did you order for the table?")

## Screen Purpose
Capture the list of dishes ordered during the meal.

---

## Visual Layout

### Header Section
- **Background**: Black (`Color.appBackground`)
- **Back button**: Top-left, chevron left icon, white color
- **Title**: "What did you order for the table?" 
  - Font: `AppFont.title2`
  - Color: `Color.textPrimary` (white)
  - Position: Top center, below back button

### Text Input Area
- **Position**: Centered vertically on screen
- **Style**:
  - Background: `Color.cardBackground` (dark gray #2A2A2A)
  - Corner radius: `CornerRadius.large`
  - Width: Full width minus `Spacing.md` x 2 (side margins)
  - Min height: 200pt
  - Max height: Expandable with content
  - Padding: `Spacing.md` inside
- **Placeholder text**: "Please write item names (one in each line)"
  - Font: `AppFont.body`
  - Color: `Color.textTertiary` (gray)
- **Input text**:
  - Font: `AppFont.body`
  - Color: `Color.textPrimary` (white)
  - Multi-line text editor
  - Auto-capitalizes first letter of each line

### Continue Button
- **Position**: Bottom of screen, above safe area
- **Style**: `.primaryButton()`
- **Text**: "Continue"
- **Full width** minus `Spacing.md` margins
- **Enabled only when**: Text is not empty

---

## User Interactions

1. **Tap text area** → Keyboard appears, user types dish names
2. **Type dish names** → One per line (press return for new dish)
3. **Tap continue** → Save dishes and navigate to photo screen
4. **Tap back** → Return to vibe selection (show alert if text entered: "Discard changes?")

---

## Data Model

```swift
@State private var dishesText: String = ""

// Computed property to split into array
var dishes: [String] {
    dishesText
        .components(separatedBy: .newlines)
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty }
}
```

---

## Technical Notes

### Text Editor Configuration
- Use SwiftUI `TextEditor` (not `TextField`)
- Multiline enabled
- Auto-capitalization: `.words`
- Keyboard type: `.default`
- Return key: `.default` (allows new lines)

### Continue Button Logic
- Disabled (grayed out) when `dishesText.isEmpty`
- Enabled (white background) when text exists
- Use `.disabled()` modifier

### Keyboard Management
- Dismiss keyboard when tapping outside text area
- Show keyboard toolbar with "Done" button on iOS

---

## Design System Usage

- Background: `Color.appBackground`
- Input card: `Color.cardBackground` with `CornerRadius.large`
- Text: `AppFont.title2`, `AppFont.body`
- Colors: `Color.textPrimary`, `Color.textTertiary`
- Spacing: `Spacing.md`
- Button: `.primaryButton()`

---

## Navigation
- Back button → Returns to VibeSelectionView
- Continue button → Navigate to PhotoUploadView
- Pass all previous context + dishes array

---

## Edge Cases
- Empty input → Continue button disabled
- Very long list (50+ items) → Scrollable text area
- Special characters → Allow all text input
- Paste text → Works normally, splits by newlines
