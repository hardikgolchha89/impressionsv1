# Screen Spec: Cover Photo Selection

## Screen Purpose
User selects one photo from their uploaded photos to be the cover/hero image for the impression.

---

## Visual Layout

### Header Section
- **Background**: Black (`Color.appBackground`)
- **Back button**: Top-left, chevron left icon, white color
- **Title**: "Choose a cover photo" 
  - Font: `AppFont.title2`
  - Color: `Color.textPrimary` (white)
  - Position: Top center

### Large Preview Area
- **Position**: Below title, centered vertically
- **Size**: 
  - Width: Full screen width minus `Spacing.md` x 2 (side margins)
  - Height: ~300pt (maintains aspect ratio of photo)
- **Style**:
  - Shows currently selected photo (full size)
  - Corner radius: `CornerRadius.large`
  - White border: 2pt
  - Shadow: `AppShadow.cardMedium`
- **Empty state** (if no photos):
  - Dark gray background (`Color.cardBackground`)
  - Camera icon centered
  - Text: "No photo selected"
  - Color: `Color.textTertiary`

### Thumbnail Strip
- **Position**: Below preview, `Spacing.md` gap
- **Layout**: Horizontal scrollable row
- **Style**: 
  - Height: 80pt
  - Spacing: `Spacing.xs` between thumbnails
  - Padding: `Spacing.md` on sides

### Thumbnail Item
- **Size**: 80x80pt square
- **Style**:
  - Corner radius: `CornerRadius.medium`
  - Shows photo cropped to fill square
- **Unselected state**:
  - Normal appearance
  - 1pt gray border
- **Selected state**:
  - White border: 3pt
  - White checkmark badge in top-right corner (24x24)

### Add Photo Button (in thumbnail strip)
- **Position**: Last item in thumbnail strip
- **Size**: 80x80pt square
- **Style**:
  - Background: `Color.cardBackground`
  - Dashed border: 2pt, `Color.textTertiary`
  - Corner radius: `CornerRadius.medium`
  - "+" icon centered
  - Font size: 32pt
  - Color: `Color.textTertiary`

### Continue Button
- **Position**: Bottom of screen, above safe area
- **Style**: `.primaryButton()`
- **Text**: "Continue"
- **Full width** minus `Spacing.md` margins
- **Enabled when**: At least one photo is selected

---

## User Interactions

1. **Screen loads**:
   - If photos exist → First photo auto-selected, shows in preview
   - If no photos → Empty preview, "Add Photo" button prominent

2. **Tap thumbnail** → Updates large preview, moves checkmark to that thumbnail

3. **Tap "Add Photo"** → Opens photo picker, adds to collection, auto-selects new photo

4. **Tap Continue** → 
   - Save selected photo as cover
   - Navigate to title customization screen

5. **Tap Back** → Return to prompt selection (save draft)

---

## Data Model

```swift
// Receive from parent:
let uploadedPhotos: [UIImage] // From photo upload screen

// State:
@State private var selectedPhotoIndex: Int? = nil // Index of selected photo
@State private var showPhotoPicker = false

// Computed:
var selectedPhoto: UIImage? {
    guard let index = selectedPhotoIndex,
          uploadedPhotos.indices.contains(index) else {
        return nil
    }
    return uploadedPhotos[index]
}
```

---

## Technical Notes

### Auto-Selection Logic
- On screen appear, if `uploadedPhotos.count > 0`:
  - Set `selectedPhotoIndex = 0` (select first photo)
  - Show it in large preview

### Thumbnail Strip
- Use `ScrollView(.horizontal)` with `HStack`
- Show all uploaded photos + "Add Photo" button
- Auto-scroll to selected thumbnail when selection changes

### Large Preview
- Use `.aspectRatio(contentMode: .fit)` to maintain photo proportions
- Max height: 300pt
- Center in available space

### Photo Picker Integration
- Reuse same photo picker logic from PhotoUploadView
- When photo added → append to `uploadedPhotos` array
- Auto-select newly added photo
- Update preview immediately

### Continue Button Logic
```swift
var canContinue: Bool {
    selectedPhotoIndex != nil
}
```

---

## Design System Usage

- Background: `Color.appBackground`
- Preview border: 2pt white
- Thumbnail borders: 3pt white (selected), 1pt gray (unselected)
- Add button border: 2pt dashed `Color.textTertiary`
- Text: `AppFont.title2`, `AppFont.body`
- Spacing: `Spacing.md`, `Spacing.xs`
- Corner radius: `CornerRadius.large`, `CornerRadius.medium`
- Shadow: `AppShadow.cardMedium`
- Button: `.primaryButton()`
- Checkmark: 24x24 white circle badge

---

## Navigation
- Back button → Returns to PromptSelectionView
- Continue button → Navigate to TitleCustomizationView
- Pass: selectedPhoto (UIImage)

---

## Edge Cases
- **No photos uploaded**: 
  - Show empty preview
  - "Add Photo" button is only option in thumbnail strip
  - Continue disabled until photo added

- **1 photo uploaded**:
  - Auto-select it
  - Thumbnail strip shows: [Photo 1] [Add Photo]
  - Continue enabled immediately

- **6+ photos uploaded**:
  - Thumbnail strip scrolls horizontally
  - All photos accessible
  - "Add Photo" at end allows adding more

- **User adds 10th photo**:
  - No limit for now (can add later)
  - All show in scrollable strip

- **Very tall/wide photos**:
  - Preview maintains aspect ratio
  - Fits within max 300pt height
  - Width adjusts accordingly
