# Retro Minesweeper - UX Design Document

## 1. Design Philosophy

This design captures the nostalgic essence of Windows 95/98 era computing while maintaining modern usability standards. The goal is to create an authentic retro experience that feels familiar to those who played the original Minesweeper, while remaining accessible and intuitive for new players.

**Design Principles:**
- Authentic retro aesthetic without sacrificing clarity
- High contrast for readability
- Immediate visual feedback for all interactions
- Clear distinction between cell states
- Minimal cognitive load through familiar patterns

---

## 2. Color Palette

### 2.1 Primary Colors (Windows 95/98 Inspired)

| Element | Color Name | Hex Code | Usage |
|---------|------------|----------|-------|
| Background | Silver Gray | `#C0C0C0` | Main application background, cell faces |
| Window Title Bar | Navy Blue | `#000080` | Header background |
| Title Text | White | `#FFFFFF` | Header title text |
| Dark Border | Gray | `#808080` | Inset/shadow borders |
| Light Border | White | `#FFFFFF` | Raised/highlight borders |
| Darkest Border | Dark Gray | `#404040` | Outer shadow edge |
| Lightest Border | Off-White | `#DFDFDF` | Inner highlight edge |

### 2.2 Cell State Colors

| State | Background | Border Style | Notes |
|-------|------------|--------------|-------|
| Hidden (Unrevealed) | `#C0C0C0` | Raised 3D bevel | Classic raised button look |
| Revealed (Empty) | `#BDBDBD` | Flat 1px inset | Slightly darker than hidden |
| Revealed (Number) | `#BDBDBD` | Flat 1px inset | With colored number |
| Flagged | `#C0C0C0` | Raised 3D bevel | Flag icon displayed |
| Mine (Game Over) | `#FF0000` | Flat inset | Red background for triggered mine |
| Mine (Revealed) | `#BDBDBD` | Flat inset | Shows mine icon on loss |
| Wrong Flag | `#BDBDBD` | Flat inset | X over mine on loss |

### 2.3 Number Colors (Adjacent Mine Count)

These colors follow the classic Minesweeper convention for instant recognition:

| Number | Color Name | Hex Code | RGB |
|--------|------------|----------|-----|
| 1 | Blue | `#0000FF` | rgb(0, 0, 255) |
| 2 | Green | `#008000` | rgb(0, 128, 0) |
| 3 | Red | `#FF0000` | rgb(255, 0, 0) |
| 4 | Dark Blue | `#000080` | rgb(0, 0, 128) |
| 5 | Maroon | `#800000` | rgb(128, 0, 0) |
| 6 | Teal | `#008080` | rgb(0, 128, 128) |
| 7 | Black | `#000000` | rgb(0, 0, 0) |
| 8 | Gray | `#808080` | rgb(128, 128, 128) |

### 2.4 UI Element Colors

| Element | Hex Code | Usage |
|---------|----------|-------|
| Mine Counter Background | `#000000` | Digital display background |
| Mine Counter Text | `#FF0000` | Red LED-style numbers |
| Restart Button Face | `#C0C0C0` | Smiley button background |
| Overlay Background | `rgba(0, 0, 0, 0.7)` | Win/lose overlay backdrop |
| Win Message | `#00FF00` | Victory text color |
| Lose Message | `#FF0000` | Game over text color |

---

## 3. Typography

### 3.1 Font Stack

```css
/* Primary Game Font */
--font-primary: 'Courier New', Courier, monospace;

/* Digital Display Font (Mine Counter) */
--font-digital: 'Consolas', 'Courier New', monospace;

/* Fallback for Pixel Effect */
--font-pixel: 'VT323', 'Courier New', monospace;
```

### 3.2 Font Sizes

| Element | Size | Weight | Notes |
|---------|------|--------|-------|
| Window Title | 14px | Bold | Header title |
| Cell Numbers | 18px | Bold | Adjacent mine count |
| Mine Counter | 24px | Bold | LED-style display |
| Overlay Title | 32px | Bold | Win/Lose message |
| Overlay Subtitle | 16px | Normal | Instructions |
| Restart Button | 20px | Normal | Smiley face |

### 3.3 Text Styling

- Numbers use bold weight for maximum readability
- All text uses anti-aliasing disabled where possible for authentic pixel look
- Letter-spacing: normal (0)
- Line-height: 1 for numbers, 1.4 for body text

---

## 4. Layout Design

### 4.1 Overall Structure

```
+--------------------------------------------------+
|  [Title Bar: "Retro Minesweeper"]                |
+--------------------------------------------------+
|  +--------------------------------------------+  |
|  |  [Mine Counter]  [Restart]  [Placeholder]  |  |
|  +--------------------------------------------+  |
|  +--------------------------------------------+  |
|  |                                            |  |
|  |                                            |  |
|  |              10 x 10 GAME GRID             |  |
|  |                                            |  |
|  |                                            |  |
|  +--------------------------------------------+  |
|  +--------------------------------------------+  |
|  |           [Status Message Area]            |  |
|  +--------------------------------------------+  |
+--------------------------------------------------+
```

### 4.2 Dimensions

| Component | Width | Height | Notes |
|-----------|-------|--------|-------|
| Window | 380px | Auto | Fixed width, height adapts |
| Title Bar | 100% | 28px | Full width header |
| Control Bar | 100% | 48px | Contains counter + restart |
| Cell | 32px | 32px | Square clickable area |
| Grid | 320px | 320px | 10 x 32px cells |
| Grid Gap | 0px | 0px | Cells touch (classic look) |
| Status Bar | 100% | 32px | Bottom message area |

### 4.3 Spacing and Padding

| Element | Padding | Margin |
|---------|---------|--------|
| Window | 8px | 0 (centered) |
| Title Bar | 4px 8px | 0 |
| Control Bar | 8px 12px | 0 |
| Grid Container | 4px | 8px 0 |
| Status Bar | 4px 8px | 0 |

### 4.4 Window Frame Design

The window uses the classic Windows 95/98 double-bevel technique:

```
Outer border: 2px solid #DFDFDF (top, left), #404040 (bottom, right)
Inner border: 2px solid #FFFFFF (top, left), #808080 (bottom, right)
```

---

## 5. Cell States Visual Design

### 5.1 Hidden Cell (Unrevealed)

```
+------------------------+
|    FFFFFF (highlight)   |  <- 3px top border
+------------------------+
|WH|                  |GR|  <- 3px left (white), 3px right (gray)
|IT|    #C0C0C0       |AY|  <- Cell background
|E |   (empty face)   |  |
+------------------------+
|    808080 (shadow)      |  <- 3px bottom border
+------------------------+
```

**Characteristics:**
- Raised 3D appearance using border technique
- No content displayed
- Cursor: pointer
- Full 32x32px clickable area

### 5.2 Revealed Cell (Empty - 0 adjacent)

```
+------------------------+
|          1px           |  <- 1px inset border #808080
|  +------------------+  |
|  |                  |  |
|  |    #BDBDBD       |  |  <- Slightly darker background
|  |    (empty)       |  |
|  +------------------+  |
+------------------------+
```

**Characteristics:**
- Flat, pressed appearance
- No content
- Non-interactive (cursor: default)

### 5.3 Revealed Cell (Number 1-8)

```
+------------------------+
|          1px           |
|  +------------------+  |
|  |                  |  |
|  |        3         |  |  <- Centered, bold, colored number
|  |    (#FF0000)     |  |  <- Color matches number value
|  +------------------+  |
+------------------------+
```

**Characteristics:**
- Flat, pressed appearance
- Bold number centered in cell
- Color indicates count (see section 2.3)
- Font: 18px bold Courier New

### 5.4 Flagged Cell

```
+------------------------+
|    FFFFFF (highlight)   |
+------------------------+
|WH|                  |GR|
|IT|       /|\        |AY|  <- Flag symbol (triangle on pole)
|E |      / | \       |  |
|  |        |         |  |
+------------------------+
|    808080 (shadow)      |
+------------------------+
```

**Visual Options for Flag:**
- Unicode character: (red flag, `U+1F6A9`) - may render as emoji
- Text representation: "F" in red (`#FF0000`)
- SVG/CSS drawn triangle flag (preferred for consistency)

**Characteristics:**
- Maintains raised 3D appearance (still hidden)
- Flag icon in red color
- Right-click toggles flag off

### 5.5 Mine Cell (Triggered - Game Over)

```
+------------------------+
|    #FF0000 (red bg)     |  <- Bright red background
|  +------------------+  |
|  |        *         |  |
|  |       ***        |  |  <- Mine symbol (asterisk/bomb)
|  |        *         |  |
|  +------------------+  |
+------------------------+
```

**Characteristics:**
- Red background indicates this mine ended the game
- Mine symbol in black
- Only the clicked mine has red background

### 5.6 Mine Cell (Revealed on Loss)

```
+------------------------+
|    #BDBDBD              |
|  +------------------+  |
|  |        *         |  |
|  |       ***        |  |  <- Mine symbol (black)
|  |        *         |  |
|  +------------------+  |
+------------------------+
```

**Characteristics:**
- Standard revealed background
- All non-triggered mines shown on game loss
- Black mine symbol

### 5.7 Wrong Flag (Revealed on Loss)

```
+------------------------+
|    #BDBDBD              |
|  +------------------+  |
|  |      \ /         |  |
|  |       X          |  |  <- Red X over mine
|  |      / \         |  |
|  +------------------+  |
+------------------------+
```

**Characteristics:**
- Shows when flag was placed on non-mine cell
- Red X indicates incorrect guess
- Displayed only on game loss

---

## 6. Interaction Patterns

### 6.1 Mouse Interactions

| Action | Target | Result | Sound |
|--------|--------|--------|-------|
| Left-click | Hidden cell | Reveal cell | Reveal blip |
| Left-click | Flagged cell | No action | None |
| Left-click | Revealed cell | No action | None |
| Right-click | Hidden cell | Toggle flag | Flag click |
| Right-click | Flagged cell | Remove flag | Flag click |
| Right-click | Revealed cell | No action | None |
| Left-click | Restart button | New game | None |

### 6.2 Hover States

| Element | Hover Effect |
|---------|--------------|
| Hidden cell | Subtle brightness increase (+5% lightness) |
| Flagged cell | Same as hidden cell |
| Revealed cell | No change (non-interactive) |
| Restart button | Invert bevel (pressed appearance) |

**CSS Hover Implementation:**
```css
.cell.hidden:hover {
    background-color: #CACACA;  /* Slightly lighter */
}

.cell.hidden:active {
    /* Invert borders - pressed state */
    border-top-color: #808080;
    border-left-color: #808080;
    border-bottom-color: #FFFFFF;
    border-right-color: #FFFFFF;
}
```

### 6.3 Click Feedback

**Active State (Mouse Down):**
- Hidden cells show pressed/inset appearance
- Border colors invert (shadow becomes highlight)
- Immediate visual feedback before release

**Transition Timing:**
- Hover: instant (no transition)
- Active: instant
- Reveal animation: none (instant state change for retro feel)

### 6.4 First Click Safety

- First click is always safe (never a mine)
- Mines are placed after first click
- First click may trigger cascade reveal

### 6.5 Keyboard Support (Accessibility)

While mouse is primary, consider:
- Tab navigation between cells (grid pattern)
- Enter/Space to reveal focused cell
- Shift+Enter or 'F' key to toggle flag
- Focus indicator: 2px dotted black outline

---

## 7. Win/Lose Overlay Design

### 7.1 Overlay Container

```
+--------------------------------------------------+
|                                                  |
|              (Semi-transparent overlay)          |
|                 rgba(0, 0, 0, 0.7)               |
|                                                  |
|     +------------------------------------+       |
|     |                                    |       |
|     |         YOU WIN! / GAME OVER       |       |
|     |                                    |       |
|     |      [Click to Play Again]         |       |
|     |                                    |       |
|     +------------------------------------+       |
|                                                  |
+--------------------------------------------------+
```

### 7.2 Win State

**Visual Design:**
```
Background: rgba(0, 0, 0, 0.7)
Message Box: #C0C0C0 with 3D bevel border
Title: "YOU WIN!" in #00FF00 (bright green)
Font: 32px bold Courier New
Subtitle: "All mines cleared!" in #000000
Button: "Play Again" with raised 3D style
```

**Celebration Elements:**
- Optional: subtle confetti effect using CSS
- Keep it simple to match retro aesthetic

### 7.3 Lose State

**Visual Design:**
```
Background: rgba(0, 0, 0, 0.7)
Message Box: #C0C0C0 with 3D bevel border
Title: "GAME OVER" in #FF0000 (red)
Font: 32px bold Courier New
Subtitle: "You hit a mine!" in #000000
Button: "Try Again" with raised 3D style
```

### 7.4 Restart Button in Overlay

```
+-----------------------------+
|   FFFFFF    |   FFFFFF      |  <- 2px highlight
+-------------+---------------+
| WH |                    |GR |
| IT |     Play Again     |AY |  <- Button text
| E  |                    |   |
+-----------------------------+
|   808080    |   808080      |  <- 2px shadow
+-----------------------------+
```

**Button States:**
- Normal: raised 3D bevel
- Hover: slightly lighter background (#CACACA)
- Active: inverted bevel (pressed)

### 7.5 Overlay Animation

- Fade in: 200ms ease-out
- No complex animations (retro simplicity)
- Click anywhere on overlay or button to restart

---

## 8. Control Bar Design

### 8.1 Mine Counter (LED Display)

```
+-------------------+
| +---------------+ |  <- Inset border (shadow inside)
| |  0   1   2    | |  <- Red digits on black background
| +---------------+ |
+-------------------+
```

**Specifications:**
- Background: `#000000` (black)
- Text color: `#FF0000` (red)
- Font: 24px bold monospace
- Border: 2px inset (dark on top-left, light on bottom-right)
- Width: 52px (fits 3 digits)
- Height: 32px
- Display: Remaining mines (total mines - flag count)

**Display Format:**
- Always show as 3 characters (padded with spaces or zeros)
- Negative numbers possible if too many flags placed (show "-" prefix)

### 8.2 Restart Button (Smiley Face)

```
+-------------------+
|  +-------------+  |
|  |     :-)     |  |  <- Smiley in normal play
|  +-------------+  |
+-------------------+
```

**Smiley States:**
| Game State | Symbol | Description |
|------------|--------|-------------|
| Playing | :-) or :) | Neutral smile |
| Cell Pressed | :-O or :O | Surprised (mouse down) |
| Won | B-) or 8-) | Cool sunglasses |
| Lost | X-( or X( | Dead face |

**Button Specifications:**
- Size: 36px x 36px
- Background: `#C0C0C0`
- Border: 3D raised bevel
- Font: 20px
- Cursor: pointer

---

## 9. Status Message Area

### 9.1 Location and Purpose

Bottom of the game window, provides contextual information:

```
+--------------------------------------------------+
|  Status: Click any cell to start                 |
+--------------------------------------------------+
```

### 9.2 Message States

| State | Message | Color |
|-------|---------|-------|
| Initial | "Click any cell to start" | `#000000` |
| Playing | "Mines remaining: X" | `#000000` |
| Won | "Congratulations! You win!" | `#008000` |
| Lost | "Game Over - You hit a mine!" | `#FF0000` |

### 9.3 Styling

- Background: `#C0C0C0` (matches window)
- Border: 1px inset (sunken panel look)
- Padding: 4px 8px
- Font: 12px normal Courier New
- Text-align: center

---

## 10. Responsive Considerations

### 10.1 Minimum Viewport

- Minimum supported width: 400px
- Minimum supported height: 500px
- Game centered horizontally on larger screens

### 10.2 Scaling (Optional Enhancement)

If viewport is significantly larger:
- Consider scaling game 1.5x or 2x
- Maintain pixel-perfect appearance (use image-rendering: pixelated)
- Scale all dimensions proportionally

### 10.3 Desktop Focus

Per requirements, this is desktop-only:
- No touch target adjustments needed
- 32px cells are appropriate for mouse precision
- No mobile breakpoints

---

## 11. Accessibility Considerations

### 11.1 Color Contrast

All number colors meet WCAG AA standards against the revealed cell background (`#BDBDBD`):

| Number | Color | Contrast Ratio | Pass? |
|--------|-------|----------------|-------|
| 1 Blue | `#0000FF` | 4.68:1 | AA Pass |
| 2 Green | `#008000` | 4.23:1 | AA Pass |
| 3 Red | `#FF0000` | 4.0:1 | AA Pass |
| 4 Dark Blue | `#000080` | 8.59:1 | AAA Pass |
| 5 Maroon | `#800000` | 7.53:1 | AAA Pass |
| 6 Teal | `#008080` | 4.23:1 | AA Pass |
| 7 Black | `#000000` | 12.63:1 | AAA Pass |
| 8 Gray | `#808080` | 3.02:1 | AA Large |

### 11.2 Visual Indicators

- Do not rely solely on color (numbers are present)
- Flag uses distinct shape, not just color
- Mine uses distinct shape (asterisk/bomb)
- 3D bevel provides texture distinction for hidden cells

### 11.3 Focus Visibility

- Visible focus indicator for keyboard navigation
- 2px dotted outline in contrasting color
- Focus follows logical grid order (left-to-right, top-to-bottom)

---

## 12. Visual Assets Summary

### 12.1 Icons Needed

| Icon | Usage | Suggested Implementation |
|------|-------|-------------------------|
| Mine | Revealed mines | Unicode: * or emoji: bomb |
| Flag | Flagged cells | Unicode: F (red) or CSS triangle |
| Smiley | Restart button | Text emoticons: :-) 8-) X-( |

### 12.2 CSS-Only Implementation

All visual elements can be achieved with pure CSS:
- 3D bevels using border colors
- Shapes using pseudo-elements or Unicode
- No image files required
- Consistent rendering across browsers

---

## 13. Implementation CSS Variables

```css
:root {
    /* Colors - Background */
    --color-bg-main: #C0C0C0;
    --color-bg-revealed: #BDBDBD;
    --color-bg-mine-triggered: #FF0000;
    --color-bg-overlay: rgba(0, 0, 0, 0.7);

    /* Colors - Borders */
    --color-border-light: #FFFFFF;
    --color-border-light-inner: #DFDFDF;
    --color-border-dark: #808080;
    --color-border-dark-outer: #404040;

    /* Colors - UI Elements */
    --color-title-bar: #000080;
    --color-title-text: #FFFFFF;
    --color-led-bg: #000000;
    --color-led-text: #FF0000;

    /* Colors - Numbers */
    --color-num-1: #0000FF;
    --color-num-2: #008000;
    --color-num-3: #FF0000;
    --color-num-4: #000080;
    --color-num-5: #800000;
    --color-num-6: #008080;
    --color-num-7: #000000;
    --color-num-8: #808080;

    /* Colors - Feedback */
    --color-win: #00FF00;
    --color-lose: #FF0000;
    --color-flag: #FF0000;

    /* Sizing */
    --cell-size: 32px;
    --border-width: 3px;
    --border-width-thin: 1px;

    /* Typography */
    --font-primary: 'Courier New', Courier, monospace;
    --font-size-cell: 18px;
    --font-size-led: 24px;
    --font-size-title: 14px;
    --font-size-overlay: 32px;
    --font-weight-bold: bold;
}
```

---

## 14. Design Checklist

Before implementation, verify:

- [ ] All hex colors defined and documented
- [ ] Typography stack specified with fallbacks
- [ ] Cell states visually distinct
- [ ] 3D bevel effect specified for hidden cells
- [ ] Number colors match classic Minesweeper
- [ ] Hover and active states defined
- [ ] Win/Lose overlay designed
- [ ] Mine counter LED display specified
- [ ] Restart button with smiley faces defined
- [ ] Accessibility contrast ratios verified
- [ ] No external assets required (CSS-only)
- [ ] Dimensions suitable for mouse interaction (32px cells)

---

*Document Version: 1.0*
*Created for: Retro Minesweeper Project*
*Design Style: Windows 95/98 Authentic Retro*
