import 'package:equatable/equatable.dart';
import 'trade.dart';

/// NPC type enum - defines the 3 trader types
enum NPCType {
  /// Kupiec Khandal - Gold trading with price fluctuation
  trader,

  /// Inżynier Zyx - Barter trades with synergy bonus
  barter,

  /// Nomada Sha'ara - Premium offers, short window
  premium,
}

/// NPC location type
enum NPCLocationType {
  /// Fixed location in specific biom
  fixed,

  /// Roaming - changes location periodically
  roaming,
}

/// NPC entity - represents a trader in the game
class NPC extends Equatable {
  /// Unique identifier
  final String id;

  /// Display name
  final String name;

  /// NPC type (trader, barter, premium)
  final NPCType type;

  /// Location type (fixed or roaming)
  final NPCLocationType locationType;

  /// Fixed biom for fixed NPCs (null for roaming)
  final String? fixedBiom;

  /// Current biom location (for roaming NPCs)
  final String? currentBiom;

  /// How often the NPC spawns (in seconds)
  final int spawnIntervalSeconds;

  /// How long the NPC is visible (in seconds)
  final int visibleDurationSeconds;

  /// How often trades refresh (in seconds)
  final int tradeRefreshSeconds;

  /// Currently available trades
  final List<Trade> currentTrades;

  /// Whether NPC is currently visible/spawned
  final bool isSpawned;

  /// Time when NPC spawned (null if not spawned)
  final DateTime? spawnTime;

  /// Description of the NPC
  final String description;

  const NPC({
    required this.id,
    required this.name,
    required this.type,
    required this.locationType,
    this.fixedBiom,
    this.currentBiom,
    required this.spawnIntervalSeconds,
    required this.visibleDurationSeconds,
    required this.tradeRefreshSeconds,
    this.currentTrades = const [],
    this.isSpawned = false,
    this.spawnTime,
    required this.description,
  });

  /// Check if NPC should despawn based on current time
  bool shouldDespawn(DateTime currentTime) {
    if (!isSpawned || spawnTime == null) return false;
    final elapsed = currentTime.difference(spawnTime!).inSeconds;
    return elapsed >= visibleDurationSeconds;
  }

  /// Get remaining visible time in seconds
  int getRemainingTime(DateTime currentTime) {
    if (!isSpawned || spawnTime == null) return 0;
    final elapsed = currentTime.difference(spawnTime!).inSeconds;
    return (visibleDurationSeconds - elapsed).clamp(0, visibleDurationSeconds);
  }

  /// Create copy with updated fields
  NPC copyWith({
    String? id,
    String? name,
    NPCType? type,
    NPCLocationType? locationType,
    String? fixedBiom,
    String? currentBiom,
    int? spawnIntervalSeconds,
    int? visibleDurationSeconds,
    int? tradeRefreshSeconds,
    List<Trade>? currentTrades,
    bool? isSpawned,
    DateTime? spawnTime,
    String? description,
  }) {
    return NPC(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      locationType: locationType ?? this.locationType,
      fixedBiom: fixedBiom ?? this.fixedBiom,
      currentBiom: currentBiom ?? this.currentBiom,
      spawnIntervalSeconds: spawnIntervalSeconds ?? this.spawnIntervalSeconds,
      visibleDurationSeconds: visibleDurationSeconds ?? this.visibleDurationSeconds,
      tradeRefreshSeconds: tradeRefreshSeconds ?? this.tradeRefreshSeconds,
      currentTrades: currentTrades ?? this.currentTrades,
      isSpawned: isSpawned ?? this.isSpawned,
      spawnTime: spawnTime ?? this.spawnTime,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        locationType,
        fixedBiom,
        currentBiom,
        spawnIntervalSeconds,
        visibleDurationSeconds,
        tradeRefreshSeconds,
        currentTrades,
        isSpawned,
        spawnTime,
      ];
}

/// Predefined NPC definitions
class NPCDefinitions {
  NPCDefinitions._();

  /// Kupiec Khandal - Gold trader
  /// Fixed in Koppalnia biom, buys resources for gold
  static const kupiec = NPC(
    id: 'kupiec_khandal',
    name: 'Kupiec Khandal',
    type: NPCType.trader,
    locationType: NPCLocationType.fixed,
    fixedBiom: 'koppalnia',
    spawnIntervalSeconds: 120, // Every 2 minutes
    visibleDurationSeconds: 300, // Visible for 5 minutes
    tradeRefreshSeconds: 300, // New prices every 5 minutes
    description: 'Buys your resources for gold. Prices fluctuate ±20%.',
  );

  /// Inżynier Zyx - Barter trader
  /// Roaming, offers resource trades with synergy bonus
  static const inzynier = NPC(
    id: 'inzynier_zyx',
    name: 'Inżynier Zyx',
    type: NPCType.barter,
    locationType: NPCLocationType.roaming,
    spawnIntervalSeconds: 300, // Every 5 minutes
    visibleDurationSeconds: 420, // Visible for 7 minutes
    tradeRefreshSeconds: 420, // New trades every 7 minutes
    description: 'Trades resources for resources. 3 trades = synergy bonus!',
  );

  /// Nomada Sha'ara - Premium offers
  /// Roaming, short window, special items
  static const nomada = NPC(
    id: 'nomada_shaara',
    name: 'Nomada Sha\'ara',
    type: NPCType.premium,
    locationType: NPCLocationType.roaming,
    spawnIntervalSeconds: 420, // Every 6-8 minutes (randomized in manager)
    visibleDurationSeconds: 120, // Only 2 minutes!
    tradeRefreshSeconds: 360, // New offers every 6 minutes
    description: 'Rare premium offers. Only 2 minutes to catch!',
  );

  /// Get all NPC definitions
  static List<NPC> get all => [kupiec, inzynier, nomada];

  /// Get NPC by ID
  static NPC? getById(String id) {
    for (final npc in all) {
      if (npc.id == id) return npc;
    }
    return null;
  }
}
