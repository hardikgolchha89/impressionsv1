# Order List Widget - Build Instructions

## What You're Building
A widget that displays what was ordered at the restaurant with item names and variants/notes.

---

## File to Create
**Filename:** `OrderListWidget.swift`

---

## Widget Appearance

### Overall Structure
```
┌─────────────────────────────────┐
│ GREEN BACKGROUND                │
│                                 │
│ What did we order for the       │ ← Title
│ table?                          │
│                                 │
│ Benne Podi Masala Dosa          │ ← Item 1
│     chicken birria tacos        │   (sub-item)
│                                 │
│ Saag Burrata w/ Bhattura        │ ← Item 2
│     chicken birria tacos        │   (sub-item)
│                                 │
│ Veg Chettinad Biryani           │ ← Item 3
│                                 │
│ (more items...)                 │
│                                 │
└─────────────────────────────────┘
```

---

## Detailed Specifications

### Container
**Background:** Color.appGreen (#6BCB77)
**Corner radius:** 12px (CornerRadius.widget)
**Padding:** 16px all sides
**Height:** Flexible based on content

---

### Content Layout
**VStack with leading alignment**

**Section 1 - Title:**
- Text: "What did we order for the table?" (or customizable)
- Font: System, 14pt, semibold
- Color: White
- Margin bottom: 12px (Spacing.md)

**Section 2 - Order Items:**
- VStack of items
- Spacing between items: 8px (Spacing.sm)
- Each item can have:
  - Main item name
  - Optional sub-item/variant (indented)

---

## Order Item Layout

**Main Item:**
- Font: System, 15pt, medium
- Color: White
- Leading alignment

**Sub-item (if exists):**
- Font: System, 13pt, regular
- Color: White with 80% opacity
- Leading padding: 16px (indented)
- Italic style
- Top padding from main item: 2px

---

## Data Model

### OrderItem struct
**Properties:**
- `id: String`
- `name: String` (main item name)
- `variant: String?` (optional sub-item/note)

### Widget accepts:
- `title: String` (widget title, default "What did we order for the table?")
- `items: [OrderItem]` (array of ordered items)

---

## Layout Measurements

**Container:**
- Background: Green
- Corner radius: 12px
- Padding: 16px all sides

**Title:**
- Font: 14pt semibold white
- Bottom margin: 12px

**Items section:**
- Spacing between items: 8px
- Main item: 15pt medium white
- Sub-item: 13pt regular white 80% opacity, italic, 16px left indent

---

## Sample Data for Preview

**Title:** "What did we order for the table?"

**Items:**
1. Name: "Benne Podi Masala Dosa"
   Variant: "chicken birria tacos"

2. Name: "Saag Burrata w/ Bhattura"  
   Variant: "chicken birria tacos"

3. Name: "Veg Chettinad Biryani"
   Variant: nil

4. Name: "Iced Filter Coffee"
   Variant: nil

5. Name: "Raggi Uttappam"
   Variant: nil

6. Name: "chicken birria tacos"
   Variant: nil

---

## Visual Example

```
┌───────────────────────────────────┐
│ Green container (rounded)         │
│                                   │
│ What did we order for the table?  │ ← 14pt semibold
│                                   │
│ Benne Podi Masala Dosa            │ ← 15pt medium
│     chicken birria tacos          │ ← 13pt italic, indented
│                                   │
│ Saag Burrata w/ Bhattura          │
│     chicken birria tacos          │
│                                   │
│ Veg Chettinad Biryani             │ ← No variant
│                                   │
│ Iced Filter Coffee                │
│                                   │
└───────────────────────────────────┘
```

---

## Implementation Notes

1. **Title section**
   - Bold white text
   - Separated from items with 12px gap

2. **Items rendering**
   - Loop through OrderItem array
   - Show main name
   - If variant exists, show indented below

3. **Each item structure**
   ```
   VStack(alignment: .leading, spacing: 2) {
       Text(item.name) // main item
       if let variant = item.variant {
           Text(variant) // sub-item
               .padding(.leading, 16)
               .italic()
       }
   }
   ```

4. **Spacing**
   - Between complete items: 8px
   - Between main and sub-item: 2px (tight)
   - After title: 12px

5. **Color consistency**
   - All text white on green
   - Sub-items slightly transparent (80%)

---

## Where This Widget Goes

**Replace green "Order list" placeholder in DetailView:**

Current:
```
Green "Order list" placeholder
```

New:
```swift
OrderListWidget(
    title: "What did we order for the table?",
    items: [
        OrderItem(id: "1", name: "Benne Podi Masala Dosa", variant: "chicken birria tacos"),
        OrderItem(id: "2", name: "Saag Burrata w/ Bhattura", variant: "chicken birria tacos"),
        OrderItem(id: "3", name: "Veg Chettinad Biryani", variant: nil),
        // ... etc
    ]
)
```

---

## Success Criteria

When done, you should see:
- Green rounded container
- Title "What did we order for the table?" at top
- List of 6 food items
- Some items with indented variants/notes
- White text on green background
- Proper spacing and hierarchy
- Items aligned to leading edge

---

## Cursor Prompt

Copy this into Cursor:

```
Create OrderListWidget.swift following ORDERLIST_INSTRUCTIONS.md

Requirements:
- Green container with rounded corners
- Title at top (14pt semibold white)
- VStack list of ordered items
- Each item: name + optional variant
- Variants indented 16px, italic, 80% opacity
- OrderItem data model
- White text on green background
- Use design system constants
- Preview with 6 sample items
```

---

## After Building This Widget

**Update ImpressionDetailView:**

Replace the green "Order list" placeholder with actual OrderListWidget component.

Pass the sample data with 6 items (some with variants, some without).

This becomes your third real widget type.
