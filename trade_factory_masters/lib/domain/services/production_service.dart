import '../entities/building.dart';
import '../entities/building_definition.dart';
import '../entities/recipe.dart';
import '../entities/tile.dart';

/// Result of production calculation
class ProductionResult {
  /// Resources produced (resourceId → quantity)
  final Map<String, int> produced;

  /// Resources consumed (resourceId → quantity)
  final Map<String, int> consumed;

  /// Whether production cycle completed
  final bool cycleCompleted;

  /// Progress towards next cycle (0.0 - 1.0)
  final double progress;

  /// Error message if production failed
  final String? error;

  const ProductionResult({
    this.produced = const {},
    this.consumed = const {},
    this.cycleCompleted = false,
    this.progress = 0.0,
    this.error,
  });

  factory ProductionResult.success({
    required Map<String, int> produced,
    Map<String, int> consumed = const {},
  }) =>
      ProductionResult(
        produced: produced,
        consumed: consumed,
        cycleCompleted: true,
      );

  factory ProductionResult.inProgress(double progress) =>
      ProductionResult(progress: progress);

  factory ProductionResult.failed(String error) =>
      ProductionResult(error: error);
}

/// Service for calculating building production
class ProductionService {
  /// Calculate production for a building based on elapsed time
  ProductionResult calculateProduction({
    required Building building,
    required BuildingDefinition definition,
    required Map<String, int> inventory,
    required Duration elapsedTime,
    Tile? placedOnTile,
  }) {
    // Check if building is active
    if (!building.isActive) {
      return ProductionResult.failed('Building is not active');
    }

    // Get active recipe for this building
    final recipe = _getActiveRecipe(definition, placedOnTile);
    if (recipe == null) {
      return ProductionResult.failed('No active recipe');
    }

    // Calculate cycle time with level bonus
    final baseCycleTime = recipe.cycleTime;
    final levelMultiplier = 1.0 - (building.level - 1) * 0.05; // 5% faster per level
    final effectiveCycleTime = baseCycleTime * levelMultiplier;

    // Calculate how many cycles can be completed
    final elapsedSeconds = elapsedTime.inMilliseconds / 1000.0;
    final completedCycles = (elapsedSeconds / effectiveCycleTime).floor();

    if (completedCycles == 0) {
      // Production in progress
      final progress = elapsedSeconds / effectiveCycleTime;
      return ProductionResult.inProgress(progress);
    }

    // Check if we have inputs for production
    if (!recipe.canExecute(inventory)) {
      return ProductionResult.failed('Insufficient resources for production');
    }

    // Calculate production
    final produced = <String, int>{};
    final consumed = <String, int>{};

    // Handle dynamic resource based on biom
    for (final output in recipe.outputs) {
      String resourceId = output.resourceId;

      // Handle dynamic gathering (mining facility)
      if (resourceId == 'dynamic' && placedOnTile != null) {
        final biomResources = placedOnTile.biom.producesResources;
        if (biomResources.isNotEmpty) {
          // For mining, gather primary biom resource
          resourceId = biomResources.first;
        } else {
          continue; // Skip if biom produces nothing
        }
      }

      // Calculate quantity with level bonus
      final baseQuantity = output.quantity * completedCycles;
      final levelBonus = 1.0 + (building.level - 1) * 0.1; // 10% more per level
      final quantity = (baseQuantity * levelBonus).floor();

      produced[resourceId] = (produced[resourceId] ?? 0) + quantity;
    }

    // Calculate consumed resources
    for (final input in recipe.inputs) {
      final quantity = input.quantity * completedCycles;
      consumed[input.resourceId] = (consumed[input.resourceId] ?? 0) + quantity;
    }

    return ProductionResult.success(
      produced: produced,
      consumed: consumed,
    );
  }

  /// Get the active recipe for a building
  Recipe? _getActiveRecipe(BuildingDefinition definition, Tile? tile) {
    if (definition.recipes.isEmpty) {
      return null;
    }

    // For most buildings, return first recipe
    // Mining buildings get dynamic recipe based on biom
    return definition.recipes.first;
  }

  /// Calculate accumulated resources since last collection
  /// Used for offline progress calculation
  Map<String, int> calculateAccumulatedResources({
    required Building building,
    required BuildingDefinition definition,
    required DateTime lastCollected,
    required DateTime now,
    Tile? placedOnTile,
    int maxStorageHours = 10,
  }) {
    // Cap offline production to maxStorageHours
    final maxDuration = Duration(hours: maxStorageHours);
    var elapsed = now.difference(lastCollected);
    if (elapsed > maxDuration) {
      elapsed = maxDuration;
    }

    // Calculate production assuming we have infinite inputs
    // (for storage calculation purposes)
    final result = calculateProduction(
      building: building,
      definition: definition,
      inventory: {}, // Infinite inputs assumption
      elapsedTime: elapsed,
      placedOnTile: placedOnTile,
    );

    return result.produced;
  }

  /// Get production rate per hour for a building
  double getProductionRatePerHour({
    required Building building,
    required BuildingDefinition definition,
  }) {
    if (definition.recipes.isEmpty) {
      return 0.0;
    }

    final recipe = definition.recipes.first;
    final baseCycleTime = recipe.cycleTime;
    final levelMultiplier = 1.0 - (building.level - 1) * 0.05;
    final effectiveCycleTime = baseCycleTime * levelMultiplier;

    // Cycles per hour
    final cyclesPerHour = 3600.0 / effectiveCycleTime;

    // Total output per hour
    final outputPerCycle =
        recipe.outputs.fold<int>(0, (sum, o) => sum + o.quantity);
    final levelBonus = 1.0 + (building.level - 1) * 0.1;

    return cyclesPerHour * outputPerCycle * levelBonus;
  }
}
