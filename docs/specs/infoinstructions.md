# Info Widget - Build Instructions

## What You're Building
A widget that displays additional information, tips, or notes about the experience.

---

## File to Create
**Filename:** `InfoWidget.swift`

---

## Widget Appearance

### Overall Structure
```
┌─────────────────────┐
│ BLUE BACKGROUND     │
│                     │
│ Title/Question      │
│                     │
│ Answer/Info text    │
│ that wraps to       │
│ multiple lines      │
│                     │
└─────────────────────┘
```

---

## Detailed Specifications

### Container
**Background:** Color.appBlue (#A8D8EA)
**Corner radius:** 12px (CornerRadius.widget)
**Padding:** 16px all sides
**Height:** Flexible based on content (minimum ~120px)

---

### Content Layout
**VStack with leading alignment**

**Element 1 - Title/Question (Optional):**
- Font: System, 13pt, semibold
- Color: Dark text (Color.appDarkText)
- Max lines: 2
- Margin bottom: 8px (Spacing.sm)
- Only shows if title is provided

**Element 2 - Info Text:**
- Font: System, 14pt, regular
- Color: Dark text (Color.appDarkText)
- Max lines: None (wraps as needed)
- Line spacing: 1.3
- Alignment: Leading

---

## Data Model

### InfoData struct
**Properties:**
- `id: String`
- `title: String?` (optional question/prompt)
- `content: String` (the info/answer text)
- `icon: String?` (optional SF Symbol name for future)

### Widget accepts:
- `info: InfoData`

---

## Layout Measurements

**Container:**
- Background: Blue
- Corner radius: 12px
- Padding: 16px all sides
- Min height: 120px (flexible)

**Title (if present):**
- Font: 13pt semibold
- Color: appDarkText
- Bottom margin: 8px

**Content text:**
- Font: 14pt regular
- Color: appDarkText
- Wraps naturally

---

## Sample Data for Preview

**Info 1:**
- Title: "What was the vibe?"
- Content: "Kanda MH Gandhipuram Dadar 12:31 PM to 12:40 PM"

**Info 2:**
- Title: "How much did you spend?"
- Content: "We were 7 of us (2 adults). Price per person came around 700/-"

**Info 3 (no title):**
- Title: nil
- Content: "The place gets crowded after 8 PM. Best to arrive early or make a reservation."

---

## Visual Example

```
┌───────────────────────────┐
│ Blue container            │
│                           │
│ What was the vibe?        │ ← 13pt semibold
│                           │
│ Kanda MH Gandhipuram      │ ← 14pt regular
│ Dadar 12:31 PM to         │
│ 12:40 PM                  │
│                           │
└───────────────────────────┘
```

---

## Implementation Notes

1. **Conditional title**
   ```
   VStack(alignment: .leading, spacing: 8) {
       if let title = info.title {
           Text(title)
               .font(.system(size: 13, weight: .semibold))
       }
       
       Text(info.content)
           .font(.system(size: 14))
   }
   ```

2. **Flexible height**
   - Don't set fixed height
   - Let VStack size based on text
   - Use minHeight(120) if needed

3. **Text wrapping**
   - Both title and content wrap naturally
   - No line limits (unless too long)

4. **Color scheme**
   - Dark text on light blue background
   - Good contrast for readability

5. **Reusable**
   - Can be used in half-width layout (2 columns)
   - Works with or without title
   - Content length flexible

---

## Where This Widget Goes

**Replace blue info placeholders in DetailView:**

Currently showing as placeholders after photo widget.

Replace with:
```swift
HStack(spacing: Spacing.md) {
    InfoWidget(info: InfoData(
        id: "1",
        title: "What was the vibe?",
        content: "Kanda MH Gandhipuram Dadar 12:31 PM to 12:40 PM",
        icon: nil
    ))
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    
    InfoWidget(info: InfoData(
        id: "2",
        title: "How much did you spend?",
        content: "We were 7 of us (2 adults). Price per person came around 700/-",
        icon: nil
    ))
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}
```

---

## Success Criteria

When done, you should see:
- Light blue rounded containers (2 side by side)
- Title text in semibold (if present)
- Content text below in regular weight
- Dark text on blue background
- Good spacing and padding
- Equal width in 2-column layout
- Text properly wrapping
- ~120px+ height based on content

---

## Cursor Prompt

Copy this into Cursor:

```
Create InfoWidget.swift following INFO_INSTRUCTIONS.md

Requirements:
- Blue container with rounded corners
- VStack: optional title + content text
- Title: 13pt semibold (if provided)
- Content: 14pt regular, wraps
- Dark text on blue background
- InfoData model with optional title
- Flexible height based on content
- Use design system constants
- Preview with 2-3 sample info widgets
```

---

## After Building This Widget

**Update ImpressionDetailView:**

Replace the two blue info placeholders with actual InfoWidget components in an HStack.

Use the sample data provided above.

Make sure both widgets have equal width using the frame modifiers shown.

This becomes your fifth (and likely final core) widget type.
