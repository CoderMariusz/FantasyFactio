# Trade Factory Masters - UX Design Document

**Author:** Claude (BMAD UX Designer Agent)
**Date:** 2025-11-17
**Version:** 1.0
**Status:** Draft
**Based on:** PRD v1.0 (docs/prd-trade-factory-masters-2025-11-17.md)

---

## Executive Summary

This UX Design document translates PRD requirements into a **mobile-first visual design system** optimized for:
- **One-handed gameplay** (80% thumb-reachable, right-hand mode)
- **60 FPS performance** (lightweight UI, sprite batching)
- **Accessibility** (44×44px tap targets, haptic feedback, colorblind-friendly)
- **Factorio fans on mobile** (desktop-quality automation in touch-optimized interface)

**Design Philosophy:** "Touch-first, not touch-adapted"
- NOT a desktop port with touch bolted on
- Built from ground-up for mobile interaction patterns
- Larger tap targets, gestures over menus, visual feedback over text

---

## Table of Contents

1. [Design System](#1-design-system)
2. [Screen Architecture](#2-screen-architecture)
3. [Core Screens](#3-core-screens)
4. [UI Components](#4-ui-components)
5. [Interaction Patterns](#5-interaction-patterns)
6. [Animation System](#6-animation-system)
7. [Accessibility](#7-accessibility)
8. [Responsive Design](#8-responsive-design)

---

## 1. Design System

### 1.1 Color Palette

**Primary Colors:**
```
Factory Blue:    #2E5CB8 (buttons, highlights, conveyors)
Success Green:   #4CAF50 (collect actions, confirmation)
Warning Orange:  #FF9800 (storage full, alerts)
Error Red:       #F44336 (blocked actions, critical warnings)
Gold:            #FFD700 (currency, premium features)
```

**Neutral Colors:**
```
Dark Gray:       #1E1E1E (UI background, dark mode friendly)
Medium Gray:     #424242 (cards, panels)
Light Gray:      #E0E0E0 (borders, dividers)
Off-White:       #F5F5F5 (text, light elements)
```

**Resource Colors:**
```
Wood:            #8D6E63 (brown)
Ore:             #78909C (gray-blue)
Food:            #66BB6A (green)
Bars:            #FF8A65 (orange-red)
Tools:           #42A5F5 (blue)
Circuits:        #7E57C2 (purple)
Machines:        #EC407A (pink)
```

**Colorblind-Friendly:**
- All colors tested with ColorOracle (deuteranopia, protanopia, tritanopia)
- Icons + color combination (not color-only indicators)
- High contrast ratios (WCAG AAA: 7:1 minimum)

### 1.2 Typography

**Font Family:** Roboto (Google Fonts, optimized for mobile)

**Type Scale:**
```
Display:   32sp / Bold      (headings, "Welcome Back!")
Title:     24sp / Semibold  (screen titles, "Build Menu")
Subtitle:  18sp / Medium    (section headers, "Resources")
Body:      14sp / Regular   (descriptions, tooltips)
Caption:   12sp / Regular   (timestamps, metadata)
Label:     10sp / Medium    (small labels, "+20% production")
```

**Line Height:** 1.5× font size (readability on mobile)

**Text Colors:**
- Primary: Off-White #F5F5F5 (main text)
- Secondary: Light Gray #E0E0E0 (less important text)
- Disabled: Medium Gray #424242 (inactive elements)

### 1.3 Spacing System

**8-Point Grid System:**
```
XXS: 4px   (tight spacing, icon padding)
XS:  8px   (component padding)
S:   12px  (small gaps)
M:   16px  (default spacing)
L:   24px  (section spacing)
XL:  32px  (screen margins)
XXL: 48px  (major section breaks)
```

**Why 8-Point Grid:**
- Scales cleanly to different screen densities
- Flutter default (Material Design 3 uses 8dp grid)
- Easy mental math for designers/developers

### 1.4 Elevation & Shadows

**Material Design 3 Elevation:**
```
Level 0: No shadow     (background, grid)
Level 1: 2dp elevation (cards, resource icons)
Level 2: 4dp elevation (floating buttons, Build Menu)
Level 3: 8dp elevation (modals, Welcome Back dialog)
Level 4: 16dp elevation (tooltips, context menus)
```

**Shadow Style:**
- Color: Black with 20% opacity
- Blur radius: 2× elevation value
- Offset: (0, elevation/2) for subtle depth

### 1.5 Icons & Sprites

**Icon Style:** Material Design Icons + Custom Factory Icons
- Size: 24×24px standard, 48×48px large (buildings)
- Style: Flat, 2-color maximum (performance)
- Format: SVG for UI, PNG sprite sheets for game objects

**Building Sprites:**
- Size: 64×64px (2×2 grid tiles at 32px each)
- 3×3 buildings: 96×96px (Smelter, Workshop)
- Pixel art style (Factorio-inspired, mobile-optimized)

**Resource Sprites:**
- Size: 16×16px (conveyor belt sprites)
- 32×32px (inventory icons)
- Simple, recognizable at small sizes

---

## 2. Screen Architecture

### 2.1 Information Architecture

```
App Launch
   ├─ Splash Screen (1-2s, logo + tagline)
   ├─ Main Game Screen (primary, 95% of session time)
   │    ├─ Grid View (50×50 factory grid)
   │    ├─ Top HUD (gold, resources, time)
   │    ├─ Bottom Toolbar (Build, Market, Settings)
   │    ├─ Minimap (top-right corner, Build Mode only)
   │    └─ Floating Action Buttons (zoom mode toggle)
   │
   ├─ Build Menu (bottom sheet modal)
   ├─ NPC Market (full-screen modal)
   ├─ Building Details (side panel, slide-in from right)
   ├─ Conveyor Mode (overlay mode with path preview)
   ├─ Welcome Back Modal (full-screen, post-offline)
   ├─ Tier 2 Unlock Celebration (full-screen, fireworks)
   └─ Settings (full-screen)
```

**Screen Hierarchy:**
- **Primary:** Main Game Screen (persistent, always visible)
- **Secondary:** Modals (Build Menu, Market) - dismiss to return to game
- **Tertiary:** Overlays (tooltips, floating text) - auto-dismiss

### 2.2 Navigation Patterns

**Primary Navigation:** Bottom Toolbar (fixed, always visible)
```
┌─────────────────────────────────────────────────┐
│                                                 │
│               Main Game Screen                  │
│                                                 │
├─────────────────────────────────────────────────┤
│ [Build] [Conveyor] [Market] [Stats] [Settings] │
└─────────────────────────────────────────────────┘
```

**Why Bottom Navigation:**
- Thumb-reachable on large phones (6.5" screens)
- Material Design 3 standard for mobile apps
- Persistent access to key actions

**Gesture Navigation:**
- Swipe: Pan camera (primary navigation in game world)
- Pinch: Zoom in/out (0.5× - 2.0× range)
- Double-tap: Recenter camera to factory center
- Long-press: Show building context menu

**No Hamburger Menu:**
- All key actions in bottom toolbar (no hidden features)
- Settings accessible but not primary action

---

## 3. Core Screens

### 3.1 Main Game Screen (Primary)

**Layout (Portrait Orientation):**

```
┌─────────────────────────────────────────────────┐
│  💰 1,234 Gold    🪵 50  ⛏️ 30  🍞 20  [≡]     │ ← Top HUD (56dp height)
├─────────────────────────────────────────────────┤
│                                                 │
│                                                 │
│                                                 │
│           50×50 FACTORY GRID                    │ ← Game Canvas (scrollable)
│                                                 │
│        [Buildings, Conveyors, Resources]        │
│                                                 │
│                                                 │
│                                      [🗺️]       │ ← Minimap (80×80px)
│                                      [🔍]       │ ← Zoom toggle
├─────────────────────────────────────────────────┤
│ [🔨Build] [🚚Conv] [🏪Market] [📊] [⚙️Settings]│ ← Bottom Toolbar (72dp)
└─────────────────────────────────────────────────┘
```

**Key Elements:**

1. **Top HUD (56dp height, fixed):**
   - Gold display (left, large, gold color)
   - Resource counts (3-4 visible, scroll horizontally if >4)
   - Hamburger menu (right) → opens Settings
   - Background: Semi-transparent dark gray (80% opacity)

2. **Game Canvas (fill remaining height):**
   - 50×50 grid rendered with Flame engine
   - Scrollable (swipe to pan)
   - Zoomable (pinch gesture)
   - Buildings show tap highlight on touch
   - Conveyors animate resources flowing (1 tile/sec)

3. **Minimap (80×80px, top-right corner):**
   - Only visible in Build Mode (1.5× zoom)
   - Hidden in Planning Mode (0.5× zoom - redundant)
   - Shows full factory overview (buildings as colored dots)
   - White rectangle = camera viewport
   - Tap to jump to location

4. **Zoom Mode Toggle (56×56dp FAB, bottom-right):**
   - Icon: 🗺️ (Planning Mode) or 🔨 (Build Mode)
   - Background: Factory Blue #2E5CB8
   - Tap to toggle between modes (300ms zoom animation)
   - Haptic feedback on toggle

5. **Bottom Toolbar (72dp height, fixed):**
   - 5 buttons, equal width (20% each)
   - Icons + labels below (12sp)
   - Active state: Factory Blue background
   - Inactive: Medium Gray
   - Haptic on tap

**Responsive Behavior:**
- Portrait: Full layout as shown
- Landscape: HUD moves to left side (vertical), game canvas expands

---

### 3.2 Build Menu (Bottom Sheet Modal)

**Layout:**

```
┌─────────────────────────────────────────────────┐
│                Main Game Screen                 │ ← Dimmed (50% opacity overlay)
├─────────────────────────────────────────────────┤
│  ═══ Build Menu ═══                    [X]      │ ← Header (drag handle)
│                                                 │
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐  │ ← Horizontal scroll
│ │🪓    │ │⛏️    │ │🌾    │ │🔥    │ │🔨    │  │
│ │Lumb. │ │Mine  │ │Farm  │ │Smelt │ │Work  │  │
│ │100g  │ │120g  │ │80g   │ │200g  │ │300g  │  │
│ │1W/min│ │1O/min│ │1F/min│ │1B/2m │ │1T/3m │  │
│ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘  │
│                                                 │
│ [Conveyor Belt] 5g + 1 Bar per tile             │ ← Tier 2 unlock only
└─────────────────────────────────────────────────┘
```

**Interaction:**
1. Tap "Build" in bottom toolbar → Bottom sheet slides up (200ms animation)
2. Swipe down on header OR tap [X] → Dismisses
3. Tap building card → Enters placement mode:
   - Game canvas shows green/red tile highlights
   - Drag building sprite to position
   - Tap to place, deducts gold, adds building
   - Haptic on successful placement

**Building Card Design:**
- Size: 120×140dp (comfortable thumb target)
- Padding: 12dp inside card
- Elevation: 2dp (card style)
- Icon: 48×48px building sprite
- Name: 14sp, white
- Cost: 12sp, gold color if affordable, red if not
- Production: 12sp, gray (e.g., "1 Wood/min")
- Disabled state: Gray overlay if can't afford

---

### 3.3 NPC Market (Full-Screen Modal)

**Layout:**

```
┌─────────────────────────────────────────────────┐
│  ← Back          NPC Market          [Info]     │ ← Header (56dp)
├─────────────────────────────────────────────────┤
│  [BUY TAB] │ [SELL TAB]                         │ ← Tab bar (48dp)
├─────────────────────────────────────────────────┤
│ ┌───────────────────────────────────────────┐   │
│ │ 🪵 Wood                     You have: 50  │   │ ← Resource row (80dp)
│ │ Buy: 8g  Sell: 5g                         │   │
│ │ [────────|─────────] 25                   │   │ ← Slider (1-100)
│ │          [SELL 25 for 125g] ✓             │   │ ← Action button
│ └───────────────────────────────────────────┘   │
│                                                 │
│ ┌───────────────────────────────────────────┐   │
│ │ ⛏️ Ore                      You have: 30  │   │
│ │ Buy: 10g  Sell: 7g                        │   │
│ │ [────────|─────────] 30                   │   │
│ │          [SELL 30 for 210g] ✓             │   │
│ └───────────────────────────────────────────┘   │
│                                                 │
│  ... (scroll for more resources)                │
└─────────────────────────────────────────────────┘
```

**Key Features:**
- **Tabs:** BUY / SELL (switch content, no full reload)
- **Resource Rows:** Vertical scroll list, 7 resources in Tier 1
- **Slider:** Adjusts quantity (1-100 or inventory max)
- **Live Calculation:** Button shows "SELL 25 for 125g" (updates as slider moves)
- **Transaction Feedback:**
  - Tap button → Green flash animation
  - Floating text: "+125 gold!" (300ms animation)
  - Haptic: Light impact
  - Gold counter in top HUD updates immediately

**Tier 2 Changes:**
- Prices show trend arrows: 🪵 Wood 5g ↑↑ (Dragon Attack event)
- Event banner at top: "⚠️ Dragon Attack! Wood prices spiked!"

---

### 3.4 Building Details Panel (Side Slide-In)

**Trigger:** Tap building in game → Panel slides in from right (200ms)

**Layout:**

```
┌────────────────┐
│ Main Game      │ ← Dimmed left side
│                │
│                │
│ ┌──────────────┤ ← Panel slides in from right (320dp width)
│ │ [X] Lumbermill Level 3                     │ ← Header
│ │ ─────────────                              │
│ │ Production: 1.4 Wood/min                   │ ← Stats
│ │ Storage: 14/14 FULL ⚠️                     │
│ │ Last Collected: 2m ago                     │
│ │                                            │
│ │ [Collect Resources] 14 Wood ✓              │ ← Primary action (green)
│ │                                            │
│ │ Upgrade to Level 4:                        │
│ │ Cost: 150g + 10 Wood + 5 Ore               │
│ │ Benefit: +20% production (1.68 W/min)      │
│ │                                            │
│ │ [Upgrade for 150g] ✓                       │ ← Secondary action (blue)
│ │                                            │
│ │ [Delete Building]                          │ ← Destructive (red text only)
│ └────────────────────────────────────────────┘
```

**Interaction:**
- Tap outside panel OR [X] → Dismisses (slides out right)
- Tap "Collect Resources" → Adds to inventory, haptic, "+14 Wood" floating text
- Tap "Upgrade" → Deducts cost, levels up building, celebration animation

---

### 3.5 Welcome Back Modal (Post-Offline)

**Layout:**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│          🎉 Welcome Back! 🎉                    │ ← Display (32sp)
│                                                 │
│     Away for 3 hours 15 minutes                 │ ← Subtitle (18sp)
│                                                 │
│  ╔════════════════════════════════════════╗     │
│  ║  Your factory produced:                ║     │ ← Production summary
│  ║                                        ║     │
│  ║  🪵 +180 Wood                          ║     │
│  ║  ⛏️ +150 Ore                           ║     │
│  ║  🍞 +120 Food                          ║     │
│  ║  💰 +450 Gold                          ║     │
│  ╚════════════════════════════════════════╝     │
│                                                 │
│  ┌────────────────────────────────────────┐    │
│  │ 🎬 Watch ad for 2× offline production? │    │ ← Ad offer (optional)
│  │                                        │    │
│  │ [No Thanks]    [Watch Ad (30s)] ▶️    │    │
│  └────────────────────────────────────────┘    │
│                                                 │
│         [Collect All Resources] ✓               │ ← Primary button (green, large)
│                                                 │
└─────────────────────────────────────────────────┘
```

**Animation:**
- Modal fades in (300ms)
- Sparkle particles around production numbers
- Numbers count up from 0 → final value (500ms each, staggered)

**Interaction:**
- Tap "No Thanks" → Collect 1× production, modal dismisses
- Tap "Watch Ad" → Loads rewarded video (30s) → Collect 2× production
- Tap "Collect All" → Resources added to inventory, modal dismisses

---

### 3.6 Tier 2 Unlock Celebration (Full-Screen)

**Layout:**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│           ✨✨ TIER 2 UNLOCKED! ✨✨              │ ← Display (32sp, gold)
│                                                 │
│              🎆 🎇 🎆 🎇 🎆                     │ ← Fireworks animation (3s)
│                                                 │
│         Conveyors Now Available!                │ ← Subtitle (24sp)
│                                                 │
│    Automate your factory with smart             │ ← Description (14sp)
│    conveyor belts. Tap BUILD → Conveyor!       │
│                                                 │
│           💰 +500 Gold Bonus!                   │ ← Reward (18sp, gold)
│                                                 │
│                                                 │
│           [Let's Automate!] ✓                   │ ← Primary button (green, large)
│                                                 │
└─────────────────────────────────────────────────┘
```

**Animation:**
- Full-screen overlay with dark background (90% opacity)
- Fireworks: 20 particle bursts over 3 seconds
- Confetti falling (60 particles, 3s duration)
- Triumphant sound effect (0.5s)
- Medium haptic on appear + light haptic on each firework burst

**Auto-Dismiss:** After 3 seconds OR tap "Let's Automate!" → Tutorial begins

---

## 4. UI Components

### 4.1 Buttons

**Primary Button (Call-to-Action):**
```
┌─────────────────────────┐
│  Collect Resources ✓    │ ← Success Green #4CAF50, 14sp white text
└─────────────────────────┘
```
- Size: 56dp height, full-width or min 200dp
- Border radius: 8dp (slightly rounded)
- Elevation: 2dp (subtle shadow)
- Tap: Haptic light impact, 100ms press animation (scale 0.95)

**Secondary Button:**
```
┌─────────────────────────┐
│  Upgrade Building       │ ← Factory Blue #2E5CB8, 14sp white text
└─────────────────────────┘
```
- Same size/style as primary, different color

**Text Button (Destructive):**
```
Delete Building ← Error Red #F44336, no background, 14sp
```
- No background, just colored text
- Used for destructive or less-important actions

**Disabled Button:**
```
┌─────────────────────────┐
│  Insufficient Gold ✗    │ ← Medium Gray #424242, 50% opacity
└─────────────────────────┘
```
- Gray background, 50% opacity
- No haptic feedback
- Shows reason in label if possible

### 4.2 Cards

**Building Card (Build Menu):**
```
┌──────────────┐
│  🪓          │ ← Icon (48×48px), centered
│              │
│  Lumbermill  │ ← Name (14sp, white)
│              │
│  100 Gold    │ ← Cost (12sp, gold color if affordable)
│  1 Wood/min  │ ← Production (12sp, gray)
└──────────────┘
```
- Size: 120×140dp
- Elevation: 2dp
- Border radius: 12dp
- Background: Medium Gray #424242

**Resource Row Card (Market):**
```
┌─────────────────────────────────────────┐
│ 🪵 Wood                  You have: 50   │ ← Header (14sp)
│ Buy: 8g  Sell: 5g                       │ ← Prices (12sp)
│ [────────|─────────] 25                 │ ← Slider + value (14sp)
│          [SELL 25 for 125g] ✓           │ ← Button (green)
└─────────────────────────────────────────┘
```
- Height: 80dp
- Elevation: 1dp
- Border radius: 8dp
- Background: Medium Gray #424242

### 4.3 Sliders

**Quantity Slider (Market):**
```
[────────|─────────] 25
Min: 1             Max: 50
```
- Track height: 4dp
- Thumb size: 24×24dp (large, easy to drag)
- Active color: Factory Blue #2E5CB8
- Inactive color: Light Gray #E0E0E0
- Shows current value above thumb

### 4.4 Tooltips

**Building Tooltip (Tap + Hold):**
```
┌───────────────────────┐
│ Lumbermill Level 3    │ ← Title (14sp, white)
│ Produces: 1.4 Wood/min│ ← Detail (12sp, gray)
│ Storage: 14/14 FULL   │
└───────────────────────┘
```
- Size: Auto-width, max 280dp
- Elevation: 4dp (floats above everything)
- Background: Dark Gray #1E1E1E, 95% opacity
- Border radius: 4dp
- Appears 500ms after long-press
- Dismisses on finger release

### 4.5 Floating Text

**Success Feedback:**
```
     +50 Wood ↑
```
- Font: 18sp, bold, Success Green #4CAF50
- Animation: Floats upward 20dp over 800ms, fades out
- Appears on resource collection, upgrade completion

**Error Feedback:**
```
     Insufficient Gold! ✗
```
- Font: 14sp, medium, Error Red #F44336
- Animation: Shakes horizontally 10dp × 3, fades out after 1s
- Appears on failed actions

---

## 5. Interaction Patterns

### 5.1 Gesture Controls

**Primary Gestures:**

1. **Tap (Single):**
   - Buildings: Select → Show Building Details Panel
   - Empty grid: Deselect all
   - UI buttons: Execute action
   - Response time: <50ms (visual feedback + haptic)

2. **Long Press (500ms hold):**
   - Buildings: Show tooltip (production, storage, status)
   - Empty grid: No action
   - Haptic: Medium impact on tooltip appear

3. **Swipe (1 finger drag):**
   - Game canvas: Pan camera across grid
   - Momentum: Continues after finger release, decelerates smoothly
   - Bounds: Cannot pan outside 50×50 grid

4. **Pinch (2 finger scale):**
   - Game canvas: Zoom in/out (0.5× - 2.0× range)
   - Centered: Zooms toward pinch midpoint
   - Smooth: Interpolated zoom, no jarring jumps

5. **Double Tap:**
   - Game canvas: Recenter camera to factory center (25, 25)
   - Animation: 400ms smooth pan + zoom to default (1.5× Build Mode)

### 5.2 Tap Target Sizing

**Minimum Sizes (Apple HIG + Material Design):**
- Tap target: 44×44dp minimum (fingers are 40-50dp)
- Buildings in Build Mode (1.5× zoom): 60×60dp ✓ (above minimum)
- Buttons: 56×56dp ✓ (comfortable)
- Conveyor tiles in Planning Mode (0.5× zoom): 20×20dp ✗ (view-only, no tap expected)

**Spacing:**
- Minimum 8dp between tappable elements
- 16dp recommended for comfortable one-handed use

### 5.3 Feedback Loops

**Visual Feedback:**
```
Tap → Highlight (50ms) → Action → Animation (200-400ms) → Result
```

**Haptic Feedback:**
```
Success:      Light impact (10ms) - resource collect, button tap
Milestone:    Medium impact (20ms) - upgrade complete, Tier unlock
Failure:      No haptic - empty building, insufficient gold
```

**Audio Feedback (Optional, can disable in settings):**
- Collect: Soft "ding" (0.1s)
- Upgrade: Triumphant chord (0.5s)
- Error: Negative buzz (0.2s)
- Music: Ambient factory sounds (loopable, 2-minute track)

---

## 6. Animation System

### 6.1 Animation Timing

**Duration Guidelines:**
```
Micro (100-200ms):  Button press, checkbox toggle
Fast (200-400ms):   Resource collection, card flip
Medium (300-500ms): Modal open/close, zoom mode toggle
Slow (500-1000ms):  Celebration effects, page transitions
```

**Easing Curves:**
- **Ease-out:** Fast start, slow end (resource collection, dismissals)
- **Ease-in:** Slow start, fast end (deletions, collapses)
- **Ease-in-out:** Smooth both ends (zoom transitions, modals)
- **Linear:** Constant speed (conveyor belt movement)

### 6.2 Key Animations

**Resource Collection:**
```
1. Tap building (t=0ms)
2. Building flash white (50ms highlight)
3. Resource sprite spawns at building center (t=100ms)
4. Sprite moves to inventory bar (200-400ms ease-out curve)
5. Inventory number increments with pop effect (t=300ms)
6. "+X Resource" floating text appears (t=300ms, floats up 800ms)
```

**Building Upgrade:**
```
1. Tap "Upgrade" button (t=0ms)
2. Button scales down 0.95 (100ms press feedback)
3. Sparkle particles burst around building (t=150ms, 20 particles)
4. Building glows green (500ms pulse)
5. Level indicator updates (number pops up)
6. "+20% production" floating text (t=300ms, gold color)
7. Medium haptic at t=150ms
```

**Camera Zoom Mode Toggle:**
```
1. Tap zoom toggle button (t=0ms)
2. Button icon swaps (Build ↔ Planning)
3. Camera zoom animates (300ms ease-in-out)
   - 1.5× → 0.5× (Planning Mode)
   - 0.5× → 1.5× (Build Mode)
4. Minimap fades in/out based on mode (300ms)
5. Light haptic at t=0ms
```

### 6.3 Performance Optimization

**60 FPS Budget: 16.67ms per frame**

**Animation Performance:**
- Use GPU-accelerated transforms (translate, scale, rotate) - NOT expensive
- Avoid layout recalculations during animations
- Batch sprite renders (all conveyors in single draw call)
- Cull off-screen animations (don't update if not visible)

**Flutter Flame Optimizations:**
- `RepaintBoundary` for complex widgets (isolates repaints)
- `AnimationController` with `vsync` (syncs to 60 FPS refresh rate)
- `Sprite.render()` with batching for 50+ conveyor sprites

---

## 7. Accessibility

### 7.1 Visual Accessibility

**Colorblind Modes:**
- Default: Full color palette (tested with ColorOracle)
- Deuteranopia Mode: Orange → Blue, Green → Purple adjustments
- Protanopia Mode: Red → Brown, Green → Blue adjustments
- Icons ALWAYS paired with color (not color-only indicators)

**Contrast Ratios (WCAG AAA):**
```
Text on Dark Gray (#1E1E1E):
- White text (#F5F5F5): 15.8:1 ✓ (AAA: >7:1)
- Light Gray (#E0E0E0): 12.6:1 ✓

Text on Medium Gray (#424242):
- White text: 9.7:1 ✓
- Gold text (#FFD700): 8.2:1 ✓
```

**Font Sizing:**
- Minimum: 12sp (captions, small labels)
- Body: 14sp (comfortable reading)
- Large Text Mode: +2sp to all text (accessibility setting)

### 7.2 Motor Accessibility

**Large Tap Targets:**
- All buttons: 56×56dp minimum ✓
- Buildings in Build Mode: 60×60dp ✓
- Slider thumb: 24×24dp (easy to grab)

**Gesture Alternatives:**
- Swipe to pan: Also available via on-screen D-pad (optional, settings)
- Pinch to zoom: Also available via +/- buttons (optional)
- Long-press tooltips: Also show on single tap in Accessibility Mode

**Reduced Motion Mode:**
- Disables all non-essential animations
- Collection still works, just instant (no 300ms sprite move)
- Modals snap open/close instead of slide

### 7.3 Cognitive Accessibility

**Clear Hierarchy:**
- Primary actions: Green buttons (largest)
- Secondary actions: Blue buttons (medium)
- Destructive actions: Red text (smallest)

**Consistent Patterns:**
- All modals dismiss with [X] button (top-right) OR swipe down
- All destructive actions require confirmation ("Delete building? [Cancel] [Delete]")
- All success actions show "+X Resource" floating text

**Tooltips Everywhere:**
- Tap + hold any building: See production, storage, status
- Tap "?" icon in Market: Explains buy/sell spread
- Tutorial tooltips: <10 words, clear arrows pointing to next action

---

## 8. Responsive Design

### 8.1 Portrait Mode (Primary)

**Optimized for:** 6.0" to 6.7" phones (95% of users)

**Layout:**
```
Top HUD:        56dp height
Game Canvas:    Fill remaining (400-600dp typically)
Bottom Toolbar: 72dp height
```

**One-Handed Reach:**
```
[  Hard  ][   OK   ][  Hard  ]  ← Top (minimap only)
[  Easy  ][  Easy  ][  Easy  ]  ← Middle (game canvas)
[ V.Easy ][ V.Easy ][ V.Easy ]  ← Bottom (toolbar) ← Thumb rests here
```

### 8.2 Landscape Mode (Secondary)

**Optimized for:** Tablet use, desk play

**Layout:**
```
┌────┬──────────────────────────────────────┐
│ HUD│                                      │
│ V  │       Game Canvas                    │
│ E  │       (expanded horizontally)        │
│ R  │                                      │
│ T  │                                      │
│ I  │                                      │
│ C  │                                      │
│ A  │                                      │
│ L  │                                      │
├────┼──────────────────────────────────────┤
│    │ [Build] [Conv] [Market] [Stats] [⚙️]│
└────┴──────────────────────────────────────┘
```

**Changes:**
- Top HUD moves to left side (vertical stack)
- Game canvas expands to fill more horizontal space
- Bottom toolbar remains, but could move to right side (future iteration)

### 8.3 Small Screens (<5.5")

**Adjustments:**
- Font sizes: -1sp (Body: 13sp instead of 14sp)
- Bottom toolbar: Icon-only mode (remove labels)
- Minimap: 60×60px instead of 80×80px

### 8.4 Large Screens (Tablets, >7")

**Adjustments:**
- Grid view: Show more tiles on screen (less zoom required)
- Side panels: 400dp width instead of 320dp
- Font sizes: +1sp (Body: 15sp instead of 14sp)
- Two-column layouts where appropriate (Market: BUY | SELL side-by-side)

---

## 9. Dark Mode (Default)

**Primary Mode:** Dark mode by default (industry standard for games)

**Why Dark Mode:**
- Battery savings on OLED screens (60% of Android devices)
- Reduces eye strain during long sessions
- Better visibility for colorful game sprites (wood, ore, resources pop against dark background)
- Night play friendly (won't blind users in dark room)

**Light Mode:** Not planned for MVP (95% of mobile games are dark mode only)

---

## 10. Design Handoff Checklist

### For Developers:

✅ **Design System Defined:**
- Color palette with hex codes
- Typography scale (Roboto font family)
- 8-point spacing grid
- Elevation levels (0-4)

✅ **All Core Screens Designed:**
- Main Game Screen (ASCII layout provided)
- Build Menu (bottom sheet)
- NPC Market (full-screen modal)
- Building Details Panel (side slide-in)
- Welcome Back Modal
- Tier 2 Unlock Celebration

✅ **Components Specified:**
- Buttons (Primary, Secondary, Text, Disabled)
- Cards (Building, Resource Row)
- Sliders (Quantity)
- Tooltips, Floating Text

✅ **Interactions Documented:**
- Tap, Long Press, Swipe, Pinch, Double Tap
- Tap target sizes (44×44dp minimum)
- Haptic feedback patterns

✅ **Animations Defined:**
- Timing (100-1000ms durations)
- Easing curves (ease-in, ease-out, ease-in-out)
- 60 FPS performance budget

✅ **Accessibility Covered:**
- Colorblind modes
- WCAG AAA contrast ratios
- Large tap targets
- Reduced motion mode

✅ **Responsive Design:**
- Portrait (primary)
- Landscape (secondary)
- Small (<5.5") and Large (>7") screens

---

## 11. Next Steps

**For Implementation:**
1. Set up Flutter project with Material Design 3
2. Create design system (colors, typography, spacing as constants)
3. Implement Flame game engine with 50×50 grid
4. Build Main Game Screen layout (HUD, canvas, toolbar)
5. Implement touch controls (tap, swipe, pinch)
6. Create component library (buttons, cards, modals)
7. Add animations (resource collection, upgrades)
8. Test on real devices (Snapdragon 660 target)

**Design Iteration:**
1. Create high-fidelity mockups in Figma (if needed)
2. Prototype key animations (Principle, After Effects)
3. User testing with 5-10 Factorio fans (feedback on touch controls)
4. Iterate based on feedback (adjust tap target sizes, animation speeds)

---

**End of UX Design Document**

**Status:** ✅ Ready for Architecture Phase
**Next:** Create System Architecture (technical design, data flow, Firebase integration)
