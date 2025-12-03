import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/building.dart';

void main() {
  group('ProductionConfig', () {
    test('creates instance with correct properties', () {
      const config = ProductionConfig(
        baseRate: 10.0,
        resourceType: 'wood',
      );

      expect(config.baseRate, equals(10.0));
      expect(config.resourceType, equals('wood'));
    });

    test('equality works correctly', () {
      const config1 = ProductionConfig(
        baseRate: 10.0,
        resourceType: 'wood',
      );
      const config2 = ProductionConfig(
        baseRate: 10.0,
        resourceType: 'wood',
      );
      const config3 = ProductionConfig(
        baseRate: 15.0,
        resourceType: 'wood',
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });
  });

  group('UpgradeConfig', () {
    test('creates instance with default maxLevel', () {
      const config = UpgradeConfig(
        baseCost: 100,
        costIncrement: 20,
      );

      expect(config.baseCost, equals(100));
      expect(config.costIncrement, equals(20));
      expect(config.maxLevel, equals(10));
    });

    test('creates instance with custom maxLevel', () {
      const config = UpgradeConfig(
        baseCost: 100,
        costIncrement: 20,
        maxLevel: 15,
      );

      expect(config.maxLevel, equals(15));
    });

    test('equality works correctly', () {
      const config1 = UpgradeConfig(
        baseCost: 100,
        costIncrement: 20,
      );
      const config2 = UpgradeConfig(
        baseCost: 100,
        costIncrement: 20,
      );
      const config3 = UpgradeConfig(
        baseCost: 150,
        costIncrement: 20,
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });
  });

  group('GridPosition', () {
    test('creates instance with correct coordinates', () {
      const position = GridPosition(x: 5, y: 10);

      expect(position.x, equals(5));
      expect(position.y, equals(10));
    });

    test('equality works correctly', () {
      const pos1 = GridPosition(x: 5, y: 10);
      const pos2 = GridPosition(x: 5, y: 10);
      const pos3 = GridPosition(x: 6, y: 10);

      expect(pos1, equals(pos2));
      expect(pos1, isNot(equals(pos3)));
    });

    test('toString returns formatted string', () {
      const position = GridPosition(x: 5, y: 10);
      expect(position.toString(), equals('GridPosition(x: 5, y: 10)'));
    });
  });

  group('Building', () {
    late Building testBuilding;
    late DateTime testTime;

    setUp(() {
      testTime = DateTime(2024, 1, 1, 12, 0);
      testBuilding = Building(
        id: 'building_1',
        type: BuildingType.mining,
        level: 1,
        gridPosition: const GridPosition(x: 5, y: 10),
        production: const ProductionConfig(
          baseRate: 10.0,
          resourceType: 'wood',
        ),
        upgradeConfig: const UpgradeConfig(
          baseCost: 100,
          costIncrement: 20,
        ),
        lastCollected: testTime,
      );
    });

    group('productionRate', () {
      test('calculates correctly for level 1', () {
        final building = testBuilding.copyWith(level: 1);
        // baseRate × [1 + (1-1) × 0.2] = 10.0 × 1.0 = 10.0
        expect(building.productionRate, equals(10.0));
      });

      test('calculates correctly for level 3', () {
        final building = testBuilding.copyWith(level: 3);
        // baseRate × [1 + (3-1) × 0.2] = 10.0 × 1.4 = 14.0
        expect(building.productionRate, equals(14.0));
      });

      test('calculates correctly for level 5', () {
        final building = testBuilding.copyWith(level: 5);
        // baseRate × [1 + (5-1) × 0.2] = 10.0 × 1.8 = 18.0
        expect(building.productionRate, equals(18.0));
      });

      test('calculates correctly for level 10', () {
        final building = testBuilding.copyWith(level: 10);
        // baseRate × [1 + (10-1) × 0.2] = 10.0 × 2.8 = 28.0
        expect(building.productionRate, equals(28.0));
      });
    });

    group('calculateUpgradeCost', () {
      test('calculates correctly for level 1 (upgrade to 2)', () {
        final building = testBuilding.copyWith(level: 1);
        // baseCost + (1-1) × costIncrement = 100 + 0 = 100
        expect(building.calculateUpgradeCost(), equals(100));
      });

      test('calculates correctly for level 2 (upgrade to 3)', () {
        final building = testBuilding.copyWith(level: 2);
        // baseCost + (2-1) × costIncrement = 100 + 20 = 120
        expect(building.calculateUpgradeCost(), equals(120));
      });

      test('calculates correctly for level 5 (upgrade to 6)', () {
        final building = testBuilding.copyWith(level: 5);
        // baseCost + (5-1) × costIncrement = 100 + 80 = 180
        expect(building.calculateUpgradeCost(), equals(180));
      });

      test('linear scaling validation', () {
        // Verify linear scaling across multiple levels
        for (int level = 1; level <= 10; level++) {
          final building = testBuilding.copyWith(level: level);
          final expectedCost = 100 + (level - 1) * 20;
          expect(
            building.calculateUpgradeCost(),
            equals(expectedCost),
            reason: 'Level $level cost should be $expectedCost',
          );
        }
      });
    });

    group('canUpgrade', () {
      test('returns false if insufficient gold', () {
        final building = testBuilding.copyWith(level: 1);
        // Upgrade costs 100, but player has only 50
        expect(building.canUpgrade(50), isFalse);
      });

      test('returns true if sufficient gold', () {
        final building = testBuilding.copyWith(level: 1);
        // Upgrade costs 100, player has 150
        expect(building.canUpgrade(150), isTrue);
      });

      test('returns true if exact gold amount', () {
        final building = testBuilding.copyWith(level: 1);
        // Upgrade costs 100, player has exactly 100
        expect(building.canUpgrade(100), isTrue);
      });

      test('returns false if building is at max level', () {
        final building = testBuilding.copyWith(level: 10);
        // Even with enough gold, can't upgrade past max level
        expect(building.canUpgrade(1000), isFalse);
      });

      test('returns false if building is inactive', () {
        final building = testBuilding.copyWith(level: 1, isActive: false);
        // Even with enough gold, can't upgrade inactive building
        expect(building.canUpgrade(150), isFalse);
      });

      test('respects custom maxLevel', () {
        final customUpgradeConfig = const UpgradeConfig(
          baseCost: 100,
          costIncrement: 20,
          maxLevel: 5,
        );
        final building = testBuilding.copyWith(
          level: 5,
          upgradeConfig: customUpgradeConfig,
        );
        expect(building.canUpgrade(1000), isFalse);
      });
    });

    group('copyWith', () {
      test('creates new instance with updated level', () {
        final updated = testBuilding.copyWith(level: 3);

        expect(updated.level, equals(3));
        expect(updated.id, equals(testBuilding.id));
        expect(updated.type, equals(testBuilding.type));
      });

      test('creates new instance with updated isActive', () {
        final updated = testBuilding.copyWith(isActive: false);

        expect(updated.isActive, isFalse);
        expect(updated.id, equals(testBuilding.id));
      });

      test('returns identical copy if no changes', () {
        final copy = testBuilding.copyWith();

        expect(copy.id, equals(testBuilding.id));
        expect(copy.level, equals(testBuilding.level));
        expect(copy.type, equals(testBuilding.type));
      });
    });

    group('equality', () {
      test('equal buildings have same hash code', () {
        final building1 = Building(
          id: 'test_1',
          type: BuildingType.mining,
          level: 1,
          gridPosition: const GridPosition(x: 0, y: 0),
          production: const ProductionConfig(
            baseRate: 10.0,
            resourceType: 'wood',
          ),
          upgradeConfig: const UpgradeConfig(
            baseCost: 100,
            costIncrement: 20,
          ),
          lastCollected: testTime,
        );

        final building2 = Building(
          id: 'test_1',
          type: BuildingType.mining,
          level: 1,
          gridPosition: const GridPosition(x: 0, y: 0),
          production: const ProductionConfig(
            baseRate: 10.0,
            resourceType: 'wood',
          ),
          upgradeConfig: const UpgradeConfig(
            baseCost: 100,
            costIncrement: 20,
          ),
          lastCollected: testTime,
        );

        expect(building1, equals(building2));
        expect(building1.hashCode, equals(building2.hashCode));
      });

      test('different buildings are not equal', () {
        final building1 = testBuilding;
        final building2 = testBuilding.copyWith(id: 'different_id');

        expect(building1, isNot(equals(building2)));
      });
    });

    test('toString returns formatted string', () {
      final str = testBuilding.toString();
      expect(str, contains('Building'));
      expect(str, contains('building_1'));
      expect(str, contains('mining'));
      expect(str, contains('level: 1'));
    });

    test('creates building with default values', () {
      final building = Building(
        id: 'test',
        type: BuildingType.storage,
        gridPosition: const GridPosition(x: 0, y: 0),
        production: const ProductionConfig(
          baseRate: 5.0,
          resourceType: 'stone',
        ),
        upgradeConfig: const UpgradeConfig(
          baseCost: 50,
          costIncrement: 10,
        ),
        lastCollected: testTime,
      );

      expect(building.level, equals(1)); // Default level
      expect(building.isActive, isTrue); // Default isActive
    });
  });

  group('BuildingType', () {
    test('has all expected types', () {
      expect(BuildingType.values, hasLength(6));
      expect(BuildingType.values, contains(BuildingType.mining));
      expect(BuildingType.values, contains(BuildingType.smelter));
      expect(BuildingType.values, contains(BuildingType.storage));
      expect(BuildingType.values, contains(BuildingType.conveyor));
      expect(BuildingType.values, contains(BuildingType.workshop));
      expect(BuildingType.values, contains(BuildingType.farm));
    });
  });
}
