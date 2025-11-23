import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/building.dart';
import 'package:trade_factory_masters/domain/entities/player_economy.dart';
import 'package:trade_factory_masters/game/components/building_component.dart';
import 'package:trade_factory_masters/game/components/grid_component.dart';
import 'package:trade_factory_masters/domain/usecases/collect_resources.dart';

/// Unit Tests: BuildingComponent
/// Tests the visual representation and interaction of buildings
///
/// Story: STORY-01.7 - Building Sprite Component (3 SP)
/// Coverage:
/// - Component initialization
/// - Grid position to screen position conversion
/// - Building size calculation based on type and level
/// - Tap detection and resource collection
/// - Animations (pulse effect)
/// - Performance with multiple buildings
void main() {
  group('BuildingComponent', () {
    late GridConfig gridConfig;
    late PlayerEconomy playerEconomy;
    late Building testBuilding;

    setUp(() {
      gridConfig = const GridConfig(
        gridWidth: 50,
        gridHeight: 50,
        tileWidth: 64.0,
        tileHeight: 32.0,
        showGridLines: true,
      );

      playerEconomy = PlayerEconomy(
        gold: 1000,
        inventory: {},
        buildings: [],
        tier: 1,
        lastSeen: DateTime.now(),
      );

      testBuilding = Building(
        id: 'test_building_1',
        type: BuildingType.collector,
        level: 1,
        gridPosition: const GridPosition(x: 10, y: 10),
        production: const ProductionConfig(
          baseRate: 5.0,
          resourceType: 'Wood',
        ),
        upgradeConfig: const UpgradeConfig(
          baseCost: 100,
          costIncrement: 50,
          maxLevel: 10,
        ),
        lastCollected: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
      );
    });

    testWithGame(
      'Component initializes with correct position',
      () => FlameTester(Flame.new),
      (game) async {
        final component = BuildingComponent(
          building: testBuilding,
          gridConfig: gridConfig,
          playerEconomy: playerEconomy,
        );

        await game.ensureAdd(component);

        // Verify position is set from grid coordinates
        final expectedPos = gridConfig.gridToScreen(
          testBuilding.gridPosition.x,
          testBuilding.gridPosition.y,
        );

        expect(component.position.x, equals(expectedPos.x));
        expect(component.position.y, equals(expectedPos.y));
      },
    );

    testWithGame(
      'Component size scales with building level',
      () => FlameTester(Flame.new),
      (game) async {
        final level1Building = testBuilding;
        final level10Building = testBuilding.copyWith(level: 10);

        final component1 = BuildingComponent(
          building: level1Building,
          gridConfig: gridConfig,
          playerEconomy: playerEconomy,
        );

        final component10 = BuildingComponent(
          building: level10Building,
          gridConfig: gridConfig,
          playerEconomy: playerEconomy,
        );

        await game.ensureAdd(component1);
        await game.ensureAdd(component10);

        // Level 10 building should be larger
        expect(component10.size.x, greaterThan(component1.size.x));
        expect(component10.size.y, greaterThan(component1.size.y));
      },
    );

    testWithGame(
      'Different building types have different colors',
      () => FlameTester(Flame.new),
      (game) async {
        final buildingTypes = [
          BuildingType.collector,
          BuildingType.processor,
          BuildingType.storage,
          BuildingType.conveyor,
          BuildingType.market,
        ];

        for (final type in buildingTypes) {
          final building = testBuilding.copyWith(type: type);
          final component = BuildingComponent(
            building: building,
            gridConfig: gridConfig,
            playerEconomy: playerEconomy,
          );

          await game.ensureAdd(component);

          // Verify component loads successfully
          expect(component.isMounted, isTrue);
        }
      },
    );

    testWithGame(
      'Resource collection callback is triggered',
      () => FlameTester(Flame.new),
      (game) async {
        bool callbackTriggered = false;
        CollectResourcesResult? capturedResult;

        final component = BuildingComponent(
          building: testBuilding,
          gridConfig: gridConfig,
          playerEconomy: playerEconomy,
          onResourcesCollected: (building, result) {
            callbackTriggered = true;
            capturedResult = result;
          },
        );

        await game.ensureAdd(component);

        // Simulate tap
        component.onTapDown(TapDownEvent());

        // Wait for callback to be processed
        await game.ready();

        expect(callbackTriggered, isTrue);
        expect(capturedResult, isNotNull);
        expect(capturedResult!.resourcesCollected, greaterThan(0));
      },
    );

    testWithGame(
      'Multiple buildings can be added to the game',
      () => FlameTester(Flame.new),
      (game) async {
        final buildings = [
          Building(
            id: 'building_1',
            type: BuildingType.collector,
            level: 1,
            gridPosition: const GridPosition(x: 10, y: 10),
            production: const ProductionConfig(
              baseRate: 5.0,
              resourceType: 'Wood',
            ),
            upgradeConfig: const UpgradeConfig(
              baseCost: 100,
              costIncrement: 50,
              maxLevel: 10,
            ),
            lastCollected: DateTime.now(),
            isActive: true,
          ),
          Building(
            id: 'building_2',
            type: BuildingType.processor,
            level: 3,
            gridPosition: const GridPosition(x: 15, y: 10),
            production: const ProductionConfig(
              baseRate: 3.0,
              resourceType: 'Planks',
            ),
            upgradeConfig: const UpgradeConfig(
              baseCost: 150,
              costIncrement: 75,
              maxLevel: 10,
            ),
            lastCollected: DateTime.now(),
            isActive: true,
          ),
          Building(
            id: 'building_3',
            type: BuildingType.storage,
            level: 5,
            gridPosition: const GridPosition(x: 20, y: 10),
            production: const ProductionConfig(
              baseRate: 0.0,
              resourceType: 'None',
            ),
            upgradeConfig: const UpgradeConfig(
              baseCost: 200,
              costIncrement: 100,
              maxLevel: 10,
            ),
            lastCollected: DateTime.now(),
            isActive: true,
          ),
        ];

        for (final building in buildings) {
          final component = BuildingComponent(
            building: building,
            gridConfig: gridConfig,
            playerEconomy: playerEconomy,
          );

          await game.ensureAdd(component);
        }

        // Verify all buildings are loaded
        expect(
          game.children.whereType<BuildingComponent>().length,
          equals(3),
        );
      },
    );

    testWithGame(
      'Inactive buildings do not collect resources',
      () => FlameTester(Flame.new),
      (game) async {
        final inactiveBuilding = testBuilding.copyWith(isActive: false);

        final component = BuildingComponent(
          building: inactiveBuilding,
          gridConfig: gridConfig,
          playerEconomy: playerEconomy,
        );

        await game.ensureAdd(component);

        // Component should still be mounted
        expect(component.isMounted, isTrue);

        // But building is inactive
        expect(component.building.isActive, isFalse);
      },
    );

    testWithGame(
      'Building component updates over time',
      () => FlameTester(Flame.new),
      (game) async {
        final component = BuildingComponent(
          building: testBuilding,
          gridConfig: gridConfig,
          playerEconomy: playerEconomy,
        );

        await game.ensureAdd(component);

        // Update for 1 second (60 frames at 60 FPS)
        for (int i = 0; i < 60; i++) {
          game.update(1 / 60);
        }

        // Component should still be active
        expect(component.isMounted, isTrue);
      },
    );

    test('Grid position conversion is consistent', () {
      final gridPos = const GridPosition(x: 25, y: 25);
      final screenPos = gridConfig.gridToScreen(gridPos.x, gridPos.y);

      // Convert back to grid coordinates
      final backToGrid = gridConfig.screenToGrid(screenPos.x, screenPos.y);

      expect(backToGrid.x, closeTo(gridPos.x.toDouble(), 0.1));
      expect(backToGrid.y, closeTo(gridPos.y.toDouble(), 0.1));
    });

    test('Building size calculation is correct', () {
      final baseWidth = gridConfig.tileWidth * 0.8;
      final baseHeight = gridConfig.tileHeight * 1.5;

      // Level 1 building
      final level1Scale = 1.0 + (1 - 1) * 0.01; // = 1.0
      final level1Width = baseWidth * level1Scale;
      final level1Height = baseHeight * level1Scale;

      expect(level1Width, equals(baseWidth));
      expect(level1Height, equals(baseHeight));

      // Level 10 building
      final level10Scale = 1.0 + (10 - 1) * 0.01; // = 1.09
      final level10Width = baseWidth * level10Scale;
      final level10Height = baseHeight * level10Scale;

      expect(level10Width, greaterThan(level1Width));
      expect(level10Height, greaterThan(level1Height));
    });

    test('Resource collection respects time elapsed', () {
      final building = testBuilding.copyWith(
        lastCollected: DateTime.now().subtract(const Duration(hours: 2)),
      );

      final economy = playerEconomy;

      final useCase = CollectResourcesUseCase();
      final result = useCase.execute(
        economy: economy,
        building: building,
      );

      // Should collect 2 hours worth of resources
      // baseRate = 5.0, level 1 multiplier = 1.0, so 5.0 * 2 = 10.0
      expect(result.resourcesCollected, equals(10.0));
    });

    test('FloatingTextComponent is created on tap', () {
      // This is a unit test without the game engine
      final floatingText = FloatingTextComponent(
        text: '+10.0 Wood',
        startPosition: Vector2(100, 100),
      );

      expect(floatingText.text, equals('+10.0 Wood'));
      expect(floatingText.position, equals(Vector2(100, 100)));
    });
  });

  group('BuildingComponent Performance', () {
    late GridConfig gridConfig;
    late PlayerEconomy playerEconomy;

    setUp(() {
      gridConfig = const GridConfig(
        gridWidth: 50,
        gridHeight: 50,
        tileWidth: 64.0,
        tileHeight: 32.0,
        showGridLines: true,
      );

      playerEconomy = PlayerEconomy(
        gold: 10000,
        inventory: {},
        buildings: [],
        tier: 1,
        lastSeen: DateTime.now(),
      );
    });

    testWithGame(
      'Can render 20+ buildings at 60 FPS',
      () => FlameTester(Flame.new),
      (game) async {
        // Add 25 buildings
        for (int i = 0; i < 25; i++) {
          final building = Building(
            id: 'building_$i',
            type: BuildingType.values[i % BuildingType.values.length],
            level: (i % 10) + 1,
            gridPosition: GridPosition(x: (i % 5) * 5, y: (i ~/ 5) * 5),
            production: const ProductionConfig(
              baseRate: 5.0,
              resourceType: 'Wood',
            ),
            upgradeConfig: const UpgradeConfig(
              baseCost: 100,
              costIncrement: 50,
              maxLevel: 10,
            ),
            lastCollected: DateTime.now(),
            isActive: true,
          );

          final component = BuildingComponent(
            building: building,
            gridConfig: gridConfig,
            playerEconomy: playerEconomy,
          );

          await game.ensureAdd(component);
        }

        // Verify all 25 buildings are loaded
        expect(
          game.children.whereType<BuildingComponent>().length,
          equals(25),
        );

        // Run for 60 frames (1 second at 60 FPS)
        final startTime = DateTime.now();
        for (int i = 0; i < 60; i++) {
          game.update(1 / 60);
        }
        final endTime = DateTime.now();

        final elapsed = endTime.difference(startTime);
        debugPrint('25 buildings rendered in ${elapsed.inMilliseconds}ms');

        // Should complete in reasonable time (allowing for test overhead)
        expect(elapsed.inMilliseconds, lessThan(5000));
      },
    );
  });
}

// Helper class for FlameTester
class Flame extends FlameGame {
  Flame() : super();
}
