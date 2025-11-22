import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'building.g.dart';

/// Production configuration for a building
/// Defines base production rate and resource type
@HiveType(typeId: 6)
class ProductionConfig extends Equatable {
  /// Base production rate per hour
  @HiveField(0)
  final double baseRate;

  /// Resource type produced by this building
  @HiveField(1)
  final String resourceType;

  const ProductionConfig({
    required this.baseRate,
    required this.resourceType,
  });

  @override
  List<Object?> get props => [baseRate, resourceType];
}

/// Upgrade configuration for building progression
/// Defines cost scaling for building upgrades
@HiveType(typeId: 7)
class UpgradeConfig extends Equatable {
  /// Base cost for level 1 upgrade
  @HiveField(0)
  final int baseCost;

  /// Cost increment per level (linear scaling Tier 1)
  @HiveField(1)
  final int costIncrement;

  /// Maximum level for this building
  @HiveField(2)
  final int maxLevel;

  const UpgradeConfig({
    required this.baseCost,
    required this.costIncrement,
    this.maxLevel = 10,
  });

  @override
  List<Object?> get props => [baseCost, costIncrement, maxLevel];
}

/// Building entity for Trade Factory Masters
/// Represents a factory building on the grid with production and upgrade logic
@HiveType(typeId: 2)
class Building extends Equatable {
  /// Unique identifier for this building instance
  @HiveField(0)
  final String id;

  /// Type of building (collector, processor, storage, etc.)
  @HiveField(1)
  final BuildingType type;

  /// Current level (1-10, affects production rate)
  @HiveField(2)
  final int level;

  /// Grid position where building is placed
  @HiveField(3)
  final GridPosition gridPosition;

  /// Production configuration (base rate, resource type)
  @HiveField(4)
  final ProductionConfig production;

  /// Upgrade cost configuration
  @HiveField(5)
  final UpgradeConfig upgradeConfig;

  /// Last time resources were collected from this building
  @HiveField(6)
  final DateTime lastCollected;

  /// Whether building is currently active
  @HiveField(7)
  final bool isActive;

  const Building({
    required this.id,
    required this.type,
    this.level = 1,
    required this.gridPosition,
    required this.production,
    required this.upgradeConfig,
    required this.lastCollected,
    this.isActive = true,
  });

  /// Calculate production rate based on level
  /// Formula: baseRate × [1 + (level-1) × 0.2]
  /// Level 1: baseRate × 1.0
  /// Level 2: baseRate × 1.2
  /// Level 5: baseRate × 1.8
  double get productionRate =>
      production.baseRate * (1 + (level - 1) * 0.2);

  /// Calculate cost to upgrade to next level
  /// Linear scaling: baseCost + (level-1) × costIncrement
  /// Level 1→2: baseCost
  /// Level 2→3: baseCost + costIncrement
  int calculateUpgradeCost() {
    return upgradeConfig.baseCost +
        (level - 1) * upgradeConfig.costIncrement;
  }

  /// Check if building can be upgraded
  /// Returns false if:
  /// - Already at max level
  /// - Player doesn't have enough gold
  /// - Building is inactive
  bool canUpgrade(int playerGold) {
    if (!isActive) return false;
    if (level >= upgradeConfig.maxLevel) return false;
    return playerGold >= calculateUpgradeCost();
  }

  /// Create a copy with modified fields
  Building copyWith({
    String? id,
    BuildingType? type,
    int? level,
    GridPosition? gridPosition,
    ProductionConfig? production,
    UpgradeConfig? upgradeConfig,
    DateTime? lastCollected,
    bool? isActive,
  }) {
    return Building(
      id: id ?? this.id,
      type: type ?? this.type,
      level: level ?? this.level,
      gridPosition: gridPosition ?? this.gridPosition,
      production: production ?? this.production,
      upgradeConfig: upgradeConfig ?? this.upgradeConfig,
      lastCollected: lastCollected ?? this.lastCollected,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        level,
        gridPosition,
        production,
        upgradeConfig,
        lastCollected,
        isActive,
      ];

  @override
  String toString() =>
      'Building(id: $id, type: $type, level: $level, position: $gridPosition)';
}

/// Building type enum
/// Defines different types of buildings in the factory
@HiveType(typeId: 3)
enum BuildingType {
  /// Collects raw resources from the grid
  @HiveField(0)
  collector,

  /// Processes raw resources into refined materials
  @HiveField(1)
  processor,

  /// Stores resources for later use
  @HiveField(2)
  storage,

  /// Transports resources between buildings
  @HiveField(3)
  conveyor,

  /// Trades resources with NPC market
  @HiveField(4)
  market,
}

/// Grid position for building placement
/// Represents x,y coordinates on the 50×50 grid
@HiveType(typeId: 4)
class GridPosition extends Equatable {
  /// X coordinate (0-49)
  @HiveField(0)
  final int x;

  /// Y coordinate (0-49)
  @HiveField(1)
  final int y;

  const GridPosition({
    required this.x,
    required this.y,
  });

  @override
  List<Object?> get props => [x, y];

  @override
  String toString() => 'GridPosition(x: $x, y: $y)';
}
