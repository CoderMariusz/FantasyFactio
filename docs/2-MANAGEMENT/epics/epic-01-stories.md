# Epic 1: Core Gameplay Loop - User Stories

<!-- AI-INDEX: epic, stories, core-gameplay, building, camera, grid -->

**Epic:** EPIC-01 - Core Gameplay Loop
**Total Stories:** 8
**Total SP:** 34
**Sprint:** 1
**Status:** ✅ Implemented (with bugs)

---

## Story Overview

| Story ID | Title | SP | Priority | Implementation Status |
|----------|-------|-----|----------|----------------------|
| STORY-01.1 | Building Entity | 3 | P0 | ✅ Done |
| STORY-01.2 | Resource & PlayerEconomy | 3 | P0 | ⚠️ Bug #2 |
| STORY-01.3 | Collect Resources UseCase | 5 | P0 | ✅ Done |
| STORY-01.4 | Upgrade Building UseCase | 5 | P0 | ✅ Done |
| STORY-01.5 | Grid System | 5 | P0 | ✅ Done |
| STORY-01.6 | Dual Zoom Camera | 8 | P0 | ⚠️ TODO animation |
| STORY-01.7 | Building Sprite Component | 3 | P0 | ✅ Done |
| STORY-01.8 | Integration Test | 5 | P1 | ❌ Bug #1 |

---

## STORY-01.1: Domain Layer - Building Entity ✅

### Objective
Zdefiniować Building domain entity z logiką produkcji i upgrade.

### User Story
**As a** developer
**I want** Building domain entity with production logic
**So that** I can implement core gameplay mechanics

### Acceptance Criteria

- [x] **AC1:** Building entity created (`lib/domain/entities/building.dart`)

- [x] **AC2:** Properties: id, type, level, gridPosition, production, upgradeConfig, lastCollected
```dart
class Building extends Equatable {
  final String id;
  final BuildingType type;     // collector, processor, storage, conveyor, market
  final int level;             // 1-10 (differs from spec: 1-5)
  final GridPosition gridPosition;
  final ProductionConfig production;
  final UpgradeConfig upgradeConfig;
  final DateTime lastCollected;
  final bool isActive;         // Added: not in original spec
}
```

- [x] **AC3:** Computed property: `productionRate`
```dart
double get productionRate =>
    production.baseRate * (1 + (level - 1) * 0.2);
```

- [x] **AC4:** Method: `canUpgrade(int playerGold)`

- [x] **AC5:** Method: `calculateUpgradeCost()`

- [x] **AC6:** Unit tests pass

### Implementation Notes

**File:** `trade_factory_masters/lib/domain/entities/building.dart`

**Differences from spec:**
- BuildingType: generic (collector, processor) vs specific (lumbermill, mine)
- maxLevel: 10 vs spec's 5
- Added `isActive` field

**Tests:** `test/domain/entities/building_test.dart`

**Story Points:** 3 SP
**Status:** ✅ DONE

---

## STORY-01.2: Domain Layer - Resource & PlayerEconomy Entities ⚠️

### Objective
Zdefiniować Resource i PlayerEconomy entities do zarządzania stanem gry.

### User Story
**As a** developer
**I want** Resource and PlayerEconomy entities
**So that** I can manage game state

### Acceptance Criteria

- [x] **AC1:** Resource entity created

- [x] **AC2:** PlayerEconomy entity created

- [x] **AC3:** Method: `canAfford(int goldCost)`

- [⚠️] **AC4:** Method: `addResource()` - **BUG #2**
```dart
// ❌ Current implementation (BROKEN):
PlayerEconomy addResource(String resourceId, int amountToAdd) {
  if (!inventory.containsKey(resourceId)) {
    return this;  // Returns unchanged - WRONG!
  }
  // ...
}

// ✅ Expected behavior:
PlayerEconomy addResource(String resourceId, int amountToAdd) {
  if (!inventory.containsKey(resourceId)) {
    // Should CREATE new Resource with amount
    final newResource = Resource(id: resourceId, amount: amountToAdd, ...);
    return copyWith(inventory: {...inventory, resourceId: newResource});
  }
  // ...
}
```

- [x] **AC5:** Method: `deductGold()`

- [x] **AC6:** Unit tests pass

### Implementation Notes

**File:** `trade_factory_masters/lib/domain/entities/player_economy.dart`

**Bug #2 - CRITICAL:**
- Lines 52-56
- `addResource()` returns unchanged PlayerEconomy if resource not in inventory
- Breaks core gameplay: resources collected but not added

**Story Points:** 3 SP
**Status:** ⚠️ BUG - needs fix

---

## STORY-01.3: Use Case - Collect Resources ✅

### Objective
Zaimplementować CollectResourcesUseCase do zbierania zasobów z budynku.

### User Story
**As a** player
**I want** to tap a building to collect produced resources
**So that** I earn materials and gold

### Acceptance Criteria

- [x] **AC1:** CollectResourcesUseCase created

- [x] **AC2:** Calculate resources based on elapsed time
```dart
final elapsed = now.difference(building.lastCollected);
final hoursElapsed = elapsed.inMinutes / 60.0;
final rawProduction = hoursElapsed * building.productionRate;
```

- [x] **AC3:** Apply storage capacity limit
```dart
final storageCapacity = building.production.baseRate * 10;
final cappedProduction = min(rawProduction, storageCapacity);
```

- [x] **AC4:** Update building lastCollected timestamp

- [x] **AC5:** Return CollectResourcesResult

- [x] **AC6:** Unit tests pass

### Implementation Notes

**File:** `trade_factory_masters/lib/domain/usecases/collect_resources.dart`

**Differences from spec:**
- Production per hour (not per minute)
- Storage = baseRate × 10 (dynamic, not in ProductionConfig)
- Returns `CollectResourcesResult` with metadata

**Tests:** `test/domain/usecases/collect_resources_test.dart`

**Story Points:** 5 SP
**Status:** ✅ DONE

---

## STORY-01.4: Use Case - Upgrade Building ✅

### Objective
Zaimplementować UpgradeBuildingUseCase do ulepszania budynków.

### User Story
**As a** player
**I want** to upgrade a building to increase production
**So that** I earn resources faster

### Acceptance Criteria

- [x] **AC1:** UpgradeBuildingUseCase created

- [x] **AC2:** Check if player can afford
```dart
if (!economy.canAfford(upgradeCost)) {
  return Result.failure(UpgradeError.insufficientGold);
}
```

- [x] **AC3:** Check max level
```dart
if (building.level >= building.upgradeConfig.maxLevel) {
  return Result.failure(UpgradeError.maxLevelReached);
}
```

- [x] **AC4:** Deduct gold, increase level

- [x] **AC5:** Return Result<PlayerEconomy, UpgradeError>

- [x] **AC6:** Unit tests pass

### Implementation Notes

**File:** `trade_factory_masters/lib/domain/usecases/upgrade_building.dart`

**UpgradeError enum:**
- maxLevelReached
- insufficientGold
- buildingInactive (added)
- buildingNotFound (added)

**Tests:** `test/domain/usecases/upgrade_building_test.dart`

**Story Points:** 5 SP
**Status:** ✅ DONE

---

## STORY-01.5: Flame Game Engine - Grid System ✅

### Objective
Zaimplementować 50×50 tile grid z Flame engine i spatial culling.

### User Story
**As a** developer
**I want** 50×50 tile grid rendered with Flame
**So that** players can place buildings on a spatial grid

### Acceptance Criteria

- [x] **AC1:** GridComponent created

- [x] **AC2:** 50×50 tile grid (isometric 64×32px)
```dart
class GridConfig {
  final int gridWidth = 50;
  final int gridHeight = 50;
  final double tileWidth = 64.0;   // Isometric
  final double tileHeight = 32.0;
}
```

- [x] **AC3:** Isometric projection
```dart
Vector2 gridToScreen(int gridX, int gridY) {
  final screenX = (gridX - gridY) * (tileWidth / 2);
  final screenY = (gridX + gridY) * (tileHeight / 2);
  return Vector2(screenX, screenY);
}
```

- [x] **AC4:** Spatial culling implemented
```dart
class GridCullingManager {
  VisibleGridRange calculateVisibleRange(Rect cameraViewport) {
    // Only renders tiles in viewport + padding
  }
}
```

- [x] **AC5:** 60 FPS maintained

- [x] **AC6:** Unit tests pass

### Implementation Notes

**File:** `trade_factory_masters/lib/game/components/grid_component.dart`

**Differences from spec:**
- Isometric view (not orthogonal 32×32)
- Diamond tile shape rendering
- Performance metrics: `getPerformanceMetrics()`

**Tests:** `test/game/components/grid_component_test.dart`

**Story Points:** 5 SP
**Status:** ✅ DONE

---

## STORY-01.6: Flame Game Engine - Dual Zoom Camera ⚠️

### Objective
Zaimplementować dual-zoom camera z gestami.

### User Story
**As a** player
**I want** to switch between Planning Mode (0.75×) and Build Mode (1.5×)
**So that** I can see full factory layout or interact with buildings

### Acceptance Criteria

- [x] **AC1:** GridCamera class with ZoomLevel enum
```dart
enum ZoomLevel {
  closeup(zoom: 1.5, name: 'Close-up'),   // Build Mode
  strategic(zoom: 0.75, name: 'Strategic'); // Planning Mode (spec: 0.5)
}
```

- [x] **AC2:** Double-tap to toggle zoom

- [x] **AC3:** Smooth zoom transition (easeInOutCubic)
```dart
double _easeInOutCubic(double t) {
  return t < 0.5
      ? 4 * t * t * t
      : 1 - math.pow(-2 * t + 2, 3) / 2;
}
```

- [x] **AC4:** Swipe panning with zoom compensation

- [x] **AC5:** Pinch-to-zoom (0.5× - 2.0×)

- [⚠️] **AC6:** Camera animation - **TODO**
```dart
void moveTo(Vector2 position, {bool animate = false}) {
  if (animate) {
    // TODO: Implement smooth camera movement animation
    gameRef.camera.viewfinder.position = position.clone();
  }
  // ...
}
```

### Implementation Notes

**File:** `trade_factory_masters/lib/game/camera/grid_camera.dart`

**Differences from spec:**
- Strategic zoom: 0.75× (not 0.5×)
- Custom ScaleDetector mixin for pinch

**TODO:** Line 302 - smooth moveTo animation

**Tests:** `test/game/camera/grid_camera_test.dart`

**Story Points:** 8 SP
**Status:** ⚠️ TODO animation

---

## STORY-01.7: Presentation Layer - Building Sprite Component ✅

### Objective
Zaimplementować BuildingComponent do renderowania budynków na gridzie.

### User Story
**As a** player
**I want** to see buildings rendered on the grid
**So that** I know where my buildings are placed

### Acceptance Criteria

- [x] **AC1:** BuildingComponent extends appropriate Flame component

- [x] **AC2:** Position at gridPosition × tileSize

- [x] **AC3:** Tap detection

- [x] **AC4:** Visual feedback on tap

- [x] **AC5:** 60 FPS with multiple buildings

- [x] **AC6:** Unit tests pass

### Implementation Notes

**File:** `trade_factory_masters/lib/game/components/building_component.dart`

**Tests:** `test/game/components/building_component_test.dart`

**Story Points:** 3 SP
**Status:** ✅ DONE

---

## STORY-01.8: Integration Test - Full Gameplay Loop ❌

### Objective
Napisać integration test dla pełnego gameplay loop.

### User Story
**As a** QA engineer
**I want** integration test for COLLECT → DECIDE → UPGRADE loop
**So that** I verify core gameplay works end-to-end

### Acceptance Criteria

- [x] **AC1:** Test launches game

- [❌] **AC2:** Test taps building - **BUG #1**
```dart
// ❌ Current code (BROKEN):
await useCase.execute(buildingId: 'building-1'); // Wrong parameter name

// ✅ Should be:
await useCase.execute(building: testBuilding);
```

- [ ] **AC3:** Verify resources collected

- [ ] **AC4:** Verify upgrade works

- [ ] **AC5:** Test executes in <30 seconds

### Implementation Notes

**File:** `integration_test/core_gameplay_loop_test.dart`

**Bug #1 - HIGH:**
- Lines 167, 278, 326, 388
- Parameter name `buildingId` should be `building`
- Test won't compile

**Story Points:** 5 SP
**Status:** ❌ WON'T COMPILE

---

## Known Bugs Summary

| Bug | Location | Severity | Description |
|-----|----------|----------|-------------|
| #1 | integration_test:167,278,326,388 | HIGH | Wrong parameter name |
| #2 | player_economy.dart:52-56 | CRITICAL | addResource returns unchanged |
| #8 | main.dart:325 | MEDIUM | Type cast precedence |

---

## Fix Priority

1. **Bug #2** (CRITICAL) - Core gameplay broken
2. **Bug #1** (HIGH) - Can't run integration tests
3. **Bug #8** (MEDIUM) - Runtime error
4. **TODO Camera** (LOW) - Polish

---

## Dependencies Graph

```
STORY-00.1 (Project Init)
    │
    ▼
STORY-01.1 (Building Entity)
    │
    ▼
STORY-01.2 (PlayerEconomy) ⚠️ BUG #2
    │
    ├──────────────────┐
    ▼                  ▼
STORY-01.3         STORY-01.5
(Collect Resources) (Grid System)
    │                  │
    ▼                  ▼
STORY-01.4         STORY-01.6 ⚠️ TODO
(Upgrade Building)  (Dual Camera)
    │                  │
    └──────────────────┘
              │
              ▼
        STORY-01.7
        (Building Component)
              │
              ▼
        STORY-01.8 ❌ BUG #1
        (Integration Test)
```

---

**Total:** 8 stories, 34 SP
**Implemented:** 6/8 fully working
**Bugs:** 3 (1 critical, 1 high, 1 medium)
**Status:** ⚠️ Needs bug fixes before Epic 2
**Last Updated:** 2025-12-03
