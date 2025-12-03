# Epic 11: Testing & Quality - Technical Specification

<!-- AI-INDEX: epic, tech-spec, testing, quality, ci-cd, coverage -->

**Epic:** EPIC-11 - Testing & Quality
**Total SP:** 20
**Duration:** 1-2 weeks (Sprint 8)
**Status:** 📋 Ready for Implementation
**Date:** 2025-12-03
**Priority:** P1 (High - quality gate)

---

## Overview

EPIC-11 zapewnia jakość produktu poprzez kompleksowe testy: unit (domain 90%+, data 80%+), widget (60%+), integration (50 testów), E2E (10 testów), performance (5 testów). CI/CD pipeline automatyzuje quality gates.

**Design Philosophy:** "Test pyramid" - więcej unit testów, mniej E2E.

**Kluczowe cele:**
- **300+ unit tests** - domain + data layers
- **100+ widget tests** - presentation layer
- **50 integration tests** - key user flows
- **10 E2E tests** - critical paths on real devices
- **80%+ overall coverage**

---

## Objectives and Scope

### In Scope

**Unit Test Suite:**
- ✅ Domain layer: 150+ tests, 90%+ coverage
- ✅ Data layer: 100+ tests, 80%+ coverage
- ✅ Test builders for data generation
- ✅ Fast execution (<100ms domain, <200ms data)

**Widget Test Suite:**
- ✅ 100+ widget tests
- ✅ 60%+ presentation layer coverage
- ✅ All screens, buttons, dialogs tested

**Integration Test Suite:**
- ✅ 50 integration tests
- ✅ Full gameplay loop
- ✅ Offline production flow
- ✅ Automation chain

**E2E Test Suite:**
- ✅ 10 E2E tests (Firebase Test Lab)
- ✅ FTUE, full gameplay, IAP flow

**Performance Tests:**
- ✅ 60 FPS with 50 conveyors
- ✅ <50ms offline production
- ✅ <3s cold start
- ✅ <150 MB memory

**CI/CD Pipeline:**
- ✅ GitHub Actions
- ✅ Automated quality gates
- ✅ Coverage reporting (Codecov)

### Out of Scope

- ❌ Visual regression testing
- ❌ Load/stress testing
- ❌ Security penetration testing
- ❌ Accessibility automated testing (manual only)

---

## Test Architecture

### Directory Structure
```
test/
├── unit/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── building_test.dart
│   │   │   ├── resource_test.dart
│   │   │   └── player_economy_test.dart
│   │   └── usecases/
│   │       ├── collect_resources_usecase_test.dart
│   │       ├── upgrade_building_usecase_test.dart
│   │       └── ...
│   └── data/
│       ├── repositories/
│       │   └── game_repository_impl_test.dart
│       └── datasources/
│           ├── hive_datasource_test.dart
│           └── firestore_datasource_test.dart
├── widget/
│   ├── screens/
│   │   ├── game_screen_test.dart
│   │   ├── market_screen_test.dart
│   │   └── settings_screen_test.dart
│   └── widgets/
│       ├── building_widget_test.dart
│       ├── resource_bar_test.dart
│       └── ...
└── helpers/
    ├── test_builders.dart
    ├── mock_providers.dart
    └── test_fixtures.dart

integration_test/
├── core_gameplay_loop_test.dart
├── offline_production_test.dart
├── automation_chain_test.dart
├── market_flow_test.dart
└── tier_unlock_test.dart
```

---

## Test Coverage Targets

| Layer | Target Coverage | Test Count |
|-------|-----------------|------------|
| Domain (entities) | 95%+ | 80 tests |
| Domain (use cases) | 90%+ | 70 tests |
| Data (repositories) | 80%+ | 60 tests |
| Data (datasources) | 80%+ | 40 tests |
| Presentation (widgets) | 60%+ | 100 tests |
| Integration | N/A | 50 tests |
| E2E | N/A | 10 tests |
| Performance | N/A | 5 tests |
| **Total** | **80%+** | **415+ tests** |

---

## Test Builders Pattern

```dart
// test/helpers/test_builders.dart
class BuildingBuilder {
  String _id = 'building-1';
  BuildingType _type = BuildingType.mine;
  int _level = 1;
  GridPosition _position = GridPosition(0, 0);

  BuildingBuilder withId(String id) => this.._id = id;
  BuildingBuilder withType(BuildingType type) => this.._type = type;
  BuildingBuilder withLevel(int level) => this.._level = level;
  BuildingBuilder atPosition(int x, int y) => this.._position = GridPosition(x, y);

  Building build() => Building(
    id: _id,
    type: _type,
    level: _level,
    position: _position,
  );
}

class PlayerEconomyBuilder {
  int _gold = 100;
  int _tier = 1;
  List<Building> _buildings = [];
  Map<String, Resource> _inventory = {};

  PlayerEconomyBuilder withGold(int gold) => this.._gold = gold;
  PlayerEconomyBuilder withTier(int tier) => this.._tier = tier;
  PlayerEconomyBuilder withBuildings(List<Building> buildings) => this.._buildings = buildings;
  PlayerEconomyBuilder withInventory(Map<String, Resource> inventory) => this.._inventory = inventory;

  PlayerEconomy build() => PlayerEconomy(
    gold: _gold,
    tier: _tier,
    buildings: _buildings,
    inventory: _inventory,
  );
}
```

---

## CI/CD Pipeline

### GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter analyze

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  integration_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter test integration_test/

  build:
    needs: [analyze, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

---

## Performance Test Specs

| Test | Target | Method |
|------|--------|--------|
| 60 FPS with 50 conveyors | 16.67ms frame time | `FrameTimingRecorder` |
| Offline production calc | <50ms | `Stopwatch` |
| Cold start | <3s | App launch to first frame |
| Memory usage | <150 MB | `dart:developer` profiler |
| Hive load time | <50ms | `Stopwatch` |

### Performance Test Example

```dart
// integration_test/performance_test.dart
testWidgets('maintains 60 FPS with 50 conveyors', (tester) async {
  final timings = <FrameTiming>[];
  WidgetsBinding.instance.addTimingsCallback((list) {
    timings.addAll(list);
  });

  await tester.pumpWidget(GameApp());

  // Place 50 conveyors
  for (var i = 0; i < 50; i++) {
    await placeConveyor(tester, from: Point(i, 0), to: Point(i, 5));
  }

  // Run for 5 seconds
  await tester.pump(Duration(seconds: 5));

  // Assert 60 FPS (16.67ms per frame)
  final avgFrameTime = timings.map((t) => t.totalSpan.inMicroseconds).average;
  expect(avgFrameTime, lessThan(16670)); // 16.67ms
});
```

---

## QA Checklist Categories

### FTUE (First-Time User Experience)
- [ ] Fresh install → tutorial starts
- [ ] Tutorial can be skipped
- [ ] Tutorial completes in 3-5 minutes
- [ ] First building auto-placed

### Gameplay
- [ ] Place 10 buildings → limit enforced
- [ ] Upgrade to level 5 → max level enforced
- [ ] Conveyors transport resources
- [ ] Market buy/sell works

### Offline Production
- [ ] 24-hour offline → production capped correctly
- [ ] Ad boost doubles production
- [ ] Welcome back modal shows correctly

### IAP
- [ ] Purchase IAP → receipt validated
- [ ] $10 cap enforced
- [ ] Restore purchases works

### Performance
- [ ] 60 FPS maintained during gameplay
- [ ] No memory leaks after 1 hour
- [ ] Battery drain <10%/hour

---

## Dependencies

**Depends On:**
- All feature epics (EPIC-01 through EPIC-10)

**Blocks:**
- Release (MVP launch)

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Unit test count | 300+ |
| Widget test count | 100+ |
| Integration test count | 50 |
| E2E test count | 10 |
| Overall coverage | 80%+ |
| CI pipeline pass rate | 99%+ |
| P0/P1 bugs at launch | 0 |

---

**Status:** 📋 Ready for Implementation
**Last Updated:** 2025-12-03
**Version:** 1.0
