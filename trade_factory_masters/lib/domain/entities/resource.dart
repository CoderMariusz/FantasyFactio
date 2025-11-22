import 'package:hive/hive.dart';

part 'resource.g.dart';

/// Resource entity for Trade Factory Masters
/// Represents a single resource type (Wood, Stone, Iron, etc.)
@HiveType(typeId: 0)
class Resource {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final ResourceType type;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final double productionRate;

  const Resource({
    required this.id,
    required this.name,
    required this.type,
    this.quantity = 0,
    this.productionRate = 0.0,
  });

  Resource copyWith({
    String? id,
    String? name,
    ResourceType? type,
    int? quantity,
    double? productionRate,
  }) {
    return Resource(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      productionRate: productionRate ?? this.productionRate,
    );
  }

  @override
  String toString() =>
      'Resource(id: $id, name: $name, type: $type, quantity: $quantity)';
}

/// Resource type enum
@HiveType(typeId: 1)
enum ResourceType {
  @HiveField(0)
  tier1, // Wood, Stone, Iron

  @HiveField(1)
  tier2, // Steel, Planks, Bricks

  @HiveField(2)
  tier3, // Advanced materials
}
