import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/pathfinder_node.dart';
import 'package:trade_factory_masters/domain/entities/building.dart';
import 'package:trade_factory_masters/domain/usecases/find_conveyor_path_usecase.dart';

void main() {
  group('Direction', () {
    test('opposite should return correct opposite direction', () {
      expect(Direction.north.opposite, equals(Direction.south));
      expect(Direction.south.opposite, equals(Direction.north));
      expect(Direction.east.opposite, equals(Direction.west));
      expect(Direction.west.opposite, equals(Direction.east));
    });

    test('delta should return correct movement vector', () {
      expect(Direction.north.delta, equals(const Point(0, -1)));
      expect(Direction.south.delta, equals(const Point(0, 1)));
      expect(Direction.east.delta, equals(const Point(1, 0)));
      expect(Direction.west.delta, equals(const Point(-1, 0)));
    });

    test('fromPoints should return correct direction for adjacent points', () {
      expect(
        Direction.fromPoints(const Point(5, 5), const Point(6, 5)),
        equals(Direction.east),
      );
      expect(
        Direction.fromPoints(const Point(5, 5), const Point(4, 5)),
        equals(Direction.west),
      );
      expect(
        Direction.fromPoints(const Point(5, 5), const Point(5, 6)),
        equals(Direction.south),
      );
      expect(
        Direction.fromPoints(const Point(5, 5), const Point(5, 4)),
        equals(Direction.north),
      );
    });

    test('fromPoints should return null for non-adjacent points', () {
      expect(Direction.fromPoints(const Point(5, 5), const Point(5, 5)), isNull);
      expect(Direction.fromPoints(const Point(5, 5), const Point(7, 5)), isNull);
      expect(Direction.fromPoints(const Point(5, 5), const Point(6, 6)), isNull);
    });
  });

  group('PathfinderNode', () {
    test('start factory should create node with correct values', () {
      final node = PathfinderNode.start(const Point(0, 0), const Point(5, 5));

      expect(node.position, equals(const Point(0, 0)));
      expect(node.gScore, equals(0));
      expect(node.fScore, equals(10)); // Manhattan distance 5+5=10
      expect(node.parent, isNull);
    });

    test('createNeighbor should create node with parent reference', () {
      final start = PathfinderNode.start(const Point(0, 0), const Point(5, 0));
      final neighbor = start.createNeighbor(const Point(1, 0), const Point(5, 0));

      expect(neighbor.position, equals(const Point(1, 0)));
      expect(neighbor.gScore, equals(1));
      expect(neighbor.fScore, equals(5)); // g=1 + h=4
      expect(neighbor.parent, equals(start));
    });

    test('compareTo should order by f-score', () {
      final nodeA = PathfinderNode(
        position: const Point(0, 0),
        gScore: 5,
        fScore: 10,
      );
      final nodeB = PathfinderNode(
        position: const Point(1, 0),
        gScore: 3,
        fScore: 8,
      );

      expect(nodeB.compareTo(nodeA), lessThan(0)); // B has lower f-score
      expect(nodeA.compareTo(nodeB), greaterThan(0));
    });

    test('equality should be based on position only', () {
      final nodeA = PathfinderNode(
        position: const Point(5, 5),
        gScore: 10,
        fScore: 20,
      );
      final nodeB = PathfinderNode(
        position: const Point(5, 5),
        gScore: 5,
        fScore: 15,
      );

      expect(nodeA, equals(nodeB));
      expect(nodeA.hashCode, equals(nodeB.hashCode));
    });
  });

  group('PathfindingResult', () {
    test('success should create result with path details', () {
      final path = [
        const Point<int>(0, 0),
        const Point<int>(1, 0),
        const Point<int>(2, 0),
      ];
      final result = PathfindingResult.success(path);

      expect(result.success, isTrue);
      expect(result.path, equals(path));
      expect(result.distance, equals(3));
      expect(result.travelTimeSeconds, equals(6.0)); // 3 tiles * 2 sec
      expect(result.error, isNull);
    });

    test('failure should create result with error message', () {
      final result = PathfindingResult.failure('No path found');

      expect(result.success, isFalse);
      expect(result.path, isEmpty);
      expect(result.distance, equals(0));
      expect(result.travelTimeSeconds, equals(0));
      expect(result.error, equals('No path found'));
    });
  });

  group('FindConveyorPathUseCase', () {
    late FindConveyorPathUseCase pathfinder;

    setUp(() {
      pathfinder = const FindConveyorPathUseCase(
        config: PathfinderConfig(
          gridWidth: 20,
          gridHeight: 20,
          maxPathLength: 50,
        ),
      );
    });

    group('Basic Pathfinding', () {
      test('should find simple 5-tile straight path', () {
        final result = pathfinder.findPath(
          start: const Point(0, 0),
          end: const Point(4, 0),
          occupiedTiles: {},
        );

        expect(result.success, isTrue);
        expect(result.distance, equals(5)); // Start + 4 steps
        expect(result.path.first, equals(const Point(0, 0)));
        expect(result.path.last, equals(const Point(4, 0)));
      });

      test('should find diagonal path (L-shaped)', () {
        final result = pathfinder.findPath(
          start: const Point(0, 0),
          end: const Point(3, 3),
          occupiedTiles: {},
        );

        expect(result.success, isTrue);
        expect(result.distance, equals(7)); // Manhattan distance + 1 (start)
        expect(result.path.first, equals(const Point(0, 0)));
        expect(result.path.last, equals(const Point(3, 3)));
      });

      test('should return same point for start equals end', () {
        final result = pathfinder.findPath(
          start: const Point(5, 5),
          end: const Point(5, 5),
          occupiedTiles: {},
        );

        expect(result.success, isTrue);
        expect(result.distance, equals(1));
        expect(result.path, equals([const Point(5, 5)]));
      });
    });

    group('Obstacle Avoidance', () {
      test('should find path around single obstacle', () {
        // Obstacle at (2, 0) - path must go around
        final result = pathfinder.findPath(
          start: const Point(0, 0),
          end: const Point(4, 0),
          occupiedTiles: {const Point(2, 0)},
        );

        expect(result.success, isTrue);
        expect(result.path.contains(const Point(2, 0)), isFalse);
        expect(result.path.first, equals(const Point(0, 0)));
        expect(result.path.last, equals(const Point(4, 0)));
      });

      test('should find path around building footprint (2x2)', () {
        // Building occupies (5,5), (6,5), (5,6), (6,6)
        final buildingTiles = {
          const Point<int>(5, 5),
          const Point<int>(6, 5),
          const Point<int>(5, 6),
          const Point<int>(6, 6),
        };

        final result = pathfinder.findPath(
          start: const Point(4, 5),
          end: const Point(7, 5),
          occupiedTiles: buildingTiles,
        );

        expect(result.success, isTrue);
        // Path should not cross building
        for (final tile in buildingTiles) {
          expect(result.path.contains(tile), isFalse);
        }
      });

      test('should find 25-tile path with obstacles', () {
        // Create obstacles but leave path possible
        final obstacles = <Point<int>>{};
        for (int x = 5; x < 15; x++) {
          obstacles.add(Point(x, 10)); // Wall with gap
        }
        obstacles.remove(const Point(10, 10)); // Gap in wall

        final result = pathfinder.findPath(
          start: const Point(10, 5),
          end: const Point(10, 15),
          occupiedTiles: obstacles,
        );

        expect(result.success, isTrue);
        expect(result.distance, lessThanOrEqualTo(30)); // Reasonable path
      });
    });

    group('Edge Cases', () {
      test('should fail when start is out of bounds', () {
        final result = pathfinder.findPath(
          start: const Point(-1, 0),
          end: const Point(5, 5),
          occupiedTiles: {},
        );

        expect(result.success, isFalse);
        expect(result.error, contains('out of bounds'));
      });

      test('should fail when end is out of bounds', () {
        final result = pathfinder.findPath(
          start: const Point(0, 0),
          end: const Point(100, 100),
          occupiedTiles: {},
        );

        expect(result.success, isFalse);
        expect(result.error, contains('out of bounds'));
      });

      test('should fail when start is blocked', () {
        final result = pathfinder.findPath(
          start: const Point(5, 5),
          end: const Point(10, 10),
          occupiedTiles: {const Point(5, 5)},
        );

        expect(result.success, isFalse);
        expect(result.error, contains('blocked'));
      });

      test('should fail when end is blocked', () {
        final result = pathfinder.findPath(
          start: const Point(0, 0),
          end: const Point(5, 5),
          occupiedTiles: {const Point(5, 5)},
        );

        expect(result.success, isFalse);
        expect(result.error, contains('blocked'));
      });

      test('should return null when path is completely blocked', () {
        // Create a wall surrounding the end point
        final walls = <Point<int>>{};
        for (int x = 4; x <= 6; x++) {
          for (int y = 4; y <= 6; y++) {
            if (x != 5 || y != 5) {
              walls.add(Point(x, y));
            }
          }
        }

        final result = pathfinder.findPath(
          start: const Point(0, 0),
          end: const Point(5, 5),
          occupiedTiles: walls,
        );

        expect(result.success, isFalse);
        expect(result.error, contains('No valid path'));
      });
    });

    group('Grid Boundaries', () {
      test('should respect grid boundaries', () {
        final result = pathfinder.findPath(
          start: const Point(0, 0),
          end: const Point(19, 19),
          occupiedTiles: {},
        );

        expect(result.success, isTrue);
        // All path points should be within bounds
        for (final point in result.path) {
          expect(point.x, greaterThanOrEqualTo(0));
          expect(point.x, lessThan(20));
          expect(point.y, greaterThanOrEqualTo(0));
          expect(point.y, lessThan(20));
        }
      });

      test('should find path along grid edge', () {
        final result = pathfinder.findPath(
          start: const Point(0, 0),
          end: const Point(0, 10),
          occupiedTiles: {},
        );

        expect(result.success, isTrue);
        expect(result.distance, equals(11)); // 0 to 10 inclusive
        // All points should be on x=0
        for (final point in result.path) {
          expect(point.x, equals(0));
        }
      });
    });

    group('Performance', () {
      test('should find 50-tile path under 100ms', () {
        final largeFinder = const FindConveyorPathUseCase(
          config: PathfinderConfig(
            gridWidth: 50,
            gridHeight: 50,
            maxPathLength: 100,
          ),
        );

        final stopwatch = Stopwatch()..start();

        final result = largeFinder.findPath(
          start: const Point(0, 0),
          end: const Point(49, 49),
          occupiedTiles: {},
        );

        stopwatch.stop();

        expect(result.success, isTrue);
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should handle 50x50 grid with sparse obstacles', () {
        final largeFinder = const FindConveyorPathUseCase(
          config: PathfinderConfig(
            gridWidth: 50,
            gridHeight: 50,
            maxPathLength: 150,
          ),
        );

        // Add random obstacles (10% coverage)
        final random = Random(42);
        final obstacles = <Point<int>>{};
        for (int i = 0; i < 250; i++) {
          obstacles.add(Point(random.nextInt(50), random.nextInt(50)));
        }
        // Ensure start and end are not blocked
        obstacles.remove(const Point(0, 0));
        obstacles.remove(const Point(49, 49));

        final stopwatch = Stopwatch()..start();

        final result = largeFinder.findPath(
          start: const Point(0, 0),
          end: const Point(49, 49),
          occupiedTiles: obstacles,
        );

        stopwatch.stop();

        // Path might not exist due to random obstacles
        if (result.success) {
          expect(stopwatch.elapsedMilliseconds, lessThan(200));
          // Path should avoid obstacles
          for (final tile in obstacles) {
            expect(result.path.contains(tile), isFalse);
          }
        }
      });
    });

    group('Path Optimization', () {
      test('should prefer straight lines over zigzags', () {
        final result = pathfinder.findPath(
          start: const Point(0, 0),
          end: const Point(10, 0),
          occupiedTiles: {},
        );

        expect(result.success, isTrue);

        // Count direction changes
        int directionChanges = 0;
        Direction? lastDirection;

        for (int i = 1; i < result.path.length; i++) {
          final direction = Direction.fromPoints(
            result.path[i - 1],
            result.path[i],
          );
          if (lastDirection != null && direction != lastDirection) {
            directionChanges++;
          }
          lastDirection = direction;
        }

        // Straight path should have 0 direction changes
        expect(directionChanges, equals(0));
      });

      test('should minimize total tiles (shortest path)', () {
        final result = pathfinder.findPath(
          start: const Point(0, 0),
          end: const Point(5, 5),
          occupiedTiles: {},
        );

        expect(result.success, isTrue);
        // Optimal Manhattan distance + 1 for start
        expect(result.distance, equals(11)); // |5-0| + |5-0| + 1
      });
    });
  });

  group('Static Helper Methods', () {
    test('getBuildingFootprint should return all tiles for 2x2 building', () {
      final building = Building(
        id: 'test',
        type: BuildingType.mining,
        level: 1,
        gridPosition: const GridPosition(x: 5, y: 5),
        production: const ProductionConfig(baseRate: 1.0, resourceType: 'Coal'),
        upgradeConfig: const UpgradeConfig(baseCost: 100, costIncrement: 50),
        lastCollected: DateTime.now(),
        isActive: true,
      );

      final footprint = FindConveyorPathUseCase.getBuildingFootprint(building);

      expect(footprint.length, equals(4)); // 2x2
      expect(footprint.contains(const Point(5, 5)), isTrue);
      expect(footprint.contains(const Point(6, 5)), isTrue);
      expect(footprint.contains(const Point(5, 6)), isTrue);
      expect(footprint.contains(const Point(6, 6)), isTrue);
    });

    test('getOccupiedTiles should combine multiple buildings', () {
      final buildings = [
        Building(
          id: 'building1',
          type: BuildingType.mining,
          level: 1,
          gridPosition: const GridPosition(x: 0, y: 0),
          production:
              const ProductionConfig(baseRate: 1.0, resourceType: 'Coal'),
          upgradeConfig: const UpgradeConfig(baseCost: 100, costIncrement: 50),
          lastCollected: DateTime.now(),
          isActive: true,
        ),
        Building(
          id: 'building2',
          type: BuildingType.mining,
          level: 1,
          gridPosition: const GridPosition(x: 10, y: 10),
          production:
              const ProductionConfig(baseRate: 1.0, resourceType: 'Coal'),
          upgradeConfig: const UpgradeConfig(baseCost: 100, costIncrement: 50),
          lastCollected: DateTime.now(),
          isActive: true,
        ),
      ];

      final occupied = FindConveyorPathUseCase.getOccupiedTiles(buildings);

      expect(occupied.length, equals(8)); // 2 buildings * 4 tiles each
      expect(occupied.contains(const Point(0, 0)), isTrue);
      expect(occupied.contains(const Point(10, 10)), isTrue);
    });
  });

  group('Manhattan Heuristic', () {
    test('should calculate correct distance for horizontal path', () {
      final start = PathfinderNode.start(const Point(0, 0), const Point(10, 0));
      expect(start.fScore, equals(10)); // 10 tiles horizontal
    });

    test('should calculate correct distance for vertical path', () {
      final start = PathfinderNode.start(const Point(0, 0), const Point(0, 10));
      expect(start.fScore, equals(10)); // 10 tiles vertical
    });

    test('should calculate correct distance for diagonal', () {
      final start = PathfinderNode.start(const Point(0, 0), const Point(5, 5));
      expect(start.fScore, equals(10)); // 5+5 Manhattan
    });
  });
}
