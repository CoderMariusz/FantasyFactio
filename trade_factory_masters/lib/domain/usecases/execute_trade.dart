import '../entities/player_economy.dart';
import '../entities/resource.dart';
import '../entities/trade.dart';
import '../entities/npc.dart';

/// Result of executing a trade
class ExecuteTradeResult {
  /// Whether trade was successful
  final bool success;

  /// Updated player economy (null if failed)
  final PlayerEconomy? economy;

  /// Error message if failed
  final String? error;

  /// Gold earned (for sell trades)
  final int goldEarned;

  /// Resources received (for barter trades)
  final Map<String, int> resourcesReceived;

  /// Special effect applied (for premium trades)
  final String? specialEffectApplied;

  /// Effect duration in seconds
  final int? effectDurationSeconds;

  const ExecuteTradeResult({
    required this.success,
    this.economy,
    this.error,
    this.goldEarned = 0,
    this.resourcesReceived = const {},
    this.specialEffectApplied,
    this.effectDurationSeconds,
  });

  factory ExecuteTradeResult.failure(String error) {
    return ExecuteTradeResult(success: false, error: error);
  }
}

/// Use case for executing a trade with an NPC
class ExecuteTradeUseCase {
  /// Execute a trade
  ExecuteTradeResult execute({
    required PlayerEconomy economy,
    required NPC npc,
    required Trade trade,
  }) {
    // Validate NPC is spawned
    if (!npc.isSpawned) {
      return ExecuteTradeResult.failure('NPC is not available');
    }

    // Validate player can afford trade
    final inventoryCounts = _getInventoryCounts(economy);
    if (!trade.canAfford(inventory: inventoryCounts, playerGold: economy.gold.toInt())) {
      return ExecuteTradeResult.failure('Cannot afford this trade');
    }

    // Execute based on trade type
    switch (trade.type) {
      case TradeType.sellForGold:
        return _executeSellTrade(economy, trade);
      case TradeType.barter:
        return _executeBarterTrade(economy, trade);
      case TradeType.premium:
        return _executePremiumTrade(economy, trade);
    }
  }

  /// Convert PlayerEconomy inventory to simple map
  Map<String, int> _getInventoryCounts(PlayerEconomy economy) {
    final counts = <String, int>{};
    for (final entry in economy.inventory.entries) {
      counts[entry.key] = entry.value.amount.toInt();
    }
    return counts;
  }

  /// Execute a sell-for-gold trade
  ExecuteTradeResult _executeSellTrade(PlayerEconomy economy, Trade trade) {
    // Calculate gold earned
    final goldEarned = trade.getActualGoldReward();

    // Deduct resources
    final newInventory = Map<String, Resource>.from(economy.inventory);
    for (final cost in trade.cost) {
      final resource = newInventory[cost.resourceId];
      if (resource != null) {
        final newAmount = resource.amount - cost.quantity;
        if (newAmount <= 0) {
          newInventory.remove(cost.resourceId);
        } else {
          newInventory[cost.resourceId] = resource.copyWith(amount: newAmount);
        }
      }
    }

    // Add gold
    final newEconomy = economy.copyWith(
      gold: economy.gold + goldEarned,
      inventory: newInventory,
    );

    return ExecuteTradeResult(
      success: true,
      economy: newEconomy,
      goldEarned: goldEarned,
    );
  }

  /// Execute a barter trade (resources for resources)
  ExecuteTradeResult _executeBarterTrade(PlayerEconomy economy, Trade trade) {
    final newInventory = Map<String, Resource>.from(economy.inventory);
    var newGold = economy.gold;

    // Deduct cost resources
    for (final cost in trade.cost) {
      final resource = newInventory[cost.resourceId];
      if (resource != null) {
        final newAmount = resource.amount - cost.quantity;
        if (newAmount <= 0) {
          newInventory.remove(cost.resourceId);
        } else {
          newInventory[cost.resourceId] = resource.copyWith(amount: newAmount);
        }
      }
    }

    // Add reward resources
    final resourcesReceived = <String, int>{};
    for (final reward in trade.reward) {
      final existing = newInventory[reward.resourceId];
      if (existing != null) {
        newInventory[reward.resourceId] = existing.copyWith(
          amount: existing.amount + reward.quantity,
        );
      } else {
        // Create new resource entry
        newInventory[reward.resourceId] = Resource(
          id: reward.resourceId,
          displayName: reward.resourceId,
          type: ResourceType.tier1,
          amount: reward.quantity,
          iconPath: 'assets/images/resources/${reward.resourceId.toLowerCase().replaceAll(' ', '_')}.png',
        );
      }
      resourcesReceived[reward.resourceId] = reward.quantity;
    }

    // Add gold reward if any
    if (trade.goldReward != null) {
      newGold += trade.goldReward!;
    }

    final newEconomy = economy.copyWith(
      gold: newGold,
      inventory: newInventory,
    );

    return ExecuteTradeResult(
      success: true,
      economy: newEconomy,
      resourcesReceived: resourcesReceived,
      goldEarned: trade.goldReward ?? 0,
    );
  }

  /// Execute a premium trade (special effects)
  ExecuteTradeResult _executePremiumTrade(PlayerEconomy economy, Trade trade) {
    final newInventory = Map<String, Resource>.from(economy.inventory);
    var newGold = economy.gold;

    // Deduct gold cost if any
    if (trade.goldCost != null) {
      newGold -= trade.goldCost!;
    }

    // Deduct resource cost
    for (final cost in trade.cost) {
      final resource = newInventory[cost.resourceId];
      if (resource != null) {
        final newAmount = resource.amount - cost.quantity;
        if (newAmount <= 0) {
          newInventory.remove(cost.resourceId);
        } else {
          newInventory[cost.resourceId] = resource.copyWith(amount: newAmount);
        }
      }
    }

    final newEconomy = economy.copyWith(
      gold: newGold,
      inventory: newInventory,
    );

    return ExecuteTradeResult(
      success: true,
      economy: newEconomy,
      specialEffectApplied: trade.specialEffect,
      effectDurationSeconds: trade.effectDurationSeconds,
    );
  }
}
