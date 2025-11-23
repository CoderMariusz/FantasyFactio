import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/building.dart';
import 'package:trade_factory_masters/domain/entities/player_economy.dart';
import 'package:trade_factory_masters/domain/entities/resource.dart';
import 'package:trade_factory_masters/domain/usecases/collect_resources.dart';

void main() {
  group('CollectResourcesUseCase', () {
    late CollectResourcesUseCase useCase;
    late PlayerEconomy testEconomy;
    late Building testBuilding;
    late DateTime testTime;

    setUp(() {
      useCase = CollectResourcesUseCase();
      testTime = DateTime(2024, 1, 1, 12, 0); // Noon

      // Create test economy with wood resource
      testEconomy = PlayerEconomy(
        gold: 1000,
        inventory: {
          'wood': const Resource(
            id: 'wood',
            displayName: 'Wood',
            type: ResourceType.tier1,
            amount: 100,
            maxCapacity: 1000,
            iconPath: 'assets/images/resources/wood.png',
          ),
        },
        buildings: [],
        tier: 1,
        lastSeen: testTime,
      );

      // Create test building (Lumbermill, level 1)
      testBuilding = Building(
        id: 'lumbermill_1',
        type: BuildingType.collector,
        level: 1,
        gridPosition: const GridPosition(x: 5, y: 5),
        production: const ProductionConfig(
          baseRate: 10.0, // 10 wood per hour
          resourceType: 'wood',
        ),
        upgradeConfig: const UpgradeConfig(
          baseCost: 100,
          costIncrement: 20,
        ),
        lastCollected: testTime.subtract(const Duration(hours: 1)), // 1 hour ago
        isActive: true,
      );
    });

    group('Basic Collection', () {
      test('collects resources based on elapsed time', () {
        // 1 hour elapsed, baseRate = 10/hour, level 1 multiplier = 1.0
        // Expected: 10 wood
        final result = useCase.execute(
          economy: testEconomy,
          building: testBuilding,
          currentTime: testTime,
        );

        expect(result.resourcesCollected, equals(10));
        expect(result.wasCapped, isFalse);
      });

      test('updates inventory with collected resources', () {
        final result = useCase.execute(
          economy: testEconomy,
          building: testBuilding,
          currentTime: testTime,
        );

        expect(result.economy.inventory['wood']!.amount, equals(110)); // 100 + 10
      });

      test('updates building lastCollected timestamp', () {
        final economyWithBuilding = testEconomy.addBuilding(testBuilding);

        final result = useCase.execute(
          economy: economyWithBuilding,
          building: testBuilding,
          currentTime: testTime,
        );

        final updatedBuilding = result.economy.buildings.first;
        expect(updatedBuilding.lastCollected, equals(testTime));
      });

      test('handles multiple hours elapsed', () {
        // 3 hours elapsed
        final buildingThreeHoursAgo = testBuilding.copyWith(
          lastCollected: testTime.subtract(const Duration(hours: 3)),
        );

        final result = useCase.execute(
          economy: testEconomy,
          building: buildingThreeHoursAgo,
          currentTime: testTime,
        );

        // 3 hours × 10/hour = 30 wood
        expect(result.resourcesCollected, equals(30));
      });

      test('handles fractional hours correctly', () {
        // 30 minutes elapsed (0.5 hours)
        final buildingHalfHourAgo = testBuilding.copyWith(
          lastCollected: testTime.subtract(const Duration(minutes: 30)),
        );

        final result = useCase.execute(
          economy: testEconomy,
          building: buildingHalfHourAgo,
          currentTime: testTime,
        );

        // 0.5 hours × 10/hour = 5 wood
        expect(result.resourcesCollected, equals(5));
      });

      test('handles zero elapsed time', () {
        final buildingNow = testBuilding.copyWith(lastCollected: testTime);

        final result = useCase.execute(
          economy: testEconomy,
          building: buildingNow,
          currentTime: testTime,
        );

        expect(result.resourcesCollected, equals(0));
      });
    });

    group('Production Rate Multipliers', () {
      test('applies level 2 multiplier (1.2×)', () {
        // Level 2: baseRate × 1.2 = 10 × 1.2 = 12/hour
        final level2Building = testBuilding.copyWith(level: 2);

        final result = useCase.execute(
          economy: testEconomy,
          building: level2Building,
          currentTime: testTime,
        );

        // 1 hour × 12/hour = 12 wood
        expect(result.resourcesCollected, equals(12));
      });

      test('applies level 5 multiplier (1.8×)', () {
        // Level 5: baseRate × 1.8 = 10 × 1.8 = 18/hour
        final level5Building = testBuilding.copyWith(level: 5);

        final result = useCase.execute(
          economy: testEconomy,
          building: level5Building,
          currentTime: testTime,
        );

        // 1 hour × 18/hour = 18 wood
        expect(result.resourcesCollected, equals(18));
      });

      test('applies level 10 multiplier (2.8×)', () {
        // Level 10: baseRate × 2.8 = 10 × 2.8 = 28/hour
        final level10Building = testBuilding.copyWith(level: 10);

        final result = useCase.execute(
          economy: testEconomy,
          building: level10Building,
          currentTime: testTime,
        );

        // 1 hour × 28/hour = 28 wood
        expect(result.resourcesCollected, equals(28));
      });
    });

    group('Storage Capacity', () {
      test('caps production at storage capacity', () {
        // Storage capacity = baseRate × 10 = 10 × 10 = 100
        // 20 hours elapsed would produce 200, but capped at 100
        final buildingLongAgo = testBuilding.copyWith(
          lastCollected: testTime.subtract(const Duration(hours: 20)),
        );

        final result = useCase.execute(
          economy: testEconomy,
          building: buildingLongAgo,
          currentTime: testTime,
        );

        expect(result.resourcesCollected, equals(100));
        expect(result.wasCapped, isTrue);
      });

      test('does not cap production below storage capacity', () {
        // 5 hours elapsed = 50 wood (below 100 cap)
        final building5HoursAgo = testBuilding.copyWith(
          lastCollected: testTime.subtract(const Duration(hours: 5)),
        );

        final result = useCase.execute(
          economy: testEconomy,
          building: building5HoursAgo,
          currentTime: testTime,
        );

        expect(result.resourcesCollected, equals(50));
        expect(result.wasCapped, isFalse);
      });

      test('caps exactly at storage capacity', () {
        // 10 hours elapsed = 100 wood (exactly at cap)
        final building10HoursAgo = testBuilding.copyWith(
          lastCollected: testTime.subtract(const Duration(hours: 10)),
        );

        final result = useCase.execute(
          economy: testEconomy,
          building: building10HoursAgo,
          currentTime: testTime,
        );

        expect(result.resourcesCollected, equals(100));
        expect(result.wasCapped, isFalse);
      });

      test('storage capacity scales with base rate', () {
        // Higher base rate building (20/hour)
        final fastBuilding = testBuilding.copyWith(
          production: const ProductionConfig(
            baseRate: 20.0,
            resourceType: 'wood',
          ),
          lastCollected: testTime.subtract(const Duration(hours: 15)),
        );

        final result = useCase.execute(
          economy: testEconomy,
          building: fastBuilding,
          currentTime: testTime,
        );

        // Storage = 20 × 10 = 200
        // 15 hours × 20/hour = 300, capped at 200
        expect(result.resourcesCollected, equals(200));
        expect(result.wasCapped, isTrue);
      });
    });

    group('Inventory Integration', () {
      test('respects player inventory maxCapacity', () {
        // Player inventory nearly full
        final nearlyFullEconomy = testEconomy.copyWith(
          inventory: {
            'wood': const Resource(
              id: 'wood',
              displayName: 'Wood',
              type: ResourceType.tier1,
              amount: 990,
              maxCapacity: 1000,
              iconPath: 'assets/images/resources/wood.png',
            ),
          },
        );

        final result = useCase.execute(
          economy: nearlyFullEconomy,
          building: testBuilding,
          currentTime: testTime,
        );

        // Would add 10, but inventory caps at 1000
        expect(result.economy.inventory['wood']!.amount, equals(1000));
      });

      test('handles resource not in inventory', () {
        // Economy without wood resource
        final economyNoWood = testEconomy.copyWith(
          inventory: const {},
        );

        final result = useCase.execute(
          economy: economyNoWood,
          building: testBuilding,
          currentTime: testTime,
        );

        // Should return economy unchanged (addResource returns same if not found)
        expect(result.economy.inventory, isEmpty);
        expect(result.resourcesCollected, equals(10)); // Still calculates correctly
      });
    });

    group('Building States', () {
      test('does not collect from inactive building', () {
        final inactiveBuilding = testBuilding.copyWith(isActive: false);

        final result = useCase.execute(
          economy: testEconomy,
          building: inactiveBuilding,
          currentTime: testTime,
        );

        expect(result.resourcesCollected, equals(0));
        expect(result.wasCapped, isFalse);
      });

      test('handles building not in economy buildings list', () {
        // Building exists but not in economy.buildings
        final result = useCase.execute(
          economy: testEconomy,
          building: testBuilding,
          currentTime: testTime,
        );

        // Should still add resources to inventory
        expect(result.economy.inventory['wood']!.amount, equals(110));
        expect(result.resourcesCollected, equals(10));
      });

      test('updates correct building when multiple buildings exist', () {
        final building2 = Building(
          id: 'lumbermill_2',
          type: BuildingType.collector,
          level: 1,
          gridPosition: const GridPosition(x: 10, y: 10),
          production: const ProductionConfig(
            baseRate: 10.0,
            resourceType: 'wood',
          ),
          upgradeConfig: const UpgradeConfig(
            baseCost: 100,
            costIncrement: 20,
          ),
          lastCollected: testTime.subtract(const Duration(hours: 2)),
          isActive: true,
        );

        final economyWithBuildings = testEconomy
            .addBuilding(testBuilding)
            .addBuilding(building2);

        final result = useCase.execute(
          economy: economyWithBuildings,
          building: testBuilding,
          currentTime: testTime,
        );

        // Only testBuilding should be updated
        final updatedBuilding1 = result.economy.buildings[0];
        final updatedBuilding2 = result.economy.buildings[1];

        expect(updatedBuilding1.lastCollected, equals(testTime));
        expect(updatedBuilding2.lastCollected, equals(testTime.subtract(const Duration(hours: 2))));
      });
    });

    group('Edge Cases', () {
      test('handles very long elapsed time (days)', () {
        // 100 hours elapsed (4+ days)
        final buildingVeryOld = testBuilding.copyWith(
          lastCollected: testTime.subtract(const Duration(hours: 100)),
        );

        final result = useCase.execute(
          economy: testEconomy,
          building: buildingVeryOld,
          currentTime: testTime,
        );

        // Should be capped at storage capacity (100)
        expect(result.resourcesCollected, equals(100));
        expect(result.wasCapped, isTrue);
      });

      test('handles different resource types', () {
        final stoneEconomy = testEconomy.copyWith(
          inventory: {
            'stone': const Resource(
              id: 'stone',
              displayName: 'Stone',
              type: ResourceType.tier1,
              amount: 50,
              maxCapacity: 1000,
              iconPath: 'assets/images/resources/stone.png',
            ),
          },
        );

        final stoneBuilding = testBuilding.copyWith(
          production: const ProductionConfig(
            baseRate: 8.0,
            resourceType: 'stone',
          ),
        );

        final result = useCase.execute(
          economy: stoneEconomy,
          building: stoneBuilding,
          currentTime: testTime,
        );

        expect(result.resourcesCollected, equals(8));
        expect(result.economy.inventory['stone']!.amount, equals(58));
      });

      test('uses DateTime.now() when currentTime not provided', () {
        // This test verifies the default behavior
        final recentBuilding = testBuilding.copyWith(
          lastCollected: DateTime.now().subtract(const Duration(minutes: 1)),
        );

        final result = useCase.execute(
          economy: testEconomy,
          building: recentBuilding,
        );

        // Should collect small amount (approximately 0-1 wood)
        expect(result.resourcesCollected, greaterThanOrEqualTo(0));
        expect(result.resourcesCollected, lessThanOrEqualTo(1));
      });

      test('immutability - original economy unchanged', () {
        final originalGold = testEconomy.gold;
        final originalInventoryAmount = testEconomy.inventory['wood']!.amount;

        useCase.execute(
          economy: testEconomy,
          building: testBuilding,
          currentTime: testTime,
        );

        expect(testEconomy.gold, equals(originalGold));
        expect(testEconomy.inventory['wood']!.amount, equals(originalInventoryAmount));
      });
    });

    group('CollectResourcesResult', () {
      test('result has correct structure', () {
        final result = useCase.execute(
          economy: testEconomy,
          building: testBuilding,
          currentTime: testTime,
        );

        expect(result, isA<CollectResourcesResult>());
        expect(result.economy, isA<PlayerEconomy>());
        expect(result.resourcesCollected, isA<int>());
        expect(result.wasCapped, isA<bool>());
      });

      test('result toString contains useful info', () {
        final result = useCase.execute(
          economy: testEconomy,
          building: testBuilding,
          currentTime: testTime,
        );

        final str = result.toString();
        expect(str, contains('CollectResourcesResult'));
        expect(str, contains('10')); // resourcesCollected
        expect(str, contains('false')); // wasCapped
      });

      test('result equality works correctly', () {
        final result1 = useCase.execute(
          economy: testEconomy,
          building: testBuilding,
          currentTime: testTime,
        );

        final result2 = useCase.execute(
          economy: testEconomy,
          building: testBuilding,
          currentTime: testTime,
        );

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });
    });
  });
}
