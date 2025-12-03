# UX Distribution Plan Across All Epics

**Date:** 2025-12-03
**Purpose:** Distribute 3 major UX screens across 12 epics to minimize blocking and maintain logical order
**Status:** Planning phase

---

## Executive Summary

**3 Major UX Screens Need Distribution:**
1. Main Hub Screen (Home Dashboard)
2. Grid World Screen (Map & Buildings)
3. Biom Gathering Screen (Resource Collection)

**Key Principle:** Separate mechanics implementation from UI polish
- **Mechanics epics** (02, 03, 04, 06): Implement core functionality + basic UI
- **UX epic** (05): Polish and optimize all interfaces
- **Result:** No blocking dependencies, parallel development possible

---

## The 12-Epic Structure Overview

```
EPIC-00: Project Setup (13 SP)
EPIC-01: Core Gameplay (34 SP, buggy)
EPIC-02: Tier 1 Economy (26→37-38 SP)
EPIC-03: Automation (42 SP, planning)
EPIC-04: Offline Production (26 SP, planning)
EPIC-05: Mobile-First UX (29 SP, ready)
EPIC-06: Progression System (18 SP, planning)
EPIC-07: ??? (Not yet defined)
EPIC-08: Ethical F2P (23 SP, planning)
EPIC-09: ??? (Not yet defined)
EPIC-10: ??? (Not yet defined)
EPIC-11: ??? (Not yet defined)
─────────────────────────────────
Total MVP: 289 SP across 12 epics
```

---

## UX Distribution Strategy

### Approach: Two-Phase Implementation

**Phase 1: Core Implementation (Mechanics Epics)**
```
EPIC-01, EPIC-02, EPIC-03, EPIC-04, EPIC-06
├─ Implement game mechanics
├─ Add basic UI (functional, minimal styling)
├─ Focus: Logic and data flow
└─ Result: Playable but not polished
```

**Phase 2: UX Polish (Mobile-First UX Epic)**
```
EPIC-05: Mobile-First UX (29 SP)
├─ Polish all screens
├─ Add animations and feedback
├─ Optimize for mobile (touch, performance)
├─ Focus: User experience and delight
└─ Result: Polished, professional product
```

**Benefit:** No blocking between mechanics and UX developers

---

## Screen 1: Main Hub Screen (Home Dashboard)

### What It Shows
- Player level, gold, playtime
- Quick stats cards (buildings, storage, farm output)
- Current objective tracker
- Skill levels overview
- Action buttons (Go to Map, Craft)

### Where It Should Go

**EPIC-02: Tier 1 Economy**
- **Story:** STORY-02.7 (Economic Balance & Testing)
- **Scope:** Basic hub screen
  - Level and gold display (from PlayerEconomy)
  - Building count card (from GridRepository)
  - Storage usage card (from StorageRepository)
  - Farm output card (real-time from ProductionCycle)
  - Action buttons to map/craft
- **Acceptance Criteria:**
  - [ ] Hub displays current level, gold, playtime
  - [ ] Quick stats update in real-time (every 100ms)
  - [ ] Cards show correct building/storage/farm data
  - [ ] [GO TO MAP] navigates to grid screen
  - [ ] [CRAFT] shows available crafts
  - [ ] Gold counter updates smoothly

**EPIC-04: Offline Production**
- **Story:** NEW (Welcome Back Notification)
- **Scope:** Offline return UI
  - Welcome back screen with offline earnings
  - Earnings breakdown (items processed, gold earned)
  - Storage warnings (if near capacity)
  - Gold animation and notification
- **Acceptance Criteria:**
  - [ ] Offline notification appears on app launch
  - [ ] Shows time offline, earnings breakdown
  - [ ] Gold counter animates (+3,168g)
  - [ ] Success sound and particles
  - [ ] Storage warnings if near capacity

**EPIC-05: Mobile-First UX**
- **Story:** NEW (Hub Screen Polish)
- **Scope:** Detailed polish
  - Card animations and transitions (300-500ms)
  - Skill progress visualization (stars, bars)
  - Objective expansion/collapse
  - Swipe interactions (pull to refresh)
  - Responsive layout (all screen sizes)
  - Dark mode (optional, Phase 2)
- **Acceptance Criteria:**
  - [ ] Smooth animations (60 FPS)
  - [ ] Cards have shadow/elevation
  - [ ] Skill display with star ratings
  - [ ] Pull-to-refresh works
  - [ ] Responsive on all sizes (375px-1024px)
  - [ ] Haptic feedback on interactions
  - [ ] Accessibility: 44px+ touch targets

**EPIC-06: Progression System**
- **Story:** NEW (Skills Display & Progression)
- **Scope:** Skill details and progression
  - Detailed skill screen (tap from hub)
  - XP progress toward next level
  - Skill suggestions ("Keep mining for level 4!")
  - Skill tree preview (future)
  - Skill book purchases (Phase 2)
- **Acceptance Criteria:**
  - [ ] Skill detail screen shows XP progress
  - [ ] Displays time to next level
  - [ ] Shows skill benefits (e.g., "+20% speed")
  - [ ] Links to buy skill books (if available)
  - [ ] [TAP TO LEVEL UP] when ready

### Dependencies
```
EPIC-02 (basic hub)
   ↑
   └─ EPIC-04 (offline notifications)
   └─ EPIC-06 (skill details)
   ↑
   └─ EPIC-05 (polish & animations)
```

### Timeline
```
Sprint 2-3: EPIC-02 (basic hub)
Sprint 4-5: EPIC-04 (offline UI)
Sprint 4-5: EPIC-06 (skill system)
Sprint 6-7: EPIC-05 (polish all)
```

---

## Screen 2: Grid World Screen (Map & Buildings)

### What It Shows
- 20×20 grid with buildings and conveyors
- Biom zones (Koppalnia, Las, Jezioro, Góry, Pustynia)
- Building status indicators
- Item flow visualization on conveyors
- Zoom controls and navigation
- Building selection and placement UI
- Grid expansion status

### Where It Should Go

**EPIC-02: Tier 1 Economy**
- **Story:** STORY-02.4 (Grid & Building Placement)
- **Scope:** Basic grid rendering
  - 20×20 grid display
  - Biom zone colors (background)
  - Building placement on grid
  - Basic building icons
  - Building selection and info panel
  - Conveyor visualization (simple lines)
  - Zoom controls (basic 3-4 levels)
- **Acceptance Criteria:**
  - [ ] Grid renders 20×20 correctly
  - [ ] Biom zones show correct colors
  - [ ] Buildings render as icons at correct positions
  - [ ] Can select building (highlight + info)
  - [ ] Can place building (valid/invalid feedback)
  - [ ] Conveyors show as lines between buildings
  - [ ] Zoom works (−/+/HOME buttons)
  - [ ] Pan works (swipe to move)

**EPIC-02: Tier 1 Economy**
- **Story:** STORY-02.4 (Grid Expansion System)
- **Scope:** Grid expansion mechanics
  - Track building count
  - Track resource depletion per biom
  - Show expansion unlock conditions
  - Expansion animation (20×20 → 30×30)
  - New biom distribution in expanded area
  - 30×30 → 40×40 expansion trigger
- **Acceptance Criteria:**
  - [ ] Expansion triggers at correct conditions
  - [ ] Expansion animation plays (1-2s)
  - [ ] Grid size updates (20×20 → 30×30)
  - [ ] New area accessible for building
  - [ ] All buildings preserved after expansion
  - [ ] Bioms distributed in new area

**EPIC-03: Automation** (Future)
- **Story:** NEW (Advanced Grid Features)
- **Scope:** (Deferred to Epic 3)
  - Conveyor pathfinding visualization
  - Item flow arrows and directions
  - Conveyor filtering visual indicators
  - Multi-layer conveyor stacking
  - Splitter visualization and configuration
  - Heat maps (item density, production rates)

**EPIC-05: Mobile-First UX**
- **Story:** NEW (Grid World Polish)
- **Scope:** Detailed polish
  - Building animations (working, idle, paused states)
  - Item animation on conveyors (smooth, visible)
  - Glow effects (active buildings)
  - Status indicators (glow color: green/yellow/red)
  - Smooth zoom transitions (300ms)
  - Pan with momentum scrolling
  - Building preview on placement (before confirm)
  - Long-press building context menu
  - Double-tap to zoom in on building
- **Acceptance Criteria:**
  - [ ] Buildings glow when working
  - [ ] Items animate smoothly on conveyors
  - [ ] Zoom transitions smooth (60 FPS)
  - [ ] Pan has momentum deceleration
  - [ ] Building preview shows on drag
  - [ ] Context menu on long-press
  - [ ] Status colors: green (working) → yellow (waiting) → red (error)
  - [ ] Haptic feedback on placement
  - [ ] Responsive zoom for all screen sizes

### Dependencies
```
EPIC-02 (basic grid & placement)
   ↑
   ├─ Requires: Resources (STORY-02.1)
   ├─ Requires: Buildings (STORY-02.2)
   └─ Requires: Grid Expansion logic
   ↑
   └─ EPIC-03 (advanced features)
   ↑
   └─ EPIC-05 (polish & animations)
```

### Timeline
```
Sprint 2-3: EPIC-02 (basic grid, 8-10 SP)
Sprint 2-3: EPIC-02 (expansion system, 2-3 SP)
Sprint 4-5: EPIC-03 (advanced grid)
Sprint 6-7: EPIC-05 (polish)
```

---

## Screen 3: Biom Gathering Screen (Resource Collection)

### What It Shows
- Current biom selection
- Available resources in biom
- Gathering progress bars
- Manual gathering with tap-and-hold
- Mining facility status
- Inventory display (per resource)
- Biom switcher (horizontal scroll or modal)
- Active events in biom

### Where It Should Go

**EPIC-02: Tier 1 Economy**
- **Story:** STORY-02.1 or STORY-02.5 (Resources & Production)
- **Scope:** Basic biom screen
  - Show available resources per biom
  - Manual gather with progress bar
  - Inventory display (items/max per resource)
  - Mining facility status (if present)
  - Biom selection (list or tabs)
  - Storage warning (if near capacity)
- **Acceptance Criteria:**
  - [ ] Resources display for current biom
  - [ ] Tap & hold starts gathering
  - [ ] Progress bar shows gather time
  - [ ] Item added after gather completes
  - [ ] Inventory shows current amount
  - [ ] Can switch bioms (horizontal scroll)
  - [ ] Mining facility shows automation status
  - [ ] Storage warning when 90%+ full

**EPIC-03: Automation** (Future)
- **Story:** NEW (Mining Facility Automation)
- **Scope:** (Deferred to Epic 3)
  - Mining facility production rates
  - Auto-gather when facility active
  - Choose which resource to gather (facility)
  - Conveyor output routing
  - Facility pause/resume controls

**EPIC-06: Progression System**
- **Story:** NEW (Skill Effects on Gathering)
- **Scope:** (Related to progression)
  - Mining skill level affects gather speed
  - Display modified gather times (1.25s → 1.06s)
  - Show XP progress toward next level
  - Suggestion: "Keep mining! 3 more → level 4"
  - Skill book effects (if purchased)
- **Acceptance Criteria:**
  - [ ] Gather time updates based on Mining skill
  - [ ] Shows speed bonus (e.g., "-5% time per level")
  - [ ] Displays XP toward next level
  - [ ] Suggest relevant actions

**EPIC-04: Offline Production** (Related)
- **Story:** NEW (Gathering State Persistence)
- **Scope:** (Offline mechanics)
  - Partial gather progress saved
  - Resume gathering after returning online
  - No loss if player leaves biom
- **Acceptance Criteria:**
  - [ ] Gathering progress persists when leaving biom
  - [ ] Can resume from same % on return
  - [ ] No progress loss (safe mechanic)

**EPIC-05: Mobile-First UX**
- **Story:** NEW (Biom Gathering Polish)
- **Scope:** Detailed polish
  - Smooth resource card animations
  - Biom background atmosphere (visual polish)
  - Gather button feedback (color change, animation)
  - Progress bar animation (smooth fill, satisfying)
  - Item completion pop-up animation
  - Sound feedback (gathering, completion)
  - Biom switch animation (cards slide)
  - Tooltip interactions (long-press for tips)
  - Responsive layout for all sizes
- **Acceptance Criteria:**
  - [ ] Progress bar animates smoothly
  - [ ] Button color changes on interaction
  - [ ] Completion shows particle effect
  - [ ] Success sound plays
  - [ ] Biom switch animation (300ms)
  - [ ] Tooltip appears on long-press
  - [ ] Responsive on all screen sizes
  - [ ] 60 FPS animations

### Dependencies
```
EPIC-02 (basic gathering screen, 5 SP)
   ↑
   ├─ Requires: Resources (STORY-02.1)
   ├─ Requires: Mining mechanics
   └─ Requires: Inventory system
   ↑
   ├─ EPIC-06 (skill effects on gathering)
   ├─ EPIC-04 (gathering state persistence)
   ├─ EPIC-03 (mining facility automation)
   ↑
   └─ EPIC-05 (polish & animations)
```

### Timeline
```
Sprint 2-3: EPIC-02 (basic biom screen, part of 02.1/02.5)
Sprint 4-5: EPIC-06 (skill effects on gathering)
Sprint 4-5: EPIC-04 (state persistence)
Sprint 5-6: EPIC-03 (mining facility integration)
Sprint 6-7: EPIC-05 (polish)
```

---

## UX Work Distribution Summary

### By Epic

**EPIC-02: Tier 1 Economy** (Add to stories)
- Basic Hub Screen (in STORY-02.7: Balance & Testing)
  - Display stats, cards, objective tracker
  - ~4-6 AC added
  - Est. +1 SP
- Basic Grid World Screen (in STORY-02.4: Grid & Building Placement)
  - Grid rendering, biom visualization, building placement UI
  - ~8 AC (already counted)
  - Est. +0 SP (included in placement story)
- Basic Grid Expansion (in STORY-02.4)
  - Expansion animation, visual feedback
  - ~3 AC (already counted)
  - Est. +0 SP (included)
- Basic Biom Gathering Screen (new mini-story or in STORY-02.5)
  - Biom UI, manual gathering, resource display
  - ~6 AC
  - Est. +2 SP (new story 02.7b or part of 02.5)
- **Total added to EPIC-02: 2-3 SP**

**EPIC-04: Offline Production** (New story needed)
- Welcome Back Notification Screen
  - Offline earnings display, gold animation
  - ~5 AC
  - Est. 2 SP (new story)

**EPIC-05: Mobile-First UX** (Will expand from 29 SP)
- Hub Screen Polish
  - Animations, cards, responsive layout
  - ~8 AC
  - Est. 3 SP
- Grid World Polish
  - Building animations, item flow, zoom smoothness
  - ~10 AC
  - Est. 3 SP
- Biom Gathering Polish
  - Progress animations, particle effects, sounds
  - ~8 AC
  - Est. 2 SP
- General UX Improvements
  - Dark mode, accessibility, haptic feedback
  - Est. 5 SP
- **Total EPIC-05 UX stories: ~13 SP** (adding to existing 29 SP = 42 SP total)

**EPIC-06: Progression System** (Add UX)
- Skill Details Screen (linked from Hub)
  - XP progress, next level info, suggestions
  - ~5 AC
  - Est. 2 SP
- Gathering Speed Skill Effects
  - Modified gather times, XP progress
  - ~4 AC
  - Est. 1 SP
- **Total added to EPIC-06: 3 SP**

---

## Recommended Epic 2 Story Updates

Based on above, add to `epic-02-stories.md`:

### STORY-02.4: Grid & Building Placement (10 SP)

**Add new section: "Grid World Screen UX"**
- AC8: Grid renders with biom visualization
- AC9: Buildings show as icons with status
- AC10: Zoom controls work (−/+/HOME)
- AC11: Pan with touch (swipe)
- AC12: Building selection shows info panel
- AC13: Placement shows valid/invalid feedback
- AC14: Grid expansion animation smooth

### STORY-02.5: Production & Inventory (8 SP)

**Add note in Implementation:** "Biom gathering screen will be detailed in separate story"

### NEW STORY-02.7b: Biom Gathering Interface (2 SP)

**New Story:** Biom Gathering Screen
- Scope: Basic UI for resource gathering
- AC1: Show available resources per biom
- AC2: Manual gather with tap & hold
- AC3: Progress bar shows gather time
- AC4: Inventory updates on completion
- AC5: Can switch bioms (horizontal scroll)
- AC6: Mining facility status shown
- AC7: Storage capacity warning

### STORY-02.7: Economic Balance & Testing (4 SP, increased from 3)

**Add new section: "Hub Screen & Overview"**
- AC1: Hub displays level, gold, playtime
- AC2: Quick stats cards show real data
- AC3: Objective tracker shows progress
- AC4: [GO TO MAP] navigates correctly
- AC5: [CRAFT] shows available crafts
- AC6: Gold counter updates smoothly

---

## Minimal Blocking Dependencies

### Can Run in Parallel:
```
EPIC-02.1 (Resources) ─┐
EPIC-02.2 (Buildings) ─┤─→ EPIC-02.4 (Grid) ─→ EPIC-02.7b (Biom)
EPIC-02.3 (NPCs)      ─┘                        EPIC-02.7 (Hub)
EPIC-02.5 (Production)┐
EPIC-02.6 (Filtering) ┴─→ No blocking to other stories

EPIC-04 (Offline) ────→ (Can start after EPIC-02 basics)
EPIC-06 (Skills)  ────→ (Parallel with EPIC-02, blocks details)
EPIC-05 (UX Polish)──→ (Starts after basic UX complete)
```

### Key Point:
- Mechanics developers (EPIC-02) work on core functionality
- UX developers (EPIC-05) work in parallel on polish
- No blocking between core mechanics and UX teams

---

## Update Plan Sequence

### IMMEDIATE (This Week)

- [ ] Update STORY-02.4 (+3-4 AC for grid screen)
- [ ] Update STORY-02.5 (note about biom screen)
- [ ] Update STORY-02.7 (+4-6 AC for hub screen)
- [ ] Create STORY-02.7b (biom gathering, 2 SP)
- [ ] Commit updated epic-02-stories.md

### NEXT WEEK

- [ ] Create EPIC-04 story (offline notifications, 2 SP)
- [ ] Create EPIC-05 stories (UX polish, 3×3 SP = 9 SP)
- [ ] Create EPIC-06 story (skill UI, 3 SP)
- [ ] Add UX design specs to relevant stories

### EPIC-2 NEW TOTAL: 40-41 SP
```
STORY-02.1: Resources (2 SP)
STORY-02.2: Buildings (3 SP)
STORY-02.3: NPCs (5 SP)
STORY-02.4: Grid & Expansion (10 SP) ← +2 SP for UI
STORY-02.5: Production (8 SP) ← No change
STORY-02.6: Storage Filtering (6 SP)
STORY-02.7: Hub Screen (4 SP) ← +1 SP for UI
STORY-02.7b: Biom Gathering (2 SP) ← NEW
──────────────────────────────────
TOTAL: 40 SP (from 26 SP original)
```

---

## Three UI Screens Implementation Matrix

| Screen | Where | When | Who | Dependencies |
|--------|-------|------|-----|--------------|
| **Hub Screen** | EPIC-02.7 | Sprint 3 | Mechanics dev | Resources, Buildings, Production |
| **Hub Polish** | EPIC-05 | Sprint 6-7 | UX dev | Hub basics from 02.7 |
| **Grid Screen** | EPIC-02.4 | Sprint 2-3 | Mechanics dev | Resources, Buildings, Grid |
| **Grid Polish** | EPIC-05 | Sprint 6-7 | UX dev | Grid basics from 02.4 |
| **Grid Expansion** | EPIC-02.4 | Sprint 2-3 | Mechanics dev | Grid system |
| **Biom Screen** | EPIC-02.7b | Sprint 2-3 | Mechanics dev | Resources, Mining |
| **Biom Polish** | EPIC-05 | Sprint 6-7 | UX dev | Biom basics from 02.7b |
| **Offline Notification** | EPIC-04 | Sprint 4-5 | Mechanics dev | Farm, Offline calc |
| **Skill Display** | EPIC-06 | Sprint 4-5 | Mechanics dev | Skills system |

---

## Questions for User

1. **Should Hub Screen be in STORY-02.7 or separate story?**
   - Option A: Add to 02.7 (Balance & Testing) ← Current plan
   - Option B: Create new story 02.8 (Hub Screen)

2. **When to start EPIC-04 (Offline)?**
   - Option A: After EPIC-02 basics (Sprint 3)
   - Option B: Sprint 4-5 (after basics solidified)
   - Option C: Parallel with EPIC-02 (if can access production data)

3. **EPIC-06 Progression - when to start?**
   - Option A: Sprint 4-5 (integrated with EPIC-02 skill mechanics)
   - Option B: Sprint 6-7 (after other systems stable)

4. **Can EPIC-05 (UX) team start design/specs now?**
   - Even though implementation comes later, UX can prep designs
   - Speeds up Sprint 6-7 UX work

---

## Status

| Task | Status | Details |
|------|--------|---------|
| EPIC-02 impact analysis | ✅ | +15-16 SP (26→40-41 SP) |
| EPIC-04 story outline | ⏳ | Need to create |
| EPIC-05 expansion | ⏳ | Need to plan detailed stories |
| EPIC-06 UX addition | ⏳ | Need to add skill screen story |
| Distribution matrix | ✅ | Complete, minimal blocking |
| Commit plan | ⏳ | Ready to execute |

---

**Document Status:** 📋 Ready for Implementation
**Recommendation:** Approve distribution, update EPIC-02 stories today
**Timeline:** All updates by 2025-12-05
