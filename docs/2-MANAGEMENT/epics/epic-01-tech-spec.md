# Epic 1: Core Gameplay Loop - Technical Specification

<!-- AI-INDEX: epic, tech-spec, core-gameplay, flame, grid, camera -->

**Epic:** EPIC-01 - Core Gameplay Loop
**Total SP:** 34
**Duration:** 2 weeks (Sprint 1)
**Status:** ✅ Implemented (with bugs)
**Date:** 2025-12-03
**Priority:** P0 (Critical Path)

---

## Overview

EPIC-01 implementuje podstawowy gameplay loop: COLLECT → DECIDE → UPGRADE na siatce 50×50, z systemem kamery dual-zoom i Flame game engine.

**Design Philosophy:** "Simple core loop, deep strategy" - prosta mechanika, głęboka strategia.

**Kluczowe cele:**
- **30-second loop** - tap building → collect resources → upgrade
- **Dual-zoom camera** - Planning (0.5×) ↔ Build (1.5×) modes
- **60 FPS** - performance na Snapdragon 660
- **Clean Architecture** - domain layer niezależny od frameworka

---

## Implementation Status

### ✅ Completed Stories

| Story | Title | SP | Files | Status |
|-------|-------|-----|-------|--------|
| 01.1 | Building Entity | 3 | `domain/entities/building.dart` | ✅ Done |
| 01.2 | Resource & PlayerEconomy | 3 | `domain/entities/player_economy.dart`, `resource.dart` | ⚠️ Bug #2 |
| 01.3 | Collect Resources UseCase | 5 | `domain/usecases/collect_resources.dart` | ✅ Done |
| 01.4 | Upgrade Building UseCase | 5 | `domain/usecases/upgrade_building.dart` | ✅ Done |
| 01.5 | Grid System | 5 | `game/components/grid_component.dart` | ✅ Done |
| 01.6 | Dual Zoom Camera | 8 | `game/camera/grid_camera.dart` | ⚠️ TODO animation |
| 01.7 | Building Component | 3 | `game/components/building_component.dart` | ✅ Done |
| 01.8 | Integration Test | 5 | `integration_test/core_gameplay_loop_test.dart` | ❌ Bug #1 |

### Known Issues (Must Fix)

**Bug #1: Integration Test Won't Compile**
- Location: `integration_test/core_gameplay_loop_test.dart` (lines 167, 278, 326, 388)
- Issue: Using parameter name `buildingId` instead of `building`
- Impact: Cannot run integration tests
- Severity: HIGH

**Bug #2: Resource Inventory Logic Broken**
- Location: `lib/domain/entities/player_economy.dart` (lines 52-56)
- Issue: `addResource()` returns unchanged economy if resource doesn't exist
- Expected: Should create new Resource if not in inventory
- Impact: Resources won't be added to inventory
- Severity: CRITICAL

**Bug #8: Type Cast Syntax Error**
- Location: `lib/main.dart` (line 325)
- Issue: `(metrics['cullRate'] as double * 100)` - incorrect precedence
- Fix: `((metrics['cullRate'] as double) * 100)`
- Severity: MEDIUM

**TODO: Camera Animation Incomplete**
- Location: `lib/game/camera/grid_camera.dart` (line 302)
- Issue: `moveTo()` has TODO for smooth animation
- Impact: Camera snaps instead of animating
- Severity: LOW

---

## System Architecture

### Implemented Files

```
trade_factory_masters/lib/
├── domain/
│   ├── core/
│   │   └── result.dart              # Result<T,E> type
│   ├── entities/
│   │   ├── building.dart            # ✅ Building, ProductionConfig, UpgradeConfig
│   │   ├── building.g.dart          # Hive adapters (generated)
│   │   ├── player_economy.dart      # ⚠️ PlayerEconomy (Bug #2)
│   │   ├── player_economy.g.dart    # Hive adapters (generated)
│   │   ├── resource.dart            # ✅ Resource entity
│   │   └── resource.g.dart          # Hive adapters (generated)
│   └── usecases/
│       ├── collect_resources.dart   # ✅ CollectResourcesUseCase
│       └── upgrade_building.dart    # ✅ UpgradeBuildingUseCase
├── game/
│   ├── camera/
│   │   └── grid_camera.dart         # ⚠️ GridCamera (TODO animation)
│   └── components/
│       ├── building_component.dart  # ✅ BuildingComponent
│       └── grid_component.dart      # ✅ GridComponent
└── main.dart                        # ⚠️ Bug #8
```

### Test Files

```
trade_factory_masters/test/
├── domain/
│   ├── entities/
│   │   ├── building_test.dart       # ✅
│   │   ├── player_economy_test.dart # ✅
│   │   └── resource_test.dart       # ✅
│   └── usecases/
│       ├── collect_resources_test.dart  # ✅
│       └── upgrade_building_test.dart   # ✅
├── game/
│   ├── camera/
│   │   └── grid_camera_test.dart    # ✅
│   └── components/
│       ├── building_component_test.dart # ✅
│       └── grid_component_test.dart     # ✅
└── hive_storage_test.dart           # ✅

integration_test/
└── core_gameplay_loop_test.dart     # ❌ Won't compile (Bug #1)
```

---

## Domain Layer Details

### Building Entity

```dart
// lib/domain/entities/building.dart
class Building extends Equatable {
  final String id;
  final BuildingType type;     // collector, processor, storage, conveyor, market
  final int level;             // 1-10
  final GridPosition gridPosition;
  final ProductionConfig production;
  final UpgradeConfig upgradeConfig;
  final DateTime lastCollected;
  final bool isActive;

  // Production rate formula: baseRate × [1 + (level-1) × 0.2]
  double get productionRate =>
      production.baseRate * (1 + (level - 1) * 0.2);

  // Upgrade cost formula: baseCost + (level-1) × costIncrement
  int calculateUpgradeCost() {
    return upgradeConfig.baseCost +
        (level - 1) * upgradeConfig.costIncrement;
  }

  bool canUpgrade(int playerGold) {
    if (!isActive) return false;
    if (level >= upgradeConfig.maxLevel) return false;
    return playerGold >= calculateUpgradeCost();
  }
}
```

### PlayerEconomy Entity (⚠️ Bug)

```dart
// lib/domain/entities/player_economy.dart
class PlayerEconomy extends Equatable {
  final int gold;                       // Default: 1000
  final Map<String, Resource> inventory;
  final List<Building> buildings;
  final int tier;                       // 1, 2, 3
  final DateTime lastSeen;

  // ⚠️ BUG: Returns unchanged if resource not in inventory
  PlayerEconomy addResource(String resourceId, int amountToAdd) {
    if (!inventory.containsKey(resourceId)) {
      return this;  // ❌ Should create new Resource instead
    }
    // ... rest of implementation
  }
}
```

---

## Game Engine Layer Details

### Grid System

```dart
// lib/game/components/grid_component.dart
class GridConfig {
  final int gridWidth = 50;
  final int gridHeight = 50;
  final double tileWidth = 64.0;    // Isometric
  final double tileHeight = 32.0;

  // Isometric projection: gridToScreen(), screenToGrid()
}

class GridComponent extends Component {
  // ✅ Spatial culling implemented
  // ✅ Performance metrics tracking
  // ✅ Isometric diamond rendering
}
```

### Dual Zoom Camera

```dart
// lib/game/camera/grid_camera.dart
enum ZoomLevel {
  closeup(zoom: 1.5),    // Build Mode
  strategic(zoom: 0.75); // Planning Mode
}

class GridCamera extends Component {
  // ✅ Double-tap toggle
  // ✅ Swipe panning
  // ✅ Pinch-to-zoom (0.5× - 2.0×)
  // ✅ Smooth zoom animation (easeInOutCubic)
  // ⚠️ TODO: moveTo() smooth animation
}
```

---

## Differences from Original Spec

| Aspect | Planned | Implemented | Notes |
|--------|---------|-------------|-------|
| Grid size | 50×50, 32px tiles | 50×50, 64×32px isometric | Better visual, isometric projection |
| Camera zoom | 0.5× / 1.5× | 0.75× / 1.5× | Strategic mode slightly more zoomed |
| BuildingType enum | lumbermill, mine, etc. | collector, processor, storage, conveyor, market | Generic types instead of specific |
| Production rate | per minute | per hour | Different time unit |
| Storage capacity | in ProductionConfig | Calculated: baseRate × 10 | Dynamic calculation |

---

## Performance Requirements

| Metric | Target | Current Status |
|--------|--------|----------------|
| Frame rate | 60 FPS | ✅ Met (with culling) |
| Frame time | <16.67ms | ✅ Met |
| Grid rendering | Only visible tiles | ✅ Spatial culling works |
| Unit test time | <100ms | ✅ Met |

---

## Dependencies

**Depends On:**
- ✅ EPIC-00 (Project Setup) - completed

**Blocks:**
- → EPIC-02 (Economy)
- → EPIC-03 (Automation)
- → EPIC-05 (Mobile UX)
- → EPIC-07 (Tutorial)

---

## Fix Priority

1. **CRITICAL:** Bug #2 (addResource logic) - blocks core gameplay
2. **HIGH:** Bug #1 (integration test) - blocks testing
3. **MEDIUM:** Bug #8 (type cast) - causes runtime error
4. **LOW:** TODO camera animation - polish feature

---

**Status:** ✅ Implemented with bugs
**Last Updated:** 2025-12-03
**Version:** 1.0
