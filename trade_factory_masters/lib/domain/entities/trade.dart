import 'package:equatable/equatable.dart';
import 'recipe.dart';

/// Trade type enum
enum TradeType {
  /// Sell resources for gold
  sellForGold,

  /// Barter - exchange resources for resources
  barter,

  /// Premium - special offers (buffs, bonuses)
  premium,
}

/// Trade entity - represents a trade offer from an NPC
class Trade extends Equatable {
  /// Unique identifier
  final String id;

  /// Display name
  final String name;

  /// Trade type
  final TradeType type;

  /// What player gives (resources or gold)
  final List<ResourceStack> cost;

  /// What player receives (resources, gold, or special effects)
  final List<ResourceStack> reward;

  /// Gold cost (for premium trades)
  final int? goldCost;

  /// Gold reward (for sell trades)
  final int? goldReward;

  /// Special effect ID (for premium trades)
  final String? specialEffect;

  /// Special effect duration in seconds
  final int? effectDurationSeconds;

  /// Whether this is a daily order (bonus price)
  final bool isDailyOrder;

  /// Bonus multiplier for daily orders
  final double dailyOrderBonus;

  /// Base price fluctuation percentage (±X%)
  final double priceFluctuationPercent;

  /// Current price multiplier (1.0 = base price)
  final double currentPriceMultiplier;

  const Trade({
    required this.id,
    required this.name,
    required this.type,
    this.cost = const [],
    this.reward = const [],
    this.goldCost,
    this.goldReward,
    this.specialEffect,
    this.effectDurationSeconds,
    this.isDailyOrder = false,
    this.dailyOrderBonus = 1.2,
    this.priceFluctuationPercent = 20.0,
    this.currentPriceMultiplier = 1.0,
  });

  /// Calculate actual gold reward with fluctuation and bonuses
  int getActualGoldReward() {
    if (goldReward == null) return 0;
    double reward = goldReward! * currentPriceMultiplier;
    if (isDailyOrder) {
      reward *= dailyOrderBonus;
    }
    return reward.round();
  }

  /// Check if player can afford this trade
  bool canAfford({
    required Map<String, int> inventory,
    required int playerGold,
  }) {
    // Check gold cost
    if (goldCost != null && playerGold < goldCost!) {
      return false;
    }

    // Check resource costs
    for (final resourceCost in cost) {
      final available = inventory[resourceCost.resourceId] ?? 0;
      if (available < resourceCost.quantity) {
        return false;
      }
    }

    return true;
  }

  /// Create copy with price fluctuation applied
  Trade withPriceFluctuation(double multiplier) {
    return Trade(
      id: id,
      name: name,
      type: type,
      cost: cost,
      reward: reward,
      goldCost: goldCost,
      goldReward: goldReward,
      specialEffect: specialEffect,
      effectDurationSeconds: effectDurationSeconds,
      isDailyOrder: isDailyOrder,
      dailyOrderBonus: dailyOrderBonus,
      priceFluctuationPercent: priceFluctuationPercent,
      currentPriceMultiplier: multiplier,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        cost,
        reward,
        goldCost,
        goldReward,
        specialEffect,
        effectDurationSeconds,
        isDailyOrder,
        currentPriceMultiplier,
      ];
}

/// Predefined trade templates
class TradeTemplates {
  TradeTemplates._();

  // ===== KUPIEC TRADES (Sell for Gold) =====

  /// Sell Coal for gold (base: 1g)
  static const sellCoal = Trade(
    id: 'sell_coal',
    name: 'Sell Coal',
    type: TradeType.sellForGold,
    cost: [ResourceStack(resourceId: 'Coal', quantity: 1)],
    goldReward: 1,
  );

  /// Sell Wood for gold (base: 1.5g → rounded to 2)
  static const sellWood = Trade(
    id: 'sell_wood',
    name: 'Sell Wood',
    type: TradeType.sellForGold,
    cost: [ResourceStack(resourceId: 'Wood', quantity: 1)],
    goldReward: 2,
  );

  /// Sell Stone for gold (base: 1g)
  static const sellStone = Trade(
    id: 'sell_stone',
    name: 'Sell Stone',
    type: TradeType.sellForGold,
    cost: [ResourceStack(resourceId: 'Stone', quantity: 1)],
    goldReward: 1,
  );

  /// Sell Cotton for gold (base: 2g)
  static const sellCotton = Trade(
    id: 'sell_cotton',
    name: 'Sell Cotton',
    type: TradeType.sellForGold,
    cost: [ResourceStack(resourceId: 'Cotton', quantity: 1)],
    goldReward: 2,
  );

  /// Sell Salt for gold (base: 3g)
  static const sellSalt = Trade(
    id: 'sell_salt',
    name: 'Sell Salt',
    type: TradeType.sellForGold,
    cost: [ResourceStack(resourceId: 'Salt', quantity: 1)],
    goldReward: 3,
  );

  /// Sell Copper for gold (base: 5g)
  static const sellCopper = Trade(
    id: 'sell_copper',
    name: 'Sell Copper',
    type: TradeType.sellForGold,
    cost: [ResourceStack(resourceId: 'Copper Ore', quantity: 1)],
    goldReward: 5,
  );

  /// Sell Clay for gold (base: 1.5g → rounded to 2)
  static const sellCite = Trade(
    id: 'sell_clay',
    name: 'Sell Clay',
    type: TradeType.sellForGold,
    cost: [ResourceStack(resourceId: 'Clay', quantity: 1)],
    goldReward: 2,
  );

  // ===== INŻYNIER TRADES (Barter) =====

  /// 15 Coal → 20 Wood
  static const barterCoalToWood = Trade(
    id: 'barter_coal_wood',
    name: 'Coal to Wood',
    type: TradeType.barter,
    cost: [ResourceStack(resourceId: 'Coal', quantity: 15)],
    reward: [ResourceStack(resourceId: 'Wood', quantity: 20)],
  );

  /// 10 Stone + 5 Cotton → 8 Clay
  static const barterStoneCottonToClay = Trade(
    id: 'barter_stone_cotton_clay',
    name: 'Stone+Cotton to Clay',
    type: TradeType.barter,
    cost: [
      ResourceStack(resourceId: 'Stone', quantity: 10),
      ResourceStack(resourceId: 'Cotton', quantity: 5),
    ],
    reward: [ResourceStack(resourceId: 'Clay', quantity: 8)],
  );

  /// 20 Wood → 1 Refined Copper
  static const barterWoodToCopper = Trade(
    id: 'barter_wood_copper',
    name: 'Wood to Copper',
    type: TradeType.barter,
    cost: [ResourceStack(resourceId: 'Wood', quantity: 20)],
    reward: [ResourceStack(resourceId: 'Copper Bar', quantity: 1)],
  );

  /// 5 Salt → 10 Gold
  static const barterSaltToGold = Trade(
    id: 'barter_salt_gold',
    name: 'Salt to Gold',
    type: TradeType.barter,
    cost: [ResourceStack(resourceId: 'Salt', quantity: 5)],
    goldReward: 10,
  );

  /// 30 Iron Ore → 5 Copper
  static const barterIronToCopper = Trade(
    id: 'barter_iron_copper',
    name: 'Iron Ore to Copper',
    type: TradeType.barter,
    cost: [ResourceStack(resourceId: 'Iron Ore', quantity: 30)],
    reward: [ResourceStack(resourceId: 'Copper Ore', quantity: 5)],
  );

  // ===== NOMADA TRADES (Premium) =====

  /// 10 Gold → Scouting bonus (+50% gather for 3 min)
  static const premiumScoutingBonus = Trade(
    id: 'premium_scouting',
    name: 'Scouting Bonus',
    type: TradeType.premium,
    goldCost: 10,
    specialEffect: 'gather_bonus_50',
    effectDurationSeconds: 180,
  );

  /// 5 Cotton → Skill book (+1 level to chosen skill)
  static const premiumSkillBook = Trade(
    id: 'premium_skill_book',
    name: 'Skill Book',
    type: TradeType.premium,
    cost: [ResourceStack(resourceId: 'Cotton', quantity: 5)],
    specialEffect: 'skill_level_up',
  );

  /// 8 Salt → Eliksir (next 3 crafts -30% time)
  static const premiumEliksir = Trade(
    id: 'premium_eliksir',
    name: 'Craft Elixir',
    type: TradeType.premium,
    cost: [ResourceStack(resourceId: 'Salt', quantity: 8)],
    specialEffect: 'craft_speed_30',
    effectDurationSeconds: 0, // Effect lasts for 3 crafts, not time
  );

  /// 15 Wood → Travel potion (fast movement 1 min)
  static const premiumTravelPotion = Trade(
    id: 'premium_travel',
    name: 'Travel Potion',
    type: TradeType.premium,
    cost: [ResourceStack(resourceId: 'Wood', quantity: 15)],
    specialEffect: 'fast_movement',
    effectDurationSeconds: 60,
  );

  /// Get all Kupiec trades
  static List<Trade> get kupiecTrades => [
        sellCoal,
        sellWood,
        sellStone,
        sellCotton,
        sellSalt,
        sellCopper,
        sellCite,
      ];

  /// Get all Inżynier trades
  static List<Trade> get inzynierTrades => [
        barterCoalToWood,
        barterStoneCottonToClay,
        barterWoodToCopper,
        barterSaltToGold,
        barterIronToCopper,
      ];

  /// Get all Nomada trades
  static List<Trade> get nomadaTrades => [
        premiumScoutingBonus,
        premiumSkillBook,
        premiumEliksir,
        premiumTravelPotion,
      ];
}
