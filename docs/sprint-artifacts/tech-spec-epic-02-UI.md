# Epic 2: Tier 1 Economy - User Interface Screens

**Part 3 of 3** | [Index & Navigation](tech-spec-epic-02-INDEX.md) | [Core Mechanics](tech-spec-epic-02-CORE.md) | [Systems](tech-spec-epic-02-SYSTEMS.md)

**Project:** Trade Factory Masters
**Epic:** EPIC-02 - Tier 1 Economy
**Date:** 2025-12-03
**Status:** ✅ COMPLETE

---

## Overview

Part 3 covers all **6 user interface screens** for Tier 1 Economy gameplay. Each screen is designed for mobile-first experience (375px minimum) with 60 FPS animations and clear interaction patterns.

**Screens Covered:**
1. Main Hub Screen (Home Dashboard)
2. Grid World Screen (Map & Buildings)
3. Biom Gathering Screen (Resource Collection)
4. Storage Management Screen (Inventory + Filtering)
5. Crafting Queue Screen (Production)
6. NPC Trading Screens (Commerce)

**Design Principles:**
- Mobile-first: 375px baseline (iPhone SE)
- Touch-friendly: 44px+ minimum targets
- Performance: 60 FPS on budget Android
- Accessibility: Clear affordances, error prevention
- Responsive: Scales to 1024px+ tablets

---

## 1. Main Hub Screen (Home Dashboard)

### Purpose

Central dashboard showing player progress, objectives, quick actions, and economy status.

### Layout (Mobile: 375×812)

```
┌────────────────────────────────┐
│ HEADER                         │
├─ Trade Factory Masters ────────┤
├────────────────────────────────┤
│ QUICK STATS (4 cards)          │
│ ┌──────────┬──────────┐        │
│ │ Level 5  │ Gold 327g│        │
│ ├──────────┼──────────┤        │
│ │ Time 0:45│ Buildings│        │
│ │ Min      │ 6 placed │        │
│ └──────────┴──────────┘        │
├────────────────────────────────┤
│ OBJECTIVE TRACKER              │
│ ├─ Gather 100 Coal ◦◦◦◦◦○○○ │
│ ├─ Build Smelter ✓            │
│ └─ Earn 500g ◦◦◦◦◦◦◦◦○       │
├────────────────────────────────┤
│ SKILL OVERVIEW (3 pills)       │
│ ┌──────┬──────┬──────┐         │
│ │ ⛏ M5 │ 🔥 S2│ 💰 T3│         │
│ └──────┴──────┴──────┘         │
├────────────────────────────────┤
│ ACTION BUTTONS                 │
│ ┌────────────┬────────────┐    │
│ │ 🗺 Map     │ 🎯 Gather  │    │
│ ├────────────┼────────────┤    │
│ │ ⚙ Craft   │ 💰 Trade  │    │
│ └────────────┴────────────┘    │
├────────────────────────────────┤
│ NOTIFICATION (if offline)      │
│ "Welcome back! +92g earned"    │
│ [Offline Details]              │
└────────────────────────────────┘
```

### Components

**Header:**
- Game title
- Current playtime
- Settings icon (⚙)

**Quick Stats (4 Cards):**
```
Card 1: Level
  Display: "Level 5"
  Stat: Current player level
  Updated: When XP gained

Card 2: Gold
  Display: "327g"
  Stat: Current gold amount
  Updated: Real-time

Card 3: Playtime
  Display: "0:45 min"
  Stat: Session duration
  Updated: Every second

Card 4: Buildings
  Display: "6 placed"
  Stat: Count of all placed buildings
  Updated: When building placed/demolished
```

**Objective Tracker:**
- List of current objectives (3-5)
- Progress bars per objective
- Checkmark when completed
- Shows next objective when one completes

**Skill Overview (Pills):**
```
Mining: ⛏ M5 (Level 5)
Smelting: 🔥 S2 (Level 2)
Trading: 💰 T3 (Level 3)

Tapping skill pill opens Skill Details screen
```

**Action Buttons (4 main):**
```
🗺 Map → Navigate to Grid World Screen
🎯 Gather → Navigate to Biom Gathering Screen
⚙ Craft → Navigate to Crafting Queue Screen
💰 Trade → Navigate to NPC Trading Screen
```

**Welcome-Back Notification (if offline):**
- Triggered when offline time > 5 minutes
- Shows gold earned during offline
- Animated counter (0 → final gold)
- Dismissable with [OK] button

### Interactions

**Tap Quick Stats:**
- Level card → Show XP progress detail
- Gold card → Show gold breakdown (farm, trades, gathering)
- Playtime card → Show session timeline
- Buildings card → Show list of all buildings

**Swipe:**
- Down from top: Pull-down for refresh (check offline progress)
- Up from bottom: Slide-up menu (settings, profile)

**Long-Press:**
- Objective → Show details and hint
- Skill pill → Show skill progression chart

### Animations

**On Load:**
```
T=0: Header fades in (200ms)
T=200: Stats cards slide in from bottom (300ms, staggered 50ms each)
T=650: Objectives fade in (200ms)
T=850: Skills slide in horizontally (250ms)
T=1100: Buttons scale in (150ms, staggered)
```

**Real-Time Updates:**
```
Gold change:
  - Quick number counter animation (200ms)
  - Brief gold flash (yellow glow)
  - Subtly satisfying

Building placed notification:
  - "Building placed!" toast (top center)
  - +1 on buildings card
  - Counter animates 5 → 6
```

**Offline Notification:**
```
Appears when offline time ends
Slides in from top (300ms)
Shows breakdown in expandable section
Counter animates final gold total
Satisfying coin drop animation
```

### Mobile Optimization

**Layout Scaling:**
- 375px: Full layout as shown
- 480px: Slightly larger touch targets
- 600px: Cards display side-by-side
- 1024px+: Tablet layout (2 columns)

**Responsive Adjustments:**
- Font sizes scale 1.2× on tablets
- Button heights increase to 56px
- Card padding adjusts for larger screens
- Grid of stats becomes flexible

**Performance:**
- Real-time updates debounced (100ms)
- Animations GPU-accelerated (60 FPS)
- Lazy-load offline notification (on demand)
- Cache stats data to avoid rebuilds

---

## 2. Grid World Screen (Map & Buildings)

### Purpose

Main production map where player places buildings, visualizes conveyors, and manages world expansion.

### Layout (Mobile: 375×812)

```
┌────────────────────────────────┐
│ TOOLBAR                        │
├─ [−] [HOME] [+] ───────────────┤
│       Grid: 20×20              │
├────────────────────────────────┤
│                                │
│    [GRID VISUALIZATION]        │
│                                │
│    • Biom zones (colors)       │
│    • Buildings (icons)         │
│    • Conveyors (lines)         │
│    • Grid lines (faint)        │
│                                │
│                                │
│                                │
├────────────────────────────────┤
│ SELECTED BUILDING INFO         │
│ Mining Facility [Demolish] [?] │
│ Gathers: Coal (1.25s)          │
│ Level: 2  Efficiency: 98%      │
└────────────────────────────────┘
```

### Components

**Toolbar:**
- **[−] Button**: Zoom out
  - Keyboard shortcut: Minus key
  - Limit: 0.5× zoom minimum

- **[HOME] Button**: Center on player
  - Keyboard shortcut: 0 (zero)
  - Resets pan/zoom to initial state

- **[+] Button**: Zoom in
  - Keyboard shortcut: Plus key
  - Limit: 2.0× zoom maximum

- **Grid Size Display**: "20×20" or "30×30" or "40×40"
  - Shows current grid expansion level
  - Updates when expansion completes

**Grid Visualization:**

**Biom Colors:**
```
Koppalnia (Mining): Dark gray (#333)
Las (Forest): Green (#4CAF50)
Góry (Mountains): Brown (#8D6E63)
Jezioro (Lake): Blue (#2196F3)
Empty/Buildable: Light gray (#EEEEEE)
```

**Building Icons (Stylized):**
```
Mining Facility: ⛏ (pickaxe)
Storage: 📦 (box)
Smelter: 🔥 (flame)
Conveyor: ➡ (arrows)
Workshop: 🔧 (wrench)
Farm: 👨‍🌾 (farmer)
```

**Conveyor Visualization:**
```
Lines connecting buildings
Color by content:
  - Green: Coal/resources flowing
  - Yellow: Blocked/queued
  - Red: Error/invalid

Animation: Items move along lines (0.5 items/sec)
```

**Grid Lines (Faint):**
- Gray dashed lines (10% opacity)
- Show tile boundaries
- Clear at 0.8× zoom or larger
- Disappear at 0.5× zoom (too dense)

**Selected Building Info Panel:**
```
Displays when building is tapped:
┌─────────────────────────────────┐
│ Building Name [Demolish] [Info] │
│                                 │
│ Status: Operational             │
│ Input: 2 items in queue         │
│ Efficiency: 98%                 │
│ Next craft: 45s remaining       │
│                                 │
│ Connected Conveyors: 2          │
│ Output ports: East, South       │
└─────────────────────────────────┘

[Demolish] button: Long-press (500ms) → Confirm dialog
[Info] button: Show detailed stats
```

### Interactions

**Zoom:**
- **Pinch zoom** (2 fingers): Zoom in/out smoothly
- **Scroll wheel**: Scroll up = zoom in, down = zoom out
- **Buttons**: [−] and [+] for discrete zoom steps
- **Limits**: 0.5× minimum (full view), 2.0× maximum (detail)

**Pan:**
- **Drag/swipe**: One finger to pan around grid
- **Limits**: Can't drag beyond grid boundaries
- **Velocity**: Smooth inertia scrolling

**Building Selection:**
- **Tap building**: Selects and shows info panel
- **Tap empty area**: Deselects
- **Double-tap building**: Opens building details screen

**Building Placement:**
- **Long-press empty tile**: Shows placement menu
- **Select building type**: Grid highlights valid locations
- **Valid tiles**: Green highlight, valid biom if needed
- **Invalid tiles**: Red X overlay (wrong biom, occupied, etc)
- **Tap to place**: Confirms placement, starts craft timer

**Building Context Menu (Long-Press):**
```
┌────────────────┐
│ Demolish       │ (80% refund)
│ Info           │ (show stats)
│ Upgrade        │ (if available)
└────────────────┘
```

**Grid Expansion:**
- Shows notification when triggered
- Dialog: "Grid can expand! Cost: 50 Beton"
- [Confirm] or [Later] buttons
- Expansion animation plays (1.5s)

### Animations

**On Load:**
```
T=0: Toolbar slides down (200ms)
T=200: Grid fades in (300ms)
T=500: Buildings appear with scale animation (200ms, staggered)
T=700: Conveyors draw in with animated lines (400ms)
T=1100: Info panel slides up from bottom (250ms)
```

**Pan & Zoom:**
- Smooth easing (cubic bezier)
- No lag on device swipe
- 60 FPS animation target

**Building Placement:**
```
Selected building shows preview:
  - Semi-transparent overlay at cursor
  - Green if valid, red if invalid
  - Animates slightly (scale pulse 0.9 → 1.0)

Confirm placement:
  - Snap to grid
  - Build animation: Scale in + rotate
  - Glow effect (200ms)
```

**Conveyor Flow:**
```
Items animate along conveyor path:
  - Position updates every 100ms
  - Color changes based on state
  - Speed: 0.5 items/second
  - Smooth interpolation
```

**Grid Expansion:**
```
T=0: Fade to white (200ms)
T=200: New grid renders
T=500: New bioms paint in (500ms)
T=1000: Zoom to fit new grid (500ms)
T=1500: Fade out, expansion complete
```

### Mobile Optimization

**Touch Targets:**
- Buildings: Min 44px × 44px
- Buttons: Min 48px × 48px
- Zoom buttons: 56px × 56px
- Long-press detection: 500ms

**Performance:**
- Only render visible tiles
- Cull buildings outside viewport
- Batch conveyor line rendering
- Use GPU for transformations
- Target 60 FPS on Snapdragon 660

**Responsive Layout:**
- 375px: Toolbar at top, info panel at bottom
- 480px: Larger grid area
- 600px+: Side-by-side layout possible (toolbar left, grid right)
- Tablets: Multi-pane view (grid left, details right)

**Gesture Handling:**
- Distinguish drag (move) from tap (select)
- Long-press (500ms) for context menu
- Double-tap (2× tap < 200ms) for details
- Pinch gesture for zoom

---

## 3. Biom Gathering Screen (Resource Collection)

### Purpose

Manual resource gathering interface where player collects resources from biom areas.

### Layout (Mobile: 375×812)

```
┌────────────────────────────────┐
│ HEADER                         │
├─ Biom Gathering ──── ⬅ ➜ ─────┤
│ Las (Forest)                   │
├────────────────────────────────┤
│ RESOURCE CARDS (2 columns)     │
│ ┌──────────────┬──────────┐    │
│ │ 🌳 Wood      │ Coal ⛏   │    │
│ │ 45/50 in     │ Gather   │    │
│ │ [GATHER]     │ 3s       │    │
│ ├──────────────┼──────────┤    │
│ │ 🪨 Stone     │ Iron Ore │    │
│ │ 12/50 in     │ 1.25s    │    │
│ │ [GATHER]     │ [GATHER] │    │
│ └──────────────┴──────────┘    │
├────────────────────────────────┤
│ MINING FACILITY STATUS         │
│ 🏭 Operational (2 of 3)        │
│ Wood: 0.94s (auto)             │
│ [Details]                      │
├────────────────────────────────┤
│ INVENTORY (bottom bar)         │
│ ⬇ Storage: 127/200 items       │
│ [View Breakdown]               │
└────────────────────────────────┘
```

### Components

**Header:**
- Biom name: "Las (Forest)" or "Koppalnia (Mining)" etc
- Navigation arrows: ⬅ ➜ to switch bioms
- Icons: 🌳 🪨 ⛏ 💎 🌊 respectively

**Resource Cards (2-3 per biom):**
```
Per card:
┌──────────────────┐
│ ICON + Name      │
│ Current/Max      │
│ in inventory     │
├──────────────────┤
│ [GATHER] button  │
│ or               │
│ Timer: 3s ⏲      │
│                  │
│ Gather speed:    │
│ 1.25s (base)     │
│ -10% (Mining +5) │
│ = 1.125s actual  │
└──────────────────┘

GATHER Button:
  - Tap and hold
  - Activates 2-3 second progress bar
  - Release before complete = cancel
  - Completes = +1 item, timer resets
```

**Progress Bar (during gathering):**
```
When holding GATHER:
[████████░░] 2.5s / 3.0s
 ◄─────► Swipe left to cancel

Animation:
  - Fills from left to right
  - Color: Green when safe, yellow when near cancel zone
  - Release early = cancel (no item gained)
```

**Mining Facility Status:**
```
Shows count: "2 of 3" (2 active, 1 slot available)

If active:
  Wood: 0.94s (auto) [Level 5 bonus applied]
  Coal: 1.125s (auto)

Shows actual time with skill bonus applied

[Details] → Shows mining queue and where resources go
```

**Inventory Status Bar:**
```
⬇ Storage: 127/200 items

Color:
  - Green: < 50%
  - Yellow: 50-80%
  - Red: > 80% (warning)
  - Blinking red: At capacity

[View Breakdown] → Opens Storage Management Screen
```

### Biom Switching

**Horizontal Scroll/Swipe:**
```
Swipe left: Next biom
Swipe right: Previous biom
Navigation wraps: Biom 5 → Biom 1

Smooth scroll animation (300ms)
Resource cards fade/transition
```

**Biom Order:**
1. Koppalnia (Mining) - Coal, Iron Ore
2. Las (Forest) - Wood
3. Góry (Mountains) - Stone, Copper
4. Jezioro (Lake) - Wata, Sól, Glina
5. (Cycling back to Koppalnia)

**Biom Availability:**
- All 4+ bioms available if on map
- Greyed out if not yet discovered (future feature)
- Swipe shows available bioms only

### Interactions

**Tap & Hold GATHER:**
```
T=0: User touches GATHER button
T=200ms: Haptic feedback (vibration)
T=300ms: Progress bar appears
T=300-3000ms: Bar fills, user can still hold
T=3000ms: ✓ Resource gained, inventory +1
         Timer resets or completes

Early release (< 3s):
  - Cancel animation (fade out)
  - No resource gained
  - User can try again immediately
```

**Swipe to Switch Bioms:**
```
Swipe left:
  - Current biom slides out left
  - Next biom slides in from right
  - 300ms animation

Swipe right:
  - Current biom slides out right
  - Previous biom slides in from left
  - 300ms animation

Swipe threshold: 50px minimum
Velocity: Inertia snap to next biom
```

**Tap Biom Name (to open map):**
```
Shows location of this biom on grid world
Allows placing mining facilities on correct biom
[Back] → Return to gathering
```

**Tap Mining Facility Details:**
```
Shows:
  - Which facilities are mining this resource
  - Which resources they're gathering
  - Current queue
  - Efficiency (skill bonus applied)

[Configure] → Reallocate mining facilities
```

### Animations

**On Load:**
```
T=0: Header fades in (200ms)
T=200: Biom cards slide in from bottom (300ms, staggered)
T=500: Mining facility info fades in (200ms)
T=700: Inventory bar slides up (150ms)
T=850: All interactive elements ready
```

**During Gathering:**
```
Progress bar fill: Smooth linear animation (actual gather time)
Haptic feedback: Vibration at start + completion
Resource gained: +1 counter animation, gold glow
```

**Biom Transition:**
```
Old biom cards: Slide out with fade (300ms)
New biom cards: Slide in with fade (300ms)
Simultaneous: Smooth flowing feeling
```

**Storage Warning:**
```
Inventory at 80%+: Yellow tint pulse (1s cycle)
Inventory at 100%: Red background, blinking (urgent)
Notification: "Storage full! Clear some items."
```

### Mobile Optimization

**Touch Targets:**
- GATHER buttons: 56px × 56px minimum
- Biom tabs: 40px high swipe zone
- Details buttons: 44px × 44px

**Layout Scaling:**
- 375px: 2-column card layout
- 480px: 2-column, larger text
- 600px+: 3-column possible
- 1024px: 4-column tablet layout

**Performance:**
- Card rendering: Lazy-load off-screen cards
- Progress bar: Use animations framework (GPU)
- Inventory updates: Debounce to 100ms
- 60 FPS target

**Accessibility:**
- Clear tap zones
- Haptic feedback on important actions
- Audio feedback option (clink sound)
- High contrast for progress bar
- Color-blind safe: Icons + labels (not color only)

---

## 4. Storage Management Screen (Inventory + Filtering)

### Purpose

View and manage storage inventory with filtering configuration per port.

### Layout (Mobile: 375×812)

```
┌────────────────────────────────┐
│ STORAGE MANAGEMENT             │
├─ Select Storage ────────────────┤
│ [Storage A] [Storage B] [+New]  │
├────────────────────────────────┤
│ INVENTORY BREAKDOWN             │
│ ┌──────────────────────────────┐│
│ │ 🌳 Wood: 45 items           ││
│ │ ⛏ Coal: 32 items           ││
│ │ 🪨 Stone: 28 items          ││
│ │ 💎 Copper: 0 items          ││
│ └──────────────────────────────┘│
│ Total: 105 / 200 items (52%)    │
├────────────────────────────────┤
│ GLOBAL FILTER                  │
│ ⊙ Accept all items             │
│ ⊙ Whitelist: [+] Coal          │
│ ⊙ Reject: [+] Copper           │
├────────────────────────────────┤
│ PORT FILTERS                   │
│ Input [Configure]              │
│ Output [Configure]             │
├────────────────────────────────┤
│ ACTIONS                        │
│ [Empty All] [Settings] [Map]   │
└────────────────────────────────┘
```

### Components

**Storage Selection:**
- Tabs showing all storages (A, B, C, etc)
- [+New] to build new storage building
- Active tab highlighted
- Shows which storage currently selected

**Inventory Breakdown:**
```
List of all items in storage:
  Icon + Name: Count items

Shows:
  - Total item count
  - Storage capacity (105/200)
  - Percentage filled (52%)
  - Color indicator: Green/yellow/red
```

**Global Filter Configuration:**
```
Radio buttons:
⊙ Accept all items (default)
⊙ Whitelist (only these items accepted)
  ├─ [+ Add Resource] button
  └─ List: Coal, Iron Ore (removable)

⊙ Reject (these items blocked)
  ├─ [+ Add Resource] button
  └─ List: Copper (removable)

[Save] [Cancel] buttons
```

**Per-Port Filter Configuration:**
```
Input Port (receives from conveyor):
  Mode selector: [ALLOW_ALL] [WHITELIST] [BLACKLIST] [SINGLE]

  If WHITELIST:
    [+ Coal] [+ Iron Ore] [+ Wood]
    (Choose up to 3 items)

  If BLACKLIST:
    [× Copper] [× Miedź]

  If SINGLE:
    [Select: Coal] [Change]

Output Port (sends to conveyor):
  [Same config as input]

  Visual indicator:
    ✓ Green: All items can exit
    ⚠️ Yellow: Some items blocked
    ✗ Red: No items can exit
```

**Action Buttons:**
```
[Empty All] → Move all items to ground (drops items near storage)
[Settings] → Advanced options (upload to cloud, reset, etc)
[Map] → Jump back to grid world
```

### Filtering Interface

**Visual Mode Selection:**
```
┌─────────────────────────────────┐
│ Input Port Filter Mode          │
│ ⊙ Allow all (accepts anything) │
│ ⊙ Whitelist (only these items) │
│ ⊙ Blacklist (none of these)    │
│ ⊙ Single type (only 1 item)    │
└─────────────────────────────────┘
```

**Adding to Whitelist:**
```
[+ Add] → Shows resource picker:
┌──────────────────┐
│ Coal    ✓        │
│ Iron Ore         │
│ Wood    ✓        │
│ Stone            │
│ Copper           │
│ ... (7 total)    │
└──────────────────┘

Select items, [Done] applies
Checkmarks show selected items
```

**Advanced Network Example (3 Storages):**
```
Storage A:
  Global: ACCEPT_ALL
  Input: WHITELIST [Coal, Iron Ore]
  Output: WHITELIST [Coal, Iron Ore] → to Smelter

Storage B:
  Global: ACCEPT_LIST [Żelazo, Miedź Ref., Beton]
  Input: SINGLE [Żelazo]
  Output: ALLOW_ALL → to Workshop

Storage C:
  Global: REJECT_LIST [Coal, Iron Ore]
  Input: WHITELIST [Młotek, Narzędzia]
  Output: SINGLE [Any] → to Farm
```

### Interactions

**Tap Storage Tab:**
```
Switches to selected storage
Updates all displays:
  - Inventory breakdown
  - Filter configuration
  - Current items
```

**Tap Filter Mode:**
```
Shows submenu:
  - ALLOW_ALL (no options)
  - WHITELIST (show resource picker)
  - BLACKLIST (show resource picker)
  - SINGLE (show single resource picker)
```

**Add Resource to Filter:**
```
[+] button → Opens resource picker
Select items (checkmarks)
[Done] → Updates filter
Visual: Chips show selected items
```

**Remove from Filter:**
```
Tap resource chip → [×] Remove
Or swipe left on item → Delete
Immediate update
```

**Empty All:**
```
Long-press [Empty All]
Confirmation dialog:
  "Drop 105 items to ground?"
  [Yes] [Cancel]

Execution:
  - Items placed on ground near storage
  - Animation: Items scatter outward
  - Count decreases
```

### Animations

**On Load:**
```
T=0: Header fades in (200ms)
T=200: Tabs slide in horizontally (250ms)
T=450: Inventory breakdown fades in (200ms)
T=650: Filter sections slide in vertically (300ms, staggered)
T=950: Action buttons appear (150ms)
```

**Filter Changes:**
```
When mode changes:
  - Old options fade out (150ms)
  - New options fade in (150ms)
  - Smooth transition

When item added:
  - Chip appears with scale animation (100ms)
  - +1 on resource count

When filter saved:
  - Confirmation toast: "Filter saved!"
  - Green checkmark animation
```

**Inventory Update:**
```
Real-time updates as items flow:
  - Item count animates (number counter 200ms)
  - Progress bar updates (100/200 → 105/200)
  - Color changes if crossing threshold (yellow ↔ red)
```

**Port Configuration:**
```
Click [Configure Input] → Modal slides up (300ms)
Shows port-specific filters
[Save] → Modal slides down, filter updated
[Cancel] → Closes without saving
```

### Mobile Optimization

**Touch Targets:**
- Storage tabs: 40px high minimum
- [+] buttons: 44px × 44px
- Resource items: 44px × 44px
- Chips (removable): 32px high, 12px wide padding

**Layout Scaling:**
- 375px: Single column, tabs at top
- 480px: Slightly larger components
- 600px+: Two-column layout (inventory left, filters right)
- 1024px: Full tablet layout (3 sections side-by-side)

**Performance:**
- Inventory list: Virtualize (only render visible)
- Filter updates: Debounce to 100ms
- Resource picker: Lazy-render
- 60 FPS animation target

**Accessibility:**
- Clear labels for all inputs
- Haptic feedback on filter changes
- High contrast for port status
- Color-blind safe icons (not color only)

---

## 5. Crafting Queue Screen (Production)

### Purpose

Monitor and manage production in Smelter, Workshop, and automated production chains.

### Layout (Mobile: 375×812)

```
┌────────────────────────────────┐
│ CRAFTING QUEUE                 │
├─ Production Status ────────────┤
│ 3 Buildings Active             │
├────────────────────────────────┤
│ PRODUCTION ITEMS (Vertical)    │
│                                │
│ 🔥 SMELTER #1 (In Progress)   │
│  Recipe: 30C + 30R → Iron     │
│  [████████░░░] 35s / 50s      │
│  Input: ✓ Coal ✓ Ore          │
│  Output: → Storage B           │
│                                │
│ 🔧 WORKSHOP #1 (Queued)       │
│  Recipe: 10 Iron → Hammer     │
│  [░░░░░░░░░░░] Waiting 45s    │
│  Input: Coal waiting           │
│                                │
│ 🏭 FARM #1 (Active)           │
│  Recipe: Item → Gold (80% off) │
│  [██████░░░░░] 12s / 15s      │
│  Processing: Węgiel x8        │
│  Earning: ~24g + 0.5s delay   │
│                                │
├────────────────────────────────┤
│ PRODUCTION RATE                │
│ Output capacity: 2 items/min   │
│ Queue depth: 5 items          │
│ Bottleneck: Iron shortage     │
│                                │
│ ACTIONS                        │
│ [Pause All] [Settings]         │
└────────────────────────────────┘
```

### Components

**Status Header:**
- Number of buildings actively producing
- Total items in all queues
- Estimated completion time for all

**Production Cards (Per Building):**
```
Building type icon + name
Current recipe
Progress bar (time remaining / total time)
Input resources (✓ available or ✗ missing)
Output destination
Current item being crafted
Next item in queue (if any)

Colors:
  🟢 Green: In progress, inputs available
  🟡 Yellow: Queued, waiting for input/output
  🔴 Red: Error (missing input, no output)
```

**Progress Bar Breakdown:**
```
[████████░░░] 35s / 50s (70% complete)

Filled portion: Green (progress)
Remaining: Gray (time left)
Time display: Shows both current and total
Animation: Smooth fill from left to right
```

**Input/Output Display:**
```
Input:
  ✓ Coal (need 30, have 45)
  ✓ Iron Ore (need 30, have 28)

Output:
  → Storage B (destination)

If input missing:
  ✗ Coal (need 30, have 5) [insufficient]
  Shows shortage in red
```

**Production Rate Summary:**
```
Total output capacity: 2 items/min
Current queue depth: 5 items
Bottleneck: Iron shortage (slowing smelter)

Color coding:
  - Green: Bottleneck resolved
  - Yellow: Minor bottleneck
  - Red: Critical shortage
```

### Interactions

**Tap Production Card:**
```
Expands to show full details:
  - Complete recipe details
  - Input item counts
  - Expected duration
  - Output destination

Shows action buttons:
  [Pause] [Cancel] [Settings]
```

**Pause/Resume:**
```
[Pause] on active recipe:
  - Pauses production immediately
  - Holds items in place (doesn't drop)
  - Button changes to [Resume]

[Resume] restarts from where paused
All items preserved
```

**Cancel Recipe:**
```
Long-press recipe card
Confirmation:
  "Cancel Hammer crafting?"
  "Refund inputs? (80%)"

[Yes] → Cancels, refunds 80% of inputs
[No] → Keeps running
```

**Tap Bottleneck Alert:**
```
Shows why production is slow:
  "Iron Ore shortage"
  "Have: 5, Need: 30"

Offers suggestions:
  [Go Gather] → Jump to Biom Screen
  [Trade with NPC] → Jump to Trading Screen
  [Expand Mine] → Jump to Grid World
```

**Scroll Through Queue:**
```
Vertical scroll through all active buildings
See full production chain state
Tap [Production Details] for any building
```

### Animations

**On Load:**
```
T=0: Header fades in (200ms)
T=200: Status cards slide in (250ms, staggered)
T=450: Production items fade in (300ms)
T=750: Progress bars initialize (200ms)
T=950: Action buttons appear (150ms)
```

**Progress Bar Animation:**
```
Continuous smooth fill (real-time)
Updates every 100ms
Color indicators:
  - Green highlight: Active
  - Yellow pulse: Queued
  - Red blink: Error

Completed item:
  - Progress bar → 100%, 200ms pause
  - Next item animates in (scale 0.8 → 1.0)
  - Previous item fades and removes
```

**Bottleneck Alert:**
```
When shortage detected:
  - Red highlight on card (200ms fade-in)
  - Pulsing animation (1s cycle)
  - Notification badge appears

When resolved:
  - Red highlight fades (200ms)
  - Returns to green
```

**Queue Depth Change:**
```
Item added to queue:
  - Card appears at bottom
  - Slide in from bottom (200ms)
  - Stagger if multiple added

Item completes:
  - Progress bar fills (accelerate final 10%)
  - Satisfaction animation (scale bounce)
  - Removed from queue (fade out)
```

### Mobile Optimization

**Touch Targets:**
- Production cards: 60px high minimum, full-width
- [Pause] button: 44px × 44px
- Expand card: 20px swipe threshold

**Layout Scaling:**
- 375px: Full-width cards, vertical scroll
- 480px: Larger fonts, more padding
- 600px+: Two columns (left: production, right: details)
- 1024px: Three-column tablet layout

**Performance:**
- Progress bars: Render at 10 FPS (less critical than game world)
- Card updates: Debounce to 200ms
- Animations: GPU-accelerated
- 30 FPS acceptable (less critical than gameplay)

**Accessibility:**
- Clear status indicators (not color only)
- Haptic feedback on completion
- Audio cues optional (ding sound)
- High contrast progress bars
- Text descriptions for all icons

---

## 6. NPC Trading Screens

### Purpose

Interface for trading with 3 NPC types (Merchant, Engineer, Nomad) with dynamic pricing and offers.

### Screen 6A: NPC Selection

**Layout (Mobile: 375×812):**
```
┌────────────────────────────────┐
│ TRADERS                        │
├─ Choose an NPC ───────────────┤
│                                │
│ ┌──────────────────────────────┐│
│ │ 💰 KUPIEC (Merchant)         ││
│ │ Sells resources for gold     ││
│ │ Dynamic prices (supply/dem.) ││
│ │ [VISIT] →                   ││
│ └──────────────────────────────┘│
│                                │
│ ┌──────────────────────────────┐│
│ │ 🔧 INŻYNIER (Engineer)       ││
│ │ Trades resources (barter)    ││
│ │ 3 fixed offers always avail. ││
│ │ [VISIT] →                   ││
│ └──────────────────────────────┘│
│                                │
│ ┌──────────────────────────────┐│
│ │ 🧑‍🚀 NOMADA (Nomad)           ││
│ │ Limited inventory, special   ││
│ │ Offer changes every 2 hours  ││
│ │ [VISIT] →                   ││
│ └──────────────────────────────┘│
│                                │
│ LAST TRADE                      │
│ Sold 10 Coal to Kupiec: +12g    │
└────────────────────────────────┘
```

**Components:**
- NPC cards (3 traders)
- Each shows name, icon, description, type
- [VISIT] button to open trading dialog
- "Last Trade" summary below

**Interactions:**
- Tap [VISIT] on any NPC card
- Opens trading dialog for that NPC
- Each NPC has own interface (see below)

### Screen 6B: Kupiec Trading (Merchant)

**Layout:**
```
┌────────────────────────────────┐
│ 💰 KUPIEC (Merchant)           │
├─ Sell Resources for Gold ──────┤
│                                │
│ RESOURCE TO SELL               │
│ [Select ▼] Coal               │
│                                │
│ CURRENT PRICE                  │
│ Coal: 1g per item             │
│ Mining bonus: +0g             │
│ Trading skill (Lv3): +0.15g   │
│ ─────────────────────         │
│ FINAL: 1.15g per coal        │
│                                │
│ QUANTITY                       │
│ ← [5] → Have: 45 items        │
│ [Max] button: 45              │
│                                │
│ TOTAL TRADE                    │
│ Sell 5 Coal for 5.75g total  │
│                                │
│ PRICE HISTORY (7-day)          │
│ [Sparkline graph]              │
│ Price trending: ↓ -10%         │
│                                │
│ ACTION                         │
│ [✓ CONFIRM] [Cancel]          │
└────────────────────────────────┘
```

**Components:**

**Resource Selector:**
```
Dropdown showing all resources
Icons + names
Current inventory count
Current price per unit
```

**Price Breakdown:**
```
Base price
+ Mining/gathering bonuses (if applicable)
+ Trading skill bonus (Lv × 5%)
= Final price per unit

Shows each component
Transparent about calculation
```

**Quantity Input:**
```
← [5] → buttons
Type to enter custom amount
[Max] button for max affordable
Shows "Have: 45 items"
```

**Total Trade Preview:**
```
"Sell 5 Coal for 5.75g total"
Updates in real-time as quantity changes
Shows final gold reward
```

**Price Trend Chart:**
```
7-day sparkline graph
Shows price history
Trending up/down indicator
Helps player decide timing
```

**Action Buttons:**
```
[✓ CONFIRM] → Execute trade
[Cancel] → Close dialog
```

### Screen 6C: Inżynier Trading (Engineer - Barter)

**Layout:**
```
┌────────────────────────────────┐
│ 🔧 INŻYNIER (Engineer)         │
├─ Barter Trades ───────────────┤
│                                │
│ OFFER 1: Copper Refining      │
│ ┌──────────────┬──────────────┐│
│ │ Give:        │ Get:         ││
│ │ 5 Coal       │ 1 Refined    ││
│ │ 5 Iron Ore   │ Copper (8g)  ││
│ │ Total: 10g   │              ││
│ │              │ [TRADE]      ││
│ └──────────────┴──────────────┘│
│ Have: ✓ Coal ✓ Iron Ore       │
│                                │
│ OFFER 2: Wood to Stone        │
│ ┌──────────────┬──────────────┐│
│ │ Give:        │ Get:         ││
│ │ 10 Wood      │ 5 Stone      ││
│ │ (15g value)  │ (5g value)   ││
│ │              │ [TRADE]      ││
│ └──────────────┴──────────────┘│
│ Have: ✓ Wood (24/10 needed)    │
│                                │
│ OFFER 3: Copper Exchange      │
│ ┌──────────────┬──────────────┐│
│ │ Give:        │ Get:         ││
│ │ 3 Copper     │ 1 Beton (6g) ││
│ │ (15g value)  │ [Trade]      ││
│ └──────────────┴──────────────┘│
│ Have: ✗ Copper (need 3)        │
│                                │
└────────────────────────────────┘
```

**Components:**

**Barter Offers (3 fixed):**
- Each offer shows: Give → Get
- Icons + resource names
- Quantities needed
- Value comparison (can see cost vs benefit)
- [TRADE] button per offer

**Resource Availability:**
```
✓ Have: Coal (5/5 needed)
✗ Have: Copper (0/3 needed)

Green checkmark: Can trade
Red X: Missing resources
```

**Trade Animation:**
```
When [TRADE] tapped:
1. Resources disappear from inventory (animation)
2. New resources appear (scale in)
3. "Trade successful!" toast
4. Dialog closes or refreshes
```

### Screen 6D: Nomada Trading (Nomad - Special Offers)

**Layout:**
```
┌────────────────────────────────┐
│ 🧑‍🚀 NOMADA (Nomad)               │
├─ Limited Time Offers ─────────┤
│ Refresh in: 47 minutes ⏱      │
│                                │
│ OFFER 1: Coal Bundle         │
│ ┌──────────────────────────────┐│
│ │ 50 Coal                      ││
│ │ For: 75g                     ││
│ │ Normal: 50g → YOU SAVE 50% ! ││
│ │                              ││
│ │ ⭐⭐⭐ (3 stars)            ││
│ │ [BUY] - First offer free    ││
│ └──────────────────────────────┘│
│                                │
│ OFFER 2: Smelting Bundle     │
│ ┌──────────────────────────────┐│
│ │ 20 Iron Ore + 10 Coal       ││
│ │ For: 80g                     ││
│ │ Normal: 60g → Normal price  ││
│ │                              ││
│ │ ⭐⭐ (2 stars)             ││
│ │ [BUY] - 100g fee           ││
│ └──────────────────────────────┘│
│                                │
│ OFFER 3: Copper Steal        │
│ ┌──────────────────────────────┐│
│ │ 1 Refined Copper            ││
│ │ For: 5g (!!)                 ││
│ │ Normal: 8g → 37% DISCOUNT   ││
│ │                              ││
│ │ ⭐⭐⭐⭐⭐ (5 stars!)     ││
│ │ [BUY] - 100g fee           ││
│ └──────────────────────────────┘│
│                                │
│ STATUS                         │
│ Gold: 327g available           │
│ Can afford: All 3 offers ✓     │
└────────────────────────────────┘
```

**Components:**

**Limited Time Header:**
- Shows countdown: "Refresh in: 47 minutes"
- Emphasizes time pressure
- Next refresh time shown

**Offer Cards (3 items):**
```
Per offer:
├─ Item name and description
├─ Quantity + cost
├─ "Normal price" comparison
├─ Discount percentage (if any)
├─ Star rating (quality indicator)
├─ [BUY] button
└─ Fee note (if not first offer)
```

**Discount Highlight:**
- Exceptional deals shown in red ("STEAL!")
- Savings clearly visible
- Star rating suggests player favorites

**Purchase Rules:**
- First offer: FREE (1 free trade per nomad visit)
- Subsequent offers: 100g fee each
- Shows current gold: "327g available"
- Indicates if can afford

**Interactions:**

**Tap [BUY]:**
```
If first offer:
  "Buy [item]? (No fee)"
  [Confirm] [Cancel]

If not first offer:
  "Buy [item]? (100g fee)"
  "After fee: 227g remaining"
  [Confirm] [Cancel]

On confirm:
  Resources added to inventory
  Gold subtracted
  Offer marked as "Purchased"
  Animation: Resources appear with glow
```

**After Purchase:**
```
Button changes to [SOLD]
Item grayed out
Can still view but can't rebuy
(Offer refreshes when nomad's inventory resets)
```

---

## 7. Notification & Warning System

### Overview

Hierarchical notification system with 4 levels: Toasts, Banners, Modals, Full-screen alerts. Designed for non-intrusive feedback with clear visual hierarchy and accessibility.

### Notification Types & Hierarchy

**LEVEL 1: TOAST (Non-blocking)**
- Brief, auto-dismiss messages
- Position: Top of screen
- Duration: 2-3 seconds
- Animation: Slide in from top (300ms), fade out (300ms)
- Stacking: Max 3 visible, queue overflow
- Interaction: Tap to dismiss early

**LEVEL 2: BANNER (Persistent)**
- Important but non-critical
- Position: Below header (sticky)
- Duration: Until dismissed by user
- Must tap [×] to close
- Multiple banners possible (up to 3)
- Contains action buttons ([BUILD MORE], [HELP])

**LEVEL 3: MODAL (Blocking)**
- Critical or requires decision
- Position: Center of screen
- Overlay: Semi-transparent black (40% opacity)
- Duration: Until action taken
- Animation: Slide up from bottom (300ms)
- Options: Multiple buttons ([YES], [CANCEL], [DETAILS])

**LEVEL 4: FULL SCREEN (Critical)**
- Game-stopping alerts
- Entire viewport covered
- Position: Center, large text
- Duration: Until critical action
- Sound: Alarm/warning
- Example: Game crash recovery, critical errors

### Toast Notifications (Non-blocking)

**4 Toast Types:**

**Type 1: SUCCESS (Green #4CAF50)**
- Icon: ✓ Checkmark
- Sound: Positive "ding!"
- Duration: 2 seconds
- Triggers: Craft complete, item collected, trade accepted, building placed, skill level up

**Type 2: INFO (Blue #2196F3)**
- Icon: ℹ Info circle
- Sound: Neutral chime
- Duration: 3 seconds
- Triggers: New offer, skill level up, building unlock, discovery, milestone

**Type 3: WARNING (Orange #FF9800)**
- Icon: ⚠ Warning triangle
- Sound: Medium beep
- Duration: 4 seconds
- Triggers: Storage near capacity, conveyor backed up, building waiting, event expiring, resource scarcity

**Type 4: ERROR (Red #F44336)**
- Icon: ✗ X mark
- Sound: Error buzz
- Duration: 4+ seconds (persistent)
- Triggers: Can't craft (missing resources), insufficient items, action blocked, critical issue

**Toast Animation Details:**

```
Entrance (300ms):
  ├─ Slide from Y=0 to Y=370px
  ├─ Opacity: 0 → 1 (fade in)
  └─ Easing: ease-out

Display duration:
  ├─ 1-2 words: 2 seconds
  ├─ 3-5 words: 3 seconds
  ├─ 6+ words: 4 seconds
  └─ User can dismiss: Tap anywhere

Exit (300ms):
  ├─ Fade out: 1 → 0 (opacity)
  ├─ Slide up: -20px position
  └─ Easing: ease-in

Stacking:
  ├─ Multiple toasts: Stack vertically
  ├─ Max visible: 3
  ├─ If 4th arrives: Oldest dismisses
  └─ New enters at top
```

**Toast Examples in Gameplay:**

Gathering scenario:
```
1. Tap gather button
2. Toast: "Gathering węgiel..." (1s)
3. Wait 1.25s (progress bar)
4. Toast: "✓ +1 węgiel added!" (green, 2s)
5. Inventory updates: 45 → 46
```

Crafting scenario:
```
1. Start żelazo craft
2. Toast: "ℹ Craft started (50s)" (blue, 3s)
3. After 50s...
4. Toast: "✓ 1 żelazo ready!" (green, 2s)
5. Item exits smelter
```

Trading scenario:
```
1. Accept Kupiec offer
2. Toast: "Calculating..." (blue, transient)
3. Toast: "✓ Sold 15 węgiel for 18g!" (green, 2s)
4. Gold counter animates +18
```

### Banner Notifications (Persistent)

**Visual Appearance:**
- Height: 60px
- Position: Below header (sticky)
- Background: Type-specific color
- Close button: [×] top right
- Action buttons: Up to 2 buttons

**Banner Types:**

**Storage Warning Banner:**
```
┌──────────────────────────────────┐
│ 📦 Storage Warning               │
├──────────────────────────────────┤
│ "Storage #1 is 95% full!"       │
│ "145/200 items (95%)"           │
│                                  │
│ [BUILD STORAGE] [CLEAR ITEMS]   │
│ [×] (dismiss)                   │
└──────────────────────────────────┘

Appears: Storage reaches 90% capacity
Color: Orange (#FF9800)
Auto-dismiss: No (user must close)
Stacking: Can have multiple banners
```

**Bottleneck/Error Banners:**
```
┌──────────────────────────────────┐
│ ⚠️ Bottleneck Detected           │
├──────────────────────────────────┤
│ "Conveyor backed up → Storage"   │
│ "5 items waiting to enter!"      │
│                                  │
│ [GO TO PROBLEM] [HELP]           │
└──────────────────────────────────┘

Color: Orange/Red (varies by severity)
Appears: Conveyor has 8+ items, destination full
Duration: Until resolved + user dismisses
```

**Event Banner:**
```
┌──────────────────────────────────┐
│ ⚡ Special Event!                │
├──────────────────────────────────┤
│ "Żyła miedzi w Górach!"         │
│ "+2x mining speed (15s remaining)"│
│                                  │
│ [GO TO GÓRY] [DISMISS]          │
└──────────────────────────────────┘

Color: Gold (#FFD700)
Auto-dismiss: When event ends
Duration: Time-sensitive
```

**Animation:**
```
Slide down from top (300ms)
Stays until user dismisses or auto-expires
Fade out: 300ms
Can stack: Up to 3 banners
```

### Modal Dialogs (Blocking)

**Modal Components:**
- Overlay: Semi-transparent black (40% opacity)
- Card: White, rounded (12px), centered
- Shadow: Strong elevation
- Animation: Slide up from bottom (300ms)
- Close: Tap [CANCEL] or outside

**Confirmation Modal:**
```
┌─────────────────────────────────┐
│ 🤔 CONFIRM ACTION              │
├─────────────────────────────────┤
│                                 │
│ "Delete this building?"         │
│ "Storage #1 (2x2)"              │
│ "Contains: 45 items"            │
│                                 │
│ Refund: 4D + 8K (80%)           │
│ Lost: 1D + 2K (20%)             │
│ Items: Dropped on ground        │
│                                 │
│ Are you sure?                   │
│                                 │
│ [YES, DELETE] [CANCEL]         │
└─────────────────────────────────┘
```

**Choice Modal (Resource Picker):**
```
Mode selector with dropdowns
Checkboxes for resource selection
Real-time preview of changes
[APPLY] [CANCEL] buttons
Scrollable if many options
```

**Information Modal (Offline Return):**
```
┌─────────────────────────────────┐
│ ℹ️ OFFLINE PRODUCTION           │
├─────────────────────────────────┤
│ 🎉 Welcome back!               │
│ Away for: 1 hour 23 minutes    │
│                                 │
│ Farm production:                │
│ ├─ Items processed: 576/720    │
│ ├─ Gold earned: 3,168 zł       │
│ ├─ Efficiency: 80%             │
│ └─ Average: 38 zł/minute       │
│                                 │
│ [CONTINUE] [VIEW DETAILS]      │
└─────────────────────────────────┘

Info-only (no scary decisions)
Scrollable if content long
Animation: Fade in (300ms)
```

### Sound Design

**Success sound:** "Ding!" (800Hz, 300ms, uplifting)
- Use: Craft complete, items added, positive events

**Warning sound:** "Beep" (600Hz, 200ms, alert tone)
- Use: Storage full, bottleneck, issues

**Error sound:** "Buzz" (400Hz, 300ms, wrong tone)
- Use: Can't craft, action blocked, errors

**Info chime:** Musical "Chime" (multiple notes, 500ms)
- Use: New offers, discoveries, milestones

**Notification entrance:** Subtle "whoosh" (100ms, background)
- Use: Toast/banner appears

**All sounds:**
- Can be muted via settings
- Respect device sound settings
- Optional haptic feedback (vibration)
- No annoying loops

### Accessibility

**Screen readers:** All notifications announced, toast text read aloud, important info vocalized

**Visual alternatives:** Colors + icons + text always combined, high contrast maintained, text 14px+

**Haptic feedback:** Vibration on alerts, patterns indicate severity, can be disabled

**Color-blind safe:** Icons + labels, not color only, high contrast

---

## 8. Building Detail Panel

### Overview

Detailed configuration panel for individual buildings showing status, ports, flows, optimization tips, and maintenance options.

### Layout Components

**Header (sticky, 40px):**
- Back arrow [←]
- Building name + icon (📦 STORAGE #1)
- Settings [⚙️] and close [X] buttons

**Sections (scrollable):**
1. Basic Info (building type, location, status)
2. Capacity/Production Details (specific to building)
3. Port Configuration (4 ports with live status)
4. Active Flows (real-time item movement)
5. Optimization Tips (AI suggestions)
6. Maintenance Options (upgrade, move, demolish)
7. Bottom Actions (GO TO MAP, BACK, HELP)

### Universal Building Details

**Basic Info:**
- Building icon (64×64px)
- Type and size: "STORAGE (2×2 grid)"
- Location: "Grid (15, 8)"
- Status: Color indicator (✓ operational, ⚠ waiting, ✗ error)

**Port Configuration (Per Building):**
- Up to 4 ports (N, S, E, W)
- Port type: INPUT or OUTPUT
- Status light: 🟢 (active) / 🟡 (waiting) / 🔴 (blocked)
- Filter: "WHITE-LIST [items]"
- Destination/Source: "Storage #1"
- Live flow: "15 items/min flowing"
- Buttons: [EDIT], [NAVIGATE], [DISCONNECT]

**Active Flows (Real-time):**
- Input flows: Source → storage
- Output flows: Storage → destination (per port)
- Visual progress bar: ▓▓▓░░░░░
- Rate: "20 items/min"
- Status: Flowing normally / Waiting / Blocked

**Optimization Tips:**
- AI-generated suggestions based on state
- Issue detection: "West port blocked"
- Fix suggestions: "Clear some items" or "Build Storage #3"
- Efficiency rating: "Good (72% usage)"

**Maintenance Options:**
- [UPGRADE] - Increase capacity/speed
- [MOVE] - Relocate building
- [DEMOLISH] - Remove and refund 80%
- Future: [MONITOR], [AUTOMATE], [BACKUP]

### Building-Specific Details

**MINING FACILITY:**
- Current resource: "Węgiel"
- Base rate: "1.25 sec/item"
- Skill bonus: "Level 3 (-15%)"
- Actual rate: "1.06 sec/item"
- Production: "~57 items/min"
- Output buffer: "5/10 items"
- Biom: Shows available resources in this location
- Active events: "No events / Żyła miedzi upcoming"

**STORAGE:**
- Capacity: "145/200 items (72%)"
- Progress bar: Visual fill indicator
- Item breakdown: Bar chart per resource
- Free space: "55 slots (39%)"
- 4-port configuration: NORTH/SOUTH/EAST/WEST
- Per-port filters: Mode + selected items
- Current flows: Input + output with rates

**SMELTER:**
- Current craft: "Żelazo"
- Progress: "▓▓▓▓▓░░░░ 50% (25s / 50s)"
- Ingredients: "30 węgiel + 30 ruda żelaza"
- Input ports: NORTH (fuel), EAST (ingredients)
- Output port: SOUTH (products)
- Available recipes: List with times
- Skill effects: "Level 4 (-20% = 40s)"
- Queue recipes: Next items to craft (Phase 2)

**WORKSHOP:**
- Active craft: "Młotek"
- Status: "⏳ GATHERING INGREDIENTS"
- Progress: "▓▓▓░░░░░ 30% (3/10 gathered)"
- Ingredients needed: List with have/need
- ETA: When complete (gathering + craft time)
- Queued recipes: 5 pending items
- Input ports: NORTH (primary), EAST (secondary)
- Skill effects: Shows time savings per craft
- Queue management: Add/remove/reorder recipes

**FARM:**
- Gold earned: "4,580 zł today"
- Average rate: "48 zł/minute"
- Current processing: "45 items in queue"
- Item value breakdown: With skill multiplier
- Input port: "NORTH - accepts all items"
- Buffer: "45/50 items"
- Optimization: "Send high-value items (miedź, sól)"
- Offline earnings: "Estimate per hour/8 hours"

### Interactions

**Tap [EDIT] on port:**
- Opens port configuration modal
- Change mode: INPUT/OUTPUT/DISABLED
- Change filter: WHITE-LIST / BLACK-LIST / ACCEPT ALL / SINGLE
- Select items (checkboxes)
- Real-time preview
- [APPLY] updates immediately

**Tap [NAVIGATE]:**
- Pan map to destination building
- Highlight building (glow effect)
- Show connection line (conveyor path)
- Allow routing optimization

**Tap [DISCONNECT]:**
- Confirmation: "Disconnect this port?"
- Effect: Port becomes unused
- Items back up if source still flowing
- Can reconnect later

**Tap [CHANGE RECIPE] (Smelter/Workshop):**
- Recipe selector modal
- Show available recipes + requirements
- Tap to switch
- Current craft stops (returns items)
- New recipe starts

**Tap efficiency metrics:**
- Detailed breakdown modal
- Bottleneck analysis
- Improvement suggestions
- Learning tooltips

### Visual Design

**Status indicators:**
- 🟢 Green: Operational, producing
- 🟡 Yellow: Waiting, issue, not optimal
- 🔴 Red: Error, paused, broken
- Size: 24×24px (clear visibility)

**Progress bars:**
- Height: 12px
- Color: Blue (normal) → Red (full/error)
- Animation: Smooth updates
- Text overlay: Percentage or time

**Port cards:**
- Background: White
- Border: 1px light gray
- Highlight: Blue if connected
- Icons: Directional arrows (↑ ↓ ← →)

**Section headers:**
- Font: 16px bold (#333)
- Divider: Light gray line
- Spacing: 12px above, 8px below

### Mobile Optimization

**Viewport:** 375×667px
- Header: Fixed (40px)
- Content: Scrollable
- Actions: Bottom sticky (60px)
- Usable: ~567px height

**Panel width:** Full (375px), padding 16px = 343px usable

**Touch targets:** All buttons 44×44px minimum

**Text sizing:**
- Headers: 16px bold
- Details: 14px regular
- Small text: 12px
- Minimum: 12px (readable)

**Performance:**
- Load: <500ms
- Animations: 60 FPS
- Memory: <10MB per panel
- Smooth scrolling

### Advanced Features (Phase 2)

**Auto-optimization:**
- AI analyzes network
- "Add splitter here?"
- "Bottleneck detected"
- Smart recommendations

**Monitoring dashboard:**
- Real-time metrics
- Flow rate tracking
- Efficiency scoring
- Performance graphs

**Historical data:**
- Items processed: Lifetime
- Gold earned: Per hour/day
- Downtime tracking
- Exportable reports

**Custom alerts:**
- "Alert if full > 95%"
- "Alert if stopped > 60s"
- Smart thresholds

**Multi-building view (Phase 2):**
- Compare buildings
- Parallel stats
- Overall efficiency
- Optimization suggestions

---

## Cross-Screen Navigation

**Navigation Map:**
```
HUB SCREEN (center)
  ├→ [🗺 Map] → GRID WORLD SCREEN
  │    ├→ [Biom Gathering] → BIOM SCREEN
  │    ├→ [Storage] → STORAGE MGMT SCREEN
  │    └→ [Crafting] → CRAFTING QUEUE SCREEN
  │
  ├→ [🎯 Gather] → BIOM GATHERING SCREEN
  │    ├→ [Map] → GRID WORLD SCREEN
  │    └→ [Storage] → STORAGE MGMT SCREEN
  │
  ├→ [⚙ Craft] → CRAFTING QUEUE SCREEN
  │    ├→ [Storage] → STORAGE MGMT SCREEN
  │    └→ [Map] → GRID WORLD SCREEN
  │
  └→ [💰 Trade] → NPC SELECTION SCREEN
       ├→ [Kupiec] → MERCHANT TRADING
       ├→ [Inżynier] → ENGINEER TRADING
       └→ [Nomada] → NOMAD TRADING

Back buttons available from all screens
```

---

## Universal Design Patterns

**Loading States:**
```
While fetching data:
  - Skeleton screens (grayed placeholders)
  - Pulse animation
  - No interaction until loaded
  - Timeout after 5s (fallback UI)
```

**Error States:**
```
Connection lost:
  - Red banner: "Connection lost - retrying..."
  - Graceful degradation (show cached data)
  - Retry button visible

Invalid operation:
  - Toast notification (bottom, 3s)
  - Error message + suggestion
  - Optional [Learn More] link
```

**Success Feedback:**
```
Action completed:
  - Toast notification (top, 2s)
  - Haptic feedback (vibration)
  - Optional sound (clink for gold, etc)
  - Brief animation (scale + fade)
```

**Gestures (consistent across all screens):**
```
Tap: Select, open, toggle
Tap & hold (500ms): Context menu, confirmation
Swipe left/right: Navigate between sections/items
Swipe up/down: Scroll, access hidden menus
Pinch zoom: Zoom (grid world only)
Double-tap: Open details (rapid)
Long-press (2s): Delete, destructive actions
```

---

## Responsive Breakpoints

**Mobile (375-480px):**
- Single column layouts
- Full-width components
- Bottom navigation
- Vertical scrolling

**Tablet (600-1024px):**
- 2-column layouts possible
- Side panels
- Larger touch targets (56px)
- Optimized for landscape

**Desktop (1024px+):**
- 3-column layouts
- Multiple windows possible
- Keyboard shortcuts
- Hover states available

---

**Status:** ✅ Complete
**Last Updated:** 2025-12-03
**Version:** 1.0 (6 complete screens, fully specified)
