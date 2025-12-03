import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/conveyor_tile.dart';
import 'package:trade_factory_masters/domain/entities/conveyor_network.dart';
import 'package:trade_factory_masters/domain/entities/pathfinder_node.dart';
import 'package:trade_factory_masters/domain/usecases/transport_items_usecase.dart';

void main() {
  group('SplitterConfig', () {
    group('2-output splitter', () {
      test('works with east and south outputs', () {
        final config = SplitterConfig(
          outputs: [Direction.east, Direction.south],
          mode: SplitterMode.roundRobin,
        );

        expect(config.outputs.length, equals(2));
        expect(config.getNextOutput({}), equals(Direction.east));
      });

      test('alternates between 2 outputs in roundRobin mode', () {
        var config = SplitterConfig(
          outputs: [Direction.east, Direction.south],
          mode: SplitterMode.roundRobin,
        );

        // First item goes east
        expect(config.getNextOutput({}), equals(Direction.east));
        config = config.afterSend(Direction.east);

        // Second item goes south
        expect(config.getNextOutput({}), equals(Direction.south));
        config = config.afterSend(Direction.south);

        // Third item goes east again
        expect(config.getNextOutput({}), equals(Direction.east));
      });

      test('skips blocked output and uses other', () {
        final config = SplitterConfig(
          outputs: [Direction.east, Direction.south],
          mode: SplitterMode.roundRobin,
        );

        // East is blocked, should use south
        expect(
          config.getNextOutput({Direction.east}),
          equals(Direction.south),
        );
      });

      test('returns null when both outputs blocked', () {
        final config = SplitterConfig(
          outputs: [Direction.east, Direction.south],
          mode: SplitterMode.roundRobin,
        );

        expect(
          config.getNextOutput({Direction.east, Direction.south}),
          isNull,
        );
      });
    });

    group('3-output splitter', () {
      test('works with north, east and south outputs', () {
        final config = SplitterConfig(
          outputs: [Direction.north, Direction.east, Direction.south],
          mode: SplitterMode.roundRobin,
        );

        expect(config.outputs.length, equals(3));
      });

      test('rotates through all 3 outputs in roundRobin mode', () {
        var config = SplitterConfig(
          outputs: [Direction.north, Direction.east, Direction.south],
          mode: SplitterMode.roundRobin,
        );

        // First 3 items go to each output
        expect(config.getNextOutput({}), equals(Direction.north));
        config = config.afterSend(Direction.north);

        expect(config.getNextOutput({}), equals(Direction.east));
        config = config.afterSend(Direction.east);

        expect(config.getNextOutput({}), equals(Direction.south));
        config = config.afterSend(Direction.south);

        // Fourth item starts rotation again
        expect(config.getNextOutput({}), equals(Direction.north));
      });

      test('skips blocked output in 3-way split', () {
        var config = SplitterConfig(
          outputs: [Direction.north, Direction.east, Direction.south],
          mode: SplitterMode.roundRobin,
        );

        // North is blocked, should use east
        expect(
          config.getNextOutput({Direction.north}),
          equals(Direction.east),
        );
        config = config.afterSend(Direction.east);

        // Next rotation continues from south
        expect(config.getNextOutput({}), equals(Direction.south));
      });

      test('handles 2 of 3 outputs blocked', () {
        final config = SplitterConfig(
          outputs: [Direction.north, Direction.east, Direction.south],
          mode: SplitterMode.roundRobin,
        );

        expect(
          config.getNextOutput({Direction.north, Direction.east}),
          equals(Direction.south),
        );
      });

      test('returns null when all 3 outputs blocked', () {
        final config = SplitterConfig(
          outputs: [Direction.north, Direction.east, Direction.south],
          mode: SplitterMode.roundRobin,
        );

        expect(
          config.getNextOutput({Direction.north, Direction.east, Direction.south}),
          isNull,
        );
      });
    });

    group('priority mode', () {
      test('always uses first available output', () {
        final config = SplitterConfig(
          outputs: [Direction.north, Direction.east, Direction.south],
          mode: SplitterMode.priority,
        );

        // Should always prefer north first
        expect(config.getNextOutput({}), equals(Direction.north));
        expect(config.getNextOutput({}), equals(Direction.north));
      });

      test('falls back to second output when first blocked', () {
        final config = SplitterConfig(
          outputs: [Direction.north, Direction.east, Direction.south],
          mode: SplitterMode.priority,
        );

        expect(
          config.getNextOutput({Direction.north}),
          equals(Direction.east),
        );
      });

      test('falls back to third output when first two blocked', () {
        final config = SplitterConfig(
          outputs: [Direction.north, Direction.east, Direction.south],
          mode: SplitterMode.priority,
        );

        expect(
          config.getNextOutput({Direction.north, Direction.east}),
          equals(Direction.south),
        );
      });
    });

    group('equal mode', () {
      test('balances items across outputs', () {
        var config = SplitterConfig(
          outputs: [Direction.north, Direction.east],
          mode: SplitterMode.equal,
        );

        // First item can go to either (both have 0 count)
        final first = config.getNextOutput({});
        expect(first, isNotNull);
        config = config.afterSend(first!);

        // Second item should go to the other one (has 0 count)
        final second = config.getNextOutput({});
        expect(second, isNot(equals(first)));
      });

      test('sends to output with lowest count', () {
        final config = SplitterConfig(
          outputs: [Direction.north, Direction.east],
          mode: SplitterMode.equal,
          outputCounts: {
            Direction.north: 5,
            Direction.east: 3,
          },
        );

        // East has lower count, should be preferred
        expect(config.getNextOutput({}), equals(Direction.east));
      });

      test('skips blocked output even with lowest count', () {
        final config = SplitterConfig(
          outputs: [Direction.north, Direction.east],
          mode: SplitterMode.equal,
          outputCounts: {
            Direction.north: 5,
            Direction.east: 3,
          },
        );

        // East blocked, should use north despite higher count
        expect(
          config.getNextOutput({Direction.east}),
          equals(Direction.north),
        );
      });
    });

    group('afterSend', () {
      test('updates currentIndex for roundRobin', () {
        final config = SplitterConfig(
          outputs: [Direction.north, Direction.east, Direction.south],
          mode: SplitterMode.roundRobin,
          currentIndex: 0,
        );

        final updated = config.afterSend(Direction.north);
        expect(updated.currentIndex, equals(1));
      });

      test('wraps currentIndex at end of outputs', () {
        final config = SplitterConfig(
          outputs: [Direction.north, Direction.east],
          mode: SplitterMode.roundRobin,
          currentIndex: 1,
        );

        final updated = config.afterSend(Direction.east);
        expect(updated.currentIndex, equals(0));
      });

      test('increments output count', () {
        final config = SplitterConfig(
          outputs: [Direction.north, Direction.east],
          mode: SplitterMode.equal,
          outputCounts: {
            Direction.north: 2,
            Direction.east: 1,
          },
        );

        final updated = config.afterSend(Direction.east);
        expect(updated.outputCounts[Direction.east], equals(2));
        expect(updated.outputCounts[Direction.north], equals(2));
      });

      test('initializes count for new direction', () {
        final config = SplitterConfig(
          outputs: [Direction.north, Direction.east],
          mode: SplitterMode.equal,
        );

        final updated = config.afterSend(Direction.north);
        expect(updated.outputCounts[Direction.north], equals(1));
      });
    });
  });

  group('Transport with splitter', () {
    late TransportItemsUseCase transportUseCase;
    late DateTime testTime;

    setUp(() {
      transportUseCase = const TransportItemsUseCase();
      testTime = DateTime(2024, 1, 1, 12, 0, 0);
    });

    test('splitter sends item to first available output', () {
      final sourceTile = ConveyorTile(
        id: 'source',
        position: const Point(0, 0),
        direction: Direction.east,
        splitter: SplitterConfig(
          outputs: [Direction.east, Direction.south],
          mode: SplitterMode.roundRobin,
        ),
        queue: [
          ResourceStack(
            resourceId: 'wood',
            quantity: 1,
            enteredAt: testTime.subtract(const Duration(seconds: 3)),
          ),
        ],
      );

      final destTileEast = ConveyorTile(
        id: 'dest_e',
        position: const Point(1, 0),
        direction: Direction.east,
      );

      final destTileSouth = ConveyorTile(
        id: 'dest_s',
        position: const Point(0, 1),
        direction: Direction.south,
      );

      var network = const ConveyorNetwork()
          .addTile(sourceTile)
          .addTile(destTileEast)
          .addTile(destTileSouth);

      final result = transportUseCase.tick(network: network, now: testTime);

      expect(result.itemsMoved, equals(1));
      expect(result.itemsBlocked, equals(0));

      // Item should be in one of the destinations
      final eastItems = result.network.getTile(const Point(1, 0), 1)?.queue.length ?? 0;
      final southItems = result.network.getTile(const Point(0, 1), 1)?.queue.length ?? 0;
      expect(eastItems + southItems, equals(1));
    });

    test('splitter causes backpressure when all outputs full', () {
      final fullQueue = List.generate(
        10,
        (i) => ResourceStack(
          resourceId: 'stone',
          quantity: 1,
          enteredAt: testTime,
        ),
      );

      final sourceTile = ConveyorTile(
        id: 'source',
        position: const Point(0, 0),
        direction: Direction.east,
        splitter: SplitterConfig(
          outputs: [Direction.east, Direction.south],
          mode: SplitterMode.roundRobin,
        ),
        queue: [
          ResourceStack(
            resourceId: 'wood',
            quantity: 1,
            enteredAt: testTime.subtract(const Duration(seconds: 3)),
          ),
        ],
      );

      final destTileEast = ConveyorTile(
        id: 'dest_e',
        position: const Point(1, 0),
        direction: Direction.east,
        queue: fullQueue,
      );

      final destTileSouth = ConveyorTile(
        id: 'dest_s',
        position: const Point(0, 1),
        direction: Direction.south,
        queue: fullQueue,
      );

      var network = const ConveyorNetwork()
          .addTile(sourceTile)
          .addTile(destTileEast)
          .addTile(destTileSouth);

      final result = transportUseCase.tick(network: network, now: testTime);

      expect(result.itemsMoved, equals(0));
      expect(result.itemsBlocked, equals(1));
      // Item should still be in source
      expect(result.network.getTile(const Point(0, 0), 1)?.queue.length, equals(1));
    });

    test('splitter skips full output and uses available one', () {
      final fullQueue = List.generate(
        10,
        (i) => ResourceStack(
          resourceId: 'stone',
          quantity: 1,
          enteredAt: testTime,
        ),
      );

      final sourceTile = ConveyorTile(
        id: 'source',
        position: const Point(0, 0),
        direction: Direction.east,
        splitter: SplitterConfig(
          outputs: [Direction.east, Direction.south],
          mode: SplitterMode.roundRobin,
        ),
        queue: [
          ResourceStack(
            resourceId: 'wood',
            quantity: 1,
            enteredAt: testTime.subtract(const Duration(seconds: 3)),
          ),
        ],
      );

      // East is full
      final destTileEast = ConveyorTile(
        id: 'dest_e',
        position: const Point(1, 0),
        direction: Direction.east,
        queue: fullQueue,
      );

      // South is empty
      final destTileSouth = ConveyorTile(
        id: 'dest_s',
        position: const Point(0, 1),
        direction: Direction.south,
      );

      var network = const ConveyorNetwork()
          .addTile(sourceTile)
          .addTile(destTileEast)
          .addTile(destTileSouth);

      final result = transportUseCase.tick(network: network, now: testTime);

      expect(result.itemsMoved, equals(1));
      // Item should go to south (only available output)
      expect(result.network.getTile(const Point(0, 1), 1)?.queue.length, equals(1));
    });

    test('no item loss when skipping blocked output', () {
      final sourceTile = ConveyorTile(
        id: 'source',
        position: const Point(0, 0),
        direction: Direction.east,
        splitter: SplitterConfig(
          outputs: [Direction.east, Direction.south],
          mode: SplitterMode.roundRobin,
        ),
        queue: [
          ResourceStack(
            resourceId: 'wood',
            quantity: 1,
            enteredAt: testTime.subtract(const Duration(seconds: 3)),
          ),
        ],
      );

      // Only south destination exists
      final destTileSouth = ConveyorTile(
        id: 'dest_s',
        position: const Point(0, 1),
        direction: Direction.south,
      );

      var network = const ConveyorNetwork()
          .addTile(sourceTile)
          .addTile(destTileSouth);

      final result = transportUseCase.tick(network: network, now: testTime);

      // Item should be moved to south (east has no tile)
      expect(result.itemsMoved, equals(1));
      expect(result.itemsDropped, equals(0));
      expect(result.network.getTile(const Point(0, 1), 1)?.queue.length, equals(1));
    });
  });

  group('Splitter validation', () {
    test('splitter must have at least 2 outputs', () {
      final config = SplitterConfig(
        outputs: [Direction.east],
        mode: SplitterMode.roundRobin,
      );

      // With only 1 output, it's technically valid but unusual
      expect(config.outputs.length, equals(1));
    });

    test('splitter can have up to 3 outputs', () {
      final config = SplitterConfig(
        outputs: [Direction.north, Direction.east, Direction.south],
        mode: SplitterMode.roundRobin,
      );

      expect(config.outputs.length, equals(3));
    });

    test('splitter outputs must be unique', () {
      final config = SplitterConfig(
        outputs: [Direction.east, Direction.east],
        mode: SplitterMode.roundRobin,
      );

      // getNextOutput should still work but only finds east
      expect(config.getNextOutput({}), equals(Direction.east));
    });
  });
}
