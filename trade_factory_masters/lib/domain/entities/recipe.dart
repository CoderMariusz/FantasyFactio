import 'package:equatable/equatable.dart';

/// Represents a stack of resources (resource ID + quantity)
class ResourceStack extends Equatable {
  /// Resource identifier (e.g., 'wood', 'iron_ore')
  final String resourceId;

  /// Quantity of resources
  final int quantity;

  const ResourceStack({
    required this.resourceId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [resourceId, quantity];

  @override
  String toString() => '$quantity x $resourceId';
}

/// Recipe definition for building production
/// Defines inputs, outputs, and cycle time for a production process
class Recipe extends Equatable {
  /// Unique identifier for this recipe
  final String id;

  /// Human-readable name
  final String name;

  /// Required input resources
  final List<ResourceStack> inputs;

  /// Output resources produced
  final List<ResourceStack> outputs;

  /// Time in seconds to complete one cycle
  final double cycleTime;

  /// Skill that affects this recipe (optional)
  final String? skillModifier;

  const Recipe({
    required this.id,
    required this.name,
    required this.inputs,
    required this.outputs,
    required this.cycleTime,
    this.skillModifier,
  });

  /// Check if player has all required inputs
  bool canExecute(Map<String, int> inventory) {
    for (final input in inputs) {
      final available = inventory[input.resourceId] ?? 0;
      if (available < input.quantity) {
        return false;
      }
    }
    return true;
  }

  @override
  List<Object?> get props => [id, name, inputs, outputs, cycleTime, skillModifier];

  @override
  String toString() => 'Recipe($name: ${inputs.join(" + ")} → ${outputs.join(" + ")} in ${cycleTime}s)';
}
