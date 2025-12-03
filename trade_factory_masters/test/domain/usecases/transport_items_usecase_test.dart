import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/conveyor_tile.dart';
import 'package:trade_factory_masters/domain/entities/conveyor_network.dart';
import 'package:trade_factory_masters/domain/entities/pathfinder_node.dart';
import 'package:trade_factory_masters/domain/usecases/transport_items_usecase.dart';

void main() {
  group('ResourceStack', () {
    test('single factory should create stack with quantity 1', () {
      final stack = ResourceStack.single('Coal');

      expect(stack.resourceId, equals('Coal'));
      expect(stack.quantity, equals(1));
    });

    test('getTimeOnTile should calculate elapsed time', () {
      final enteredAt = DateTime.now().subtract(const Duration(seconds: 5));
      final stack = ResourceStack(
        resourceId: 'Coal',
        quantity: 1,
        enteredAt: enteredAt,
      );

      final elapsed = stack.getTimeOnTile(DateTime.now());
      expect(elapsed, greaterThanOrEqualTo(5000));
    });

    test('resetEntryTime should create new stack with current time', () {
      final oldStack = ResourceStack(
        resourceId: 'Coal',
        quantity: 1,
        enteredAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      final newStack = oldStack.resetEntryTime();

      expect(newStack.resourceId, equals(oldStack.resourceId));
      expect(newStack.quantity, equals(oldStack.quantity));
      expect(newStack.enteredAt.isAfter(oldStack.enteredAt), isTrue);
    });
  });

  group('ConveyorFilter', () {
    test('allowAll should accept any resource', () {
      const filter = ConveyorFilter();

      expect(filter.canPass('Coal'), isTrue);
      expect(filter.canPass('Wood'), isTrue);
      expect(filter.canPass('Iron Bar'), isTrue);
    });

    test('whitelist should only accept specified resources', () {
      final filter = ConveyorFilter.whitelist(['Coal', 'Wood']);

      expect(filter.canPass('Coal'), isTrue);
      expect(filter.canPass('Wood'), isTrue);
      expect(filter.canPass('Iron Bar'), isFalse);
    });

    test('blacklist should reject specified resources', () {
      final filter = ConveyorFilter.blacklist(['Coal']);

      expect(filter.canPass('Coal'), isFalse);
      expect(filter.canPass('Wood'), isTrue);
      expect(filter.canPass('Iron Bar'), isTrue);
    });

    test('single should only accept one specific resource', () {
      final filter = ConveyorFilter.single('Coal');

      expect(filter.canPass('Coal'), isTrue);
      expect(filter.canPass('Wood'), isFalse);
    });
  });

  group('SplitterConfig', () {
    test('roundRobin should distribute items in rotation', () {
      var config = SplitterConfig(
        outputs: [Direction.north, Direction.east, Direction.south],
        mode: SplitterMode.roundRobin,
      );

      // First item goes north
      expect(config.getNextOutput({}), equals(Direction.north));
      config = config.afterSend(Direction.north);

      // Second item goes east
      expect(config.getNextOutput({}), equals(Direction.east));
      config = config.afterSend(Direction.east);

      // Third item goes south
      expect(config.getNextOutput({}), equals(Direction.south));
      config = config.afterSend(Direction.south);

      // Fourth item goes north again
      expect(config.getNextOutput({}), equals(Direction.north));
    });

    test('roundRobin should skip blocked outputs', () {
      final config = SplitterConfig(
        outputs: [Direction.north, Direction.east, Direction.south],
        mode: SplitterMode.roundRobin,
      );

      // North is blocked
      expect(
        config.getNextOutput({Direction.north}),
        equals(Direction.east),
      );

      // North and east are blocked
      expect(
        config.getNextOutput({Direction.north, Direction.east}),
        equals(Direction.south),
      );

      // All blocked
      expect(
        config.getNextOutput({Direction.north, Direction.east, Direction.south}),
        isNull,
      );
    });

    test('priority should try outputs in order', () {
      final config = SplitterConfig(
        outputs: [Direction.north, Direction.east, Direction.south],
        mode: SplitterMode.priority,
      );

      // First available
      expect(config.getNextOutput({}), equals(Direction.north));

      // North blocked
      expect(
        config.getNextOutput({Direction.north}),
        equals(Direction.east),
      );
    });

    test('equal should balance items across outputs', () {
      var config = SplitterConfig(
        outputs: [Direction.north, Direction.east],
        mode: SplitterMode.equal,
      );

      // Both equal (0), picks first
      expect(config.getNextOutput({}), equals(Direction.north));
      config = config.afterSend(Direction.north);

      // North has 1, east has 0, picks east
      expect(config.getNextOutput({}), equals(Direction.east));
      config = config.afterSend(Direction.east);

      // Both have 1, picks first
      expect(config.getNextOutput({}), equals(Direction.north));
    });
  });

  group('ConveyorTile', () {
    test('should have correct max queue size', () {
      expect(ConveyorTile.maxQueueSize, equals(10));
    });

    test('should have correct transport interval', () {
      expect(ConveyorTile.transportIntervalMs, equals(2000)); // 0.5 items/sec
    });

    test('isFull should return true when queue is at max', () {
      final items = List.generate(
        10,
        (i) => ResourceStack.single('Coal'),
      );

      final tile = ConveyorTile(
        id: 'test',
        position: const Point(0, 0),
        direction: Direction.east,
        queue: items,
      );

      expect(tile.isFull, isTrue);
    });

    test('canAccept should check filter and capacity', () {
      final tile = ConveyorTile(
        id: 'test',
        position: const Point(0, 0),
        direction: Direction.east,
        filter: ConveyorFilter.whitelist(['Coal']),
      );

      expect(tile.canAccept('Coal'), isTrue);
      expect(tile.canAccept('Wood'), isFalse);
    });

    test('canAccept should return false when inactive', () {
      final tile = ConveyorTile(
        id: 'test',
        position: const Point(0, 0),
        direction: Direction.east,
        isActive: false,
      );

      expect(tile.canAccept('Coal'), isFalse);
    });

    test('getNextPosition should calculate correctly', () {
      final tile = ConveyorTile(
        id: 'test',
        position: const Point(5, 5),
        direction: Direction.east,
      );

      expect(tile.getNextPosition(), equals(const Point(6, 5)));
      expect(tile.getNextPosition(Direction.north), equals(const Point(5, 4)));
    });

    test('addItem should add to queue', () {
      const tile = ConveyorTile(
        id: 'test',
        position: Point(0, 0),
        direction: Direction.east,
      );

      final item = ResourceStack.single('Coal');
      final updated = tile.addItem(item);

      expect(updated.queue.length, equals(1));
      expect(updated.queue.first.resourceId, equals('Coal'));
    });

    test('removeFirstItem should remove from queue', () {
      final tile = ConveyorTile(
        id: 'test',
        position: const Point(0, 0),
        direction: Direction.east,
        queue: [
          ResourceStack.single('Coal'),
          ResourceStack.single('Wood'),
        ],
      );

      final updated = tile.removeFirstItem();

      expect(updated.queue.length, equals(1));
      expect(updated.queue.first.resourceId, equals('Wood'));
    });

    test('getReadyItem should return item after transport interval', () {
      final now = DateTime.now();
      final oldItem = ResourceStack(
        resourceId: 'Coal',
        quantity: 1,
        enteredAt: now.subtract(const Duration(seconds: 3)),
      );
      final newItem = ResourceStack(
        resourceId: 'Wood',
        quantity: 1,
        enteredAt: now.subtract(const Duration(milliseconds: 500)),
      );

      final tileOld = ConveyorTile(
        id: 'test1',
        position: const Point(0, 0),
        direction: Direction.east,
        queue: [oldItem],
      );

      final tileNew = ConveyorTile(
        id: 'test2',
        position: const Point(1, 0),
        direction: Direction.east,
        queue: [newItem],
      );

      expect(tileOld.getReadyItem(now), isNotNull);
      expect(tileNew.getReadyItem(now), isNull);
    });
  });

  group('ConveyorNetwork', () {
    test('addTile should add to correct layer', () {
      const network = ConveyorNetwork();

      final tile1 = ConveyorTile(
        id: 'tile1',
        position: const Point(0, 0),
        direction: Direction.east,
        layer: 1,
      );

      final tile2 = ConveyorTile(
        id: 'tile2',
        position: const Point(0, 0),
        direction: Direction.north,
        layer: 2,
      );

      var updated = network.addTile(tile1);
      updated = updated.addTile(tile2);

      expect(updated.tilesLayer1.length, equals(1));
      expect(updated.tilesLayer2.length, equals(1));
      expect(updated.getTilesAt(const Point(0, 0)).length, equals(2));
    });

    test('canAddLayer should respect max layers', () {
      const network = ConveyorNetwork();

      expect(network.canAddLayer(const Point(0, 0)), isTrue);

      final tile1 = ConveyorTile(
        id: 'tile1',
        position: const Point(0, 0),
        direction: Direction.east,
        layer: 1,
      );

      final tile2 = ConveyorTile(
        id: 'tile2',
        position: const Point(0, 0),
        direction: Direction.north,
        layer: 2,
      );

      var updated = network.addTile(tile1);
      expect(updated.canAddLayer(const Point(0, 0)), isTrue);

      updated = updated.addTile(tile2);
      expect(updated.canAddLayer(const Point(0, 0)), isFalse);
    });

    test('removeTile should remove from correct layer', () {
      final tile = ConveyorTile(
        id: 'tile1',
        position: const Point(0, 0),
        direction: Direction.east,
        layer: 1,
      );

      var network = const ConveyorNetwork().addTile(tile);
      expect(network.totalTiles, equals(1));

      network = network.removeTile(const Point(0, 0), 1);
      expect(network.totalTiles, equals(0));
    });

    test('totalItemsInTransit should count all queued items', () {
      final tile1 = ConveyorTile(
        id: 'tile1',
        position: const Point(0, 0),
        direction: Direction.east,
        layer: 1,
        queue: [ResourceStack.single('Coal'), ResourceStack.single('Coal')],
      );

      final tile2 = ConveyorTile(
        id: 'tile2',
        position: const Point(1, 0),
        direction: Direction.east,
        layer: 1,
        queue: [ResourceStack.single('Wood')],
      );

      final network = const ConveyorNetwork()
          .addTile(tile1)
          .addTile(tile2);

      expect(network.totalItemsInTransit, equals(3));
    });
  });

  group('TransportItemsUseCase', () {
    late TransportItemsUseCase useCase;

    setUp(() {
      useCase = const TransportItemsUseCase();
    });

    test('tick should move item from tile A to tile B', () {
      // Create two connected tiles
      final now = DateTime.now();
      final oldTime = now.subtract(const Duration(seconds: 3));

      final tileA = ConveyorTile(
        id: 'tileA',
        position: const Point(0, 0),
        direction: Direction.east,
        layer: 1,
        queue: [
          ResourceStack(
            resourceId: 'Coal',
            quantity: 1,
            enteredAt: oldTime,
          ),
        ],
      );

      const tileB = ConveyorTile(
        id: 'tileB',
        position: Point(1, 0),
        direction: Direction.east,
        layer: 1,
      );

      final network = const ConveyorNetwork()
          .addTile(tileA)
          .addTile(tileB);

      final result = useCase.tick(network: network, now: now);

      expect(result.itemsMoved, equals(1));
      expect(result.network.getTile(const Point(0, 0), 1)!.isEmpty, isTrue);
      expect(result.network.getTile(const Point(1, 0), 1)!.queue.length, equals(1));
    });

    test('tick should respect movement rate (2 seconds per tile)', () {
      final now = DateTime.now();
      final recentTime = now.subtract(const Duration(milliseconds: 500));

      final tile = ConveyorTile(
        id: 'tile',
        position: const Point(0, 0),
        direction: Direction.east,
        layer: 1,
        queue: [
          ResourceStack(
            resourceId: 'Coal',
            quantity: 1,
            enteredAt: recentTime,
          ),
        ],
      );

      const destTile = ConveyorTile(
        id: 'dest',
        position: Point(1, 0),
        direction: Direction.east,
        layer: 1,
      );

      final network = const ConveyorNetwork()
          .addTile(tile)
          .addTile(destTile);

      final result = useCase.tick(network: network, now: now);

      // Item not ready to move yet (only 500ms elapsed)
      expect(result.itemsMoved, equals(0));
    });

    test('tick should handle backpressure when destination full', () {
      final now = DateTime.now();
      final oldTime = now.subtract(const Duration(seconds: 3));

      final tileA = ConveyorTile(
        id: 'tileA',
        position: const Point(0, 0),
        direction: Direction.east,
        layer: 1,
        queue: [
          ResourceStack(resourceId: 'Coal', quantity: 1, enteredAt: oldTime),
        ],
      );

      // Full destination
      final fullQueue = List.generate(
        10,
        (i) => ResourceStack.single('Wood'),
      );

      final tileB = ConveyorTile(
        id: 'tileB',
        position: const Point(1, 0),
        direction: Direction.east,
        layer: 1,
        queue: fullQueue,
      );

      final network = const ConveyorNetwork()
          .addTile(tileA)
          .addTile(tileB);

      final result = useCase.tick(network: network, now: now);

      expect(result.itemsBlocked, equals(1));
      expect(result.itemsMoved, equals(0));
      // Item stays in source
      expect(result.network.getTile(const Point(0, 0), 1)!.queue.length, equals(1));
    });

    test('tick should drop items when no destination', () {
      final now = DateTime.now();
      final oldTime = now.subtract(const Duration(seconds: 3));

      final tile = ConveyorTile(
        id: 'tile',
        position: const Point(0, 0),
        direction: Direction.east,
        layer: 1,
        queue: [
          ResourceStack(resourceId: 'Coal', quantity: 1, enteredAt: oldTime),
        ],
      );

      // No destination tile at (1, 0)
      final network = const ConveyorNetwork().addTile(tile);

      final result = useCase.tick(network: network, now: now);

      expect(result.itemsDropped, equals(1));
      expect(result.network.droppedItems.length, equals(1));
    });

    test('tick should deliver items to building input ports', () {
      final now = DateTime.now();
      final oldTime = now.subtract(const Duration(seconds: 3));

      final tile = ConveyorTile(
        id: 'tile',
        position: const Point(0, 0),
        direction: Direction.east,
        layer: 1,
        queue: [
          ResourceStack(resourceId: 'Coal', quantity: 1, enteredAt: oldTime),
        ],
      );

      const port = BuildingPort(
        buildingId: 'smelter_1',
        type: PortType.input,
        position: Point(1, 0),
        direction: Direction.west,
      );

      final network = const ConveyorNetwork()
          .addTile(tile)
          .addInputPort(port);

      final result = useCase.tick(network: network, now: now);

      expect(result.itemsMoved, equals(1));
      expect(result.deliveredToBuildings['smelter_1']?.length, equals(1));
    });

    test('layers should work correctly (layer 1 and layer 2)', () {
      final now = DateTime.now();
      final oldTime = now.subtract(const Duration(seconds: 3));

      final tileL1 = ConveyorTile(
        id: 'tileL1',
        position: const Point(0, 0),
        direction: Direction.east,
        layer: 1,
        queue: [
          ResourceStack(resourceId: 'Coal', quantity: 1, enteredAt: oldTime),
        ],
      );

      const tileL2 = ConveyorTile(
        id: 'tileL2',
        position: Point(1, 0),
        direction: Direction.east,
        layer: 2,
      );

      // Only layer 2 tile at destination
      final network = const ConveyorNetwork()
          .addTile(tileL1)
          .addTile(tileL2);

      final result = useCase.tick(network: network, now: now);

      // Should still move (cross-layer transfer allowed)
      expect(result.itemsMoved, equals(1));
    });

    test('queue should respect FIFO order', () {
      final now = DateTime.now();

      // Create items with different entry times
      final item1 = ResourceStack(
        resourceId: 'Coal',
        quantity: 1,
        enteredAt: now.subtract(const Duration(seconds: 5)),
      );
      final item2 = ResourceStack(
        resourceId: 'Wood',
        quantity: 1,
        enteredAt: now.subtract(const Duration(seconds: 3)),
      );

      final tile = ConveyorTile(
        id: 'tile',
        position: const Point(0, 0),
        direction: Direction.east,
        layer: 1,
        queue: [item1, item2], // item1 entered first
      );

      const destTile = ConveyorTile(
        id: 'dest',
        position: Point(1, 0),
        direction: Direction.east,
        layer: 1,
      );

      final network = const ConveyorNetwork()
          .addTile(tile)
          .addTile(destTile);

      final result = useCase.tick(network: network, now: now);

      // First item (Coal) should move first
      expect(result.itemsMoved, equals(1));
      final movedItem = result.network.getTile(const Point(1, 0), 1)!.queue.first;
      expect(movedItem.resourceId, equals('Coal'));
    });

    test('createConveyorPath should create tiles from path', () {
      const network = ConveyorNetwork();
      final path = [
        const Point<int>(0, 0),
        const Point<int>(1, 0),
        const Point<int>(2, 0),
        const Point<int>(2, 1),
      ];

      final updated = useCase.createConveyorPath(
        network: network,
        path: path,
        idPrefix: 'test',
      );

      // Should create 3 tiles (last point is destination, no tile needed)
      expect(updated.totalTiles, equals(3));

      // Check directions
      expect(updated.getTile(const Point(0, 0), 1)!.direction, equals(Direction.east));
      expect(updated.getTile(const Point(1, 0), 1)!.direction, equals(Direction.east));
      expect(updated.getTile(const Point(2, 0), 1)!.direction, equals(Direction.south));
    });

    test('injectFromBuilding should add items to connected conveyor', () {
      const tile = ConveyorTile(
        id: 'tile',
        position: Point(1, 0),
        direction: Direction.east,
        layer: 1,
      );

      const port = BuildingPort(
        buildingId: 'mining_1',
        type: PortType.output,
        position: Point(1, 0),
        direction: Direction.east,
      );

      final network = const ConveyorNetwork()
          .addTile(tile)
          .addOutputPort(port);

      final items = [ResourceStack.single('Coal')];

      final updated = useCase.injectFromBuilding(
        network: network,
        buildingId: 'mining_1',
        items: items,
      );

      expect(updated.getTile(const Point(1, 0), 1)!.queue.length, equals(1));
    });
  });

  group('TransportResult', () {
    test('success factory should create correct result', () {
      final item = ResourceStack.single('Coal');
      final result = TransportResult.success(item, const Point(1, 0));

      expect(result.status, equals(TransportStatus.success));
      expect(result.item, equals(item));
      expect(result.destination, equals(const Point(1, 0)));
    });

    test('blocked factory should create correct result', () {
      final item = ResourceStack.single('Coal');
      final result = TransportResult.blocked(item);

      expect(result.status, equals(TransportStatus.blocked));
      expect(result.message, contains('full'));
    });

    test('dropped factory should create correct result', () {
      final item = ResourceStack.single('Coal');
      final result = TransportResult.dropped(item);

      expect(result.status, equals(TransportStatus.dropped));
      expect(result.message, contains('destination'));
    });
  });
}
