import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/building.dart';
import 'package:trade_factory_masters/domain/entities/player_economy.dart';
import 'package:trade_factory_masters/domain/usecases/upgrade_building.dart';
import 'package:trade_factory_masters/domain/core/result.dart';

void main() {
  group('UpgradeBuildingUseCase', () {
    late UpgradeBuildingUseCase useCase;
    late PlayerEconomy testEconomy;
    late Building testBuilding;
    late DateTime testTime;

    setUp(() {
      useCase = UpgradeBuildingUseCase();
      testTime = DateTime(2024, 1, 1, 12, 0);

      // Create test building (level 1, upgrade cost = 100)
      testBuilding = Building(
        id: 'mining_1',
        type: BuildingType.mining,
        level: 1,
        gridPosition: const GridPosition(x: 5, y: 5),
        production: const ProductionConfig(
          baseRate: 10.0,
          resourceType: 'wood',
        ),
        upgradeConfig: const UpgradeConfig(
          baseCost: 100,
          costIncrement: 20,
          maxLevel: 10,
        ),
        lastCollected: testTime,
        isActive: true,
      );

      // Create test economy with building and enough gold
      testEconomy = PlayerEconomy(
        gold: 500,
        inventory: const {},
        buildings: [testBuilding],
        tier: 1,
        lastSeen: testTime,
      );
    });

    group('Successful Upgrades', () {
      test('upgrades building from level 1 to level 2', () {
        final result = useCase.execute(
          economy: testEconomy,
          building: testBuilding,
        );

        expect(result.isSuccess, isTrue);
        final economy = result.valueOrNull!;
        final upgradedBuilding = economy.buildings.first;
        expect(upgradedBuilding.level, equals(2));
      });

      test('deducts correct gold amount', () {
        // Level 1→2 cost = baseCost = 100
        final result = useCase.execute(
          economy: testEconomy,
          building: testBuilding,
        );

        expect(result.isSuccess, isTrue);
        final economy = result.valueOrNull!;
        expect(economy.gold, equals(400)); // 500 - 100
      });

      test('upgrades building from level 2 to level 3', () {
        final level2Building = testBuilding.copyWith(level: 2);
        final economyWithLevel2 = testEconomy.copyWith(
          buildings: [level2Building],
        );

        final result = useCase.execute(
          economy: economyWithLevel2,
          building: level2Building,
        );

        expect(result.isSuccess, isTrue);
        final economy = result.valueOrNull!;
        final upgradedBuilding = economy.buildings.first;
        expect(upgradedBuilding.level, equals(3));
      });

      test('calculates cost correctly for level 2→3 upgrade', () {
        // Level 2→3 cost = baseCost + (2-1) × costIncrement = 100 + 20 = 120
        final level2Building = testBuilding.copyWith(level: 2);
        final economyWithLevel2 = testEconomy.copyWith(
          buildings: [level2Building],
        );

        final result = useCase.execute(
          economy: economyWithLevel2,
          building: level2Building,
        );

        expect(result.isSuccess, isTrue);
        final economy = result.valueOrNull!;
        expect(economy.gold, equals(380)); // 500 - 120
      });

      test('calculates cost correctly for level 5→6 upgrade', () {
        // Level 5→6 cost = baseCost + (5-1) × costIncrement = 100 + 80 = 180
        final level5Building = testBuilding.copyWith(level: 5);
        final economyWithLevel5 = testEconomy.copyWith(
          buildings: [level5Building],
        );

        final result = useCase.execute(
          economy: economyWithLevel5,
          building: level5Building,
        );

        expect(result.isSuccess, isTrue);
        final economy = result.valueOrNull!;
        expect(economy.gold, equals(320)); // 500 - 180
      });

      test('preserves all other building properties', () {
        final result = useCase.execute(
          economy: testEconomy,
          building: testBuilding,
        );

        expect(result.isSuccess, isTrue);
        final upgradedBuilding = result.valueOrNull!.buildings.first;

        expect(upgradedBuilding.id, equals(testBuilding.id));
        expect(upgradedBuilding.type, equals(testBuilding.type));
        expect(upgradedBuilding.gridPosition, equals(testBuilding.gridPosition));
        expect(upgradedBuilding.production, equals(testBuilding.production));
        expect(upgradedBuilding.upgradeConfig, equals(testBuilding.upgradeConfig));
        expect(upgradedBuilding.isActive, equals(testBuilding.isActive));
      });

      test('updates correct building in multi-building economy', () {
        final building2 = Building(
          id: 'smelter_1',
          type: BuildingType.smelter,
          level: 3,
          gridPosition: const GridPosition(x: 10, y: 10),
          production: const ProductionConfig(
            baseRate: 8.0,
            resourceType: 'stone',
          ),
          upgradeConfig: const UpgradeConfig(
            baseCost: 150,
            costIncrement: 30,
          ),
          lastCollected: testTime,
          isActive: true,
        );

        final economyWithMultipleBuildings = testEconomy.copyWith(
          buildings: [testBuilding, building2],
        );

        final result = useCase.execute(
          economy: economyWithMultipleBuildings,
          building: testBuilding,
        );

        expect(result.isSuccess, isTrue);
        final economy = result.valueOrNull!;

        // First building should be upgraded
        expect(economy.buildings[0].level, equals(2));
        // Second building should remain unchanged
        expect(economy.buildings[1].level, equals(3));
      });
    });

    group('Validation Errors', () {
      test('fails when building is at max level', () {
        final maxLevelBuilding = testBuilding.copyWith(level: 10);
        final economyWithMaxLevel = testEconomy.copyWith(
          buildings: [maxLevelBuilding],
        );

        final result = useCase.execute(
          economy: economyWithMaxLevel,
          building: maxLevelBuilding,
        );

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, equals(UpgradeError.maxLevelReached));
      });

      test('fails when player has insufficient gold', () {
        final poorEconomy = testEconomy.copyWith(gold: 50); // Need 100

        final result = useCase.execute(
          economy: poorEconomy,
          building: testBuilding,
        );

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, equals(UpgradeError.insufficientGold));
      });

      test('fails when player has exactly one gold less than needed', () {
        final almostEnoughEconomy = testEconomy.copyWith(gold: 99);

        final result = useCase.execute(
          economy: almostEnoughEconomy,
          building: testBuilding,
        );

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, equals(UpgradeError.insufficientGold));
      });

      test('succeeds when player has exact gold amount needed', () {
        final exactGoldEconomy = testEconomy.copyWith(gold: 100);

        final result = useCase.execute(
          economy: exactGoldEconomy,
          building: testBuilding,
        );

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!.gold, equals(0));
      });

      test('fails when building is inactive', () {
        final inactiveBuilding = testBuilding.copyWith(isActive: false);
        final economyWithInactive = testEconomy.copyWith(
          buildings: [inactiveBuilding],
        );

        final result = useCase.execute(
          economy: economyWithInactive,
          building: inactiveBuilding,
        );

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, equals(UpgradeError.buildingInactive));
      });

      test('fails when building not found in economy', () {
        final buildingNotInEconomy = Building(
          id: 'nonexistent_building',
          type: BuildingType.mining,
          level: 1,
          gridPosition: const GridPosition(x: 99, y: 99),
          production: const ProductionConfig(
            baseRate: 10.0,
            resourceType: 'wood',
          ),
          upgradeConfig: const UpgradeConfig(
            baseCost: 100,
            costIncrement: 20,
          ),
          lastCollected: testTime,
          isActive: true,
        );

        final result = useCase.execute(
          economy: testEconomy,
          building: buildingNotInEconomy,
        );

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, equals(UpgradeError.buildingNotFound));
      });
    });

    group('Edge Cases', () {
      test('handles upgrade to max level', () {
        final almostMaxBuilding = testBuilding.copyWith(level: 9);
        final economyWithAlmostMax = testEconomy.copyWith(
          buildings: [almostMaxBuilding],
          gold: 1000,
        );

        final result = useCase.execute(
          economy: economyWithAlmostMax,
          building: almostMaxBuilding,
        );

        expect(result.isSuccess, isTrue);
        final upgradedBuilding = result.valueOrNull!.buildings.first;
        expect(upgradedBuilding.level, equals(10));
      });

      test('cannot upgrade beyond max level', () {
        final maxLevelBuilding = testBuilding.copyWith(level: 10);
        final economyWithMax = testEconomy.copyWith(
          buildings: [maxLevelBuilding],
        );

        final result = useCase.execute(
          economy: economyWithMax,
          building: maxLevelBuilding,
        );

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, equals(UpgradeError.maxLevelReached));
      });

      test('immutability - original economy unchanged on success', () {
        final originalGold = testEconomy.gold;
        final originalBuildingLevel = testEconomy.buildings.first.level;

        useCase.execute(
          economy: testEconomy,
          building: testBuilding,
        );

        expect(testEconomy.gold, equals(originalGold));
        expect(testEconomy.buildings.first.level, equals(originalBuildingLevel));
      });

      test('immutability - original economy unchanged on failure', () {
        final poorEconomy = testEconomy.copyWith(gold: 50);
        final originalGold = poorEconomy.gold;

        useCase.execute(
          economy: poorEconomy,
          building: testBuilding,
        );

        expect(poorEconomy.gold, equals(originalGold));
      });
    });

    group('Result Type Behavior', () {
      test('Result.isSuccess is true for successful upgrade', () {
        final result = useCase.execute(
          economy: testEconomy,
          building: testBuilding,
        );

        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });

      test('Result.isFailure is true for failed upgrade', () {
        final poorEconomy = testEconomy.copyWith(gold: 50);

        final result = useCase.execute(
          economy: poorEconomy,
          building: testBuilding,
        );

        expect(result.isFailure, isTrue);
        expect(result.isSuccess, isFalse);
      });

      test('Result.fold handles success case', () {
        final result = useCase.execute(
          economy: testEconomy,
          building: testBuilding,
        );

        final message = result.fold(
          onSuccess: (economy) => 'Upgraded to level ${economy.buildings.first.level}',
          onFailure: (error) => 'Failed: $error',
        );

        expect(message, equals('Upgraded to level 2'));
      });

      test('Result.fold handles failure case', () {
        final poorEconomy = testEconomy.copyWith(gold: 50);

        final result = useCase.execute(
          economy: poorEconomy,
          building: testBuilding,
        );

        final message = result.fold(
          onSuccess: (economy) => 'Success',
          onFailure: (error) => 'Failed: ${error.name}',
        );

        expect(message, equals('Failed: insufficientGold'));
      });
    });

    group('UpgradeError Messages', () {
      test('maxLevelReached has correct message', () {
        expect(
          UpgradeError.maxLevelReached.message,
          equals('Building is already at maximum level'),
        );
      });

      test('insufficientGold has correct message', () {
        expect(
          UpgradeError.insufficientGold.message,
          equals('Not enough gold to upgrade'),
        );
      });

      test('buildingInactive has correct message', () {
        expect(
          UpgradeError.buildingInactive.message,
          equals('Cannot upgrade inactive building'),
        );
      });

      test('buildingNotFound has correct message', () {
        expect(
          UpgradeError.buildingNotFound.message,
          equals('Building not found in player economy'),
        );
      });
    });
  });
}
