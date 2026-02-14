# Map Widget - Build Instructions

## What You're Building
A widget that displays the restaurant/place location with a map pin icon and address.

---

## File to Create
**Filename:** `MapWidget.swift`

---

## Widget Appearance

### Overall Structure
```
┌─────────────────────────────┐
│ BLUE BACKGROUND             │
│                             │
│       📍                    │
│    (map pin icon)           │
│                             │
│    Kamala Mills             │
│    Compound, Lower          │
│    Parel, Mumbai            │
│                             │
│    See places nearby →      │
│                             │
└─────────────────────────────┘
```

---

## Detailed Specifications

### Container
**Background:** Color.appBlue (#A8D8EA)
**Corner radius:** 12px (CornerRadius.widget)
**Padding:** 20px all sides
**Height:** Flexible based on content (~160-180px)

---

### Content Layout
**VStack with center alignment**

**Element 1 - Map Pin Icon:**
- SF Symbol: `mappin.circle.fill`
- Size: 48pt
- Color: White
- Centered
- Margin bottom: 12px (Spacing.md)

**Element 2 - Place Name & Address:**
- Text alignment: Center
- Font: System, 16pt, semibold
- Color: White
- Max lines: 3-4 (for multi-line addresses)
- Line spacing: 1.2
- Margin bottom: 16px (Spacing.lg)

**Element 3 - Action Link:**
- Text: "See places nearby →"
- Font: System, 13pt, medium
- Color: White
- Italic style
- Centered
- Arrow symbol: → (or use SF Symbol `arrow.right`)

---

## Data Model

### MapData struct
**Properties:**
- `id: String`
- `placeName: String` (e.g., "Kamala Mills")
- `address: String` (e.g., "Compound, Lower Parel, Mumbai")
- `latitude: Double?` (optional, for future map integration)
- `longitude: Double?` (optional, for future map integration)

### Widget accepts:
- `map: MapData`

---

## Layout Measurements

**Container:**
- Background: Blue
- Corner radius: 12px
- Padding: 20px all sides

**Map pin icon:**
- Size: 48pt
- Color: White
- Bottom margin: 12px

**Place name & address:**
- Font: 16pt semibold white
- Center aligned
- Multi-line support
- Bottom margin: 16px

**Action link:**
- Font: 13pt medium white
- Italic
- Center aligned

**Total height:** ~160-180px (flexible)

---

## Sample Data for Preview

**Map 1:**
- Place Name: "Kamala Mills"
- Address: "Compound, Lower Parel, Mumbai"
- Lat/Long: nil (for now)

**Map 2:**
- Place Name: "The Bombay Canteen"
- Address: "Lower Parel, Mumbai"
- Lat/Long: nil (for now)

---

## Visual Example

```
┌─────────────────────────────┐
│ Blue container              │
│                             │
│          📍                 │ ← 48pt icon, white
│       (large pin)           │
│                             │
│    Kamala Mills             │ ← 16pt semibold
│    Compound, Lower          │    white, centered
│    Parel, Mumbai            │
│                             │
│  See places nearby →        │ ← 13pt italic
│                             │
└─────────────────────────────┘
```

---

## Implementation Notes

1. **Layout structure**
   ```
   VStack(alignment: .center, spacing: 0) {
       // Map pin icon
       Image(systemName: "mappin.circle.fill")
           .font(.system(size: 48))
           .foregroundColor(.white)
           .padding(.bottom, 12)
       
       // Place name + address (combined)
       Text("\(map.placeName)\n\(map.address)")
           .font(.system(size: 16, weight: .semibold))
           .foregroundColor(.white)
           .multilineTextAlignment(.center)
           .padding(.bottom, 16)
       
       // Action link
       Text("See places nearby →")
           .font(.system(size: 13, weight: .medium))
           .italic()
           .foregroundColor(.white)
   }
   ```

2. **Icon sizing**
   - Large 48pt pin is prominent
   - White stands out on blue

3. **Text handling**
   - Combine place name and address in single Text
   - Use `\n` for line break
   - Center alignment for both

4. **Action link**
   - Italic styling makes it look like link
   - Arrow indicates interactivity
   - For now, no action (placeholder)
   - Later: tap to open maps app

5. **Spacing**
   - Icon to text: 12px
   - Text to link: 16px
   - Creates good visual hierarchy

---

## Where This Widget Goes

**Add to widget types in DetailView:**

Include in the widgets array when building impressions:

```swift
.map(data: MapData(
    id: "1",
    placeName: "Kamala Mills",
    address: "Compound, Lower Parel, Mumbai",
    latitude: nil,
    longitude: nil
))
```

Can be placed anywhere in the widget flow - typically near top or bottom.

---

## Success Criteria

When done, you should see:
- Blue rounded container
- Large white map pin icon at top
- Place name and address centered (multi-line)
- White text on blue background
- "See places nearby" link at bottom
- Clean, simple, readable layout
- ~160-180px height

---

## Future Enhancements

Later you can add:
- Tap to open in Apple Maps / Google Maps
- Actual embedded map view (using MapKit)
- Show nearby places from same area
- Distance from user's location
- Map preview thumbnail

For now, just get the structure working.

---

## Cursor Prompt

Copy this into Cursor:

```
Create MapWidget.swift following MAP_INSTRUCTIONS.md

Requirements:
- Blue container with rounded corners
- VStack centered content
- Large map pin icon (48pt) at top
- Place name + address text (16pt semibold, centered)
- "See places nearby →" link at bottom (13pt italic)
- White text on blue background
- MapData model with placeName, address, lat/long
- Use design system constants
- Preview with sample data
```

---

## After Building This Widget

1. Test the widget in preview
2. Add MapData to your widget types enum
3. Include in DetailView widget rendering switch case
4. Add sample map widget to MockData impressions

This becomes your seventh widget type.
