# Screen Spec: Prompt Selection (Tabbed Interface)

## Screen Purpose
User selects 3-5 prompts they want to answer from categorized question banks.

---

## Visual Layout

### Header Section
- **Background**: Black (`Color.appBackground`)
- **Back button**: Top-left, chevron left icon, white color
- **No title** - tabs start immediately below back button

### Tab Bar
- **Position**: Below back button, `Spacing.md` from top
- **Style**: Horizontal scrollable tabs
- **Background**: Semi-transparent dark gray (`Color.cardBackground.opacity(0.5)`)
- **Corner radius**: `CornerRadius.large`
- **Height**: 44pt
- **Padding**: `Spacing.xs` inside

**4 Tabs:**
1. **Craft & Details** - Yellow (`Color.appYellow`)
2. **Service** - Pink (`Color.appPink`)
3. **Expectations** - Green (`Color.appGreen`)
4. **Social** - Blue (`Color.appBlue`)

**Tab Appearance:**
- **Inactive tab**: 
  - Text color: `Color.textSecondary`
  - Font: `AppFont.bodySmall`
  - No background
- **Active tab**:
  - Background: Category color (yellow/pink/green/blue)
  - Text color: Black
  - Font: `AppFont.bodyBold`
  - Corner radius: `CornerRadius.medium`
  - Padding: `Spacing.xs` horizontal, `Spacing.xxs` vertical

### Prompt Cards Area
- **Scrollable vertical list** of prompt cards
- **Padding**: `Spacing.md` on sides
- **Spacing**: `Spacing.sm` between cards

### Prompt Card
- **Size**: Full width minus side padding
- **Height**: Auto (based on text, min 100pt)
- **Background**: Category color (yellow for Craft, pink for Service, etc.)
- **Corner radius**: `CornerRadius.large`
- **Padding**: `Spacing.md` inside
- **Border**: 3pt white border (when selected)
- **Shadow**: `AppShadow.cardMedium`

**Card Content:**
- **Question text**: 
  - Font: `AppFont.body`
  - Color: White
  - Multiple lines allowed
  - Left-aligned

**Selection State:**
- **Unselected**: Normal appearance, no border
- **Selected**: 3pt white border around entire card
- **Selection badge**: Small white checkmark in top-right corner (24x24)

### Bottom Section
- **Selection counter**: "3/5 prompts selected" 
  - Font: `AppFont.caption`
  - Color: `Color.textSecondary`
  - Center-aligned
  - `Spacing.sm` above button

- **Continue button**:
  - Style: `.primaryButton()`
  - Text: "Continue"
  - Full width minus `Spacing.md` margins
  - **Enabled only when**: 3-5 prompts selected
  - Position: Above bottom safe area

---

## User Interactions

1. **Tap tab** → Switch category, show different prompts
2. **Tap prompt card** → Toggle selection (add/remove white border + checkmark)
3. **Select 3rd prompt** → Continue button becomes enabled
4. **Select 6th prompt** → Show alert: "Maximum 5 prompts. Deselect one to continue."
5. **Tap continue** → Navigate to answer first selected prompt
6. **Tap back** → Return to photo upload screen

---

## Data Model

```swift
struct Prompt: Identifiable {
    let id: UUID
    let question: String
    let category: PromptCategory
}

enum PromptCategory: String, CaseIterable {
    case craftDetails = "Craft & Details"
    case service = "Service"
    case expectations = "Expectations"
    case social = "Social"
    
    var color: Color {
        switch self {
        case .craftDetails: return .appYellow
        case .service: return .appPink
        case .expectations: return .appGreen
        case .social: return .appBlue
        }
    }
}

@State private var selectedTab: PromptCategory = .craftDetails
@State private var selectedPrompts: Set<UUID> = []
```

---

## Sample Prompts

### Craft & Details (Yellow)
1. "What did you notice that most people wouldn't?"
2. "Did they do anything technical really well or really poorly?"
3. "Was there anything about the quality of basics that stood out?"
4. "What would a regular at this place know to ask for or avoid?"

### Service (Pink)
1. "How did they greet you and get you seated?"
2. "Did the staff explain the menu or just take your order?"
3. "How was the pacing?"
4. "Did they notice things without you asking?"
5. "How did they present the bill and handle payment?"

### Expectations (Green)
1. "What did you order for the table?"
2. "This would pair well with"
3. (Additional prompts from your doc)

### Social (Blue)
1. "Who would you confidently bring here vs who would you NOT bring here?"
2. "Would you suggest this place to impress someone?"
3. "Can you have a proper conversation here?"

---

## Technical Notes

### Tab Switching
- Use `@State var selectedTab` to track active tab
- Filter prompts by category: `prompts.filter { $0.category == selectedTab }`
- Smooth transition animation when switching tabs

### Selection Logic
- Use `Set<UUID>` to store selected prompt IDs
- Min: 3 prompts required
- Max: 5 prompts allowed
- Check count before allowing new selections

### Continue Button State
```swift
var canContinue: Bool {
    selectedPrompts.count >= 3 && selectedPrompts.count <= 5
}
```

### Tab Bar Scroll
- Use `ScrollView(.horizontal)` for tabs
- Auto-scroll to active tab when changed
- Use `ScrollViewReader` for programmatic scrolling

---

## Design System Usage

- Background: `Color.appBackground`
- Tab bar: `Color.cardBackground.opacity(0.5)`
- Cards: Category colors from `PromptCategory.color`
- Selected border: 3pt white stroke
- Text: `AppFont.body`, `AppFont.bodyBold`, `AppFont.caption`
- Spacing: `Spacing.md`, `Spacing.sm`, `Spacing.xs`
- Corner radius: `CornerRadius.large`, `CornerRadius.medium`
- Button: `.primaryButton()`
- Shadow: `AppShadow.cardMedium`

---

## Navigation
- Back button → Returns to PhotoUploadView
- Continue button → Navigate to PromptAnswerView (first selected prompt)
- Pass all context + array of selected prompts

---

## Edge Cases
- No prompts selected → Continue disabled, counter shows "0/5"
- 1-2 prompts selected → Continue disabled, show "Select at least 3"
- 3-5 prompts selected → Continue enabled
- 6+ prompts → Block new selections, show alert
- Switch tabs with selections → Selections persist across tabs
- Empty category → Show "No prompts available" message
