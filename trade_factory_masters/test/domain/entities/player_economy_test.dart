import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/player_economy.dart';
import 'package:trade_factory_masters/domain/entities/resource.dart';
import 'package:trade_factory_masters/domain/entities/building.dart';

void main() {
  group('PlayerEconomy', () {
    late DateTime testTime;
    late PlayerEconomy testEconomy;

    setUp(() {
      testTime = DateTime(2024, 1, 1, 12, 0);
      testEconomy = PlayerEconomy(
        gold: 5000,
        tier: 2,
        inventory: {
          'wood': const Resource(
            id: 'wood',
            displayName: 'Wood',
            type: ResourceType.tier1,
            amount: 500,
            maxCapacity: 1000,
            iconPath: 'assets/images/resources/wood.png',
          ),
          'stone': const Resource(
            id: 'stone',
            displayName: 'Stone',
            type: ResourceType.tier1,
            amount: 300,
            maxCapacity: 1000,
            iconPath: 'assets/images/resources/stone.png',
          ),
        },
        buildings: [],
        lastSeen: testTime,
      );
    });

    test('creates with default values', () {
      final economy = PlayerEconomy(lastSeen: testTime);

      expect(economy.gold, equals(1000));
      expect(economy.tier, equals(1));
      expect(economy.inventory, isEmpty);
      expect(economy.buildings, isEmpty);
    });

    test('creates with custom values', () {
      expect(testEconomy.gold, equals(5000));
      expect(testEconomy.tier, equals(2));
      expect(testEconomy.inventory.length, equals(2));
      expect(testEconomy.buildings, isEmpty);
      expect(testEconomy.lastSeen, equals(testTime));
    });

    group('canAfford', () {
      test('returns true when gold is sufficient', () {
        expect(testEconomy.canAfford(3000), isTrue);
      });

      test('returns true when gold is exact amount', () {
        expect(testEconomy.canAfford(5000), isTrue);
      });

      test('returns false when gold is insufficient', () {
        expect(testEconomy.canAfford(6000), isFalse);
      });

      test('returns true for 0 cost', () {
        expect(testEconomy.canAfford(0), isTrue);
      });
    });

    group('addResource', () {
      test('adds resources correctly', () {
        final updated = testEconomy.addResource('wood', 200);

        expect(updated.inventory['wood']!.amount, equals(700));
        expect(testEconomy.inventory['wood']!.amount, equals(500)); // Original unchanged
      });

      test('respects maxCapacity limit', () {
        final updated = testEconomy.addResource('wood', 800);

        // Should clamp to maxCapacity (1000)
        expect(updated.inventory['wood']!.amount, equals(1000));
      });

      test('creates new resource if not in inventory', () {
        final updated = testEconomy.addResource('iron', 100);

        expect(updated.inventory.containsKey('iron'), isTrue);
        expect(updated.inventory['iron']!.amount, equals(100));
        expect(testEconomy.inventory.containsKey('iron'), isFalse); // Original unchanged
      });

      test('handles adding to full resource', () {
        final fullEconomy = testEconomy.copyWith(
          inventory: {
            'wood': const Resource(
              id: 'wood',
              displayName: 'Wood',
              type: ResourceType.tier1,
              amount: 1000,
              maxCapacity: 1000,
              iconPath: 'assets/images/resources/wood.png',
            ),
          },
        );

        final updated = fullEconomy.addResource('wood', 500);

        expect(updated.inventory['wood']!.amount, equals(1000));
      });

      test('immutability - original economy unchanged', () {
        final original = testEconomy.inventory['wood']!.amount;
        testEconomy.addResource('wood', 100);

        expect(testEconomy.inventory['wood']!.amount, equals(original));
      });
    });

    group('deductGold', () {
      test('deducts gold correctly', () {
        final updated = testEconomy.deductGold(2000);

        expect(updated.gold, equals(3000));
        expect(testEconomy.gold, equals(5000)); // Original unchanged
      });

      test('allows gold to go negative', () {
        final updated = testEconomy.deductGold(6000);

        expect(updated.gold, equals(-1000));
      });

      test('immutability - original economy unchanged', () {
        testEconomy.deductGold(1000);

        expect(testEconomy.gold, equals(5000));
      });
    });

    group('addGold', () {
      test('adds gold correctly', () {
        final updated = testEconomy.addGold(1500);

        expect(updated.gold, equals(6500));
        expect(testEconomy.gold, equals(5000)); // Original unchanged
      });

      test('handles large amounts', () {
        final updated = testEconomy.addGold(1000000);

        expect(updated.gold, equals(1005000));
      });
    });

    group('deductResource', () {
      test('deducts resources correctly', () {
        final updated = testEconomy.deductResource('wood', 200);

        expect(updated.inventory['wood']!.amount, equals(300));
        expect(testEconomy.inventory['wood']!.amount, equals(500)); // Original unchanged
      });

      test('clamps to 0 minimum', () {
        final updated = testEconomy.deductResource('wood', 800);

        expect(updated.inventory['wood']!.amount, equals(0));
      });

      test('returns same economy if resource not in inventory', () {
        final updated = testEconomy.deductResource('iron', 100);

        expect(updated, equals(testEconomy));
      });

      test('immutability - original economy unchanged', () {
        testEconomy.deductResource('wood', 100);

        expect(testEconomy.inventory['wood']!.amount, equals(500));
      });
    });

    group('addBuilding', () {
      test('adds building to empty list', () {
        final building = Building(
          id: 'mining_1',
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

        final updated = testEconomy.addBuilding(building);

        expect(updated.buildings.length, equals(1));
        expect(updated.buildings[0].id, equals('mining_1'));
        expect(testEconomy.buildings, isEmpty); // Original unchanged
      });

      test('adds building to existing list', () {
        final building1 = Building(
          id: 'mining_1',
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

        final building2 = Building(
          id: 'storage_1',
          type: BuildingType.storage,
          level: 1,
          gridPosition: const GridPosition(x: 10, y: 10),
          production: const ProductionConfig(
            baseRate: 0.0,
            resourceType: 'none',
          ),
          upgradeConfig: const UpgradeConfig(
            baseCost: 50,
            costIncrement: 10,
          ),
          lastCollected: testTime,
        );

        final updated = testEconomy.addBuilding(building1).addBuilding(building2);

        expect(updated.buildings.length, equals(2));
      });
    });

    group('copyWith', () {
      test('creates copy with updated gold', () {
        final updated = testEconomy.copyWith(gold: 10000);

        expect(updated.gold, equals(10000));
        expect(updated.tier, equals(testEconomy.tier));
        expect(updated.inventory, equals(testEconomy.inventory));
      });

      test('creates copy with updated tier', () {
        final updated = testEconomy.copyWith(tier: 3);

        expect(updated.tier, equals(3));
        expect(updated.gold, equals(testEconomy.gold));
      });

      test('creates copy with updated inventory', () {
        final newInventory = {
          'iron': const Resource(
            id: 'iron',
            displayName: 'Iron',
            type: ResourceType.tier1,
            amount: 100,
            maxCapacity: 1000,
            iconPath: 'assets/images/resources/iron.png',
          ),
        };

        final updated = testEconomy.copyWith(inventory: newInventory);

        expect(updated.inventory.length, equals(1));
        expect(updated.inventory.containsKey('iron'), isTrue);
        expect(testEconomy.inventory.length, equals(2)); // Original unchanged
      });

      test('creates identical copy when no parameters provided', () {
        final copy = testEconomy.copyWith();

        expect(copy.gold, equals(testEconomy.gold));
        expect(copy.tier, equals(testEconomy.tier));
        expect(copy.inventory, equals(testEconomy.inventory));
        expect(copy.buildings, equals(testEconomy.buildings));
      });
    });

    group('equality', () {
      test('equal economies have same hash code', () {
        final economy1 = PlayerEconomy(
          gold: 1000,
          tier: 1,
          inventory: const {},
          buildings: const [],
          lastSeen: testTime,
        );

        final economy2 = PlayerEconomy(
          gold: 1000,
          tier: 1,
          inventory: const {},
          buildings: const [],
          lastSeen: testTime,
        );

        expect(economy1, equals(economy2));
        expect(economy1.hashCode, equals(economy2.hashCode));
      });

      test('different economies are not equal', () {
        final economy1 = PlayerEconomy(
          gold: 1000,
          tier: 1,
          inventory: const {},
          buildings: const [],
          lastSeen: testTime,
        );

        final economy2 = PlayerEconomy(
          gold: 2000,
          tier: 1,
          inventory: const {},
          buildings: const [],
          lastSeen: testTime,
        );

        expect(economy1, isNot(equals(economy2)));
      });
    });

    test('toString returns formatted string', () {
      final str = testEconomy.toString();

      expect(str, contains('5000'));
      expect(str, contains('2')); // tier
      expect(str, contains('2')); // resources count
    });

    group('immutability validation', () {
      test('state transitions create new instances', () {
        final original = testEconomy;
        final afterGold = testEconomy.deductGold(1000);
        final afterResource = afterGold.addResource('wood', 100);

        expect(original.gold, equals(5000));
        expect(afterGold.gold, equals(4000));
        expect(afterResource.gold, equals(4000));
        expect(afterResource.inventory['wood']!.amount, equals(600));
        expect(original.inventory['wood']!.amount, equals(500));
      });
    });
  });
}
