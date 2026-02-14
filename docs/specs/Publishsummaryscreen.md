# Screen Spec: Publish Summary (MVP)

## Screen Purpose
Show a simple summary of what's been created, then publish to feed.

---

## Visual Layout

### Header Section
- **Background**: Black (`Color.appBackground`)
- **Back button**: Top-left, chevron left icon, white color
- **Title**: "Ready to publish?" 
  - Font: `AppFont.title2`
  - Color: `Color.textPrimary` (white)
  - Position: Top center

### Summary Cards (Vertical Stack)
- **Position**: Centered vertically on screen
- **Spacing**: `Spacing.sm` between cards

#### Summary Card Style (Repeated for each item)
- **Background**: `Color.cardBackground` (dark gray)
- **Corner radius**: `CornerRadius.medium`
- **Padding**: `Spacing.md` inside
- **Full width** minus `Spacing.md` x 2 margins

#### Card Content:
- **Checkmark icon**: Green circle with white checkmark (left side)
- **Label text**: What was completed
- **Detail text**: Summary/count
- **Layout**: HStack with icon left, text right

### Summary Items (in order):

1. **Cover Photo**
   - Icon: ✓ (green)
   - Label: "Cover photo"
   - Detail: "Selected"

2. **Title**
   - Icon: ✓ (green)
   - Label: "Title"
   - Detail: First 40 chars of title + "..."

3. **Dishes**
   - Icon: ✓ (green) or ∅ (gray) if none
   - Label: "Food items"
   - Detail: "4 dishes listed" or "None added"

4. **Photos**
   - Icon: ✓ (green) or ∅ (gray) if none
   - Label: "Photos"
   - Detail: "5 photos" or "No photos"

5. **Prompts**
   - Icon: ✓ (green)
   - Label: "Questions answered"
   - Detail: "3 prompts"

### Bottom Button
- **Position**: Bottom of screen, above safe area
- **Style**: `.primaryButton()`
- **Text**: "Publish to Feed"
- **Full width** minus `Spacing.md` margins
- **Always enabled**

---

## User Interactions

1. **Screen loads** → Shows summary of all collected data

2. **Tap "Publish to Feed"** → 
   - Show loading indicator (disable button, show spinner)
   - Save impression (mock for now)
   - Wait 1 second (simulate upload)
   - Navigate to Feed

3. **Tap Back** → Return to title customization

---

## Data Model

```swift
// Receive from previous screens:
let selectedPlace: Place
let selectedMeal: MealType
let selectedCompanions: Set<CompanionType>
let selectedTime: TimeOfDay
let selectedVibe: VibeType
let dishesOrdered: [String]
let uploadedPhotos: [UIImage]
let selectedCoverPhoto: UIImage?
let impressionTitle: String
let answeredPrompts: [(Prompt, PromptAnswer)]

// State:
@State private var isPublishing: Bool = false

// Computed:
var summaryItems: [SummaryItem] {
    [
        SummaryItem(
            label: "Cover photo",
            detail: selectedCoverPhoto != nil ? "Selected" : "None",
            isComplete: selectedCoverPhoto != nil
        ),
        SummaryItem(
            label: "Title",
            detail: String(impressionTitle.prefix(40)) + (impressionTitle.count > 40 ? "..." : ""),
            isComplete: !impressionTitle.isEmpty
        ),
        SummaryItem(
            label: "Food items",
            detail: dishesOrdered.isEmpty ? "None added" : "\(dishesOrdered.count) dishes listed",
            isComplete: !dishesOrdered.isEmpty
        ),
        SummaryItem(
            label: "Photos",
            detail: uploadedPhotos.isEmpty ? "No photos" : "\(uploadedPhotos.count) photo\(uploadedPhotos.count == 1 ? "" : "s")",
            isComplete: !uploadedPhotos.isEmpty
        ),
        SummaryItem(
            label: "Questions answered",
            detail: "\(answeredPrompts.count) prompts",
            isComplete: answeredPrompts.count >= 3
        )
    ]
}

struct SummaryItem {
    let label: String
    let detail: String
    let isComplete: Bool
}
```

---

## Technical Notes

### Summary Card Component
```swift
struct SummaryCard: View {
    let item: SummaryItem
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Checkmark icon
            Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundColor(item.isComplete ? .green : .textTertiary)
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(item.label)
                    .font(AppFont.bodySmall)
                    .foregroundColor(.textSecondary)
                
                Text(item.detail)
                    .font(AppFont.body)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.medium)
    }
}
```

### Publish Action
```swift
func publishImpression() {
    isPublishing = true
    
    // Mock save (replace with real backend later)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        isPublishing = false
        
        // Navigate to Feed
        // For now, just print success
        print("Published!")
    }
}
```

### Loading State
- When `isPublishing == true`:
  - Disable button
  - Show spinner inside button
  - Text changes to "Publishing..."

---

## Design System Usage

- Background: `Color.appBackground`
- Cards: `Color.cardBackground`
- Text: `AppFont.title2`, `AppFont.body`, `AppFont.bodySmall`
- Colors: `Color.textPrimary`, `Color.textSecondary`, `Color.textTertiary`, `.green`
- Spacing: `Spacing.md`, `Spacing.sm`
- Corner radius: `CornerRadius.medium`
- Button: `.primaryButton()`

---

## Navigation

- Back button → Returns to TitleCustomizationView
- Publish button → Navigate to FeedView (main feed screen)

---

## Edge Cases

- **Missing optional data**: Show "None" or "Not added" (grayed out checkmark)
- **All data complete**: All checkmarks green
- **Publish in progress**: Button disabled, shows spinner
- **Publish fails**: Show error alert (later), for now assume success

---

## Next Step After This Screen

Build **FeedView** - the main feed showing published impressions from all users.
