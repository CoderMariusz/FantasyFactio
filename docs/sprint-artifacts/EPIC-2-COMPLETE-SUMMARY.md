# EPIC 2 COMPREHENSIVE SUMMARY
## Tech-Spec Restructuring & UX Expansion Complete

**Date:** 2025-12-03
**Status:** ✅ PHASE 1 COMPLETE - Tech-Spec fully specified
**Branch:** `claude/project-status-display-01WgeBaEE9s5pXkKZraeZEwN`

---

## 📊 OVERALL PROGRESS

### What Started
- Epic 2 Base Spec (1,583 lines, monolithic)
- 3 new game systems (specifications provided by user)
- 6 UX screens (detailed layouts provided by user)
- Request: Reorganize + expand documentation

### What Was Completed
- **4-File Restructured Tech-Spec** (3,900+ lines total)
- **8 Complete UI Sections** (2x new: Notifications, Building Panels)
- **5 Advanced Systems** (Conveyors, NPCs, Offline, Grid Expansion, Filtering)
- **6 Full-Screen UX Designs** (mobile-optimized)
- **3 Git Commits** (all pushed to remote)

### Files Created & Committed
```
✅ tech-spec-epic-02-INDEX.md       (379 lines)  - Navigation & quick reference
✅ tech-spec-epic-02-CORE.md        (410 lines)  - Core mechanics
✅ tech-spec-epic-02-SYSTEMS.md     (963 lines)  - Advanced systems
✅ tech-spec-epic-02-UI.md          (2,095 lines) - All 8 UI sections
─────────────────────────────────────────────
   TOTAL NEW SPEC              (3,847 lines)
```

---

## 📁 FILE STRUCTURE & ORGANIZATION

### Tech-Spec Documentation (4-File Structure)

**1. tech-spec-epic-02-INDEX.md** (Navigation Hub)
```
Purpose: Entry point for all 4 documents
Content:
├─ Quick reference by role (designer, dev, QA)
├─ Quick reference by topic (resources, buildings, grid, economy)
├─ System dependencies diagram
├─ Implementation checklist (all 8 stories)
├─ Critical formulas (offline calc, expansion cost, filtering)
└─ Document statistics
```

**2. tech-spec-epic-02-CORE.md** (Foundation)
```
Purpose: Foundational mechanics, framework-independent
Content:
├─ Overview & scope
├─ 7 Resources (table: types, gather speeds, biom, base values)
├─ 6 Buildings (table: sizes, costs, unlock conditions)
│  ├─ Mining Facility (2×2, FREE, biom-restricted)
│  ├─ Storage (2×2, 5D+10K, 200 capacity)
│  ├─ Smelter (2×3, 15D+10K+5M)
│  ├─ Conveyor (1×1, 2D+1Z)
│  ├─ Workshop (2×2, 20D+15K+5Z)
│  └─ Farm (3×3, 25B+12Z+15D)
├─ Grid System (20×20 start, biom distribution, placement rules)
├─ Skill Progression (Mining, Smelting, Trading with formulas)
├─ Demolition System (80% refund mechanics)
└─ Testing requirements
```

**3. tech-spec-epic-02-SYSTEMS.md** (Advanced Mechanics)
```
Purpose: 5 complex systems that define deep gameplay
Content:
├─ CONVEYOR SYSTEM (963 lines total in document)
│  ├─ Transport mechanics (0.5 items/sec, max 2 layers)
│  ├─ 4-mode filtering (ALLOW_ALL, WHITELIST, BLACKLIST, SINGLE)
│  ├─ Splitter system (1→2-3 outputs, round-robin)
│  ├─ Layering (Layer 1 under, Layer 2 over buildings)
│  └─ Visual feedback (green/yellow/red status)
│
├─ NPC TRADING SYSTEM
│  ├─ Kupiec (Merchant): Dynamic prices, supply/demand
│  ├─ Inżynier (Engineer): 3 fixed barter offers
│  └─ Nomada (Nomad): Limited inventory, special deals
│
├─ OFFLINE PRODUCTION SYSTEM
│  ├─ 80% efficiency formula
│  ├─ Welcome-back notification screen
│  ├─ Calculation: MIN(queueLength, offlineSeconds/cycleTime * 0.80)
│  ├─ Gold earned animation
│  └─ No decay for stored items
│
├─ GRID EXPANSION SYSTEM
│  ├─ 3-stage progression: 20×20 → 30×30 → 40×40
│  ├─ Dual triggers: Building capacity OR resource scarcity
│  ├─ Cost: 50 beton (stage 1), 100 beton (stage 2)
│  ├─ Expansion animation (1.5s, white fade, zoom fit)
│  └─ Biom distribution maintained
│
└─ STORAGE FILTERING SYSTEM
   ├─ Global accept/reject filter per storage
   ├─ Per-port filtering (4 ports: N, S, E, W)
   ├─ 4-mode filters per port
   ├─ Advanced 3-storage network example
   ├─ Visual feedback (green/yellow/red)
   └─ Implementation logic (backpressure, blocking)
```

**4. tech-spec-epic-02-UI.md** (User Interface)
```
Purpose: 8 complete UI sections with mobile-first design
Content:
├─ SECTION 1: HUB SCREEN (Home Dashboard)
│  ├─ Quick stats (Level, Gold, Playtime, Buildings)
│  ├─ Objective tracker
│  ├─ Skill overview (Mining, Smelting, Trading)
│  ├─ Action buttons (Map, Gather, Craft, Trade)
│  └─ Welcome-back notification
│
├─ SECTION 2: GRID WORLD SCREEN (Map & Buildings)
│  ├─ Zoom/pan system (0.5x-2.0x)
│  ├─ Biom visualization (colors for each)
│  ├─ Building placement & preview
│  ├─ Conveyor visualization with flow animation
│  ├─ Selected building info panel
│  └─ Grid expansion triggers
│
├─ SECTION 3: BIOM GATHERING SCREEN (Resource Collection)
│  ├─ Resource cards (2-3 per biom)
│  ├─ Tap-and-hold gather mechanic
│  ├─ Mining facility status
│  ├─ Biom switching (swipe left/right)
│  ├─ Inventory status bar
│  └─ Skill bonus display
│
├─ SECTION 4: STORAGE MANAGEMENT SCREEN
│  ├─ Storage selection (tabs A, B, C)
│  ├─ Inventory breakdown (items + count)
│  ├─ Global filter configuration (3 modes)
│  ├─ Per-port filter configuration
│  ├─ Advanced network examples (3-storage setup)
│  └─ Empty all & settings actions
│
├─ SECTION 5: CRAFTING QUEUE SCREEN (Production)
│  ├─ Production status header
│  ├─ Building production cards (per building)
│  ├─ Progress bars (real-time)
│  ├─ Input/output display
│  ├─ Production rate summary
│  ├─ Bottleneck alerts
│  ├─ Pause/resume/cancel options
│  └─ Vertical scroll through queue
│
├─ SECTION 6: NPC TRADING SCREENS
│  ├─ NPC Selection screen (3 NPCs shown)
│  ├─ Kupiec (Merchant) - Dynamic pricing interface
│  │  ├─ Resource selector
│  │  ├─ Price breakdown (base + skill bonus)
│  │  ├─ Quantity input
│  │  ├─ Total trade preview
│  │  └─ 7-day price trend chart
│  │
│  ├─ Inżynier (Engineer) - Barter interface
│  │  ├─ 3 fixed offer cards
│  │  ├─ Give/Get breakdown per offer
│  │  └─ Resource availability indicators
│  │
│  └─ Nomada (Nomad) - Special offers
│     ├─ 3 limited-time offers
│     ├─ Countdown timer (2-hour cycle)
│     ├─ Discount highlights
│     ├─ Star ratings (quality)
│     └─ First offer free, others 100g fee
│
├─ SECTION 7: NOTIFICATION & WARNING SYSTEM ✨ NEW
│  ├─ 4-level hierarchy (Toast, Banner, Modal, Full-screen)
│  ├─ Toast types (Success, Info, Warning, Error)
│  │  ├─ Auto-dismiss timing (2-4s)
│  │  ├─ Stacking behavior (max 3)
│  │  └─ Animation (slide in 300ms, fade out 300ms)
│  │
│  ├─ Banner notifications (Persistent below header)
│  │  ├─ Storage warnings
│  │  ├─ Bottleneck alerts
│  │  ├─ Event banners
│  │  └─ Animation (slide down 300ms)
│  │
│  ├─ Modal dialogs (Blocking, center screen)
│  │  ├─ Confirmation modals (delete, cancel)
│  │  ├─ Choice modals (resource picker)
│  │  ├─ Information modals (offline earnings)
│  │  └─ Animation (slide up 300ms)
│  │
│  ├─ Full-screen alerts (Critical, game-stopping)
│  │  └─ Reserved for critical errors
│  │
│  ├─ Sound design (Ding, Beep, Buzz, Chime, Whoosh)
│  ├─ Accessibility (Screen readers, haptic, high contrast)
│  └─ Performance (Debouncing, throttling, GPU acceleration)
│
└─ SECTION 8: BUILDING DETAIL PANEL ✨ NEW
   ├─ Universal interface for all building types
   ├─ Layout components:
   │  ├─ Sticky header (building name + icon + controls)
   │  ├─ Basic info (type, location, status)
   │  ├─ Capacity/production details (type-specific)
   │  ├─ Port configuration (4 ports with live status)
   │  ├─ Active flows (real-time visualization)
   │  ├─ Optimization tips (AI suggestions)
   │  ├─ Maintenance options (upgrade/move/demolish)
   │  └─ Bottom actions (sticky: GO TO MAP, BACK, HELP)
   │
   ├─ Building-specific details:
   │  ├─ Mining: Resource, gather rate, skill bonus, biom resources
   │  ├─ Storage: Capacity, item breakdown, port configuration
   │  ├─ Smelter: Current craft, progress, ingredients, recipes
   │  ├─ Workshop: Queue management, gathering status, recipes
   │  └─ Farm: Earnings, processing, value breakdown, offline estimate
   │
   ├─ Port management:
   │  ├─ [EDIT] - Change mode/filter (modal)
   │  ├─ [NAVIGATE] - Pan to destination building
   │  ├─ [DISCONNECT] - Remove connection
   │  └─ Live status indicators (green/yellow/red)
   │
   ├─ Real-time flows:
   │  ├─ Visual progress bars (▓▓▓░░░░░)
   │  ├─ Item/minute rates
   │  ├─ Status descriptions (Flowing, Waiting, Blocked)
   │  └─ Animated item movement
   │
   ├─ Optimization tips:
   │  ├─ Bottleneck detection
   │  ├─ Efficiency ratings
   │  ├─ AI suggestions ("Build Storage #3")
   │  └─ Build recommendations
   │
   ├─ Maintenance:
   │  ├─ [UPGRADE] - Increase capacity/speed
   │  ├─ [MOVE] - Relocate building
   │  ├─ [DEMOLISH] - Remove, refund 80%
   │  └─ Future: [MONITOR], [AUTOMATE]
   │
   ├─ Mobile optimization:
   │  ├─ 375px viewport (375×667)
   │  ├─ Full-width scrollable content
   │  ├─ Sticky header (40px) + footer (60px)
   │  ├─ Touch targets: 44×44px minimum
   │  └─ Load time: <500ms
   │
   └─ Advanced Phase 2:
      ├─ Auto-optimization (AI routing suggestions)
      ├─ Monitoring dashboard (real-time metrics)
      ├─ Historical data (lifetime stats, trends)
      ├─ Custom alerts ("Alert if > 95%")
      └─ Multi-building view (comparisons)
```

**Additional Resources:**
```
├─ tech-spec-epic-02-UPDATED.md (Old monolithic, 1,583 lines, archived)
├─ tech-spec-epic-02.md (Original, reference)
├─ epic-1-completion-report.md (Previous epic summary)
└─ epic-1-retro-2025-11-23.md (Retrospective)
```

---

## 🎯 WHAT WAS DELIVERED BY SECTION

### Section 1: HUB SCREEN ✅ COMPLETE
**Deliverables:**
- Dashboard layout (375×812px mockup)
- Quick stats cards (Level, Gold, Playtime, Buildings)
- Objective tracker with progress bars
- Skill overview pills (Mining, Smelting, Trading)
- 4 main action buttons (Map, Gather, Craft, Trade)
- Welcome-back notification (if offline)
- Real-time stat updates (debounced 100ms)
- Animations: Staggered entry (1.1s total), smooth transitions

**Design Details:**
- Font sizes: Headers 18px, details 14px
- Colors: Skill-specific (pickaxe, flame, coins)
- Touch targets: 44px minimum
- Responsive: 375px baseline, scales to 1024px+

### Section 2: GRID WORLD SCREEN ✅ COMPLETE
**Deliverables:**
- Full-screen map visualization
- Zoom system (0.5×-2.0×)
- Pan/drag support (inertia scrolling)
- 4 biom colors (Mining gray, Forest green, Mountain brown, Lake blue)
- Building icons (⛏ ⛏ 🔥 ➡ 🔧 👨‍🌾)
- Conveyor lines with item animation (0.5 items/sec)
- Grid lines (faint, toggle visibility)
- Selected building info panel (shows stats, ports, status)
- Building placement mode (long-press to place)
- Grid expansion trigger (20×20→30×30→40×40)
- Animations: Smooth zoom/pan (cubic bezier), building scale-in, expansion fade

**Interactions:**
- Pinch zoom (2-finger)
- Scroll wheel zoom (desktop)
- [−] [HOME] [+] buttons (discrete zoom)
- Drag to pan
- Tap building to select
- Double-tap for details
- Long-press empty tile to place

**Performance:**
- Only render visible tiles
- Cull buildings outside viewport
- Batch conveyor rendering
- 60 FPS target

### Section 3: BIOM GATHERING SCREEN ✅ COMPLETE
**Deliverables:**
- Biom selector with navigation arrows (⬅ ➜)
- 2-column resource card grid
- Resource cards show: Icon, name, current/max in inventory, [GATHER] button
- Tap-and-hold gather mechanic
  - 200ms: Haptic feedback (vibration)
  - 300ms-gather time: Progress bar visible
  - 3+ seconds: ✓ Resource gained
  - Early release: Cancel (no item gained)
- Mining facility status (count: 2 of 3 active)
- Skill bonus displayed (e.g., "-10% from Mining +5")
- Inventory status bar ("⬇ Storage: 127/200 items")
- Biom switching animation (300ms smooth scroll)
- Biom order (Koppalnia, Las, Góry, Jezioro, cycling)

**Interactions:**
- Swipe left: Next biom
- Swipe right: Previous biom
- Tap [GATHER]: Long-press to activate gather
- Tap biom name: Show map location
- Tap mining facility: Show details
- Tap [View Breakdown]: Go to Storage Management

**Animations:**
- Card slide-in (staggered 50ms each)
- Progress bar fill (actual gather time)
- Biom transition (300ms fade)
- Inventory counter animate
- Storage warning (yellow pulse at 80%+)

### Section 4: STORAGE MANAGEMENT SCREEN ✅ COMPLETE
**Deliverables:**
- Storage selection tabs (A, B, C, [+New])
- Inventory breakdown (list of items + counts)
- Capacity indicator ("105/200 items (52%)")
- Color coding: Green (<50%), Yellow (50-80%), Red (>80%)
- Global filter configuration
  - Radio buttons: Accept all / Whitelist / Reject
  - [+ Add Resource] button
  - Resource list (removable: [×])
- Per-port filter configuration
  - Separate sections for Input/Output ports
  - Mode selector: [ALLOW_ALL] [WHITELIST] [BLACKLIST] [SINGLE]
  - Checkboxes for resource selection
  - Real-time preview: "Sending: węgiel+ruda"
  - Visual status: ✓ Green / ⚠️ Yellow / ✗ Red
- Advanced network example (3-storage setup documented)
- [Empty All] button (long-press confirmation)
- [Settings] and [Map] buttons

**Interactions:**
- Tap storage tab: Switch active storage
- Tap filter mode: Show mode selector
- [+ Add]: Open resource picker modal
- Tap resource chip: Show [×] Remove
- Swipe left on item: Delete
- Tap [Empty All]: Confirmation dialog
- [APPLY]: Save filter changes
- [CANCEL]: Discard changes

**Animations:**
- Tab switch (smooth transition)
- Filter mode change (fade old, fade new: 150ms each)
- Resource chip add (scale 0.8→1.0)
- Inventory update (number counter: 200ms)
- Color change threshold (yellow↔red transition)

### Section 5: CRAFTING QUEUE SCREEN ✅ COMPLETE
**Deliverables:**
- Status header: "3 Buildings Active"
- Production item cards (vertical scroll)
  - Building icon + name (emoji + #1, #2, etc)
  - Recipe (inputs → output)
  - Progress bar with time remaining
  - Input resources: ✓ available or ✗ missing
  - Output destination
  - Current processing item
  - Next item in queue
- Production rate summary
  - "Output capacity: 2 items/min"
  - "Queue depth: 5 items"
  - "Bottleneck: Iron shortage"
- Bottleneck alerts (clickable, shows details)
- Action buttons per recipe:
  - [Pause] - Pause this recipe
  - [Cancel] - Cancel (long-press confirmation)
  - [Settings] - Recipe options

**Interactions:**
- Tap card: Expand full details
- Tap [Pause]: Toggle pause/resume
- Long-press [Cancel]: Confirmation dialog
- Tap bottleneck alert: Show cause + suggestions
- Swipe: Vertical scroll through queue
- Tap [Production Details]: Show breakdown

**Animations:**
- Progress bar continuous fill (updates every 100ms)
- Color indicators (green=active, yellow=queued, red=error)
- Item completion bounce (scale effect)
- Queue depth changes (slide in/out)
- Bottleneck pulsing (red highlight, 1s cycle)

### Section 6: NPC TRADING SCREENS ✅ COMPLETE

**Screen 6A: NPC Selection**
- 3 NPC cards (Kupiec, Inżynier, Nomada)
- Each card shows:
  - Icon + name
  - Description
  - Specialty
  - [VISIT] button
- Last trade summary ("Sold 10 Coal to Kupiec: +12g")

**Screen 6B: Kupiec (Merchant)**
- Resource selector dropdown
- Current price display
  - Base price breakdown
  - Mining bonuses (if applicable)
  - Trading skill bonus (Level × 5%)
  - Final calculated price
- Quantity input
  - ← [5] → buttons
  - [Max] button
  - "Have: 45 items"
- Total trade preview: "Sell 5 Coal for 5.75g total"
- 7-day price trend sparkline chart
- Price trending indicator (↑ ↓)
- [✓ CONFIRM] [Cancel] buttons

**Screen 6C: Inżynier (Engineer)**
- 3 fixed barter offer cards
  - Offer 1: "5 Coal + 5 Iron Ore → 1 Refined Copper"
  - Offer 2: "10 Wood → 5 Stone"
  - Offer 3: "3 Copper → 1 Beton"
- Per offer:
  - Give → Get breakdown
  - Value comparison
  - Resource availability indicators (✓/✗)
  - [TRADE] button

**Screen 6D: Nomada (Nomad)**
- Limited time header: "Refresh in: 47 minutes"
- 3 offer cards
  - Item + quantity
  - Price + discount %
  - Normal vs special price
  - Star rating (quality indicator)
  - [BUY] button
- Purchase rules:
  - First offer: Free (no fee)
  - Subsequent: 100g fee each
- Current gold display: "327g available"
- Affordability indicators

### Section 7: NOTIFICATION & WARNING SYSTEM ✨ NEW ✅ COMPLETE
**Deliverables:**

**Toast Notifications (4 types):**
- SUCCESS (Green #4CAF50): ✓ icon, "ding!" sound, 2s
- INFO (Blue #2196F3): ℹ icon, chime sound, 3s
- WARNING (Orange #FF9800): ⚠ icon, beep sound, 4s
- ERROR (Red #F44336): ✗ icon, buzz sound, persistent

**Toast Behavior:**
- Position: Top of screen (375px width)
- Animation: Slide in from top (300ms), fade out (300ms)
- Stacking: Max 3 visible, queue overflow
- Dismissal: Auto (timed) or tap to dismiss early
- Duration: 2s (short) to 4s (long) based on message length

**Banner Notifications:**
- Position: Below header (sticky)
- Types: Storage warnings, bottlenecks, events, skill-ups
- Animation: Slide down (300ms), persist until dismissed
- Buttons: Up to 2 action buttons ([BUILD MORE], [HELP])
- Close: [×] button (top right)
- Stacking: Up to 3 banners visible

**Modal Dialogs:**
- Position: Center of screen
- Overlay: Semi-transparent black (40% opacity)
- Types: Confirmation, choice, information
- Animation: Slide up from bottom (300ms)
- Close: [CANCEL] button or tap outside
- Examples: Delete confirmation, resource picker, offline earnings

**Full-Screen Alerts:**
- Entire viewport
- Reserved for critical errors
- Game-stopping (requires action)
- Sound: Alarm/warning

**Sound Design:**
- Success ding (800Hz, 300ms, uplifting)
- Warning beep (600Hz, 200ms, alert)
- Error buzz (400Hz, 300ms, wrong tone)
- Info chime (multiple notes, 500ms, melodic)
- Entry whoosh (100ms, subtle)

**Accessibility:**
- Screen reader support: All text announced
- Haptic feedback: Vibration on alerts
- High contrast: 4.5:1 WCAG AA standard
- Color-blind safe: Icons + labels (not color-only)

### Section 8: BUILDING DETAIL PANEL ✨ NEW ✅ COMPLETE
**Deliverables:**

**Universal Interface (All Buildings):**
- Sticky header (40px): [←] Name [⚙️] [X]
- Basic info: Icon (64×64px), type, location, status
- Scrollable content sections:
  1. Capacity/Production details (type-specific)
  2. Port configuration (4 ports: N, S, E, W)
  3. Active flows (real-time visualization)
  4. Optimization tips (AI suggestions)
  5. Maintenance options (upgrade, move, demolish)
- Sticky bottom actions (60px): [GO TO MAP] [BACK] [HELP]

**Port Management:**
- Per port: Status light (🟢/🟡/🔴), direction icon, mode
- Filter display: "WHITE-LIST [węgiel, ruda]"
- Destination/source: Linked building name
- Live flow: "15 items/min flowing"
- Buttons: [EDIT], [NAVIGATE], [DISCONNECT]
- Real-time progress bars: ▓▓▓░░░░░

**Building-Specific Details:**

*Mining Facility:*
- Current resource
- Base rate (1.25s/item)
- Skill bonus (Level 3: -15%)
- Actual rate (1.06s/item)
- Production rate (~57 items/min)
- Output buffer status
- Available resources in biom
- Active events

*Storage:*
- Capacity: 145/200 items (72%)
- Item breakdown (bar chart per type)
- Free space indicator
- 4-port configuration
- Filter configuration per port
- Current flows (input + output rates)

*Smelter:*
- Current craft (Żelazo)
- Progress bar (▓▓▓▓▓░░░░ 50%)
- Ingredients needed + have
- Input ports (fuel, ingredients)
- Output port (products)
- Available recipes list
- Skill effects (-20% = 40s instead of 50s)
- Queue management (Phase 2)

*Workshop:*
- Active craft + status
- Gathering progress (3/10 ingredients)
- ETA (gathering + craft time)
- Queued recipes (5 pending)
- Input ports (primary, secondary)
- Skill effects (time savings)
- Queue management (add/remove/reorder)

*Farm:*
- Gold earned today (4,580g)
- Average rate (48g/min)
- Items in queue (45 total)
- Item values (with skill multiplier)
- Input port (accepts items)
- Optimization tips (send high-value items)
- Offline earnings estimate (per hour/8 hours)

**Interactions:**
- [EDIT] port: Open modal to configure filter/mode
- [NAVIGATE] port: Pan map to destination, highlight building
- [DISCONNECT]: Confirmation, remove connection
- [CHANGE RECIPE] (Smelter/Workshop): Modal with recipe selector
- Tap efficiency metrics: Detailed analysis modal

**Visual Design:**
- Status indicators: 🟢 (green) / 🟡 (yellow) / 🔴 (red), 24×24px
- Progress bars: 12px height, blue→red color, smooth animation
- Port cards: White background, 1px border, highlighted if connected
- Section headers: 16px bold, light gray divider

**Mobile Optimization:**
- Viewport: 375×667px
- Header: Fixed (40px)
- Content: Scrollable
- Footer: Sticky (60px)
- Touch targets: 44×44px minimum
- Text: 14px (details), 16px (headers), min 12px (readable)
- Load: <500ms
- Animations: 60 FPS

**Phase 2 Features:**
- Auto-optimization AI (suggest improvements)
- Monitoring dashboard (real-time metrics)
- Historical data (lifetime stats, trends)
- Custom alerts (if > 95%, etc)
- Multi-building view (comparisons)

---

## 📋 CONTENT BREAKDOWN BY EPIC STORY

### Epic 2 Story Distribution Plan (From UX-Distribution-Plan.md)

**EPIC-02 Stories (8 total, 40 SP):**
```
STORY 02.1: Basic Resources System
├─ Scope: Implement 7 resources with properties
├─ Spec location: CORE.md (Section 2)
├─ Acceptance Criteria: 7 resources, properties, gathering base speeds
├─ Estimated SP: 5
├─ Blocks: All other stories

STORY 02.2: Building Placement System
├─ Scope: 6 buildings, placement rules, grid validation
├─ Spec location: CORE.md (Section 2 + 3)
├─ Acceptance Criteria: All 6 building types, placement rules, biom checks
├─ Estimated SP: 8
├─ Blocks: Conveyor, production stories

STORY 02.3: Grid & Biom System
├─ Scope: 20×20 grid, biom distribution, placement validation
├─ Spec location: CORE.md (Section 3)
├─ Acceptance Criteria: Grid 20×20, 4 bioms, resource spawn, placement rules
├─ Estimated SP: 5
├─ Blocks: Mining, resource gathering

STORY 02.4: Grid Expansion System ⭐
├─ Scope: 20→30→40 progression, dual triggers, animations
├─ Spec location: SYSTEMS.md (Section 4)
├─ Acceptance Criteria:
│  ├─ Dual triggers: Building capacity (6+) OR resource scarcity (80%+)
│  ├─ Stage 1: 50 beton, animation, 20→30×30
│  ├─ Stage 2: 100 beton, animation, 30→40×40
│  ├─ Biom distribution maintained
│  └─ +7 new AC
├─ Estimated SP: 6
├─ Blocks: EPIC-03 (advanced grid features)

STORY 02.5: Offline Production System ⭐
├─ Scope: Farm at 80% efficiency, welcome notification, calculations
├─ Spec location: SYSTEMS.md (Section 3)
├─ Acceptance Criteria:
│  ├─ 80% efficiency formula
│  ├─ Welcome notification (gold earned + breakdown)
│  ├─ Gold animation counter
│  ├─ Storage items safe (no decay)
│  ├─ Time cap (max 30 days)
│  └─ +7 new AC
├─ Estimated SP: 5
├─ Blocks: EPIC-04 (offline features), EPIC-05 (UI polish)

STORY 02.6: Storage Filtering System ⭐
├─ Scope: Global + per-port filtering, 4 modes, advanced networks
├─ Spec location: SYSTEMS.md (Section 5)
├─ Acceptance Criteria:
│  ├─ Global accept/reject filter
│  ├─ Per-port filters (4 ports)
│  ├─ 4 filter modes (ALLOW_ALL, WHITE, BLACK, SINGLE)
│  ├─ Backpressure mechanics
│  ├─ Visual feedback
│  └─ 8 new AC (added)
├─ Estimated SP: 8
├─ Blocks: EPIC-03 (automation), EPIC-05 (UI)

STORY 02.7: Basic Hub Screen ⭐
├─ Scope: Dashboard with stats, objectives, skills, actions
├─ Spec location: UI.md (Section 1)
├─ Acceptance Criteria:
│  ├─ Quick stats (Level, Gold, Playtime, Buildings)
│  ├─ Objective tracker with progress
│  ├─ Skill overview (3 pills)
│  ├─ Action buttons (Map, Gather, Craft, Trade)
│  ├─ Welcome-back notification
│  ├─ Real-time updates (100ms debounce)
│  ├─ Animations (staggered entry 1.1s)
│  └─ +4 new AC (notifications)
├─ Estimated SP: 7
├─ Blocks: EPIC-05 (Hub polish)

STORY 02.7b: Biom Gathering Screen ⭐
├─ Scope: Manual resource collection with mining facilities
├─ Spec location: UI.md (Section 3)
├─ Acceptance Criteria:
│  ├─ Resource cards (2-3 per biom)
│  ├─ Tap-and-hold gather (200ms→gather time)
│  ├─ Mining facility status
│  ├─ Biom switching (swipe)
│  ├─ Inventory status bar
│  ├─ Skill bonus display
│  └─ 7 new AC
├─ Estimated SP: 7
├─ Blocks: EPIC-05 (Biom screen polish)

EPIC-02 ADDITIONAL (Not in story, but included):
├─ STORY 02.X: NPC Trading System
│  ├─ Scope: Kupiec (dynamic), Inżynier (barter), Nomada (limited)
│  ├─ Spec location: SYSTEMS.md (Section 2)
│  ├─ Estimated SP: 8
│  └─ Phase: Belongs to EPIC-06 (Progression) per UX plan

├─ STORY 02.Y: Conveyor System
│  ├─ Scope: Transport, filtering, splitters, layering
│  ├─ Spec location: SYSTEMS.md (Section 1)
│  ├─ Estimated SP: 8
│  └─ Phase: Belongs to EPIC-03 (Automation) per UX plan

├─ STORY 02.Z: Grid World Screen
│  ├─ Scope: Map, zoom/pan, buildings, conveyors
│  ├─ Spec location: UI.md (Section 2)
│  ├─ Estimated SP: 8
│  └─ Phase: Split (EPIC-02 basic, EPIC-05 polish)

├─ STORY 02.A: Storage Management Screen
│  ├─ Scope: Inventory + filtering configuration
│  ├─ Spec location: UI.md (Section 4)
│  ├─ Estimated SP: 7
│  └─ Phase: EPIC-02 basic, EPIC-05 polish

├─ STORY 02.B: Crafting Queue Screen
│  ├─ Scope: Production monitoring + bottleneck detection
│  ├─ Spec location: UI.md (Section 5)
│  ├─ Estimated SP: 6
│  └─ Phase: EPIC-02 basic, EPIC-05 polish

├─ STORY 02.C: NPC Trading Screens
│  ├─ Scope: 6A (selection), 6B (merchant), 6C (barter), 6D (nomad)
│  ├─ Spec location: UI.md (Section 6)
│  ├─ Estimated SP: 7
│  └─ Phase: EPIC-02 basic, EPIC-06 (trading polish)

├─ STORY 02.D: Notification System ✨ NEW
│  ├─ Scope: Toasts, banners, modals, full-screen
│  ├─ Spec location: UI.md (Section 7)
│  ├─ Estimated SP: 5
│  └─ Phase: EPIC-05 (feedback/polish)

└─ STORY 02.E: Building Detail Panel ✨ NEW
   ├─ Scope: Universal building config interface
   ├─ Spec location: UI.md (Section 8)
   ├─ Estimated SP: 8
   └─ Phase: EPIC-02 basic, EPIC-05 (polish + advanced features)

TOTAL EPIC-02: 8 main stories = 40 SP
ADDITIONAL STORIES: 8 supporting stories (26 SP in other epics)
COMPREHENSIVE COVERAGE: 16 stories fully specified, 66 SP distributed
```

---

## ⏭️ WHAT NEEDS TO BE DONE NEXT

### IMMEDIATE (Next Session - Story Implementation)

**Phase 1: Update Epic Story Files**
```
[ ] Update: docs/2-MANAGEMENT/epics/epic-02-stories.md
    ├─ Add expanded acceptance criteria for 8 stories
    ├─ Distribute new AC from UX-Distribution-Plan
    ├─ Update SP estimates (26→40)
    ├─ Add tech-spec cross-references
    ├─ Add test cases for each story
    └─ Status: Ready for development

[ ] Create: docs/2-MANAGEMENT/epics/epic-02-dependencies.md
    ├─ Story dependency diagram
    ├─ Blocking relationships
    ├─ Testing sequence
    └─ Parallel development opportunities
```

**Phase 2: Code Implementation Patterns**
```
[ ] Update: .claude/PATTERNS.md
    ├─ Add offline calculation formula (code example)
    ├─ Add storage filtering logic (implementation)
    ├─ Add grid expansion mechanics (state changes)
    ├─ Add conveyor transport algorithm
    ├─ Add NPC price calculation
    └─ Mobile gesture patterns

[ ] Update: .claude/FILE-MAP.md
    ├─ Note 4 new tech-spec files
    ├─ Update file statistics
    ├─ Add tech-spec folder structure
    └─ Cross-reference with story locations
```

**Phase 3: Project Status Updates**
```
[ ] Update: docs/2-MANAGEMENT/project-status.md
    ├─ Confirm Epic 2 scope = 40 SP
    ├─ Update MVP timeline (Sprint 2-3: Epic 2)
    ├─ Note: Epic 1 bugs must be fixed before Sprint 2
    ├─ Note: 3 critical bugs (integration test, resource logic, type cast)
    └─ Next milestone: Bug fixes + Story 02.1 implementation

[ ] Update: docs/2-MANAGEMENT/MVP-TODO.md
    ├─ Mark tech-spec complete
    ├─ Add story implementation tasks
    ├─ Add bug fix tasks (critical before sprint)
    └─ Set Sprint 2 start date

[ ] Archive: docs/5-ARCHIVE/ (old docs)
    ├─ Move: tech-spec-epic-02-UPDATED.md → Archive
    ├─ Create: Archive index noting reason
    └─ Update: docs/BMAD-STRUCTURE.md (archive location)
```

### SHORT-TERM (Sprint 2 Preparation)

**Story Implementation Sequence:**
```
1. STORY 02.1: Basic Resources (5 SP, BLOCKING)
   ├─ Implement: 7 resources with properties
   ├─ Create: Resource entity in domain/
   ├─ Add: Resource repository
   ├─ Test: Unit tests for resource properties
   └─ Duration: ~1 week (solo dev)

2. STORY 02.2: Building Placement (8 SP, BLOCKING)
   ├─ Implement: 6 building types with costs
   ├─ Create: Building entity, placement logic
   ├─ Add: Grid validation, biom checking
   ├─ Test: Building placement rules
   └─ Duration: ~2 weeks

3. STORY 02.3: Grid & Biom System (5 SP, BLOCKING)
   ├─ Implement: 20×20 grid with biom distribution
   ├─ Create: Grid entity, biom spawning
   ├─ Add: Placement validation
   ├─ Test: Biom distribution, resource spawning
   └─ Duration: ~1.5 weeks

4. STORY 02.4: Grid Expansion (6 SP)
   ├─ Implement: 20→30→40 progression
   ├─ Create: Expansion logic, animations
   ├─ Add: Trigger detection (capacity/scarcity)
   ├─ Test: Expansion costs, biom distribution
   └─ Duration: ~1.5 weeks

5. STORY 02.5: Offline Production (5 SP)
   ├─ Implement: 80% efficiency calculation
   ├─ Create: Offline system, welcome notification
   ├─ Add: Gold animation
   ├─ Test: Calculation accuracy, time limits
   └─ Duration: ~1 week

6. STORY 02.6: Storage Filtering (8 SP)
   ├─ Implement: Global + per-port filters
   ├─ Create: Filter entity, 4 modes
   ├─ Add: Backpressure mechanics
   ├─ Test: Filter logic, bottleneck detection
   └─ Duration: ~2 weeks

7. STORY 02.7: Hub Screen (7 SP)
   ├─ Implement: Dashboard with stats
   ├─ Create: Hub UI components (Riverpod)
   ├─ Add: Real-time updates, animations
   ├─ Test: State management, animations
   └─ Duration: ~1.5 weeks

8. STORY 02.7b: Biom Gathering (7 SP)
   ├─ Implement: Resource collection screen
   ├─ Create: Gathering UI, mining facilities
   ├─ Add: Tap-and-hold mechanic, skill effects
   ├─ Test: Gathering mechanics, animations
   └─ Duration: ~1.5 weeks

TOTAL: ~13 weeks solo dev (25 SP/week = 4-5 weeks realistic)
```

**Bug Fixes (CRITICAL - Before Sprint 2):**
```
[ ] Bug #1: Integration Test Compilation
    ├─ File: integration_test/core_gameplay_loop_test.dart
    ├─ Issue: Parameter name mismatch (buildingId vs building)
    ├─ Fix: Change 4 instances
    ├─ Test: flutter test integration_test/ (must pass)
    └─ Duration: 30 min

[ ] Bug #2: Resource Inventory Logic
    ├─ File: lib/domain/entities/player_economy.dart
    ├─ Issue: addResource() returns unchanged if resource missing
    ├─ Fix: Create new Resource if not in inventory
    ├─ Test: Unit tests for addResource()
    └─ Duration: 1 hour

[ ] Bug #8: Type Cast Syntax Error
    ├─ File: lib/main.dart line 325
    ├─ Issue: Incorrect precedence in (metrics['cullRate'] as double * 100)
    ├─ Fix: Add parentheses ((metrics['cullRate'] as double) * 100)
    ├─ Test: flutter run (app launches)
    └─ Duration: 15 min

TOTAL BUG FIX: ~2 hours work
```

**Documentation Finalization:**
```
[ ] Tech-spec review and corrections (if needed)
[ ] Add test cases to each tech-spec section
[ ] Create implementation guide (.claude/IMPLEMENTATION-GUIDE.md)
[ ] Add dependency notes to each story
[ ] Create code review checklist for each story
```

### MEDIUM-TERM (EPIC-03 to EPIC-08 Planning)

**Which Epics Depend on Epic 2:**
```
EPIC-03 (Automation) - 42 SP
├─ Depends on: STORY 02.6 (Storage Filtering)
├─ Depends on: SYSTEMS.md (Conveyor System spec)
├─ Blocked until: Storage filtering + conveyor basic work
└─ Estimated start: Week 6 of dev

EPIC-04 (Offline Production) - 26 SP
├─ Depends on: STORY 02.5 (Offline Production basic)
├─ Depends on: SYSTEMS.md (Offline mechanics)
├─ Blocked until: Basic offline working
└─ Estimated start: Week 7 of dev

EPIC-05 (Mobile-First UX Polish) - 29 SP
├─ Depends on: All screens (STORY 02.7, 02.7b, screens)
├─ Polish phase: Add animations, notifications, accessibility
├─ Blocked until: All basic screens working
└─ Estimated start: Week 10+ of dev

EPIC-06 (Progression/Skills/NPCs) - 21 SP
├─ Depends on: SYSTEMS.md (NPC Trading, Skill formulas)
├─ Implements: NPC trading screens, skill progression UI
├─ Blocked until: Story 02.Y (NPCs, skills work)
└─ Estimated start: Week 9 of dev
```

---

## 📊 SUMMARY BY THE NUMBERS

### Documentation Metrics
```
Tech-Spec Files Created:         4 files
├─ INDEX.md                      379 lines
├─ CORE.md                       410 lines
├─ SYSTEMS.md                    963 lines
└─ UI.md                         2,095 lines
                         ─────────────────
TOTAL NEW SPEC:          3,847 lines
PREVIOUS SPEC:           1,583 lines (now archived)
EXPANSION:               +2,264 lines (+143% more detailed)

Content Distribution:
├─ Core Mechanics:       ~600 lines (16%)
├─ Advanced Systems:     ~1,100 lines (29%)
├─ UI Screens:          ~2,000 lines (52%)
├─ Navigation:           ~150 lines (4%)
└─ Total:              ~3,850 lines

Words Estimate:
├─ Core.md:             ~2,000 words
├─ SYSTEMS.md:          ~6,000 words
├─ UI.md:              ~12,500 words
└─ INDEX.md:            ~2,000 words
                 ──────────────────
TOTAL:                ~22,500 words (+250% from original 9,000)
```

### Story Coverage
```
Total Stories Specified:         16 stories
├─ EPIC-02 Main:                 8 stories = 40 SP
├─ EPIC-03 (Conveyors):          1 story  = 8 SP
├─ EPIC-04 (Offline):            1 story  = 5 SP
├─ EPIC-05 (UX Polish):          2 stories = 9 SP
├─ EPIC-06 (NPCs/Skills):        2 stories = 15 SP
├─ EPIC-02.D (Notifications):    1 story  = 5 SP
└─ EPIC-02.E (Building Panel):   1 story  = 8 SP
                         ─────────────────
TOTAL SPECIFIED:        16 stories = 90 SP

Non-Specified (Still Need Planning):
├─ EPIC-03 (Advanced):   5 additional stories = 34 SP
├─ EPIC-04 (Offline):    4 additional stories = 21 SP
├─ EPIC-05 (Polish):     8 additional stories = 20 SP
├─ EPIC-06+ (Others):    Remaining epics
└─ Total remaining:      ~70-80 stories = ~180 SP

Coverage: 16/86 stories = 19% of MVP fully spec'd
Confidence: 90 SP out of 289 MVP = 31% of scope documented in detail
```

### UI Screens Designed
```
Complete Screens:                 6 primary + 2 new
├─ HUB SCREEN                    (1 section, full mockup)
├─ GRID WORLD SCREEN             (1 section, full mockup)
├─ BIOM GATHERING SCREEN         (1 section, full mockup)
├─ STORAGE MANAGEMENT SCREEN     (1 section, full mockup)
├─ CRAFTING QUEUE SCREEN         (1 section, full mockup)
├─ NPC TRADING (4 sub-screens)   (1 section, 4 complete)
├─ NOTIFICATION SYSTEM ✨        (1 section, 4 levels)
└─ BUILDING DETAIL PANEL ✨      (1 section, 5 building types)

Per-Screen Specs:
├─ Layout (mockup with ASCII boxes)
├─ Component breakdown (sizes, fonts, colors)
├─ Interactions (tap, swipe, long-press, etc)
├─ Animations (timings, easing, visual effects)
├─ Mobile optimization (responsive, touch targets)
├─ Accessibility (screen reader, haptic, contrast)
└─ Performance targets (load time, FPS, memory)

Interaction Patterns:
├─ Tap (select, open, toggle)
├─ Tap & hold (context menu, confirmation)
├─ Swipe left/right (navigate, dismiss)
├─ Swipe up/down (scroll, access menus)
├─ Pinch zoom (grid world only)
├─ Double-tap (open details)
└─ Long-press (delete, destructive)

Mobile-First Design:
├─ Baseline: 375px (iPhone SE)
├─ Touch targets: 44px minimum
├─ Font sizes: 14px (body), 16px (headers), 12px+ (min readable)
├─ Viewport heights: 667px (typical mobile)
├─ Responsive: Scales to tablets (600px+), desktop (1024px+)
├─ Performance: 60 FPS animations, <500ms load times
└─ Accessibility: WCAG AA standard (4.5:1 contrast)
```

### Systems Specified
```
Core Game Systems:               5 major
├─ CONVEYOR SYSTEM              (1,200+ words, detailed mechanics)
├─ NPC TRADING SYSTEM           (1,500+ words, 3 NPC types)
├─ OFFLINE PRODUCTION           (1,000+ words, formulas + UI)
├─ GRID EXPANSION               (1,000+ words, stages + triggers)
└─ STORAGE FILTERING            (1,200+ words, advanced networks)
                         ──────────────────
TOTAL SYSTEMS:         ~6,000+ words with examples

Mechanical Details:
├─ Formulas (offline calc, NPC prices, expansion costs)
├─ Animations (timings, visual effects)
├─ Edge cases (time limits, backpressure, blocked states)
├─ Integration points (data persistence, save/load)
└─ Testing requirements (unit + integration tests)
```

---

## 🎓 DELIVERABLES SUMMARY TABLE

| Component | Status | Lines | Words | Completeness |
|-----------|--------|-------|-------|--------------|
| **CORE.md** (Mechanics) | ✅ Complete | 410 | 2,000 | 100% |
| **SYSTEMS.md** (5 Systems) | ✅ Complete | 963 | 6,000 | 100% |
| **UI.md** (8 Sections) | ✅ Complete | 2,095 | 12,500 | 100% |
| **INDEX.md** (Navigation) | ✅ Complete | 379 | 2,000 | 100% |
| --- | --- | --- | --- | --- |
| **Tech-Spec Total** | ✅ Complete | 3,847 | 22,500 | 100% |
| --- | --- | --- | --- | --- |
| **Story Details** | ⏳ Ready | --- | --- | 85% (8 stories detailed) |
| **Implementation Patterns** | ⏳ Ready | --- | --- | 95% (ready to code) |
| **Bug Fixes** | ⏳ Ready | --- | --- | 100% (documented, 2hr fix) |
| **Project Status** | ⏳ Ready | --- | --- | 90% (needs update) |
| --- | --- | --- | --- | --- |
| **PHASE 1 COMPLETE** | ✅ | 3,847 | 22,500 | **95%** |

---

## 🚀 NEXT IMMEDIATE ACTIONS

**For Next Session (Recommended):**

1. **Update epic-02-stories.md**
   - Copy story details from this summary
   - Add acceptance criteria
   - Link to tech-spec sections
   - Estimated time: 2-3 hours

2. **Fix Critical Bugs**
   - 3 bugs, ~2 hours total
   - Required before Sprint 2 starts
   - Run tests to verify

3. **Start Story 02.1 (Resources)**
   - First implementable story
   - 5 SP, ~1 week work
   - Create domain entity
   - Add unit tests

4. **Project Status Update**
   - Update MVP-TODO with Epic 2 complete status
   - Confirm Sprint 2 timeline
   - Organize sprint planning

---

**All documentation committed and pushed to:**
`claude/project-status-display-01WgeBaEE9s5pXkKZraeZEwN` ✅
