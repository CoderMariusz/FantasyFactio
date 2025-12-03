import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/config/economic_config.dart';
import 'package:trade_factory_masters/domain/entities/building.dart';
import 'package:trade_factory_masters/domain/entities/player_economy.dart';
import 'package:trade_factory_masters/domain/entities/resource.dart';
import 'package:trade_factory_masters/domain/services/balance_calculator.dart';

void main() {
  group('ResourcePricing', () {
    test('getSellPrice should return correct prices for raw resources', () {
      expect(ResourcePricing.getSellPrice('Coal'), equals(1));
      expect(ResourcePricing.getSellPrice('Wood'), equals(1));
      expect(ResourcePricing.getSellPrice('Stone'), equals(2));
      expect(ResourcePricing.getSellPrice('Iron Ore'), equals(3));
    });

    test('getSellPrice should return correct prices for processed resources',
        () {
      expect(ResourcePricing.getSellPrice('Iron Bar'), equals(10));
      expect(ResourcePricing.getSellPrice('Copper Bar'), equals(8));
      expect(ResourcePricing.getSellPrice('Steel'), equals(25));
    });

    test('getSellPrice should return correct prices for crafted items', () {
      expect(ResourcePricing.getSellPrice('Hammer'), equals(50));
      expect(ResourcePricing.getSellPrice('Concrete'), equals(30));
    });

    test('getSellPrice should return 1 for unknown resources', () {
      expect(ResourcePricing.getSellPrice('Unknown'), equals(1));
    });

    test('getBuyPrice should be higher than sell price', () {
      expect(ResourcePricing.getBuyPrice('Coal'),
          greaterThan(ResourcePricing.getSellPrice('Coal')));
      expect(ResourcePricing.getBuyPrice('Iron Bar'),
          greaterThan(ResourcePricing.getSellPrice('Iron Bar')));
    });

    test('tier multipliers should increase with tier', () {
      expect(ResourcePricing.tierMultipliers[1], equals(1.0));
      expect(ResourcePricing.tierMultipliers[2], greaterThan(1.0));
      expect(ResourcePricing.tierMultipliers[3],
          greaterThan(ResourcePricing.tierMultipliers[2]!));
    });
  });

  group('BuildingEconomics', () {
    test('getUpgradeCost should increase with level', () {
      final cost1 = BuildingEconomics.getUpgradeCost('mining_facility', 1);
      final cost5 = BuildingEconomics.getUpgradeCost('mining_facility', 5);
      final cost10 = BuildingEconomics.getUpgradeCost('mining_facility', 10);

      expect(cost5, greaterThan(cost1));
      expect(cost10, greaterThan(cost5));
    });

    test('getUpgradeCost should vary by building type', () {
      final miningCost = BuildingEconomics.getUpgradeCost('mining_facility', 1);
      final farmCost = BuildingEconomics.getUpgradeCost('farm', 1);

      expect(farmCost, greaterThan(miningCost));
    });

    test('getUpgradeCost should return default for unknown buildings', () {
      final cost = BuildingEconomics.getUpgradeCost('unknown', 1);
      expect(cost, greaterThan(0));
    });

    test('productionBonusPerLevel should be positive', () {
      expect(BuildingEconomics.productionBonusPerLevel, greaterThan(0));
      expect(BuildingEconomics.productionBonusPerLevel, lessThanOrEqualTo(0.2));
    });

    test('maxBuildingLevel should be 10', () {
      expect(BuildingEconomics.maxBuildingLevel, equals(10));
    });
  });

  group('TradeEconomics', () {
    test('price multiplier range should be valid', () {
      expect(TradeEconomics.minPriceMultiplier, lessThan(1.0));
      expect(TradeEconomics.maxPriceMultiplier, greaterThan(1.0));
    });

    test('dailyOrderBonus should provide bonus', () {
      expect(TradeEconomics.dailyOrderBonus, greaterThan(1.0));
    });

    test('synergyBonus should provide bonus', () {
      expect(TradeEconomics.synergyBonus, greaterThan(1.0));
    });

    test('calculateTradePrice should apply base price', () {
      final price = TradeEconomics.calculateTradePrice(
        basePrice: 100,
        priceMultiplier: 1.0,
      );
      expect(price, equals(100));
    });

    test('calculateTradePrice should apply daily order bonus', () {
      final normalPrice = TradeEconomics.calculateTradePrice(
        basePrice: 100,
        priceMultiplier: 1.0,
      );
      final dailyPrice = TradeEconomics.calculateTradePrice(
        basePrice: 100,
        priceMultiplier: 1.0,
        isDailyOrder: true,
      );
      expect(dailyPrice, greaterThan(normalPrice));
    });

    test('calculateTradePrice should apply synergy bonus', () {
      final normalPrice = TradeEconomics.calculateTradePrice(
        basePrice: 100,
        priceMultiplier: 1.0,
      );
      final synergyPrice = TradeEconomics.calculateTradePrice(
        basePrice: 100,
        priceMultiplier: 1.0,
        hasSynergyBonus: true,
      );
      expect(synergyPrice, greaterThan(normalPrice));
    });

    test('calculateTradePrice should stack bonuses', () {
      final singleBonus = TradeEconomics.calculateTradePrice(
        basePrice: 100,
        priceMultiplier: 1.0,
        isDailyOrder: true,
      );
      final doubleBonus = TradeEconomics.calculateTradePrice(
        basePrice: 100,
        priceMultiplier: 1.0,
        isDailyOrder: true,
        hasSynergyBonus: true,
      );
      expect(doubleBonus, greaterThan(singleBonus));
    });

    test('effect durations should all be positive', () {
      for (final duration in TradeEconomics.effectDurations.values) {
        expect(duration, greaterThan(0));
      }
    });
  });

  group('ProductionTiming', () {
    test('getEffectiveCycleTime should decrease with level', () {
      final time1 = ProductionTiming.getEffectiveCycleTime('smelter', 1);
      final time5 = ProductionTiming.getEffectiveCycleTime('smelter', 5);
      final time10 = ProductionTiming.getEffectiveCycleTime('smelter', 10);

      expect(time5, lessThan(time1));
      expect(time10, lessThan(time5));
    });

    test('getEffectiveCycleTime should not go below 50% of base', () {
      final time = ProductionTiming.getEffectiveCycleTime('smelter', 100);
      final baseTime = ProductionTiming.baseCycleTimes['smelter']!;
      expect(time, greaterThanOrEqualTo(baseTime * 0.5));
    });

    test('maxStorageHours should be reasonable', () {
      expect(ProductionTiming.maxStorageHours, greaterThan(0));
      expect(ProductionTiming.maxStorageHours, lessThanOrEqualTo(24));
    });

    test('minCollectionInterval should be positive', () {
      expect(ProductionTiming.minCollectionInterval, greaterThan(0));
    });
  });

  group('ProgressionMilestones', () {
    test('unlockRequirements should have positive values', () {
      for (final value in ProgressionMilestones.unlockRequirements.values) {
        expect(value, greaterThan(0));
      }
    });

    test('tierRequirements should increase with tier', () {
      final tier2 = ProgressionMilestones.tierRequirements[2]!;
      final tier3 = ProgressionMilestones.tierRequirements[3]!;

      expect(tier3.goldRequired, greaterThan(tier2.goldRequired));
      expect(tier3.buildingsRequired, greaterThan(tier2.buildingsRequired));
    });
  });

  group('TierRequirement', () {
    test('isMet should return true when all requirements met', () {
      final req = ProgressionMilestones.tierRequirements[2]!;
      expect(
        req.isMet(
          currentGold: req.goldRequired,
          totalBuildings: req.buildingsRequired,
          totalTrades: req.tradesRequired,
        ),
        isTrue,
      );
    });

    test('isMet should return false when gold insufficient', () {
      final req = ProgressionMilestones.tierRequirements[2]!;
      expect(
        req.isMet(
          currentGold: req.goldRequired - 1,
          totalBuildings: req.buildingsRequired,
          totalTrades: req.tradesRequired,
        ),
        isFalse,
      );
    });
  });

  group('BalanceCalculator', () {
    late BalanceCalculator calculator;
    late PlayerEconomy emptyEconomy;
    late PlayerEconomy richEconomy;

    setUp(() {
      calculator = BalanceCalculator();
      emptyEconomy = PlayerEconomy(
        gold: 0,
        inventory: {},
        buildings: [],
        tier: 1,
        lastSeen: DateTime.now(),
      );
      richEconomy = PlayerEconomy(
        gold: 50000,
        inventory: {
          'Coal': Resource(
            id: 'Coal',
            displayName: 'Coal',
            type: ResourceType.tier1,
            amount: 1000,
            iconPath: 'assets/coal.png',
          ),
        },
        buildings: [],
        tier: 1,
        lastSeen: DateTime.now(),
      );
    });

    test('analyzeEconomy should return tutorial stage for empty economy', () {
      final analysis = calculator.analyzeEconomy(
        economy: emptyEconomy,
        buildings: [],
      );
      expect(analysis.stage, equals(GameStage.tutorial));
    });

    test('analyzeEconomy should provide recommendations', () {
      final analysis = calculator.analyzeEconomy(
        economy: emptyEconomy,
        buildings: [],
      );
      expect(analysis.recommendations, isNotEmpty);
    });

    test('analyzeEconomy should calculate efficiency score', () {
      final analysis = calculator.analyzeEconomy(
        economy: emptyEconomy,
        buildings: [],
      );
      expect(analysis.efficiencyScore, greaterThanOrEqualTo(0));
      expect(analysis.efficiencyScore, lessThanOrEqualTo(100));
    });

    test('calculateUpgradeROI should return positive for valid upgrades', () {
      final building = Building(
        id: 'test',
        type: BuildingType.smelter,
        level: 1,
        gridPosition: const GridPosition(x: 0, y: 0),
        production:
            const ProductionConfig(baseRate: 10, resourceType: 'Iron Bar'),
        upgradeConfig: const UpgradeConfig(baseCost: 100, costIncrement: 50),
        lastCollected: DateTime.now(),
        isActive: true,
      );

      final roi = calculator.calculateUpgradeROI(
        building: building,
        goldCost: 100,
      );

      expect(roi, greaterThan(0));
      expect(roi.isFinite, isTrue);
    });

    test('calculateUpgradeROI should return infinity for zero cost', () {
      final building = Building(
        id: 'test',
        type: BuildingType.mining,
        level: 1,
        gridPosition: const GridPosition(x: 0, y: 0),
        production: const ProductionConfig(baseRate: 10, resourceType: 'Coal'),
        upgradeConfig: const UpgradeConfig(baseCost: 100, costIncrement: 50),
        lastCollected: DateTime.now(),
        isActive: true,
      );

      final roi = calculator.calculateUpgradeROI(
        building: building,
        goldCost: 0,
      );

      expect(roi, equals(double.infinity));
    });
  });

  group('BalanceConstants', () {
    test('targetGoldPerHour should increase with game stage', () {
      expect(
        BalanceConstants.targetGoldPerHour['mid_game']!,
        greaterThan(BalanceConstants.targetGoldPerHour['early_game']!),
      );
      expect(
        BalanceConstants.targetGoldPerHour['late_game']!,
        greaterThan(BalanceConstants.targetGoldPerHour['mid_game']!),
      );
    });

    test('gatherRatesPerHour should all be positive', () {
      for (final rate in BalanceConstants.gatherRatesPerHour.values) {
        expect(rate, greaterThan(0));
      }
    });

    test('progression times should be reasonable', () {
      expect(BalanceConstants.minutesToFirstBuilding, greaterThan(0));
      expect(BalanceConstants.minutesToFirstBuilding, lessThan(30));
      expect(BalanceConstants.minutesToUnlockAllTier1, greaterThan(0));
      expect(BalanceConstants.minutesToUnlockAllTier1, lessThan(180));
    });
  });
}
