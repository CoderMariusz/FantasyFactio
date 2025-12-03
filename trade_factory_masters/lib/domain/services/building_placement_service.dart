import '../entities/building_definition.dart';
import '../entities/building.dart';
import '../entities/tile.dart';
import '../entities/placement_rules.dart';
import '../entities/player_economy.dart';

/// Result of a placement validation
class PlacementResult {
  /// Whether placement is valid
  final bool isValid;

  /// Error message if invalid
  final String? error;

  /// Affected tile positions (for multi-tile buildings)
  final List<(int, int)> affectedTiles;

  const PlacementResult._({
    required this.isValid,
    this.error,
    this.affectedTiles = const [],
  });

  /// Valid placement result
  factory PlacementResult.valid(List<(int, int)> tiles) =>
      PlacementResult._(isValid: true, affectedTiles: tiles);

  /// Invalid placement with reason
  factory PlacementResult.invalid(String reason) =>
      PlacementResult._(isValid: false, error: reason);
}

/// Result of a building placement operation
class BuildingPlacementResult {
  /// Whether placement succeeded
  final bool success;

  /// Error message if failed
  final String? error;

  /// Updated grid after placement
  final GameGrid? updatedGrid;

  /// Created building instance
  final Building? building;

  /// Updated player economy after costs deducted
  final PlayerEconomy? updatedEconomy;

  const BuildingPlacementResult._({
    required this.success,
    this.error,
    this.updatedGrid,
    this.building,
    this.updatedEconomy,
  });

  factory BuildingPlacementResult.success({
    required GameGrid grid,
    required Building building,
    required PlayerEconomy economy,
  }) =>
      BuildingPlacementResult._(
        success: true,
        updatedGrid: grid,
        building: building,
        updatedEconomy: economy,
      );

  factory BuildingPlacementResult.failure(String reason) =>
      BuildingPlacementResult._(success: false, error: reason);
}

/// Service for validating and executing building placements
class BuildingPlacementService {
  /// Validate if a building can be placed at position
  PlacementResult validatePlacement({
    required BuildingDefinition definition,
    required GameGrid grid,
    required int x,
    required int y,
  }) {
    // Collect all tiles this building would occupy
    final affectedTiles = <(int, int)>[];

    for (int dx = 0; dx < definition.width; dx++) {
      for (int dy = 0; dy < definition.height; dy++) {
        final tileX = x + dx;
        final tileY = y + dy;
        affectedTiles.add((tileX, tileY));
      }
    }

    // Check all tiles are within grid bounds
    for (final (tileX, tileY) in affectedTiles) {
      if (!grid.isValidPosition(tileX, tileY)) {
        return PlacementResult.invalid('Position outside grid bounds');
      }
    }

    // Check all tiles pass placement rules
    for (final (tileX, tileY) in affectedTiles) {
      final tile = grid.getTile(tileX, tileY);
      if (tile == null) {
        return PlacementResult.invalid('Tile data not found');
      }

      final canPlace = definition.placementRule.canPlace(
        tileBiom: tile.biom.id,
        isOccupied: tile.isOccupied,
        currentLayers: tile.layers,
      );

      if (!canPlace) {
        // Provide specific error based on rule type
        if (definition.placementRule is BiomRestrictedRule) {
          final rule = definition.placementRule as BiomRestrictedRule;
          return PlacementResult.invalid(
            'Requires biom: ${rule.allowedBioms.join(", ")}',
          );
        }
        if (tile.isOccupied) {
          return PlacementResult.invalid('Tile is already occupied');
        }
        return PlacementResult.invalid('Cannot place here');
      }
    }

    return PlacementResult.valid(affectedTiles);
  }

  /// Check if player can afford to build
  bool canAfford({
    required BuildingDefinition definition,
    required PlayerEconomy economy,
  }) {
    for (final entry in definition.buildCost.entries) {
      final resourceId = entry.key;
      final required = entry.value;
      final available = economy.inventory[resourceId]?.amount ?? 0;
      if (available < required) {
        return false;
      }
    }
    return true;
  }

  /// Execute building placement
  BuildingPlacementResult placeBuilding({
    required BuildingDefinition definition,
    required GameGrid grid,
    required PlayerEconomy economy,
    required int x,
    required int y,
    required String buildingId,
  }) {
    // Validate placement
    final validation = validatePlacement(
      definition: definition,
      grid: grid,
      x: x,
      y: y,
    );

    if (!validation.isValid) {
      return BuildingPlacementResult.failure(
        validation.error ?? 'Invalid placement',
      );
    }

    // Check affordability
    if (!canAfford(definition: definition, economy: economy)) {
      return BuildingPlacementResult.failure('Cannot afford building');
    }

    // Deduct resources
    var updatedInventory = Map<String, dynamic>.from(
      economy.inventory.map((k, v) => MapEntry(k, v)),
    );

    for (final entry in definition.buildCost.entries) {
      final resourceId = entry.key;
      final cost = entry.value;
      final resource = economy.inventory[resourceId];
      if (resource != null) {
        updatedInventory[resourceId] = resource.copyWith(
          amount: resource.amount - cost,
        );
      }
    }

    // Update grid
    var updatedGrid = grid;
    for (final (tileX, tileY) in validation.affectedTiles) {
      updatedGrid = updatedGrid.placeBuilding(tileX, tileY, buildingId);
    }

    // Create building instance
    final building = Building(
      id: buildingId,
      type: definition.type,
      gridPosition: GridPosition(x: x, y: y),
      level: 1,
      production: const ProductionConfig(baseRate: 1.0, resourceType: 'none'),
      upgradeConfig: const UpgradeConfig(baseCost: 100, costIncrement: 50),
      lastCollected: DateTime.now(),
    );

    // Create updated economy
    final updatedEconomy = economy.copyWith(
      inventory: updatedInventory.map(
        (k, v) => MapEntry(k, v as dynamic),
      ),
    );

    return BuildingPlacementResult.success(
      grid: updatedGrid,
      building: building,
      economy: updatedEconomy,
    );
  }

  /// Remove building from grid
  GameGrid removeBuilding({
    required GameGrid grid,
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    var updatedGrid = grid;
    for (int dx = 0; dx < width; dx++) {
      for (int dy = 0; dy < height; dy++) {
        updatedGrid = updatedGrid.removeBuilding(x + dx, y + dy);
      }
    }
    return updatedGrid;
  }

  /// Get all valid placement positions for a building definition
  List<(int, int)> getValidPlacements({
    required BuildingDefinition definition,
    required GameGrid grid,
  }) {
    final validPositions = <(int, int)>[];

    for (int y = 0; y < grid.height - definition.height + 1; y++) {
      for (int x = 0; x < grid.width - definition.width + 1; x++) {
        final result = validatePlacement(
          definition: definition,
          grid: grid,
          x: x,
          y: y,
        );
        if (result.isValid) {
          validPositions.add((x, y));
        }
      }
    }

    return validPositions;
  }
}
