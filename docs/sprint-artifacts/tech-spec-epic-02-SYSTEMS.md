# Epic 2: Tier 1 Economy - Game Systems

**Part 2 of 3** | [Index & Navigation](tech-spec-epic-02-INDEX.md) | [Core Mechanics](tech-spec-epic-02-CORE.md) | [UI Screens](tech-spec-epic-02-UI.md)

**Project:** Trade Factory Masters
**Epic:** EPIC-02 - Tier 1 Economy
**Date:** 2025-12-03
**Status:** ✅ COMPLETE (Reorganized)

---

## Overview

Part 2 covers the **3 game systems** specific to EPIC-02's Tier 1 economy. Systems that belong to later epics have been moved to their respective tech-specs.

**Systems Covered in This File:**
1. NPC Trading System - Commerce with dynamic NPCs
2. Grid Expansion System - World growth progression
3. Storage Item Filtering System - Basic inventory management

**Systems Moved to Other Epics:**
- ❌ ~~Conveyor System~~ → **[EPIC-03: tech-spec](../2-MANAGEMENT/epics/epic-03-tech-spec.md)** (Automation)
- ❌ ~~Offline Production~~ → **[EPIC-04: tech-spec](../2-MANAGEMENT/epics/epic-04-tech-spec.md)** (Offline Systems)

---

## 1. NPC Trading System

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

## 2. Grid Expansion System

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

## 3. Storage Item Filtering System (Basic)

> **Note:** Advanced filtering (multi-port, network configurations) moved to **[EPIC-03: tech-spec](../2-MANAGEMENT/epics/epic-03-tech-spec.md)**

### Overview

**Purpose:** Enable basic inventory management for Tier 1 economy

**Architecture (Basic):**
- Global accept/reject filter (per storage)
- Simple whitelist/blacklist

### Global Storage Filter

**Purpose:** Block certain items from entering storage

**Mechanics:**
```
When item arrives at storage input:
1. Check global filter
   ├─ IF accepted → Enter storage
   └─ IF rejected → Stay on ground / source

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

### Implementation Notes

**Data Structure:**
```dart
class StorageFilter {
  FilterMode mode;           // ALLOW_ALL, WHITELIST, BLACKLIST
  List<String> filteredItems; // Resource types
  DateTime lastModified;
}

class StorageBuilding {
  String id;
  Vector2 position;
  List<ResourceStack> inventory;
  StorageFilter globalFilter;
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
  }
}
```

---

## Quick Reference: Formulas

### NPC Price Calculation
```
finalPrice = basePrice * demandMultiplier * (1 + 0.05 * tradingLevel)

demandMultiplier = 1.0 - (timesSoldThisSession * 0.02) + (minutesSinceLast * 0.01)
```

### Grid Expansion Cost
```
Expansion 1: 50 beton = 50 * 56s = 2,800s ≈ 47 minutes
Expansion 2: 100 beton = 100 * 56s = 5,600s ≈ 93 minutes
```

---

## Cross-References

| System | Location | Purpose |
|--------|----------|---------|
| **Conveyor System** | [epic-03-tech-spec.md](../2-MANAGEMENT/epics/epic-03-tech-spec.md) | Full automation transport |
| **Offline Production** | [epic-04-tech-spec.md](../2-MANAGEMENT/epics/epic-04-tech-spec.md) | Passive income calculation |
| **Advanced Filtering** | [epic-03-tech-spec.md](../2-MANAGEMENT/epics/epic-03-tech-spec.md) | Multi-port, splitter filtering |
| **Mobile UX** | [epic-05-tech-spec.md](../2-MANAGEMENT/epics/epic-05-tech-spec.md) | Touch controls, animations |

---

## Testing Requirements

### Unit Tests
- [ ] NPC Kupiec price fluctuation (demand model)
- [ ] Inżynier barter offers (no fluctuation)
- [ ] Nomada offer selection (randomization + weighting)
- [ ] Grid expansion triggers (capacity AND scarcity)
- [ ] Basic storage filter logic (whitelist/blacklist)

### Integration Tests
- [ ] NPC trade updates player gold
- [ ] Grid expansion preserves all buildings
- [ ] Storage filter blocks correct items

---

## Next Steps

→ Read [tech-spec-epic-02-UI.md](tech-spec-epic-02-UI.md) for all 6 user interface screens

---

**Status:** ✅ Complete (Reorganized)
**Last Updated:** 2025-12-03
**Version:** 2.0 (Systems moved to respective epics)
