# Epic 2: Tier 1 Economy - Advanced Systems

**Part 2 of 3** | [Index & Navigation](tech-spec-epic-02-INDEX.md) | [Core Mechanics](tech-spec-epic-02-CORE.md) | [UI Screens](tech-spec-epic-02-UI.md)

**Project:** Trade Factory Masters
**Epic:** EPIC-02 - Tier 1 Economy
**Date:** 2025-12-03
**Status:** ✅ COMPLETE

---

## Overview

Part 2 covers the **5 advanced game systems** that define EPIC-02's complex mechanics. These systems build on the core entities (resources, buildings, grid) and provide the depth that makes the economy feel alive and strategic.

**Systems Covered:**
1. Conveyor System - Item transportation and distribution
2. NPC Trading System - Commerce with dynamic NPCs
3. Offline Production System - Passive income mechanics
4. Grid Expansion System - World growth progression
5. Storage Item Filtering System - Advanced inventory management

---

## 1. Conveyor System (Complete)

### Overview

**Purpose:** Transport items between buildings and filter flows based on player rules

**Core Mechanics:**
- Linear 1×1 tiles transporting items in cardinal directions
- Speed: 0.5 items per second (1 item per 2 seconds)
- Max 2 layers allowed per tile (3+ layers invalid)
- Supports 4-directional placement (N, S, E, W)
- Custom filtering with splitter outputs
- Capacity: 10 items max per tile

### Conveyor Specifications

**Cost & Placement:**
- Cost: 2 Drewno + 1 Żelazo per tile (5s craft time each)
- Unlock: After first żelazo smelted
- Can place ANYWHERE (no biom restrictions)
- Max 2 layers: Layer 1 under buildings (darker), Layer 2 over buildings (bright)

**Transport Mechanics:**
```
Movement Rate: 0.5 items/second
Direction: 4-way (North, South, East, West)
Queuing: FIFO (first in, first out)
Capacity per tile: 10 items (backpressure stops input)
```

**Connection Rules:**
- Connects to building INPUT/OUTPUT ports
- Connects to other conveyor tiles in direction
- Invalid connections blocked with red visual feedback
- No connection = item falls to ground (dropped)

### Filtering System

**3-Mode Filtering:**

**Mode 1: Accept All (Default)**
- All items pass through without restriction
- Connects to any output

**Mode 2: Whitelist (Include-Only)**
- Specify 1-3 resource types to accept
- All others blocked (backed up on conveyor)
- Example: Coal + Iron Ore only (blocks Copper)

**Mode 3: Blacklist (Exclude)**
- Specify 1-3 resource types to reject
- All others pass through
- Example: Block Sól (allow everything else)

**Mode 4: Single Type**
- Accept ONLY one specific resource
- All others blocked
- Example: Wood ONLY

### Splitter System

**Purpose:** Distribute items across multiple outputs

**Mechanics:**
```
1 Input → Multiple Outputs (2-3 directions)
Distribution: Round-robin to available outputs
If destination full: Try next output, then wait
If all full: Backpressure stops input

Example:
Input from Smelter → Output A (Workshop), Output B (Farm)
Coal goes round-robin: Coal #1→A, Coal #2→B, Coal #3→A...
```

**Splitter Rules:**
- Max 3 output directions per splitter
- Must have at least 1 valid output
- Item loses on missing outputs (falls to ground)
- Visual feedback: Highlight active output (green)

### Layering System

**Layer 1 (Under Buildings):**
- Slightly darker visually
- Conveyors appear beneath structures
- Can be covered by buildings
- Used for main distribution lines

**Layer 2 (Over Buildings):**
- Bright and clearly visible
- Conveyors appear above structures
- Used for overflow or secondary routes
- 2-layer max per tile enforced

**Invalid Layering:**
- 3+ layers on same tile: RED visual feedback
- Player prevented from placing 3rd layer
- Error message: "Maximum conveyor layers reached"

### Visual Feedback

**Item Flow Indicators:**
- Green highlight: Item moving normally
- Yellow highlight: Item waiting in queue (backpressure)
- Red highlight: Invalid connection or blocked
- Animated item icons: Show direction and progress
- Smoke effect: Overload (too many items)

### Implementation Notes

**Data Structure:**
```dart
class ConveyorTile {
  Vector2 position;
  Direction direction;        // N, S, E, W
  int layer;                  // 1 or 2
  List<ResourceStack> queue;  // Items in transit (max 10)
  FilterMode filterMode;      // ALLOW_ALL, WHITELIST, BLACKLIST, SINGLE
  List<String> filterList;    // Resource types to filter
  SplitterConfig? splitter;   // If multi-output
}
```

**Cycle Logic:**
```
Every 2 seconds (2000ms / 0.5 items/sec):
1. Check each tile's queue
2. For each item in queue:
   - Check filter rules
   - If passes: Move to next tile OR building input
   - If blocked: Stay in queue (backpressure)
   - If no destination: Drop to ground
3. Check input ports for new items
4. Render flow visualization
```

---

## 2. NPC Trading System

### Overview

**Purpose:** Provide commerce beyond farming, introduce risk/reward decision-making

**3 NPC Types:**
1. **Kupiec** (Merchant) - Gold trading with dynamic prices
2. **Inżynier** (Engineer) - Barter system for rare resources
3. **Nomada** (Nomad) - Special offers, limited inventory

### Kupiec (Merchant) - Gold Prices

**Mechanics:**
- Buys any resource for gold
- Price fluctuates based on supply/demand
- Base prices: See Resource table in CORE.md
- High demand (sold to Kupiec many times) → Price DECREASES
- Low demand (not sold recently) → Price INCREASES

**Price Fluctuation Formula:**
```
Kupiec base value + Trading skill bonus + demand modifier
```

**Dynamic Pricing Example:**
```
Coal base: 1g
Sold to Kupiec 10 times in this session: -20% → 0.8g
Not sold for 5 minutes: +10% → 1.1g
Trading skill level 5: +25% → 1.375g

Final: 1g * 0.8 * 1.1 * 1.25 = 1.1g per coal
```

**Trader Properties:**
- Always available (no cooldown)
- Buys in bulk (no limit per transaction)
- Updates prices every game minute (60s)
- Memory: Tracks demand across session
- Resets each game restart

### Inżynier (Engineer) - Barter System

**Mechanics:**
- Trades items for items (no gold)
- Offers 3 fixed barter ratios
- Ratios focus on crafting materials
- Useful for skipping tedious gathering

**Fixed Barter Offers:**
```
OFFER 1: 5 Coal + 5 Iron Ore → 1 Refined Copper
  Purpose: Skip 44s smelting time
  Saves: 44s craft + fuel cost
  Cost: 10 resources for 1 output

OFFER 2: 10 Wood → 5 Stone
  Purpose: Convert common → less common
  Saves: ~20s gathering time
  Cost: 2:1 wood-to-stone

OFFER 3: 3 Copper → 1 Beton (partial recipe)
  Purpose: Trade rare → useful
  Saves: Copper grinding, advances expansion
  Cost: High (3 copper = 15g value)
```

**Trader Properties:**
- 3 fixed offers (no haggling)
- Unlimited swaps (no cooldown)
- No price fluctuation
- Useful for strategic planning
- Available after first smelter built

### Nomada (Nomad) - Special Offers

**Mechanics:**
- Limited inventory (3 items at a time)
- Offers change every 2 game hours
- Special bundle deals
- Random + player-influenced selections
- Risk/reward: Limited time, attractive prices

**Nomad Special Offers:**
```
OFFER POOL (changes every 120 minutes):
- 50 Coal for 75g (1.5g each, above base)
- 20 Iron Ore + 10 Coal for 80g (direct sale)
- 1 Refined Copper for 10g (below base 8g!)
- Wood bundle: 100 Wood for 120g
- Seasonal rare: 1 Copper for 5g (steal!)
```

**Selection Logic:**
```
Randomly pick 3 offers from pool
Weight by player demand:
- If player recently bought Wood → offer more Wood
- If player recently ignored Copper → offer Copper cheap
```

**Trader Properties:**
- 3 items per visit
- Changes every 2 hours (real-time or game-time)
- First offer free, others 100g negotiation fee
- No quantity discount (buy exact amount or nothing)
- Limited time creates urgency

### NPC Interaction Flow

**UI Flow:**
```
Player → Tap NPC → NPC Dialog Screen
  │
  ├─→ Kupiec: Select resource + quantity → Confirm → Gold earned
  ├─→ Inżynier: Select offer → Confirm → Resources traded
  └─→ Nomada: View 3 offers → Select → Confirm → Trade
```

**Audio/Visual:**
- Dialog open: Slide in from side (200ms)
- Transaction: Gold counter animation (satisfying)
- Price drop: Green highlight (profit)
- Price spike: Red highlight (expensive)
- Nomada: Special sound for limited offer

---

## 3. Offline Production System

### Overview

**Purpose:** Reward players for returning, provide passive income, create session motivation

**Core Mechanic:** Farm produces at 80% efficiency while offline

### Offline Production Calculation

**Formula:**
```
offlineTimeSeconds = returnTime - lastLogoutTime

itemsProcessedInQueue = MIN(
  farm.inputBuffer.length,
  (offlineTimeSeconds / itemCycleTime) * 0.80
)

goldEarned = itemsProcessedInQueue * baseValue * (1.0 + tradingSkillBonus)
```

**Example Calculation:**
```
Player logs out with Farm queue:
- 50 Węgiel in input
- 30 Ruda Żelaza in input
- Item cycle time: 3 seconds

Offline for: 2 hours (7,200 seconds)

Processing calculation:
- Items that could process: 7,200s / 3s = 2,400 items
- At 80% efficiency: 2,400 * 0.80 = 1,920 items
- Limited by queue: MIN(1,920, 80) = 80 items
- All 50 Węgiel + 30 Ruda processed

Gold earned:
- Węgiel (base 1g): 50 * 1g * 1.0 = 50g
- Ruda (base 1g): 30 * 1g * 1.0 = 30g
- Total: 80g earned offline
```

**Key Rules:**
- 80% efficiency (not 100%, encourages active play)
- Capped by input buffer length (can't create items)
- Respects farm processing speed
- Trading skill multiplier applies
- NO overflow losses (items stay in queue if can't process)
- NO decay for storage items (safe to log off)

### Welcome-Back Notification System

**Trigger:** When player logs in after offline time > 5 minutes

**Notification Screen Elements:**

1. **Title & Time Display**
   ```
   "Welcome Back!"
   "Away for: 2 hours 34 minutes"
   ```

2. **Earnings Breakdown**
   ```
   Farm Production Summary:
   ├─ Węgiel (50 items): 50g
   ├─ Ruda Żelaza (30 items): 30g
   ├─ Trading Skill Bonus (+15%): +12g
   └─ TOTAL: 92g
   ```

3. **Gold Animation**
   - Duration: 2 seconds
   - Counter animates from 0 → 92g
   - Coins fall from top, accumulate at bottom
   - Satisfying sound effects (clink, accumulate, complete)
   - +XP notification (earned 18 XP from 18 trades)

4. **Action Buttons**
   - [OK] - Close and start playing
   - [View Breakdown] - More details (optional)
   - [Continue Offline] - Stay offline longer (future feature)

### Offline Calculation Timing

**When Calculated:**
- On game launch, if lastLogoutTime exists
- Before any player action
- Used to populate welcome notification
- Farm input buffer updated

**Storage of Calculation:**
```
PlayerData {
  lastLogoutTime: DateTime
  lastSessionGold: int (calculated offline gold)
  lastOfflineMinutes: int (time away)
  farmQueueAtLogout: List<Resource> (saved)
}
```

**Edge Cases:**
- Device time changed backward: Use 0 minutes offline
- Farm building demolished: No offline production
- Game crash: Last logoutTime not updated (no production)
- Time > 30 days: Cap at 30 days max (prevent exploits)

### Premium Features (Future)

These are outlined in tech-spec but NOT in MVP:
- Offline production > 100% (premium boost)
- Skip welcome notification (premium setting)
- Offline time multiplier (2x production, premium)
- Scheduled farming (set production for specific hours)

---

## 4. Grid Expansion System

### Overview

**Purpose:** Expand world as player progresses, teach resource management, gate production

**3-Stage Progression:**
```
Stage 1: 20×20 (400 tiles, starting)
Stage 2: 30×30 (900 tiles, ~35-40 min playtime)
Stage 3: 40×40 (1,600 tiles, ~70-80 min playtime)
```

### Expansion Triggers

**Dual-Trigger Logic (Either One Triggers Expansion):**

**Trigger A: Building Capacity**
```
Condition: Player has placed 6+ buildings
Action: Unlock grid expansion
Cost: 50 Beton (for first expansion)

Timeline: ~15-20 minutes
- Mining facility: ~3 min
- Storage: ~1 min
- Smelter: ~2 min
- Conveyor chains: ~5 min
- Workshop: ~2 min
- 6th building: ~40 min craft time

Total: 6 buildings by ~30 minutes possible
```

**Trigger B: Resource Scarcity**
```
Condition: Storage full AND biom resources gathered 80%+
Action: Unlock grid expansion
Cost: 50 Beton (same)

Timeline: ~20-35 minutes
- Intensive gathering from single bioms
- Storage reaches 200 items limit
- Need more mining locations
```

**Winner: Whichever condition hits first determines expansion time**

### Expansion Mechanics

**Stage 1→Stage 2 Expansion (20×20 → 30×30):**
```
Cost: 50 Beton
Prerequisites: 6 buildings OR storage full
Craft Time: 50 Beton * 56s per beton = 2,800 seconds ≈ 47 minutes

New Grid Size: 30×30 = 900 tiles (up from 400)
New Area: 500 new tiles (55% growth)
All buildings: Preserved in original center positions
```

**Stage 2→Stage 3 Expansion (30×30 → 40×40):**
```
Cost: 100 Beton (doubled cost)
Prerequisites: 4 Smelters + 2 Workshops + 1 Farm placed
Craft Time: 100 Beton * 56s = 5,600 seconds ≈ 93 minutes

New Grid Size: 40×40 = 1,600 tiles (up from 900)
New Area: 700 new tiles (77% growth)
All buildings: Preserved in center area
Timeline: ~70-80 minutes into session
```

### Biom Distribution After Expansion

**Initial 20×20 Distribution:**
```
Koppalnia (Mining): ~24 tiles (6%)
Las (Forest): ~32 tiles (8%)
Góry (Mountains): ~32 tiles (8%)
Jezioro (Lake): ~24 tiles (6%)
Empty/Buildable: ~288 tiles (72%)
```

**New Bioms Added (30×30 Expansion):**
```
New tiles: 500
Additional bioms:
├─ Koppalnia: +8 tiles (on edges)
├─ Las: +12 tiles (spread)
├─ Góry: +12 tiles (corners)
└─ Jezioro: +8 tiles (scattered)

Total distribution remains ~6-8% each
```

**New Bioms Added (40×40 Expansion):**
```
New tiles: 700
Additional bioms:
├─ Koppalnia: +12 tiles
├─ Las: +18 tiles
├─ Góry: +18 tiles
└─ Jezioro: +12 tiles

Total distribution consistent ~6-8% each
```

### Expansion Animation

**Visual Sequence (1.5 seconds total):**
```
T=0ms: Player taps "Confirm Expand"
T=100ms: Fade to white overlay (fade in, 200ms)
T=300ms: New grid appears, buildings still visible
T=500ms: New bioms render with color transition (500ms)
T=800ms: New area highlights with pulsing light effect
T=1000ms: Camera zooms to fit new grid (500ms)
T=1500ms: Overlay fades out, expansion complete

Audio: Whoosh (start) + chime (complete)
```

**No Building Loss:** All buildings and items preserved at exact coordinates

### Grid Storage & Performance

**Memory Usage per Expansion:**
```
20×20 = 400 tiles × 50 bytes = ~20 KB
30×30 = 900 tiles × 50 bytes = ~45 KB
40×40 = 1,600 tiles × 50 bytes = ~80 KB

Total for max grid: <1 MB (acceptable)
```

**Performance Considerations:**
- Partial rendering: Only visible tiles rendered
- Biom culling: Off-screen bioms not processed
- Building culling: Off-screen buildings skipped
- Target FPS: 60 FPS on budget Android

---

## 5. Storage Item Filtering System

### Overview

**Purpose:** Enable advanced factory automation with strategic item routing

**Architecture:**
- Global accept/reject filter (per storage)
- Per-port input/output filtering (4 modes each)
- Advanced multi-storage networks possible
- Visual feedback and error recovery

### Global Storage Filter

**Purpose:** Block certain items from entering storage

**Mechanics:**
```
When item arrives at storage input:
1. Check global filter
   ├─ IF accepted → Enter storage
   └─ IF rejected → Bounce back on conveyor

Global filter options:
├─ ACCEPT_ALL (default)
├─ ACCEPT_LIST (whitelist 1-5 items)
└─ REJECT_LIST (blacklist 1-5 items)
```

**Configuration UI:**
```
Storage Settings Menu:
┌─────────────────────────────────┐
│ Global Input Filter             │
├─────────────────────────────────┤
│ ○ Accept all items             │
│ ○ Accept only: [+] Coal, Iron  │
│ ○ Reject: [+] Copper, Miedź    │
└─────────────────────────────────┘

[Save] [Cancel]
```

### Per-Port Filtering

**Architecture:**
```
Storage has 2 sides (or 4 sides depending on design):
- Input Port (left): Items flowing IN
- Output Port (right): Items flowing OUT

Each port has own filter configuration
```

**4 Filtering Modes per Port:**

**Mode 1: Accept All (ALLOW_ALL)**
- Default mode
- All items pass through
- No filtering applied
- Visual: Green checkmark

**Mode 2: Whitelist (ACCEPT_ONLY)**
- Specify 1-3 resource types
- ONLY these items pass
- All others blocked/backed up
- Visual: Green items, red items rejected
- Example: Accept ONLY [Coal, Iron Ore]

**Mode 3: Blacklist (REJECT)**
- Specify 1-3 resource types
- These items BLOCKED
- All others pass through
- Visual: Red X for blocked items
- Example: Reject [Copper, Miedź]

**Mode 4: Single Type (SINGLE)**
- Accept ONLY one specific item
- Strictest mode
- All others rejected
- Visual: Clear indicator of single type
- Example: [Coal] ONLY

### Filtering Logic Flow

**Input Port Filtering:**
```
Item → Arrives at storage input
       │
       ├→ Check global filter
       │  ├─ ACCEPT_ALL? YES → Enter storage
       │  ├─ Whitelist matches? YES → Enter storage
       │  └─ Blacklist matches? YES → Reject (bounce back)
       │
       └→ If rejected → Bounce back on input conveyor
                        Backpressure stops source
```

**Output Port Filtering:**
```
Item → Ready to leave storage
       │
       ├→ Check output port filter
       │  ├─ ALLOW_ALL? YES → Exit to conveyor
       │  ├─ Whitelist matches? YES → Exit to conveyor
       │  ├─ Blacklist blocks? YES → Try next port
       │  └─ SINGLE type match? YES → Exit to conveyor
       │
       ├→ If no port accepts → Stay in storage
       ├→ If port full (backpressure) → Try next port
       └→ If all ports blocked → Item queued (visual indicator)
```

### Advanced Network Example

**3-Storage Production Network:**

```
Flow:
  Mining → Conveyor → [STORAGE A] → Conveyor → [SMELTER]
                            ↓
                      Filters coal+ore

  Smelter → Conveyor → [STORAGE B] → Conveyor → [WORKSHOP]
                            ↓
                      Filters smelted items

  Workshop → Conveyor → [STORAGE C] → Conveyor → [FARM]
                            ↓
                      Filters finished goods
```

**Detailed Configuration:**

**STORAGE A (Input from Mining):**
```
Global: ACCEPT_ALL
Input Port (from conveyor):
  Mode: WHITELIST
  Items: [Coal, Iron Ore, Wood]

Output Port (to Smelter):
  Mode: WHITELIST
  Items: [Coal, Iron Ore]
  Purpose: Only ore+fuel go to smelter
```

**STORAGE B (Output from Smelter):**
```
Global: ACCEPT_LIST
  Items: [Żelazo, Miedź Ref., Beton]
  Purpose: Only smelted items enter

Input Port (from conveyor):
  Mode: SINGLE
  Item: [Żelazo]
  Purpose: Only iron ingots stored here

Output Port (to Workshop):
  Mode: ALLOW_ALL
  Purpose: Send to workshop freely
```

**STORAGE C (Output from Workshop):**
```
Global: REJECT_LIST
  Items: [Coal, Iron Ore]
  Purpose: Raw materials never enter

Input Port (from conveyor):
  Mode: WHITELIST
  Items: [Młotek, Narzędzia, Materiały]
  Purpose: Only finished goods

Output Port (to Farm):
  Mode: SINGLE
  Item: [Any item, for monetization]
  Purpose: Farm accepts one type at a time
```

### Visual Feedback System

**Item Flow Indicators:**

**Green Items:** Accepted, flowing normally
```
Visual: Green highlight, smooth movement
Sound: Light chime as items move
```

**Yellow Items:** Queued, waiting (backpressure)
```
Visual: Yellow highlight, pulsing animation
Sound: None (normal wait state)
```

**Red Items:** Rejected, bouncing back
```
Visual: Red X overlay, bounce-back animation
Sound: Error buzz
Message: "This storage doesn't accept [Coal]"
```

**Port Status Indicators:**
```
Port open (green): ✓ Items can flow
Port closed (red): ✗ No items accept
Port full (yellow): ⚠ Waiting for space
```

### Error Handling & Recovery

**Scenario 1: Item Stuck in Storage**
```
Cause: All output ports reject item
Display: "⚠ Coal stuck in Storage A"
Action: Tap notification → Storage settings
Fix: Change output port filters to accept Coal
Recovery: Item immediately exits (auto-retry)
```

**Scenario 2: Conveyor Backpressure**
```
Cause: Storage full, can't accept items
Display: Yellow pulsing items on conveyor
Action: Automatic retry every 5 seconds
Fix: Player empties storage, backpressure releases
Recovery: Items resume flowing
```

**Scenario 3: No Valid Routes**
```
Cause: No conveyor connected to output port
Display: Items accumulate in storage (warning)
Action: Tap storage → "No output connected"
Fix: Build conveyor to output port
Recovery: Items start exiting
```

### Filtering Progression Difficulty

**Early Game (First Storage):**
- Simple: ACCEPT_ALL mode only
- No filtering complexity
- Player learns basic transport

**Mid Game (After Smelter):**
- Introduce: WHITELIST mode
- Example: "Only accept smelted items"
- Player controls item types

**Late Game (Before Farm):**
- Introduce: BLACKLIST and SINGLE modes
- Complex: Multi-storage networks
- Advanced players build sophisticated factories

### Implementation Notes

**Data Structure:**
```dart
class StorageFilter {
  FilterMode mode;           // ALLOW_ALL, WHITELIST, BLACKLIST, SINGLE
  List<String> filteredItems; // Resource types (if whitelist/blacklist)
  String singleItem;         // If SINGLE mode
  DateTime lastModified;
}

class StorageBuilding {
  String id;
  Vector2 position;
  List<ResourceStack> inventory;
  StorageFilter globalFilter;
  Map<String, StorageFilter> portFilters; // 'input', 'output_n'
}
```

**Filtering Logic Function:**
```dart
bool canAcceptItem(Resource item, StorageFilter filter) {
  switch (filter.mode) {
    case ALLOW_ALL:
      return true;
    case WHITELIST:
      return filter.filteredItems.contains(item.type);
    case BLACKLIST:
      return !filter.filteredItems.contains(item.type);
    case SINGLE:
      return item.type == filter.singleItem;
  }
}
```

---

## System Interactions

**Production Chain with Filtering:**
```
Mining → Conveyor[Coal+Ore filter] → Storage A
    ↓
Smelter ← Conveyor[Iron+Copper routes]
    ↓
Smelted → Conveyor → Storage B[smelted filter]
    ↓
Workshop ← Conveyor[iron items only]
    ↓
Finished → Conveyor → Storage C[finished only]
    ↓
Farm ← Conveyor[all items accepted]
```

**Offline Production with NPC:**
- Farm fills queue from storage
- Player logs off
- Returns after 2 hours
- Offline: Farm processes 80% of queue
- NPC Kupiec adjusts price down (oversupply of gold)
- Welcome notification shows earnings
- Grid expansion may have triggered

---

## Dependencies and Integration

**Depends On (EPIC-02 Part 1):**
- ✅ Resources (7 types defined)
- ✅ Buildings (6 types including storage/farm/smelter)
- ✅ Grid System (placement, biom rules)
- ✅ Skills (Trading skill affects NPC prices & farm income)
- ✅ Conveyor building type

**Blocks (EPIC-03):**
- → Automation system (uses conveyor + filtering)
- → Production chains (uses offline mechanics)

**Integration Points:**
- NPC prices logged to analytics (future insights)
- Grid expansion triggers achievements
- Offline production persists across sessions
- Filtering enables complex automation strategies

---

## Quick Reference: Formulas

### Offline Production
```
itemsProcessedOffline = MIN(
  queueLength,
  (offlineSeconds / cycleTime) * 0.80
)

goldOffline = itemsProcessed * baseValue * (1 + tradingBonusPercent)
```

### NPC Price Calculation
```
finalPrice = basePrice * demandMultiplier * (1 + 0.05 * tradingLevel)

demandMultiplier = 1.0 - (timesOldThisSession * 0.02) + (minutesSinceLast * 0.01)
```

### Grid Expansion Cost
```
Expansion 1: 50 beton = 50 * 56s = 2,800s ≈ 47 minutes
Expansion 2: 100 beton = 100 * 56s = 5,600s ≈ 93 minutes
```

### Conveyor Movement
```
itemsPerSecond = 0.5
timePerItem = 2 seconds
capacityPerTile = 10 items
```

---

## Testing Requirements

### Unit Tests
- [ ] NPC Kupiec price fluctuation (demand model)
- [ ] Inżynier barter offers (no fluctuation)
- [ ] Nomada offer selection (randomization + weighting)
- [ ] Offline production calculation (formula accuracy)
- [ ] Offline time limits (min 5 min, max 30 days)
- [ ] Grid expansion triggers (capacity AND scarcity)
- [ ] Conveyor filter modes (all 4 modes work)
- [ ] Storage filter logic (whitelist/blacklist behavior)
- [ ] Backpressure mechanics (items queue correctly)

### Integration Tests
- [ ] NPC trade updates player gold
- [ ] Offline production persists across sessions
- [ ] Grid expansion preserves all buildings
- [ ] Welcome notification shows correct amount
- [ ] Conveyor + filtering chain works end-to-end
- [ ] 3-storage network produces correctly

---

## Next Steps

→ Read [tech-spec-epic-02-UI.md](tech-spec-epic-02-UI.md) for all 6 user interface screens

---

**Status:** ✅ Complete
**Last Updated:** 2025-12-03
**Version:** 1.0 (5 major systems, fully specified)
