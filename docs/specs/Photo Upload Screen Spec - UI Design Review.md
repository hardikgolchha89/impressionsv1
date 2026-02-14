# Screen Spec: Photo Upload ("Share some photos?")

## Screen Purpose
Allow users to add photos from their meal (optional step).

---

## Visual Layout

### Header Section
- **Background**: Black (`Color.appBackground`)
- **Back button**: Top-left, chevron left icon, white color
- **Title**: "Share some photos?" 
  - Font: `AppFont.title2`
  - Color: `Color.textPrimary` (white)
  - Position: Top center, below back button

### Photo Grid
- **Layout**: 3 columns x 2 rows = 6 slots
- **Spacing**: `Spacing.sm` between items
- **Padding**: `Spacing.md` on sides
- **Position**: Centered vertically on screen

### Photo Slot (Individual Item)
- **Size**: Square aspect ratio (fills 1/3 width minus spacing)
- **Corner radius**: `CornerRadius.large`
- **Empty state**:
  - Background: `Color.cardBackground` (dark gray)
  - Small image icon in center (SF Symbol: "photo")
  - Color: `Color.textTertiary`
- **Filled state**:
  - Shows selected photo
  - Small white checkmark badge in top-right corner
  - Badge: 24x24pt circle, white background, black checkmark
- **All slots tappable** (whether empty or filled)

### Bottom Buttons
**Two buttons stacked vertically:**

1. **Continue Button** (top)
   - Style: `.primaryButton()`
   - Text: "Continue"
   - Full width minus `Spacing.md` margins
   - Always visible

2. **Skip Button** (below)
   - Style: `.secondaryButton()`
   - Text: "Skip for now"
   - Full width minus `Spacing.md` margins
   - Allows proceeding without photos

**Spacing**: `Spacing.sm` between buttons
**Position**: Above bottom safe area with `Spacing.md` margin

---

## User Interactions

1. **Tap empty photo slot** → Photo picker opens (camera roll)
2. **Select photo** → Photo appears in slot with checkmark
3. **Tap filled slot** → Show options: "Change Photo" / "Remove Photo"
4. **Tap Continue** → Proceed with selected photos
5. **Tap Skip** → Proceed without photos
6. **Tap back** → Return to food order screen (photos saved in draft)

---

## Data Model

```swift
@State private var selectedPhotos: [Int: UIImage] = [:] // Key = slot index (0-5)
@State private var showImagePicker = false
@State private var selectedSlot: Int? = nil

// For image picker
@State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary
```

---

## Technical Notes

### Photo Picker
- Use `PhotosUI` framework (iOS 16+) or `UIImagePickerController`
- Allow selecting from photo library only (no camera for MVP)
- Photos stored in memory (@State) for now
- Later: Save to app documents or cloud storage

### Photo Grid Layout
```swift
let columns = [
    GridItem(.flexible(), spacing: Spacing.sm),
    GridItem(.flexible(), spacing: Spacing.sm),
    GridItem(.flexible(), spacing: Spacing.sm)
]

let photoSlots = 0..<6 // 6 total slots
```

### Image Handling
- Resize large images to max 1024x1024 to save memory
- Use `.aspectRatio(contentMode: .fill)` to fill slots
- Clip to rounded corners with `.clipShape(RoundedRectangle(...))`

### Action Sheet for Filled Slots
When tapping filled slot, show action sheet:
- "Change Photo" → Opens picker again
- "Remove Photo" → Clears that slot
- "Cancel"

---

## Design System Usage

- Background: `Color.appBackground`
- Empty slots: `Color.cardBackground`
- Text: `AppFont.title2`, `AppFont.body`
- Spacing: `Spacing.md`, `Spacing.sm`
- Corner radius: `CornerRadius.large`
- Buttons: `.primaryButton()`, `.secondaryButton()`
- Checkmark badge: Small white circle (24x24)

---

## Navigation
- Back button → Returns to FoodOrderView (saves photos in draft)
- Continue button → Navigate to PromptSelectionView
- Skip button → Navigate to PromptSelectionView (no photos)
- Pass all context + photos array

---

## Edge Cases
- No photos selected → Both Continue and Skip work the same
- All 6 slots filled → User can still change/remove any
- Photo picker canceled → No change to current selection
- Permission denied → Show alert: "Photo access required. Enable in Settings?"
- Large images → Automatically resize before storing
