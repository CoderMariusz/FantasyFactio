# PATTERNS - Code Patterns & Conventions

<!-- AI-INDEX: patterns, examples, conventions, standards, code-style -->

Last Updated: 2025-12-02

---

## Quick Reference

When writing code, use these proven patterns from the existing codebase.

---

## Clean Architecture Layers

### 1. Domain Layer (Business Logic)

Domain layer is **framework-independent**. No imports of Flutter, Flame, or external packages except core types.

```dart
// lib/domain/usecases/collect_resources_usecase.dart

import 'package:trade_factory_masters/domain/core/result.dart';
import 'package:trade_factory_masters/domain/entities/building.dart';
import 'package:trade_factory_masters/domain/entities/player_economy.dart';

enum CollectError { generic }

class CollectResourcesUseCase {
  Result<PlayerEconomy, CollectError> execute({
    required PlayerEconomy economy,
    required Building building,
  }) {
    // Pure business logic - no side effects
    // Return Result.success() or Result.failure()
    return Result.success(updatedEconomy);
  }
}
```

**Key Points:**
- No Flutter imports
- Stateless (pure functions)
- Return Result<Success, Failure> type
- Throw no exceptions (use Result instead)

### 2. Game Layer (Flame Components)

Game components handle rendering and interaction only. Complex logic should be in domain layer.

```dart
// lib/game/components/building_component.dart

import 'package:flame/components.dart';

class BuildingComponent extends PositionComponent {
  late Sprite _sprite;
  bool _isSelected = false;

  @override
  Future<void> onLoad() async {
    _sprite = await Sprite.load('images/buildings/farm.png');
    size = Vector2(64, 64);
  }

  @override
  void render(Canvas canvas) {
    _sprite.render(canvas, position: position, size: size);
    if (_isSelected) {
      _drawSelectedIndicator(canvas);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isSelected = !_isSelected;
  }
}
```

**Key Points:**
- Inherit from appropriate Flame component
- Keep rendering separate from logic
- Delegate business logic to domain layer
- Use onLoad() for resource initialization

### 3. Entity Pattern

Entities are immutable, represent core domain objects.

```dart
// lib/domain/entities/building.dart

class Building {
  final String id;
  final String name;
  final int level;
  final double productionRate; // resources per second

  const Building({
    required this.id,
    required this.name,
    required this.level,
    required this.productionRate,
  });

  // Create modified copy (immutability pattern)
  Building copyWith({
    String? id,
    String? name,
    int? level,
    double? productionRate,
  }) {
    return Building(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      productionRate: productionRate ?? this.productionRate,
    );
  }

  // Equality for testing
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Building &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          level == other.level;

  @override
  int get hashCode => id.hashCode ^ level.hashCode;
}
```

**Key Points:**
- Use `const` constructor (enables compiler optimization)
- Implement `==` and `hashCode` for testing
- Use `copyWith()` for immutable updates
- No mutable state

### 4. Use Case Pattern

Use cases orchestrate domain logic and return Result type.

```dart
// lib/domain/usecases/upgrade_building_usecase.dart

import 'package:trade_factory_masters/domain/core/result.dart';

enum UpgradeError {
  insufficientGold,
  maxLevelReached,
  generic,
}

class UpgradeBuildingUseCase {
  Result<PlayerEconomy, UpgradeError> execute({
    required PlayerEconomy economy,
    required Building building,
  }) {
    // Validate preconditions
    if (economy.gold < building.upgradeCost) {
      return Result.failure(UpgradeError.insufficientGold);
    }

    if (building.level >= building.maxLevel) {
      return Result.failure(UpgradeError.maxLevelReached);
    }

    // Execute domain logic
    final upgradedBuilding = building.copyWith(
      level: building.level + 1,
      productionRate: building.productionRate * 1.2,
    );

    final updatedEconomy = economy
        .removeGold(building.upgradeCost)
        .updateBuilding(upgradedBuilding);

    return Result.success(updatedEconomy);
  }
}
```

**Key Points:**
- Method is called `execute()`
- Returns `Result<Success, Failure>`
- Validate preconditions first
- Use domain objects, not data models

---

## Error Handling Pattern

### Result Type

```dart
// lib/domain/core/result.dart

abstract class Result<Success, Failure> {
  const Result();

  factory Result.success(Success value) = _Success;
  factory Result.failure(Failure error) = _Failure;

  T fold<T>(
    T Function(Success) onSuccess,
    T Function(Failure) onFailure,
  );
}

class _Success<Success, Failure> extends Result<Success, Failure> {
  final Success value;
  const _Success(this.value);

  @override
  T fold<T>(T Function(Success) onSuccess, T Function(Failure) _) =>
      onSuccess(value);
}

class _Failure<Success, Failure> extends Result<Success, Failure> {
  final Failure error;
  const _Failure(this.error);

  @override
  T fold<T>(T Function(Success) _, T Function(Failure) onFailure) =>
      onFailure(error);
}
```

### Usage in Code

```dart
// Using fold() pattern (recommended)
final result = CollectResourcesUseCase().execute(
  economy: currentEconomy,
  building: selectedBuilding,
);

result.fold(
  (success) => updateGameState(success),
  (failure) => showErrorDialog(failure),
);

// Or check with pattern matching
if (result is _Success<PlayerEconomy, CollectError>) {
  updateGameState(result.value);
} else if (result is _Failure) {
  showErrorDialog(result.error);
}
```

**Benefits:**
- No exceptions thrown
- Type-safe error handling
- Forces you to handle failure case
- Composable and testable

---

## State Management Pattern (Riverpod)

### Provider Pattern

```dart
// lib/infrastructure/providers/game_state_provider.dart

import 'package:riverpod/riverpod.dart';
import 'package:trade_factory_masters/domain/entities/player_economy.dart';

// Simple state provider (mutable)
final gameStateProvider = StateProvider<PlayerEconomy>((ref) {
  return PlayerEconomy(
    gold: 100,
    buildings: [],
    inventory: {},
    tier: 1,
    lastSeen: DateTime.now(),
  );
});

// Use in UI (ConsumerWidget)
class GameScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      body: Text('Gold: ${gameState.gold}'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(gameStateProvider.notifier).state =
              gameState.copyWith(gold: gameState.gold + 10);
        },
      ),
    );
  }
}
```

### Using with Use Cases

```dart
// Define use case as provider
final collectResourcesProvider = Provider((ref) {
  return CollectResourcesUseCase();
});

// Use in ConsumerWidget
class GameScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final collectResources = ref.watch(collectResourcesProvider);

    return GestureDetector(
      onTap: () {
        final result = collectResources.execute(
          economy: gameState,
          building: selectedBuilding,
        );

        result.fold(
          (success) {
            ref.read(gameStateProvider.notifier).state = success;
          },
          (failure) => showError(failure),
        );
      },
    );
  }
}
```

---

## Camera/Grid Pattern

### Coordinate Conversion

```dart
// Converting between grid and screen coordinates

// Grid coordinates (0,0 to 50,49) → Screen coordinates (pixels)
Vector2 gridToScreen(int gridX, int gridY) {
  final screenX = (gridX - gridY) * tileWidth / 2;
  final screenY = (gridX + gridY) * tileHeight / 2;
  return Vector2(screenX, screenY);
}

// Screen coordinates (pixels) → Grid coordinates
Pair<int, int> screenToGrid(Vector2 screenPos) {
  final gridX = (screenPos.x / tileWidth + screenPos.y / tileHeight).toInt();
  final gridY = (screenPos.y / tileHeight - screenPos.x / tileWidth).toInt();
  return Pair(gridX, gridY);
}
```

### Camera Zoom Example

```dart
// Zoom levels
const double MIN_ZOOM = 0.3;
const double MAX_ZOOM = 2.0;

// Apply zoom (in game component)
canvas.scale(zoomLevel);
canvas.translate(-camera.position.x, -camera.position.y);
// render components
```

---

## Testing Patterns

### Unit Test Pattern

```dart
// test/domain/entities/building_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/building.dart';

void main() {
  group('Building', () {
    test('creates building with correct properties', () {
      const building = Building(
        id: 'farm-1',
        name: 'Farm',
        level: 1,
        productionRate: 1.0,
      );

      expect(building.id, equals('farm-1'));
      expect(building.level, equals(1));
      expect(building.productionRate, equals(1.0));
    });

    test('copyWith creates new instance with updated values', () {
      const original = Building(
        id: 'farm-1',
        name: 'Farm',
        level: 1,
        productionRate: 1.0,
      );

      final updated = original.copyWith(level: 2);

      expect(original.level, equals(1)); // Original unchanged
      expect(updated.level, equals(2)); // New instance has update
      expect(updated.id, equals('farm-1')); // Other fields unchanged
    });

    test('equality works correctly', () {
      const building1 = Building(
        id: 'farm-1',
        name: 'Farm',
        level: 1,
        productionRate: 1.0,
      );

      const building2 = Building(
        id: 'farm-1',
        name: 'Farm',
        level: 1,
        productionRate: 1.0,
      );

      expect(building1, equals(building2));
    });
  });
}
```

### Integration Test Pattern

```dart
// integration_test/core_gameplay_loop_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trade_factory_masters/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete gameplay loop', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Test steps
    expect(find.text('Gold: 100'), findsOneWidget);

    // Tap building
    await tester.tap(find.byType(BuildingComponent));
    await tester.pumpAndSettle();

    // Verify result
    expect(find.text('Gold: 110'), findsOneWidget);
  });
}
```

---

## File Naming Conventions

| Element | Format | Example |
|---------|--------|---------|
| File | snake_case.dart | `collect_resources_usecase.dart` |
| Class | PascalCase | `CollectResourcesUseCase` |
| Enum | PascalCase | `CollectError` |
| Function | camelCase | `collectResources()` |
| Variable | camelCase | `currentEconomy` |
| Constant | UPPER_SNAKE_CASE | `MAX_GRID_WIDTH` |
| Private field | _camelCase | `_isSelected` |
| Private function | _camelCase | `_drawGlowEffect()` |

---

## Import Organization

```dart
// 1. Dart imports first
import 'dart:async';
import 'dart:math';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 3. Package imports (external)
import 'package:flame/components.dart';
import 'package:riverpod/riverpod.dart';

// 4. Project imports (internal)
import 'package:trade_factory_masters/domain/entities/building.dart';
import 'package:trade_factory_masters/domain/usecases/collect_resources_usecase.dart';

// 5. Relative imports (for same package, sparingly)
import '../entities/building.dart';
```

---

## Code Style Guidelines

### Formatting

- Use `dart format` automatically (run before commit)
- Max line length: 120 characters
- 2-space indentation

### Comments

```dart
// Use single-line comments for single statements
int calculateCost(int level) {
  // Production cost increases exponentially with level
  return 10 * (2 << level);
}

// Use doc comments (///) for public APIs
/// Calculates the cost to upgrade a building to next level
///
/// [level] Current building level
/// Returns the gold cost for next upgrade
int calculateUpgradeCost(int level) {
  return 10 * (2 << level);
}
```

### Null Safety

```dart
// Always use non-null types where possible
String name; // ✅ Required

// Use ? only when null is a valid value
String? nickname; // ✅ Nullable

// Use ! only after null checks
final value = maybeNull;
if (value != null) {
  print(value.length); // ✅ Type narrowing
}
```

---

## Avoid Common Mistakes

### ❌ DON'T

```dart
// Don't throw exceptions in domain layer
throw Exception('Not enough gold');

// Don't mix UI and domain logic
void collect() {
  final result = useCase.execute(...);
  navigator.push(...); // UI code in domain!
}

// Don't use mutable state in entities
class Building {
  int level = 1; // ❌ Mutable
}

// Don't hardcode values
final maxZoom = 2.0; // ❌ Magic number
```

### ✅ DO

```dart
// Return Result type instead
return Result.failure(CollectError.insufficientGold);

// Keep domain logic separate from UI
final result = useCase.execute(...);
result.fold(
  (success) => ref.read(provider.notifier).state = success,
  (failure) => showError(failure),
);

// Use immutable entities
class Building {
  final int level;
  Building({required this.level});
}

// Extract magic numbers to constants
static const double MAX_ZOOM = 2.0;
```

---

## How to Update This File

When discovering new patterns or established conventions:

1. Add new section with clear example
2. Show both pattern and anti-pattern if relevant
3. Explain why this pattern is preferred
4. Reference files where pattern is used
5. Include test examples if applicable

**This file is AI-optimized for quick pattern lookup. Keep examples short and clear!**
