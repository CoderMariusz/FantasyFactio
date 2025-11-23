import 'dart:math';
import '../entities/player_economy.dart';
import '../entities/building.dart';

/// Use case for collecting produced resources from a building
/// Calculates production based on elapsed time since last collection
/// and updates player's economy with new resources
class CollectResourcesUseCase {
  /// Execute the resource collection for a specific building
  ///
  /// Calculates resources based on:
  /// - Time elapsed since lastCollected
  /// - Building's production rate (accounts for level multiplier)
  /// - Storage capacity limit (prevents over-accumulation)
  ///
  /// Returns updated PlayerEconomy with:
  /// - Added resources to inventory
  /// - Updated building with new lastCollected timestamp
  CollectResourcesResult execute({
    required PlayerEconomy economy,
    required Building building,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();

    // Validate building is active
    if (!building.isActive) {
      return CollectResourcesResult(
        economy: economy,
        resourcesCollected: 0,
        wasCapped: false,
      );
    }

    // Calculate time elapsed
    final elapsed = now.difference(building.lastCollected);
    final hoursElapsed = elapsed.inMinutes / 60.0;

    // Calculate production (productionRate already includes level multiplier)
    final rawProduction = hoursElapsed * building.productionRate;

    // Apply storage capacity limit
    // Storage capacity = base production rate × 10 (equivalent to 10 hours storage)
    final storageCapacity = building.production.baseRate * 10;
    final cappedProduction = min(rawProduction, storageCapacity);
    final resourceAmount = cappedProduction.toInt();

    // Check if production was capped
    final wasCapped = rawProduction > storageCapacity;

    // Add resources to economy
    final updatedEconomy = economy.addResource(
      building.production.resourceType,
      resourceAmount,
    );

    // Update building's lastCollected timestamp
    final updatedBuilding = building.copyWith(lastCollected: now);

    // Replace building in economy's building list
    final buildingIndex = economy.buildings.indexWhere((b) => b.id == building.id);
    if (buildingIndex == -1) {
      // Building not found in economy, return economy with added resources only
      return CollectResourcesResult(
        economy: updatedEconomy,
        resourcesCollected: resourceAmount,
        wasCapped: wasCapped,
      );
    }

    final updatedBuildings = List<Building>.from(economy.buildings);
    updatedBuildings[buildingIndex] = updatedBuilding;

    final finalEconomy = updatedEconomy.copyWith(buildings: updatedBuildings);

    return CollectResourcesResult(
      economy: finalEconomy,
      resourcesCollected: resourceAmount,
      wasCapped: wasCapped,
    );
  }
}

/// Result of collecting resources from a building
class CollectResourcesResult {
  /// Updated player economy with collected resources
  final PlayerEconomy economy;

  /// Amount of resources collected
  final int resourcesCollected;

  /// Whether production was capped by storage capacity
  final bool wasCapped;

  const CollectResourcesResult({
    required this.economy,
    required this.resourcesCollected,
    required this.wasCapped,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectResourcesResult &&
          runtimeType == other.runtimeType &&
          economy == other.economy &&
          resourcesCollected == other.resourcesCollected &&
          wasCapped == other.wasCapped;

  @override
  int get hashCode =>
      economy.hashCode ^ resourcesCollected.hashCode ^ wasCapped.hashCode;

  @override
  String toString() =>
      'CollectResourcesResult(collected: $resourcesCollected, wasCapped: $wasCapped)';
}
