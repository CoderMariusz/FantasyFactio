import 'dart:math';

import 'package:equatable/equatable.dart';

/// Direction for conveyor movement
enum Direction {
  north,
  south,
  east,
  west;

  /// Get opposite direction
  Direction get opposite => switch (this) {
        Direction.north => Direction.south,
        Direction.south => Direction.north,
        Direction.east => Direction.west,
        Direction.west => Direction.east,
      };

  /// Get delta for this direction
  Point<int> get delta => switch (this) {
        Direction.north => const Point(0, -1),
        Direction.south => const Point(0, 1),
        Direction.east => const Point(1, 0),
        Direction.west => const Point(-1, 0),
      };

  /// Get direction from one point to another (adjacent points only)
  static Direction? fromPoints(Point<int> from, Point<int> to) {
    final dx = to.x - from.x;
    final dy = to.y - from.y;

    if (dx == 1 && dy == 0) return Direction.east;
    if (dx == -1 && dy == 0) return Direction.west;
    if (dx == 0 && dy == 1) return Direction.south;
    if (dx == 0 && dy == -1) return Direction.north;

    return null; // Not adjacent or same point
  }
}

/// Node used in A* pathfinding algorithm
class PathfinderNode extends Equatable implements Comparable<PathfinderNode> {
  /// Grid position of this node
  final Point<int> position;

  /// Cost from start to this node (g-score)
  final double gScore;

  /// Estimated total cost through this node (f-score = g + h)
  final double fScore;

  /// Parent node in the path (for reconstruction)
  final PathfinderNode? parent;

  const PathfinderNode({
    required this.position,
    required this.gScore,
    required this.fScore,
    this.parent,
  });

  /// Create a starting node
  factory PathfinderNode.start(Point<int> position, Point<int> goal) {
    final hScore = _manhattanDistance(position, goal);
    return PathfinderNode(
      position: position,
      gScore: 0,
      fScore: hScore,
    );
  }

  /// Create a neighbor node
  PathfinderNode createNeighbor(Point<int> neighborPos, Point<int> goal) {
    final newGScore = gScore + 1; // Each step costs 1
    final hScore = _manhattanDistance(neighborPos, goal);
    return PathfinderNode(
      position: neighborPos,
      gScore: newGScore,
      fScore: newGScore + hScore,
      parent: this,
    );
  }

  /// Manhattan distance heuristic (admissible for grid-based pathfinding)
  static double _manhattanDistance(Point<int> a, Point<int> b) {
    return ((a.x - b.x).abs() + (a.y - b.y).abs()).toDouble();
  }

  /// Compare by f-score for priority queue ordering
  @override
  int compareTo(PathfinderNode other) {
    final fCompare = fScore.compareTo(other.fScore);
    if (fCompare != 0) return fCompare;
    // Tie-breaker: prefer lower g-score (closer to goal)
    return gScore.compareTo(other.gScore);
  }

  @override
  List<Object?> get props => [position];

  @override
  String toString() =>
      'PathfinderNode(${position.x},${position.y} g:$gScore f:$fScore)';
}

/// Result of pathfinding operation
class PathfindingResult extends Equatable {
  /// Whether a path was found
  final bool success;

  /// The path as list of points (empty if no path found)
  final List<Point<int>> path;

  /// Total distance (number of tiles)
  final int distance;

  /// Estimated travel time in seconds (at 0.5 items/sec = 2 sec per tile)
  final double travelTimeSeconds;

  /// Error message if path not found
  final String? error;

  const PathfindingResult._({
    required this.success,
    required this.path,
    required this.distance,
    required this.travelTimeSeconds,
    this.error,
  });

  /// Create a successful result
  factory PathfindingResult.success(List<Point<int>> path) {
    return PathfindingResult._(
      success: true,
      path: path,
      distance: path.length,
      travelTimeSeconds: path.length * 2.0, // 2 seconds per tile
    );
  }

  /// Create a failure result
  factory PathfindingResult.failure(String error) {
    return PathfindingResult._(
      success: false,
      path: const [],
      distance: 0,
      travelTimeSeconds: 0,
      error: error,
    );
  }

  @override
  List<Object?> get props => [success, path, distance, error];

  @override
  String toString() => success
      ? 'PathfindingResult(${path.length} tiles, ${travelTimeSeconds}s)'
      : 'PathfindingResult(failed: $error)';
}
