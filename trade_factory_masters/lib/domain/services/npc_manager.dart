import 'dart:math';
import '../entities/npc.dart';
import '../entities/trade.dart';

/// Manages NPC spawning, despawning, and trade generation
class NPCManager {
  final Random _random = Random();

  /// Current state of all NPCs
  final Map<String, NPC> _npcs = {};

  /// Time of last spawn check for each NPC
  final Map<String, DateTime> _lastSpawnCheck = {};

  /// Consecutive trades counter for synergy bonus (Inżynier)
  int _consecutiveTrades = 0;

  /// Synergy bonus expiration time
  DateTime? _synergyBonusExpires;

  /// Available bioms for roaming NPCs
  final List<String> _bioms = ['koppalnia', 'las', 'gory', 'jezioro'];

  NPCManager() {
    // Initialize all NPCs in despawned state
    for (final npcDef in NPCDefinitions.all) {
      _npcs[npcDef.id] = npcDef;
      _lastSpawnCheck[npcDef.id] = DateTime.now();
    }
  }

  /// Get all NPCs (spawned and not spawned)
  List<NPC> get allNPCs => _npcs.values.toList();

  /// Get only spawned NPCs
  List<NPC> get spawnedNPCs =>
      _npcs.values.where((npc) => npc.isSpawned).toList();

  /// Get NPC by ID
  NPC? getNPC(String id) => _npcs[id];

  /// Check if synergy bonus is active
  bool get isSynergyActive =>
      _synergyBonusExpires != null &&
      DateTime.now().isBefore(_synergyBonusExpires!);

  /// Get synergy bonus remaining seconds
  int get synergyRemainingSeconds {
    if (_synergyBonusExpires == null) return 0;
    final remaining = _synergyBonusExpires!.difference(DateTime.now()).inSeconds;
    return remaining.clamp(0, 120);
  }

  /// Update NPC states - call this every game tick
  void update(DateTime currentTime) {
    for (final npcId in _npcs.keys.toList()) {
      final npc = _npcs[npcId]!;

      if (npc.isSpawned) {
        // Check for despawn
        if (npc.shouldDespawn(currentTime)) {
          _despawnNPC(npcId);
        }
      } else {
        // Check for spawn
        final lastCheck = _lastSpawnCheck[npcId]!;
        final elapsed = currentTime.difference(lastCheck).inSeconds;

        // Add randomness for Nomada (6-8 min instead of fixed)
        int spawnInterval = npc.spawnIntervalSeconds;
        if (npc.type == NPCType.premium) {
          spawnInterval += _random.nextInt(120); // +0-2 min randomness
        }

        if (elapsed >= spawnInterval) {
          _spawnNPC(npcId, currentTime);
          _lastSpawnCheck[npcId] = currentTime;
        }
      }
    }
  }

  /// Spawn an NPC
  void _spawnNPC(String npcId, DateTime currentTime) {
    final npc = _npcs[npcId]!;

    // Generate trades for this NPC
    final trades = _generateTrades(npc);

    // Determine location for roaming NPCs
    String? currentBiom;
    if (npc.locationType == NPCLocationType.roaming) {
      currentBiom = _bioms[_random.nextInt(_bioms.length)];
    }

    _npcs[npcId] = npc.copyWith(
      isSpawned: true,
      spawnTime: currentTime,
      currentTrades: trades,
      currentBiom: currentBiom,
    );
  }

  /// Despawn an NPC
  void _despawnNPC(String npcId) {
    final npc = _npcs[npcId]!;
    _npcs[npcId] = npc.copyWith(
      isSpawned: false,
      spawnTime: null,
      currentTrades: [],
      currentBiom: null,
    );
  }

  /// Generate trades for an NPC
  List<Trade> _generateTrades(NPC npc) {
    switch (npc.type) {
      case NPCType.trader:
        return _generateKupiecTrades();
      case NPCType.barter:
        return _generateInzynierTrades();
      case NPCType.premium:
        return _generateNomadaTrades();
    }
  }

  /// Generate Kupiec trades with price fluctuation
  List<Trade> _generateKupiecTrades() {
    final trades = <Trade>[];

    for (final template in TradeTemplates.kupiecTrades) {
      // Apply ±20% price fluctuation
      final fluctuation = 0.8 + _random.nextDouble() * 0.4;
      trades.add(template.withPriceFluctuation(fluctuation));
    }

    // Add 2 random daily orders with +20% bonus
    final dailyOrderIndices = <int>[];
    while (dailyOrderIndices.length < 2) {
      final index = _random.nextInt(trades.length);
      if (!dailyOrderIndices.contains(index)) {
        dailyOrderIndices.add(index);
      }
    }

    for (final index in dailyOrderIndices) {
      final trade = trades[index];
      trades[index] = Trade(
        id: trade.id,
        name: '${trade.name} (Daily Order)',
        type: trade.type,
        cost: trade.cost,
        reward: trade.reward,
        goldReward: trade.goldReward,
        isDailyOrder: true,
        currentPriceMultiplier: trade.currentPriceMultiplier,
      );
    }

    return trades;
  }

  /// Generate Inżynier trades (show 3 random)
  List<Trade> _generateInzynierTrades() {
    final allTrades = List<Trade>.from(TradeTemplates.inzynierTrades);
    allTrades.shuffle(_random);
    return allTrades.take(3).toList();
  }

  /// Generate Nomada trades (show 2-3 random)
  List<Trade> _generateNomadaTrades() {
    final allTrades = List<Trade>.from(TradeTemplates.nomadaTrades);
    allTrades.shuffle(_random);
    final count = 2 + _random.nextInt(2); // 2 or 3
    return allTrades.take(count).toList();
  }

  /// Record a trade execution (for synergy tracking)
  void recordTrade(String npcId) {
    final npc = _npcs[npcId];
    if (npc == null) return;

    if (npc.type == NPCType.barter) {
      _consecutiveTrades++;

      // Activate synergy after 3 consecutive trades
      if (_consecutiveTrades >= 3) {
        _synergyBonusExpires = DateTime.now().add(const Duration(minutes: 2));
        _consecutiveTrades = 0; // Reset counter
      }
    }
  }

  /// Reset consecutive trades (called when player leaves Inżynier)
  void resetConsecutiveTrades() {
    _consecutiveTrades = 0;
  }

  /// Force spawn NPC (for testing)
  void forceSpawn(String npcId) {
    _spawnNPC(npcId, DateTime.now());
  }

  /// Force despawn NPC (for testing)
  void forceDespawn(String npcId) {
    _despawnNPC(npcId);
  }

  /// Refresh trades for a spawned NPC
  void refreshTrades(String npcId) {
    final npc = _npcs[npcId];
    if (npc == null || !npc.isSpawned) return;

    final trades = _generateTrades(npc);
    _npcs[npcId] = npc.copyWith(currentTrades: trades);
  }
}
