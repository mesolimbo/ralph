# Retro Minesweeper - Architecture Document

## 1. Technology Stack

### Recommended Stack: Single HTML File with Embedded CSS/JS

| Layer | Technology | Rationale |
|-------|------------|-----------|
| Structure | HTML5 | Semantic markup, no build process required |
| Styling | Embedded CSS3 | Retro aesthetics, beveled effects, no external dependencies |
| Logic | Vanilla JavaScript (ES6+) | Game state, event handling, no framework overhead |
| Audio | Web Audio API | Generate sounds programmatically, no external audio files |

### Why This Approach

1. **Zero Dependencies**: No npm, no build tools, no CDN links
2. **Instant Deployment**: Drop the HTML file anywhere and it works
3. **Offline Capable**: Works without internet after initial load
4. **Browser Native**: Leverages modern browser APIs directly
5. **Maintainable**: All code in one place, easy to understand and modify

---

## 2. File Structure

```
minesweeper.html    # Single self-contained file
```

### Internal Organization (within the HTML file)

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Retro Minesweeper</title>
    <style>
        /* Section 1: CSS Variables (colors, fonts) */
        /* Section 2: Layout styles */
        /* Section 3: Grid and cell styles */
        /* Section 4: UI component styles */
        /* Section 5: Animations */
    </style>
</head>
<body>
    <!-- Section 1: Game header (title, mine counter, restart button) -->
    <!-- Section 2: Game grid container -->
    <!-- Section 3: Status/message overlay -->

    <script>
        /* Section 1: Configuration constants */
        /* Section 2: Game state management */
        /* Section 3: Grid/board logic */
        /* Section 4: UI rendering */
        /* Section 5: Event handlers */
        /* Section 6: Sound generation */
        /* Section 7: Initialization */
    </script>
</body>
</html>
```

---

## 3. Key Components and Responsibilities

### 3.1 Game State Manager

**Responsibility**: Maintain and update the authoritative game state.

```
GameState
  |-- status: 'playing' | 'won' | 'lost'
  |-- mineCount: number (total mines)
  |-- flagCount: number (currently placed flags)
  |-- revealedCount: number (cells revealed)
  |-- grid: 2D array of Cell objects
```

**Operations**:
- `initializeGame()`: Reset state, place mines, calculate numbers
- `revealCell(row, col)`: Handle cell reveal logic
- `toggleFlag(row, col)`: Toggle flag on a cell
- `checkWinCondition()`: Determine if player has won

### 3.2 Grid/Board Logic

**Responsibility**: Handle mine placement, number calculation, and cascade reveal.

**Operations**:
- `placeMines(excludeRow, excludeCol)`: Randomly place mines (first click safe)
- `calculateAdjacentMines()`: Compute numbers for all cells
- `getAdjacentCells(row, col)`: Return list of valid neighbor coordinates
- `cascadeReveal(row, col)`: Recursively reveal empty cell regions

### 3.3 UI Renderer

**Responsibility**: Render game state to the DOM and update visual elements.

**Operations**:
- `renderGrid()`: Create initial grid DOM structure
- `updateCell(row, col)`: Update single cell appearance
- `updateMineCounter()`: Update the remaining mines display
- `showGameOverlay(message)`: Display win/lose message
- `hideGameOverlay()`: Clear overlay for new game

### 3.4 Event Handler

**Responsibility**: Capture and route user interactions.

**Events Handled**:
- `click` (left): Reveal cell
- `contextmenu` (right): Toggle flag
- `click` on restart button: Reset game

**Event Flow**:
```
User Click -> Event Handler -> Game State Update -> UI Render -> Sound Play
```

### 3.5 Sound Manager

**Responsibility**: Generate and play audio feedback using Web Audio API.

**Sounds**:
| Sound | Trigger | Character |
|-------|---------|-----------|
| Reveal | Cell uncovered | Short blip/pop |
| Flag | Flag placed/removed | Click/toggle |
| Win | Game won | Ascending melody |
| Lose | Mine hit | Low buzz/explosion |

**Implementation**: Use `OscillatorNode` and `GainNode` to synthesize retro-style sounds.

---

## 4. Data Structures

### 4.1 Cell Object

```javascript
Cell {
    isMine: boolean,        // true if cell contains a mine
    isRevealed: boolean,    // true if cell has been revealed
    isFlagged: boolean,     // true if cell has a flag
    adjacentMines: number   // count of adjacent mines (0-8)
}
```

### 4.2 Game Grid

```javascript
// 2D array representing the 10x10 board
grid: Cell[10][10]

// Access pattern
grid[row][col]  // row: 0-9, col: 0-9
```

### 4.3 Configuration Constants

```javascript
const CONFIG = {
    GRID_SIZE: 10,          // 10x10 grid
    MINE_COUNT: 12,         // Number of mines (adjustable 10-15)
    CELL_SIZE: 32,          // Pixels per cell
};
```

### 4.4 Number Color Palette (Classic Minesweeper)

```javascript
const NUMBER_COLORS = {
    1: '#0000FF',  // Blue
    2: '#008000',  // Green
    3: '#FF0000',  // Red
    4: '#000080',  // Navy
    5: '#800000',  // Maroon
    6: '#008080',  // Teal
    7: '#000000',  // Black
    8: '#808080'   // Gray
};
```

---

## 5. Module/Function Design

### 5.1 Initialization Module

```javascript
function init() {
    // Create initial game state
    // Render empty grid to DOM
    // Attach event listeners
    // Initialize audio context (on first user interaction)
}

function createEmptyGrid() {
    // Returns: Cell[10][10] with default values
}
```

### 5.2 Game Logic Module

```javascript
function placeMines(grid, excludeRow, excludeCol) {
    // Place MINE_COUNT mines randomly
    // Exclude the first-clicked cell and its neighbors
    // Returns: modified grid
}

function calculateNumbers(grid) {
    // For each non-mine cell, count adjacent mines
    // Returns: modified grid
}

function getNeighbors(row, col) {
    // Returns: array of {row, col} for valid adjacent cells
}

function revealCell(row, col) {
    // If mine: game over
    // If number: reveal single cell
    // If empty (0): trigger cascade
    // Check win condition after reveal
}

function cascadeReveal(row, col) {
    // Use BFS or recursive DFS to reveal connected empty cells
    // Stop at numbered cells (reveal them but don't continue)
}

function toggleFlag(row, col) {
    // Toggle isFlagged on unrevealed cells
    // Update flag counter
}

function checkWin() {
    // Win if: all non-mine cells are revealed
    // Returns: boolean
}
```

### 5.3 UI Rendering Module

```javascript
function renderGrid() {
    // Create 10x10 grid of div elements
    // Assign data attributes for row/col
    // Apply initial "unrevealed" styling
}

function updateCellDisplay(row, col, cell) {
    // Update cell appearance based on state:
    // - Unrevealed: raised/beveled look
    // - Flagged: show flag symbol
    // - Revealed + mine: show mine symbol
    // - Revealed + number: show colored number
    // - Revealed + empty: flat empty cell
}

function updateHeader() {
    // Update mine counter display
    // Update any status indicators
}

function showOverlay(isWin) {
    // Display win/lose message
    // Show restart prompt
}
```

### 5.4 Event Handling Module

```javascript
function handleCellClick(event) {
    // Get row/col from event target
    // If game over: ignore
    // If flagged: ignore
    // If first click: place mines, then reveal
    // Else: reveal cell
}

function handleCellRightClick(event) {
    // Prevent context menu
    // Get row/col from event target
    // If game over: ignore
    // If revealed: ignore
    // Else: toggle flag
}

function handleRestart() {
    // Reset game state
    // Re-render grid
    // Hide overlay
}
```

### 5.5 Sound Module

```javascript
let audioContext = null;

function initAudio() {
    // Create AudioContext on first user interaction
    // Required due to browser autoplay policies
}

function playSound(type) {
    // type: 'reveal' | 'flag' | 'win' | 'lose'
    // Create oscillator with appropriate frequency/duration
    // Apply gain envelope for retro feel
}

function playRevealSound() {
    // Short high-pitched blip (~100ms, ~800Hz)
}

function playFlagSound() {
    // Click sound (~50ms, ~400Hz)
}

function playWinSound() {
    // Ascending arpeggio (3-4 notes)
}

function playLoseSound() {
    // Descending tone or buzz (~300ms, ~200Hz)
}
```

---

## 6. Event Flow Diagrams

### 6.1 Cell Reveal Flow

```
Left Click on Cell
       |
       v
[Is game over?] --YES--> (ignore)
       |NO
       v
[Is cell flagged?] --YES--> (ignore)
       |NO
       v
[Is first click?] --YES--> placeMines() -> calculateNumbers()
       |NO                        |
       v                          v
[Reveal cell] <-------------------+
       |
       v
[Is mine?] --YES--> setGameOver('lost') -> revealAllMines() -> playLoseSound()
       |NO
       v
[Is empty (0)?] --YES--> cascadeReveal()
       |NO                    |
       v                      v
updateCellDisplay() <---------+
       |
       v
playRevealSound()
       |
       v
[checkWin()?] --YES--> setGameOver('won') -> playWinSound()
       |NO
       v
(continue playing)
```

### 6.2 Flag Toggle Flow

```
Right Click on Cell
       |
       v
preventDefault() (block context menu)
       |
       v
[Is game over?] --YES--> (ignore)
       |NO
       v
[Is cell revealed?] --YES--> (ignore)
       |NO
       v
toggleFlag()
       |
       v
updateCellDisplay()
       |
       v
updateMineCounter()
       |
       v
playFlagSound()
```

---

## 7. CSS Architecture

### 7.1 Design Tokens (CSS Variables)

```css
:root {
    /* Colors */
    --bg-color: #c0c0c0;        /* Classic gray */
    --cell-light: #ffffff;       /* Bevel highlight */
    --cell-dark: #808080;        /* Bevel shadow */
    --cell-bg: #c0c0c0;          /* Cell background */
    --cell-revealed: #bdbdbd;    /* Revealed cell */

    /* Sizing */
    --cell-size: 32px;
    --border-width: 3px;
    --grid-gap: 1px;

    /* Typography */
    --font-family: 'Courier New', monospace;
    --font-size: 18px;
    --font-weight: bold;
}
```

### 7.2 Beveled Cell Effect (Retro 3D Look)

```css
.cell {
    /* Raised button appearance */
    border-top: var(--border-width) solid var(--cell-light);
    border-left: var(--border-width) solid var(--cell-light);
    border-bottom: var(--border-width) solid var(--cell-dark);
    border-right: var(--border-width) solid var(--cell-dark);
}

.cell.revealed {
    /* Flat pressed appearance */
    border: 1px solid var(--cell-dark);
}
```

---

## 8. Browser Compatibility

| Feature | Chrome | Firefox | Safari | Edge |
|---------|--------|---------|--------|------|
| CSS Grid | 57+ | 52+ | 10.1+ | 16+ |
| CSS Variables | 49+ | 31+ | 9.1+ | 15+ |
| Web Audio API | 35+ | 25+ | 6+ | 12+ |
| ES6 (const, let, arrow) | 51+ | 44+ | 10+ | 14+ |

All target browsers support required features. No polyfills needed.

---

## 9. Performance Considerations

1. **DOM Updates**: Update only changed cells, not entire grid
2. **Event Delegation**: Single click handler on grid container, not per-cell
3. **Audio Context**: Reuse single AudioContext instance
4. **Cascade Reveal**: Use iterative BFS to avoid stack overflow on large reveals
5. **Initial Render**: Generate grid HTML as string, single innerHTML assignment

---

## 10. Security Notes

- No external resources loaded
- No user data stored or transmitted
- No eval() or dynamic code execution
- Context menu disabled only on game grid
