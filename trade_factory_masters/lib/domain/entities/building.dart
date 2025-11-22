import 'package:hive/hive.dart';

part 'building.g.dart';

/// Building entity for Trade Factory Masters
/// Represents a factory building on the grid
@HiveType(typeId: 2)
class Building {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final BuildingType type;

  @HiveField(3)
  final int level;

  @HiveField(4)
  final GridPosition position;

  @HiveField(5)
  final bool isActive;

  const Building({
    required this.id,
    required this.name,
    required this.type,
    this.level = 1,
    required this.position,
    this.isActive = true,
  });

  Building copyWith({
    String? id,
    String? name,
    BuildingType? type,
    int? level,
    GridPosition? position,
    bool? isActive,
  }) {
    return Building(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      level: level ?? this.level,
      position: position ?? this.position,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() =>
      'Building(id: $id, name: $name, type: $type, level: $level)';
}

/// Building type enum
@HiveType(typeId: 3)
enum BuildingType {
  @HiveField(0)
  collector, // Collects raw resources

  @HiveField(1)
  processor, // Processes resources

  @HiveField(2)
  storage, // Stores resources

  @HiveField(3)
  conveyor, // Transports resources

  @HiveField(4)
  market, // Trades resources
}

/// Grid position for building placement
@HiveType(typeId: 4)
class GridPosition {
  @HiveField(0)
  final int x;

  @HiveField(1)
  final int y;

  const GridPosition({
    required this.x,
    required this.y,
  });

  @override
  String toString() => 'GridPosition(x: $x, y: $y)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
