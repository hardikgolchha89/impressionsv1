# Pairing Widget - Build Instructions

## What You're Building
A widget that suggests another place/restaurant that pairs well with this experience.

---

## File to Create
**Filename:** `PairingWidget.swift`

---

## Widget Appearance

### Overall Structure
```
┌─────────────────────────────────────┐
│ GREEN BACKGROUND                    │
│                                     │
│ I'd pair this up with               │
│                                     │
│ Bombay Sweet Shop,        [Photo]   │
│ Palladium Mall                      │
│                                     │
└─────────────────────────────────────┘
```

---

## Detailed Specifications

### Container
**Background:** Color.appGreen (#6BCB77)
**Corner radius:** 12px (CornerRadius.widget)
**Padding:** 16px all sides
**Height:** ~100-120px

---

### Content Layout
**VStack with leading alignment**

**Line 1 - Prompt Text:**
- Text: "I'd pair this up with"
- Font: System, 13pt, regular
- Color: White
- Margin bottom: 8px (Spacing.sm)

**Line 2 - Place Info + Photo:**
- HStack with space between
- Left side: Place name/location
- Right side: Small photo thumbnail

**Place Text (Left):**
- VStack with leading alignment
- Place name: System, 16pt, semibold, white
- Location: System, 13pt, regular, white 80% opacity
- Spacing between: 2px

**Photo Thumbnail (Right):**
- Size: 60x60px square
- Corner radius: 8px
- For now: Gray placeholder or actual image
- Content mode: Aspect fill

---

## Data Model

### PairingData struct
**Properties:**
- `id: String`
- `placeName: String`
- `location: String`
- `imageUrl: String?` (optional, for later)

### Widget accepts:
- `pairing: PairingData`

---

## Layout Measurements

**Container:**
- Background: Green
- Corner radius: 12px
- Padding: 16px all sides
- Height: ~100-120px

**Prompt text:**
- Font: 13pt regular white
- Bottom margin: 8px

**Bottom section HStack:**
- Space between: justified (Spacer)
- Left: Place info (flexible width)
- Right: Photo (60x60px fixed)

**Place info:**
- Name: 16pt semibold white
- Location: 13pt regular white 80%
- Vertical spacing: 2px

**Photo:**
- 60x60px square
- 8px corner radius
- Gray placeholder with icon

---

## Sample Data for Preview

**Pairing 1:**
- Place: "Bombay Sweet Shop"
- Location: "Palladium Mall"
- Image: nil (placeholder)

**Pairing 2:**
- Place: "Collin's"
- Location: "Malad"
- Image: nil (placeholder)

---

## Visual Example

```
┌─────────────────────────────────────┐
│ Green container (rounded)           │
│                                     │
│ I'd pair this up with               │ ← 13pt
│                                     │
│ Bombay Sweet Shop      ┌──────┐    │
│ Palladium Mall         │      │    │ ← 60x60 photo
│                        │ img  │    │
│                        └──────┘    │
│                                     │
└─────────────────────────────────────┘
```

---

## Implementation Notes

1. **Layout structure**
   ```
   VStack(alignment: .leading) {
       Text("I'd pair this up with")
       
       HStack {
           VStack(alignment: .leading) {
               Text(placeName) // bold
               Text(location)  // lighter
           }
           
           Spacer()
           
           // Photo thumbnail
           RoundedRectangle()
               .frame(width: 60, height: 60)
       }
   }
   ```

2. **Prompt text**
   - Simple white text
   - Separates from place info

3. **Place info**
   - Name is prominent (16pt semibold)
   - Location is secondary (13pt, 80% opacity)

4. **Photo placeholder**
   - Gray rounded rectangle
   - "photo" SF Symbol icon
   - Will be replaced with actual images later

5. **Spacing**
   - 16px padding all around
   - 8px between prompt and place info
   - 2px between place name and location
   - Photo aligned to trailing edge

---

## Where This Widget Goes

**Replace green pairing placeholder in DetailView:**

Current:
```
Green "I'd pair this up with..." placeholder
```

New:
```swift
PairingWidget(
    pairing: PairingData(
        id: "1",
        placeName: "Bombay Sweet Shop",
        location: "Palladium Mall",
        imageUrl: nil
    )
)
```

---

## Success Criteria

When done, you should see:
- Green rounded container
- "I'd pair this up with" text at top
- Place name + location on left
- Small 60x60 photo thumbnail on right
- White text on green background
- Proper spacing and alignment
- ~100-120px total height

---

## Cursor Prompt

Copy this into Cursor:

```
Create PairingWidget.swift following PAIRING_INSTRUCTIONS.md

Requirements:
- Green container with rounded corners
- "I'd pair this up with" prompt text
- HStack: place info (left) + photo (right)
- Place name: 16pt semibold white
- Location: 13pt regular white 80%
- Photo: 60x60px rounded square
- PairingData model
- Use design system constants
- Preview with sample data
```

---

## After Building This Widget

**Update ImpressionDetailView:**

Replace the green pairing placeholder with actual PairingWidget component.

Pass sample data for "Bombay Sweet Shop, Palladium Mall".

This becomes your fourth real widget type.
