import 'package:hive/hive.dart';
import 'resource.dart';
import 'building.dart';

part 'player_economy.g.dart';

/// PlayerEconomy entity for Trade Factory Masters
/// Represents player's economic state (resources, buildings, currency)
@HiveType(typeId: 5)
class PlayerEconomy {
  @HiveField(0)
  final String playerId;

  @HiveField(1)
  final int gold;

  @HiveField(2)
  final List<Resource> resources;

  @HiveField(3)
  final List<Building> buildings;

  @HiveField(4)
  final DateTime lastUpdated;

  const PlayerEconomy({
    required this.playerId,
    this.gold = 1000, // Starting gold
    this.resources = const [],
    this.buildings = const [],
    required this.lastUpdated,
  });

  PlayerEconomy copyWith({
    String? playerId,
    int? gold,
    List<Resource>? resources,
    List<Building>? buildings,
    DateTime? lastUpdated,
  }) {
    return PlayerEconomy(
      playerId: playerId ?? this.playerId,
      gold: gold ?? this.gold,
      resources: resources ?? this.resources,
      buildings: buildings ?? this.buildings,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() => 'PlayerEconomy(playerId: $playerId, gold: $gold, '
      'resources: ${resources.length}, buildings: ${buildings.length})';
}
