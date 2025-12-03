# Epic Technical Specification: Planning & Automation (EPIC-03)

Date: 2025-11-23
Author: Claude (BMAD Game Development Agent)
Epic ID: EPIC-03
Epic Name: Tier 2 Automation / Planning Systems
Status: Ready for Implementation
Group: B - Operations

---

## Overview

Epic 03 delivers the **Planning & Automation** core system that transforms Trade Factory Masters from a simple collection game into a strategic automation factory builder. This epic implements **A* pathfinding**, **conveyor belt systems**, and **automated resource transport** - the key differentiator from competitor games.

**Epic Goal:** Enable players to design and automate complex production chains using conveyors that intelligently transport resources between buildings.

**Business Value:**
- **Core Differentiator:** Automation gameplay distinguishes us from idle clickers (Tap Titans, Cookie Clicker)
- **Engagement Driver:** Planning optimal routes creates "one more turn" gameplay loop
- **Retention Impact:** 60%+ players unlock Tier 2 within 2-3 hours (target metric)
- **Monetization Hook:** Premium "Auto-Optimize Routes" IAP ($2.99) for advanced players

**Technical Complexity:** HIGH (8-13 SP stories) due to A* algorithm implementation, performance optimization for 60 FPS with 50+ active conveyors, and complex state management.

---

## Objectives and Scope

### In-Scope (Must Have)

✅ **A* Pathfinding Algorithm**
- Manhattan distance heuristic for grid-based pathfinding
- Obstacle avoidance (existing buildings, other conveyors, terrain)
- Performance: <100ms for 50-tile paths on Snapdragon 660 (target device)
- Return optimal path or null if no valid route exists

✅ **Conveyor Entity System**
- ConveyorRoute data model (start/end buildings, path, resource type, state)
- JSON serialization for Hive (local) and Firestore (cloud save)
- State management: active, paused, blocked (insufficient resources)
- Travel time calculation: 1 tile/second base speed (upgradeable to 0.5s/tile at Level 5)

✅ **Conveyor Rendering**
- Flame sprite rendering for conveyor tiles (belt, arrows, direction indicators)
- Resource sprite animation along path (smooth movement, 1 tile/sec)
- Visual feedback: green (active), yellow (paused), red (blocked)
- Performance: 60 FPS with 50+ conveyors + 100+ animated resource sprites

✅ **Placement & Validation System**
- UI: Tap start building → tap end building → preview path → confirm/cancel
- Path validation: Check all tiles unoccupied before placement
- Cost calculation: 10 gold/tile (encourages efficient route planning)
- Undo/delete conveyor functionality

✅ **AI Route Suggestion**
- "Suggest Route" button analyzes building placement
- Identifies unconnected production chains (e.g., Lumbermill → Smelter gap)
- Calls A* pathfinder and presents suggested path with cost preview
- Player can accept, modify, or reject suggestion

### Out-of-Scope (Future Phases)

❌ **Advanced Features (Post-MVP)**
- Conveyor upgrades (speed, multi-resource support) → EPIC-06 Progression
- Route optimization algorithms (minimize total tile count) → Phase 2
- Underground conveyors (pass through buildings) → Month 3 feature
- Conveyor junction splits (1 input → 2 outputs) → Post-launch

❌ **Performance Enhancements (If Needed)**
- Spatial hashing for collision detection (only if FPS <50)
- WebGL sprite batching (Flame supports natively, may not need custom solution)
- Conveyor pooling (object pooling pattern) → optimize if >100 conveyors

### Success Criteria (Testable)

| Metric | Target | Measurement |
|--------|--------|-------------|
| A* Performance | <100ms for 50-tile path | Performance test on Snapdragon 660 emulator |
| Rendering Performance | 60 FPS with 50 conveyors + 100 sprites | FPS counter in debug mode |
| Pathfinding Accuracy | 100% success for valid paths | 25 unit tests (various grid configurations) |
| Player Adoption | 60%+ players place ≥1 conveyor | Firebase Analytics event tracking |
| Session Length | +20% avg session time vs Tier 1 | A/B test with/without conveyors |

---

## System Architecture Alignment

### Clean Architecture Layers

**Domain Layer (lib/domain/)**
```
lib/domain/entities/
  ├── conveyor_route.dart         # Core entity: path, state, metadata
  ├── building.dart                # Extended: input/output connection points
  └── resource_flow.dart           # New: Represents resource in transit

lib/domain/use_cases/
  ├── pathfinding/
  │   ├── find_conveyor_path.dart  # A* algorithm implementation
  │   ├── validate_path.dart       # Check path validity (obstacles, cost)
  │   └── suggest_optimal_routes.dart # AI route suggestion logic
  └── conveyors/
      ├── place_conveyor.dart      # Create conveyor, deduct gold, validate
      ├── delete_conveyor.dart     # Remove, refund 50% gold
      └── transport_resources.dart # Move resources along path (game loop)

lib/domain/repositories/
  └── conveyor_repository.dart     # Abstract: save/load conveyors
```

**Data Layer (lib/data/)**
```
lib/data/models/
  └── conveyor_route_model.dart    # JSON serialization, Hive TypeAdapter

lib/data/repositories/
  ├── conveyor_repository_impl.dart      # Implements domain interface
  └── local_cache/
      └── hive_conveyor_cache.dart       # Offline-first caching
```

**Presentation Layer (lib/presentation/)**
```
lib/presentation/screens/game/
  └── widgets/
      ├── conveyor_placement_overlay.dart # UI: start/end selection, preview
      ├── route_suggestion_button.dart    # "AI Suggest" button
      └── conveyor_cost_display.dart      # "Cost: 150 gold (15 tiles)"

lib/presentation/providers/
  ├── conveyor_placement_provider.dart    # @riverpod state for placement flow
  └── pathfinding_provider.dart           # Cached A* results (memoization)
```

**Game Layer (lib/game/)**
```
lib/game/systems/
  ├── pathfinding_system.dart      # A* algorithm (pure Dart, no Flame deps)
  └── conveyor_system.dart         # Flame system: update resource positions

lib/game/components/
  ├── conveyor_component.dart      # Flame component: sprite rendering
  └── resource_sprite_component.dart # Animated sprite moving along path
```

### Technology Stack Alignment

| Component | Technology | Justification |
|-----------|-----------|---------------|
| Pathfinding | Pure Dart (no packages) | A* is 100 lines, no external deps needed |
| Data Structure | `PriorityQueue` (collection package) | Efficient open set for A* algorithm |
| Sprites | Flame SpriteComponent | Native Flame rendering, sprite batching |
| Animation | Flame MoveEffect | Smooth 1 tile/sec movement along path |
| State | Riverpod @riverpod | Reactive state updates when conveyors placed |
| Storage | Hive TypeAdapter | Fast local save/load of conveyor state |
| Cloud Sync | Firestore subcollection | `users/{uid}/conveyors/{conveyorId}` |

### Integration Points

**Epic 01 (Core Loop) Dependencies:**
- Grid System: A* uses `GridManager.isOccupied(x, y)` for obstacle detection
- Building Entity: Extended with `inputConnections` and `outputConnections` sets

**Epic 02 (Economy) Dependencies:**
- Gold Deduction: Conveyor placement costs `10 gold × pathLength`
- Building Inventory: Resources consumed from output buildings, added to input buildings

**Provides to Epic 04 (Offline Production):**
- `List<ConveyorRoute>` persisted to Hive for offline calculation
- Topological sort uses conveyor graph to determine production order

---

## Detailed Design

### Services and Modules

#### 1. Pathfinding System (`lib/game/systems/pathfinding_system.dart`)

**Responsibility:** Find optimal path from point A to B using A* algorithm.

**API:**
```dart
class ConveyorPathfinder {
  final Size gridSize;
  final Set<Point<int>> occupiedTiles;

  ConveyorPathfinder({
    required this.gridSize,
    required this.occupiedTiles,
  });

  /// Finds shortest path using A* with Manhattan heuristic.
  /// Returns null if no valid path exists.
  List<Point<int>>? findPath(Point<int> start, Point<int> end) {
    // A* implementation (see Algorithm section below)
  }

  /// Validates if path is placeable (no obstacles on route).
  bool isPathValid(List<Point<int>> path) {
    return path.every((tile) => !occupiedTiles.contains(tile));
  }

  /// Calculates gold cost for path (10 gold/tile).
  int calculateCost(List<Point<int>> path) => path.length * 10;
}
```

**A* Algorithm (Pseudocode):**
```
1. Initialize openSet = PriorityQueue (sorted by fScore)
2. Initialize closedSet = Set<Point>
3. Initialize gScore = Map<Point, double> { start: 0 }
4. Initialize cameFrom = Map<Point, Point>

5. Add start node to openSet

6. While openSet not empty:
   a. current = openSet.removeFirst() (lowest fScore)
   b. If current == end: return reconstructPath(cameFrom, current)
   c. Add current to closedSet

   d. For each neighbor in getNeighbors(current):
      i.   If neighbor in closedSet OR occupiedTiles: skip
      ii.  tentativeGScore = gScore[current] + 1
      iii. If tentativeGScore < gScore[neighbor]:
           - cameFrom[neighbor] = current
           - gScore[neighbor] = tentativeGScore
           - fScore = tentativeGScore + heuristic(neighbor, end)
           - Add Node(neighbor, fScore) to openSet

7. Return null (no path found)
```

**Heuristic Function:**
```dart
double _heuristic(Point<int> a, Point<int> b) {
  // Manhattan distance (4-directional movement)
  return (a.x - b.x).abs() + (a.y - b.y).abs().toDouble();
}
```

#### 2. Conveyor System (`lib/game/systems/conveyor_system.dart`)

**Responsibility:** Update resource positions along conveyor paths (60 FPS game loop).

**API:**
```dart
class ConveyorSystem extends System {
  late final List<ConveyorRoute> _conveyors;
  late final Map<String, ResourceSprite> _activeResources;

  @override
  void update(double dt) {
    for (final conveyor in _conveyors.where((c) => c.state == ConveyorState.active)) {
      _updateResourceFlow(conveyor, dt);
    }
  }

  void _updateResourceFlow(ConveyorRoute conveyor, double dt) {
    // 1. Check if source building has resources
    final sourceBuilding = _getBuildingById(conveyor.startBuildingId);
    if (!sourceBuilding.hasOutputResource(conveyor.resourceType)) {
      conveyor.state = ConveyorState.blocked;
      return;
    }

    // 2. Spawn new resource sprite if cooldown expired
    if (conveyor.timeSinceLastSpawn >= conveyor.spawnInterval) {
      final resource = sourceBuilding.consumeOutputResource(conveyor.resourceType, 1);
      _spawnResourceSprite(resource, conveyor.path);
      conveyor.timeSinceLastSpawn = 0;
    }

    // 3. Update all resource sprites on this conveyor
    for (final sprite in _activeResources.values.where((s) => s.conveyorId == conveyor.id)) {
      sprite.position += sprite.velocity * dt; // Move along path

      // Check if reached destination
      if (sprite.currentPathIndex >= conveyor.path.length) {
        _deliverResource(sprite, conveyor.endBuildingId);
        _activeResources.remove(sprite.id);
      }
    }

    conveyor.timeSinceLastSpawn += dt;
  }
}
```

#### 3. Route Suggestion AI (`lib/domain/use_cases/pathfinding/suggest_optimal_routes.dart`)

**Responsibility:** Analyze building layout and suggest conveyor placements.

**Logic:**
```dart
class SuggestOptimalRoutesUseCase {
  final ConveyorPathfinder pathfinder;

  List<SuggestedRoute> execute(PlayerEconomy economy) {
    final suggestions = <SuggestedRoute>[];

    // 1. Find all buildings with output resources
    final producers = economy.buildings.where((b) => b.production.outputResource != null);

    // 2. Find all buildings that consume those resources
    for (final producer in producers) {
      final resourceType = producer.production.outputResource!.type;
      final consumers = economy.buildings.where(
        (b) => b.production.inputResources.contains(resourceType),
      );

      // 3. For each producer-consumer pair, check if already connected
      for (final consumer in consumers) {
        if (_isConnected(producer, consumer, economy.conveyors)) continue;

        // 4. Try to find path
        final path = pathfinder.findPath(
          producer.gridPosition,
          consumer.gridPosition,
        );

        if (path != null) {
          suggestions.add(SuggestedRoute(
            from: producer,
            to: consumer,
            path: path,
            cost: path.length * 10,
            reason: 'Connect ${producer.type} → ${consumer.type} (${resourceType})',
          ));
        }
      }
    }

    // 5. Sort by priority (shortest path first, high-value resources prioritized)
    suggestions.sort((a, b) => a.cost.compareTo(b.cost));

    return suggestions.take(3).toList(); // Show top 3 suggestions
  }
}
```

---

### Data Models and Contracts

#### ConveyorRoute Entity

```dart
import 'package:equatable/equatable.dart';

enum ConveyorState { active, paused, blocked }

class ConveyorRoute extends Equatable {
  final String id;
  final String startBuildingId;
  final String endBuildingId;
  final List<Point<int>> path;
  final ResourceType resourceType;
  final ConveyorState state;
  final int level; // 1-5, affects speed
  final double timeSinceLastSpawn; // Internal state for resource flow

  const ConveyorRoute({
    required this.id,
    required this.startBuildingId,
    required this.endBuildingId,
    required this.path,
    required this.resourceType,
    this.state = ConveyorState.active,
    this.level = 1,
    this.timeSinceLastSpawn = 0.0,
  });

  /// Base speed: 1 tile/sec at level 1, 0.5 tile/sec at level 5
  double get tileSpeed => 1.0 / level;

  /// Time between resource spawns (seconds)
  double get spawnInterval => 5.0; // Spawn 1 resource every 5 seconds

  /// Gold cost to place this conveyor
  int get placementCost => path.length * 10;

  /// Refund when deleting (50% of placement cost)
  int get deletionRefund => (placementCost * 0.5).toInt();

  @override
  List<Object?> get props => [
    id,
    startBuildingId,
    endBuildingId,
    path,
    resourceType,
    state,
    level,
  ];

  ConveyorRoute copyWith({
    ConveyorState? state,
    int? level,
    double? timeSinceLastSpawn,
  }) {
    return ConveyorRoute(
      id: id,
      startBuildingId: startBuildingId,
      endBuildingId: endBuildingId,
      path: path,
      resourceType: resourceType,
      state: state ?? this.state,
      level: level ?? this.level,
      timeSinceLastSpawn: timeSinceLastSpawn ?? this.timeSinceLastSpawn,
    );
  }
}
```

#### ConveyorRouteModel (Data Layer)

```dart
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'conveyor_route_model.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class ConveyorRouteModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String startBuildingId;

  @HiveField(2)
  final String endBuildingId;

  @HiveField(3)
  final List<Map<String, int>> path; // [{x: 0, y: 0}, {x: 1, y: 0}, ...]

  @HiveField(4)
  final String resourceType;

  @HiveField(5)
  final String state; // 'active', 'paused', 'blocked'

  @HiveField(6)
  final int level;

  ConveyorRouteModel({
    required this.id,
    required this.startBuildingId,
    required this.endBuildingId,
    required this.path,
    required this.resourceType,
    required this.state,
    required this.level,
  });

  factory ConveyorRouteModel.fromJson(Map<String, dynamic> json) =>
      _$ConveyorRouteModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConveyorRouteModelToJson(this);

  // Domain entity conversion
  ConveyorRoute toDomain() {
    return ConveyorRoute(
      id: id,
      startBuildingId: startBuildingId,
      endBuildingId: endBuildingId,
      path: path.map((p) => Point<int>(p['x']!, p['y']!)).toList(),
      resourceType: ResourceType.values.firstWhere((t) => t.name == resourceType),
      state: ConveyorState.values.firstWhere((s) => s.name == state),
      level: level,
    );
  }

  static ConveyorRouteModel fromDomain(ConveyorRoute conveyor) {
    return ConveyorRouteModel(
      id: conveyor.id,
      startBuildingId: conveyor.startBuildingId,
      endBuildingId: conveyor.endBuildingId,
      path: conveyor.path.map((p) => {'x': p.x, 'y': p.y}).toList(),
      resourceType: conveyor.resourceType.name,
      state: conveyor.state.name,
      level: conveyor.level,
    );
  }
}
```

---

### APIs and Interfaces

#### ConveyorRepository (Domain Interface)

```dart
abstract class ConveyorRepository {
  /// Fetches all conveyors for current player (local + cloud merge)
  Future<List<ConveyorRoute>> getConveyors();

  /// Saves conveyor to local cache and syncs to Firestore
  Future<void> saveConveyor(ConveyorRoute conveyor);

  /// Deletes conveyor from local cache and Firestore
  Future<void> deleteConveyor(String conveyorId);

  /// Batch update for offline production (efficient bulk update)
  Future<void> updateConveyorStates(Map<String, ConveyorState> updates);
}
```

#### ConveyorRepositoryImpl (Data Layer)

```dart
class ConveyorRepositoryImpl implements ConveyorRepository {
  final Box<ConveyorRouteModel> _hiveBox;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ConveyorRepositoryImpl(this._hiveBox, this._firestore, this._auth);

  @override
  Future<List<ConveyorRoute>> getConveyors() async {
    final userId = _auth.currentUser!.uid;

    // 1. Load from local cache first (offline-first)
    final localConveyors = _hiveBox.values.map((m) => m.toDomain()).toList();

    // 2. Sync from Firestore if online
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('conveyors')
          .get()
          .timeout(Duration(seconds: 3));

      final cloudConveyors = snapshot.docs
          .map((doc) => ConveyorRouteModel.fromJson(doc.data()).toDomain())
          .toList();

      // 3. Merge: cloud wins for conflicts (last-write-wins)
      final merged = _mergeConveyors(localConveyors, cloudConveyors);

      // 4. Update local cache
      await _hiveBox.clear();
      for (final conveyor in merged) {
        await _hiveBox.put(conveyor.id, ConveyorRouteModel.fromDomain(conveyor));
      }

      return merged;
    } catch (e) {
      // Offline or network error: return local cache
      return localConveyors;
    }
  }

  @override
  Future<void> saveConveyor(ConveyorRoute conveyor) async {
    final model = ConveyorRouteModel.fromDomain(conveyor);

    // 1. Save to local cache immediately
    await _hiveBox.put(conveyor.id, model);

    // 2. Sync to Firestore (fire-and-forget, retry on next app open)
    final userId = _auth.currentUser!.uid;
    _firestore
        .collection('users')
        .doc(userId)
        .collection('conveyors')
        .doc(conveyor.id)
        .set(model.toJson())
        .catchError((e) => print('Firestore sync failed: $e'));
  }

  // ... deleteConveyor, updateConveyorStates implementations
}
```

---

### Workflows and Sequencing

#### Workflow 1: Player Places Conveyor

```
┌──────────┐     ┌────────────────┐     ┌──────────────┐     ┌────────────┐
│  Player  │     │ Presentation   │     │   Domain     │     │    Data    │
│          │     │     Layer      │     │    Layer     │     │   Layer    │
└────┬─────┘     └────────┬───────┘     └──────┬───────┘     └─────┬──────┘
     │                    │                    │                   │
     │ 1. Tap "Conveyor"  │                    │                   │
     ├───────────────────>│                    │                   │
     │                    │                    │                   │
     │ 2. Tap Start       │                    │                   │
     │    Building        │                    │                   │
     ├───────────────────>│                    │                   │
     │                    │                    │                   │
     │ 3. Tap End         │                    │                   │
     │    Building        │                    │                   │
     ├───────────────────>│                    │                   │
     │                    │ 4. FindPath        │                   │
     │                    │    (start, end)    │                   │
     │                    ├───────────────────>│                   │
     │                    │                    │                   │
     │                    │ 5. Path Preview    │                   │
     │                    │<───────────────────┤                   │
     │                    │                    │                   │
     │ 6. Confirm         │                    │                   │
     ├───────────────────>│                    │                   │
     │                    │ 7. PlaceConveyor   │                   │
     │                    │    (path, cost)    │                   │
     │                    ├───────────────────>│                   │
     │                    │                    │ 8. ValidatePath   │
     │                    │                    │    & DeductGold   │
     │                    │                    ├───────────────────┤
     │                    │                    │                   │
     │                    │                    │ 9. SaveConveyor   │
     │                    │                    ├──────────────────>│
     │                    │                    │                   │
     │                    │                    │10. Success        │
     │                    │                    │<──────────────────┤
     │                    │11. ConveyorPlaced  │                   │
     │                    │    Event           │                   │
     │                    │<───────────────────┤                   │
     │                    │                    │                   │
     │12. Show Conveyor   │                    │                   │
     │    on Grid         │                    │                   │
     │<───────────────────┤                    │                   │
     │                    │                    │                   │
```

#### Workflow 2: Resource Transport (Game Loop)

```
Every Frame (60 FPS):
1. ConveyorSystem.update(dt) called by Flame engine
2. For each active conveyor:
   a. Check if source building has resources
      - If yes: Proceed to step 3
      - If no: Mark conveyor as 'blocked', show red indicator

   b. Check spawn cooldown (timeSinceLastSpawn >= 5 seconds)
      - If ready: Spawn new ResourceSprite at start position
      - If not ready: Increment timeSinceLastSpawn += dt

   c. Update all ResourceSprite positions on this conveyor
      - Move sprite along path (velocity = 1 tile/sec × dt)
      - If reached next path point: Increment sprite.currentPathIndex
      - If reached end of path: Deliver resource to destination building

3. Render all conveyor sprites (Flame batches automatically)
4. Render all resource sprites (Flame batches automatically)
```

**Performance Optimization:**
- **Sprite Batching:** Flame automatically batches sprites with same texture
- **Culling:** Only update/render conveyors in viewport (CameraComponent.visibleRect)
- **Fixed Timestep:** Use `update(double dt)` for frame-rate independent movement

---

## Non-Functional Requirements

### Performance

**Target Device:** Snapdragon 660, 4GB RAM (mid-tier Android phone from 2018)

| Metric | Requirement | Test Method |
|--------|-------------|-------------|
| Frame Rate | 60 FPS sustained | Debug FPS counter, 5-min gameplay session |
| A* Pathfinding | <100ms for 50-tile path | Performance test: `Stopwatch` in unit test |
| Conveyor Rendering | 50+ conveyors, 100+ sprites | Stress test: Place max conveyors, monitor FPS |
| Memory Usage | <200MB RAM for game layer | Android Studio Profiler |
| Battery Drain | <10% per hour | Manual test: 1-hour gameplay session |

**Optimization Strategies:**
1. **Object Pooling:** Reuse ResourceSprite components (create pool of 200 sprites)
2. **Spatial Partitioning:** Grid-based culling (only render visible conveyors)
3. **A* Caching:** Memoize frequently used paths (e.g., common building positions)
4. **Sprite Atlases:** Pack all conveyor/resource sprites into single texture (reduce draw calls)

### Security

**Data Integrity:**
- **Client-Side Validation:** Check path validity before placement (prevent cheating)
- **Server-Side Validation:** Cloud Functions validate gold cost on Firestore write
  ```javascript
  // Firebase Cloud Function
  exports.validateConveyorPlacement = functions.firestore
    .document('users/{userId}/conveyors/{conveyorId}')
    .onCreate((snap, context) => {
      const conveyor = snap.data();
      const pathLength = conveyor.path.length;
      const expectedCost = pathLength * 10;

      // Check if player has enough gold (read from users/{userId}/economy)
      // If not: Delete conveyor document, log cheat attempt
    });
  ```

**Anti-Cheat:**
- **Path Validation:** Server checks all path tiles are valid (no diagonal, no out-of-bounds)
- **Cost Verification:** Server recalculates cost and verifies gold deduction
- **Rate Limiting:** Max 100 conveyors per player (prevent spam/DOS)

### Reliability/Availability

**Offline Support:**
- **Local-First:** All conveyor data cached in Hive (works offline)
- **Sync on Connect:** Merge local + cloud state when connection restored
- **Conflict Resolution:** Last-write-wins (cloud timestamp > local timestamp)

**Error Handling:**
```dart
try {
  final path = pathfinder.findPath(start, end);
  if (path == null) {
    showSnackBar('No valid path found. Try different positions.');
    return;
  }
} catch (e, stackTrace) {
  FirebaseCrashlytics.instance.recordError(e, stackTrace);
  showSnackBar('Pathfinding error. Please restart the app.');
}
```

### Observability

**Firebase Analytics Events:**
```dart
// Track conveyor placement
FirebaseAnalytics.instance.logEvent(
  name: 'conveyor_placed',
  parameters: {
    'path_length': path.length,
    'cost': pathCost,
    'resource_type': resourceType.name,
    'ai_suggested': usedAISuggestion, // true/false
  },
);

// Track pathfinding performance
FirebaseAnalytics.instance.logEvent(
  name: 'pathfinding_performance',
  parameters: {
    'duration_ms': stopwatch.elapsedMilliseconds,
    'path_length': path?.length ?? 0,
    'grid_size': '${gridSize.width}x${gridSize.height}',
  },
);
```

**Crashlytics Custom Keys:**
```dart
FirebaseCrashlytics.instance.setCustomKey('active_conveyors', conveyors.length);
FirebaseCrashlytics.instance.setCustomKey('grid_size', '50x50');
```

---

## Dependencies and Integrations

### Upstream Dependencies (Must Complete First)

| Epic/Story | Dependency Type | Required Artifacts |
|------------|----------------|-------------------|
| **EPIC-01: Core Loop** | Hard Dependency | `GridManager.isOccupied()`, `Building.gridPosition` |
| **STORY-01.5: Grid System** | Hard Dependency | Grid rendering, tile coordinate system |
| **EPIC-02: Economy** | Hard Dependency | `PlayerEconomy.gold`, `Building.production.outputResource` |
| **STORY-02.1: Resource Definitions** | Hard Dependency | `ResourceType` enum, `ResourceDefinition` class |

### Downstream Dependents (Will Use This Epic)

| Epic/Story | How It Uses EPIC-03 |
|------------|---------------------|
| **EPIC-04: Offline Production** | Uses `List<ConveyorRoute>` for topological sort, resource flow simulation |
| **EPIC-06: Progression** | Tier 2 unlock requires placing ≥1 conveyor (achievement) |
| **EPIC-10: Analytics** | Tracks conveyor placement rate, AI suggestion adoption, avg path length |

### External Integrations

| Service | Purpose | API Endpoint |
|---------|---------|-------------|
| Firebase Firestore | Cloud save for conveyors | `users/{uid}/conveyors/{conveyorId}` |
| Firebase Analytics | Event tracking | `FirebaseAnalytics.instance.logEvent()` |
| Hive | Local cache | `Box<ConveyorRouteModel>('conveyors')` |

---

## Acceptance Criteria (Authoritative)

### Functional Acceptance Criteria

✅ **AC-1: Pathfinding Accuracy**
- Given: 50×50 grid with obstacles (buildings at random positions)
- When: Player requests path from (0, 0) to (49, 49)
- Then: A* returns optimal path OR null if no valid path exists
- Test: 25 unit tests with various grid configurations

✅ **AC-2: Conveyor Placement**
- Given: Player has 500 gold, 2 buildings at (5,5) and (10,10)
- When: Player taps "Conveyor" → taps building A → taps building B → confirms
- Then:
  - Path preview shown with cost (e.g., "8 tiles × 10 gold = 80 gold")
  - On confirm: Conveyor created, 80 gold deducted
  - Conveyor renders on grid with green color (active state)
- Test: Widget test + integration test

✅ **AC-3: Resource Transport**
- Given: Conveyor connecting Lumbermill (produces Wood) to Smelter (consumes Wood)
- When: 60 seconds elapse (game time)
- Then:
  - 12 Wood sprites spawn (1 every 5 seconds)
  - Each sprite moves along path at 1 tile/sec
  - When sprite reaches Smelter: Wood added to Smelter's input storage
- Test: Integration test with mocked time

✅ **AC-4: AI Route Suggestion**
- Given: 3 buildings (A produces Wood, B unconnected, C consumes Wood)
- When: Player taps "Suggest Routes" button
- Then:
  - UI shows "Suggested: A → C (5 tiles, 50 gold)"
  - On accept: Conveyor auto-placed, gold deducted
- Test: Unit test for suggestion logic + widget test for UI

✅ **AC-5: Performance**
- Given: 50 conveyors placed, 100 resource sprites active
- When: Player plays for 5 minutes
- Then: FPS stays ≥60 FPS (measured with debug counter)
- Test: Performance test on Snapdragon 660 emulator

### Non-Functional Acceptance Criteria

✅ **AC-6: Offline Support**
- Given: 10 conveyors placed while online
- When: Player goes offline → closes app → reopens offline
- Then: All 10 conveyors render and transport resources (no cloud needed)
- Test: Manual test with airplane mode

✅ **AC-7: Error Handling**
- Given: Player tries to place conveyor with path that crosses obstacles
- When: Pathfinder returns null
- Then: Show error: "No valid path. Try different positions."
- Test: Unit test for null path handling

---

## Traceability Mapping

| Requirement | Epic/Story | Acceptance Criteria |
|-------------|-----------|---------------------|
| **FR-003: Tier 2 Automation** | EPIC-03 (this doc) | AC-1 through AC-5 |
| FR-003.1: A* Pathfinding | STORY-03.1 | AC-1 (Pathfinding Accuracy) |
| FR-003.2: Conveyor Placement | STORY-03.3 | AC-2 (Conveyor Placement) |
| FR-003.3: Resource Transport | STORY-03.4 | AC-3 (Resource Transport) |
| FR-003.4: AI Suggestions | STORY-03.5 | AC-4 (AI Route Suggestion) |
| **NFR-001: Performance** | Cross-cutting | AC-5 (60 FPS with 50 conveyors) |
| **NFR-002: Offline-First** | Cross-cutting | AC-6 (Offline Support) |

---

## Risks, Assumptions, Open Questions

### High Risks

🔴 **RISK-1: A* Performance on Low-End Devices**
- **Impact:** HIGH - Pathfinding >100ms breaks 60 FPS target
- **Likelihood:** MEDIUM - A* is O(n log n), may struggle on 50×50 grid with obstacles
- **Mitigation:**
  1. Implement A* with binary heap (not PriorityQueue) for faster open set operations
  2. Add path caching: Store frequently used paths in Map<(start, end), path>
  3. Fallback: If pathfinding >100ms, show loading spinner (non-blocking)
- **Contingency:** If still slow, limit grid size to 30×30 for pathfinding (performance mode)

🔴 **RISK-2: FPS Drop with 50+ Conveyors**
- **Impact:** HIGH - <60 FPS causes poor user experience, negative reviews
- **Likelihood:** MEDIUM - 50 conveyors × 100 sprites = 5000 draw calls/frame
- **Mitigation:**
  1. Use Flame sprite batching (automatic, same texture = 1 draw call)
  2. Implement object pooling for ResourceSprite (reuse components)
  3. Culling: Only render conveyors in viewport
- **Contingency:** Reduce max conveyors to 30, or add "Low Graphics Mode" setting

🟡 **RISK-3: Offline Production with Conveyors (Complex)**
- **Impact:** MEDIUM - Wrong offline calculation = players lose resources = churn
- **Likelihood:** MEDIUM - Topological sort + resource flow simulation is complex
- **Mitigation:**
  1. Extensive unit tests (40+ tests for STORY-04.2)
  2. Add "Offline Production Log" UI to show calculation details (transparency)
  3. Beta test with 100 players before launch
- **Contingency:** Disable conveyor offline production in v1.0, add in v1.1 after validation

### Assumptions

1. **Pathfinding Grid:** Assumes 50×50 grid is sufficient for MVP (can expand later)
2. **4-Directional Movement:** Assumes no diagonal movement (simplifies A* heuristic)
3. **Single Resource per Conveyor:** Assumes conveyors transport 1 resource type (multi-resource in v2.0)
4. **No Conveyor Intersections:** Assumes conveyors cannot cross each other (simplifies collision)

### Open Questions

❓ **Q1:** Should conveyors have visual levels (e.g., Level 3 = blue belt)?
- **Decision Needed By:** Sprint 3 planning
- **Owner:** UX Designer
- **Impact:** Medium (affects sprite assets needed)

❓ **Q2:** Should AI suggestions be free or cost gold?
- **Decision Needed By:** Sprint 3 planning
- **Owner:** Game Designer
- **Impact:** Low (balance decision, can A/B test)

❓ **Q3:** Should conveyors auto-pause when source runs out of resources?
- **Decision Needed By:** Sprint 4 (before STORY-03.4)
- **Owner:** Game Designer
- **Current Approach:** Show "blocked" state (red color), don't pause (still consumes resources when available)

---

## Test Strategy Summary

### Unit Tests (Target: 90+ tests)

**Pathfinding (25 tests):**
- ✅ Find path (0,0) → (5,5) on empty grid = 11 tiles
- ✅ Find path with obstacles (building at 2,2) = detour around
- ✅ No path exists (end surrounded by obstacles) = return null
- ✅ Path to self (start == end) = [start]
- ✅ Path with single obstacle blocking direct route
- ✅ Performance: 50-tile path in <100ms

**Conveyor Entity (15 tests):**
- ✅ Calculate travel time: 10-tile path at level 1 = 10 seconds
- ✅ Calculate cost: 15-tile path = 150 gold
- ✅ Calculate refund: 150 gold placement = 75 gold refund
- ✅ State transitions: active → blocked (no resources)
- ✅ JSON serialization roundtrip (toJson → fromJson)

**Route Suggestion (10 tests):**
- ✅ Suggest route: Lumbermill → unconnected Smelter
- ✅ No suggestions if all buildings connected
- ✅ Prioritize short paths over long paths
- ✅ Skip suggestions if no valid path exists

**Placement Use Case (20 tests):**
- ✅ Place conveyor: deduct gold, create ConveyorRoute entity
- ✅ Insufficient gold: throw exception, no conveyor created
- ✅ Invalid path (overlaps building): throw exception
- ✅ Delete conveyor: refund 50% gold, remove from list

**Transport Use Case (30 tests):**
- ✅ Spawn resource every 5 seconds (time-based test)
- ✅ Move resource along path (position updates)
- ✅ Deliver resource to destination building (inventory updated)
- ✅ Block conveyor if source has no resources

### Integration Tests (5 tests)

- ✅ End-to-end: Place conveyor → resources flow → destination receives
- ✅ Offline sync: Place conveyor offline → go online → syncs to Firestore
- ✅ Multi-conveyor: 3 conveyors active simultaneously, no conflicts
- ✅ AI suggestion accepted: Tap suggest → tap accept → conveyor placed
- ✅ Performance: 50 conveyors, 100 sprites, 60 FPS for 5 minutes

### Widget Tests (8 tests)

- ✅ Conveyor placement UI: Tap start → tap end → preview shown
- ✅ Cost display: "Cost: 150 gold (15 tiles)" shown in preview
- ✅ Confirm button: Tap confirm → conveyor renders on grid
- ✅ Cancel button: Tap cancel → no conveyor placed, no gold deducted
- ✅ Insufficient gold: Show error snackbar "Not enough gold"
- ✅ AI suggestion button: Tap → suggestion modal appears
- ✅ Conveyor state indicator: Green (active), red (blocked)
- ✅ Delete conveyor: Long-press → confirm delete → refund shown

### Performance Tests (3 tests)

- ✅ A* benchmark: 50-tile path in <100ms on Snapdragon 660
- ✅ FPS test: 50 conveyors + 100 sprites = 60 FPS sustained
- ✅ Memory test: Conveyor system uses <50MB RAM

**Total Tests:** 90+ unit + 5 integration + 8 widget + 3 performance = **106 tests**

---

## Implementation Notes

**Sprint Allocation:**
- **Sprint 3 (Week 5):** STORY-03.1 (A*), STORY-03.2 (Entity)
- **Sprint 4 (Week 6):** STORY-03.3 (Placement UI), STORY-03.4 (Transport), STORY-03.5 (Rendering)
- **Sprint 5 (Week 7):** STORY-03.6 (AI Suggestion), STORY-03.7 (Validation)

**Developer Notes:**
- Use `collection` package for PriorityQueue (part of Dart SDK)
- Flame's `SpriteComponent` automatically batches sprites with same texture
- Test on real device (Snapdragon 660) before sprint review
- Add debug overlay: Show pathfinding time, active conveyor count, FPS

**Code Review Checklist:**
- [ ] A* returns null for impossible paths (no infinite loops)
- [ ] All path tiles validated before placement (no cheating)
- [ ] Conveyor state updates trigger UI rebuild (Riverpod reactivity)
- [ ] Performance: No List.map() in update() loop (causes allocations)
- [ ] Tests: 100% coverage for pathfinding, conveyor entity, placement logic

---

**Document Status:** ✅ Ready for Development
**Next Steps:** Sprint 3 planning, assign STORY-03.1 and STORY-03.2
**Questions:** Contact Game Designer (AI suggestion pricing) or Architect (performance concerns)
