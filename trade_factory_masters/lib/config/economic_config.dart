/// Economic configuration for Trade Factory Masters
/// Centralized balance values for the game economy
library;

/// Resource pricing and values
class ResourcePricing {
  ResourcePricing._();

  /// Base sell prices for resources (gold per unit)
  static const Map<String, int> baseSellPrices = {
    // Tier 1 Raw Resources
    'Coal': 1,
    'Wood': 1,
    'Stone': 2,
    'Iron Ore': 3,
    'Copper Ore': 3,
    'Cotton': 2,
    'Salt': 2,
    'Clay': 2,

    // Tier 1 Processed Resources
    'Iron Bar': 10,
    'Copper Bar': 8,
    'Steel': 25,

    // Tier 1 Crafted Items
    'Hammer': 50,
    'Concrete': 30,
  };

  /// Resource tier multipliers for pricing
  static const Map<int, double> tierMultipliers = {
    1: 1.0, // Tier 1 base
    2: 2.5, // Tier 2 = 2.5x Tier 1
    3: 6.0, // Tier 3 = 6x Tier 1
  };

  /// Get sell price for a resource
  static int getSellPrice(String resourceId) {
    return baseSellPrices[resourceId] ?? 1;
  }

  /// Get buy price (typically higher than sell)
  static int getBuyPrice(String resourceId) {
    final sellPrice = getSellPrice(resourceId);
    return (sellPrice * 1.5).ceil(); // 50% markup
  }
}

/// Building cost and upgrade configuration
class BuildingEconomics {
  BuildingEconomics._();

  /// Upgrade cost scaling per tier
  /// Formula: baseCost + (level - 1) * costIncrement
  static const Map<String, UpgradeCostConfig> upgradeCosts = {
    'mining_facility': UpgradeCostConfig(baseCost: 50, increment: 25),
    'storage': UpgradeCostConfig(baseCost: 75, increment: 40),
    'smelter': UpgradeCostConfig(baseCost: 100, increment: 50),
    'conveyor': UpgradeCostConfig(baseCost: 25, increment: 15),
    'workshop': UpgradeCostConfig(baseCost: 150, increment: 75),
    'farm': UpgradeCostConfig(baseCost: 200, increment: 100),
  };

  /// Production rate bonuses per level (percentage increase)
  static const double productionBonusPerLevel = 0.1; // 10% per level

  /// Cycle time reduction per level (percentage decrease)
  static const double cycleTimeReductionPerLevel = 0.05; // 5% faster per level

  /// Maximum building level
  static const int maxBuildingLevel = 10;

  /// Get upgrade cost for a building at specific level
  static int getUpgradeCost(String buildingId, int currentLevel) {
    final config = upgradeCosts[buildingId];
    if (config == null) return 100 + currentLevel * 50;
    return config.baseCost + (currentLevel - 1) * config.increment;
  }
}

/// Upgrade cost configuration
class UpgradeCostConfig {
  final int baseCost;
  final int increment;

  const UpgradeCostConfig({
    required this.baseCost,
    required this.increment,
  });
}

/// NPC trading economics
class TradeEconomics {
  TradeEconomics._();

  /// Price fluctuation range (0.8 - 1.2 = ±20%)
  static const double minPriceMultiplier = 0.8;
  static const double maxPriceMultiplier = 1.2;

  /// Daily order bonus multiplier
  static const double dailyOrderBonus = 1.2; // 20% bonus

  /// Synergy bonus after 3 trades with same NPC
  static const double synergyBonus = 1.15; // 15% bonus

  /// Premium effect durations (seconds)
  static const Map<String, int> effectDurations = {
    'gather_bonus_50': 180, // 3 minutes
    'production_boost_25': 300, // 5 minutes
    'trade_bonus_10': 600, // 10 minutes
    'luck_boost': 120, // 2 minutes
  };

  /// Calculate actual trade price with modifiers
  static int calculateTradePrice({
    required int basePrice,
    required double priceMultiplier,
    bool isDailyOrder = false,
    bool hasSynergyBonus = false,
  }) {
    double price = basePrice * priceMultiplier;

    if (isDailyOrder) {
      price *= dailyOrderBonus;
    }

    if (hasSynergyBonus) {
      price *= synergyBonus;
    }

    return price.round();
  }
}

/// Production timing constants
class ProductionTiming {
  ProductionTiming._();

  /// Base cycle times in seconds for each building type
  static const Map<String, double> baseCycleTimes = {
    'mining_facility': 1.25, // Gather every 1.25s
    'smelter': 50.0, // Smelt iron in 50s
    'workshop': 62.0, // Craft hammer in 62s
    'farm': 5.0, // Convert to gold every 5s
  };

  /// Storage accumulation cap (hours)
  static const double maxStorageHours = 10.0;

  /// Minimum collection interval (seconds)
  static const int minCollectionInterval = 60;

  /// Offline production cap (hours)
  static const int maxOfflineHours = 24;

  /// Get effective cycle time with level bonus
  static double getEffectiveCycleTime(String buildingId, int level) {
    final baseTime = baseCycleTimes[buildingId] ?? 10.0;
    final reduction = 1.0 - (level - 1) * BuildingEconomics.cycleTimeReductionPerLevel;
    return baseTime * reduction.clamp(0.5, 1.0); // Cap at 50% reduction
  }
}

/// Game progression milestones
class ProgressionMilestones {
  ProgressionMilestones._();

  /// Actions required to unlock buildings
  static const Map<String, int> unlockRequirements = {
    'smelt_iron_ore': 1, // Unlocks smelter, conveyor
    'craft_any': 5, // Unlocks workshop
    'trade_with_npc': 2, // Unlocks farm
  };

  /// Tier progression requirements
  static const Map<int, TierRequirement> tierRequirements = {
    2: TierRequirement(
      goldRequired: 10000,
      buildingsRequired: 5,
      tradesRequired: 20,
    ),
    3: TierRequirement(
      goldRequired: 50000,
      buildingsRequired: 15,
      tradesRequired: 100,
    ),
  };
}

/// Tier advancement requirements
class TierRequirement {
  final int goldRequired;
  final int buildingsRequired;
  final int tradesRequired;

  const TierRequirement({
    required this.goldRequired,
    required this.buildingsRequired,
    required this.tradesRequired,
  });

  /// Check if requirements are met
  bool isMet({
    required int currentGold,
    required int totalBuildings,
    required int totalTrades,
  }) {
    return currentGold >= goldRequired &&
        totalBuildings >= buildingsRequired &&
        totalTrades >= tradesRequired;
  }
}

/// Economy balance constants
class BalanceConstants {
  BalanceConstants._();

  /// Target gold per hour at different stages
  static const Map<String, int> targetGoldPerHour = {
    'early_game': 100, // First 30 min
    'mid_game': 500, // 30 min - 2 hours
    'late_game': 2000, // 2+ hours
  };

  /// Resource gathering rates per biom (units per hour at level 1)
  static const Map<String, double> gatherRatesPerHour = {
    'koppalnia': 2880.0, // 1.25s cycle = 2880/hour
    'las': 3456.0, // 20% faster = 3456/hour
    'gory': 2304.0, // 20% slower = 2304/hour
    'jezioro': 2592.0, // 10% slower = 2592/hour
  };

  /// Expected time to afford first non-free building (minutes)
  static const int minutesToFirstBuilding = 5;

  /// Expected time to unlock all Tier 1 buildings (minutes)
  static const int minutesToUnlockAllTier1 = 60;
}
