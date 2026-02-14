# DetailView (Impression Detail) - Build Instructions

## What You're Building
The full impression detail screen that shows when user taps "Read Post" on a feed card.

---

## File to Create
**Filename:** `ImpressionDetailView.swift`

---

## Screen Structure

### Overall Layout
```
ScrollView
├── Hero Image (full width, top)
└── Content Container (overlapping hero slightly)
    ├── Title
    ├── Author Header (with Share/Recommend icons)
    ├── Metadata Section
    └── Widgets Grid (scrollable)
```

---

## Detailed Specifications

### Hero Image Section
**Layout:** Full width at top of screen

**Image specs:**
- Width: Full screen width
- Height: 400px fixed
- Corner radius: 0 (full bleed to edges)
- Border: 4px solid blue (#A8D8EA or Color.appBlue)
- Border on all 4 sides
- Content mode: Aspect fill (covers area)
- For now: Gray placeholder with "photo" icon

**Placeholder styling:**
- Background: Gray at 30% opacity
- Icon: "photo" SF Symbol, gray color, 40pt size
- Centered in the frame

---

### Content Container
**This overlaps the hero image slightly (like in your design)**

**Background:** Same color as card (pink or blue)
**Corner radius:** 24px on top corners only (bottom stays square)
**Position:** Starts 20px before hero image ends (creates overlap effect)
**Padding:** 24px all sides (Spacing.xxl)

**Layout inside container:**
- VStack with leading alignment
- Spacing between sections varies (see below)

---

### Title Section
**First element in content container**

**Text specs:**
- Font: System, 24pt, bold (larger than feed card)
- Color: Color.appDarkText
- Line limit: None (can wrap multiple lines)
- Alignment: Leading

**Spacing below:** 16px (Spacing.lg)

---

### Author Header with Actions
**Layout:** HStack with content on both sides

**Left side - Author info:**
- Same as feed card
- Avatar: 40x40 circle (slightly larger than feed)
- Name: AppFont.author()
- Timestamp: AppFont.timestamp() in gray
- Vertical stack with 2px gap
- Horizontal gap between avatar and text: 8px (Spacing.sm)

**Right side - Action icons:**
- HStack with 2 icons
- Gap between icons: 12px (Spacing.md)
- Vertically centered with author name/timestamp

**Share icon:**
- SF Symbol: `square.and.arrow.up`
- Size: 22px
- Color: Dark red/maroon (same as title color)
- Touch target: 44x44px minimum
- Action: Empty for now

**Recommend icon:**
- SF Symbol: `star.circle`
- Size: 22px
- Color: Dark red/maroon (same as title color)
- Touch target: 44x44px minimum
- Action: Empty for now

**Section spacing below:** 16px (Spacing.lg)

---

### Metadata Section
**Same as feed card**

**Layout:** VStack with 3 rows
- Row spacing: 4px (Spacing.xs)
- Same icons and styling as feed card
- Location, Companions, Occasion

**Section spacing below:** 20px (Spacing.xl)

---

### Widgets Grid Section
**This is the scrollable area with various widget types**

**Layout:** VStack with custom spacing

**Widget grid rules:**
- Some widgets are full width (1 column)
- Some widgets are half width (2 columns side by side)
- Gap between widgets: 12px (Spacing.md)
- All widgets have 12px corner radius (CornerRadius.widget)

**Widget arrangement for MVP:**
Show these widgets in order (all placeholders for now):

1. **Food Grid Widget** (full width, green)
   - Background: Color.appGreen
   - Height: 120px
   - Corner radius: 12px
   - Placeholder text: "Food items grid" centered, white color

2. **Two Quote Widgets** (half width each, yellow)
   - Background: Color.appYellow
   - Height: 140px each
   - Side by side with 12px gap
   - Corner radius: 12px
   - Placeholder text: "Quote 1" and "Quote 2" centered

3. **What did you order Widget** (full width, green)
   - Background: Color.appGreen
   - Height: 150px
   - Corner radius: 12px
   - Placeholder text: "Order list" centered, white color

4. **Photo + Info Widgets** (half width each)
   - Left: Gray placeholder (like feed photos)
   - Right: Blue background (Color.appBlue)
   - Height: 160px each
   - 12px gap between them
   - Corner radius: 12px

5. **Pairing Widget** (full width, green with image)
   - Background: Color.appGreen
   - Height: 100px
   - Corner radius: 12px
   - Placeholder text: "I'd pair this up with..." white color

6. **Two Info Widgets** (half width each, blue)
   - Background: Color.appBlue
   - Height: 120px each
   - Side by side with 12px gap
   - Corner radius: 12px
   - Placeholder text: "Info 1" and "Info 2" centered

**Bottom padding:** 40px (extra space after last widget)

---

## Layout Measurements

### Hero Image:
- Width: Full screen
- Height: 400px
- Border: 4px blue
- Overlap: Content starts 20px before hero ends

### Content Container:
- Corner radius top: 24px
- Padding: 24px all sides
- Background: Pink or blue (matches card color)

### Section Spacing:
- Title to Author: 16px
- Author to Metadata: 16px
- Metadata to Widgets: 20px
- Between widgets: 12px
- After last widget: 40px

### Author Header:
- Avatar: 40x40px
- Icons: 22px each
- Icon gap: 12px
- Touch target: 44x44px

---

## Data Model for Detail View

### Create struct `ImpressionDetail`
**Properties:**
- Same as ImpressionPreview PLUS:
- `heroImage: String` (main large image)
- `widgets: [WidgetType]` (array of widget data - placeholder for now)

**For now, just use:**
- heroImage: placeholder string
- widgets: empty array (we'll build widget types later)

---

## Widget Placeholder Helper

**Create a simple helper view for now:**

**WidgetPlaceholder:**
- Accepts: background color, height, text
- Shows: Colored rectangle with text centered
- Corner radius: 12px
- Text: White or dark depending on background

This lets you build the grid layout without building actual widgets yet.

---

## Navigation

**This view is shown when:**
- User taps a FeedCardView
- Pushed onto navigation stack

**Add to FeedCardView:**
- Wrap entire card in NavigationLink
- Destination: ImpressionDetailView
- Pass the impression data

**Back button:**
- Standard iOS back button (automatic with NavigationStack)
- No custom back button needed

---

## Color Assignment

**Content container background:**
- If impression.cardColor == .pink → Color.appPink
- If impression.cardColor == .blue → Color.appBlue

**Hero image border:**
- Always Color.appBlue (4px)

---

## Visual Structure

```
┌─────────────────────────────────┐
│                                 │
│       HERO IMAGE                │
│       (400px tall)              │
│       [blue border]             │
│                                 │
├─────────────────────────────────┤ ← overlaps hero by 20px
│ ╔═════════════════════════════╗ │
│ ║ PINK/BLUE CONTAINER         ║ │
│ ║ (rounded top corners)       ║ │
│ ║                             ║ │
│ ║ Title                       ║ │
│ ║                             ║ │
│ ║ [Avatar] Name    [↗][⭐]   ║ │
│ ║         Time                ║ │
│ ║                             ║ │
│ ║ 📍 Metadata                 ║ │
│ ║ 👥 Metadata                 ║ │
│ ║ 📅 Metadata                 ║ │
│ ║                             ║ │
│ ║ ┌─────────────────────┐     ║ │
│ ║ │  GREEN WIDGET       │     ║ │
│ ║ └─────────────────────┘     ║ │
│ ║                             ║ │
│ ║ ┌──────┐ ┌──────┐           ║ │
│ ║ │YELLOW│ │YELLOW│           ║ │
│ ║ └──────┘ └──────┘           ║ │
│ ║                             ║ │
│ ║ ┌─────────────────────┐     ║ │
│ ║ │  GREEN WIDGET       │     ║ │
│ ║ └─────────────────────┘     ║ │
│ ║                             ║ │
│ ║ (more widgets...)           ║ │
│ ║                             ║ │
│ ╚═════════════════════════════╝ │
└─────────────────────────────────┘
```

---

## Implementation Notes

1. Hero image stays at top, doesn't scroll with content
   - Actually, let it scroll for now (simpler)
   - We can make it sticky later if needed

2. Content container has rounded top corners only
   - Use `.clipShape(RoundedRectangle(cornerRadius: 24))` on top
   - Or use custom shape with top-only corners

3. For half-width widgets, use HStack with equal sizing
   - Each widget gets `.frame(maxWidth: .infinity)`

4. All widgets are placeholders for now
   - Just colored rectangles with text
   - We'll build actual widget views next

5. Share/Recommend icons should look tappable
   - Use `.buttonStyle(.plain)` or custom button styling
   - Add subtle animation on tap (optional)

---

## Success Criteria

When done, you should see:
- Hero image at top with blue border
- Pink/blue content overlapping hero slightly
- Title larger than feed card
- Author header with 2 action icons on right
- Metadata section
- Grid of placeholder widgets in various layouts
- Smooth scrolling
- Navigation from feed card works

---

## Cursor Prompt

Copy this into Cursor:

```
Create ImpressionDetailView.swift following DETAILVIEW_INSTRUCTIONS.md

Requirements:
- ScrollView with hero image at top
- Content container with rounded top corners
- Title, author header with share/recommend icons
- Metadata section (same as feed card)
- Widget grid with placeholders (various layouts)
- Accept ImpressionDetail data model
- Use all design system constants
- Add NavigationLink to FeedCardView to navigate here
```

---

## Additional Task: Update FeedCardView

**After creating ImpressionDetailView, update FeedCardView:**

Wrap the entire card content in NavigationLink:

```
NavigationLink(destination: ImpressionDetailView(impression: convertToDetail())) {
    // existing card content
}
.buttonStyle(.plain)
```

You'll need to convert ImpressionPreview to ImpressionDetail (just add heroImage field).
