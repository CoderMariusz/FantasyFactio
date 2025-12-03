import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/npc.dart';
import 'package:trade_factory_masters/domain/entities/trade.dart';
import 'package:trade_factory_masters/domain/entities/recipe.dart';
import 'package:trade_factory_masters/domain/services/npc_manager.dart';
import 'package:trade_factory_masters/domain/usecases/execute_trade.dart';
import 'package:trade_factory_masters/domain/entities/player_economy.dart';
import 'package:trade_factory_masters/domain/entities/resource.dart';

void main() {
  group('NPCDefinitions', () {
    test('should have exactly 3 NPCs defined', () {
      expect(NPCDefinitions.all.length, equals(3));
    });

    test('Kupiec should be trader type with fixed location', () {
      final kupiec = NPCDefinitions.kupiec;
      expect(kupiec.type, equals(NPCType.trader));
      expect(kupiec.locationType, equals(NPCLocationType.fixed));
      expect(kupiec.fixedBiom, equals('koppalnia'));
    });

    test('Inżynier should be barter type with roaming location', () {
      final inzynier = NPCDefinitions.inzynier;
      expect(inzynier.type, equals(NPCType.barter));
      expect(inzynier.locationType, equals(NPCLocationType.roaming));
    });

    test('Nomada should be premium type with short window', () {
      final nomada = NPCDefinitions.nomada;
      expect(nomada.type, equals(NPCType.premium));
      expect(nomada.visibleDurationSeconds, equals(120)); // 2 minutes only!
    });

    test('getById should return correct NPC', () {
      expect(NPCDefinitions.getById('kupiec_khandal')?.name, equals('Kupiec Khandal'));
      expect(NPCDefinitions.getById('inzynier_zyx')?.name, equals('Inżynier Zyx'));
      expect(NPCDefinitions.getById('unknown'), isNull);
    });
  });

  group('NPC Entity', () {
    test('shouldDespawn should return false when not spawned', () {
      final npc = NPCDefinitions.kupiec;
      expect(npc.shouldDespawn(DateTime.now()), isFalse);
    });

    test('shouldDespawn should return true after visible duration', () {
      final npc = NPCDefinitions.kupiec.copyWith(
        isSpawned: true,
        spawnTime: DateTime.now().subtract(const Duration(minutes: 6)),
      );
      expect(npc.shouldDespawn(DateTime.now()), isTrue);
    });

    test('getRemainingTime should calculate correctly', () {
      final spawnTime = DateTime.now().subtract(const Duration(minutes: 2));
      final npc = NPCDefinitions.kupiec.copyWith(
        isSpawned: true,
        spawnTime: spawnTime,
      );
      // Kupiec visible for 5 min, spawned 2 min ago = 3 min remaining
      final remaining = npc.getRemainingTime(DateTime.now());
      expect(remaining, closeTo(180, 5)); // ~180 seconds ± 5s tolerance
    });
  });

  group('TradeTemplates', () {
    test('Kupiec should have 7 sell trades', () {
      expect(TradeTemplates.kupiecTrades.length, equals(7));
    });

    test('Inżynier should have 5 barter trades', () {
      expect(TradeTemplates.inzynierTrades.length, equals(5));
    });

    test('Nomada should have 4 premium trades', () {
      expect(TradeTemplates.nomadaTrades.length, equals(4));
    });

    test('sell trades should have goldReward', () {
      for (final trade in TradeTemplates.kupiecTrades) {
        expect(trade.goldReward, isNotNull);
        expect(trade.goldReward, greaterThan(0));
      }
    });

    test('premium trades should have specialEffect', () {
      for (final trade in TradeTemplates.nomadaTrades) {
        expect(trade.specialEffect, isNotNull);
      }
    });
  });

  group('Trade', () {
    test('canAfford should check resource requirements', () {
      final trade = TradeTemplates.sellCoal;

      expect(
        trade.canAfford(inventory: {'Coal': 0}, playerGold: 100),
        isFalse,
      );
      expect(
        trade.canAfford(inventory: {'Coal': 1}, playerGold: 100),
        isTrue,
      );
    });

    test('canAfford should check gold for premium trades', () {
      final trade = TradeTemplates.premiumScoutingBonus;

      expect(
        trade.canAfford(inventory: {}, playerGold: 5),
        isFalse,
      );
      expect(
        trade.canAfford(inventory: {}, playerGold: 10),
        isTrue,
      );
    });

    test('getActualGoldReward should apply fluctuation', () {
      final trade = TradeTemplates.sellCoal.withPriceFluctuation(1.2);
      expect(trade.getActualGoldReward(), equals(1)); // 1 * 1.2 = 1.2 → rounded to 1
    });

    test('getActualGoldReward should apply daily bonus', () {
      final trade = Trade(
        id: 'test',
        name: 'Test',
        type: TradeType.sellForGold,
        cost: [const ResourceStack(resourceId: 'Coal', quantity: 10)],
        goldReward: 10,
        isDailyOrder: true,
        dailyOrderBonus: 1.2,
        currentPriceMultiplier: 1.0,
      );
      expect(trade.getActualGoldReward(), equals(12)); // 10 * 1.0 * 1.2 = 12
    });
  });

  group('NPCManager', () {
    late NPCManager manager;

    setUp(() {
      manager = NPCManager();
    });

    test('should initialize with 3 NPCs', () {
      expect(manager.allNPCs.length, equals(3));
    });

    test('all NPCs should start despawned', () {
      expect(manager.spawnedNPCs.length, equals(0));
    });

    test('forceSpawn should spawn NPC with trades', () {
      manager.forceSpawn('kupiec_khandal');
      final npc = manager.getNPC('kupiec_khandal');

      expect(npc?.isSpawned, isTrue);
      expect(npc?.currentTrades.isNotEmpty, isTrue);
    });

    test('forceDespawn should despawn NPC', () {
      manager.forceSpawn('kupiec_khandal');
      manager.forceDespawn('kupiec_khandal');
      final npc = manager.getNPC('kupiec_khandal');

      expect(npc?.isSpawned, isFalse);
      expect(npc?.currentTrades.isEmpty, isTrue);
    });

    test('Kupiec trades should include daily orders', () {
      manager.forceSpawn('kupiec_khandal');
      final npc = manager.getNPC('kupiec_khandal');
      final dailyOrders = npc?.currentTrades.where((t) => t.isDailyOrder).toList();

      expect(dailyOrders?.length, equals(2));
    });

    test('synergy bonus should activate after 3 trades with Inżynier', () {
      manager.forceSpawn('inzynier_zyx');

      manager.recordTrade('inzynier_zyx');
      manager.recordTrade('inzynier_zyx');
      expect(manager.isSynergyActive, isFalse);

      manager.recordTrade('inzynier_zyx');
      expect(manager.isSynergyActive, isTrue);
    });
  });

  group('ExecuteTradeUseCase', () {
    late ExecuteTradeUseCase useCase;
    late PlayerEconomy economy;

    setUp(() {
      useCase = ExecuteTradeUseCase();
      economy = PlayerEconomy(
        gold: 100,
        inventory: {
          'Coal': Resource(
            id: 'Coal',
            displayName: 'Coal',
            type: ResourceType.tier1,
            amount: 50,
            iconPath: 'assets/coal.png',
          ),
          'Wood': Resource(
            id: 'Wood',
            displayName: 'Wood',
            type: ResourceType.tier1,
            amount: 30,
            iconPath: 'assets/wood.png',
          ),
        },
        buildings: [],
        tier: 1,
        lastSeen: DateTime.now(),
      );
    });

    test('should fail if NPC not spawned', () {
      final npc = NPCDefinitions.kupiec;
      final trade = TradeTemplates.sellCoal;

      final result = useCase.execute(
        economy: economy,
        npc: npc,
        trade: trade,
      );

      expect(result.success, isFalse);
      expect(result.error, equals('NPC is not available'));
    });

    test('should fail if cannot afford trade', () {
      final npc = NPCDefinitions.kupiec.copyWith(isSpawned: true);
      final trade = Trade(
        id: 'expensive',
        name: 'Expensive',
        type: TradeType.sellForGold,
        cost: [const ResourceStack(resourceId: 'Gold Bars', quantity: 100)],
        goldReward: 1000,
      );

      final result = useCase.execute(
        economy: economy,
        npc: npc,
        trade: trade,
      );

      expect(result.success, isFalse);
      expect(result.error, equals('Cannot afford this trade'));
    });

    test('should execute sell trade and add gold', () {
      final npc = NPCDefinitions.kupiec.copyWith(isSpawned: true);
      final trade = TradeTemplates.sellCoal;

      final result = useCase.execute(
        economy: economy,
        npc: npc,
        trade: trade,
      );

      expect(result.success, isTrue);
      expect(result.goldEarned, greaterThan(0));
      expect(result.economy?.inventory['Coal']?.amount, equals(49));
    });

    test('should execute barter trade and exchange resources', () {
      final npc = NPCDefinitions.inzynier.copyWith(isSpawned: true);
      final trade = TradeTemplates.barterCoalToWood;

      // Need 15 Coal for this trade
      final result = useCase.execute(
        economy: economy,
        npc: npc,
        trade: trade,
      );

      expect(result.success, isTrue);
      expect(result.economy?.inventory['Coal']?.amount, equals(35)); // 50 - 15
      expect(result.economy?.inventory['Wood']?.amount, equals(50)); // 30 + 20
    });

    test('should execute premium trade with special effect', () {
      final npc = NPCDefinitions.nomada.copyWith(isSpawned: true);
      final trade = TradeTemplates.premiumScoutingBonus;

      final result = useCase.execute(
        economy: economy,
        npc: npc,
        trade: trade,
      );

      expect(result.success, isTrue);
      expect(result.specialEffectApplied, equals('gather_bonus_50'));
      expect(result.effectDurationSeconds, equals(180));
      expect(result.economy?.gold, equals(90)); // 100 - 10
    });
  });
}
