import '../entities/player_economy.dart';
import '../entities/building.dart';
import '../entities/building_definition.dart';
import '../../../config/game_config.dart';

/// Result of an inventory operation
class InventoryOperationResult {
  /// Whether operation succeeded
  final bool success;

  /// Error message if failed
  final String? error;

  /// Updated economy after operation
  final PlayerEconomy? economy;

  /// Quantity actually transferred
  final int quantityTransferred;

  const InventoryOperationResult._({
    required this.success,
    this.error,
    this.economy,
    this.quantityTransferred = 0,
  });

  factory InventoryOperationResult.success({
    required PlayerEconomy economy,
    required int quantity,
  }) =>
      InventoryOperationResult._(
        success: true,
        economy: economy,
        quantityTransferred: quantity,
      );

  factory InventoryOperationResult.failure(String error) =>
      InventoryOperationResult._(success: false, error: error);
}

/// Manages player inventory operations
class InventoryManager {
  /// Add resources to inventory
  InventoryOperationResult addResources({
    required PlayerEconomy economy,
    required String resourceId,
    required int quantity,
  }) {
    if (quantity <= 0) {
      return InventoryOperationResult.failure('Quantity must be positive');
    }

    final resource = economy.inventory[resourceId];
    final currentAmount = resource?.amount ?? 0;
    final maxCapacity =
        resource?.maxCapacity ?? EconomyConstants.defaultMaxCapacity;

    // Calculate how much can be added
    final remainingCapacity = maxCapacity - currentAmount;
    final actualQuantity =
        quantity > remainingCapacity ? remainingCapacity : quantity;

    if (actualQuantity <= 0) {
      return InventoryOperationResult.failure('Inventory is full');
    }

    // PlayerEconomy.addResource handles creation of new resources automatically
    final updatedEconomy = economy.addResource(resourceId, actualQuantity);

    return InventoryOperationResult.success(
      economy: updatedEconomy,
      quantity: actualQuantity,
    );
  }

  /// Remove resources from inventory
  InventoryOperationResult removeResources({
    required PlayerEconomy economy,
    required String resourceId,
    required int quantity,
  }) {
    if (quantity <= 0) {
      return InventoryOperationResult.failure('Quantity must be positive');
    }

    final resource = economy.inventory[resourceId];
    if (resource == null) {
      return InventoryOperationResult.failure('Resource not in inventory');
    }

    if (resource.amount < quantity) {
      return InventoryOperationResult.failure('Insufficient resources');
    }

    final updatedEconomy = economy.deductResource(resourceId, quantity);

    return InventoryOperationResult.success(
      economy: updatedEconomy,
      quantity: quantity,
    );
  }

  /// Transfer resources between inventory and gold (sell)
  InventoryOperationResult sellResources({
    required PlayerEconomy economy,
    required String resourceId,
    required int quantity,
    required int pricePerUnit,
  }) {
    // Check if player has enough resources
    final resource = economy.inventory[resourceId];
    if (resource == null || resource.amount < quantity) {
      return InventoryOperationResult.failure('Insufficient resources to sell');
    }

    // Calculate gold earned
    final goldEarned = quantity * pricePerUnit;

    // Deduct resources and add gold
    final updatedEconomy =
        economy.deductResource(resourceId, quantity).addGold(goldEarned);

    return InventoryOperationResult.success(
      economy: updatedEconomy,
      quantity: goldEarned,
    );
  }

  /// Check if player can afford a recipe's inputs
  bool canAffordRecipe({
    required PlayerEconomy economy,
    required Map<String, int> inputs,
  }) {
    for (final entry in inputs.entries) {
      final resource = economy.inventory[entry.key];
      final available = resource?.amount ?? 0;
      if (available < entry.value) {
        return false;
      }
    }
    return true;
  }

  /// Check if player can afford a building's cost
  bool canAffordBuilding({
    required PlayerEconomy economy,
    required BuildingDefinition definition,
  }) {
    return definition.canAfford(
      economy.inventory.map((k, v) => MapEntry(k, v.amount)),
    );
  }

  /// Calculate total inventory capacity used
  int getTotalInventoryUsed(PlayerEconomy economy) {
    return economy.inventory.values.fold<int>(
      0,
      (sum, resource) => sum + resource.amount,
    );
  }

  /// Calculate total inventory capacity
  int getTotalInventoryCapacity(PlayerEconomy economy) {
    // Base capacity + storage buildings
    int baseCapacity = EconomyConstants.defaultMaxCapacity;

    for (final building in economy.buildings) {
      if (building.type == BuildingType.storage) {
        final definition = BuildingDefinitions.getByType(building.type);
        baseCapacity += definition.storageCapacity ?? 0;
      }
    }

    return baseCapacity;
  }

  /// Get resource sell price
  int getResourceSellPrice(String resourceId) {
    // Base prices for resources
    const prices = {
      'Coal': 1,
      'Wood': 1,
      'Stone': 2,
      'Iron Ore': 3,
      'Copper Ore': 3,
      'Cotton': 2,
      'Salt': 2,
      'Clay': 2,
      'Iron Bar': 10,
      'Copper Bar': 8,
      'Steel': 25,
      'Hammer': 50,
      'Concrete': 30,
    };
    return prices[resourceId] ?? 1;
  }
}
