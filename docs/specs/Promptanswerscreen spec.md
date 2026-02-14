# Screen Spec: Prompt Answer Screen

## Screen Purpose
User answers a single selected prompt. This screen appears after tapping a prompt card.

---

## Visual Layout

### Header Section
- **Background**: Black (`Color.appBackground`)
- **Back button**: Top-left, chevron left icon, white color
- **Progress indicator**: "3/5" in top-right corner
  - Font: `AppFont.bodySmall`
  - Color: `Color.textSecondary`
  - Shows: (current answered count) / (total needed, e.g., 5)

### Prompt Display Card
- **Position**: Top of screen, below header
- **Style**: Same as selection screen
  - Background: Category color (yellow/pink/green/blue)
  - Corner radius: `CornerRadius.large`
  - White border: 1.5pt
  - Padding: `Spacing.md` inside
  - Full width minus `Spacing.md` margins
- **Content**: 
  - Prompt question text
  - Font: `AppFont.body`
  - Color: White
  - Read-only, not editable

### Answer Input Area
- **Position**: Below prompt card, `Spacing.md` gap
- **Style**:
  - Background: `Color.cardBackground` (dark gray)
  - Corner radius: `CornerRadius.large`
  - Full width minus `Spacing.md` margins
  - Min height: 200pt
  - Max height: Expandable with keyboard
  - Padding: `Spacing.md` inside
- **Placeholder**: "Your answer..."
  - Font: `AppFont.body`
  - Color: `Color.textTertiary`
- **Input text**:
  - Font: `AppFont.body`
  - Color: `Color.textPrimary` (white)
  - Multi-line text editor
  - Auto-focus when screen appears

### Media Attachment Options (Optional for MVP)
- **Position**: Below text input
- **Style**: Row of icon buttons
  - Camera icon
  - Photo library icon
  - Voice note icon
- **Later feature** - can skip for now

### Bottom Section
- **Submit button**:
  - Style: `.primaryButton()`
  - Text: "Submit Answer"
  - Full width minus `Spacing.md` margins
  - Position: Above bottom safe area
  - **Enabled only when**: Text is not empty (min 10 characters recommended)

---

## User Interactions

1. **Screen appears** → Text input auto-focuses, keyboard appears
2. **User types answer** → Submit button becomes enabled
3. **Tap submit** → Save answer, navigate back to prompt selection
4. **Tap back** → Show alert: "Discard answer?" (if text entered)
5. **Back without text** → Just navigate back (no alert)

---

## Data Model

```swift
struct PromptAnswer: Identifiable {
    let id: UUID
    let promptId: UUID
    let answerText: String
    let mediaAttachments: [URL]? // For future: photos, audio
    let timestamp: Date
}

// Passed from prompt selection:
let prompt: Prompt
let answeredCount: Int // How many prompts already answered
let totalRequired: Int // Usually 5

// State:
@State private var answerText: String = ""
@State private var showDiscardAlert: Bool = false
```

---

## Technical Notes

### Auto-Focus
- Use `.focused()` modifier to auto-focus text editor on appear
- Keyboard should appear automatically

### Text Editor Configuration
- Use SwiftUI `TextEditor` (multiline)
- Auto-capitalization: `.sentences`
- Keyboard type: `.default`
- Return key: `.default` (allows new lines)
- Min character count: 10 (optional validation)

### Submit Button Logic
```swift
var canSubmit: Bool {
    answerText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
}
```

### Navigation Back
- On submit → Pass answer back to parent view
- Update answered prompts list
- Return to PromptSelectionView
- That prompt now shows "answered" state

### Discard Alert
```swift
.alert("Discard answer?", isPresented: $showDiscardAlert) {
    Button("Discard", role: .destructive) {
        // Navigate back without saving
    }
    Button("Keep Writing", role: .cancel) { }
}
```

---

## Design System Usage

- Background: `Color.appBackground`
- Prompt card: Category color from prompt
- Input area: `Color.cardBackground`
- Text: `AppFont.body`, `AppFont.bodySmall`
- Colors: `Color.textPrimary`, `Color.textSecondary`, `Color.textTertiary`
- Spacing: `Spacing.md`
- Corner radius: `CornerRadius.large`
- Button: `.primaryButton()`

---

## Navigation Flow

### Entry:
- User taps prompt card in PromptSelectionView
- Pass: selected Prompt, current answered count

### Exit (Submit):
- Save answer
- Navigate back to PromptSelectionView
- Update that prompt's state to "answered"
- Increment answered count

### Exit (Back button):
- If text is empty → Just go back
- If text exists → Show discard alert first

---

## Updated PromptSelectionView Behavior

After implementing this screen, update PromptSelectionView:

### Prompt Card States:
1. **Unanswered** (default):
   - Normal appearance
   - Tappable → Opens answer screen

2. **Answered**:
   - Small checkmark badge in top-right corner (24x24, white circle, black check)
   - Still tappable → Opens answer screen with existing answer pre-filled
   - Shows "Edit" or just allows re-answering

### Continue Button:
- Hidden when < 3 prompts answered
- Visible when 3-5 prompts answered
- Tapping → Navigate to next major screen (preview/publish)

### Counter Update:
- Changes from "0/5 prompts selected" to "3/5 prompts answered"
- Updates live as user submits answers

---

## Edge Cases
- Empty answer → Submit disabled
- Very long answer (1000+ chars) → Allow, but scroll
- User answered 5 prompts, taps 6th → Show alert: "Max 5 prompts. Edit existing answer or continue."
- Keyboard covers input → Text editor should scroll with keyboard
- User leaves mid-answer → Auto-save draft (optional)
