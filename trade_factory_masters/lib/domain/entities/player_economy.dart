import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'resource.dart';
import 'building.dart';

part 'player_economy.g.dart';

/// PlayerEconomy entity for Trade Factory Masters
/// Represents player's economic state (gold, resources, buildings, progression tier)
/// Immutable - all state transitions create new instances
@HiveType(typeId: 5)
class PlayerEconomy extends Equatable {
  /// Player's gold currency
  @HiveField(0)
  final int gold;

  /// Resource inventory (resourceId → Resource)
  /// Stored as Map for O(1) lookup
  @HiveField(1)
  final Map<String, Resource> inventory;

  /// Buildings placed on the grid
  @HiveField(2)
  final List<Building> buildings;

  /// Current progression tier (1, 2, 3)
  /// Determines which resources/buildings are unlocked
  @HiveField(3)
  final int tier;

  /// Last time player was active (for offline production)
  @HiveField(4)
  final DateTime lastSeen;

  const PlayerEconomy({
    this.gold = 1000, // Starting gold
    this.inventory = const {},
    this.buildings = const [],
    this.tier = 1, // Start at Tier 1
    required this.lastSeen,
  });

  /// Check if player can afford a purchase
  /// Returns true if gold >= goldCost
  bool canAfford(int goldCost) => gold >= goldCost;

  /// Add resources to inventory (respects maxCapacity)
  /// Returns new PlayerEconomy instance with updated inventory
  /// If resource doesn't exist in inventory, creates it with default values
  /// If adding would exceed maxCapacity, clamps to max
  PlayerEconomy addResource(String resourceId, int amountToAdd) {
    final updatedInventory = Map<String, Resource>.from(inventory);

    if (!inventory.containsKey(resourceId)) {
      // Resource not in inventory yet - create new one with defaults
      final newResource = Resource(
        id: resourceId,
        displayName: _capitalizeResourceName(resourceId),
        type: ResourceType.tier1,
        amount: min(amountToAdd, 1000), // Default maxCapacity is 1000
        maxCapacity: 1000,
        iconPath: 'assets/images/resources/$resourceId.png',
      );
      updatedInventory[resourceId] = newResource;
      return copyWith(inventory: updatedInventory);
    }

    final resource = inventory[resourceId]!;
    final newAmount = min(
      resource.amount + amountToAdd,
      resource.maxCapacity,
    );

    final updatedResource = resource.copyWith(amount: newAmount);
    updatedInventory[resourceId] = updatedResource;

    return copyWith(inventory: updatedInventory);
  }

  /// Helper to capitalize resource name for display
  /// e.g., "wood" -> "Wood", "iron_ore" -> "Iron Ore"
  static String _capitalizeResourceName(String resourceId) {
    return resourceId
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  /// Deduct gold from player's balance
  /// Returns new PlayerEconomy instance with reduced gold
  /// WARNING: Does not check if player can afford
  /// Call canAfford() first to validate
  PlayerEconomy deductGold(int amount) {
    return copyWith(gold: gold - amount);
  }

  /// Add gold to player's balance
  /// Returns new PlayerEconomy instance with increased gold
  PlayerEconomy addGold(int amount) {
    return copyWith(gold: gold + amount);
  }

  /// Deduct resources from inventory
  /// Returns new PlayerEconomy instance with reduced resource amount
  /// WARNING: Does not check if player has enough resources
  PlayerEconomy deductResource(String resourceId, int amountToDeduct) {
    if (!inventory.containsKey(resourceId)) {
      return this;
    }

    final resource = inventory[resourceId]!;
    final newAmount = max(0, resource.amount - amountToDeduct);

    final updatedResource = resource.copyWith(amount: newAmount);
    final updatedInventory = Map<String, Resource>.from(inventory);
    updatedInventory[resourceId] = updatedResource;

    return copyWith(inventory: updatedInventory);
  }

  /// Add a building to the player's collection
  /// Returns new PlayerEconomy instance with added building
  PlayerEconomy addBuilding(Building building) {
    final updatedBuildings = List<Building>.from(buildings)..add(building);
    return copyWith(buildings: updatedBuildings);
  }

  /// Create a copy with modified fields
  PlayerEconomy copyWith({
    int? gold,
    Map<String, Resource>? inventory,
    List<Building>? buildings,
    int? tier,
    DateTime? lastSeen,
  }) {
    return PlayerEconomy(
      gold: gold ?? this.gold,
      inventory: inventory ?? this.inventory,
      buildings: buildings ?? this.buildings,
      tier: tier ?? this.tier,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  List<Object?> get props => [
        gold,
        inventory,
        buildings,
        tier,
        lastSeen,
      ];

  @override
  String toString() => 'PlayerEconomy(gold: $gold, tier: $tier, '
      'resources: ${inventory.length}, buildings: ${buildings.length})';
}
