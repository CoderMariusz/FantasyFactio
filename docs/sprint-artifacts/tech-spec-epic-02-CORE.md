# Epic 2: Tier 1 Economy - Core Mechanics

**Part 1 of 3** | [Index & Navigation](tech-spec-epic-02-INDEX.md) | [Systems](tech-spec-epic-02-SYSTEMS.md) | [UI](tech-spec-epic-02-UI.md)

**Project:** Trade Factory Masters
**Epic:** EPIC-02 - Tier 1 Economy
**Date:** 2025-12-03
**Status:** ✅ COMPLETE

---

## Overview

EPIC-02 implementuje fundament systemu ekonomicznego gry Trade Factory Masters. W tej epice:

- **7 zasobów** w pełni sprecyzowanych
- **6 budynków** produkcyjnych
- **Grid system** (20×20 → 30×30 → 40×40)
- **System umiejętności** (Mining, Smelting, Trading)
- **Ekonomia gry** zweryfikowana (1000g w 120 minut)

System ekonomii Tier 1 jest zaprojektowany aby:
- Nauczyć graczy podstawowych mechanik ekonomicznych
- Wprowadzić koncepcję łańcuchów produkcyjnych
- Stworzyć motywację do automatyzacji
- Zapewnić 0-2 godziny rozgrywki w Tier 1

---

## Objectives and Scope

### IN SCOPE - EPIC 2 MVP

#### 1. Resources (7 Types)

**Raw Materials Table:**

| Resource | Gather Speed | Primary Biom | Base Value | Description |
|----------|--------------|--------------|------------|-------------|
| **Węgiel** (Coal) | 1.25s | Koppalnia | 1g | Basic fuel, fundamental |
| **Ruda Żelaza** (Iron Ore) | 1.25s | Koppalnia | 1g | Smelted to iron bars |
| **Drewno** (Wood) | 1.88s | Las | 1.5g | Common building material |
| **Kamień** (Stone) | 2.5s | Góry | 1g | Construction base |
| **Miedź** (Copper) | 5.0s | Góry | 5g | Rare, high value |
| **Wata** (Salt/Brine) | 1.88s | Jezioro | 2g | Chemical ingredient |
| **Sól** (Saltwater) | 3.75s | Jezioro | 3g | Valuable processing input |
| **Glina** (Clay) | 3.13s | Jezioro | 1.5g | Construction material |

**Processing Results (Smelted Products):**

| Product | Recipe | Time | Value | Purpose |
|---------|--------|------|-------|---------|
| **Żelazo** (Iron) | 30W + 30Rz | 50s | 3g | Crafting base |
| **Miedź R.** (Refined Copper) | 20W + 10M | 44s | 8g | Crafting component |
| **Beton** (Concrete) | 15K + 10G + 5Wa | 56s | 6g | Grid expansion |

**Resource Properties:**
- All resources renewable (infinite gathering possible)
- Gather speeds include Mining skill bonuses
- Base values used for NPC trading and farm income
- No decay in storage (safe to accumulate)

#### 2. Buildings (6 Types)

**Building Definitions Table:**

| Building | Size | Cost | Craft Time | Unlock | Function |
|----------|------|------|-----------|--------|----------|
| **Mining Facility** | 2×2 | FREE | 0s | Start | Gathers resource (+50% vs manual) |
| **Storage** | 2×2 | 5D+10K | 45s | Start | Hold 200 items (upgradeable) |
| **Smelter** | 2×3 | 15D+10K+5M | 70s | After 1st iron | Auto-craft smelted items |
| **Conveyor** | 1×1 | 2D+1Z | 5s/tile | After 1st iron | Transport (0.5 items/sec) |
| **Workshop** | 2×2 | 20D+15K+5Z | 60s | After 5 crafts | Auto-craft processed items |
| **Farm** | 3×3 | 25B+12Z+15D | 85s | After 2 trades | Convert items → gold |

**Building Details:**

##### Mining Facility (2×2)
- Free to place, no cost
- Must place on matching biom tile (Koppalnia/Las/Góry/Jezioro)
- Produces: 1 item per gather speed (adjustable by player)
- Passive income: Core gathering method
- Multiplier: +50% faster than manual gathering
- Skill affected: Mining skill (-5% time per level)

##### Storage (2×2)
- Cost: 5 Drewno + 10 Kamień (45s)
- Capacity: 200 items (upgradeable: +50 per upgrade)
- Function: Central inventory hub
- Can be placed anywhere
- Multiple storages possible
- Max items per resource: No hard limit (per type)

##### Smelter (2×3)
- Cost: 15 Drewno + 10 Kamień + 5 Miedź (70s)
- Unlock: After smelting 1st żelazo manually
- Process: Fuel + Ore → Product
- Example: 30 Węgiel + 30 Ruda → 1 Żelazo (50s)
- Queue: Multiple recipes can queue
- Skill affected: Smelting skill (-2% time per level)

##### Conveyor (1×1)
- Cost: 2 Drewno + 1 Żelazo (5s per tile)
- Unlock: After 1st żelazo smelted
- Speed: 0.5 items/second (1 item per 2 seconds)
- Capacity: 10 items max per tile
- Direction: 4-directional (N, S, E, W)
- Layering: Max 2 layers (3+ forbidden)
- Transport: Custom filtering possible (detailed in SYSTEMS)

##### Workshop (2×2)
- Cost: 20 Drewno + 15 Kamień + 5 Żelazo (60s)
- Unlock: After 5 successful manual crafts
- Process: Ingredients → Crafted item
- Example: 10 Żelazo → 1 Młotek (62s)
- Queue: Multiple recipes queue automatically
- Skill affected: Smelting skill applies (-2% time per level)

##### Farm Monetyzacyjna (3×3)
- Cost: 25 Beton + 12 Żelazo + 15 Drewno (85s)
- Unlock: After trading with 2 different NPCs
- Process: Any item → Gold
- Income: Item base value × (1 + Trading skill bonus)
- Core monetization: Main late-game income source
- Skill affected: Trading skill (+5% value per level)
- Offline: Operates at 80% efficiency when offline (detailed in SYSTEMS)

#### 3. Grid System

**Grid Progression:**

| Level | Size | Start | Trigger | Cost | Timeline |
|-------|------|-------|---------|------|----------|
| Start | 20×20 | 0 min | Game start | - | Immediate |
| Expand 1 | 30×30 | - | 6 buildings OR storage full | 50 beton | 35-40 min |
| Expand 2 | 40×40 | - | 4 Smelters + 2 Workshops + Farm | 100 beton | 70-80 min |

**Grid Details:**

##### Initial Grid (20×20)
- Size: 400 total tiles
- Biom distribution:
  - Koppalnia: ~24 tiles (6%, bottom area)
  - Las: ~32 tiles (8%, sides)
  - Góry: ~32 tiles (8%, edges)
  - Jezioro: ~24 tiles (6%, scattered)
  - Empty/neutral: ~288 tiles (72%, buildable)
- Placement: Player starts in center
- Practical capacity: ~20-25 buildings before tight

##### Tile Properties
```dart
class Tile {
  Vector2 position;
  String biom;        // koppalnia, las, gory, jezioro, empty
  bool occupied;      // Has building placed
  List<String> layers; // Building IDs (max 2 for conveyors)
  List<ResourceStack> resources; // Items on ground
}
```

##### Placement Rules

**Mining Facilities (Biom-Restricted):**
- MUST place on matching biom tile
- Valid bioms: Koppalnia, Las, Góry, Jezioro
- Produces correct resource for biom only
- Cannot place on empty/wrong biom

**Other Buildings (Flexible):**
- Can place ANYWHERE on buildable tile
- No biom requirements
- Flexible factory layout
- Only limitation: Space availability

**Conveyors (Layering):**
- Can place ANYWHERE
- Can stack: Max 2 layers allowed
- 3+ layers: INVALID (red visual feedback)
- Layer 1: Under buildings (slightly darker)
- Layer 2: Over buildings (bright visible)

##### Grid Expansion System

**Expansion Details:**
→ See [tech-spec-epic-02-SYSTEMS.md - Grid Expansion](tech-spec-epic-02-SYSTEMS.md#grid-expansion-system)

---

## Skill Progression

**Three Skills (Auto-Leveling)**

### Mining Skill
```
Effect: Increases resource gathering speed
Formula: Base speed * (1 - 0.02 * level)

Levels:
├─ Level 1: Base (no bonus)
├─ Level 5: -10% time (faster gathering)
├─ Level 10: -20% time
└─ Level 20: -40% time

Gain: +1 XP per 25 items gathered
Unlock: N/A (always available)

Example:
├─ Węgiel base: 1.25s
├─ At level 5: 1.25s * 0.9 = 1.125s
├─ At level 10: 1.25s * 0.8 = 1.0s
└─ Time saved: 25% faster
```

### Smelting Skill
```
Effect: Decreases craft cycle time
Formula: Base time * (1 - 0.02 * level)

Levels:
├─ Level 1: Base (no bonus)
├─ Level 5: -10% time
├─ Level 10: -20% time
└─ Level 20: -40% time

Gain: +1 XP per 10 successful smelter cycles
Unlock: First use of smelter

Example:
├─ Żelazo base: 50s
├─ At level 5: 50s * 0.9 = 45s
├─ At level 10: 50s * 0.8 = 40s
└─ 20% faster production
```

### Trading Skill
```
Effect: Increases item value (sell prices)
Formula: Base value * (1 + 0.05 * level)

Levels:
├─ Level 1: 1.0x (base)
├─ Level 5: 1.25x (25% more gold)
├─ Level 10: 1.5x (50% more gold)
└─ Level 20: 2.0x (double gold)

Gain: +1 XP per 5 NPC trades
Unlock: First NPC trade

Effect locations:
├─ NPC gold trades: Kupiec's offers worth more
├─ Farm income: Items worth more gold
└─ Economy: Accelerates late-game earnings

Example:
├─ Węgiel base: 1g
├─ At level 5: 1g * 1.25 = 1.25g per item
├─ At level 10: 1g * 1.5 = 1.5g per item
└─ Better monetization
```

**Skill Interaction:**

- Skills auto-level (no manual activation)
- All three skills stack additively
- Craft time bonuses from Smelting: Applied to all buildings
- No skill cap (can exceed level 10, no limit)
- Skills persist across sessions (saved data)

---

## Demolition System

**Mechanic:**
- Long-press building → Demolish dialog
- Confirmation required (prevent accidental loss)
- 80% refund of building cost
- Items inside fall to ground
- Ground items can be picked up or transported

**Execution:**
```
1. Player long-presses building (500ms hold)
2. Dialog appears: "Demolish [Building]?"
3. Show: Refund amount (80% of cost)
4. Show: Items inside (will drop)
5. Tap [YES] or [NO]

On YES:
├─ 80% cost refunded to inventory
├─ All items inside drop to ground
├─ Building removed from grid
├─ Tile marked as unoccupied
└─ Conveyors can pass through

On NO:
└─ Dialog closes, building preserved
```

**Refund Calculation:**
```
Original cost: 5 Drewno + 10 Kamień (45s craft)
Refund: 80%

Items returned: 4 Drewno + 8 Kamień
Time wasted: 9s (20% of 45s lost)

Formula: Each resource * 0.8, rounded down
```

**Use Cases:**
- Mistake placement (fix grid layout)
- Obsolete building (free up space)
- Restartegy (rebuild optimized)
- Cost: Small loss (20% of investment)

---

## Dependencies and Integration

**Depends On (EPIC-01):**
- ✅ Core gameplay loop working
- ✅ Building entity
- ✅ Resource entity
- ✅ Grid system
- ✅ Tap detection

**Required External:**
- Firebase (persistence)
- Riverpod (state management)
- JSON serialization

**Blocks (Future Epics):**
- → EPIC-03 (Automation - uses these building types)
- → EPIC-04 (Offline - uses production system)
- → EPIC-05 (UX - depends on these mechanics)
- → EPIC-06 (Skills - uses this system)

---

## Quick Reference: Key Formulas

### Gather Speed
```
Base speed - (Base speed * 0.02 * Mining level)

Example: Węgiel (1.25s) at level 5
= 1.25 - (1.25 * 0.02 * 5)
= 1.25 - 0.125
= 1.125s per item
```

### Craft Time
```
Base time - (Base time * 0.02 * Smelting level)

Example: Żelazo (50s) at level 5
= 50 - (50 * 0.02 * 5)
= 50 - 5
= 45s per craft
```

### Item Value
```
Base value * (1 + 0.05 * Trading level)

Example: Węgiel (1g) at level 5
= 1 * (1 + 0.05 * 5)
= 1 * 1.25
= 1.25g from farm
```

### Building Cost (in items)
```
All costs specified as resource stacks
Example: Storage = 5 Drewno + 10 Kamień
= 5 * 1.5g + 10 * 1g = 17.5g equivalent
```

---

## Testing Requirements

### Unit Tests (Suggested)
- [ ] All 7 resources have unique IDs
- [ ] All resources have valid gather speeds (> 0)
- [ ] All resources have base values > 0
- [ ] All 6 buildings have unique IDs
- [ ] All buildings have valid dimensions
- [ ] Skill calculations are accurate
- [ ] Demolition refund is 80% (not 100%)

### Integration Tests
- [ ] Mining produces correct resource for biom
- [ ] Building placement validates biom rules
- [ ] Grid expansion triggers at correct conditions
- [ ] Skills modify speeds correctly
- [ ] Skill XP gains are accurate

---

## Next Steps

→ Read [tech-spec-epic-02-SYSTEMS.md](tech-spec-epic-02-SYSTEMS.md) for advanced systems

---

**Status:** ✅ Complete
**Last Updated:** 2025-12-03
**Version:** 1.0 (Core mechanics only)
