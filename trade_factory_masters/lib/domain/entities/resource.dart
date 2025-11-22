import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'resource.g.dart';

/// Resource entity for Trade Factory Masters
/// Represents a single resource type (Wood, Stone, Iron, etc.)
@HiveType(typeId: 0)
class Resource extends Equatable {
  /// Unique identifier for this resource
  @HiveField(0)
  final String id;

  /// Display name shown to player (e.g., "Wood", "Stone", "Iron Ore")
  @HiveField(1)
  final String displayName;

  /// Resource tier (tier1, tier2, tier3)
  @HiveField(2)
  final ResourceType type;

  /// Current amount of this resource
  @HiveField(3)
  final int amount;

  /// Maximum storage capacity for this resource
  @HiveField(4)
  final int maxCapacity;

  /// Path to icon asset (e.g., "assets/images/resources/wood.png")
  @HiveField(5)
  final String iconPath;

  const Resource({
    required this.id,
    required this.displayName,
    required this.type,
    this.amount = 0,
    this.maxCapacity = 1000,
    required this.iconPath,
  });

  /// Check if resource is at maximum capacity
  bool get isFull => amount >= maxCapacity;

  /// Calculate remaining capacity
  int get remainingCapacity => maxCapacity - amount;

  /// Create a copy with modified fields
  Resource copyWith({
    String? id,
    String? displayName,
    ResourceType? type,
    int? amount,
    int? maxCapacity,
    String? iconPath,
  }) {
    return Resource(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      iconPath: iconPath ?? this.iconPath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        type,
        amount,
        maxCapacity,
        iconPath,
      ];

  @override
  String toString() =>
      'Resource(id: $id, displayName: $displayName, amount: $amount/$maxCapacity)';
}

/// Resource type enum
/// Defines progression tiers for resources
@HiveType(typeId: 1)
enum ResourceType {
  /// Tier 1: Basic resources (Wood, Stone, Iron Ore)
  @HiveField(0)
  tier1,

  /// Tier 2: Processed materials (Steel, Planks, Bricks)
  @HiveField(1)
  tier2,

  /// Tier 3: Advanced materials (unlocked via progression)
  @HiveField(2)
  tier3,
}
