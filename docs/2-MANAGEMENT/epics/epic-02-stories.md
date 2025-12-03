# Epic 2: Tier 1 Economy - Detailed Stories

<!-- AI-INDEX: epic, stories, acceptance-criteria, implementation -->

**Epic:** EPIC-02 - Tier 1 Economy
**Total SP:** 26
**Duration:** 2-3 weeks (Sprints 2-3)
**Status:** 📋 Ready for Implementation
**Tech-Spec:** [epic-02-tech-spec.md](epic-02-tech-spec.md)
**Detailed Specs:**
- [tech-spec-epic-02-INDEX.md](../../sprint-artifacts/tech-spec-epic-02-INDEX.md)
- [tech-spec-epic-02-CORE.md](../../sprint-artifacts/tech-spec-epic-02-CORE.md)
- [tech-spec-epic-02-SYSTEMS.md](../../sprint-artifacts/tech-spec-epic-02-SYSTEMS.md)
- [tech-spec-epic-02-UI.md](../../sprint-artifacts/tech-spec-epic-02-UI.md)

---

## STORY-02.1: Resource Definitions (2 SP)

### Objective
Implement all 7 game resources with their properties, gather speeds, market values, and biome associations. Create entity models and repositories for resource storage and retrieval.

### User Story
As a game developer, I need to define all 7 resources with their game properties so that the gathering and economy systems have concrete data to work with.

### Description
This story implements the foundational resource system. All resources are gathered from specific biomes, have different gather speeds, and different base market values. This creates resource differentiation and strategy depth.

### Acceptance Criteria

#### AC1: Resource Entity Complete
```dart
✅ Resource class implements:
  - id: String (e.g., 'wegiel', 'drewno')
  - name: String (Polish name)
  - gatherSpeed: Duration (time to gather 1 item)
  - biome: String (where it's found)
  - baseValue: int (gold equivalent)
  - rarity: ResourceRarity enum (common, uncommon, rare)
  - maxStackSize: int (how many stack in 1 inventory slot)
```

#### AC2: All 7 Resources Defined
```
✅ Węgiel (Coal):
   - gatherSpeed: 1.25s
   - biome: Koppalnia (Mine)
   - baseValue: 1 gold

✅ Ruda Żelaza (Iron Ore):
   - gatherSpeed: 1.25s
   - biome: Koppalnia
   - baseValue: 1 gold

✅ Drewno (Wood):
   - gatherSpeed: 1.88s
   - biome: Las (Forest)
   - baseValue: 1.5 gold

✅ Kamień (Stone):
   - gatherSpeed: 2.5s
   - biome: Góry (Mountains)
   - baseValue: 1 gold

✅ Miedź (Copper):
   - gatherSpeed: 5.0s
   - biome: Góry
   - baseValue: 5 gold

✅ Wata (Salt):
   - gatherSpeed: 1.88s
   - biome: Jezioro (Lake)
   - baseValue: 2 gold

✅ Sól (Brine/Saltwater):
   - gatherSpeed: 3.75s
   - biome: Jezioro
   - baseValue: 3 gold

✅ Glina (Clay):
   - gatherSpeed: 3.13s
   - biome: Jezioro
   - baseValue: 1.5 gold
```

#### AC3: Resource Repository Implemented
```
✅ getResourceById(id: String) → Resource
✅ getAllResources() → List<Resource>
✅ getResourcesByBiome(biome: String) → List<Resource>
✅ Caching mechanism for repeated lookups
```

#### AC4: Unit Tests Pass
```
✅ Test: All 7 resources have unique IDs
✅ Test: All resources have valid gather speeds (> 0)
✅ Test: All resources have base values > 0
✅ Test: All resources assigned to valid biomes
✅ Test: No duplicate resources
✅ Test: Repository returns correct resources by biome
```

#### AC5: Documentation Updated
```
✅ .claude/TABLES.md updated with resource schema
✅ Tech spec marked: ✅ Resources implemented
```

### Implementation Notes

**Files to Create/Modify:**
- `lib/domain/entities/resource.dart` - Entity definition
- `lib/domain/repositories/resource_repository.dart` - Interface
- `lib/data/repositories/resource_repository_impl.dart` - Implementation
- `test/domain/entities/resource_test.dart` - Unit tests

**Key Pattern:**
Immutable entity with factory constructors for predefined resources:
```dart
class Resource {
  static final wegiel = Resource(
    id: 'wegiel',
    name: 'Węgiel',
    gatherSpeed: Duration(milliseconds: 1250),
    biome: 'koppalnia',
    baseValue: 1,
    rarity: ResourceRarity.common,
  );

  static final all = [wegiel, rudaZelaza, drewno, ...];
}
```

**Dependencies:**
- None (pure domain layer)

**Blocked by:**
- Nothing

**Blocks:**
- STORY-02.2 (Building Definitions use resources)
- STORY-02.4 (Recipes need resources)

---

## STORY-02.2: Building Definitions (3 SP)

### Objective
Implement all 6 building types with their properties, placement rules, crafting recipes, and unlock conditions. Buildings are the core production facilities.

### User Story
As a game developer, I need to define all 6 building types so that the player can place them and start production chains.

### Description
Buildings are the primary mechanism for automation and economic growth. Each building has specific requirements (cost, biom), production recipes (inputs/outputs), and unlock conditions. This story defines all building types and their properties.

### Acceptance Criteria

#### AC1: Building Entity Complete
```dart
✅ Building class implements:
  - id: String (e.g., 'mining_facility')
  - name: String (Polish name)
  - type: BuildingType enum
  - width: int
  - height: int
  - placementRules: PlacementRules
  - recipes: List<Recipe>
  - baseCost: Map<String, int> (resource → quantity)
  - buildTime: Duration
  - unlockCondition: UnlockCondition?
```

#### AC2: All 6 Buildings Defined
```
✅ Mining Facility:
   - Size: 2×2
   - Cost: FREE
   - buildTime: 0s
   - Unlock: Available at game start
   - Recipes: Gathers resources from biom
   - Rule: Must place on Koppalnia/Las/Góry/Jezioro tile

✅ Storage:
   - Size: 2×2
   - Cost: 5 Drewno + 10 Kamień
   - buildTime: 45s
   - Unlock: Available at game start
   - Recipes: Stores up to 200 items
   - Rule: Can place anywhere

✅ Smelter:
   - Size: 2×3
   - Cost: 15 Drewno + 10 Kamień + 5 Miedź
   - buildTime: 70s
   - Unlock: After smelting 1st Żelazo manually
   - Recipes: 30 Węgiel + 30 Ruda → 1 Żelazo (50s)
   - Rule: Can place anywhere

✅ Conveyor:
   - Size: 1×1 (per tile)
   - Cost: 2 Drewno + 1 Żelazo
   - buildTime: 5s/tile
   - Unlock: After smelting 1st Żelazo
   - Recipes: Transports items (0.5 items/sec)
   - Rule: Can place anywhere, max 2 layers

✅ Workshop:
   - Size: 2×2
   - Cost: 20 Drewno + 15 Kamień + 5 Żelazo
   - buildTime: 60s
   - Unlock: After 5 successful crafts
   - Recipes: 10 Żelazo → 1 Młotek (62s)
   - Rule: Can place anywhere

✅ Farm Monetyzacyjna:
   - Size: 3×3
   - Cost: 25 Beton + 12 Żelazo + 15 Drewno
   - buildTime: 85s
   - Unlock: After trading with 2 NPCs
   - Recipes: 1 item → variable gold
   - Rule: Can place anywhere
```

#### AC3: Placement Rules Implemented
```
✅ BiomRestricted rule (Mining only):
   - Must place on matching biom tile
   - Cannot place on empty/wrong biom

✅ FlexiblePlacement rule (others):
   - Can place on any non-blocked tile
   - Visual feedback showing valid/invalid tiles

✅ LayeringRule (Conveyors):
   - Max 2 layers allowed
   - 3+ layers = red invalid indicator
```

#### AC4: Recipe System
```
✅ Recipe class:
   - inputs: List<ResourceStack>
   - outputs: List<ResourceStack>
   - cycleTime: Duration
   - skillModifier: String? (affected skill)

✅ Each building has 1+ recipes:
   - Mining: Dynamic (depends on biom)
   - Smelter: 1 recipe (ore → bar)
   - Workshop: 1 recipe (bar → tool)
   - Farm: Dynamic (item → gold based on value)
```

#### AC5: Unlock Conditions
```
✅ UnlockCondition types:
   - GameStart (immediately available)
   - AfterAction (after crafting X, trading X)
   - AfterLevel (after skill reaches level X)

✅ Each building has correct unlock:
   - Mining: GameStart
   - Storage: GameStart
   - Smelter: AfterAction("smelt_iron_ore", 1)
   - Conveyor: AfterAction("smelt_iron_ore", 1)
   - Workshop: AfterAction("craft_any", 5)
   - Farm: AfterAction("trade_with_npc", 2)
```

#### AC6: Unit Tests Pass
```
✅ Test: All 6 buildings have unique IDs
✅ Test: All buildings have valid dimensions
✅ Test: All buildings have valid costs
✅ Test: Placement rules work correctly
✅ Test: Recipes have valid inputs/outputs
✅ Test: Unlock conditions evaluate correctly
```

### Implementation Notes

**Files to Create/Modify:**
- `lib/domain/entities/building.dart` - Main entity
- `lib/domain/entities/placement_rules.dart` - Placement logic
- `lib/domain/entities/recipe.dart` - Recipe definition
- `lib/domain/repositories/building_repository.dart` - Interface
- `lib/data/repositories/building_repository_impl.dart` - Implementation
- `test/domain/entities/building_test.dart` - Tests

**Key Pattern:**
Factory constructors for each building type:
```dart
class Building {
  static final miningFacility = Building(
    id: 'mining_facility',
    name: 'Koppalnia',
    width: 2,
    height: 2,
    costFree: true,
    placementRules: BiomRestrictedRule(['koppalnia', 'las', 'gory', 'jezioro']),
  );
}
```

**Dependencies:**
- STORY-02.1 (Resources must be defined first)

**Blocked by:**
- STORY-02.1

**Blocks:**
- STORY-02.5 (Building Placement needs building definitions)

---

## STORY-02.3: NPC Trading System (5 SP)

### Objective
Implement 3 NPC traders with their trading mechanics: Kupiec (gold trading), Inżynier (barter), and Nomada (premium offers). NPCs provide alternative trading routes and strategic depth.

### User Story
As a game developer, I need to implement NPC traders so players have diverse trading options and economic strategies beyond direct selling.

### Description
NPCs are dynamic traders that appear in specific bioms on a timer, offering various trades. Each NPC has unique mechanics:
- Kupiec: Straightforward gold trading with price fluctuation
- Inżynier: Barter trades that give synergy bonuses
- Nomada: Premium items for late-game progression

### Acceptance Criteria

#### AC1: NPC Entity Complete
```dart
✅ NPC class:
   - id: String (e.g., 'kupiec_khandal')
   - name: String
   - type: NPCType enum (trader, barter, premium)
   - location: NPCLocation (fixed biom or roaming)
   - spawnRate: Duration (how often appears)
   - despawnTime: Duration (how long visible)
   - currentTrades: List<Trade>
   - tradeRefreshRate: Duration
```

#### AC2: Kupiec Khandal (Gold Trading) ✅
```
✅ Location: Fixed in Koppalnia biom
✅ Spawn: Every 2 minutes (starts at game min 2)
✅ Visible Duration: 5 minutes (can visit anytime)
✅ Trade Refreshing: Every 5 minutes new base prices

✅ Base Prices (can be sold):
   - Węgiel: 1 → fluctuates ±20%
   - Drewno: 1.5 → fluctuates ±20%
   - Kamień: 1 → fluctuates ±20%
   - Wata: 2 → fluctuates ±20%
   - Sól: 3 → fluctuates ±20%
   - Miedź: 5 → fluctuates ±20%
   - Glina: 1.5 → fluctuates ±20%

✅ Daily Orders (2 random resources, +20% bonus):
   - Example: "I need 20 Węgiel → 24 zł" (vs 20 zł normal)
   - Changes every 5 min
   - Visual indicator: "Order active!"

✅ Synergy Bonus: None (direct trading)
```

#### AC3: Inżynier Zyx (Barter Trading) ✅
```
✅ Location: Random biom (roaming, changes every 5 min)
✅ Spawn: Every 5 minutes
✅ Visible Duration: 7 minutes
✅ Must player explore to find

✅ Trade Recipes (shows 3 of these, rotates every 7 min):
   1. 15 Węgiel → 20 Drewno
   2. 10 Kamień + 5 Wata → 8 Glina
   3. 20 Drewno → 1 Miedź rafinowana
   4. 5 Sól → 10 zł
   5. 30 Ruda żelaza → 5 Miedź
   (+ more in Phase 2)

✅ Synergy Bonus:
   - After 3 consecutive trades
   - All buildings get -20% craft time for 2 minutes
   - Visual: Special UI indicator
   - Can be stacked if traded again before expiry
```

#### AC4: Nomada Sha'ara (Premium Offers) ✅
```
✅ Location: Random on map (roaming)
✅ Spawn: Every 6-8 minutes (random)
✅ Visible Duration: 2 minutes ONLY (must be quick!)
✅ Despawn: If not visited in 2 minutes, disappears

✅ Offers (shows 2-3 of these, changes every 6 min):
   1. 10 zł → Scouting bonus (+50% gather from 1 biom for 3 min)
   2. 5 Wata → Skill book (choose: Mining/Smelting/Trading +1 level)
   3. 8 Sól → Eliksir (next 3 crafts -30% time)
   4. 20 zł → Secret biom unlock (Phase 2)
   5. 15 Drewno → Travel potion (fast movement for 1 min)
   (+ more in Phase 2)
```

#### AC5: NPC Management System
```
✅ NPCManager tracks:
   - All 3 NPCs with spawn/despawn timers
   - Current location of roaming NPCs
   - Active trades for each NPC
   - Player visit history (for analytics)

✅ Spawn Logic:
   - Kupiec: Timer-based, fixed location
   - Inżynier: Timer-based, random biom each spawn
   - Nomada: Timer-based, random map location

✅ Trade Execution:
   - Player can only trade if NPC visible
   - Resources deducted immediately
   - Rewards given immediately
   - Synergy bonus applied to game state
```

#### AC6: UI/UX Integration
```
✅ NPC Indicator:
   - Map shows NPC locations (exclamation mark)
   - Roaming NPCs flash when appearing

✅ Trade Dialog:
   - Shows current NPC trades
   - Displays prices/resources clearly
   - Confirm/cancel buttons
   - Stock validation (player has resources)

✅ Notification System:
   - Alert when Nomada appears (2 min window!)
   - Price fluctuation alerts for Kupiec
   - Synergy bonus notification when activated
```

#### AC7: Unit Tests Pass
```
✅ Test: NPCs spawn at correct intervals
✅ Test: Kupiec prices fluctuate correctly (±20%)
✅ Test: Inżynier trades execute correctly
✅ Test: Nomada despawns after 2 minutes
✅ Test: Synergy bonus applies after 3 trades
✅ Test: Player cannot trade without resources
✅ Test: Resources deducted and rewards applied
```

### Implementation Notes

**Files to Create/Modify:**
- `lib/domain/entities/npc.dart` - NPC definition
- `lib/domain/entities/trade.dart` - Trade definition
- `lib/domain/usecases/execute_trade_usecase.dart` - Trade execution
- `lib/domain/repositories/npc_repository.dart` - Interface
- `lib/data/repositories/npc_repository_impl.dart` - Implementation
- `lib/data/models/npc_model.dart` - JSON serialization
- `test/domain/usecases/execute_trade_usecase_test.dart` - Tests

**Synergy Bonus Implementation:**
```dart
// In PlayerEconomy, add synergized state
synergizationActive: DateTime?, // When expires
synergizationCraftMultiplier: 0.8, // -20% = 0.8x

// In UpgradeBuilding/CollectResources usecases:
if (currentTime < playerEconomy.synergizationActive) {
  cycleTime = cycleTime * 0.8; // Apply synergy
}
```

**Price Fluctuation:**
```dart
// In Kupiec pricing
basePrice * (0.8 + Random().nextDouble() * 0.4) // ±20% variation
```

**Dependencies:**
- STORY-02.1 (Resources must be defined)
- STORY-02.2 (Buildings for context)

**Blocked by:**
- STORY-02.1

**Blocks:**
- STORY-02.4 (Market transactions use NPC system)

---

## STORY-02.4: Grid & Building Placement System (8 SP)

### Objective
Implement the grid system (20×20 expandable to 30×30→40×40) and building placement mechanics with biom validation, layering support, and visual feedback.

### User Story
As a game developer, I need a complete grid and placement system so players can place buildings with clear validation and visual feedback.

### Description
The grid is the foundation of the factory builder gameplay. This story implements:
- Grid initialization (20×20 start)
- Tile properties (biom type, occupied/empty, layer count)
- Building placement validation
- Grid expansion triggers and mechanics
- Visual placement feedback (valid green, invalid red)

### Acceptance Criteria

#### AC1: Grid Entity Complete
```dart
✅ Grid class:
   - width: int (20, 30, or 40)
   - height: int (20, 30, or 40)
   - tiles: Map<Vector2, Tile>
   - buildings: List<PlacedBuilding>
   - expandLevel: int (1, 2, or 3)

✅ Tile class:
   - position: Vector2
   - biom: String (koppalnia, las, gory, jezioro)
   - occupied: bool
   - layers: List<String> (building IDs, max 2)
   - resources: List<ResourceStack> (items on ground)
```

#### AC2: Grid Initialization ✅
```
✅ Start with 20×20 grid (400 tiles)
✅ Biom distribution:
   - Koppalnia (Mine): ~6% of tiles (24 tiles)
   - Las (Forest): ~8% of tiles (32 tiles)
   - Góry (Mountains): ~8% of tiles (32 tiles)
   - Jezioro (Lake): ~6% of tiles (24 tiles)
   - Empty/neutral: ~72% of tiles (288 tiles)

✅ Biom placement:
   - Realistic distribution (not random chaos)
   - Koppalnia at bottom, Las on sides, Góry at edges
   - Jezioro scattered throughout

✅ Player starts in center of grid
✅ Initial buildings: None (player builds from scratch)
```

#### AC3: Building Placement Logic
```
✅ Placement validation:
   1. Building has space (not overlapping)
   2. All tiles under building are walkable
   3. BiomRestricted buildings check biom type
   4. Layering limit not exceeded (max 2)

✅ Placement execution:
   1. Deduct resources from inventory
   2. Add PlacedBuilding to grid
   3. Mark tiles as occupied
   4. Update building layer count
   5. Return success/failure

✅ Placement visual feedback:
   - While dragging: Green outline = valid, Red outline = invalid
   - Invalid reasons: Too close to edge, overlapping, wrong biom
   - Tooltip explains why invalid
```

#### AC4: Grid Expansion System ✅
```
✅ Expansion Level 1→2 (20×20 → 30×30):
   - Trigger: 2+ Smelters + Mining Level 5 + 50 Beton crafted
   - Cost: 50 Beton (must have in inventory)
   - Time: 50s animation
   - Result: Grid expands to 30×30 (900 tiles)
   - New area: Ring of empty tiles + bioms

✅ Expansion Level 2→3 (30×30 → 40×40):
   - Trigger: 4+ Smelters + 2+ Workshops + Farm exists + 100 Beton
   - Cost: 100 Beton
   - Time: 90s animation
   - Result: Grid expands to 40×40 (1600 tiles)

✅ Expansion mechanics:
   - Existing buildings stay in place
   - New ring of tiles added around perimeter
   - New bioms distributed in new area
   - Visual animation (grid slides/expands)
```

#### AC5: Layering System (Conveyors) ✅
```
✅ Conveyor layers:
   - Layer 1: Under buildings, can be placed anywhere
   - Layer 2: Over buildings, visible on top
   - Layer 3+: FORBIDDEN (red visual feedback)

✅ Layer visibility:
   - Layer 1: Drawn below buildings (slightly darker)
   - Layer 2: Drawn above buildings (bright)
   - Player can toggle view to see layers

✅ Conveyor pathfinding:
   - Items follow conveyor network across layers
   - Must handle layer transitions at splitters
   - Visual arrows show item flow direction
```

#### AC6: Demolition System ✅
```
✅ Long-press building → Demolish dialog
✅ Confirmation: "Demolish [Building] for 80% refund?"
✅ Execution:
   - 80% of building cost returned to inventory
   - Building removed from grid
   - Tiles marked as unoccupied
   - Items inside fall to ground
   - Ground items can be picked up or taken by conveyors
```

#### AC7: Unit Tests Pass
```
✅ Test: Grid initializes 20×20 with correct biom distribution
✅ Test: Building placement validates correctly
✅ Test: Overlapping buildings rejected
✅ Test: BiomRestricted buildings check biom
✅ Test: Layering limit enforced (max 2)
✅ Test: Expansion triggers work correctly
✅ Test: Expansion cost deducted from inventory
✅ Test: Demolition returns 80% refund
✅ Test: Grid expands to correct size (30×30, 40×40)
```

### Implementation Notes

**Files to Create/Modify:**
- `lib/domain/entities/grid.dart` - Grid system
- `lib/domain/entities/tile.dart` - Tile definition
- `lib/domain/entities/placed_building.dart` - Building on grid
- `lib/domain/usecases/place_building_usecase.dart` - Placement logic
- `lib/domain/usecases/expand_grid_usecase.dart` - Expansion logic
- `lib/domain/repositories/grid_repository.dart` - Interface
- `lib/data/repositories/grid_repository_impl.dart` - Implementation
- `lib/game/components/grid_component.dart` - Visual rendering
- `test/domain/usecases/place_building_usecase_test.dart` - Tests

**Vector2 for positions:**
```dart
// Tile position uses Vector2(x, y)
// Isometric projection handled in GridComponent
Vector2 tileAt(int x, int y) => Vector2(x.toDouble(), y.toDouble());
```

**Biom Generation Algorithm:**
```dart
// Pseudocode
for each tile {
  if random < 0.06 && noMineNearby: koppalnia
  else if random < 0.14 && noForestNearby: las
  else if (nearEdge || randomInMountainZone): gory
  else if (scattered && nearWater): jezioro
  else: empty
}
```

**Dependencies:**
- STORY-02.1 (Resources)
- STORY-02.2 (Building definitions)

**Blocked by:**
- STORY-02.2

**Blocks:**
- STORY-02.5 (Production mechanics need grid)

---

## STORY-02.5: Production & Inventory System (5 SP)

### Objective
Implement building production cycles, inventory management, and conveyor transport. Players can place buildings, configure recipes, and watch production chains in action.

### User Story
As a game developer, I need production mechanics so that buildings actually produce items and conveyors move them, creating satisfying production chains.

### Description
This story brings buildings to life:
- Mining facilities gather resources from bioms
- Smelters process ores into bars (with fuel requirement)
- Workshops craft bars into tools
- Farms convert items to gold
- Conveyors transport items between buildings
- Storage holds items and prevents backing up
- Skills modify production speeds

### Acceptance Criteria

#### AC1: Production Cycle System ✅
```
✅ ProductionCycle class:
   - buildingId: String
   - recipe: Recipe
   - progress: double (0.0-1.0)
   - elapsedTime: Duration
   - startTime: DateTime
   - status: ProductionStatus (running, paused, complete)

✅ Production states:
   - Waiting: No inputs available
   - Running: Producing (visual progress bar)
   - Complete: Output ready for pickup
   - Paused: Backed up (destination full)
```

#### AC2: Mining Facility ✅
```
✅ Dynamic gathering based on biom:
   - If on Koppalnia: Gather Węgiel OR Ruda Żelaza (player chooses)
   - If on Las: Gather Drewno
   - If on Góry: Gather Kamień OR Miedź (player chooses)
   - If on Jezioro: Gather Wata OR Sól OR Glina (player chooses)

✅ Gather speeds affected by:
   - Base speed (defined in Resource)
   - Mining skill (+20% at Lvl 5, +50% at Lvl 10)
   - Building boost (+50% for this building vs manual)

✅ Production cycle:
   - Start: Immediately (renewable resource)
   - Duration: Base gather time - mining skill bonus
   - Output: 1 item of selected resource
   - Repeat: Automatic, continuous
```

#### AC3: Smelter ✅
```
✅ Recipe: 30 Węgiel + 30 Ruda Żelaza → 1 Żelazo (50s)

✅ Requirements:
   - Requires BOTH input resources
   - Must have space in output
   - Processing: 50s base
   - Skill bonus: Smelting skill (-20% at Lvl 5, -40% at Lvl 10)

✅ Production logic:
   1. Check inputs available (30 of each)
   2. Check output space (≤ storage capacity)
   3. Start cycle (50s)
   4. When complete: Consume inputs, add output
   5. Synergy bonus if active: Cycle time * 0.8
   6. Repeat automatically

✅ Backed up handling:
   - If output full: Pause production
   - Red X visual on smelter
   - Resume when space available
```

#### AC4: Workshop ✅
```
✅ Recipe: 10 Żelazo → 1 Młotek (62s)

✅ Same logic as Smelter:
   - Check inputs (10 Żelazo)
   - Check outputs (≤ capacity)
   - Process 62s with skill bonuses
   - Synergy bonus applies
   - Auto-repeat
```

#### AC5: Farm (Monetization) ✅
```
✅ Dynamic recipe: 1 item → variable gold

✅ Conversion logic:
   - Input: Any resource
   - Output: Gold = item.baseValue * trading_skill_multiplier
   - Cycle time: 5s base
   - Can process up to 10 items in queue

✅ Skill interaction:
   - Trading Skill (+20% at Lvl 5, +50% at Lvl 10)
   - Farm outputs more gold per item at higher skill
   - Example: Drewno (1.5g base) → 1.5g (Skill 1) → 1.8g (Skill 5) → 2.25g (Skill 10)

✅ Monetization:
   - Provides main gold source for late game
   - Sustainable income after 120 minutes
   - Encourages item production
```

#### AC6: Conveyor Building Definition (Definition Only)
```
✅ Conveyor Building (Tier 1):
   - Size: 1×1 per tile
   - Cost: 2 Drewno + 1 Żelazo
   - Build time: 5s/tile
   - Unlock: After smelting 1st Żelazo

✅ Basic placement rules:
   - Can place anywhere on grid
   - Max 2 layers per tile
   - Visual feedback: valid/invalid placement

⚠️ NOTE: Full Conveyor Transport System (pathfinding, filtering,
   splitter, item movement) is implemented in EPIC-03.

   See: [epic-03-tech-spec.md](epic-03-tech-spec.md) for:
   - A* Pathfinding algorithm
   - 4-mode filtering system
   - Splitter mechanics
   - Transport rate and bottleneck handling
```

#### AC7: Inventory System ✅
```
✅ PlayerEconomy tracks:
   - Resources inventory (what items player has)
   - Gold amount
   - Building inventory (what's inside each building)

✅ Inventory limits:
   - Max 200 items in Storage (upgradeable)
   - Each building has internal buffer
   - Ground items: No limit (but slow to pickup)

✅ Inventory operations:
   - addResource(resource, quantity) → bool (success/failure)
   - removeResource(resource, quantity) → bool
   - getResourceCount(resource) → int
   - canAddResource(resource, quantity) → bool

✅ Persistence:
   - Inventory saved to Hive on every change
   - Load on game start
```

#### AC8: Skill Progression ✅
```
✅ Mining Skill:
   - Gained: +1 per 25 items gathered
   - Effect: +2% speed per level (Lvl 1: base, Lvl 5: +8%, Lvl 10: +18%)

✅ Smelting Skill:
   - Gained: +1 per 10 smelter cycles
   - Effect: -2% time per level (Lvl 1: base, Lvl 5: -8%, Lvl 10: -16%)

✅ Trading Skill:
   - Gained: +1 per 5 NPC trades
   - Effect: +5% sell price per level (Lvl 1: 1.0x, Lvl 5: 1.25x, Lvl 10: 1.5x)
```

#### AC9: Unit Tests Pass
```
✅ Test: Mining produces correct resources for biom
✅ Test: Smelter requires both inputs
✅ Test: Smelter produces correct output
✅ Test: Skill bonuses apply to cycle times
✅ Test: Synergy bonus applies when active
✅ Test: Conveyor building can be placed (definition only)
✅ Test: Conveyor respects 2-layer limit
✅ Test: Farm outputs correct gold for skill level
✅ Test: Inventory persists to Hive

⚠️ Full conveyor transport tests are in EPIC-03:
   - Pathfinding, filtering, splitter tests
```

### Implementation Notes

**Files to Create/Modify:**
- `lib/domain/entities/production_cycle.dart` - Production state
- `lib/domain/entities/conveyor.dart` - Conveyor building definition only
- `lib/domain/usecases/run_production_cycle_usecase.dart` - Main loop
- `lib/domain/usecases/apply_skill_bonus_usecase.dart` - Skill system
- `lib/game/components/production_component.dart` - Game loop integration
- `test/domain/usecases/run_production_cycle_usecase_test.dart` - Tests

**Note:** Conveyor transport logic (conveyor_network.dart, transport_items_usecase.dart,
conveyor_animation_component.dart) moved to EPIC-03.

**Main Game Loop Integration:**
```dart
// In GameWorld update()
for each building {
  if productionCycle.isRunning {
    productionCycle.elapsedTime += deltaTime;
    if (productionCycle.progress >= 1.0) {
      executeProductionCycle(building);
    }
  }
}

// Update visuals
updateProductionBars();

// Note: Conveyor transport moved to EPIC-03
```

**Dependencies:**
- STORY-02.1 (Resources)
- STORY-02.2 (Buildings)
- STORY-02.3 (NPC system for context)
- STORY-02.4 (Grid/placement)

**Blocked by:**
- STORY-02.4 (Needs grid system)

**Blocks:**
- STORY-02.6 (Economic balance testing)

---

## STORY-02.6: Economic Balance & Testing (3 SP)

### Objective
Verify and balance the entire Tier 1 economy. Ensure progression is satisfying, the 1000g goal is achievable in 120 minutes, and all production chains work correctly.

### User Story
As a game developer/PM, I need to verify the economy is balanced so that players can reach economic goals without exploitation or dead-ends.

### Description
This is the final validation story. It:
- Runs complete economic simulations
- Verifies timeline targets (1000g in 120 min)
- Tests all production chains work together
- Identifies and fixes balance issues
- Creates economic balance documentation

### Acceptance Criteria

#### AC1: Complete Economic Simulation ✅
```
✅ Simulation system:
   - Simulate full 120-minute play session
   - Auto-place optimal buildings
   - Execute production at realistic speeds
   - Track all resource flows
   - Generate detailed report

✅ Simulation parameters:
   - Start: No buildings, no resources
   - End: Check if 1000g achievable
   - Constraints: Only Tier 1 resources/buildings
```

#### AC2: Achieve 1000g Goal ✅
```
✅ Phase 1 (0-15 min): ~30-50 gold
   - Manual gathering: Węgiel (Koppalnia), Drewno (Las)
   - Sell low-value items: ~30g from gathering

✅ Phase 2 (15-50 min): ~150-300 gold
   - First Smelter built (15 Drewno + 10 Kamień + 5 Miedź)
   - First Żelazo produced
   - Workshop unlocked after 5 crafts
   - Simple production chain: Ore → Żelazo → Młotek → Gold
   - Accumulated: ~180g

✅ Phase 3 (50-120 min): ~500-1000 gold
   - Farm unlocked after 2 NPC trades
   - Conveyors set up for automation
   - Multiple production chains running
   - Farm converts items → gold continuously
   - Accumulated: ~800g
   - **TOTAL: 1000g VERIFIED ✅**
```

#### AC3: Production Chain Verification ✅
```
✅ Test all chains work together:
   1. Mining → Storage → Smelter → Storage → Workshop → Storage → Farm → Gold
   2. Mining → Conveyor → Smelter → Conveyor → Workshop → Conveyor → Farm
   3. Conveyor with filters: Route specific resources correctly
   4. Splitter: Distribute items across multiple facilities

✅ Test bottleneck scenarios:
   - Storage full: Production pauses, items back up (red visual)
   - Conveyor full: Source building pauses
   - Multiple sources to 1 destination: Fairness/priority
   - Resolution: Add storage, reroute, use splitter

✅ Test edge cases:
   - Mining on different bioms produces correct resources
   - Locked recipes (Workshop only unlocks after crafts)
   - Skill bonuses apply correctly (speed/time reduction)
   - Synergy bonus from Inżynier (3 trades → -20% craft time)
```

#### AC4: Balance Issues Document ✅
```
✅ Create BALANCE-ISSUES.md with findings:
   - Any resource too cheap/expensive?
   - Any building too easy/hard to unlock?
   - Any production chain too slow?
   - Any gold source too powerful?
   - Recommendations for rebalancing

✅ Example findings:
   - Miedź (5g) might be bottleneck → Consider 5.0s gather speed
   - Farm output at Skill 1 might be too low → Consider base 1.5x multiplier
   - Grid expansion cost (50 Beton) might be excessive → Consider 30 Beton
```

#### AC5: Performance Validation ✅
```
✅ Game performance:
   - 60 FPS with 10+ buildings running
   - Smooth conveyor animation (items move smoothly)
   - No lag when placing buildings
   - Smooth grid expansion animation

✅ Profiling:
   - Production cycle: < 1ms per building per frame
   - Conveyor pathfinding: < 5ms per update
   - Serialization: < 10ms save
```

#### AC6: Integration Tests ✅
```
✅ Test: Full economic simulation completes without errors
✅ Test: 1000g goal achievable in 120 minutes
✅ Test: All production chains execute correctly
✅ Test: Skills unlock and apply correctly
✅ Test: NPC trades execute correctly
✅ Test: Grid expansion triggers work
✅ Test: Inventory persists across saves
✅ Test: Performance meets 60 FPS target
```

#### AC7: Documentation ✅
```
✅ Create docs/sprint-artifacts/EPIC-02-BALANCE-REPORT.md:
   - Simulation results (detailed timeline)
   - Balance assessment (each mechanic)
   - Issues found and resolutions
   - Recommendations for future phases
   - Performance metrics

✅ Update .claude/TABLES.md:
   - Add economic summary table
   - Add production timelines
```

#### AC8: Definition of Done
```
✅ All 5 stories merged to main branch
✅ All tests passing (unit + integration)
✅ Balance report completed
✅ project-status.md updated (EPIC-02: ✅ Complete)
✅ No critical bugs remaining
✅ Code reviewed for quality
✅ Performance tested (60 FPS minimum)
```

### Implementation Notes

**Files to Create/Modify:**
- `lib/domain/usecases/simulate_economy_usecase.dart` - Full simulation
- `lib/domain/repositories/simulation_repository.dart` - Simulation persistence
- `test/domain/usecases/simulate_economy_usecase_test.dart` - Integration tests
- `docs/sprint-artifacts/EPIC-02-BALANCE-REPORT.md` - Results document

**Simulation Algorithm:**
```dart
// Pseudocode
simulate(duration: 120 minutes) {
  gameState.clear();

  // Phase 1: Manual gathering (0-15 min)
  while (time < 15 min) {
    gatherResources();
    sellToNPC(); // Kupiec
    trackGold();
  }

  // Phase 2: First automation (15-50 min)
  while (time < 50 min) {
    buildSmelter();
    runProductionCycle();
    buildWorkshop();
    trackProgress();
  }

  // Phase 3: Full automation (50-120 min)
  while (time < 120 min) {
    buildFarm();
    setupConveyors();
    automate();
    trackGold();
  }

  // Results
  return {
    totalGold: goldAmount,
    buildingsBuilt: [...],
    timeline: [...],
    issues: [...],
  };
}
```

**Dependencies:**
- All previous stories (STORY-02.1 through STORY-02.5)

**Blocked by:**
- STORY-02.5

**Blocks:**
- Nothing (final story)

---

## Story Summary Table

| Story | SP | Focus | Dependencies |
|-------|----|----|------|
| **STORY-02.1** | 2 | Resource definitions | None |
| **STORY-02.2** | 3 | Building definitions (incl. Conveyor) | 02.1 |
| **STORY-02.3** | 5 | NPC trading system | 02.1 |
| **STORY-02.4** | 8 | Grid & placement | 02.1, 02.2 |
| **STORY-02.5** | 5 | Production & inventory | 02.1, 02.2, 02.4 |
| **STORY-02.6** | 3 | Balance & testing | 02.1-02.5 |
| **TOTAL** | **26 SP** | Tier 1 Economy MVP | - |

---

## Implementation Order

**Recommended Sprint 2 (Weeks 2-3):**
1. **Week 2:** STORY-02.1 + 02.2 + 02.3 (10 SP) - Definitions
2. **Week 3:** STORY-02.4 + 02.5 (13 SP) - Mechanics
3. **Week 4:** STORY-02.6 (3 SP) - Balance & testing

**Build Sequence:**
1. First: Resources + Buildings (domain layer, no UI needed)
2. Second: Grid + Placement (game interaction needed)
3. Third: NPCs + Production (full feature set)
4. Fourth: Balance (quality assurance)

---

## Success Metrics

**After EPIC-02 Complete:**
- ✅ All 7 resources fully implemented
- ✅ All 6 buildings defined (including Conveyor as building type)
- ✅ 3 NPCs trading with players
- ✅ Grid system with expansion (20×20 → 40×40)
- ✅ Basic production chains working (manual transport)
- ✅ 1000g achievable in 120 minutes
- ✅ Game progression feels satisfying
- ✅ All tests passing
- ✅ Performance: 60 FPS minimum

**Note:** Full conveyor automation (transport, filtering, splitter) → EPIC-03

**When EPIC-02 Complete:**
- Overall Progress: ~26% (73/289 SP)
- Ready to start: EPIC-03 (Automation)
- Code quality: Production-ready
- User experience: Core gameplay loop validated

---

**Document Status:** 📋 Ready for Development
**Last Updated:** 2025-12-03
**Version:** 2.0 (Conveyor transport moved to EPIC-03)
**Next Review:** After STORY-02.1 complete
