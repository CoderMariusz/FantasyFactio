# Epic 3: Tier 2 Automation - Technical Specification

**Epic:** EPIC-03 - Tier 2 Automation
**Total SP:** 42
**Duration:** 2-3 weeks (Sprints 4-5)
**Status:** 📋 Ready for Implementation
**Date:** 2025-12-03

---

## Overview

EPIC-03 implementuje **system automatyzacji** który przekształca Trade Factory Masters z prostej gry zbierającej w strategiczny factory builder. Kluczowe elementy:

- **A* Pathfinding** - optymalne ścieżki dla conveyorów
- **Conveyor System** - transport itemów między budynkami
- **Filtering System** - zaawansowane zarządzanie przepływem
- **Splitter System** - dystrybucja na wiele wyjść

**Business Value:**
- Core differentiator od idle clickers
- "One more turn" gameplay loop
- 60%+ graczy odblokuje Tier 2 w 2-3h

---

## 1. A* Pathfinding Algorithm

### Overview

**Purpose:** Znajdowanie optymalnych ścieżek dla conveyorów

**Performance Target:** <100ms dla 50-tile path na Snapdragon 660

### Implementation

```dart
class ConveyorPathfinder {
  final Size gridSize;
  final Set<Point<int>> occupiedTiles;

  List<Point<int>>? findPath(Point<int> start, Point<int> end) {
    final openSet = PriorityQueue<Node>((a, b) => a.fScore.compareTo(b.fScore));
    final closedSet = <Point<int>>{};
    final cameFrom = <Point<int>, Point<int>>{};
    final gScore = <Point<int>, double>{start: 0};

    openSet.add(Node(start, _heuristic(start, end)));

    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();

      if (current.position == end) {
        return _reconstructPath(cameFrom, current.position);
      }

      closedSet.add(current.position);

      for (final neighbor in _getNeighbors(current.position)) {
        if (closedSet.contains(neighbor) || occupiedTiles.contains(neighbor)) {
          continue;
        }

        final tentativeGScore = gScore[current.position]! + 1;

        if (!gScore.containsKey(neighbor) || tentativeGScore < gScore[neighbor]!) {
          cameFrom[neighbor] = current.position;
          gScore[neighbor] = tentativeGScore;
          final fScore = tentativeGScore + _heuristic(neighbor, end);
          openSet.add(Node(neighbor, fScore));
        }
      }
    }

    return null; // No path found
  }

  double _heuristic(Point<int> a, Point<int> b) {
    // Manhattan distance
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }
}
```

### Success Criteria

| Metric | Target |
|--------|--------|
| Performance | <100ms for 50-tile path |
| Accuracy | 100% success for valid paths |
| Memory | <5MB for pathfinding cache |

---

## 2. Conveyor System (Complete)

> **Source:** Przeniesione z Epic 2 SYSTEMS.md (system automatyzacji)

### Overview

**Purpose:** Transport items między buildings i filtrowanie przepływu

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

### Data Structure

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

### Cycle Logic

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

## 3. Filtering System

### 4-Mode Filtering

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

### Filtering Logic Function

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

## 4. Splitter System

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

---

## 5. Layering System

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

---

## 6. Visual Feedback

**Item Flow Indicators:**
- Green highlight: Item moving normally
- Yellow highlight: Item waiting in queue (backpressure)
- Red highlight: Invalid connection or blocked
- Animated item icons: Show direction and progress
- Smoke effect: Overload (too many items)

---

## 7. Storage Item Filtering System

> **Source:** Przeniesione z Epic 2 SYSTEMS.md

### Overview

**Purpose:** Enable advanced factory automation with strategic item routing

**Architecture:**
- Global accept/reject filter (per storage)
- Per-port input/output filtering (4 modes each)
- Advanced multi-storage networks possible
- Visual feedback and error recovery

### Global Storage Filter

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

### Per-Port Filtering

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

### Advanced Network Example

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

---

## 8. Conveyor Creation UI

### UI Flow

```
[Toolbar: Build | Conveyor | Market | ...]

↓ Tap "Conveyor"

┌─────────────────────────────────┐
│ Conveyor Mode                   │
│ Step 1: Select START building   │
│ Tap a building to begin...      │
└─────────────────────────────────┘

↓ Tap Lumbermill

┌─────────────────────────────────┐
│ START: Lumbermill (Level 2)     │
│ Step 2: Select END building     │
│ Tap destination building...     │
│              [Cancel]           │
└─────────────────────────────────┘

↓ Tap Smelter

┌─────────────────────────────────┐
│ Path Found! 9 tiles             │
│ Cost: 18 Drewno + 9 Żelazo      │
│                                 │
│ [~~~ Animated path preview ~~~] │
│                                 │
│ Transport: Wood                 │
│ Travel time: 18 seconds         │
│                                 │
│   [Confirm]        [Cancel]     │
└─────────────────────────────────┘
```

**Path Preview Animation:**
- Dashed line (2px white, 50% opacity)
- Animated: dash offset moves (like "marching ants")
- 60 FPS animation

---

## Dependencies

**Depends On:**
- ✅ EPIC-01 (Core Gameplay Loop)
- ✅ EPIC-02 (Tier 1 Economy - zasoby, budynki, grid)

**Blocks:**
- → EPIC-04 (Offline - uses conveyor chains for calculation)
- → EPIC-06 (Progression - conveyor upgrades)

---

## Testing Requirements

### Unit Tests
- [ ] A* finds shortest path (25 tests)
- [ ] Obstacle avoidance works
- [ ] No-path returns null
- [ ] Conveyor filter modes (all 4)
- [ ] Splitter distribution (round-robin)
- [ ] Layering limit enforced (max 2)
- [ ] Storage filter logic

### Integration Tests
- [ ] Full automation chain: Mining → Conveyor → Smelter → Workshop → Farm
- [ ] Backpressure stops source correctly
- [ ] 60 FPS with 50 conveyors + 100 items

---

## Success Metrics

| Metric | Target |
|--------|--------|
| A* Performance | <100ms for 50-tile path |
| Rendering FPS | 60 FPS with 50+ conveyors |
| Player Adoption | 60%+ place ≥1 conveyor |
| Session Length | +20% avg with automation |

---

**Status:** 📋 Ready for Implementation
**Last Updated:** 2025-12-03
**Version:** 2.0 (Merged from Epic 2 SYSTEMS.md)
