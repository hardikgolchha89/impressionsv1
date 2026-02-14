# Quote Widget - Build Instructions

## What You're Building
A widget that displays a question prompt and the user's answer text.

---

## File to Create
**Filename:** `QuoteWidget.swift`

---

## Widget Appearance

### Overall Structure
```
┌─────────────────────────┐
│ YELLOW BACKGROUND       │
│                         │
│ Question prompt text    │
│                         │
│ User's answer text      │
│ that can wrap to        │
│ multiple lines          │
│                         │
└─────────────────────────┘
```

---

## Detailed Specifications

### Container
**Background:** Color.appYellow (#FFD93D)
**Corner radius:** 12px (CornerRadius.widget)
**Padding:** 16px all sides
**Height:** Flexible (based on text content, minimum ~140px)

---

### Content Layout
**VStack with leading alignment**

**Element 1 - Question/Prompt:**
- Font: System, 13pt, semibold
- Color: Dark gray/brown (Color.appDarkText)
- Max lines: 2
- Line spacing: 1.2
- Margin bottom: 8px (Spacing.sm)

**Element 2 - Answer Text:**
- Font: System, 15pt, regular
- Color: Dark gray/brown (Color.appDarkText)
- Max lines: None (can wrap as needed)
- Line spacing: 1.3
- Alignment: Leading

---

## Data Model

### QuoteData struct
**Properties:**
- `id: String`
- `prompt: String` (the question/prompt)
- `answer: String` (user's response)

### Widget accepts:
- `quote: QuoteData`

---

## Layout Measurements

**Container:**
- Background: Yellow
- Corner radius: 12px
- Padding: 16px all sides
- Min height: 140px (lets content expand if needed)

**Prompt text:**
- Font: 13pt semibold
- Color: appDarkText
- Bottom margin: 8px

**Answer text:**
- Font: 15pt regular
- Color: appDarkText
- Wraps naturally

---

## Sample Data for Preview

**Quote 1:**
- Prompt: "What did you notice that most people wouldn't?"
- Answer: "They were sharing their favourite dishes they like. If you speak to them and not just repeating the menu listings."

**Quote 2:**
- Prompt: "What made you think 'okay, they actually care here'?"
- Answer: "The staff started giving suggestions as per their liking and not just repeating the menu listings."

---

## Visual Example

```
┌─────────────────────────────────┐
│ Yellow container (rounded)      │
│                                 │
│ What did you notice that most   │ ← Prompt (13pt semibold)
│ people wouldn't?                │
│                                 │
│ They were sharing their         │ ← Answer (15pt regular)
│ favourite dishes they like.     │
│ If you speak to them and not    │
│ just repeating the menu         │
│ listings.                       │
│                                 │
└─────────────────────────────────┘
```

---

## Implementation Notes

1. **Flexible height**
   - Don't set fixed height
   - Let VStack size based on text content
   - Add minHeight modifier if needed (140px)

2. **Text wrapping**
   - Prompt can be 1-2 lines
   - Answer wraps as much as needed
   - Both use leading alignment

3. **Color contrast**
   - Dark text on yellow background
   - Ensure readability (use appDarkText)

4. **Spacing**
   - 16px padding around all content
   - 8px gap between prompt and answer

5. **Reusable**
   - Takes QuoteData as parameter
   - Can be used multiple times in grid
   - Works in half-width layout (2 columns)

---

## Where This Widget Goes

**Replace yellow placeholders in DetailView:**

Current:
```
Two yellow "Quote 1" and "Quote 2" placeholders
```

New:
```swift
HStack(spacing: Spacing.md) {
    QuoteWidget(quote: QuoteData(
        id: "1",
        prompt: "What did you notice...",
        answer: "They were sharing..."
    ))
    
    QuoteWidget(quote: QuoteData(
        id: "2",
        prompt: "What made you think...",
        answer: "The staff started..."
    ))
}
```

---

## Success Criteria

When done, you should see:
- Yellow rounded containers (2 side by side)
- Prompt text in semibold
- Answer text below in regular weight
- Text properly wrapping
- Dark text on yellow background
- Good spacing and padding
- Each widget ~140px+ height

---

## Cursor Prompt

Copy this into Cursor:

```
Create QuoteWidget.swift following QUOTE_INSTRUCTIONS.md

Requirements:
- Yellow container with rounded corners
- VStack: prompt text + answer text
- Prompt: 13pt semibold
- Answer: 15pt regular, wraps
- Dark text on yellow background
- QuoteData model
- Flexible height based on content
- Use design system constants
- Preview with 2 sample quotes
```

---

## After Building This Widget

**Update ImpressionDetailView:**

Replace the two yellow placeholders with actual QuoteWidget components in an HStack.

Pass 2 different QuoteData samples.

This becomes your second real widget type.
