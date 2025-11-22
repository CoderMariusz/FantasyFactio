# Trade Factory Masters - Test Design Document

**Author:** Claude (BMAD Test Design Agent)
**Date:** 2025-11-17
**Version:** 1.0
**Status:** Draft
**Based on:** PRD v1.0, Architecture v1.0

---

## Executive Summary

This Test Design document defines the **testing strategy** for Trade Factory Masters to ensure:
- **Quality:** 60 FPS on budget Android, <1% crash rate
- **Reliability:** Core gameplay loop works correctly (COLLECT → DECIDE → UPGRADE)
- **Maintainability:** 80%+ test coverage enables safe refactoring
- **Performance:** Automated FPS validation (no manual testing for performance)

**Test Strategy Philosophy:** "Test the behavior, not the implementation"
- Focus on user-facing functionality (can user collect resources?)
- NOT testing implementation details (internal state structure)
- Tests should survive refactoring (change code, tests still pass)

**Coverage Targets:**
- **Domain Layer:** 90%+ (business logic must be bulletproof)
- **Data Layer:** 80%+ (repository implementations)
- **Presentation Layer:** 60%+ (UI logic, not widget trees)
- **Overall:** 80%+ (industry best practice)

---

## Table of Contents

1. [Test Strategy Overview](#1-test-strategy-overview)
2. [Test Pyramid](#2-test-pyramid)
3. [Unit Testing](#3-unit-testing)
4. [Widget Testing](#4-widget-testing)
5. [Integration Testing](#5-integration-testing)
6. [Performance Testing](#6-performance-testing)
7. [Accessibility Testing](#7-accessibility-testing)
8. [Device Testing Matrix](#8-device-testing-matrix)
9. [CI/CD Integration](#9-cicd-integration)
10. [Test Coverage Monitoring](#10-test-coverage-monitoring)
11. [Test Tools & Frameworks](#11-test-tools--frameworks)
12. [Example Test Suites](#12-example-test-suites)

---

## 1. Test Strategy Overview

### 1.1 Testing Principles

**1. Test Behavior, Not Implementation:**
```dart
// ❌ BAD: Testing implementation details
test('should update _internalState variable', () {
  expect(useCase._internalState, equals(newState));
});

// ✅ GOOD: Testing behavior
test('should add resources to inventory when collecting', () {
  final result = useCase.collectResources(building);
  expect(result.inventory['wood'].amount, greaterThan(0));
});
```

**2. Arrange-Act-Assert Pattern:**
```dart
test('upgrade building increases level', () {
  // Arrange: Setup initial state
  final building = Building(level: 1);
  final economy = PlayerEconomy(gold: 200);

  // Act: Execute the behavior
  final result = useCase.upgradeBuilding(economy, building);

  // Assert: Verify outcome
  expect(result.buildings.first.level, equals(2));
  expect(result.gold, lessThan(200)); // Cost deducted
});
```

**3. Test Independence:**
- Each test should run in isolation (no shared state)
- Tests can run in any order
- Parallel execution safe

**4. Fast Execution:**
- Unit tests: <100ms total runtime for 300 tests
- Widget tests: <5s total runtime for 100 tests
- Integration tests: <30s total runtime for 10 tests

### 1.2 What to Test (Priority Order)

**P0 (Critical - Must Test):**
1. Core gameplay loop (collect, decide, upgrade)
2. Offline production calculation
3. A* pathfinding for conveyors
4. Resource flow simulation
5. Firebase security rules
6. Performance (60 FPS validation)

**P1 (High - Should Test):**
1. NPC Market buy/sell logic
2. Building upgrade cost calculation
3. Conveyor route creation
4. Camera zoom modes
5. Authentication flow
6. Analytics event tracking

**P2 (Medium - Nice to Test):**
1. UI animations (smooth transitions)
2. Haptic feedback timing
3. Welcome Back modal calculations
4. Tier 2 unlock celebration
5. Tutorial tooltips

**P3 (Low - Skip for MVP):**
1. Particle effects rendering
2. Sound effects playback
3. Minimap tap-to-jump
4. Settings menu persistence

---

## 2. Test Pyramid

### 2.1 Distribution Target

```
         ┌─────────────────┐
        /  E2E Tests (5%)   \
       /   10 tests          \
      /   - Full game flows  \
     /    - Device-specific  \
    ┌────────────────────────┐
   /  Integration (15%)      \
  /   50 tests                \
 /    - Multi-component flows \
/     - Firebase integration  \
┌──────────────────────────────┐
│   Unit Tests (80%)           │
│   300+ tests                 │
│   - Domain layer (use cases) │
│   - Data layer (repos)       │
│   - Game logic (pathfinding) │
└──────────────────────────────┘
```

**Why This Distribution:**
- **Unit tests (80%):** Fast, easy to debug, catch logic errors early
- **Integration tests (15%):** Verify components work together
- **E2E tests (5%):** Expensive to maintain, slow, but validate full user journey

### 2.2 Test Count Targets

| Test Type | Count | Runtime | Coverage |
|-----------|-------|---------|----------|
| Unit Tests | 300+ | <100ms total | 80%+ |
| Widget Tests | 100 | <5s total | 60%+ |
| Integration Tests | 50 | <30s total | Key flows |
| E2E Tests | 10 | <5min total | Critical paths |
| Performance Tests | 5 | <2min total | 60 FPS, memory |
| **Total** | **465+** | **<8min** | **80%+** |

---

## 3. Unit Testing

### 3.1 Domain Layer Testing (Priority: P0)

**What to Test:**
- ✅ Entities (Building, Resource, ConveyorRoute)
- ✅ Use Cases (CollectResources, UpgradeBuilding, CreateConveyor)
- ✅ Business Logic (production rate calculation, upgrade costs)

**Test Structure:**

```dart
// test/domain/usecases/collect_resources_use_case_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBuildingRepository extends Mock implements BuildingRepository {}

void main() {
  late CollectResourcesUseCase useCase;
  late MockBuildingRepository mockRepo;

  setUp(() {
    mockRepo = MockBuildingRepository();
    useCase = CollectResourcesUseCase(mockRepo);
  });

  group('CollectResourcesUseCase', () {
    test('should calculate resources based on time elapsed', () {
      // Arrange
      final building = Building(
        id: 'lumbermill_1',
        type: BuildingType.lumbermill,
        level: 3,
        production: ProductionConfig(
          outputResource: Resource(id: 'wood'),
          baseRate: 1.0, // 1 Wood/min
          storageCapacity: 14,
        ),
        lastCollected: DateTime.now().subtract(Duration(minutes: 10)),
      );

      final economy = PlayerEconomy(
        gold: 100,
        inventory: {'wood': Resource(id: 'wood', amount: 0, maxCapacity: 1000)},
        buildings: [building],
      );

      // Act
      final result = useCase.execute(economy, building);

      // Assert
      // Level 3 = 1.4× production rate
      // 10 minutes × 1.4 Wood/min = 14 Wood
      expect(result.inventory['wood']!.amount, equals(14));
    });

    test('should respect storage capacity limit', () {
      // Arrange
      final building = Building(
        // ... same as above
        production: ProductionConfig(
          storageCapacity: 10, // Only holds 10
        ),
        lastCollected: DateTime.now().subtract(Duration(hours: 10)), // Long time
      );

      // Act
      final result = useCase.execute(economy, building);

      // Assert
      expect(result.inventory['wood']!.amount, equals(10)); // Capped at 10
    });

    test('should not collect if lastCollected is recent', () {
      // Arrange
      final building = Building(
        lastCollected: DateTime.now(), // Just collected
      );

      // Act
      final result = useCase.execute(economy, building);

      // Assert
      expect(result.inventory['wood']!.amount, equals(0)); // Nothing collected
    });

    test('should update building lastCollected timestamp', () {
      // Arrange
      final oldTimestamp = DateTime.now().subtract(Duration(minutes: 5));
      final building = Building(lastCollected: oldTimestamp);

      // Act
      final result = useCase.execute(economy, building);

      // Assert
      final updatedBuilding = result.buildings.first;
      expect(updatedBuilding.lastCollected.isAfter(oldTimestamp), isTrue);
    });
  });
}
```

### 3.2 Data Layer Testing (Priority: P1)

**Repository Testing:**

```dart
// test/data/repositories/game_repository_impl_test.dart
void main() {
  late GameRepositoryImpl repository;
  late MockFirestoreDataSource mockFirestore;
  late MockHiveDataSource mockHive;

  setUp(() {
    mockFirestore = MockFirestoreDataSource();
    mockHive = MockHiveDataSource();
    repository = GameRepositoryImpl(
      firestoreDataSource: mockFirestore,
      hiveDataSource: mockHive,
    );
  });

  group('GameRepositoryImpl', () {
    test('should load from Hive cache first (offline-first)', () async {
      // Arrange
      final cachedState = PlayerEconomy(gold: 500);
      when(() => mockHive.getGameState())
          .thenAnswer((_) async => cachedState);

      // Act
      final result = await repository.loadGameState();

      // Assert
      expect(result, equals(cachedState));
      verify(() => mockHive.getGameState()).called(1);
      verifyNever(() => mockFirestore.getGameState()); // Didn't hit Firestore
    });

    test('should fallback to Firestore if Hive cache empty', () async {
      // Arrange
      when(() => mockHive.getGameState())
          .thenAnswer((_) async => null); // Cache empty
      final firestoreState = PlayerEconomy(gold: 1000);
      when(() => mockFirestore.getGameState())
          .thenAnswer((_) async => firestoreState);

      // Act
      final result = await repository.loadGameState();

      // Assert
      expect(result, equals(firestoreState));
      verify(() => mockHive.getGameState()).called(1);
      verify(() => mockFirestore.getGameState()).called(1);
    });

    test('should save to both Hive and Firestore', () async {
      // Arrange
      final state = PlayerEconomy(gold: 750);

      // Act
      await repository.saveGameState(state);

      // Assert
      verify(() => mockHive.saveGameState(state)).called(1);
      verify(() => mockFirestore.saveGameState(state)).called(1);
    });
  });
}
```

### 3.3 Game Logic Testing (Priority: P0)

**A* Pathfinding Test:**

```dart
// test/game/systems/pathfinding_system_test.dart
void main() {
  group('ConveyorPathfinder', () {
    test('should find shortest path between two points', () {
      // Arrange
      final pathfinder = ConveyorPathfinder(
        gridSize: Size(10, 10),
        occupiedTiles: {}, // Empty grid
      );

      final start = Point(0, 0);
      final end = Point(5, 5);

      // Act
      final path = pathfinder.findPath(start, end);

      // Assert
      expect(path, isNotNull);
      expect(path!.first, equals(start));
      expect(path.last, equals(end));
      // Manhattan distance = 10, so path should be ~10 tiles
      expect(path.length, equals(11)); // 11 tiles (start + 10 moves)
    });

    test('should avoid occupied tiles', () {
      // Arrange
      final obstacle = Point(2, 2);
      final pathfinder = ConveyorPathfinder(
        gridSize: Size(10, 10),
        occupiedTiles: {obstacle}, // Building at (2, 2)
      );

      final start = Point(0, 0);
      final end = Point(5, 5);

      // Act
      final path = pathfinder.findPath(start, end);

      // Assert
      expect(path, isNotNull);
      expect(path!.contains(obstacle), isFalse); // Path avoids obstacle
    });

    test('should return null if no path exists', () {
      // Arrange: Block end point with obstacles
      final pathfinder = ConveyorPathfinder(
        gridSize: Size(5, 5),
        occupiedTiles: {
          Point(3, 3), Point(3, 4), Point(3, 5),
          Point(4, 3), Point(4, 5),
          Point(5, 3), Point(5, 4), Point(5, 5),
        }, // Surround (4, 4)
      );

      final start = Point(0, 0);
      final end = Point(4, 4); // Unreachable

      // Act
      final path = pathfinder.findPath(start, end);

      // Assert
      expect(path, isNull); // No path possible
    });
  });
}
```

---

## 4. Widget Testing

### 4.1 UI Component Testing (Priority: P1)

**Button Widget Test:**

```dart
// test/presentation/widgets/buttons/primary_button_test.dart
void main() {
  group('PrimaryButton', () {
    testWidgets('should display label text', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Collect Resources',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Collect Resources'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      // Arrange
      var pressCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Test',
              onPressed: () => pressCount++,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      // Assert
      expect(pressCount, equals(1));
    });

    testWidgets('should be disabled when onPressed is null', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Disabled',
              onPressed: null, // Disabled
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.enabled, isFalse);
    });

    testWidgets('should have minimum 44×44 tap target', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      final size = tester.getSize(find.byType(PrimaryButton));
      expect(size.height, greaterThanOrEqualTo(44)); // Apple HIG minimum
    });
  });
}
```

**Building Card Widget Test:**

```dart
// test/presentation/screens/build_menu/widgets/building_card_test.dart
void main() {
  group('BuildingCard', () {
    testWidgets('should show building name and cost', (tester) async {
      // Arrange
      final buildingDef = BuildingDefinition(
        type: BuildingType.lumbermill,
        displayName: 'Lumbermill',
        costs: BuildingCosts(construction: 100),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BuildingCard(definition: buildingDef),
          ),
        ),
      );

      // Assert
      expect(find.text('Lumbermill'), findsOneWidget);
      expect(find.text('100 Gold'), findsOneWidget);
    });

    testWidgets('should show disabled state if insufficient gold', (tester) async {
      // Arrange
      final buildingDef = BuildingDefinition(
        costs: BuildingCosts(construction: 200),
      );

      final playerEconomy = PlayerEconomy(gold: 50); // Not enough

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BuildingCard(
              definition: buildingDef,
              playerEconomy: playerEconomy,
            ),
          ),
        ),
      );

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, equals(Colors.grey)); // Disabled color
    });
  });
}
```

### 4.2 Screen Testing (Priority: P2)

**Main Game Screen Test:**

```dart
// test/presentation/screens/main_game/main_game_screen_test.dart
void main() {
  group('MainGameScreen', () {
    testWidgets('should display Top HUD with gold count', (tester) async {
      // Arrange
      final mockEconomy = PlayerEconomy(gold: 1234);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider.overrideWith((ref) => mockEconomy),
          ],
          child: MaterialApp(home: MainGameScreen()),
        ),
      );

      // Assert
      expect(find.text('1,234 Gold'), findsOneWidget);
    });

    testWidgets('should display Bottom Toolbar with 5 buttons', (tester) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: MainGameScreen()));

      // Assert
      expect(find.text('Build'), findsOneWidget);
      expect(find.text('Conveyor'), findsOneWidget);
      expect(find.text('Market'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should open Build Menu when Build button tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(home: MainGameScreen()));

      // Act
      await tester.tap(find.text('Build'));
      await tester.pumpAndSettle(); // Wait for bottom sheet animation

      // Assert
      expect(find.byType(BuildMenuScreen), findsOneWidget);
    });
  });
}
```

---

## 5. Integration Testing

### 5.1 Full Game Flow Tests (Priority: P0)

**Complete Gameplay Loop Test:**

```dart
// integration_test/full_game_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full Game Flow', () {
    testWidgets('Player can complete COLLECT → DECIDE → UPGRADE loop', (tester) async {
      // Arrange: Launch app
      await tester.pumpWidget(TradeFactoryApp());
      await tester.pumpAndSettle();

      // Step 1: COLLECT - Tap building to collect resources
      print('Step 1: Collecting resources');
      final buildingFinder = find.byType(BuildingComponent).first;
      await tester.tap(buildingFinder);
      await tester.pumpAndSettle();

      // Verify floating text "+X Wood" appeared
      expect(find.textContaining('Wood'), findsWidgets);

      // Step 2: DECIDE - Open Market and sell resources
      print('Step 2: Selling resources at Market');
      await tester.tap(find.text('Market'));
      await tester.pumpAndSettle();

      // Switch to SELL tab
      await tester.tap(find.text('SELL'));
      await tester.pumpAndSettle();

      // Find Wood row, adjust slider to 10, tap Sell
      await tester.drag(
        find.byType(Slider).first,
        Offset(100, 0), // Drag slider right
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sell'));
      await tester.pumpAndSettle();

      // Verify gold increased
      expect(find.textContaining('Gold'), findsWidgets);

      // Close Market
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Step 3: UPGRADE - Upgrade building
      print('Step 3: Upgrading building');
      await tester.tap(buildingFinder); // Tap building again
      await tester.pumpAndSettle();

      // Building Details Panel should appear
      expect(find.text('Upgrade'), findsOneWidget);

      await tester.tap(find.text('Upgrade'));
      await tester.pumpAndSettle();

      // Verify level increased (find "Level 2" text)
      expect(find.text('Level 2'), findsOneWidget);

      // Verify celebration animation
      expect(find.textContaining('+20%'), findsWidgets);

      print('✅ Full loop completed successfully');
    });
  });
}
```

### 5.2 Offline Production Test

```dart
// integration_test/offline_production_test.dart
void main() {
  testWidgets('Offline production calculates correctly', (tester) async {
    // Arrange: Setup game with 1 Lumbermill
    await tester.pumpWidget(TradeFactoryApp());
    await tester.pumpAndSettle();

    // Get initial gold/resources
    final initialGold = _getGoldCount(tester);

    // Simulate app close (save lastSeen timestamp)
    final lastSeen = DateTime.now();
    await _saveLastSeen(lastSeen);

    // Simulate time passing (3 hours)
    final now = lastSeen.add(Duration(hours: 3));

    // Restart app with mocked DateTime.now()
    await tester.pumpWidget(
      TradeFactoryApp(currentTime: now), // Inject time
    );
    await tester.pumpAndSettle();

    // Assert: Welcome Back Modal should appear
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.textContaining('3 hours'), findsOneWidget);

    // Verify production amounts
    // Level 1 Lumbermill: 1 Wood/min × 180 min = 180 Wood
    expect(find.text('+180 Wood'), findsOneWidget);

    // Tap "Collect All"
    await tester.tap(find.text('Collect All Resources'));
    await tester.pumpAndSettle();

    // Verify resources added to inventory
    expect(find.text('180'), findsOneWidget); // Wood count in HUD
  });
}
```

---

## 6. Performance Testing

### 6.1 FPS Validation Test (Priority: P0)

**60 FPS with 50 Conveyors:**

```dart
// test/performance/fps_test.dart
void main() {
  test('Game maintains 60 FPS with 50 active conveyors', () async {
    // Arrange: Create game instance
    final game = TradeFactoryGame();
    await game.onLoad();

    // Add 50 conveyor routes with active resource sprites
    for (int i = 0; i < 50; i++) {
      final route = ConveyorRoute(
        id: 'route_$i',
        path: _generateRandomPath(length: 20),
        // ... other properties
      );
      game.addConveyor(route);

      // Add 2 resource sprites per conveyor (100 total sprites)
      game.spawnResourceSprite(route, ResourceType.wood);
      game.spawnResourceSprite(route, ResourceType.ore);
    }

    // Act: Measure FPS over 10 seconds
    final fpsReadings = <double>[];
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsedMilliseconds < 10000) {
      final frameStart = DateTime.now().microsecondsSinceEpoch;

      game.update(0.016); // 16ms per frame (60 FPS)
      game.render(MockCanvas());

      final frameEnd = DateTime.now().microsecondsSinceEpoch;
      final frameDuration = (frameEnd - frameStart) / 1000; // ms

      fpsReadings.add(1000 / frameDuration);

      await Future.delayed(Duration(milliseconds: 16));
    }

    // Assert: Average FPS should be 60 ± 5
    final avgFPS = fpsReadings.reduce((a, b) => a + b) / fpsReadings.length;
    print('Average FPS: $avgFPS');

    expect(avgFPS, greaterThanOrEqualTo(55));
    expect(avgFPS, lessThanOrEqualTo(65));

    // No frame should drop below 30 FPS (critical drops)
    final minFPS = fpsReadings.reduce(min);
    expect(minFPS, greaterThanOrEqualTo(30));
  });
}
```

### 6.2 Memory Usage Test

```dart
// test/performance/memory_test.dart
void main() {
  test('Game memory usage stays under 150 MB', () async {
    // Arrange
    final game = TradeFactoryGame();
    await game.onLoad();

    // Load all sprites (worst case)
    await SpriteLoader.loadAll();

    // Add 20 buildings (Tier 1 + Tier 2)
    for (int i = 0; i < 20; i++) {
      game.addBuilding(Building(/* ... */));
    }

    // Add 50 conveyors
    for (int i = 0; i < 50; i++) {
      game.addConveyor(ConveyorRoute(/* ... */));
    }

    // Act: Measure memory
    final memoryUsage = _getMemoryUsage(); // MB

    // Assert
    expect(memoryUsage, lessThan(150)); // Target: <150 MB
    print('Memory usage: $memoryUsage MB');
  });
}
```

### 6.3 Load Time Test

```dart
// test/performance/load_time_test.dart
void main() {
  testWidgets('App cold start completes in <3 seconds', (tester) async {
    // Arrange
    final stopwatch = Stopwatch()..start();

    // Act: Launch app
    await tester.pumpWidget(TradeFactoryApp());

    // Wait until first frame is playable
    await tester.pumpAndSettle();

    stopwatch.stop();
    final loadTime = stopwatch.elapsedMilliseconds / 1000; // seconds

    // Assert
    expect(loadTime, lessThan(3.0)); // Target: <3s
    print('Load time: ${loadTime}s');
  });
}
```

---

## 7. Accessibility Testing

### 7.1 Contrast Ratio Test

```dart
// test/accessibility/contrast_test.dart
void main() {
  test('Text has WCAG AAA contrast ratio (7:1)', () {
    // Arrange: Design system colors
    final backgroundColor = Color(0xFF1E1E1E); // Dark Gray
    final textColor = Color(0xFFF5F5F5); // Off-White

    // Act: Calculate contrast ratio
    final ratio = _calculateContrastRatio(backgroundColor, textColor);

    // Assert: WCAG AAA requires 7:1 for normal text
    expect(ratio, greaterThanOrEqualTo(7.0));
  });

  test('Primary button has sufficient contrast', () {
    final buttonColor = Color(0xFF4CAF50); // Success Green
    final textColor = Colors.white;

    final ratio = _calculateContrastRatio(buttonColor, textColor);

    expect(ratio, greaterThanOrEqualTo(4.5)); // WCAG AA for large text
  });
}

double _calculateContrastRatio(Color bg, Color fg) {
  final l1 = _relativeLuminance(bg);
  final l2 = _relativeLuminance(fg);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}
```

### 7.2 Tap Target Size Test

```dart
// test/accessibility/tap_target_test.dart
void main() {
  testWidgets('All buttons meet 44×44px minimum', (tester) async {
    // Arrange & Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              PrimaryButton(label: 'Test 1', onPressed: () {}),
              SecondaryButton(label: 'Test 2', onPressed: () {}),
              // ... all button types
            ],
          ),
        ),
      ),
    );

    // Assert: Check all button sizes
    final buttons = find.byType(ElevatedButton);
    for (final button in buttons.evaluate()) {
      final size = tester.getSize(find.byWidget(button.widget));

      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    }
  });
}
```

---

## 8. Device Testing Matrix

### 8.1 Target Devices

**Android (Priority):**
| Device | OS | Screen Size | RAM | Test Focus |
|--------|-----|-------------|-----|------------|
| **Snapdragon 660** | Android 10 | 6.0" FHD+ | 4GB | Performance (budget target) |
| Pixel 6 | Android 14 | 6.4" FHD+ | 8GB | Latest features, 60 FPS |
| Samsung Galaxy A52 | Android 13 | 6.5" FHD+ | 6GB | Mid-range, common device |
| OnePlus Nord | Android 12 | 6.44" | 8GB | OxygenOS compatibility |

**iOS (Secondary):**
| Device | OS | Screen Size | RAM | Test Focus |
|--------|-----|-------------|-----|------------|
| iPhone SE (2022) | iOS 17 | 4.7" | 4GB | Small screen, budget iOS |
| iPhone 13 | iOS 17 | 6.1" | 4GB | Standard size |
| iPhone 15 Pro | iOS 17 | 6.1" | 8GB | Latest hardware, ProMotion |

### 8.2 Testing Checklist per Device

**Per Device Test:**
- [ ] 60 FPS sustained (play 30 min with 50 conveyors)
- [ ] <3s cold start load time
- [ ] <1% crash rate (100 sessions)
- [ ] Touch controls responsive (<50ms tap response)
- [ ] Haptic feedback works correctly
- [ ] Camera pan/pinch/zoom smooth
- [ ] Offline production calculation <50ms
- [ ] Battery drain acceptable (<10% per hour)

### 8.3 Automated Device Testing (Firebase Test Lab)

```yaml
# .github/workflows/device_test.yml
name: Firebase Test Lab

on:
  push:
    branches: [main, develop]

jobs:
  test-lab:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build APK for testing
        run: flutter build apk --debug

      - name: Run tests on Firebase Test Lab
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          projectId: trade-factory-masters
          devices: |
            - model: blueline  # Pixel 3 (Snapdragon 845)
              version: 28
            - model: a50       # Galaxy A50 (similar to budget target)
              version: 29
            - model: redfin    # Pixel 5 (mid-range)
              version: 30
```

---

## 9. CI/CD Integration

### 9.1 GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Get dependencies
        run: flutter pub get

      - name: Analyze code
        run: flutter analyze

      - name: Run unit tests
        run: flutter test --coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  widget-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2

      - run: flutter pub get
      - run: flutter test test/presentation/

  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2

      - run: flutter pub get
      - run: flutter test integration_test/

  performance-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2

      - run: flutter pub get
      - run: flutter test test/performance/

  # Require all tests pass before merge
  all-tests-passed:
    needs: [unit-tests, widget-tests, integration-tests, performance-tests]
    runs-on: ubuntu-latest
    steps:
      - run: echo "All tests passed! ✅"
```

### 9.2 Pre-Commit Hooks

```bash
# .git/hooks/pre-commit
#!/bin/sh

echo "Running tests before commit..."

# Run unit tests
flutter test --no-sound-null-safety || {
  echo "❌ Unit tests failed. Commit aborted."
  exit 1
}

# Run analyzer
flutter analyze || {
  echo "❌ Flutter analyze found issues. Commit aborted."
  exit 1
}

echo "✅ All tests passed. Committing..."
exit 0
```

---

## 10. Test Coverage Monitoring

### 10.1 Coverage Targets

| Layer | Target | Priority |
|-------|--------|----------|
| Domain Layer | 90%+ | CRITICAL |
| Data Layer | 80%+ | HIGH |
| Presentation Layer | 60%+ | MEDIUM |
| Game Engine | 70%+ | HIGH |
| **Overall** | **80%+** | **TARGET** |

### 10.2 Generating Coverage Reports

```bash
# Generate coverage
flutter test --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

### 10.3 Coverage Badges

```markdown
# README.md
![Coverage](https://codecov.io/gh/CoderMariusz/FantasyFactio/branch/main/graph/badge.svg)
```

---

## 11. Test Tools & Frameworks

### 11.1 Dependencies

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter

  # Unit Testing
  mocktail: ^1.0.1              # Mocking (better than mockito)
  faker: ^2.1.0                 # Test data generation

  # Integration Testing
  integration_test:
    sdk: flutter

  # Performance Testing
  flutter_driver:
    sdk: flutter

  # Coverage
  coverage: ^1.6.4

  # Linting
  flutter_lints: ^3.0.0
```

### 11.2 Helper Utilities

**Test Data Builders:**

```dart
// test/helpers/builders/building_builder.dart
class BuildingBuilder {
  String _id = 'building_1';
  BuildingType _type = BuildingType.lumbermill;
  int _level = 1;
  DateTime _lastCollected = DateTime.now();

  BuildingBuilder withId(String id) {
    _id = id;
    return this;
  }

  BuildingBuilder withLevel(int level) {
    _level = level;
    return this;
  }

  BuildingBuilder lastCollectedAt(DateTime time) {
    _lastCollected = time;
    return this;
  }

  Building build() {
    return Building(
      id: _id,
      type: _type,
      level: _level,
      lastCollected: _lastCollected,
      // ... other default values
    );
  }
}

// Usage in tests:
final building = BuildingBuilder()
    .withLevel(3)
    .lastCollectedAt(DateTime.now().subtract(Duration(minutes: 10)))
    .build();
```

---

## 12. Example Test Suites

### 12.1 Offline Production Test Suite

```dart
// test/domain/usecases/calculate_offline_production_test.dart
void main() {
  group('CalculateOfflineProductionUseCase', () {
    late CalculateOfflineProductionUseCase useCase;

    setUp(() {
      useCase = CalculateOfflineProductionUseCase();
    });

    group('Tier 1 (Simple Production)', () {
      test('should calculate production for single building', () {
        // Arrange
        final building = BuildingBuilder()
            .withType(BuildingType.lumbermill)
            .withLevel(1)
            .lastCollectedAt(DateTime(2025, 1, 1, 10, 0))
            .build();

        final buildings = [building];
        final lastSeen = DateTime(2025, 1, 1, 10, 0);
        final now = DateTime(2025, 1, 1, 13, 0); // 3 hours later

        // Act
        final result = useCase.execute(buildings, [], lastSeen, now);

        // Assert
        // 3 hours × 60 min/hour × 1 Wood/min = 180 Wood
        expect(result.getTotalProduced(ResourceType.wood), equals(180));
      });

      test('should respect storage capacity', () {
        // Arrange
        final building = BuildingBuilder()
            .withProductionConfig(
              ProductionConfig(
                baseRate: 1.0,
                storageCapacity: 100, // Max 100 Wood
              ),
            )
            .lastCollectedAt(DateTime.now().subtract(Duration(hours: 10)))
            .build();

        // Act
        final result = useCase.execute([building], [], lastSeen, now);

        // Assert: Capped at 100 despite 10 hours production
        expect(result.getTotalProduced(ResourceType.wood), equals(100));
        expect(result.buildingResults.first.wasCapped, isTrue);
      });

      test('should apply 12-hour offline cap for Tier 1', () {
        // Arrange
        final building = BuildingBuilder().build();
        final lastSeen = DateTime.now().subtract(Duration(days: 7)); // 1 week
        final now = DateTime.now();

        // Act
        final result = useCase.execute([building], [], lastSeen, now);

        // Assert: Only 12 hours of production applied
        final maxProduction = 12 * 60 * 1; // 12h × 60min × 1 Wood/min = 720
        expect(
          result.getTotalProduced(ResourceType.wood),
          lessThanOrEqualTo(maxProduction),
        );
      });
    });

    group('Tier 2 (Automated Production with Conveyors)', () {
      test('should calculate production with supply chain dependencies', () {
        // Arrange: Lumbermill → Smelter → Workshop
        final lumbermill = BuildingBuilder()
            .withType(BuildingType.lumbermill)
            .build();

        final smelter = BuildingBuilder()
            .withType(BuildingType.smelter)
            .withRecipe(ProductionRecipe(
              inputs: {'wood': 1, 'ore': 1},
              outputs: {'bars': 1},
            ))
            .build();

        final workshop = BuildingBuilder()
            .withType(BuildingType.workshop)
            .withRecipe(ProductionRecipe(
              inputs: {'bars': 2, 'ore': 1},
              outputs: {'tools': 1},
            ))
            .build();

        final conveyors = [
          ConveyorRoute(
            startBuilding: lumbermill,
            endBuilding: smelter,
            resourceType: ResourceType.wood,
          ),
          ConveyorRoute(
            startBuilding: smelter,
            endBuilding: workshop,
            resourceType: ResourceType.bars,
          ),
        ];

        // Act: 1 hour offline
        final result = useCase.execute(
          [lumbermill, smelter, workshop],
          conveyors,
          lastSeen,
          now,
        );

        // Assert: Production limited by slowest step
        expect(result.getTotalProduced(ResourceType.tools), greaterThan(0));
      });

      test('should detect bottlenecks in supply chain', () {
        // Arrange: Smelter needs Wood + Ore, but no Ore building
        final lumbermill = BuildingBuilder().build();
        final smelter = BuildingBuilder()
            .withType(BuildingType.smelter)
            .build();

        final conveyors = [
          ConveyorRoute(
            startBuilding: lumbermill,
            endBuilding: smelter,
            resourceType: ResourceType.wood,
          ),
        ];

        // Act
        final result = useCase.execute(
          [lumbermill, smelter],
          conveyors,
          lastSeen,
          now,
        );

        // Assert: Smelter produced 0 (missing Ore input)
        final smelterResult = result.buildingResults[smelter]!;
        expect(smelterResult.amount, equals(0));
        expect(smelterResult.limitedBy, equals('inputs'));
      });
    });
  });
}
```

---

## 13. Test Execution Schedule

### 13.1 Development Workflow

**Before Every Commit:**
- [ ] Run unit tests (`flutter test`)
- [ ] Run analyzer (`flutter analyze`)

**Before Pull Request:**
- [ ] Run full test suite (unit + widget + integration)
- [ ] Check coverage (>80%)
- [ ] Run performance tests on local device

**Before Release:**
- [ ] Run E2E tests on all target devices (Firebase Test Lab)
- [ ] Manual QA testing (20 hours gameplay)
- [ ] Performance profiling (60 FPS validation)
- [ ] Accessibility audit (contrast, tap targets)

### 13.2 Continuous Monitoring

**Post-Launch:**
- Firebase Crashlytics: Monitor crash-free rate (>99% target)
- Firebase Performance Monitoring: Track FPS, load times
- Firebase Analytics: Monitor D7 retention (30-35% target)
- User feedback: App Store reviews, Discord reports

---

## 14. Test Design Validation Checklist

✅ **Test Strategy Defined:**
- Test pyramid (80% unit, 15% integration, 5% E2E) ✓
- Coverage targets (80%+ overall, 90%+ Domain) ✓
- Priority matrix (P0-P3 for what to test) ✓

✅ **Test Frameworks Selected:**
- flutter_test, mocktail, integration_test ✓
- CI/CD integration (GitHub Actions) ✓
- Device testing (Firebase Test Lab) ✓

✅ **Critical Paths Covered:**
- Core gameplay loop (COLLECT → DECIDE → UPGRADE) ✓
- Offline production calculation ✓
- A* pathfinding ✓
- 60 FPS performance ✓

✅ **Accessibility Validated:**
- Contrast ratios (WCAG AAA 7:1) ✓
- Tap target sizes (44×44px minimum) ✓
- Screen reader support (future) ✓

✅ **Performance Tested:**
- 60 FPS with 50 conveyors ✓
- <3s cold start load time ✓
- <150 MB memory usage ✓

---

**End of Test Design Document**

**Status:** ✅ Ready for Sprint Planning
**Next:** Create Epics & Stories → Start Implementation (Week 1: Setup)
