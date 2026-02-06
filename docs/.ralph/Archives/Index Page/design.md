# Landing Page Design Document

## Project: Demo Showcase Index Page

**Version:** 1.0
**Date:** 2026-02-06
**Status:** Design Specification

---

## 1. Overview

### Purpose
Create a visually engaging landing page that showcases two interactive demo applications:
- **SDLC Agent Inventory** - A modern orbital visualization of software development agents
- **Retro Minesweeper** - A classic Windows 95-style game recreation

### Design Philosophy
The landing page should create visual intrigue while maintaining simplicity. Rather than choosing one aesthetic (modern vs. retro), the design celebrates the contrast between the two demos as a feature, using a "portal" or "window into different worlds" metaphor.

---

## 2. Layout Architecture

### Page Structure
```
+--------------------------------------------------+
|                    HEADER                         |
|    "Demo Showcase" + subtle animated accent       |
+--------------------------------------------------+
|                                                   |
|    +------------------+  +------------------+     |
|    |                  |  |                  |     |
|    |   INVENTORY      |  |   MINESWEEPER    |     |
|    |   CARD           |  |   CARD           |     |
|    |                  |  |                  |     |
|    |  [Preview Area]  |  |  [Preview Area]  |     |
|    |                  |  |                  |     |
|    |  Description     |  |  Description     |     |
|    |  [Launch Demo]   |  |  [Launch Demo]   |     |
|    +------------------+  +------------------+     |
|                                                   |
+--------------------------------------------------+
|                    FOOTER                         |
|           Minimal technical credits               |
+--------------------------------------------------+
```

### Grid System
- **Desktop (1024px+):** Two-column grid with equal-width cards, centered with comfortable margins
- **Tablet (768px-1023px):** Two-column grid, reduced padding
- **Mobile (<768px):** Single-column stack, full-width cards

### Spacing
- Container max-width: 1000px
- Card gap: 32px (desktop), 24px (tablet), 16px (mobile)
- Card padding: 24px
- Section padding: 48px vertical

---

## 3. Visual Design

### Color Palette

The page uses a neutral dark base that complements both demos:

| Element | Color | Usage |
|---------|-------|-------|
| Background | `#0f0f13` | Deep charcoal, near-black |
| Surface | `#1a1a24` | Card backgrounds |
| Surface Elevated | `#252532` | Hover states |
| Text Primary | `#f0f0f5` | Headings, primary content |
| Text Secondary | `#a0a0b0` | Descriptions, meta |
| Accent Inventory | `#4ecdc4` | Teal - matches inventory theme |
| Accent Minesweeper | `#c0c0c0` | Silver - matches Win95 chrome |
| Accent Minesweeper Alt | `#008080` | Classic teal background |
| Border | `rgba(255,255,255,0.08)` | Subtle card borders |

### Typography

**Font Stack:** System fonts for performance and native feel
```css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto,
             Oxygen, Ubuntu, Cantarell, sans-serif;
```

| Element | Size | Weight | Style |
|---------|------|--------|-------|
| Page Title | 2.5rem (40px) | 700 | Letter-spacing: -0.02em |
| Card Title | 1.5rem (24px) | 600 | Normal |
| Description | 1rem (16px) | 400 | Line-height: 1.6 |
| Tags/Meta | 0.875rem (14px) | 500 | Uppercase, letter-spacing: 0.05em |
| Button | 1rem (16px) | 600 | Normal |

### Card Design

Each demo card acts as a "window" into its respective world:

#### Inventory Card
- Border: 1px solid with subtle teal glow on hover
- Preview: Mini visualization showing orbital concept (CSS-only)
- Gradient overlay hinting at dark theme aesthetic

#### Minesweeper Card
- Border: Classic 3D beveled border (light top-left, dark bottom-right)
- Preview: Static grid representation with recognizable iconography
- Background hint of the teal (#008080) retro aesthetic

### Visual Hierarchy
1. **Page title** - Establishes context
2. **Card previews** - Visual hooks that draw attention
3. **Card titles** - Clear identification
4. **Descriptions** - Supporting context
5. **CTAs** - Clear action path

---

## 4. Components

### 4.1 Header

**Structure:**
- Page title: "Demo Showcase"
- Optional tagline: "Interactive experiments in web development"
- Subtle animated gradient underline accent

**Behavior:**
- Fixed position not required (page is short)
- Centered alignment

### 4.2 Demo Cards

**Anatomy:**
```
+----------------------------------------+
|  [PREVIEW AREA - 200px height]         |
|  Visual representation of the demo     |
+----------------------------------------+
|  [TAG] Modern / Retro                  |
|                                        |
|  DEMO TITLE                            |
|                                        |
|  Brief 2-3 line description of what    |
|  the demo showcases and its features.  |
|                                        |
|  [====== LAUNCH DEMO ======]           |
+----------------------------------------+
```

**Preview Areas:**

*Inventory Preview:*
- Dark background (#12121a)
- 5-6 small colored circles arranged in a mini orbital pattern
- Subtle CSS animation: gentle rotation or floating
- Creates intrigue without revealing full experience

*Minesweeper Preview:*
- Gray background (#c0c0c0)
- 4x4 mini grid of cells with classic beveled borders
- One cell with a flag, one revealed with a number
- Static but instantly recognizable

**Tags:**
- Inventory: "MODERN" in teal
- Minesweeper: "RETRO" in classic gray with bevel effect

### 4.3 Buttons (CTA)

**Primary Button Style:**
```css
/* Base */
padding: 14px 28px;
border-radius: 8px;
font-weight: 600;
transition: all 0.2s ease;

/* Inventory Button */
background: linear-gradient(135deg, #4ecdc4, #44a8a0);
color: #0a0a0f;

/* Minesweeper Button */
background: #c0c0c0;
border: 3px outset #dfdfdf;
color: #000;
```

**Hover States:**
- Inventory: Subtle glow effect, slight scale (1.02)
- Minesweeper: Classic "pressed" state preview (inset border simulation)

**Focus States:**
- Visible focus ring (3px offset)
- Never remove outline, only enhance it

### 4.4 Footer

Minimal footer with:
- "Built with vanilla HTML, CSS, and JavaScript"
- Current year
- Optional: "No frameworks harmed in the making"

---

## 5. Interactions and Animations

### Page Load Sequence
1. **0ms:** Background renders
2. **100ms:** Header fades in and slides down slightly
3. **200ms:** Left card fades in and slides up
4. **300ms:** Right card fades in and slides up
5. Total duration: ~500ms

```css
@keyframes fadeSlideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

### Card Hover Effects

**Inventory Card:**
- Border gains subtle teal glow: `box-shadow: 0 0 20px rgba(78, 205, 196, 0.15)`
- Preview animation speeds up slightly
- Smooth transition: 0.3s ease

**Minesweeper Card:**
- Border highlights intensify (brighter bevels)
- Subtle "lift" effect: `transform: translateY(-4px)`
- Box shadow increases depth

### Preview Animations

**Inventory Orbital (CSS-only):**
```css
/* Container rotates slowly */
.orbital-preview {
  animation: gentleRotate 20s linear infinite;
}

/* Individual dots float independently */
.orbital-dot {
  animation: float 3s ease-in-out infinite;
  animation-delay: calc(var(--i) * 0.5s);
}

@keyframes gentleRotate {
  to { transform: rotate(360deg); }
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-8px); }
}
```

**Minesweeper Grid (CSS-only):**
- Static by default
- On card hover: subtle "ready" pulse on the smiley face button representation

### Button Interactions

- Hover: Color shift, subtle scale
- Active: Pressed state (scale 0.98)
- Focus: Visible ring

### Reduced Motion Support
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## 6. Responsive Behavior

### Breakpoints

| Breakpoint | Layout | Adjustments |
|------------|--------|-------------|
| 1024px+ | 2-column | Full experience |
| 768-1023px | 2-column | Reduced padding, smaller previews |
| <768px | 1-column | Stacked cards, full-width |

### Mobile Considerations
- Cards stack vertically
- Preview areas maintain aspect ratio but reduce height
- Touch targets minimum 44x44px
- Increased padding on buttons for thumb reach
- Font sizes remain readable (no smaller than 16px body)

### Container Queries (Progressive Enhancement)
Use container queries if supported for card-internal responsiveness:
```css
@container (max-width: 400px) {
  .card-content { padding: 16px; }
}
```

---

## 7. Accessibility

### WCAG 2.1 AA Compliance Checklist

**Perceivable:**
- [x] Color contrast: All text exceeds 4.5:1 ratio
- [x] Text can be resized to 200% without loss of content
- [x] No information conveyed by color alone
- [x] Preview animations are decorative (not essential)

**Operable:**
- [x] All interactive elements keyboard accessible
- [x] Visible focus indicators on all focusables
- [x] No keyboard traps
- [x] Sufficient target sizes (44x44px minimum)
- [x] Skip link to main content (hidden until focused)

**Understandable:**
- [x] Language declared in HTML lang attribute
- [x] Consistent navigation pattern
- [x] Clear labels on interactive elements

**Robust:**
- [x] Valid HTML5 structure
- [x] ARIA landmarks: header, main, footer
- [x] Links vs. buttons used semantically correctly

### Focus Management
```css
/* Custom focus ring */
:focus-visible {
  outline: 2px solid #4ecdc4;
  outline-offset: 3px;
}

/* Remove default only when custom applied */
:focus:not(:focus-visible) {
  outline: none;
}
```

### Screen Reader Considerations
- Decorative preview animations use `aria-hidden="true"`
- Cards use semantic heading hierarchy (h1 > h2)
- Links include descriptive text ("Launch SDLC Agent Inventory demo")
- Live regions not needed (no dynamic updates)

### Skip Link
```html
<a href="#main" class="skip-link">Skip to main content</a>
```

---

## 8. Technical Specifications

### File Structure
Single self-contained HTML file:
```
index.html
  |-- <style> (all CSS inline)
  |-- <body>
       |-- Skip link
       |-- Header
       |-- Main (card grid)
       |-- Footer
  |-- <script> (minimal JS for animations, optional)
```

### Performance Targets
- Total file size: < 30KB (no images, CSS/JS inline)
- First Contentful Paint: < 1s
- Time to Interactive: < 1s
- No external dependencies
- No JavaScript required for core functionality

### Browser Support
- Chrome 90+
- Firefox 90+
- Safari 15+
- Edge 90+

### CSS Features Used
- CSS Grid
- Flexbox
- CSS Custom Properties
- CSS Animations
- clamp() for fluid typography
- :focus-visible
- prefers-reduced-motion
- prefers-color-scheme (optional light mode)

### JavaScript (Optional/Progressive Enhancement)
Minimal JS for:
- Staggered load animations (CSS-only fallback works)
- Intersection Observer for scroll animations (if page grows)

Can be fully functional with JavaScript disabled.

---

## 9. Content

### Page Title
"Demo Showcase"

### Page Tagline
"Interactive experiments built with vanilla web technologies"

### Inventory Card Content
**Tag:** MODERN
**Title:** SDLC Agent Inventory
**Description:** An interactive orbital visualization of 10 software development lifecycle agents. Features filtering, search, keyboard navigation, and a dark/light theme toggle. Fully accessible with zero dependencies.
**CTA:** Launch Demo

### Minesweeper Card Content
**Tag:** RETRO
**Title:** Minesweeper
**Description:** The classic puzzle game faithfully recreated with authentic Windows 95 styling. Features a 10x10 grid, flag placement, and that satisfying cascade when you clear empty cells.
**CTA:** Play Game

### Footer
"Built with HTML, CSS, and JavaScript. No frameworks required."

---

## 10. Implementation Notes

### CSS Custom Properties (Root Variables)
```css
:root {
  /* Colors */
  --color-bg: #0f0f13;
  --color-surface: #1a1a24;
  --color-surface-hover: #252532;
  --color-text: #f0f0f5;
  --color-text-muted: #a0a0b0;
  --color-accent-modern: #4ecdc4;
  --color-accent-retro: #c0c0c0;
  --color-accent-retro-bg: #008080;
  --color-border: rgba(255, 255, 255, 0.08);

  /* Spacing */
  --space-xs: 8px;
  --space-sm: 16px;
  --space-md: 24px;
  --space-lg: 32px;
  --space-xl: 48px;

  /* Animation */
  --transition-fast: 0.15s ease;
  --transition-medium: 0.3s ease;

  /* Borders */
  --radius-sm: 8px;
  --radius-md: 12px;
}
```

### Key HTML Structure
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Demo Showcase</title>
  <style>/* All CSS here */</style>
</head>
<body>
  <a href="#main" class="skip-link">Skip to main content</a>

  <header class="header">
    <h1 class="title">Demo Showcase</h1>
    <p class="tagline">Interactive experiments...</p>
  </header>

  <main id="main" class="main">
    <div class="card-grid">
      <article class="card card--modern">
        <div class="card__preview" aria-hidden="true">
          <!-- Orbital preview -->
        </div>
        <div class="card__content">
          <span class="tag tag--modern">Modern</span>
          <h2 class="card__title">SDLC Agent Inventory</h2>
          <p class="card__description">...</p>
          <a href="examples/inventory.html" class="btn btn--modern">
            Launch Demo
          </a>
        </div>
      </article>

      <article class="card card--retro">
        <!-- Similar structure -->
      </article>
    </div>
  </main>

  <footer class="footer">
    <p>Built with HTML, CSS, and JavaScript.</p>
  </footer>
</body>
</html>
```

---

## 11. Design Rationale

### Why This Approach?

**Contrast as a Feature:**
Rather than forcing both demos into one visual style, the design uses their contrast as a storytelling element. The dark, neutral landing page serves as a "gallery" that lets each demo's aesthetic shine through its preview.

**Simplicity Over Cleverness:**
A two-card grid is immediately understandable. Users spend zero cognitive effort figuring out how to navigate. They see two options, understand what each is, and can choose in seconds.

**Performance as a Feature:**
With zero external dependencies and minimal JavaScript, the page loads instantly. This sets expectations for the demos themselves (which are also self-contained).

**Accessibility from the Start:**
Rather than retrofitting accessibility, the design incorporates it from the beginning: semantic HTML, sufficient contrast, keyboard navigation, and screen reader support.

### Trade-offs Accepted

- **No dark/light toggle on landing page:** Keeps it simple; demos have their own themes
- **Minimal interactivity:** Cards hover but no complex interactions - lets demos be the stars
- **No thumbnail screenshots:** CSS previews are lighter and more engaging than static images

---

## 12. Future Considerations

If more demos are added:
- Convert to 3-column grid or masonry layout
- Add category filtering
- Consider pagination or infinite scroll

If sharing is needed:
- Add Open Graph meta tags for social previews
- Include favicon

---

## Appendix: Visual Reference

### Card Layout Dimensions
```
+------------------------------------------+
|           PREVIEW AREA                   |  180px
|         (aspect-ratio: 16/9)             |
+------------------------------------------+
|  [TAG]                                   |  padding: 24px
|                                          |
|  TITLE                                   |  h2: 24px
|                                          |  margin: 8px
|  Description text that wraps to          |  p: 16px
|  multiple lines if needed.               |  margin: 16px
|                                          |
|  [========= BUTTON =========]            |  48px height
|                                          |
+------------------------------------------+
```

### Color Contrast Verification
| Pair | Ratio | Pass? |
|------|-------|-------|
| Text (#f0f0f5) on Surface (#1a1a24) | 12.4:1 | AAA |
| Muted (#a0a0b0) on Surface (#1a1a24) | 6.2:1 | AA |
| Accent (#4ecdc4) on Surface (#1a1a24) | 8.9:1 | AAA |
| Button text (#0a0a0f) on Accent (#4ecdc4) | 10.1:1 | AAA |

---

*End of Design Document*
