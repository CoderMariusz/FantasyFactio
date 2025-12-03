import '../entities/building.dart';
import '../entities/building_definition.dart';
import '../entities/player_economy.dart';
import '../../config/economic_config.dart';

/// Result of economy analysis
class EconomyAnalysis {
  /// Total gold income per hour
  final double goldPerHour;

  /// Total resource production per hour (by resource)
  final Map<String, double> resourcesPerHour;

  /// Current game stage
  final GameStage stage;

  /// Estimated time to next tier (hours)
  final double? hoursToNextTier;

  /// Efficiency score (0-100)
  final int efficiencyScore;

  /// Recommendations for improvement
  final List<String> recommendations;

  const EconomyAnalysis({
    required this.goldPerHour,
    required this.resourcesPerHour,
    required this.stage,
    this.hoursToNextTier,
    required this.efficiencyScore,
    this.recommendations = const [],
  });
}

/// Game progression stage
enum GameStage {
  /// Just started, learning basics
  tutorial,

  /// Building first production chains
  earlyGame,

  /// Established economy, optimizing
  midGame,

  /// Late game, preparing for next tier
  lateGame,

  /// Ready for tier advancement
  tierReady,
}

/// Calculator for economic balance and progression analysis
class BalanceCalculator {
  /// Analyze player's current economy
  EconomyAnalysis analyzeEconomy({
    required PlayerEconomy economy,
    required List<Building> buildings,
  }) {
    // Calculate production rates
    final resourcesPerHour = _calculateResourcesPerHour(buildings);
    final goldPerHour = _calculateGoldPerHour(buildings, resourcesPerHour);

    // Determine game stage
    final stage = _determineGameStage(economy, buildings, goldPerHour);

    // Calculate time to next tier
    final hoursToNextTier = _calculateTimeToNextTier(economy, goldPerHour);

    // Calculate efficiency score
    final efficiencyScore = _calculateEfficiencyScore(
      economy,
      buildings,
      goldPerHour,
      stage,
    );

    // Generate recommendations
    final recommendations = _generateRecommendations(
      economy,
      buildings,
      stage,
      resourcesPerHour,
    );

    return EconomyAnalysis(
      goldPerHour: goldPerHour,
      resourcesPerHour: resourcesPerHour,
      stage: stage,
      hoursToNextTier: hoursToNextTier,
      efficiencyScore: efficiencyScore,
      recommendations: recommendations,
    );
  }

  /// Calculate resources produced per hour
  Map<String, double> _calculateResourcesPerHour(List<Building> buildings) {
    final rates = <String, double>{};

    for (final building in buildings) {
      if (!building.isActive) continue;

      final definition = BuildingDefinitions.getByType(building.type);
      if (definition.recipes.isEmpty) continue;

      final recipe = definition.recipes.first;
      final baseCycleTime = recipe.cycleTime;
      final levelReduction =
          1.0 - (building.level - 1) * BuildingEconomics.cycleTimeReductionPerLevel;
      final effectiveCycleTime = baseCycleTime * levelReduction.clamp(0.5, 1.0);

      final cyclesPerHour = 3600.0 / effectiveCycleTime;
      final levelBonus =
          1.0 + (building.level - 1) * BuildingEconomics.productionBonusPerLevel;

      for (final output in recipe.outputs) {
        if (output.resourceId == 'dynamic' || output.resourceId == 'Gold') {
          continue; // Skip dynamic/gold outputs
        }
        final rate = cyclesPerHour * output.quantity * levelBonus;
        rates[output.resourceId] = (rates[output.resourceId] ?? 0) + rate;
      }
    }

    return rates;
  }

  /// Calculate gold income per hour
  double _calculateGoldPerHour(
    List<Building> buildings,
    Map<String, double> resourcesPerHour,
  ) {
    double goldPerHour = 0;

    // Farm buildings convert resources to gold
    for (final building in buildings) {
      if (building.type == BuildingType.farm && building.isActive) {
        final definition = BuildingDefinitions.getByType(building.type);
        if (definition.recipes.isNotEmpty) {
          final cycleTime = ProductionTiming.getEffectiveCycleTime(
            'farm',
            building.level,
          );
          final cyclesPerHour = 3600.0 / cycleTime;
          goldPerHour += cyclesPerHour; // 1 gold per cycle base
        }
      }
    }

    // Estimate gold from selling excess resources
    for (final entry in resourcesPerHour.entries) {
      final price = ResourcePricing.getSellPrice(entry.key);
      // Assume 50% of production gets sold
      goldPerHour += entry.value * price * 0.5;
    }

    return goldPerHour;
  }

  /// Determine current game stage
  GameStage _determineGameStage(
    PlayerEconomy economy,
    List<Building> buildings,
    double goldPerHour,
  ) {
    final buildingCount = buildings.length;
    final totalGold = economy.gold;

    // Tutorial: No buildings yet
    if (buildingCount == 0) {
      return GameStage.tutorial;
    }

    // Check if ready for tier 2
    final tier2Req = ProgressionMilestones.tierRequirements[2];
    if (tier2Req != null &&
        tier2Req.isMet(
          currentGold: totalGold,
          totalBuildings: buildingCount,
          totalTrades: 0, // Would need to track this
        )) {
      return GameStage.tierReady;
    }

    // Late game: High gold income
    if (goldPerHour >= BalanceConstants.targetGoldPerHour['late_game']!) {
      return GameStage.lateGame;
    }

    // Mid game: Established economy
    if (goldPerHour >= BalanceConstants.targetGoldPerHour['mid_game']! ||
        buildingCount >= 5) {
      return GameStage.midGame;
    }

    // Early game: Building up
    return GameStage.earlyGame;
  }

  /// Calculate estimated time to reach next tier
  double? _calculateTimeToNextTier(
    PlayerEconomy economy,
    double goldPerHour,
  ) {
    if (economy.tier >= 3) return null; // Max tier

    final nextTier = economy.tier + 1;
    final requirement = ProgressionMilestones.tierRequirements[nextTier];
    if (requirement == null) return null;

    final goldNeeded = requirement.goldRequired - economy.gold;
    if (goldNeeded <= 0) return 0;

    if (goldPerHour <= 0) return double.infinity;

    return goldNeeded / goldPerHour;
  }

  /// Calculate efficiency score (0-100)
  int _calculateEfficiencyScore(
    PlayerEconomy economy,
    List<Building> buildings,
    double goldPerHour,
    GameStage stage,
  ) {
    int score = 0;

    // Building utilization (up to 30 points)
    final activeBuildings = buildings.where((b) => b.isActive).length;
    if (buildings.isNotEmpty) {
      score += ((activeBuildings / buildings.length) * 30).round();
    }

    // Gold income vs target (up to 40 points)
    final targetGold = switch (stage) {
      GameStage.tutorial => 50.0,
      GameStage.earlyGame => BalanceConstants.targetGoldPerHour['early_game']!.toDouble(),
      GameStage.midGame => BalanceConstants.targetGoldPerHour['mid_game']!.toDouble(),
      GameStage.lateGame => BalanceConstants.targetGoldPerHour['late_game']!.toDouble(),
      GameStage.tierReady => BalanceConstants.targetGoldPerHour['late_game']!.toDouble(),
    };
    final incomeRatio = (goldPerHour / targetGold).clamp(0.0, 1.0);
    score += (incomeRatio * 40).round();

    // Building levels (up to 20 points)
    if (buildings.isNotEmpty) {
      final avgLevel =
          buildings.fold<int>(0, (sum, b) => sum + b.level) / buildings.length;
      score += ((avgLevel / BuildingEconomics.maxBuildingLevel) * 20).round();
    }

    // Resource diversity (up to 10 points)
    final resourceTypes = economy.inventory.keys.length;
    score += (resourceTypes.clamp(0, 10));

    return score.clamp(0, 100);
  }

  /// Generate improvement recommendations
  List<String> _generateRecommendations(
    PlayerEconomy economy,
    List<Building> buildings,
    GameStage stage,
    Map<String, double> resourcesPerHour,
  ) {
    final recommendations = <String>[];

    // Check for inactive buildings
    final inactiveCount = buildings.where((b) => !b.isActive).length;
    if (inactiveCount > 0) {
      recommendations.add('Aktywuj $inactiveCount nieaktywnych budynków');
    }

    // Check for low-level buildings
    final lowLevelBuildings =
        buildings.where((b) => b.level < 3 && b.isActive).length;
    if (lowLevelBuildings > 2) {
      recommendations.add('Ulepsz budynki do poziomu 3+');
    }

    // Stage-specific recommendations
    switch (stage) {
      case GameStage.tutorial:
        recommendations.add('Zbuduj swoją pierwszą kopalnię');
        break;
      case GameStage.earlyGame:
        recommendations.add('Zbuduj magazyn na więcej zasobów');
        if (!buildings.any((b) => b.type == BuildingType.smelter)) {
          recommendations.add('Odblokuj piec hutniczy do przetwarzania rud');
        }
        break;
      case GameStage.midGame:
        if (!buildings.any((b) => b.type == BuildingType.farm)) {
          recommendations.add('Zbuduj farmę monetyzacyjną');
        }
        recommendations.add('Handluj z NPC dla lepszych cen');
        break;
      case GameStage.lateGame:
        recommendations.add('Optymalizuj łańcuchy produkcji');
        recommendations.add('Przygotuj się na awans do Tier 2');
        break;
      case GameStage.tierReady:
        recommendations.add('Możesz awansować do następnego Tier!');
        break;
    }

    // Resource bottleneck detection
    if (resourcesPerHour.isEmpty) {
      recommendations.add('Brak produkcji zasobów - zbuduj kopalnię');
    }

    return recommendations.take(5).toList(); // Max 5 recommendations
  }

  /// Calculate ROI for building upgrade
  double calculateUpgradeROI({
    required Building building,
    required int goldCost,
  }) {
    if (goldCost <= 0) return double.infinity;

    final definition = BuildingDefinitions.getByType(building.type);
    if (definition.recipes.isEmpty) return 0;

    // Calculate production increase
    final currentBonus =
        1.0 + (building.level - 1) * BuildingEconomics.productionBonusPerLevel;
    final newBonus =
        1.0 + building.level * BuildingEconomics.productionBonusPerLevel;
    final productionIncrease = (newBonus - currentBonus) / currentBonus;

    // Estimate gold value of increased production per hour
    final recipe = definition.recipes.first;
    double goldValuePerHour = 0;

    for (final output in recipe.outputs) {
      if (output.resourceId == 'dynamic' || output.resourceId == 'Gold') {
        continue;
      }
      final price = ResourcePricing.getSellPrice(output.resourceId);
      final cycleTime = ProductionTiming.getEffectiveCycleTime(
        definition.id,
        building.level,
      );
      final outputPerHour = (3600 / cycleTime) * output.quantity;
      goldValuePerHour += outputPerHour * price * productionIncrease;
    }

    // ROI = hours to recover investment
    if (goldValuePerHour <= 0) return double.infinity;
    return goldCost / goldValuePerHour;
  }
}
