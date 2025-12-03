# Epic 11: Testing & Quality - User Stories

<!-- AI-INDEX: epic, stories, testing, quality, ci-cd, coverage -->

**Epic:** EPIC-11 - Testing & Quality
**Total Stories:** 8
**Total SP:** 20
**Sprint:** 11 (post-MVP)
**Status:** 📋 Ready for Implementation

---

## Story Overview

| Story ID | Title | SP | Priority | Dependencies |
|----------|-------|-----|----------|--------------|
| STORY-11.1 | Unit Test Suite - Domain Layer | 5 | P1 | All domain stories |
| STORY-11.2 | Unit Test Suite - Data Layer | 3 | P1 | STORY-09.3 |
| STORY-11.3 | Widget Test Suite | 5 | P1 | All UI stories |
| STORY-11.4 | Integration Test Suite | 5 | P1 | All feature epics |
| STORY-11.5 | Performance Test Suite | 3 | P1 | STORY-05.3 |
| STORY-11.6 | E2E Test Suite | 5 | P2 | All features |
| STORY-11.7 | CI/CD Pipeline - GitHub Actions | 2 | P1 | STORY-00.3 |
| STORY-11.8 | Manual QA Testing Checklist | 2 | P2 | All features |

---

## STORY-11.1: Unit Test Suite - Domain Layer (90%+ coverage)

### Objective
Zaimplementować kompleksowe unit testy dla domain layer z 90%+ coverage.

### User Story
**As a** developer
**I want** comprehensive domain layer tests
**So that** business logic is bulletproof

### Description
150+ unit testów dla entities i use cases. Test builders dla generowania danych testowych.

### Acceptance Criteria

- [ ] **AC1:** 150+ unit tests for domain layer

- [ ] **AC2:** Coverage: 90%+ (entities, use cases)
```dart
// test/unit/domain/entities/building_test.dart
void main() {
  group('Building', () {
    test('creates with default values', () {
      final building = BuildingBuilder().build();
      expect(building.level, equals(1));
      expect(building.type, equals(BuildingType.mine));
    });

    test('upgrade increases level', () {
      final building = BuildingBuilder().withLevel(1).build();
      final upgraded = building.upgrade();
      expect(upgraded.level, equals(2));
    });

    test('cannot upgrade beyond max level', () {
      final building = BuildingBuilder().withLevel(5).build();
      expect(() => building.upgrade(), throwsA(isA<MaxLevelReachedException>()));
    });
  });
}
```

- [ ] **AC3:** Test builders for test data generation
```dart
// test/helpers/test_builders.dart
class BuildingBuilder {
  String _id = 'building-1';
  BuildingType _type = BuildingType.mine;
  int _level = 1;

  BuildingBuilder withId(String id) => this.._id = id;
  BuildingBuilder withType(BuildingType type) => this.._type = type;
  BuildingBuilder withLevel(int level) => this.._level = level;

  Building build() => Building(id: _id, type: _type, level: _level);
}
```

- [ ] **AC4:** Fast execution: <100ms total runtime

- [ ] **AC5:** Use case tests with mocked repositories
```dart
// test/unit/domain/usecases/collect_resources_usecase_test.dart
void main() {
  group('CollectResourcesUseCase', () {
    late MockGameRepository mockRepo;
    late CollectResourcesUseCase useCase;

    setUp(() {
      mockRepo = MockGameRepository();
      useCase = CollectResourcesUseCase(mockRepo);
    });

    test('collects resources from building', () async {
      final building = BuildingBuilder().withType(BuildingType.mine).build();
      when(mockRepo.getBuilding(any)).thenReturn(building);

      final result = await useCase.execute(building.id);

      expect(result.isSuccess, isTrue);
      expect(result.resources, isNotEmpty);
    });
  });
}
```

### Implementation Notes

**Test Categories:**
- Entities: Building, Resource, PlayerEconomy, Conveyor
- Use Cases: Collect, Upgrade, Place, Market, Offline

**Packages:**
- `flutter_test`
- `mockito: ^5.4.0`
- `build_runner` (for mock generation)

### Definition of Done
- [ ] 150 unit tests pass
- [ ] Coverage report: 90%+ domain layer
- [ ] Test execution <100ms

**Story Points:** 5 SP
**Priority:** P1
**Sprint:** Sprint 8

---

## STORY-11.2: Unit Test Suite - Data Layer (80%+ coverage)

### Objective
Zaimplementować unit testy dla data layer (repositories, datasources) z mockami dla Firestore i Hive.

### User Story
**As a** developer
**I want** data layer tests
**So that** repositories work correctly

### Description
100+ unit testów dla repositories i datasources. Mocked Firestore/Hive dla izolacji testów.

### Acceptance Criteria

- [ ] **AC1:** 100+ unit tests for data layer

- [ ] **AC2:** Coverage: 80%+ (repositories, data sources)

- [ ] **AC3:** Mock Firestore for isolation
```dart
// test/unit/data/datasources/firestore_datasource_test.dart
void main() {
  group('FirestoreDatasource', () {
    late MockFirebaseFirestore mockFirestore;
    late FirestoreDatasource datasource;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      datasource = FirestoreDatasource(mockFirestore);
    });

    test('saves game state', () async {
      final economy = PlayerEconomyBuilder().withGold(500).build();

      await datasource.saveGameState(economy);

      verify(mockFirestore.collection('users').doc(any).set(any)).called(1);
    });
  });
}
```

- [ ] **AC4:** Mock Hive for isolation
```dart
// test/unit/data/datasources/hive_datasource_test.dart
void main() {
  group('HiveDatasource', () {
    late MockBox<GameStateModel> mockBox;
    late HiveDatasource datasource;

    setUp(() {
      mockBox = MockBox<GameStateModel>();
      datasource = HiveDatasource(mockBox);
    });

    test('loads game state from box', () async {
      final model = GameStateModel(gold: 100, tier: 1);
      when(mockBox.get('gameState')).thenReturn(model);

      final result = await datasource.loadGameState();

      expect(result?.gold, equals(100));
    });
  });
}
```

- [ ] **AC5:** Fast execution: <200ms total

### Definition of Done
- [ ] 100 unit tests pass
- [ ] Coverage: 80%+ data layer
- [ ] No flaky tests

**Story Points:** 3 SP
**Priority:** P1
**Sprint:** Sprint 8

---

## STORY-11.3: Widget Test Suite (60%+ coverage)

### Objective
Zaimplementować widget testy dla UI components z 60%+ coverage presentation layer.

### User Story
**As a** developer
**I want** widget tests for UI components
**So that** UI works correctly

### Description
100+ widget testów dla wszystkich screens, buttons, dialogs. Golden tests dla key widgets.

### Acceptance Criteria

- [ ] **AC1:** 100+ widget tests

- [ ] **AC2:** Coverage: 60%+ presentation layer

- [ ] **AC3:** Test all screens
```dart
// test/widget/screens/game_screen_test.dart
void main() {
  group('GameScreen', () {
    testWidgets('displays grid', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameProvider.overrideWith((ref) => MockGameNotifier())],
          child: MaterialApp(home: GameScreen()),
        ),
      );

      expect(find.byType(GridWidget), findsOneWidget);
    });

    testWidgets('shows building menu on tap', (tester) async {
      await tester.pumpWidget(/* ... */);

      await tester.tap(find.byKey(Key('build-button')));
      await tester.pumpAndSettle();

      expect(find.byType(BuildingMenuDialog), findsOneWidget);
    });
  });
}
```

- [ ] **AC4:** Test buttons and dialogs
```dart
// test/widget/widgets/upgrade_button_test.dart
testWidgets('upgrade button triggers upgrade', (tester) async {
  var upgraded = false;
  await tester.pumpWidget(
    MaterialApp(
      home: UpgradeButton(
        onUpgrade: () => upgraded = true,
        cost: 50,
        canAfford: true,
      ),
    ),
  );

  await tester.tap(find.byType(UpgradeButton));

  expect(upgraded, isTrue);
});
```

- [ ] **AC5:** Fast execution: <5s total

### Definition of Done
- [ ] 100 widget tests pass
- [ ] Coverage: 60%+ presentation layer
- [ ] No flaky UI tests

**Story Points:** 5 SP
**Priority:** P1
**Sprint:** Sprint 8

---

## STORY-11.4: Integration Test Suite (50 tests)

### Objective
Zaimplementować integration testy dla kluczowych user flows.

### User Story
**As a** QA engineer
**I want** integration tests for key flows
**So that** end-to-end functionality works

### Description
50 integration testów pokrywających: full gameplay loop, offline production, automation chain, market flow, tier unlock.

### Acceptance Criteria

- [ ] **AC1:** 50 integration tests

- [ ] **AC2:** Cover: Full gameplay loop
```dart
// integration_test/core_gameplay_loop_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete gameplay loop', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Place building
    await tester.tap(find.byKey(Key('grid-cell-0-0')));
    await tester.tap(find.text('Mine'));
    await tester.pumpAndSettle();

    // Wait for production
    await tester.pump(Duration(seconds: 5));

    // Collect resources
    await tester.tap(find.byType(BuildingWidget));
    await tester.pumpAndSettle();

    // Verify resources collected
    expect(find.textContaining('Wood: 10'), findsOneWidget);
  });
}
```

- [ ] **AC3:** Cover: Offline production flow
```dart
// integration_test/offline_production_test.dart
testWidgets('offline production calculated correctly', (tester) async {
  // Setup: place buildings, close app
  // Simulate time passage
  // Reopen app
  // Verify offline production modal
  // Collect with ad boost
  // Verify doubled resources
});
```

- [ ] **AC4:** Cover: Automation chain
```dart
// integration_test/automation_chain_test.dart
testWidgets('conveyor transports resources', (tester) async {
  // Place mine
  // Place storage
  // Connect with conveyor
  // Verify resources flow
});
```

- [ ] **AC5:** Execution: <30s total

### Definition of Done
- [ ] 50 integration tests pass
- [ ] Key flows validated
- [ ] Tests stable on CI

**Story Points:** 5 SP
**Priority:** P1
**Sprint:** Sprint 8

---

## STORY-11.5: Performance Test Suite (5 tests)

### Objective
Zaimplementować automated performance testy dla krytycznych metryk.

### User Story
**As a** QA engineer
**I want** automated performance tests
**So that** 60 FPS is maintained

### Description
5 performance testów: 60 FPS z 50 conveyors, offline production <50ms, cold start <3s, memory <150 MB.

### Acceptance Criteria

- [ ] **AC1:** Test: 60 FPS with 50 conveyors
```dart
testWidgets('maintains 60 FPS with 50 conveyors', (tester) async {
  final timings = <FrameTiming>[];
  WidgetsBinding.instance.addTimingsCallback((list) {
    timings.addAll(list);
  });

  await tester.pumpWidget(GameApp());

  // Place 50 conveyors
  for (var i = 0; i < 50; i++) {
    await placeConveyor(tester);
  }

  await tester.pump(Duration(seconds: 5));

  final avgFrameTime = timings.map((t) => t.totalSpan.inMicroseconds).average;
  expect(avgFrameTime, lessThan(16670)); // 16.67ms = 60 FPS
});
```

- [ ] **AC2:** Test: <50ms offline production calculation
```dart
test('offline production calculates in <50ms', () {
  final economy = createLargeEconomy(); // 50 buildings
  final stopwatch = Stopwatch()..start();

  calculateOfflineProduction(economy, Duration(hours: 24));

  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(50));
});
```

- [ ] **AC3:** Test: <3s cold start load

- [ ] **AC4:** Test: <150 MB memory usage

- [ ] **AC5:** Performance benchmarks documented

### Definition of Done
- [ ] 5 performance tests pass
- [ ] Benchmarks met on CI
- [ ] No performance regressions

**Story Points:** 3 SP
**Priority:** P1
**Sprint:** Sprint 8

---

## STORY-11.6: E2E Test Suite (10 tests)

### Objective
Zaimplementować E2E testy na real devices przez Firebase Test Lab.

### User Story
**As a** QA engineer
**I want** end-to-end tests on real devices
**So that** critical paths work

### Description
10 E2E testów na Firebase Test Lab pokrywających FTUE, full gameplay, IAP flow.

### Acceptance Criteria

- [ ] **AC1:** 10 E2E tests configured for Firebase Test Lab

- [ ] **AC2:** Cover: FTUE flow
```dart
testWidgets('FTUE completes successfully', (tester) async {
  await tester.pumpWidget(MyApp());

  // Welcome screen
  expect(find.text('Welcome to Trade Factory Masters'), findsOneWidget);
  await tester.tap(find.text('Start Building'));

  // Tutorial steps
  await completeTutorialSteps(tester);

  // Verify tutorial complete
  expect(find.text('Tutorial Complete!'), findsOneWidget);
});
```

- [ ] **AC3:** Cover: Full gameplay (Tier 1 → Tier 2)

- [ ] **AC4:** Cover: IAP flow (mock)

- [ ] **AC5:** Execution: <5min total on Test Lab

### Implementation Notes

**Firebase Test Lab Config:**
```yaml
# .github/workflows/e2e.yml
- name: Run E2E tests on Firebase Test Lab
  run: |
    gcloud firebase test android run \
      --type instrumentation \
      --app build/app/outputs/apk/debug/app-debug.apk \
      --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
      --device model=Pixel6,version=33
```

### Definition of Done
- [ ] 10 E2E tests pass on Android/iOS
- [ ] Test Lab integration working
- [ ] Results visible in Firebase console

**Story Points:** 5 SP
**Priority:** P2
**Sprint:** Sprint 8

---

## STORY-11.7: CI/CD Pipeline - GitHub Actions

### Objective
Skonfigurować automated CI/CD pipeline z quality gates.

### User Story
**As a** developer
**I want** automated CI/CD pipeline
**So that** quality gates are enforced

### Description
GitHub Actions workflow: analyze, test, integration test, coverage report, build APK/IPA.

### Acceptance Criteria

- [ ] **AC1:** GitHub Actions workflow configured
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
      - run: flutter analyze

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3

  build:
    needs: [analyze, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
```

- [ ] **AC2:** Run on: push to main/develop, pull requests

- [ ] **AC3:** Steps: flutter analyze, unit tests, widget tests, integration tests

- [ ] **AC4:** Coverage report uploaded to Codecov

- [ ] **AC5:** Build APK on success

### Definition of Done
- [ ] CI pipeline passes on all commits
- [ ] Coverage badge: 80%+
- [ ] APK artifact uploaded

**Story Points:** 2 SP (verification of existing STORY-00.3)
**Priority:** P1
**Sprint:** Sprint 1

---

## STORY-11.8: Manual QA Testing Checklist

### Objective
Utworzyć manual testing checklist dla edge cases nie pokrytych przez automated testy.

### User Story
**As a** QA engineer
**I want** manual testing checklist
**So that** I validate edge cases

### Description
50-item QA checklist dla FTUE, gameplay, IAP, offline, performance. Bug tracking via GitHub Issues.

### Acceptance Criteria

- [ ] **AC1:** 50-item QA checklist created

- [ ] **AC2:** Cover: FTUE
  - [ ] Install fresh → tutorial starts
  - [ ] Tutorial can be skipped at any step
  - [ ] Tutorial completes in 3-5 minutes
  - [ ] First building auto-placed

- [ ] **AC3:** Cover: Gameplay
  - [ ] Place 10 buildings → Tier 1 limit enforced
  - [ ] Upgrade to level 5 → max level enforced
  - [ ] Conveyors path correctly around obstacles
  - [ ] Market prices update correctly

- [ ] **AC4:** Cover: IAP & Offline
  - [ ] Purchase IAP → receipt validated
  - [ ] $10 cap enforced
  - [ ] 24-hour offline → production capped
  - [ ] Ad boost doubles production

- [ ] **AC5:** Cover: Performance
  - [ ] 60 FPS maintained during gameplay
  - [ ] No memory leaks after 1 hour session
  - [ ] Battery drain <10%/hour

### QA Checklist Template

```markdown
## FTUE
- [ ] Fresh install shows welcome screen
- [ ] "Start Building" begins tutorial
- [ ] First building tooltip appears
- [ ] Can skip tutorial at any step
- [ ] Tutorial completes in 3-5 minutes

## Core Gameplay
- [ ] Place building on empty cell
- [ ] Cannot place on occupied cell
- [ ] Collect resources by tapping
- [ ] Upgrade building increases production
- [ ] Max level (5) enforced

## Market
- [ ] Can buy resources
- [ ] Can sell resources
- [ ] Prices reflect supply/demand
- [ ] Insufficient gold prevented

## Conveyors
- [ ] Create conveyor between buildings
- [ ] Resources flow automatically
- [ ] Splitters divide resources
- [ ] Filters work correctly

## Offline
- [ ] Production continues offline
- [ ] Welcome back modal shows
- [ ] Ad boost option works
- [ ] 24-hour cap enforced

## IAP
- [ ] Products displayed correctly
- [ ] Purchase completes
- [ ] $10 cap shown
- [ ] Restore purchases works

## Performance
- [ ] Smooth 60 FPS
- [ ] No lag with 50 conveyors
- [ ] App doesn't crash
- [ ] Memory stable over time
```

### Definition of Done
- [ ] QA checklist completed by 2 testers
- [ ] All P0/P1 bugs fixed before launch
- [ ] Sign-off from QA lead

**Story Points:** 2 SP (checklist creation)
**Priority:** P2
**Sprint:** Sprint 8

---

## Dependencies Graph

```
All Feature Epics (EPIC-01 to EPIC-10)
    │
    ├────────────────┬────────────────┬────────────────┐
    ▼                ▼                ▼                ▼
STORY-11.1       STORY-11.2       STORY-11.3       STORY-11.4
(Domain Tests)   (Data Tests)     (Widget Tests)   (Integration)
    │                │                │                │
    └────────────────┴────────────────┴────────────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │                     │
              STORY-11.5            STORY-11.6
              (Performance)         (E2E Tests)
                    │                     │
                    └──────────┬──────────┘
                               ▼
                         STORY-11.7
                         (CI/CD Pipeline)
                               │
                               ▼
                         STORY-11.8
                         (Manual QA)
```

---

**Total:** 8 stories, 20 SP
**Status:** 📋 Ready for Implementation
**Last Updated:** 2025-12-03
