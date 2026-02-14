# Photo Widget - Build Instructions

## What You're Building
A widget that displays user-uploaded photos from the impression.

---

## File to Create
**Filename:** `PhotoWidget.swift`

---

## Widget Appearance

### Overall Structure
```
┌─────────────────┐
│                 │
│                 │
│     PHOTO       │
│                 │
│                 │
└─────────────────┘
```

Simple photo display with optional caption.

---

## Detailed Specifications

### Container
**No background color** - Just the image itself
**Corner radius:** 12px (CornerRadius.image)
**Aspect ratio:** Square (1:1) or flexible based on image

---

### Photo Display
**Image specs:**
- Full size of widget
- Corner radius: 12px
- Content mode: Aspect fill (covers area without distortion)
- Clipped to bounds (no overflow)

**Placeholder (when no image):**
- Background: Gray at 30% opacity
- SF Symbol: "photo" icon, 32pt
- Icon color: Gray
- Centered

---

## Optional Caption
**If caption provided:**
- Show below photo
- Font: System, 12pt, regular
- Color: Color.appDarkText
- Max lines: 2
- Padding top: 6px
- Alignment: Leading

---

## Data Model

### PhotoData struct
**Properties:**
- `id: String`
- `imageUrl: String?` (photo URL or asset name)
- `caption: String?` (optional caption)

### Widget accepts:
- `photo: PhotoData`

---

## Layout Measurements

**Photo:**
- Full widget size
- Corner radius: 12px
- Aspect ratio: 1:1 (square) - or maintain original ratio

**Caption (if present):**
- Font: 12pt regular
- Top padding: 6px
- Max 2 lines

**Placeholder:**
- Gray background (30% opacity)
- Icon: 32pt "photo" symbol
- Square aspect ratio

---

## Sample Data for Preview

**Photo 1:**
- Image: nil (placeholder)
- Caption: nil

**Photo 2:**
- Image: nil (placeholder)
- Caption: "The presentation was beautiful"

---

## Visual Example

```
┌─────────────────┐
│                 │
│                 │
│   Gray Box      │ ← Placeholder or actual image
│   [photo icon]  │
│                 │
└─────────────────┘
  Optional caption text here
```

---

## Implementation Notes

1. **Basic structure**
   ```
   VStack(alignment: .leading, spacing: 6) {
       // Photo
       if let imageUrl = photo.imageUrl {
           Image(imageUrl)
               .resizable()
               .aspectRatio(1, contentMode: .fill)
               .clipShape(RoundedRectangle(cornerRadius: 12))
       } else {
           // Placeholder
           RoundedRectangle(cornerRadius: 12)
               .fill(Color.gray.opacity(0.3))
               .aspectRatio(1, contentMode: .fit)
               .overlay(
                   Image(systemName: "photo")
                       .font(.system(size: 32))
                       .foregroundColor(.gray)
               )
       }
       
       // Caption
       if let caption = photo.caption {
           Text(caption)
               .font(.system(size: 12))
               .lineLimit(2)
       }
   }
   ```

2. **Image handling**
   - For now, use placeholder
   - Later will load from URL or asset
   - Maintain aspect ratio
   - Fill the frame

3. **Square aspect**
   - Use `.aspectRatio(1, contentMode: .fill)` for square
   - Or remove aspect ratio constraint for original proportions

4. **Clipping**
   - Use `.clipShape(RoundedRectangle)` to clip overflow
   - Ensures corners stay rounded

5. **Reusable**
   - Can be used in half-width layout (2 columns)
   - Works with or without caption
   - Placeholder for missing images

---

## Where This Widget Goes

**Replace gray photo placeholders in DetailView:**

Currently showing 2 gray boxes after OrderListWidget.

Replace with:
```swift
HStack(spacing: Spacing.md) {
    PhotoWidget(photo: PhotoData(
        id: "1",
        imageUrl: nil, // placeholder for now
        caption: nil
    ))
    .frame(maxWidth: .infinity)
    
    PhotoWidget(photo: PhotoData(
        id: "2",
        imageUrl: nil, // placeholder for now
        caption: nil
    ))
    .frame(maxWidth: .infinity)
}
```

---

## Success Criteria

When done, you should see:
- 2 photo widgets side by side
- Gray placeholders with photo icons
- Square aspect ratio
- 12px rounded corners
- Equal width in 2-column layout
- Clean, simple presentation
- Ready to receive actual images later

---

## Cursor Prompt

Copy this into Cursor:

```
Create PhotoWidget.swift following PHOTO_INSTRUCTIONS.md

Requirements:
- Display photo or gray placeholder
- Square aspect ratio (1:1)
- 12px corner radius
- Optional caption below photo
- PhotoData model
- Placeholder: gray background + photo icon
- Use design system constants
- Preview with 2 sample photos
```

---

## After Building This Widget

**Update ImpressionDetailView:**

Replace the two gray photo placeholders with actual PhotoWidget components in an HStack.

Use placeholder PhotoData (nil images) for now.

Make sure both widgets have equal width.

This becomes your sixth widget type - completing the core widget system.

---

## Future Enhancement

Later you'll update this to:
- Load actual images from URLs
- Handle different aspect ratios
- Add tap to expand/view full screen
- Support captions from user input

For now, just get the structure working with placeholders.
