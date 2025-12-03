import 'dart:collection';
import 'dart:math';

import '../entities/pathfinder_node.dart';
import '../entities/tile.dart';
import '../entities/building.dart';
import '../entities/building_definition.dart';

/// Configuration for the pathfinder
class PathfinderConfig {
  /// Grid width (number of tiles)
  final int gridWidth;

  /// Grid height (number of tiles)
  final int gridHeight;

  /// Maximum path length to search (performance limit)
  final int maxPathLength;

  /// Whether to prefer straight lines over zigzags
  final bool preferStraightLines;

  const PathfinderConfig({
    this.gridWidth = 50,
    this.gridHeight = 50,
    this.maxPathLength = 100,
    this.preferStraightLines = true,
  });
}

/// Use case for finding optimal conveyor paths using A* algorithm
class FindConveyorPathUseCase {
  final PathfinderConfig config;

  const FindConveyorPathUseCase({
    this.config = const PathfinderConfig(),
  });

  /// Find optimal path from start to end position
  ///
  /// [start] - Starting grid position
  /// [end] - Ending grid position
  /// [occupiedTiles] - Set of occupied tile positions (buildings, other conveyors at max layers)
  /// [buildingFootprints] - Map of building ID to list of tiles it occupies
  PathfindingResult findPath({
    required Point<int> start,
    required Point<int> end,
    required Set<Point<int>> occupiedTiles,
    Map<String, List<Point<int>>>? buildingFootprints,
  }) {
    // Validate start position
    if (!_isValidPosition(start)) {
      return PathfindingResult.failure('Start position is out of bounds');
    }

    // Validate end position
    if (!_isValidPosition(end)) {
      return PathfindingResult.failure('End position is out of bounds');
    }

    // Check if start equals end
    if (start == end) {
      return PathfindingResult.success([start]);
    }

    // Check if start is blocked
    if (occupiedTiles.contains(start)) {
      return PathfindingResult.failure('Start position is blocked');
    }

    // Check if end is blocked
    if (occupiedTiles.contains(end)) {
      return PathfindingResult.failure('End position is blocked');
    }

    // Run A* algorithm
    return _aStarSearch(start, end, occupiedTiles);
  }

  /// Find path between two buildings
  ///
  /// Automatically finds the best output port from source and input port to destination
  PathfindingResult findPathBetweenBuildings({
    required Building source,
    required Building destination,
    required Set<Point<int>> occupiedTiles,
    required GameGrid grid,
  }) {
    // Get source building definition for port locations
    final sourceDef = BuildingDefinitions.getByType(source.type);
    final destDef = BuildingDefinitions.getByType(destination.type);

    // Calculate output port position (edge of source building closest to destination)
    final sourceOutputPort = _getBestOutputPort(source, sourceDef, destination);
    if (sourceOutputPort == null) {
      return PathfindingResult.failure('Source building has no valid output port');
    }

    // Calculate input port position (edge of destination building closest to source)
    final destInputPort = _getBestInputPort(destination, destDef, source);
    if (destInputPort == null) {
      return PathfindingResult.failure('Destination building has no valid input port');
    }

    // Find path between ports
    return findPath(
      start: sourceOutputPort,
      end: destInputPort,
      occupiedTiles: occupiedTiles,
    );
  }

  /// A* search algorithm implementation
  PathfindingResult _aStarSearch(
    Point<int> start,
    Point<int> end,
    Set<Point<int>> occupiedTiles,
  ) {
    // Priority queue (min-heap by f-score)
    final openSet = SplayTreeSet<PathfinderNode>();
    final openSetMap = <Point<int>, PathfinderNode>{};

    // Closed set (already evaluated nodes)
    final closedSet = <Point<int>>{};

    // Best g-score for each position
    final gScores = <Point<int>, double>{};

    // Create starting node
    final startNode = PathfinderNode.start(start, end);
    openSet.add(startNode);
    openSetMap[start] = startNode;
    gScores[start] = 0;

    int iterations = 0;
    final maxIterations = config.maxPathLength * config.maxPathLength;

    while (openSet.isNotEmpty && iterations < maxIterations) {
      iterations++;

      // Get node with lowest f-score
      final current = openSet.first;
      openSet.remove(current);
      openSetMap.remove(current.position);

      // Check if we reached the goal
      if (current.position == end) {
        return PathfindingResult.success(_reconstructPath(current));
      }

      // Add to closed set
      closedSet.add(current.position);

      // Check all neighbors
      for (final direction in Direction.values) {
        final neighborPos = Point(
          current.position.x + direction.delta.x,
          current.position.y + direction.delta.y,
        );

        // Skip if out of bounds
        if (!_isValidPosition(neighborPos)) continue;

        // Skip if already evaluated
        if (closedSet.contains(neighborPos)) continue;

        // Skip if blocked (unless it's the goal)
        if (neighborPos != end && occupiedTiles.contains(neighborPos)) continue;

        // Calculate tentative g-score
        final tentativeGScore = current.gScore + _getMovementCost(current, direction);

        // Check if this is a better path
        final existingGScore = gScores[neighborPos] ?? double.infinity;
        if (tentativeGScore < existingGScore) {
          // This is a better path
          gScores[neighborPos] = tentativeGScore;

          // Remove old node if exists
          final oldNode = openSetMap[neighborPos];
          if (oldNode != null) {
            openSet.remove(oldNode);
          }

          // Create new neighbor node
          final neighbor = current.createNeighbor(neighborPos, end);
          // Adjust f-score if preferring straight lines
          final adjustedNeighbor = config.preferStraightLines
              ? _adjustForStraightLine(neighbor, current, direction, end)
              : neighbor;

          openSet.add(adjustedNeighbor);
          openSetMap[neighborPos] = adjustedNeighbor;
        }
      }
    }

    // No path found
    if (iterations >= maxIterations) {
      return PathfindingResult.failure('Path search exceeded maximum iterations');
    }

    return PathfindingResult.failure('No valid path exists');
  }

  /// Get movement cost (1 for all moves, but can be adjusted)
  double _getMovementCost(PathfinderNode from, Direction direction) {
    return 1.0;
  }

  /// Adjust f-score to prefer straight lines
  PathfinderNode _adjustForStraightLine(
    PathfinderNode node,
    PathfinderNode parent,
    Direction currentDirection,
    Point<int> goal,
  ) {
    // Check if parent had a direction
    if (parent.parent != null) {
      final parentDirection = Direction.fromPoints(
        parent.parent!.position,
        parent.position,
      );

      // If direction changed, add small penalty
      if (parentDirection != null && parentDirection != currentDirection) {
        return PathfinderNode(
          position: node.position,
          gScore: node.gScore,
          fScore: node.fScore + 0.001, // Tiny penalty for turns
          parent: node.parent,
        );
      }
    }

    return node;
  }

  /// Reconstruct path from goal node to start
  List<Point<int>> _reconstructPath(PathfinderNode goalNode) {
    final path = <Point<int>>[];
    PathfinderNode? current = goalNode;

    while (current != null) {
      path.add(current.position);
      current = current.parent;
    }

    return path.reversed.toList();
  }

  /// Check if position is within grid bounds
  bool _isValidPosition(Point<int> pos) {
    return pos.x >= 0 &&
        pos.x < config.gridWidth &&
        pos.y >= 0 &&
        pos.y < config.gridHeight;
  }

  /// Get best output port from source building
  Point<int>? _getBestOutputPort(
    Building source,
    BuildingDefinition sourceDef,
    Building destination,
  ) {
    // Get building footprint
    final sourceX = source.gridPosition.x;
    final sourceY = source.gridPosition.y;
    final width = sourceDef.width;
    final height = sourceDef.height;

    // Calculate center of destination for direction
    final destX = destination.gridPosition.x;
    final destY = destination.gridPosition.y;

    // Determine best edge based on destination direction
    final dx = destX - sourceX;
    final dy = destY - sourceY;

    // Try edges in order of preference based on destination direction
    final edgeOrder = _getEdgeOrder(dx, dy);

    for (final edge in edgeOrder) {
      final port = _getEdgePort(sourceX, sourceY, width, height, edge);
      if (_isValidPosition(port)) {
        // Return position adjacent to the building (outside)
        return Point(
          port.x + edge.delta.x,
          port.y + edge.delta.y,
        );
      }
    }

    return null;
  }

  /// Get best input port to destination building
  Point<int>? _getBestInputPort(
    Building destination,
    BuildingDefinition destDef,
    Building source,
  ) {
    // Get building footprint
    final destX = destination.gridPosition.x;
    final destY = destination.gridPosition.y;
    final width = destDef.width;
    final height = destDef.height;

    // Calculate center of source for direction
    final sourceX = source.gridPosition.x;
    final sourceY = source.gridPosition.y;

    // Determine best edge based on source direction (opposite)
    final dx = sourceX - destX;
    final dy = sourceY - destY;

    // Try edges in order of preference based on source direction
    final edgeOrder = _getEdgeOrder(dx, dy);

    for (final edge in edgeOrder) {
      final port = _getEdgePort(destX, destY, width, height, edge);
      if (_isValidPosition(port)) {
        // Return position adjacent to the building (outside)
        return Point(
          port.x + edge.delta.x,
          port.y + edge.delta.y,
        );
      }
    }

    return null;
  }

  /// Get edge order based on direction preference
  List<Direction> _getEdgeOrder(int dx, int dy) {
    final result = <Direction>[];

    // Primary direction
    if (dx.abs() >= dy.abs()) {
      // Prefer horizontal
      if (dx > 0) {
        result.add(Direction.east);
        result.add(Direction.west);
      } else {
        result.add(Direction.west);
        result.add(Direction.east);
      }
      if (dy > 0) {
        result.add(Direction.south);
        result.add(Direction.north);
      } else {
        result.add(Direction.north);
        result.add(Direction.south);
      }
    } else {
      // Prefer vertical
      if (dy > 0) {
        result.add(Direction.south);
        result.add(Direction.north);
      } else {
        result.add(Direction.north);
        result.add(Direction.south);
      }
      if (dx > 0) {
        result.add(Direction.east);
        result.add(Direction.west);
      } else {
        result.add(Direction.west);
        result.add(Direction.east);
      }
    }

    return result;
  }

  /// Get center point of building edge
  Point<int> _getEdgePort(int x, int y, int width, int height, Direction edge) {
    return switch (edge) {
      Direction.north => Point(x + width ~/ 2, y - 1),
      Direction.south => Point(x + width ~/ 2, y + height),
      Direction.east => Point(x + width, y + height ~/ 2),
      Direction.west => Point(x - 1, y + height ~/ 2),
    };
  }

  /// Get all tiles occupied by a building
  static Set<Point<int>> getBuildingFootprint(Building building) {
    final definition = BuildingDefinitions.getByType(building.type);
    final footprint = <Point<int>>{};

    for (int dx = 0; dx < definition.width; dx++) {
      for (int dy = 0; dy < definition.height; dy++) {
        footprint.add(Point(
          building.gridPosition.x + dx,
          building.gridPosition.y + dy,
        ));
      }
    }

    return footprint;
  }

  /// Get all occupied tiles from a list of buildings
  static Set<Point<int>> getOccupiedTiles(List<Building> buildings) {
    final occupied = <Point<int>>{};

    for (final building in buildings) {
      occupied.addAll(getBuildingFootprint(building));
    }

    return occupied;
  }
}
