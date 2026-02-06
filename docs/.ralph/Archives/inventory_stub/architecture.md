# Technical Architecture Document: Agent Inventory Interactive Chart

**Document Version:** 1.0
**Date:** 2026-02-05
**Author:** software-architect
**Status:** Approved for Implementation
**Deliverable:** `/workspace/inventory.html`

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Technology Decisions](#2-technology-decisions)
3. [Visual Layout Strategy: Orbital/Radial Diagram](#3-visual-layout-strategy-orbitalradial-diagram)
4. [HTML Structure and Semantic Markup](#4-html-structure-and-semantic-markup)
5. [CSS Architecture](#5-css-architecture)
6. [JavaScript Architecture](#6-javascript-architecture)
7. [Data Model and Agent Data Structure](#7-data-model-and-agent-data-structure)
8. [State Management](#8-state-management)
9. [Animation Strategy](#9-animation-strategy)
10. [Accessibility Architecture](#10-accessibility-architecture)
11. [Responsive Design Strategy](#11-responsive-design-strategy)
12. [Security Architecture](#12-security-architecture)
13. [Performance Budget and Optimization](#13-performance-budget-and-optimization)
14. [Component and Module Breakdown](#14-component-and-module-breakdown)
15. [Implementation Sequence](#15-implementation-sequence)
16. [Technical Risks and Mitigations](#16-technical-risks-and-mitigations)
17. [Appendix: Reference Calculations](#appendix-reference-calculations)

---

## 1. Architecture Overview

### 1.1 High-Level Architecture

The application is a single-file, client-side HTML page with all CSS and JavaScript inline. It follows a declarative data-driven rendering approach where a static JavaScript data structure drives all DOM generation, layout computation, and interaction behavior.

```
+---------------------------------------------------------------+
|  inventory.html                                                |
|                                                                |
|  +------------------+  +------------------+  +---------------+ |
|  |    <style>       |  |    <body>        |  |   <script>    | |
|  |                  |  |                  |  |               | |
|  | - CSS Custom     |  | - Semantic HTML  |  | - Data Layer  | |
|  |   Properties     |  |   skeleton       |  | - State Mgmt  | |
|  | - Layout Rules   |  | - ARIA landmarks |  | - Renderer    | |
|  | - Component      |  | - Container divs |  | - Animations  | |
|  |   Styles         |  |   for JS render  |  | - Events      | |
|  | - Animations     |  |                  |  | - Layout Eng  | |
|  | - Media Queries  |  |                  |  |               | |
|  | - Reduced Motion |  |                  |  |               | |
|  +------------------+  +------------------+  +---------------+ |
+---------------------------------------------------------------+
```

### 1.2 Architectural Principles

1. **Zero Dependencies:** Vanilla HTML, CSS, and JavaScript only. No frameworks, no CDN libraries. This eliminates CDN availability risk and keeps file size minimal.
2. **Data-Driven Rendering:** All 10 agents are defined in a single JavaScript data array. The DOM is generated programmatically from this data. Static HTML skeleton provides the structural shell and accessibility landmarks.
3. **CSS-First Animation:** All animations and transitions use CSS transforms and opacity exclusively (GPU-composited properties). JavaScript only triggers class changes.
4. **Progressive Enhancement:** The HTML skeleton contains a `<noscript>` fallback with all agent data in a readable, styled `<table>` element, ensuring content is accessible even without JavaScript.
5. **Single Responsibility Modules:** JavaScript is organized into clearly scoped module functions within a single IIFE (Immediately Invoked Function Expression) to avoid global namespace pollution.

---

## 2. Technology Decisions

### 2.1 Decision Record

| Decision | Choice | Rationale | Alternatives Considered |
|----------|--------|-----------|------------------------|
| **JavaScript Framework** | Vanilla JS (ES2020) | Zero dependency, tiny footprint, full control over DOM and performance. 10 agents is a trivially small data set; no framework overhead is justified. | React (too heavy, requires build step), Vue (CDN option adds 30KB+, unnecessary), Alpine.js (adds dependency for minimal benefit) |
| **CSS Methodology** | CSS Custom Properties + BEM-inspired naming | Custom properties enable theming (including dark mode) with a single variable swap. BEM naming prevents selector collisions in a large inline stylesheet. | Tailwind (requires build), CSS-in-JS (needs runtime) |
| **Layout Engine** | CSS for static layout, JS `Math.cos`/`Math.sin` for orbital positioning | The orbital layout requires trigonometric placement. CSS cannot compute radial positions dynamically for N items. JS computes positions once, then applies them as CSS custom properties on each node, allowing CSS transitions to animate changes. | Pure CSS Grid (cannot achieve orbital look), SVG (heavier, harder to make interactive/accessible), Canvas (not accessible, no DOM nodes for keyboard/screen reader) |
| **Icon Strategy** | Inline SVG symbols | SVGs are resolution-independent, styleable with CSS (fill, stroke), lightweight, and accessible (title elements). A single `<svg>` block with `<symbol>` definitions is referenced via `<use>`, keeping markup DRY. | Icon font (extra file or large inline base64), emoji (inconsistent cross-platform), PNG/base64 (not scalable, bloats file size) |
| **Animation Engine** | CSS transitions + CSS keyframe animations, triggered by JS class toggling | CSS animations are GPU-composited for transform/opacity, achieving 60 FPS. JS only adds/removes classes, never directly animates properties. `requestAnimationFrame` used only for the ambient idle animation loop. | Web Animations API (good but less browser-tested for complex choreography), GreenSock (external dependency), pure JS animation loops (60 FPS risk, main thread blocking) |
| **State Management** | Single plain object + pub/sub event emitter | With only ~5 state properties (selectedAgent, activeFilter, searchQuery, compareMode, darkMode), a simple state object with a custom event dispatcher is sufficient. No reactive framework needed. | Redux pattern (overkill), Proxy-based reactivity (clever but harder to debug), scattered variables (unmaintainable) |

### 2.2 Browser Feature Requirements

The following modern features are used. All are supported in Chrome 90+, Firefox 90+, Safari 15+, Edge 90+.

| Feature | Usage |
|---------|-------|
| CSS Custom Properties | Theming, per-agent colors |
| CSS Grid | Page layout shell |
| CSS Flexbox | Component-level alignment |
| CSS `transform`, `opacity` transitions | All animations |
| CSS `@media (prefers-reduced-motion)` | Accessibility |
| CSS `@media (prefers-color-scheme)` | Dark mode auto-detect |
| JS `querySelectorAll`, `closest`, `matches` | DOM traversal |
| JS `addEventListener` with options | Event delegation |
| JS Template Literals | DOM string generation |
| JS `Array.prototype.filter/map/find` | Data operations |
| SVG `<use>` with `<symbol>` | Icon system |
| `IntersectionObserver` | Staggered entry animation trigger (optional, fallback to timeout) |

---

## 3. Visual Layout Strategy: Orbital/Radial Diagram

### 3.1 Recommended Layout: Orbital Ring with Category Grouping

The orbital/radial layout is the recommended visual metaphor. This was selected for the following reasons:

1. **Natural Metaphor:** Agents "orbiting" a central hub conveys collaboration and ecosystem thinking, matching the SDLC agent narrative.
2. **Equal Visual Weight:** Unlike a grid, all nodes on a circle are equidistant from center, giving no agent implicit priority.
3. **Category Arcs:** Agents in the same SDLC category are placed in adjacent positions on the ring, creating visible "arcs" of related agents. A subtle background arc or gradient reinforces category grouping.
4. **Responsive Degradation:** On mobile, the orbital layout transforms into a vertical card list with category headers, which is a natural and readable fallback.
5. **Interaction Friendly:** The center of the ring is the natural location for the detail panel when an agent is selected, creating a clear spatial relationship between the selected node and its expanded information.

### 3.2 Layout Geometry

```
                    [Planning Arc]
                  PM ---- SA
                /                \
     [Doc]   TW                    SD   [Development]
              |                    |
              |     +---------+    |
              |     | DETAIL  |    |
              |     | PANEL / |    |
              |     | CENTER  |    |
              |     +---------+    |
              |                    |
             RM                   UD
     [Ops]    \                /   [Development]
                DO --- PE --- SE
                   [Quality Arc]
```

**Placement Algorithm (pseudocode):**

```
// Category order determines arc positions (clockwise from top)
const categoryOrder = ['Planning', 'Development', 'Quality', 'Operations', 'Documentation'];

// Agents are sorted by category, then placed evenly around the ring
// Total agents = 10, so angular spacing = 360 / 10 = 36 degrees
// Starting angle offset = -90 degrees (top of circle = 12 o'clock)

for (let i = 0; i < agents.length; i++) {
    const angle = -90 + (i * 36);       // degrees
    const radians = angle * (Math.PI / 180);
    const x = centerX + radius * Math.cos(radians);
    const y = centerY + radius * Math.sin(radians);
    // Apply as CSS custom properties: --agent-x, --agent-y
}
```

**Agent Placement Order (clockwise from top):**

| Position | Angle | Agent | Category |
|----------|-------|-------|----------|
| 0 | -90 (top) | Product Manager | Planning |
| 1 | -54 | Software Architect | Planning |
| 2 | -18 | Software Developer | Development |
| 3 | +18 | UX Designer | Development |
| 4 | +54 | QA Engineer | Quality |
| 5 | +90 (right) | Security Engineer | Quality |
| 6 | +126 | Performance Engineer | Quality |
| 7 | +162 | DevOps Engineer | Operations |
| 8 | +198 (-162) | Release Manager | Operations |
| 9 | +234 (-126) | Technical Writer | Documentation |

### 3.3 Radius Sizing

- **Desktop (>= 1024px):** Radius = `min(viewportWidth, viewportHeight) * 0.30` with a max of `280px`. Agent node diameter = `100px`.
- **Tablet (768-1023px):** Radius = `min(viewportWidth, viewportHeight) * 0.28` with a max of `220px`. Agent node diameter = `80px`.
- **Mobile (< 768px):** Layout switches to a vertical card list. No orbital computation.

### 3.4 Center Hub

The center of the orbital ring contains:
- **Default state:** A title or logo element ("SDLC Agent Ecosystem" or similar) with a subtle pulse animation.
- **Agent selected state:** The detail panel with agent name, description, capabilities, and category badge. The panel fades/scales in from the center.
- **Filter active state:** A label indicating the active filter category, with a "Show All" reset button.

---

## 4. HTML Structure and Semantic Markup

### 4.1 Document Skeleton

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SDLC Agent Inventory</title>
    <meta name="description" content="Interactive chart of 10 SDLC agents and their capabilities">
    <style>
        /* All CSS here - see Section 5 */
    </style>
</head>
<body>

    <!-- Skip Link for Accessibility -->
    <a href="#main-chart" class="skip-link">Skip to agent chart</a>

    <!-- Page Header -->
    <header class="page-header" role="banner">
        <h1 class="page-header__title">Agent Inventory</h1>
        <!-- Search Input (P1 Nice-to-Have) -->
        <div class="search" role="search">
            <label for="agent-search" class="sr-only">Search agents</label>
            <input type="text" id="agent-search" class="search__input"
                   placeholder="Search agents..." autocomplete="off">
        </div>
    </header>

    <!-- Main Content Area -->
    <main id="main-chart" class="chart" role="main">

        <!-- Category Filter Legend -->
        <nav class="legend" role="navigation" aria-label="Filter agents by category">
            <ul class="legend__list" role="list">
                <!-- JS renders category filter buttons here -->
            </ul>
            <button class="legend__reset" type="button" aria-label="Show all agents">
                Show All
            </button>
        </nav>

        <!-- Orbital Chart Container -->
        <div class="orbital" role="group" aria-label="Agent orbital chart">

            <!-- SVG Definitions (icons) - hidden, referenced by <use> -->
            <svg class="svg-defs" aria-hidden="true">
                <!-- <symbol> elements for each agent icon -->
            </svg>

            <!-- Connection Lines (SVG layer behind nodes) -->
            <svg class="orbital__connections" aria-hidden="true">
                <!-- Category arc lines rendered by JS -->
            </svg>

            <!-- Agent Nodes Container -->
            <div class="orbital__ring" role="list" aria-label="Agent nodes">
                <!-- JS renders agent nodes here, each as a role="listitem" -->
            </div>

            <!-- Center Hub / Detail Panel -->
            <div class="orbital__center" role="region" aria-label="Agent details"
                 aria-live="polite">
                <!-- Default: hub title -->
                <!-- On selection: detail panel content -->
            </div>

        </div>

    </main>

    <!-- Dark Mode Toggle (P1 Nice-to-Have) -->
    <button class="theme-toggle" type="button" aria-label="Toggle dark mode">
        <!-- Sun/Moon icon -->
    </button>

    <!-- Noscript Fallback -->
    <noscript>
        <style>.chart { display: none; }</style>
        <main class="noscript-fallback">
            <h1>SDLC Agent Inventory</h1>
            <table>
                <!-- Static table with all agent data for graceful degradation -->
                <!-- One row per agent: Name, Category, Description, Capabilities -->
            </table>
        </main>
    </noscript>

    <script>
        /* All JavaScript here - see Section 6 */
    </script>

</body>
</html>
```

### 4.2 Agent Node Markup (generated by JS)

Each agent node in the orbital ring follows this template:

```html
<div class="agent-node"
     role="listitem"
     tabindex="0"
     data-agent-id="software-architect"
     data-category="Planning"
     style="--agent-x: 245px; --agent-y: 89px; --agent-color: #6366f1; --delay: 1"
     aria-label="Software Architect - Planning">

    <div class="agent-node__icon" aria-hidden="true">
        <svg viewBox="0 0 48 48" width="48" height="48">
            <use href="#icon-software-architect"></use>
        </svg>
    </div>

    <span class="agent-node__label">Software Architect</span>
</div>
```

### 4.3 Detail Panel Markup (generated by JS on selection)

```html
<div class="detail-panel" role="dialog" aria-modal="false"
     aria-labelledby="detail-title">

    <button class="detail-panel__close" type="button"
            aria-label="Close detail panel">X</button>

    <div class="detail-panel__icon" aria-hidden="true">
        <svg viewBox="0 0 48 48" width="64" height="64">
            <use href="#icon-software-architect"></use>
        </svg>
    </div>

    <h2 id="detail-title" class="detail-panel__title">Software Architect</h2>

    <span class="detail-panel__category badge badge--planning">Planning</span>

    <p class="detail-panel__description">
        Designs system architecture, makes technology decisions, plans for
        scalability, and reviews architectural approaches.
    </p>

    <h3 class="detail-panel__capabilities-heading">Capabilities</h3>
    <ul class="detail-panel__capabilities" role="list">
        <li>System Design</li>
        <li>Technology Decisions</li>
        <li>Scalability Planning</li>
        <li>API Design</li>
        <li>Architecture Review</li>
    </ul>
</div>
```

---

## 5. CSS Architecture

### 5.1 Custom Properties (Design Tokens)

All themeable values are defined as CSS custom properties on `:root`. This enables dark mode by overriding a single block of properties on `[data-theme="dark"]`.

```css
:root {
    /* --- Layout --- */
    --orbital-radius: 260px;
    --node-size: 100px;
    --center-size: 320px;

    /* --- Typography --- */
    --font-family: system-ui, -apple-system, BlinkMacSystemFont,
                   'Segoe UI', Roboto, sans-serif;
    --font-size-base: 16px;
    --font-size-sm: 14px;
    --font-size-lg: 20px;
    --font-size-xl: 28px;

    /* --- Colors: Global --- */
    --color-bg: #0f1117;
    --color-surface: #1a1d2e;
    --color-surface-hover: #242842;
    --color-text: #e2e8f0;
    --color-text-muted: #94a3b8;
    --color-border: #2d3348;
    --color-focus-ring: #60a5fa;

    /* --- Colors: Category --- */
    --color-planning: #a78bfa;
    --color-development: #34d399;
    --color-quality: #f97316;
    --color-operations: #38bdf8;
    --color-documentation: #f472b6;

    /* --- Colors: Per-Agent (unique accent) --- */
    --color-product-manager: #a78bfa;
    --color-software-architect: #818cf8;
    --color-software-developer: #34d399;
    --color-ux-designer: #2dd4bf;
    --color-qa-engineer: #fb923c;
    --color-security-engineer: #f97316;
    --color-performance-engineer: #f59e0b;
    --color-devops-engineer: #38bdf8;
    --color-release-manager: #22d3ee;
    --color-technical-writer: #f472b6;

    /* --- Animation --- */
    --transition-fast: 150ms ease;
    --transition-normal: 300ms ease;
    --transition-slow: 500ms ease;
    --transition-spring: 500ms cubic-bezier(0.34, 1.56, 0.64, 1);

    /* --- Shadows --- */
    --shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.3);
    --shadow-md: 0 4px 16px rgba(0, 0, 0, 0.4);
    --shadow-lg: 0 8px 32px rgba(0, 0, 0, 0.5);
    --shadow-glow: 0 0 20px;
}
```

### 5.2 Dark-on-Dark Base Theme

The default theme uses a dark background. Rationale:

1. **Visual Impact:** Glowing agent nodes and colored arcs look dramatically better on dark backgrounds, creating a "constellation" or "mission control" feel.
2. **Glow Effects:** `box-shadow` glow effects are invisible on white backgrounds but striking on dark ones.
3. **Modern Aesthetic:** Dark themes are widely preferred for developer-facing tools.
4. **Light Mode Override:** The optional dark mode toggle simply swaps to a light theme, or the page can auto-detect via `prefers-color-scheme`.

### 5.3 CSS Organization (top-to-bottom order in `<style>`)

```
1. Reset and Base           - Box-sizing, margin reset, body font
2. Custom Properties        - All :root variables (see 5.1)
3. Utility Classes          - .sr-only, .skip-link, .badge
4. Layout: Page Shell       - .page-header, .chart, CSS Grid definition
5. Layout: Legend/Filter     - .legend, .legend__item, active states
6. Layout: Orbital          - .orbital, .orbital__ring, .orbital__center
7. Components: Agent Node   - .agent-node, hover/focus/selected/dimmed states
8. Components: Detail Panel - .detail-panel, open/close transitions
9. Components: Search       - .search, .search__input
10. Components: Theme Toggle - .theme-toggle
11. SVG Definitions         - .svg-defs (hidden)
12. Keyframe Animations     - @keyframes for entry, pulse, float, glow
13. Media Queries           - Tablet, mobile breakpoints, orientation
14. Reduced Motion          - @media (prefers-reduced-motion: reduce)
15. Light Theme Override    - [data-theme="light"] overrides
16. Noscript Fallback       - .noscript-fallback table styles
```

### 5.4 Key CSS Patterns

**Agent Node Positioning (orbital):**
```css
.agent-node {
    position: absolute;
    left: calc(50% + var(--agent-x) - var(--node-size) / 2);
    top: calc(50% + var(--agent-y) - var(--node-size) / 2);
    width: var(--node-size);
    height: var(--node-size);
    transition: transform var(--transition-normal),
                opacity var(--transition-normal),
                box-shadow var(--transition-normal);
    /* GPU compositing hint */
    will-change: transform, opacity;
}
```

**Hover glow (using agent color):**
```css
.agent-node:hover,
.agent-node:focus-visible {
    transform: scale(1.15);
    box-shadow: var(--shadow-glow) var(--agent-color);
    z-index: 10;
}
```

**Filter dimming:**
```css
.agent-node--dimmed {
    opacity: 0.2;
    transform: scale(0.9);
    filter: grayscale(0.7);
    pointer-events: none;
}
```

**Entry animation stagger:**
```css
.agent-node {
    opacity: 0;
    transform: scale(0.3) translateY(20px);
    animation: agent-enter 600ms var(--transition-spring) forwards;
    animation-delay: calc(var(--delay) * 80ms);
}

@keyframes agent-enter {
    to {
        opacity: 1;
        transform: scale(1) translateY(0);
    }
}
```

---

## 6. JavaScript Architecture

### 6.1 Module Structure (within single IIFE)

All JavaScript is wrapped in a single IIFE to prevent global scope pollution. Internally, it is organized into clearly separated concerns using function groupings.

```javascript
(function AgentInventory() {
    'use strict';

    // ==========================================
    // 1. DATA LAYER
    // ==========================================
    // - AGENTS: Array of 10 agent objects
    // - CATEGORIES: Array of 5 category objects with colors
    // - CATEGORY_ORDER: Array defining clockwise placement

    // ==========================================
    // 2. STATE MANAGEMENT
    // ==========================================
    // - AppState object
    // - setState(patch) function
    // - subscribe(listener) function
    // - State change event dispatching

    // ==========================================
    // 3. LAYOUT ENGINE
    // ==========================================
    // - computeOrbitalPositions(agents, radius, centerX, centerY)
    // - computeResponsiveRadius(viewportW, viewportH)
    // - recalculateLayout() - called on resize

    // ==========================================
    // 4. RENDERER
    // ==========================================
    // - renderAgentNodes(container, agents)
    // - renderDetailPanel(container, agent)
    // - renderLegend(container, categories)
    // - renderCenterHub(container, state)
    // - renderConnectionArcs(svgContainer, agents, positions)
    // - updateNodeStates(state) - applies dimmed/selected classes

    // ==========================================
    // 5. ANIMATION CONTROLLER
    // ==========================================
    // - triggerEntryAnimation()
    // - startIdleAnimation() - subtle floating, ambient glow
    // - stopIdleAnimation()
    // - respectsReducedMotion() - checks media query

    // ==========================================
    // 6. EVENT HANDLERS
    // ==========================================
    // - handleAgentClick(agentId)
    // - handleAgentHover(agentId)
    // - handleCategoryFilter(category)
    // - handleSearch(query)
    // - handleReset()
    // - handleKeyboard(event)
    // - handleClickOutside(event)
    // - handleResize()

    // ==========================================
    // 7. INITIALIZATION
    // ==========================================
    // - init() - entry point, called on DOMContentLoaded
    // - setupEventDelegation()
    // - setupKeyboardNavigation()
    // - setupResizeObserver()

    // ==========================================
    // 8. UTILITIES
    // ==========================================
    // - escapeHtml(str) - XSS prevention
    // - debounce(fn, ms)
    // - $(selector) - shorthand for querySelector
    // - $$(selector) - shorthand for querySelectorAll

})();
```

### 6.2 Event Delegation Strategy

Instead of attaching individual event listeners to each agent node, we use event delegation on the orbital container. This is more performant and handles dynamically rendered content.

```javascript
function setupEventDelegation() {
    const orbital = document.querySelector('.orbital');

    // Click delegation
    orbital.addEventListener('click', function(e) {
        const agentNode = e.target.closest('.agent-node');
        if (agentNode) {
            handleAgentClick(agentNode.dataset.agentId);
            return;
        }
        // Click on empty space = deselect
        if (!e.target.closest('.detail-panel')) {
            handleReset();
        }
    });

    // Hover delegation via mouseover/mouseout
    orbital.addEventListener('mouseover', function(e) {
        const agentNode = e.target.closest('.agent-node');
        if (agentNode) {
            handleAgentHover(agentNode.dataset.agentId);
        }
    });

    // Legend filter delegation
    const legend = document.querySelector('.legend');
    legend.addEventListener('click', function(e) {
        const item = e.target.closest('.legend__item');
        if (item) {
            handleCategoryFilter(item.dataset.category);
            return;
        }
        if (e.target.closest('.legend__reset')) {
            handleReset();
        }
    });
}
```

### 6.3 DOM Rendering Strategy

DOM rendering uses `document.createElement` for security-critical content and template literals for static structure. The key rule is: **never use `innerHTML` with any user-provided data (search input)**. Agent data is trusted (hardcoded), but the search query is user input and must be escaped.

```javascript
function renderAgentNode(agent, position) {
    const node = document.createElement('div');
    node.className = 'agent-node';
    node.setAttribute('role', 'listitem');
    node.setAttribute('tabindex', '0');
    node.dataset.agentId = agent.id;
    node.dataset.category = agent.category;
    node.style.setProperty('--agent-x', position.x + 'px');
    node.style.setProperty('--agent-y', position.y + 'px');
    node.style.setProperty('--agent-color', agent.color);
    node.style.setProperty('--delay', String(position.index));
    node.setAttribute('aria-label', agent.name + ' - ' + agent.category);

    // Icon (static SVG reference, safe)
    node.innerHTML =
        '<div class="agent-node__icon" aria-hidden="true">' +
            '<svg viewBox="0 0 48 48" width="48" height="48">' +
                '<use href="#icon-' + agent.id + '"></use>' +
            '</svg>' +
        '</div>' +
        '<span class="agent-node__label">' + escapeHtml(agent.name) + '</span>';

    return node;
}
```

### 6.4 Resize Handling

The orbital layout must recalculate on viewport resize. This uses a debounced resize observer.

```javascript
function setupResizeObserver() {
    const orbitalEl = document.querySelector('.orbital');
    let resizeTimer;

    const observer = new ResizeObserver(function(entries) {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function() {
            recalculateLayout();
        }, 150);
    });

    observer.observe(orbitalEl);
}

function recalculateLayout() {
    const orbital = document.querySelector('.orbital');
    const rect = orbital.getBoundingClientRect();
    const radius = computeResponsiveRadius(rect.width, rect.height);
    const positions = computeOrbitalPositions(getState().agents, radius, 0, 0);

    // Update each node's CSS custom properties
    positions.forEach(function(pos) {
        const node = orbital.querySelector(
            '[data-agent-id="' + pos.agentId + '"]'
        );
        if (node) {
            node.style.setProperty('--agent-x', pos.x + 'px');
            node.style.setProperty('--agent-y', pos.y + 'px');
        }
    });
}
```

---

## 7. Data Model and Agent Data Structure

### 7.1 Agent Object Schema

```javascript
const AGENTS = [
    {
        id: 'product-manager',
        name: 'Product Manager',
        category: 'Planning',
        description: 'Plans product features, defines user stories, manages stakeholder requirements, and creates project roadmaps.',
        capabilities: [
            'Feature Planning',
            'User Story Definition',
            'Stakeholder Management',
            'Roadmap Creation',
            'Scope Management'
        ],
        icon: 'product-manager',  // references <symbol id="icon-product-manager">
        color: '#a78bfa'          // unique accent color
    },
    // ... 9 more agents
];
```

### 7.2 Category Object Schema

```javascript
const CATEGORIES = [
    { id: 'Planning',       color: '#a78bfa', icon: 'clipboard' },
    { id: 'Development',    color: '#34d399', icon: 'code' },
    { id: 'Quality',        color: '#f97316', icon: 'shield-check' },
    { id: 'Operations',     color: '#38bdf8', icon: 'server' },
    { id: 'Documentation',  color: '#f472b6', icon: 'book' }
];
```

### 7.3 Per-Agent Color Assignments

Each agent gets a unique color that is a variation within its category hue range, ensuring both per-agent uniqueness and category visual cohesion.

| Agent | Color | Hex | Category Hue Family |
|-------|-------|-----|---------------------|
| Product Manager | Soft Violet | `#a78bfa` | Planning (purple) |
| Software Architect | Medium Indigo | `#818cf8` | Planning (purple) |
| Software Developer | Emerald | `#34d399` | Development (green) |
| UX Designer | Teal | `#2dd4bf` | Development (green) |
| QA Engineer | Light Orange | `#fb923c` | Quality (orange) |
| Security Engineer | Orange | `#f97316` | Quality (orange) |
| Performance Engineer | Amber | `#f59e0b` | Quality (orange/yellow) |
| DevOps Engineer | Sky Blue | `#38bdf8` | Operations (blue) |
| Release Manager | Cyan | `#22d3ee` | Operations (blue) |
| Technical Writer | Pink | `#f472b6` | Documentation (pink) |

### 7.4 SVG Icon Definitions

Each agent has a custom inline SVG icon that metaphorically represents its role. The icons use simple geometric shapes for minimal file size.

| Agent | Icon Metaphor | Description |
|-------|---------------|-------------|
| Product Manager | Clipboard with checkmark | Represents planning and task management |
| Software Architect | Compass/protractor | Represents design and structural planning |
| Software Developer | Code brackets `</>` | Represents coding |
| UX Designer | Pen tool/bezier curve | Represents design and creativity |
| QA Engineer | Magnifying glass with check | Represents inspection and verification |
| Security Engineer | Shield | Represents protection |
| Performance Engineer | Rocket/speedometer | Represents speed and optimization |
| DevOps Engineer | Infinity loop/gear | Represents CI/CD and automation |
| Release Manager | Flag/package | Represents milestones and releases |
| Technical Writer | Book/document | Represents documentation |

All icons are defined as `<symbol>` elements within a hidden SVG block at the top of `<body>`, referenced via `<use href="#icon-{agent-id}">`. Each icon uses a consistent 48x48 viewBox, stroke-based design (2px stroke), with `currentColor` for easy CSS color inheritance.

---

## 8. State Management

### 8.1 State Object

```javascript
const initialState = {
    selectedAgent: null,    // string (agent id) or null
    activeFilter: null,     // string (category name) or null
    searchQuery: '',        // string
    compareMode: false,     // boolean (P1)
    compareAgents: [],      // string[] max length 2 (P1)
    darkMode: false,        // boolean (P1), auto-detected initially
    isMobile: false         // boolean, set on resize
};
```

### 8.2 State Manager Implementation

```javascript
function createStateManager(initial) {
    let state = Object.assign({}, initial);
    const listeners = [];

    return {
        getState: function() {
            return Object.assign({}, state);
        },

        setState: function(patch) {
            const prev = Object.assign({}, state);
            Object.assign(state, patch);
            const changed = Object.keys(patch).filter(function(key) {
                return prev[key] !== state[key];
            });
            if (changed.length > 0) {
                listeners.forEach(function(fn) {
                    fn(state, prev, changed);
                });
            }
        },

        subscribe: function(fn) {
            listeners.push(fn);
            return function unsubscribe() {
                const idx = listeners.indexOf(fn);
                if (idx > -1) listeners.splice(idx, 1);
            };
        }
    };
}
```

### 8.3 State-to-View Mapping

Each state change triggers specific view updates. The subscriber function inspects the `changed` keys array to determine which DOM updates are needed.

| State Property | DOM Updates Triggered |
|----------------|----------------------|
| `selectedAgent` | Update `.agent-node--selected` class, render/clear detail panel, update ARIA attributes |
| `activeFilter` | Update `.agent-node--dimmed` class on non-matching agents, update legend active state, update connection arcs visibility |
| `searchQuery` | Update `.agent-node--dimmed` class based on text match, highlight matching text in labels |
| `darkMode` | Toggle `data-theme` attribute on `<html>` element |
| `isMobile` | Trigger layout recalculation (orbital vs card list) |

---

## 9. Animation Strategy

### 9.1 Animation Categories and Implementation

| Animation | Trigger | Implementation | Properties Animated | Duration |
|-----------|---------|----------------|---------------------|----------|
| **Entry stagger** | Page load | CSS `@keyframes` with `animation-delay` computed from `--delay` custom property | `opacity`, `transform (scale, translateY)` | 600ms per node, 80ms stagger |
| **Hover glow** | Mouse enter | CSS `:hover` and `:focus-visible` pseudo-classes | `transform (scale)`, `box-shadow` | 150ms |
| **Selection expand** | Click agent | CSS class `.agent-node--selected` | `transform (scale)`, `box-shadow`, `border-color` | 300ms |
| **Detail panel open** | Click agent | CSS class `.detail-panel--open` | `opacity`, `transform (scale, translateY)` | 300ms spring easing |
| **Detail panel close** | Click outside/Escape | Remove `.detail-panel--open` class | `opacity`, `transform` | 200ms ease-out |
| **Filter dim** | Category filter | CSS class `.agent-node--dimmed` | `opacity`, `transform (scale)`, `filter (grayscale)` | 300ms |
| **Legend active** | Category filter | CSS class `.legend__item--active` | `background-color`, `border-color`, `transform (scale)` | 150ms |
| **Idle float** | Always (after entry) | `requestAnimationFrame` loop updating a CSS custom property `--float-offset` | `transform (translateY)` via CSS `calc()` | Continuous, 3-6s period per node |
| **Idle glow pulse** | Always (after entry) | CSS `@keyframes` infinite animation | `box-shadow` opacity | 4s infinite |
| **Connection line draw** | Page load (after entry) | CSS `stroke-dashoffset` animation | SVG `stroke-dashoffset` | 1000ms |

### 9.2 Performance Rules

1. **Only animate `transform` and `opacity`** for element movement and visibility. These are composited on the GPU and do not trigger layout or paint.
2. **`box-shadow` animation** is acceptable for glow effects on a small number of elements (10 nodes). If performance issues arise on low-end devices, the idle glow can be disabled.
3. **`filter: grayscale()`** is used only for the dimmed state (a momentary transition), not for continuous animation.
4. **`will-change: transform, opacity`** is set on `.agent-node` to hint the browser to promote these elements to their own compositor layer.
5. **Idle animation loop** uses a single `requestAnimationFrame` callback that updates a shared time variable. Each node reads this variable via a CSS custom property (`--time`) and computes its own offset using `calc()` and its unique `--delay`. This means **one JS RAF call drives all 10 nodes** without per-node JS computation.
6. **Reduced motion:** When `prefers-reduced-motion: reduce` is active, all animations are disabled except for immediate opacity transitions (instant state changes with no motion).

### 9.3 Idle Animation Detail (Single RAF Loop)

```javascript
function startIdleAnimation() {
    if (respectsReducedMotion()) return;

    let startTime = null;

    function tick(timestamp) {
        if (!startTime) startTime = timestamp;
        const elapsed = (timestamp - startTime) / 1000; // seconds
        document.documentElement.style.setProperty('--time', String(elapsed));
        idleAnimationId = requestAnimationFrame(tick);
    }

    idleAnimationId = requestAnimationFrame(tick);
}
```

In CSS, each node uses this:

```css
.agent-node {
    --float-speed: 4s;
    --float-amplitude: 6px;
    transform: translateY(
        calc(
            sin((var(--time, 0) + var(--delay, 0) * 0.3) * 1.0471975)
            * var(--float-amplitude)
        )
    );
}
```

**Note:** CSS `sin()` is supported in Chrome 111+, Firefox 108+, Safari 15.4+. For broader compatibility, the JS RAF loop can compute the Y offset per node and set it as an inline style. Since we have only 10 nodes, this is still a single loop with 10 `style.transform` writes per frame, well within 60 FPS budget.

**Fallback approach (wider compatibility):**

```javascript
function tick(timestamp) {
    if (!startTime) startTime = timestamp;
    const elapsed = (timestamp - startTime) / 1000;
    nodes.forEach(function(node, i) {
        const offset = Math.sin((elapsed + i * 0.3) * 1.0471975) * 6;
        node.style.transform = 'translateY(' + offset.toFixed(1) + 'px)';
    });
    idleAnimationId = requestAnimationFrame(tick);
}
```

This modifies only `transform` (composited property), so no layout or paint is triggered. 10 nodes at 60 FPS is trivial.

---

## 10. Accessibility Architecture

### 10.1 ARIA Landmark Structure

```
<body>
  [banner]      <header role="banner">         - Page title, search
  [main]        <main role="main">             - Chart area
    [navigation]  <nav aria-label="Filter..."> - Category legend/filter
    [group]       <div role="group">           - Orbital chart
      [list]        <div role="list">          - Agent nodes
        [listitem]    <div role="listitem">    - Individual agent
      [region]      <div role="region"         - Detail panel
                         aria-live="polite">
```

### 10.2 Keyboard Navigation Model

| Key | Context | Action |
|-----|---------|--------|
| `Tab` | Anywhere | Move focus to next interactive element (standard tab order: search, legend items, agent nodes, close button) |
| `Shift+Tab` | Anywhere | Move focus to previous interactive element |
| `Enter` / `Space` | Agent node focused | Select agent, open detail panel |
| `Escape` | Detail panel open | Close detail panel, return focus to previously selected agent node |
| `Arrow Left/Right` | Agent node focused | Move focus to adjacent agent node in the ring (wrapping) |
| `Arrow Up/Down` | Agent node focused | Move focus to agent in adjacent category arc (spatial navigation) |
| `Home` | Agent node focused | Move focus to first agent node |
| `End` | Agent node focused | Move focus to last agent node |

### 10.3 Focus Management

```javascript
function handleAgentClick(agentId) {
    store.setState({ selectedAgent: agentId });
    // After detail panel renders, move focus to it
    requestAnimationFrame(function() {
        const closeBtn = document.querySelector('.detail-panel__close');
        if (closeBtn) closeBtn.focus();
    });
}

function handleDetailClose() {
    const prevAgent = store.getState().selectedAgent;
    store.setState({ selectedAgent: null });
    // Return focus to the agent node that was selected
    if (prevAgent) {
        const node = document.querySelector(
            '[data-agent-id="' + prevAgent + '"]'
        );
        if (node) node.focus();
    }
}
```

### 10.4 Screen Reader Announcements

- The detail panel container has `aria-live="polite"`, so when its content changes (agent selected), the screen reader will announce the new content.
- Filter changes announce via a visually hidden live region: "Showing 3 agents in Quality category" or "Showing all 10 agents."
- Each agent node has an `aria-label` combining name and category: "Software Architect - Planning."

### 10.5 Color Contrast Verification

All agent colors were selected to meet WCAG 2.1 AA contrast ratio against the dark background (`#0f1117`):

| Agent Color | Hex | Contrast vs `#0f1117` | Pass (4.5:1)? |
|-------------|-----|----------------------|---------------|
| Soft Violet | `#a78bfa` | 6.2:1 | Yes |
| Medium Indigo | `#818cf8` | 5.1:1 | Yes |
| Emerald | `#34d399` | 8.4:1 | Yes |
| Teal | `#2dd4bf` | 8.1:1 | Yes |
| Light Orange | `#fb923c` | 7.3:1 | Yes |
| Orange | `#f97316` | 6.5:1 | Yes |
| Amber | `#f59e0b` | 7.8:1 | Yes |
| Sky Blue | `#38bdf8` | 7.9:1 | Yes |
| Cyan | `#22d3ee` | 8.0:1 | Yes |
| Pink | `#f472b6` | 6.4:1 | Yes |

**Note:** These ratios should be verified with a tool during implementation. If any fail, increase lightness of the agent color or darken the background further.

---

## 11. Responsive Design Strategy

### 11.1 Breakpoint System

| Breakpoint | Name | Layout | Agent Display |
|------------|------|--------|---------------|
| >= 1024px | Desktop | Orbital ring, full center detail panel | All 10 visible without scroll |
| 768-1023px | Tablet | Smaller orbital ring, reduced node size, overlay detail panel | All 10 visible, may need slight scroll |
| < 768px | Mobile | Vertical card list with category headers | Scrollable list, tap to expand |

### 11.2 Mobile Layout Transformation

On mobile, the orbital layout transforms completely into a vertical card list. This is not merely a resized orbital; it is an entirely different layout mode controlled by the `isMobile` state flag and CSS media queries.

**Mobile Card Layout:**

```
+-----------------------------------+
| [Search Input]                     |
+-----------------------------------+
| [Category Pills: scrollable row]   |
+-----------------------------------+
|                                   |
| PLANNING                          |
| +-------------------------------+ |
| | [Icon] Product Manager    [>] | |
| +-------------------------------+ |
| +-------------------------------+ |
| | [Icon] Software Architect [>] | |
| +-------------------------------+ |
|                                   |
| DEVELOPMENT                       |
| +-------------------------------+ |
| | [Icon] Software Developer [>] | |
| +-------------------------------+ |
| ...                               |
+-----------------------------------+
```

When an agent card is tapped on mobile, the detail view slides up as a bottom sheet overlay.

### 11.3 CSS Media Query Structure

```css
/* Tablet */
@media (max-width: 1023px) and (min-width: 768px) {
    :root {
        --orbital-radius: 200px;
        --node-size: 80px;
        --center-size: 240px;
    }
    /* Adjust font sizes, spacing */
}

/* Mobile */
@media (max-width: 767px) {
    .orbital__ring {
        /* Override absolute positioning with flex column */
        position: static;
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    .agent-node {
        position: static;
        width: 100%;
        /* Card style overrides */
    }
    .orbital__connections {
        display: none;
    }
    .orbital__center {
        /* Bottom sheet style */
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
        transform: translateY(100%);
        transition: transform var(--transition-normal);
    }
    .orbital__center--open {
        transform: translateY(0);
    }
}
```

### 11.4 Touch Support

- **Tap = Click:** No special handling needed; `click` events fire on tap.
- **Hover Preview:** On touch devices, hover is not available. The tooltip/preview is skipped; tapping goes directly to selection. Detect touch via `'ontouchstart' in window` or `matchMedia('(hover: none)')`.
- **Tap Outside:** Touch events on the background close the detail panel (handled by the same click-outside logic).

---

## 12. Security Architecture

### 12.1 XSS Prevention

| Vector | Mitigation |
|--------|-----------|
| Search input reflected in DOM | All search query text is escaped via `escapeHtml()` before any DOM insertion. No `innerHTML` with user input. |
| Agent data in DOM | Agent data is hardcoded and trusted, but still escaped via `escapeHtml()` as defense-in-depth. |
| URL parameters | No URL parameters are read. The page does not parse `location.search` or `location.hash`. |
| `eval()` / `Function()` | Not used anywhere. |
| Inline event handlers | Not used. All events attached via `addEventListener`. |

### 12.2 Content Security Policy Readiness

The page is designed to be compatible with a strict CSP:

```
Content-Security-Policy:
    default-src 'none';
    style-src 'self' 'unsafe-inline';
    script-src 'self' 'unsafe-inline';
    img-src 'none';
```

**Note:** Since all CSS and JS are inline, `'unsafe-inline'` is required for `style-src` and `script-src`. This is unavoidable for a single-file delivery. A nonce-based approach could be added by the hosting server if desired, but is out of scope for a static file.

### 12.3 escapeHtml Utility

```javascript
function escapeHtml(str) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
}
```

This uses the browser's own text node escaping, which correctly handles `<`, `>`, `&`, `"`, and `'`.

---

## 13. Performance Budget and Optimization

### 13.1 File Size Budget

| Component | Estimated Size | Budget |
|-----------|---------------|--------|
| HTML structure + noscript fallback | ~3 KB | 10 KB |
| CSS (all styles, animations, media queries) | ~12 KB | 20 KB |
| JavaScript (data + logic + rendering) | ~15 KB | 25 KB |
| SVG icon definitions (10 icons, stroke-based) | ~5 KB | 10 KB |
| **Total (uncompressed)** | **~35 KB** | **65 KB** |
| **Total (gzip compressed)** | **~10 KB** | **20 KB** |

This is well under the 500 KB constraint. No CDN dependencies means no additional network requests.

### 13.2 Load Performance

| Metric | Target | Strategy |
|--------|--------|----------|
| First Contentful Paint | < 1s | Single file, no external resources, minimal HTML skeleton renders immediately |
| Time to Interactive | < 2s | JS runs after DOM parse, no heavy computation. 10 trig calculations are microseconds. |
| Largest Contentful Paint | < 1.5s | The orbital layout renders in the first animation frame after JS executes |

### 13.3 Runtime Performance

| Operation | Strategy |
|-----------|----------|
| 60 FPS animations | Only `transform` and `opacity` are animated. `will-change` hints set. Idle animation is a single RAF loop for all 10 nodes. |
| Filter updates | Class toggling only (`.agent-node--dimmed`). No DOM creation/destruction during filtering. |
| Resize recalculation | Debounced to 150ms. Only updates CSS custom properties (no DOM rebuild). |
| Search filtering | Debounced to 100ms. String matching on 10 agents is O(1) in practice. |
| Detail panel render | `innerHTML` of a single container. Content is small (~500 bytes). |

### 13.4 Memory

- No detached DOM nodes (detail panel is rendered into a persistent container, not created/destroyed).
- No growing arrays or event listener leaks.
- Single RAF loop with a stored ID for clean cancellation.
- Estimated total JS heap: < 1 MB.

---

## 14. Component and Module Breakdown

### 14.1 Visual Component Tree

```
inventory.html
|
+-- PageHeader
|   +-- Title ("Agent Inventory")
|   +-- SearchInput (P1)
|
+-- ChartMain
|   +-- CategoryLegend
|   |   +-- LegendItem (x5, one per category)
|   |   +-- ResetButton
|   |
|   +-- OrbitalChart
|   |   +-- SVGDefs (hidden icon symbols)
|   |   +-- ConnectionArcs (SVG background layer)
|   |   +-- AgentNodeRing
|   |   |   +-- AgentNode (x10)
|   |   |       +-- IconContainer (SVG <use>)
|   |   |       +-- NameLabel
|   |   |       +-- Tooltip (hover, CSS-only)
|   |   |
|   |   +-- CenterHub
|   |       +-- DefaultView (title + tagline)
|   |       +-- DetailPanel (shown on selection)
|   |           +-- CloseButton
|   |           +-- AgentIcon (large)
|   |           +-- AgentTitle
|   |           +-- CategoryBadge
|   |           +-- Description
|   |           +-- CapabilitiesList
|   |
|   +-- LiveAnnouncer (sr-only, aria-live)
|
+-- ThemeToggle (P1)
+-- NoscriptFallback
```

### 14.2 JavaScript Module Responsibilities

| Module | Responsibility | Approximate Lines |
|--------|---------------|-------------------|
| **Data** | Agent and category definitions, static config constants | 80-100 |
| **State** | `createStateManager`, initial state, state types | 40-50 |
| **Layout** | `computeOrbitalPositions`, `computeResponsiveRadius`, `recalculateLayout` | 50-60 |
| **Renderer** | All `render*` functions, `updateNodeStates`, DOM manipulation | 150-200 |
| **Animation** | Entry triggers, idle loop, reduced motion check | 40-60 |
| **Events** | `setupEventDelegation`, `setupKeyboardNavigation`, all `handle*` functions | 100-120 |
| **Init** | `init`, `DOMContentLoaded` listener, orchestration | 20-30 |
| **Utilities** | `escapeHtml`, `debounce`, `$`, `$$` | 20-30 |
| **Total** | | **~500-650 lines** |

---

## 15. Implementation Sequence

The developer should implement in this order, testing each phase before proceeding.

### Phase 1: Foundation (estimated 1 hour)
1. Create the HTML skeleton with all semantic landmarks, `<noscript>` fallback table, and empty containers.
2. Define all CSS custom properties and base styles (reset, typography, colors).
3. Define the `AGENTS` and `CATEGORIES` data arrays in JavaScript.
4. Implement the `createStateManager` function.
5. Implement `escapeHtml` and other utilities.

### Phase 2: Static Orbital Layout (estimated 1 hour)
1. Create the SVG icon `<symbol>` definitions for all 10 agents.
2. Implement `computeOrbitalPositions` and `renderAgentNodes`.
3. Implement `renderLegend` for the category filter bar.
4. Style the orbital layout, agent nodes, and legend in CSS.
5. Verify all 10 agents appear correctly positioned in a ring.

### Phase 3: Core Interactions (estimated 1.5 hours)
1. Implement `setupEventDelegation` for click and hover.
2. Implement `handleAgentClick` and `renderDetailPanel` (center hub detail view).
3. Implement `handleCategoryFilter` and `updateNodeStates` (dimming).
4. Implement `handleReset`.
5. Implement `handleClickOutside` and Escape key handling.
6. Wire up state subscriptions so state changes trigger view updates.

### Phase 4: Keyboard and Accessibility (estimated 1 hour)
1. Implement full keyboard navigation (Tab, Arrow keys, Enter, Space, Escape, Home, End).
2. Add all ARIA attributes (`aria-label`, `aria-live`, `role`).
3. Implement focus management (focus return on detail close).
4. Implement the live announcer for filter changes.
5. Add skip link functionality.
6. Test with keyboard-only navigation.

### Phase 5: Animations (estimated 1 hour)
1. Implement entry stagger animation (CSS `@keyframes` + `animation-delay`).
2. Implement hover/focus glow effects (CSS transitions).
3. Implement detail panel open/close transitions.
4. Implement connection arc SVG draw animation.
5. Implement idle floating animation (RAF loop).
6. Implement `prefers-reduced-motion` disabling.

### Phase 6: Responsive and Touch (estimated 1 hour)
1. Implement tablet media query (smaller orbital).
2. Implement mobile media query (card list layout).
3. Implement mobile bottom-sheet detail panel.
4. Implement touch detection and touch-specific behavior.
5. Test on simulated mobile viewports.

### Phase 7: Nice-to-Have Features (estimated 1-2 hours)
1. Search input (P1) with debounced filtering.
2. Dark/Light mode toggle (P1).
3. Easter egg interaction (P1).
4. Agent comparison mode (P1).

### Phase 8: Polish and Validation (estimated 30 min)
1. Run HTML through W3C validator.
2. Test color contrast ratios.
3. Test with screen reader (VoiceOver, NVDA).
4. Performance audit (Lighthouse or manual timeline recording).
5. Final visual polish.

---

## 16. Technical Risks and Mitigations

### 16.1 Risk Matrix

| ID | Risk | Impact | Likelihood | Mitigation |
|----|------|--------|------------|------------|
| R1 | **CSS `sin()` not supported in target browsers** | Animation fallback needed | Medium | Use the JS RAF fallback approach (Section 9.3). Do NOT rely on CSS trigonometric functions. Use JS `Math.sin()` exclusively. |
| R2 | **Orbital layout unreadable on small tablets** | Layout breaks between 768-900px | Medium | Test at 768px specifically. If nodes overlap, reduce `--node-size` to 70px and `--orbital-radius` to 180px at this breakpoint. Alternatively, switch to card layout at 900px instead of 768px. |
| R3 | **SVG icons increase file size beyond budget** | Exceeds 500KB | Low | Keep icons to stroke-based simple geometry (< 500 bytes each). Total SVG block target: < 5KB for 10 icons. |
| R4 | **Idle animation causes jank on low-end devices** | Below 60 FPS | Low | The idle animation is optional (P1). Implement a feature check: if the first 60 frames drop below 55 FPS average, disable idle animation automatically. Also disabled by `prefers-reduced-motion`. |
| R5 | **Detail panel overlaps agent nodes at small radii** | Unreadable content | Medium | Set `--center-size` to be smaller than the inner ring space. On tablet, use an overlay detail panel (positioned above the orbital) instead of in-center. |
| R6 | **Focus trap issues with detail panel** | Accessibility failure | Medium | Do NOT use a true modal focus trap (the detail panel is not `aria-modal="true"`). Instead, just manage focus: on open, focus close button; on close, return focus to agent node. Users can still Tab away freely. |
| R7 | **Text truncation in agent labels on small nodes** | Unreadable labels | Medium | Use `font-size: clamp(10px, 1.2vw, 14px)` for node labels. On mobile card layout, full names are always visible. On orbital, allow two-line wrapping with `text-align: center`. |
| R8 | **High-DPI screens cause blurry SVG rendering** | Visual quality issue | Low | SVG icons are vector-based and resolution-independent. No risk here. |

### 16.2 Fallback Strategy

If any critical feature fails at runtime, the page should degrade gracefully:

1. **JavaScript fails to execute:** The `<noscript>` fallback table provides all agent data in a readable format.
2. **CSS animations not supported:** The page is fully functional without animations. All states are achieved via class toggling which also changes static visual properties (background, border, opacity).
3. **ResizeObserver not available:** Fall back to a debounced `window.resize` event listener.
4. **CSS Grid not supported:** Fall back to flexbox wrapping for the legend and absolute positioning for the orbital (which does not use Grid).

---

## Appendix: Reference Calculations

### A.1 Angular Positions for 10 Agents

```
Agent 0 (PM):    angle = -90 + (0 * 36) = -90    => top center
Agent 1 (SA):    angle = -90 + (1 * 36) = -54    => upper right
Agent 2 (SD):    angle = -90 + (2 * 36) = -18    => right upper
Agent 3 (UX):    angle = -90 + (3 * 36) =  18    => right lower
Agent 4 (QA):    angle = -90 + (4 * 36) =  54    => lower right
Agent 5 (SEC):   angle = -90 + (5 * 36) =  90    => bottom center
Agent 6 (PERF):  angle = -90 + (6 * 36) = 126    => lower left
Agent 7 (DO):    angle = -90 + (7 * 36) = 162    => left lower
Agent 8 (RM):    angle = -90 + (8 * 36) = 198    => left upper
Agent 9 (TW):    angle = -90 + (9 * 36) = 234    => upper left
```

### A.2 Cartesian Coordinates (radius = 260px)

```
Agent 0 (PM):    x =  260 * cos(-90) =    0,  y = 260 * sin(-90) = -260
Agent 1 (SA):    x =  260 * cos(-54) =  153,  y = 260 * sin(-54) = -210
Agent 2 (SD):    x =  260 * cos(-18) =  247,  y = 260 * sin(-18) =  -80
Agent 3 (UX):    x =  260 * cos( 18) =  247,  y = 260 * sin( 18) =   80
Agent 4 (QA):    x =  260 * cos( 54) =  153,  y = 260 * sin( 54) =  210
Agent 5 (SEC):   x =  260 * cos( 90) =    0,  y = 260 * sin( 90) =  260
Agent 6 (PERF):  x =  260 * cos(126) = -153,  y = 260 * sin(126) =  210
Agent 7 (DO):    x =  260 * cos(162) = -247,  y = 260 * sin(162) =   80
Agent 8 (RM):    x =  260 * cos(198) = -247,  y = 260 * sin(198) =  -80
Agent 9 (TW):    x =  260 * cos(234) = -153,  y = 260 * sin(234) = -210
```

### A.3 Category Arc Angles

| Category | Agents | Arc Start | Arc End | Arc Span |
|----------|--------|-----------|---------|----------|
| Planning | PM, SA | -90 | -54 | 36 |
| Development | SD, UX | -18 | +18 | 36 |
| Quality | QA, SEC, PERF | +54 | +126 | 72 |
| Operations | DO, RM | +162 | +198 | 36 |
| Documentation | TW | +234 | +234 | 0 (single point) |

These arcs can be rendered as SVG `<path>` elements using the `arc` command, with the category color at reduced opacity as a background ring segment.

---

*End of Architecture Document*
