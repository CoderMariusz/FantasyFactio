import 'package:equatable/equatable.dart';

/// Base class for building placement rules
/// Determines where a building can be placed on the grid
abstract class PlacementRule extends Equatable {
  const PlacementRule();

  /// Check if placement is valid at the given tile
  /// Returns true if building can be placed, false otherwise
  bool canPlace({
    required String tileBiom,
    required bool isOccupied,
    required int currentLayers,
  });

  /// Get human-readable description of the rule
  String get description;
}

/// Biom-restricted placement rule
/// Building can only be placed on specific biom types
class BiomRestrictedRule extends PlacementRule {
  /// List of allowed biom types (e.g., ['koppalnia', 'las'])
  final List<String> allowedBioms;

  const BiomRestrictedRule(this.allowedBioms);

  @override
  bool canPlace({
    required String tileBiom,
    required bool isOccupied,
    required int currentLayers,
  }) {
    if (isOccupied) return false;
    return allowedBioms.contains(tileBiom);
  }

  @override
  String get description => 'Must be placed on: ${allowedBioms.join(", ")}';

  @override
  List<Object?> get props => [allowedBioms];
}

/// Flexible placement rule
/// Building can be placed on any unoccupied tile
class FlexiblePlacementRule extends PlacementRule {
  const FlexiblePlacementRule();

  @override
  bool canPlace({
    required String tileBiom,
    required bool isOccupied,
    required int currentLayers,
  }) {
    return !isOccupied;
  }

  @override
  String get description => 'Can be placed anywhere';

  @override
  List<Object?> get props => [];
}

/// Layering rule for conveyors
/// Allows placement on tiles with existing buildings up to max layers
class LayeringRule extends PlacementRule {
  /// Maximum number of layers allowed
  final int maxLayers;

  const LayeringRule({this.maxLayers = 2});

  @override
  bool canPlace({
    required String tileBiom,
    required bool isOccupied,
    required int currentLayers,
  }) {
    return currentLayers < maxLayers;
  }

  @override
  String get description => 'Max $maxLayers layers allowed';

  @override
  List<Object?> get props => [maxLayers];
}
