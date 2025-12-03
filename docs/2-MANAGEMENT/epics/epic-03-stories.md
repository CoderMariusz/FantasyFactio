# Epic 3: Tier 2 Automation - Detailed Stories

<!-- AI-INDEX: epic, stories, acceptance-criteria, automation, conveyor -->

**Epic:** EPIC-03 - Tier 2 Automation
**Total SP:** 42
**Duration:** 2-3 weeks (Sprints 3-4)
**Status:** 📋 Ready for Implementation
**Tech-Spec:** [epic-03-tech-spec.md](epic-03-tech-spec.md)

**Prerequisites:**
- ✅ EPIC-01 (Core Gameplay Loop)
- ✅ EPIC-02 (Tier 1 Economy - zasoby, budynki, grid, conveyor definition)

---

## STORY-03.1: A* Pathfinding System (5 SP)

### Objective
Implement A* pathfinding algorithm for finding optimal conveyor routes between buildings on the grid.

### User Story
As a player, I want the game to automatically calculate the best path for my conveyors so I can quickly set up efficient transport routes without manual tile-by-tile placement.

### Description
The pathfinding system is the foundation for conveyor automation. It calculates optimal routes while avoiding obstacles (occupied tiles, buildings) and respecting grid boundaries.

### Acceptance Criteria

#### AC1: A* Algorithm Implementation
```dart
✅ ConveyorPathfinder class:
   - findPath(start, end) → List<Point<int>>?
   - Uses Manhattan distance heuristic
   - Respects grid boundaries (20×20 to 40×40)
   - Avoids occupied tiles (buildings)
   - Returns null if no valid path exists

✅ Performance requirements:
   - <100ms for 50-tile path on Snapdragon 660
   - <5MB memory for pathfinding cache
   - Supports async calculation for long paths
```

#### AC2: Obstacle Avoidance
```
✅ Pathfinder respects:
   - Building footprints (2×2, 2×3, 3×3)
   - Existing conveyor tiles (if layer limit reached)
   - Grid edges (no out-of-bounds paths)
   - Blocked tiles (if any marked as impassable)

✅ Edge cases:
   - Source building has no valid exit → Error message
   - Destination building has no valid input → Error message
   - Path completely blocked → "No path found" feedback
```

#### AC3: Path Optimization
```
✅ Optimization rules:
   - Prefer straight lines over zigzags
   - Minimize total tiles (shortest path)
   - Consider layer usage (prefer empty layers)
   - Cache recent paths for repeated queries

✅ Path preview:
   - Return path as List<Point<int>>
   - Include estimated tile count
   - Include estimated travel time
```

#### AC4: Unit Tests Pass
```
✅ Test: Simple 5-tile path found correctly
✅ Test: 25-tile path with obstacles
✅ Test: 50-tile path under 100ms
✅ Test: No-path returns null (completely blocked)
✅ Test: Path avoids building footprints
✅ Test: Path respects grid boundaries
✅ Test: Manhattan heuristic calculates correctly
```

### Implementation Notes

**Files to Create:**
- `lib/domain/usecases/find_conveyor_path_usecase.dart` - Main pathfinder
- `lib/domain/entities/pathfinder_node.dart` - Node for A* algorithm
- `test/domain/usecases/find_conveyor_path_usecase_test.dart` - Tests

**Algorithm:**
```dart
// Priority queue with f-score ordering
// g-score = actual distance from start
// h-score = Manhattan distance to end
// f-score = g + h
```

**Dependencies:**
- EPIC-02 Grid system (tile occupancy data)

**Blocks:**
- STORY-03.2 (Conveyor Transport uses pathfinding)

---

## STORY-03.2: Conveyor Transport Mechanics (8 SP)

### Objective
Implement the core conveyor transport system that moves items between buildings using the pathfinding algorithm.

### User Story
As a player, I want to place conveyors that automatically transport items from one building to another so I can automate my production chains.

### Description
The conveyor system is the heart of factory automation. Items move along conveyor tiles at 0.5 items/second, following calculated paths from source to destination buildings.

### Acceptance Criteria

#### AC1: ConveyorTile Entity
```dart
✅ ConveyorTile class:
   - position: Vector2
   - direction: Direction (N, S, E, W)
   - layer: int (1 or 2)
   - queue: List<ResourceStack> (max 10 items)
   - filterMode: FilterMode
   - filterList: List<String>
   - splitterConfig: SplitterConfig?

✅ Direction enum:
   - North, South, East, West
   - Determines item flow direction
   - Visual arrow indicator
```

#### AC2: Transport Mechanics
```
✅ Movement rate: 0.5 items/second (1 item per 2s per tile)
✅ Capacity: 10 items max per tile
✅ Direction: 4-way (N, S, E, W)
✅ Queuing: FIFO (first in, first out)

✅ Transport cycle (every 2 seconds):
   1. Check each tile's queue
   2. For each item:
      - Check filter rules (pass/reject)
      - If passes: Move to next tile OR building input
      - If blocked: Stay in queue (backpressure)
      - If no destination: Drop to ground
   3. Check building outputs for new items
   4. Update visual animations
```

#### AC3: Connection Rules
```
✅ Valid connections:
   - Conveyor → Conveyor (same or adjacent layer)
   - Building OUTPUT port → Conveyor
   - Conveyor → Building INPUT port

✅ Invalid connections:
   - Conveyor pointing at wall/edge → Red visual
   - Conveyor with no destination → Items drop
   - 3+ layers on same tile → Blocked

✅ Port detection:
   - Buildings have defined input/output ports
   - Conveyors auto-connect to nearest port
   - Visual: Green highlight on valid ports
```

#### AC4: Layering System
```
✅ Layer 1 (Under Buildings):
   - Slightly darker visual (80% opacity)
   - Can be covered by buildings
   - Used for main distribution lines

✅ Layer 2 (Over Buildings):
   - Bright and clearly visible (100%)
   - Appears above structures
   - Used for overflow routes

✅ Layer limits:
   - Max 2 layers per tile
   - 3rd layer attempt: RED feedback + error message
   - "Maximum conveyor layers reached"
```

#### AC5: Backpressure System
```
✅ When destination full:
   - Items stop moving on belt
   - Yellow pulsing visual on waiting items
   - Source building pauses production
   - Red X indicator on source

✅ Resolution:
   - Destination empties → Items resume
   - Automatic retry every 2 seconds
   - No item loss (queue preserved)
```

#### AC6: Unit Tests Pass
```
✅ Test: Item moves from tile A to tile B
✅ Test: Movement rate is 0.5 items/sec
✅ Test: Queue respects FIFO order
✅ Test: Backpressure stops movement
✅ Test: Layer 1 and 2 work correctly
✅ Test: 3rd layer rejected
✅ Test: Items connect to building ports
✅ Test: Dropped items go to ground
```

### Implementation Notes

**Files to Create:**
- `lib/domain/entities/conveyor_tile.dart` - Tile entity
- `lib/domain/entities/conveyor_network.dart` - Network graph
- `lib/domain/usecases/transport_items_usecase.dart` - Movement logic
- `lib/game/components/conveyor_component.dart` - Flame component
- `test/domain/usecases/transport_items_usecase_test.dart` - Tests

**Game Loop Integration:**
```dart
// In GameWorld.update()
conveyorNetwork.tick(deltaTime);
// Updates all tile queues
// Moves items between tiles
// Triggers animations
```

**Dependencies:**
- STORY-03.1 (Pathfinding for route calculation)
- EPIC-02 Buildings (input/output ports)

**Blocks:**
- STORY-03.3 (Filtering uses conveyor network)
- STORY-03.4 (Splitter uses conveyor network)

---

## STORY-03.3: Filtering System (5 SP)

### Objective
Implement the 4-mode filtering system that controls which items can pass through conveyors and storage.

### User Story
As a player, I want to filter what items flow through my conveyors so I can route specific resources to specific buildings.

### Description
The filtering system enables strategic item routing. Players can whitelist/blacklist resources, enabling complex factory layouts with sorted item flows.

### Acceptance Criteria

#### AC1: FilterMode Enum
```dart
✅ FilterMode enum:
   - ALLOW_ALL (default) - All items pass
   - WHITELIST - Only specified items pass
   - BLACKLIST - Specified items blocked
   - SINGLE - Only one specific item type passes

✅ Filter configuration:
   - Max 3 items in whitelist/blacklist
   - Single mode: exactly 1 item type
```

#### AC2: Filtering Logic
```dart
✅ canAcceptItem(item, filter) function:
   - ALLOW_ALL → always true
   - WHITELIST → item.type in filter.list
   - BLACKLIST → item.type NOT in filter.list
   - SINGLE → item.type == filter.singleItem

✅ Blocked item behavior:
   - Item stays in source queue
   - Backpressure applies to upstream
   - Yellow warning visual on blocked item
```

#### AC3: Filter UI
```
✅ Filter configuration panel:
   - Tap conveyor tile → Open filter menu
   - Mode selector: 4 radio buttons
   - Item picker: Grid of available resources
   - Apply/Cancel buttons

✅ Visual indicators:
   - Conveyor with filter: Small icon on tile
   - WHITELIST: Green filter icon
   - BLACKLIST: Red filter icon
   - SINGLE: Blue filter icon
```

#### AC4: Per-Port Filtering
```
✅ Storage buildings support:
   - Global filter (applies to all ports)
   - Per-port filters (input, output_n)
   - Filters evaluated in order: port → global

✅ Conveyor tiles support:
   - Single filter per tile
   - Applies to all items passing through
```

#### AC5: Unit Tests Pass
```
✅ Test: ALLOW_ALL passes all items
✅ Test: WHITELIST passes only listed items
✅ Test: BLACKLIST blocks only listed items
✅ Test: SINGLE passes exactly one type
✅ Test: Blocked items stay in queue
✅ Test: Filter changes apply immediately
✅ Test: Storage global filter works
✅ Test: Per-port filter overrides global
```

### Implementation Notes

**Files to Create:**
- `lib/domain/entities/filter_mode.dart` - Filter enum and config
- `lib/domain/usecases/apply_filter_usecase.dart` - Filter logic
- `lib/presentation/widgets/filter_panel.dart` - UI widget
- `test/domain/usecases/apply_filter_usecase_test.dart` - Tests

**Filter Evaluation:**
```dart
// Check in order:
// 1. Conveyor tile filter
// 2. Destination port filter
// 3. Destination global filter
// All must pass for item to enter
```

**Dependencies:**
- STORY-03.2 (Conveyor network)
- EPIC-02 Resources (item types)

**Blocks:**
- STORY-03.6 (Storage networks use filtering)

---

## STORY-03.4: Splitter System (5 SP)

### Objective
Implement splitter nodes that distribute items across multiple conveyor outputs.

### User Story
As a player, I want to split my conveyor output to multiple destinations so I can feed several production buildings from one source.

### Description
Splitters enable complex factory layouts by distributing items from one input to multiple outputs using round-robin distribution.

### Acceptance Criteria

#### AC1: Splitter Entity
```dart
✅ SplitterConfig class:
   - outputs: List<Direction> (2-3 directions)
   - mode: SplitterMode (ROUND_ROBIN, PRIORITY, EQUAL)
   - currentIndex: int (for round-robin)

✅ Placement rules:
   - Must have exactly 1 input direction
   - Must have 2-3 output directions
   - All 4 directions available (N, S, E, W)
```

#### AC2: Distribution Modes
```
✅ ROUND_ROBIN (default):
   - Items distributed in rotation
   - Item #1 → Output A
   - Item #2 → Output B
   - Item #3 → Output C
   - Item #4 → Output A (repeat)

✅ PRIORITY:
   - Try Output A first
   - If A full → Try Output B
   - If B full → Try Output C
   - If all full → Backpressure

✅ EQUAL:
   - Track item counts per output
   - Send to output with lowest count
   - Balances load over time
```

#### AC3: Splitter UI
```
✅ Splitter placement:
   - Tap existing conveyor → "Convert to Splitter"
   - Select output directions (2-3)
   - Select distribution mode
   - Confirm placement

✅ Visual indicators:
   - Splitter tile: Special icon (branching arrows)
   - Active output: Green highlight (pulsing)
   - Blocked output: Red highlight
   - Round-robin animation: Rotating indicator
```

#### AC4: Backpressure Handling
```
✅ If one output full:
   - Round-robin skips to next
   - Items continue flowing
   - No item loss

✅ If all outputs full:
   - Splitter stops accepting input
   - Backpressure to upstream
   - Yellow warning visual
   - Resume when any output clears
```

#### AC5: Unit Tests Pass
```
✅ Test: Round-robin distributes evenly
✅ Test: Priority uses first available
✅ Test: Equal balances counts
✅ Test: 2-output splitter works
✅ Test: 3-output splitter works
✅ Test: Full output skipped (no item loss)
✅ Test: All full causes backpressure
✅ Test: Visual indicators update correctly
```

### Implementation Notes

**Files to Create:**
- `lib/domain/entities/splitter_config.dart` - Splitter data
- `lib/domain/usecases/distribute_items_usecase.dart` - Distribution logic
- `lib/presentation/widgets/splitter_panel.dart` - UI widget
- `test/domain/usecases/distribute_items_usecase_test.dart` - Tests

**Distribution Logic:**
```dart
Direction? getNextOutput(SplitterConfig config, List<bool> outputsFull) {
  switch (config.mode) {
    case ROUND_ROBIN:
      // Try each output starting from currentIndex
      for (int i = 0; i < config.outputs.length; i++) {
        int idx = (config.currentIndex + i) % config.outputs.length;
        if (!outputsFull[idx]) {
          config.currentIndex = (idx + 1) % config.outputs.length;
          return config.outputs[idx];
        }
      }
      return null; // All full
    // ... other modes
  }
}
```

**Dependencies:**
- STORY-03.2 (Conveyor network)
- STORY-03.3 (Filtering for outputs)

**Blocks:**
- STORY-03.6 (Complex networks use splitters)

---

## STORY-03.5: Conveyor UI & Creation Flow (8 SP)

### Objective
Implement the user interface for creating, editing, and visualizing conveyor networks.

### User Story
As a player, I want an intuitive UI for placing conveyors so I can easily build and manage my automation network.

### Description
The conveyor UI provides a streamlined workflow: select source building, select destination, preview path, and confirm. Visual feedback shows item flow in real-time.

### Acceptance Criteria

#### AC1: Conveyor Creation Flow
```
✅ Step 1: Enter Conveyor Mode
   - Tap "Conveyor" button in toolbar
   - Grid enters selection mode
   - "Select START building" prompt

✅ Step 2: Select Source
   - Tap building with output port
   - Building highlights (green outline)
   - "Select END building" prompt
   - Cancel button available

✅ Step 3: Select Destination
   - Tap building with input port
   - Pathfinding calculates route
   - Path preview displayed

✅ Step 4: Confirm Placement
   - Show: tile count, cost, travel time
   - Animated path preview (marching ants)
   - Confirm/Cancel buttons
   - Resources deducted on confirm
```

#### AC2: Path Preview Animation
```
✅ Visual preview:
   - Dashed line (2px white, 50% opacity)
   - Animated dash offset (marching ants)
   - 60 FPS smooth animation
   - Highlights each tile in path

✅ Cost display:
   - "Path Found! 9 tiles"
   - "Cost: 18 Drewno + 9 Żelazo"
   - "Travel time: 18 seconds"
```

#### AC3: Item Flow Visualization
```
✅ Flow indicators:
   - Green: Item moving normally
   - Yellow: Item waiting (backpressure)
   - Red: Blocked or error
   - Animated item icons along belt
   - Direction arrows on tiles

✅ Item animation:
   - Smooth movement between tiles (lerp)
   - 60 FPS animation
   - Items visible on both layers
   - Pile-up visual when congested
```

#### AC4: Conveyor Editing
```
✅ Edit mode:
   - Long-press conveyor tile → Edit menu
   - Options: Filter, Remove, Convert to Splitter
   - Filter opens filter panel (STORY-03.3)
   - Remove refunds 50% resources

✅ Bulk selection:
   - Drag to select multiple tiles
   - "Remove all" option
   - Confirmation dialog
```

#### AC5: Error Feedback
```
✅ Invalid placement:
   - Red X on invalid tiles
   - Shake animation on error
   - Toast message explaining issue

✅ Error messages:
   - "No valid path found"
   - "Building has no output port"
   - "Maximum layers reached"
   - "Not enough resources"
```

#### AC6: Unit Tests Pass
```
✅ Test: Creation flow completes successfully
✅ Test: Path preview shows correct tiles
✅ Test: Cost calculated correctly
✅ Test: Resources deducted on confirm
✅ Test: Cancel returns to normal mode
✅ Test: Error messages display correctly
✅ Test: Edit menu opens on long-press
✅ Test: Remove refunds 50%
```

### Implementation Notes

**Files to Create:**
- `lib/presentation/screens/conveyor_mode_screen.dart` - Creation flow
- `lib/presentation/widgets/path_preview.dart` - Path animation
- `lib/presentation/widgets/conveyor_edit_menu.dart` - Edit options
- `lib/game/components/conveyor_animation_component.dart` - Item flow
- `test/presentation/conveyor_mode_screen_test.dart` - Tests

**Animation System:**
```dart
// Marching ants effect
dashOffset += deltaTime * 50; // pixels per second
if (dashOffset > dashLength) dashOffset = 0;
```

**Dependencies:**
- STORY-03.1 (Pathfinding)
- STORY-03.2 (Conveyor network)
- STORY-03.3 (Filter panel)
- STORY-03.4 (Splitter panel)

**Blocks:**
- Nothing (final UI layer)

---

## STORY-03.6: Storage Integration & Networks (6 SP)

### Objective
Implement advanced storage filtering and multi-storage conveyor networks for complex automation.

### User Story
As a player, I want to connect multiple storages with filtered conveyors so I can build efficient sorting and distribution systems.

### Description
This story enables advanced factory layouts where storages act as distribution hubs with filtered inputs and outputs.

### Acceptance Criteria

#### AC1: Storage Filter Configuration
```dart
✅ StorageBuilding extended:
   - globalFilter: StorageFilter
   - portFilters: Map<String, StorageFilter>
   - Ports: 'input', 'output_n', 'output_e', 'output_s', 'output_w'

✅ Filter evaluation order:
   1. Check port-specific filter
   2. Check global filter
   3. Both must pass for item to enter/exit
```

#### AC2: Multi-Storage Networks
```
✅ Supported patterns:
   - Mining → Storage A (ore) → Smelter
   - Smelter → Storage B (bars) → Workshop
   - Workshop → Storage C (tools) → Farm

✅ Network validation:
   - Detect cycles (warn player)
   - Detect dead ends (warn player)
   - Suggest optimizations
```

#### AC3: Error Handling
```
✅ Stuck items:
   - Display: "⚠ Coal stuck in Storage A"
   - Tap notification → Storage settings
   - Suggest fix: Change filter

✅ Overflow protection:
   - Storage at 90%: Yellow warning
   - Storage at 100%: Red warning + pause input
   - Automatic resume when space available

✅ Network diagnostics:
   - "Show flow" button: Highlight all paths
   - Bottleneck detection: Red on slowest link
   - Throughput stats: Items/minute per route
```

#### AC4: Performance Optimization
```
✅ Network efficiency:
   - Cache connected components
   - Lazy path recalculation
   - Batch item movements

✅ Memory limits:
   - Max 100 conveyor tiles per network
   - Max 500 items in transit
   - Warn player if approaching limits
```

#### AC5: Unit Tests Pass
```
✅ Test: Global filter blocks correctly
✅ Test: Port filter overrides global
✅ Test: Multi-hop network works
✅ Test: Stuck item detected
✅ Test: Overflow warning triggers
✅ Test: Cycle detection works
✅ Test: Performance under 100ms for 100 tiles
```

### Implementation Notes

**Files to Create:**
- `lib/domain/entities/storage_network.dart` - Network graph
- `lib/domain/usecases/validate_network_usecase.dart` - Validation
- `lib/domain/usecases/diagnose_network_usecase.dart` - Diagnostics
- `lib/presentation/widgets/network_diagnostics.dart` - UI
- `test/domain/usecases/validate_network_usecase_test.dart` - Tests

**Network Example:**
```
Mining → Conveyor → [STORAGE A] → Conveyor → [SMELTER]
                          ↓
                    Filters: Coal + Ore

Smelter → Conveyor → [STORAGE B] → Conveyor → [WORKSHOP]
                          ↓
                    Filters: Żelazo only
```

**Dependencies:**
- STORY-03.2 (Conveyor network)
- STORY-03.3 (Filtering)
- STORY-03.4 (Splitters)
- EPIC-02 Storage building

**Blocks:**
- EPIC-04 (Offline uses network graph)

---

## STORY-03.7: Integration Testing & Performance (5 SP)

### Objective
Validate complete automation chains work correctly and meet performance targets.

### User Story
As a developer, I need to verify the entire automation system works together at 60 FPS so players have a smooth experience.

### Description
This is the validation story that tests all automation components working together under realistic conditions.

### Acceptance Criteria

#### AC1: Full Automation Chain Test
```
✅ Complete chain works:
   Mining → Conveyor → Storage → Conveyor → Smelter →
   Conveyor → Storage → Conveyor → Workshop →
   Conveyor → Storage → Conveyor → Farm

✅ Verification:
   - Items flow from start to end
   - No items lost in transit
   - Filters route correctly
   - Splitters distribute correctly
   - Farm converts to gold
```

#### AC2: Backpressure Integration
```
✅ Backpressure cascade:
   - Block Farm output
   - Workshop pauses (output full)
   - Smelter pauses (Workshop full)
   - Mining pauses (Smelter full)
   - All queues preserved

✅ Resume cascade:
   - Unblock Farm
   - Items resume in order
   - No item loss
   - Correct FIFO ordering
```

#### AC3: Performance Targets
```
✅ 60 FPS requirements:
   - 50 conveyors + 100 items in transit
   - Smooth animations at 60 FPS
   - No frame drops during item movement
   - Tested on Snapdragon 660 equivalent

✅ Profiling metrics:
   - Transport tick: <5ms per frame
   - Path recalculation: <100ms
   - Memory: <20MB for automation
```

#### AC4: Edge Cases
```
✅ Stress tests:
   - 100 items on single conveyor (max)
   - 50 splitters in network
   - Cycle detection (A→B→C→A)
   - Disconnect mid-transport

✅ Error recovery:
   - Building demolished mid-transport
   - Conveyor removed with items
   - Grid expansion with active network
```

#### AC5: Integration Tests Pass
```
✅ Test: Full Mining→Farm chain completes
✅ Test: Backpressure cascade and recovery
✅ Test: 60 FPS with 50 conveyors
✅ Test: 100 items in transit simultaneously
✅ Test: Splitter network with 3 outputs each
✅ Test: Filter network sorts correctly
✅ Test: Building removal handles gracefully
✅ Test: Grid expansion preserves network
```

### Implementation Notes

**Files to Create:**
- `integration_test/automation_chain_test.dart` - Full chain
- `integration_test/backpressure_test.dart` - Cascade
- `integration_test/performance_test.dart` - 60 FPS
- `lib/domain/usecases/profile_automation_usecase.dart` - Metrics

**Performance Test Setup:**
```dart
// Create 50 conveyor network
// Spawn 100 items at intervals
// Measure frame time for 60 seconds
// Assert: 95% of frames < 16.67ms (60 FPS)
```

**Dependencies:**
- All STORY-03.x complete

**Blocks:**
- EPIC-04 (Offline depends on working automation)

---

## Story Summary Table

| Story | SP | Focus | Dependencies |
|-------|----|----|------|
| **STORY-03.1** | 5 | A* Pathfinding | EPIC-02 |
| **STORY-03.2** | 8 | Conveyor Transport | 03.1 |
| **STORY-03.3** | 5 | Filtering System | 03.2 |
| **STORY-03.4** | 5 | Splitter System | 03.2, 03.3 |
| **STORY-03.5** | 8 | Conveyor UI | 03.1-03.4 |
| **STORY-03.6** | 6 | Storage Networks | 03.2-03.4 |
| **STORY-03.7** | 5 | Integration & Perf | 03.1-03.6 |
| **TOTAL** | **42 SP** | Tier 2 Automation | - |

---

## Implementation Order

**Recommended Sprint 3-4:**

**Week 1:** Foundation
1. STORY-03.1: A* Pathfinding (5 SP)
2. STORY-03.2: Conveyor Transport (8 SP)

**Week 2:** Features
3. STORY-03.3: Filtering System (5 SP)
4. STORY-03.4: Splitter System (5 SP)

**Week 3:** Integration
5. STORY-03.5: Conveyor UI (8 SP)
6. STORY-03.6: Storage Networks (6 SP)
7. STORY-03.7: Integration Testing (5 SP)

---

## Success Metrics

**After EPIC-03 Complete:**
- ✅ A* pathfinding <100ms for 50-tile path
- ✅ Conveyor transport at 0.5 items/sec
- ✅ 4-mode filtering working correctly
- ✅ Splitters distribute with round-robin
- ✅ 60 FPS with 50 conveyors + 100 items
- ✅ Full automation chain: Mining → Farm
- ✅ All tests passing

**When EPIC-03 Complete:**
- Overall Progress: ~31% (115/289 SP)
- Ready to start: EPIC-04 (Offline Production)
- Automation differentiates from idle clickers
- Session length +20% expected

---

**Document Status:** 📋 Ready for Development
**Last Updated:** 2025-12-03
**Version:** 1.0
**Next Review:** After STORY-03.1 complete
