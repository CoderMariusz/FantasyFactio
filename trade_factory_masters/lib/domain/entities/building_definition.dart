import 'package:equatable/equatable.dart';
import 'building.dart';
import 'recipe.dart';
import 'placement_rules.dart';
import 'unlock_condition.dart';
import '../../../config/game_config.dart';

/// Static definition of a building type
/// Contains all properties that define a building (cost, size, recipes, etc.)
class BuildingDefinition extends Equatable {
  /// Unique identifier matching BuildingType
  final String id;

  /// Display name (Polish)
  final String name;

  /// Building type enum value
  final BuildingType type;

  /// Width in grid tiles
  final int width;

  /// Height in grid tiles
  final int height;

  /// Build cost (resource ID → quantity)
  /// Empty map means FREE
  final Map<String, int> buildCost;

  /// Time to build in seconds (0 = instant)
  final double buildTime;

  /// Placement rules for this building
  final PlacementRule placementRule;

  /// Available recipes for this building
  final List<Recipe> recipes;

  /// Condition to unlock this building
  final UnlockCondition unlockCondition;

  /// Storage capacity (for storage buildings only)
  final int? storageCapacity;

  /// Description of the building
  final String description;

  const BuildingDefinition({
    required this.id,
    required this.name,
    required this.type,
    required this.width,
    required this.height,
    required this.buildCost,
    required this.buildTime,
    required this.placementRule,
    required this.recipes,
    required this.unlockCondition,
    this.storageCapacity,
    required this.description,
  });

  /// Check if player can afford to build this
  bool canAfford(Map<String, int> inventory) {
    for (final entry in buildCost.entries) {
      final available = inventory[entry.key] ?? 0;
      if (available < entry.value) {
        return false;
      }
    }
    return true;
  }

  /// Get formatted cost string
  String get costString {
    if (buildCost.isEmpty) return 'FREE';
    return buildCost.entries
        .map((e) => '${e.value} ${e.key}')
        .join(' + ');
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        width,
        height,
        buildCost,
        buildTime,
        placementRule,
        recipes,
        unlockCondition,
        storageCapacity,
      ];
}

/// Repository of all building definitions
/// Provides static access to building data
class BuildingDefinitions {
  BuildingDefinitions._();

  /// Mining Facility - FREE starter building
  /// Gathers resources from biom tiles
  static final miningFacility = BuildingDefinition(
    id: 'mining_facility',
    name: 'Koppalnia',
    type: BuildingType.mining,
    width: 2,
    height: 2,
    buildCost: {}, // FREE
    buildTime: 0,
    placementRule: const BiomRestrictedRule([
      'koppalnia', // Mine biom
      'las', // Forest biom
      'gory', // Mountains biom
      'jezioro', // Lake biom
    ]),
    recipes: [
      // Dynamic - depends on biom placed on
      const Recipe(
        id: 'gather_dynamic',
        name: 'Gather Resources',
        inputs: [], // No inputs needed
        outputs: [ResourceStack(resourceId: 'dynamic', quantity: 1)],
        cycleTime: 1.25, // Base gather speed, modified by biom
        skillModifier: 'mining',
      ),
    ],
    unlockCondition: const UnlockCondition.gameStart(),
    description: 'Gathers resources from the biom. +50% faster than manual gathering.',
  );

  /// Storage - Basic inventory expansion
  /// Stores up to 200 items
  static final storage = BuildingDefinition(
    id: 'storage',
    name: 'Magazyn',
    type: BuildingType.storage,
    width: 2,
    height: 2,
    buildCost: {
      ResourceIds.wood: 5,
      ResourceIds.stone: 10,
    },
    buildTime: 45,
    placementRule: const FlexiblePlacementRule(),
    recipes: [], // Storage doesn't produce
    unlockCondition: const UnlockCondition.gameStart(),
    storageCapacity: 200,
    description: 'Stores up to 200 items. Essential for production chains.',
  );

  /// Smelter - Processes ore into bars
  /// 30 Coal + 30 Iron Ore → 1 Iron Bar (50s)
  static final smelter = BuildingDefinition(
    id: 'smelter',
    name: 'Piec hutniczy',
    type: BuildingType.smelter,
    width: 2,
    height: 3,
    buildCost: {
      ResourceIds.wood: 15,
      ResourceIds.stone: 10,
      ResourceIds.copper: 5,
    },
    buildTime: 70,
    placementRule: const FlexiblePlacementRule(),
    recipes: [
      const Recipe(
        id: 'smelt_iron',
        name: 'Smelt Iron',
        inputs: [
          ResourceStack(resourceId: ResourceIds.coal, quantity: 30),
          ResourceStack(resourceId: ResourceIds.ironOre, quantity: 30),
        ],
        outputs: [
          ResourceStack(resourceId: ResourceIds.ironBar, quantity: 1),
        ],
        cycleTime: 50,
        skillModifier: 'smelting',
      ),
    ],
    unlockCondition: const UnlockCondition.afterAction('smelt_iron_ore', 1),
    description: 'Converts ore and coal into metal bars.',
  );

  /// Conveyor - Transports items between buildings
  /// Note: Full transport mechanics in EPIC-03
  static final conveyor = BuildingDefinition(
    id: 'conveyor',
    name: 'Przenośnik',
    type: BuildingType.conveyor,
    width: 1,
    height: 1,
    buildCost: {
      ResourceIds.wood: 2,
      ResourceIds.ironBar: 1,
    },
    buildTime: 5,
    placementRule: const LayeringRule(maxLayers: 2),
    recipes: [], // Transport only, no production
    unlockCondition: const UnlockCondition.afterAction('smelt_iron_ore', 1),
    description: 'Transports items between buildings. 0.5 items/sec.',
  );

  /// Workshop - Crafts advanced items
  /// 10 Iron Bar → 1 Hammer (62s)
  static final workshop = BuildingDefinition(
    id: 'workshop',
    name: 'Warsztat',
    type: BuildingType.workshop,
    width: 2,
    height: 2,
    buildCost: {
      ResourceIds.wood: 20,
      ResourceIds.stone: 15,
      ResourceIds.ironBar: 5,
    },
    buildTime: 60,
    placementRule: const FlexiblePlacementRule(),
    recipes: [
      const Recipe(
        id: 'craft_hammer',
        name: 'Craft Hammer',
        inputs: [
          ResourceStack(resourceId: ResourceIds.ironBar, quantity: 10),
        ],
        outputs: [
          ResourceStack(resourceId: 'hammer', quantity: 1),
        ],
        cycleTime: 62,
        skillModifier: 'crafting',
      ),
    ],
    unlockCondition: const UnlockCondition.afterAction('craft_any', 5),
    description: 'Crafts tools and advanced items from metal bars.',
  );

  /// Farm Monetyzacyjna - Converts items to gold
  /// Dynamic recipe: any item → gold based on value
  static final farm = BuildingDefinition(
    id: 'farm',
    name: 'Farma Monetyzacyjna',
    type: BuildingType.farm,
    width: 3,
    height: 3,
    buildCost: {
      ResourceIds.coal: 25, // Beton in spec, using coal for now
      ResourceIds.ironBar: 12,
      ResourceIds.wood: 15,
    },
    buildTime: 85,
    placementRule: const FlexiblePlacementRule(),
    recipes: [
      // Dynamic - converts any resource to gold
      const Recipe(
        id: 'monetize_item',
        name: 'Convert to Gold',
        inputs: [ResourceStack(resourceId: 'any', quantity: 1)],
        outputs: [ResourceStack(resourceId: ResourceIds.gold, quantity: 1)],
        cycleTime: 5,
        skillModifier: 'trading',
      ),
    ],
    unlockCondition: const UnlockCondition.afterAction('trade_with_npc', 2),
    description: 'Converts items to gold. Main income source late game.',
  );

  /// Get all building definitions
  static List<BuildingDefinition> get all => [
        miningFacility,
        storage,
        smelter,
        conveyor,
        workshop,
        farm,
      ];

  /// Get building definition by type
  static BuildingDefinition getByType(BuildingType type) {
    switch (type) {
      case BuildingType.mining:
        return miningFacility;
      case BuildingType.storage:
        return storage;
      case BuildingType.smelter:
        return smelter;
      case BuildingType.conveyor:
        return conveyor;
      case BuildingType.workshop:
        return workshop;
      case BuildingType.farm:
        return farm;
    }
  }

  /// Get building definition by ID
  static BuildingDefinition? getById(String id) {
    for (final def in all) {
      if (def.id == id) return def;
    }
    return null;
  }

  /// Get unlocked buildings based on player progress
  static List<BuildingDefinition> getUnlocked({
    required Map<String, int> actionCounts,
    required Map<String, int> skillLevels,
  }) {
    return all.where((def) {
      return def.unlockCondition.isMet(
        actionCounts: actionCounts,
        skillLevels: skillLevels,
      );
    }).toList();
  }
}
