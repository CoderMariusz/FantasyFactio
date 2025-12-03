# FILE-MAP - FantasyFactio Code Index

<!-- AI-INDEX: files, structure, codebase, modules, organization -->

Last Updated: 2025-12-03

---

## Quick Navigation

### By Purpose

| Purpose | Location | Files |
|---------|----------|-------|
| **Entry Point** | lib/ | `main.dart` |
| **Configuration** | lib/config/ | `game_config.dart` |
| **Game Logic** | lib/domain/ | entities/, usecases/, core/ |
| **Game Rendering** | lib/game/ | camera/, components/ |
| **Tests** | test/, integration_test/ | `*_test.dart` files |

---

## lib/ - Application Code

### Core Application Entry Point

| File | Purpose | Status | LOC |
|------|---------|--------|-----|
| `main.dart` | App initialization, Firebase setup, theme | ✅ Complete | 400+ |

### lib/config/ - Game Configuration

| File | Purpose | Classes | Status |
|------|---------|---------|--------|
| `game_config.dart` | Centralized game constants | GridConstants, CameraConstants, EconomyConstants, BuildingConstants, DisplayConstants | ✅ Complete |

### lib/domain/ - Business Logic (Framework-Independent)

#### Core Types

| File | Description | Exports | Status |
|------|-------------|---------|--------|
| `core/either.dart` | Either<Left, Right> type for error handling | Either, Left, Right | ✅ Complete |
| `core/result.dart` | Result<Success, Failure> wrapper | Result | ✅ Complete |

#### Entities

| File | Class | Purpose | Status | Tests |
|------|-------|---------|--------|-------|
| `entities/building.dart` | Building | Defines building structure, production, upgrade config | ✅ Complete | ✅ Yes |
| `entities/resource.dart` | Resource | Game resource (wood, iron, etc) with capacity | ✅ Complete | ✅ Yes |
| `entities/player_economy.dart` | PlayerEconomy | Player's game state (gold, buildings, inventory) | ✅ Complete | ✅ Yes |

#### Use Cases

| File | Class | Purpose | Input | Output | Status |
|-------|-------|---------|-------|--------|--------|
| `usecases/collect_resources_usecase.dart` | CollectResourcesUseCase | Collect resources from building | PlayerEconomy, Building | Result<PlayerEconomy, CollectError> | ✅ Complete |
| `usecases/upgrade_building_usecase.dart` | UpgradeBuildingUseCase | Upgrade building (costs gold) | PlayerEconomy, Building | Result<PlayerEconomy, UpgradeError> | ✅ Complete |

### lib/game/ - Flame Game Engine Layer

#### Camera System

| File | Class | Purpose | Status |
|------|-------|---------|--------|
| `camera/grid_camera.dart` | GridCamera | Isometric camera with zoom modes, smooth animation | ✅ Complete |
| `camera/grid_camera_config.dart` | GridCameraConfig | Camera configuration parameters | ✅ Complete |

#### Game Components

| File | Class | Purpose | Status | Renders |
|-------|-------|---------|--------|---------|
| `components/grid_component.dart` | GridComponent | 50×50 isometric grid renderer | ✅ Complete | Grid tiles, debug info |
| `components/building_component.dart` | BuildingComponent | Building sprite and interaction detection | ✅ Complete | Building sprites with glow |

**Features:**
- Grid culling (spatial optimization)
- Isometric coordinate conversion
- Touch detection for tap interactions

### lib/data/ - Data Persistence (If Exists)

**Status:** Not yet reviewed in detail. Expected to contain:
- `models/` - JSON-serializable data classes
- `repositories/` - Hive and Firebase implementations
- `datasources/` - Local and remote data sources

---

## test/ - Unit Tests

### Unit Test Files

| File | Tests | Coverage | Status |
|------|-------|----------|--------|
| `domain/entities/building_test.dart` | Building entity | Medium | ✅ Complete |
| `domain/entities/resource_test.dart` | Resource entity | Medium | ✅ Complete |
| `domain/entities/player_economy_test.dart` | PlayerEconomy | High | ✅ Complete |
| `domain/usecases/collect_resources_test.dart` | CollectResourcesUseCase | High (~40 tests) | ✅ Complete |
| `domain/usecases/upgrade_building_test.dart` | UpgradeBuildingUseCase | High (~30 tests) | ✅ Complete |
| `game/camera/grid_camera_test.dart` | GridCamera | Medium | ✅ Complete |
| `game/components/building_component_test.dart` | BuildingComponent | Medium | ✅ Complete |
| `game/components/grid_component_test.dart` | GridComponent | Medium | ✅ Complete |
| `hive_storage_test.dart` | Hive adapter registration | Low | ✅ Basic |
| `widget_test.dart` | Generic Flutter test | Low | ✅ Placeholder |

**Summary:**
- ~70-80 unit tests estimated
- Good coverage for domain layer
- Missing presentation layer tests

---

## integration_test/ - Integration Tests

| File | Tests | Status |
|------|-------|--------|
| `core_gameplay_loop_test.dart` | Core gameplay COLLECT→UPGRADE flow | ✅ Complete |

---

## pubspec.yaml - Dependencies

| Dependency | Version | Purpose | Status |
|-----------|---------|---------|--------|
| flutter | 3.16+ | UI framework | ✅ |
| flame | 1.33.0 | 2D game engine | ✅ |
| riverpod | 3.0+ | State management | ✅ |
| firebase_core | latest | Firebase backend | ✅ |
| firebase_auth | latest | Auth service | ✅ |
| firebase_firestore | latest | Cloud database | ✅ |
| firebase_analytics | latest | Event tracking | ✅ |
| hive | latest | Local storage | ✅ |
| hive_flutter | latest | Hive UI | ✅ |

---

## Key Statistics

| Metric | Value |
|--------|-------|
| **Total Files in lib/** | ~21 files |
| **Config Layer Files** | 1 file |
| **Domain Layer Files** | 9 files |
| **Game Layer Files** | 6 files |
| **Test Files** | ~15 files |
| **Total Lines of Code** | ~3,600 (estimated) |
| **Total Test Lines** | ~1,500 (estimated) |
| **Code Health** | ✅ Production Ready |

---

## File Organization Rules

### Adding New Files

When adding new code, follow this pattern:

1. **Domain logic** → `lib/domain/{layer}/{name}.dart`
   - Layer: `core/`, `entities/`, `usecases/`, `repositories/`
   - Example: `lib/domain/usecases/build_conveyor_usecase.dart`

2. **Game components** → `lib/game/components/{name}_component.dart`
   - Example: `lib/game/components/conveyor_component.dart`

3. **Data/persistence** → `lib/data/{layer}/{name}.dart`
   - Layer: `models/`, `datasources/`, `repositories/`

4. **Tests** → Mirror lib structure in `test/`
   - Unit test: `test/domain/usecases/build_conveyor_test.dart`
   - Integration test: `integration_test/conveyor_flow_test.dart`

### File Naming

- **Dart files:** snake_case.dart
  - UseCase: `collect_resources_usecase.dart`
  - Entity: `building.dart`
  - Component: `building_component.dart`

- **Classes:** PascalCase
  - `CollectResourcesUseCase`
  - `BuildingComponent`
  - `GridCamera`

- **Functions/methods:** camelCase
  - `collectResources()`
  - `calculateProduction()`

---

## How to Update This File

When you add/modify files:

1. Add new row to appropriate table
2. Update **Key Statistics** at bottom
3. Include file status (✅ Complete, ⏳ In Progress, ❌ Broken)
4. Include test status if applicable
5. Note any known issues or TODOs
6. Update "Last Updated" date

**This file is AI-optimized to reduce search time. Keep it accurate!**
