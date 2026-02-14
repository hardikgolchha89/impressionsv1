# ContentView (Feed Screen) - Build Instructions

## What You're Building
The main feed screen that displays the header, scrollable cards, and bottom navigation.

---

## File to Update
**Filename:** `ContentView.swift` (replace existing content)

---

## Screen Structure

### Overall Layout
```
NavigationStack
└── ZStack
    ├── ScrollView (feed content)
    │   └── VStack
    │       ├── Header Section
    │       └── Cards Section
    └── Bottom Navigation (overlay)
```

---

## Detailed Specifications

### Header Section
**Layout:** VStack aligned to leading edge
**Spacing between elements:** 4px

**Line 1 - Greeting:**
- Text: "Hello Taashi!" (use actual user name when available)
- Font: System, 28pt, bold
- Color: Color.appDarkText
- No line limit

**Line 2 - Prompt + Action:**
- Layout: HStack with spacer between
- Left side text: "Been anywhere new?"
  - Font: System, 22pt, regular
  - Color: Color.appDarkText
- Right side button: "Share your\nImpression"
  - Font: System, 11pt, medium
  - Color: Color.appDarkText
  - Alignment: Trailing (right-aligned)
  - Multi-line text allowed
  - Action: Empty for now (placeholder)

**Section padding:**
- Horizontal: 16px (Spacing.lg)
- Top: 20px (Spacing.xl)
- Bottom: 20px (Spacing.xl)

---

### Cards Section
**Layout:** VStack with spacing

**Spacing between cards:** 16px (Spacing.lg)

**Content:**
- Show 3 FeedCardView components
- Use sample/mock data for now
- Alternate colors: Pink, Blue, Pink pattern

**Card 1 data:**
- Author: "Hardik G"
- Time: "12d ago"
- Title: "Life Changing Dinner at The Bombay Canteen after ages"
- Place: "The Bombay Canteen, Lower Parel"
- Companions: "Table for 5"
- Occasion: "First Date"
- Photos: 2 placeholders
- Color: Pink

**Card 2 data:**
- Author: "Taashi T"
- Time: "5d ago"
- Title: "Amazing brunch spot in Bandra"
- Place: "Cafe Zoe, Bandra"
- Companions: "Solo"
- Occasion: "Weekend Brunch"
- Photos: 2 placeholders
- Color: Blue

**Card 3 data:**
- Same as Card 1 (repeat for now)
- Color: Pink

**Section padding:**
- Horizontal: 16px (Spacing.lg)
- Bottom: 100px (space for bottom nav)

---

### ScrollView Container
**Background:** Light gray color (#F5F5F5)
- Use Color(hex: "F5F5F5")

**Scroll behavior:**
- Vertical only
- Bounces enabled (default)
- Shows scroll indicators (default)

---

### Bottom Navigation
**Layout:** Overlay positioned at bottom

**Structure:**
- VStack with Spacer pushing content to bottom
- HStack containing 3 icons
- Spacing between icons: 40px
- Background: Black (Color.black)
- Padding vertical: 16px
- Full width
- Ignores safe area on bottom edge

**Icons (left to right):**

**Icon 1 - Discover:**
- SF Symbol: `sparkles`
- Size: 24pt
- Color: White
- Action: None (placeholder)

**Icon 2 - Add (center):**
- SF Symbol: `plus.circle.fill`
- Size: 44pt
- Color: Red (Color.red)
- Action: None (placeholder)
- This icon is larger/prominent

**Icon 3 - Map:**
- SF Symbol: `map`
- Size: 24pt
- Color: White
- Action: None (placeholder)

**Navigation bar styling:**
- Full width
- Black background
- Icons centered horizontally
- Spans full width at bottom
- Overlays the ScrollView content

---

## Layout Measurements Summary

**Header:**
- Horizontal padding: 16px
- Top padding: 20px
- Bottom padding: 20px
- Internal spacing: 4px

**Cards:**
- Horizontal padding: 16px
- Spacing between cards: 16px
- Bottom padding: 100px (for nav clearance)

**Bottom Nav:**
- Height: ~76px (16px padding top/bottom + icons)
- Icon spacing: 40px
- Side icons: 24pt
- Center icon: 44pt

---

## Constants to Use

**Spacing:**
- `Spacing.lg` = 16px
- `Spacing.xl` = 20px

**Colors:**
- `Color.appDarkText`
- `Color(hex: "F5F5F5")` for background
- `Color.black` for nav bar
- `Color.red` for center nav icon

**Fonts:**
- Header greeting: `.system(size: 28, weight: .bold)`
- Header prompt: `.system(size: 22, weight: .regular)`
- Button text: `.system(size: 11, weight: .medium)`
- Nav icons: `.system(size: 24)` and `.system(size: 44)`

---

## Implementation Notes

1. Wrap everything in NavigationStack (for future navigation)
2. Use ZStack to overlay bottom nav on top of scroll content
3. Bottom nav should ignore safe area on bottom edge only
4. ScrollView should have light gray background
5. Cards use the FeedCardView component you just created
6. All data is hardcoded mock data for now
7. All button actions are empty closures for now
8. Bottom padding on cards section prevents content from hiding under nav

---

## Visual Hierarchy

```
┌─────────────────────────────────┐
│ Hello Taashi!          Share    │ ← Header (white/default bg)
│ Been anywhere new?     your     │
│                        Impression│
├─────────────────────────────────┤
│                                 │
│ ┌─────────────────────────────┐ │
│ │                             │ │
│ │   FeedCardView (Pink)       │ │ ← Card 1
│ │                             │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │                             │ │
│ │   FeedCardView (Blue)       │ │ ← Card 2
│ │                             │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │                             │ │
│ │   FeedCardView (Pink)       │ │ ← Card 3
│ │                             │ │
│ └─────────────────────────────┘ │
│                                 │
│ [extra space for scrolling]     │
│                                 │
├─────────────────────────────────┤
│    ✨        ⊕        🗺        │ ← Bottom nav (black)
└─────────────────────────────────┘
```

---

## Success Criteria

When done, you should see:
- Header with greeting and prompt at top
- 3 feed cards scrolling vertically
- Light gray background
- Black bottom nav bar with 3 icons
- Cards don't get hidden under bottom nav
- Smooth scrolling
- Center nav icon is larger and red

---

## Cursor Prompt

Copy this into Cursor:

```
Update ContentView.swift following CONTENTVIEW_INSTRUCTIONS.md

Requirements:
- NavigationStack wrapper
- Header with greeting and action button
- ScrollView with 3 FeedCardView instances
- Light gray background
- Bottom navigation overlay with 3 icons
- Use all spacing constants from DesignSystem
- Mock data for cards
- Match exact layout specifications
```
