import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/building.dart';
import 'package:trade_factory_masters/domain/entities/building_definition.dart';
import 'package:trade_factory_masters/domain/entities/placement_rules.dart';
import 'package:trade_factory_masters/domain/entities/unlock_condition.dart';
import 'package:trade_factory_masters/config/game_config.dart';

void main() {
  group('BuildingDefinitions', () {
    test('should have exactly 6 buildings defined', () {
      expect(BuildingDefinitions.all.length, equals(6));
    });

    test('all buildings should have unique IDs', () {
      final ids = BuildingDefinitions.all.map((b) => b.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, equals(uniqueIds.length));
    });

    test('all buildings should have valid dimensions (width > 0, height > 0)', () {
      for (final building in BuildingDefinitions.all) {
        expect(building.width, greaterThan(0), reason: '${building.name} width should be > 0');
        expect(building.height, greaterThan(0), reason: '${building.name} height should be > 0');
      }
    });

    test('getByType should return correct building for each type', () {
      expect(BuildingDefinitions.getByType(BuildingType.mining).id, equals('mining_facility'));
      expect(BuildingDefinitions.getByType(BuildingType.storage).id, equals('storage'));
      expect(BuildingDefinitions.getByType(BuildingType.smelter).id, equals('smelter'));
      expect(BuildingDefinitions.getByType(BuildingType.conveyor).id, equals('conveyor'));
      expect(BuildingDefinitions.getByType(BuildingType.workshop).id, equals('workshop'));
      expect(BuildingDefinitions.getByType(BuildingType.farm).id, equals('farm'));
    });

    test('getById should return correct building', () {
      expect(BuildingDefinitions.getById('mining_facility')?.type, equals(BuildingType.mining));
      expect(BuildingDefinitions.getById('storage')?.type, equals(BuildingType.storage));
      expect(BuildingDefinitions.getById('unknown'), isNull);
    });
  });

  group('MiningFacility', () {
    final mining = BuildingDefinitions.miningFacility;

    test('should be FREE (no build cost)', () {
      expect(mining.buildCost, isEmpty);
      expect(mining.costString, equals('FREE'));
    });

    test('should have instant build time', () {
      expect(mining.buildTime, equals(0));
    });

    test('should require biom-restricted placement', () {
      expect(mining.placementRule, isA<BiomRestrictedRule>());
    });

    test('should be unlocked at game start', () {
      expect(mining.unlockCondition.type, equals(UnlockType.gameStart));
      expect(
        mining.unlockCondition.isMet(actionCounts: {}, skillLevels: {}),
        isTrue,
      );
    });

    test('should have 2x2 size', () {
      expect(mining.width, equals(2));
      expect(mining.height, equals(2));
    });
  });

  group('Storage', () {
    final storage = BuildingDefinitions.storage;

    test('should cost 5 Wood + 10 Stone', () {
      expect(storage.buildCost[ResourceIds.wood], equals(5));
      expect(storage.buildCost[ResourceIds.stone], equals(10));
    });

    test('should have 200 item capacity', () {
      expect(storage.storageCapacity, equals(200));
    });

    test('should have flexible placement', () {
      expect(storage.placementRule, isA<FlexiblePlacementRule>());
    });

    test('should be unlocked at game start', () {
      expect(storage.unlockCondition.type, equals(UnlockType.gameStart));
    });
  });

  group('Smelter', () {
    final smelter = BuildingDefinitions.smelter;

    test('should cost 15 Wood + 10 Stone + 5 Copper', () {
      expect(smelter.buildCost[ResourceIds.wood], equals(15));
      expect(smelter.buildCost[ResourceIds.stone], equals(10));
      expect(smelter.buildCost[ResourceIds.copper], equals(5));
    });

    test('should have 70s build time', () {
      expect(smelter.buildTime, equals(70));
    });

    test('should unlock after smelting iron ore once', () {
      expect(smelter.unlockCondition.type, equals(UnlockType.afterAction));
      expect(
        smelter.unlockCondition.isMet(
          actionCounts: {'smelt_iron_ore': 0},
          skillLevels: {},
        ),
        isFalse,
      );
      expect(
        smelter.unlockCondition.isMet(
          actionCounts: {'smelt_iron_ore': 1},
          skillLevels: {},
        ),
        isTrue,
      );
    });

    test('should have iron smelting recipe', () {
      expect(smelter.recipes.length, equals(1));
      final recipe = smelter.recipes.first;
      expect(recipe.id, equals('smelt_iron'));
      expect(recipe.cycleTime, equals(50));
    });

    test('should have 2x3 size', () {
      expect(smelter.width, equals(2));
      expect(smelter.height, equals(3));
    });
  });

  group('Conveyor', () {
    final conveyor = BuildingDefinitions.conveyor;

    test('should cost 2 Wood + 1 Iron Bar', () {
      expect(conveyor.buildCost[ResourceIds.wood], equals(2));
      expect(conveyor.buildCost[ResourceIds.ironBar], equals(1));
    });

    test('should have layering placement rule with max 2 layers', () {
      expect(conveyor.placementRule, isA<LayeringRule>());
      final rule = conveyor.placementRule as LayeringRule;
      expect(rule.maxLayers, equals(2));
    });

    test('should have 1x1 size', () {
      expect(conveyor.width, equals(1));
      expect(conveyor.height, equals(1));
    });
  });

  group('Workshop', () {
    final workshop = BuildingDefinitions.workshop;

    test('should unlock after 5 crafts', () {
      expect(workshop.unlockCondition.type, equals(UnlockType.afterAction));
      expect(
        workshop.unlockCondition.isMet(
          actionCounts: {'craft_any': 4},
          skillLevels: {},
        ),
        isFalse,
      );
      expect(
        workshop.unlockCondition.isMet(
          actionCounts: {'craft_any': 5},
          skillLevels: {},
        ),
        isTrue,
      );
    });

    test('should have hammer crafting recipe', () {
      expect(workshop.recipes.length, equals(1));
      final recipe = workshop.recipes.first;
      expect(recipe.id, equals('craft_hammer'));
      expect(recipe.cycleTime, equals(62));
    });
  });

  group('Farm', () {
    final farm = BuildingDefinitions.farm;

    test('should unlock after trading with 2 NPCs', () {
      expect(farm.unlockCondition.type, equals(UnlockType.afterAction));
      expect(
        farm.unlockCondition.isMet(
          actionCounts: {'trade_with_npc': 1},
          skillLevels: {},
        ),
        isFalse,
      );
      expect(
        farm.unlockCondition.isMet(
          actionCounts: {'trade_with_npc': 2},
          skillLevels: {},
        ),
        isTrue,
      );
    });

    test('should have 3x3 size (largest building)', () {
      expect(farm.width, equals(3));
      expect(farm.height, equals(3));
    });
  });

  group('PlacementRules', () {
    test('BiomRestrictedRule should only allow specified bioms', () {
      final rule = const BiomRestrictedRule(['koppalnia', 'las']);

      expect(
        rule.canPlace(tileBiom: 'koppalnia', isOccupied: false, currentLayers: 0),
        isTrue,
      );
      expect(
        rule.canPlace(tileBiom: 'las', isOccupied: false, currentLayers: 0),
        isTrue,
      );
      expect(
        rule.canPlace(tileBiom: 'gory', isOccupied: false, currentLayers: 0),
        isFalse,
      );
      expect(
        rule.canPlace(tileBiom: 'koppalnia', isOccupied: true, currentLayers: 0),
        isFalse,
      );
    });

    test('FlexiblePlacementRule should allow any unoccupied tile', () {
      const rule = FlexiblePlacementRule();

      expect(
        rule.canPlace(tileBiom: 'empty', isOccupied: false, currentLayers: 0),
        isTrue,
      );
      expect(
        rule.canPlace(tileBiom: 'koppalnia', isOccupied: false, currentLayers: 0),
        isTrue,
      );
      expect(
        rule.canPlace(tileBiom: 'empty', isOccupied: true, currentLayers: 0),
        isFalse,
      );
    });

    test('LayeringRule should respect max layers', () {
      const rule = LayeringRule(maxLayers: 2);

      expect(
        rule.canPlace(tileBiom: 'any', isOccupied: true, currentLayers: 0),
        isTrue,
      );
      expect(
        rule.canPlace(tileBiom: 'any', isOccupied: true, currentLayers: 1),
        isTrue,
      );
      expect(
        rule.canPlace(tileBiom: 'any', isOccupied: true, currentLayers: 2),
        isFalse,
      );
    });
  });

  group('Recipe', () {
    test('canExecute should check inventory', () {
      final recipe = BuildingDefinitions.smelter.recipes.first;

      // Not enough resources
      expect(
        recipe.canExecute({ResourceIds.coal: 10, ResourceIds.ironOre: 10}),
        isFalse,
      );

      // Exactly enough
      expect(
        recipe.canExecute({ResourceIds.coal: 30, ResourceIds.ironOre: 30}),
        isTrue,
      );

      // More than enough
      expect(
        recipe.canExecute({ResourceIds.coal: 100, ResourceIds.ironOre: 100}),
        isTrue,
      );
    });
  });

  group('BuildingDefinition.canAfford', () {
    test('should return true for FREE buildings', () {
      final mining = BuildingDefinitions.miningFacility;
      expect(mining.canAfford({}), isTrue);
    });

    test('should check resource requirements', () {
      final storage = BuildingDefinitions.storage;

      // Not enough
      expect(storage.canAfford({ResourceIds.wood: 2, ResourceIds.stone: 5}), isFalse);

      // Exactly enough
      expect(storage.canAfford({ResourceIds.wood: 5, ResourceIds.stone: 10}), isTrue);

      // More than enough
      expect(storage.canAfford({ResourceIds.wood: 100, ResourceIds.stone: 100}), isTrue);
    });
  });

  group('getUnlocked', () {
    test('should return only game start buildings for new player', () {
      final unlocked = BuildingDefinitions.getUnlocked(
        actionCounts: {},
        skillLevels: {},
      );

      expect(unlocked.length, equals(2)); // mining + storage
      expect(unlocked.any((b) => b.id == 'mining_facility'), isTrue);
      expect(unlocked.any((b) => b.id == 'storage'), isTrue);
    });

    test('should unlock smelter and conveyor after first smelt', () {
      final unlocked = BuildingDefinitions.getUnlocked(
        actionCounts: {'smelt_iron_ore': 1},
        skillLevels: {},
      );

      expect(unlocked.any((b) => b.id == 'smelter'), isTrue);
      expect(unlocked.any((b) => b.id == 'conveyor'), isTrue);
    });

    test('should unlock workshop after 5 crafts', () {
      final unlocked = BuildingDefinitions.getUnlocked(
        actionCounts: {'craft_any': 5},
        skillLevels: {},
      );

      expect(unlocked.any((b) => b.id == 'workshop'), isTrue);
    });

    test('should unlock farm after 2 NPC trades', () {
      final unlocked = BuildingDefinitions.getUnlocked(
        actionCounts: {'trade_with_npc': 2},
        skillLevels: {},
      );

      expect(unlocked.any((b) => b.id == 'farm'), isTrue);
    });
  });
}
