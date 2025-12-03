import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/conveyor_tile.dart';
import 'package:trade_factory_masters/domain/entities/conveyor_network.dart';
import 'package:trade_factory_masters/domain/entities/pathfinder_node.dart';
import 'package:trade_factory_masters/domain/usecases/apply_filter_usecase.dart';

void main() {
  late ApplyFilterUseCase useCase;

  setUp(() {
    useCase = const ApplyFilterUseCase();
  });

  group('ConveyorFilter validation', () {
    test('allowAll filter is always valid', () {
      const filter = ConveyorFilter();
      expect(filter.isValid, isTrue);
    });

    test('whitelist filter is valid with 1-3 items', () {
      expect(
        ConveyorFilter.whitelist(['wood']).isValid,
        isTrue,
      );
      expect(
        ConveyorFilter.whitelist(['wood', 'stone']).isValid,
        isTrue,
      );
      expect(
        ConveyorFilter.whitelist(['wood', 'stone', 'iron']).isValid,
        isTrue,
      );
    });

    test('whitelist filter is invalid with 0 items', () {
      const filter = ConveyorFilter(
        mode: FilterMode.whitelist,
        resourceIds: [],
      );
      expect(filter.isValid, isFalse);
    });

    test('whitelist filter is invalid with more than 3 items', () {
      final filter = ConveyorFilter.whitelist([
        'wood',
        'stone',
        'iron',
        'copper',
      ]);
      expect(filter.isValid, isFalse);
    });

    test('blacklist filter is valid with 1-3 items', () {
      expect(
        ConveyorFilter.blacklist(['coal']).isValid,
        isTrue,
      );
      expect(
        ConveyorFilter.blacklist(['coal', 'copper']).isValid,
        isTrue,
      );
      expect(
        ConveyorFilter.blacklist(['coal', 'copper', 'gold']).isValid,
        isTrue,
      );
    });

    test('blacklist filter is invalid with more than 3 items', () {
      final filter = ConveyorFilter.blacklist([
        'wood',
        'stone',
        'iron',
        'copper',
      ]);
      expect(filter.isValid, isFalse);
    });

    test('single filter is valid with non-empty resourceId', () {
      expect(
        ConveyorFilter.single('iron').isValid,
        isTrue,
      );
    });

    test('single filter is invalid with empty resourceId', () {
      const filter = ConveyorFilter(
        mode: FilterMode.single,
        singleResourceId: '',
      );
      expect(filter.isValid, isFalse);
    });

    test('single filter is invalid with null resourceId', () {
      const filter = ConveyorFilter(
        mode: FilterMode.single,
        singleResourceId: null,
      );
      expect(filter.isValid, isFalse);
    });

    test('maxListItems constant is 3', () {
      expect(ConveyorFilter.maxListItems, equals(3));
    });
  });

  group('StorageFilterConfig', () {
    test('default config allows all', () {
      const config = StorageFilterConfig();
      expect(config.globalFilter.mode, equals(FilterMode.allowAll));
      expect(config.portFilters, isEmpty);
    });

    test('canPassPort returns true when no filters', () {
      const config = StorageFilterConfig();
      expect(config.canPassPort('wood', 'input'), isTrue);
      expect(config.canPassPort('stone', 'output_n'), isTrue);
    });

    test('global filter applies to all ports', () {
      final config = StorageFilterConfig(
        globalFilter: ConveyorFilter.whitelist(['wood', 'stone']),
      );
      expect(config.canPassPort('wood', 'input'), isTrue);
      expect(config.canPassPort('stone', 'output_n'), isTrue);
      expect(config.canPassPort('iron', 'input'), isFalse);
    });

    test('port filter overrides global filter', () {
      final config = StorageFilterConfig(
        globalFilter: ConveyorFilter.whitelist(['wood']),
        portFilters: {
          'input': ConveyorFilter.whitelist(['iron']),
        },
      );
      // Port filter applies to 'input'
      expect(config.canPassPort('iron', 'input'), isTrue);
      expect(config.canPassPort('wood', 'input'), isFalse);

      // Global filter applies to other ports
      expect(config.canPassPort('wood', 'output_n'), isTrue);
      expect(config.canPassPort('iron', 'output_n'), isFalse);
    });

    test('port filter completely overrides global filter', () {
      final config = StorageFilterConfig(
        globalFilter: ConveyorFilter.whitelist(['wood', 'iron']),
        portFilters: {
          'input': ConveyorFilter.blacklist(['iron']),
        },
      );
      // wood: passes port blacklist (not blacklisted) - global ignored
      expect(config.canPassPort('wood', 'input'), isTrue);
      // iron: fails port blacklist (is blacklisted)
      expect(config.canPassPort('iron', 'input'), isFalse);
      // stone: passes port blacklist (not blacklisted) - global ignored
      expect(config.canPassPort('stone', 'input'), isTrue);
    });

    test('getFilterForPort returns port filter if exists', () {
      final portFilter = ConveyorFilter.single('iron');
      final config = StorageFilterConfig(
        globalFilter: ConveyorFilter.whitelist(['wood']),
        portFilters: {'input': portFilter},
      );
      expect(config.getFilterForPort('input'), equals(portFilter));
    });

    test('getFilterForPort returns global filter if no port filter', () {
      final globalFilter = ConveyorFilter.whitelist(['wood']);
      final config = StorageFilterConfig(
        globalFilter: globalFilter,
        portFilters: {'output_n': ConveyorFilter.single('iron')},
      );
      expect(config.getFilterForPort('input'), equals(globalFilter));
    });

    test('copyWith creates new instance with updated values', () {
      const original = StorageFilterConfig();
      final updated = original.copyWith(
        globalFilter: ConveyorFilter.single('coal'),
      );
      expect(updated.globalFilter.mode, equals(FilterMode.single));
      expect(original.globalFilter.mode, equals(FilterMode.allowAll));
    });
  });

  group('ApplyFilterUseCase.canPassTile', () {
    test('returns true for allowAll filter', () {
      final tile = ConveyorTile(
        id: 'tile1',
        position: const Point(0, 0),
        direction: Direction.east,
        filter: const ConveyorFilter(),
      );
      expect(useCase.canPassTile('wood', tile), isTrue);
      expect(useCase.canPassTile('iron', tile), isTrue);
    });

    test('returns true for whitelisted items', () {
      final tile = ConveyorTile(
        id: 'tile1',
        position: const Point(0, 0),
        direction: Direction.east,
        filter: ConveyorFilter.whitelist(['wood', 'stone']),
      );
      expect(useCase.canPassTile('wood', tile), isTrue);
      expect(useCase.canPassTile('stone', tile), isTrue);
      expect(useCase.canPassTile('iron', tile), isFalse);
    });

    test('returns false for blacklisted items', () {
      final tile = ConveyorTile(
        id: 'tile1',
        position: const Point(0, 0),
        direction: Direction.east,
        filter: ConveyorFilter.blacklist(['coal']),
      );
      expect(useCase.canPassTile('wood', tile), isTrue);
      expect(useCase.canPassTile('coal', tile), isFalse);
    });

    test('returns true only for single item type', () {
      final tile = ConveyorTile(
        id: 'tile1',
        position: const Point(0, 0),
        direction: Direction.east,
        filter: ConveyorFilter.single('iron'),
      );
      expect(useCase.canPassTile('iron', tile), isTrue);
      expect(useCase.canPassTile('wood', tile), isFalse);
      expect(useCase.canPassTile('stone', tile), isFalse);
    });
  });

  group('ApplyFilterUseCase.canPassPort', () {
    test('returns true for allowAll filter', () {
      final port = BuildingPort(
        buildingId: 'b1',
        type: PortType.input,
        position: const Point(0, 0),
        direction: Direction.north,
        filter: const ConveyorFilter(),
      );
      expect(useCase.canPassPort('wood', port), isTrue);
    });

    test('returns true for whitelisted items', () {
      final port = BuildingPort(
        buildingId: 'b1',
        type: PortType.input,
        position: const Point(0, 0),
        direction: Direction.north,
        filter: ConveyorFilter.whitelist(['iron']),
      );
      expect(useCase.canPassPort('iron', port), isTrue);
      expect(useCase.canPassPort('wood', port), isFalse);
    });
  });

  group('ApplyFilterUseCase.canPassStorage', () {
    test('passes when no filters', () {
      const config = StorageFilterConfig();
      expect(
        useCase.canPassStorage(
          resourceId: 'wood',
          storageConfig: config,
          portName: 'input',
        ),
        isTrue,
      );
    });

    test('respects global filter', () {
      final config = StorageFilterConfig(
        globalFilter: ConveyorFilter.whitelist(['iron']),
      );
      expect(
        useCase.canPassStorage(
          resourceId: 'iron',
          storageConfig: config,
          portName: 'input',
        ),
        isTrue,
      );
      expect(
        useCase.canPassStorage(
          resourceId: 'wood',
          storageConfig: config,
          portName: 'input',
        ),
        isFalse,
      );
    });

    test('port filter overrides global', () {
      final config = StorageFilterConfig(
        globalFilter: ConveyorFilter.whitelist(['wood']),
        portFilters: {
          'input': ConveyorFilter.whitelist(['iron']),
        },
      );
      expect(
        useCase.canPassStorage(
          resourceId: 'iron',
          storageConfig: config,
          portName: 'input',
        ),
        isTrue,
      );
      expect(
        useCase.canPassStorage(
          resourceId: 'wood',
          storageConfig: config,
          portName: 'input',
        ),
        isFalse,
      );
    });
  });

  group('ApplyFilterUseCase.evaluateFilterChain', () {
    test('passes when no filters provided', () {
      final result = useCase.evaluateFilterChain(resourceId: 'wood');
      expect(result.passes, isTrue);
      expect(result.blockedBy, isNull);
    });

    test('blocked by tile filter', () {
      final tile = ConveyorTile(
        id: 'tile1',
        position: const Point(0, 0),
        direction: Direction.east,
        filter: ConveyorFilter.blacklist(['wood']),
      );
      final result = useCase.evaluateFilterChain(
        resourceId: 'wood',
        sourceTile: tile,
      );
      expect(result.passes, isFalse);
      expect(result.blockedBy, equals(FilterBlockReason.tileFilter));
    });

    test('blocked by port filter', () {
      final port = BuildingPort(
        buildingId: 'b1',
        type: PortType.input,
        position: const Point(0, 0),
        direction: Direction.north,
        filter: ConveyorFilter.whitelist(['iron']),
      );
      final result = useCase.evaluateFilterChain(
        resourceId: 'wood',
        destinationPort: port,
      );
      expect(result.passes, isFalse);
      expect(result.blockedBy, equals(FilterBlockReason.portFilter));
    });

    test('blocked by global storage filter', () {
      final config = StorageFilterConfig(
        globalFilter: ConveyorFilter.single('gold'),
      );
      final result = useCase.evaluateFilterChain(
        resourceId: 'wood',
        storageConfig: config,
      );
      expect(result.passes, isFalse);
      expect(result.blockedBy, equals(FilterBlockReason.globalFilter));
    });

    test('passes when all filters allow', () {
      final tile = ConveyorTile(
        id: 'tile1',
        position: const Point(0, 0),
        direction: Direction.east,
        filter: ConveyorFilter.whitelist(['iron', 'wood']),
      );
      final port = BuildingPort(
        buildingId: 'b1',
        type: PortType.input,
        position: const Point(0, 0),
        direction: Direction.north,
        filter: const ConveyorFilter(),
      );
      final config = StorageFilterConfig(
        globalFilter: ConveyorFilter.blacklist(['coal']),
      );
      final result = useCase.evaluateFilterChain(
        resourceId: 'wood',
        sourceTile: tile,
        destinationPort: port,
        storageConfig: config,
      );
      expect(result.passes, isTrue);
    });

    test('tile filter checked first', () {
      final tile = ConveyorTile(
        id: 'tile1',
        position: const Point(0, 0),
        direction: Direction.east,
        filter: ConveyorFilter.single('iron'),
      );
      final port = BuildingPort(
        buildingId: 'b1',
        type: PortType.input,
        position: const Point(0, 0),
        direction: Direction.north,
        filter: ConveyorFilter.single('gold'),
      );
      // wood fails tile filter (only iron allowed)
      final result = useCase.evaluateFilterChain(
        resourceId: 'wood',
        sourceTile: tile,
        destinationPort: port,
      );
      expect(result.blockedBy, equals(FilterBlockReason.tileFilter));
    });

    test('port filter checked after tile', () {
      final tile = ConveyorTile(
        id: 'tile1',
        position: const Point(0, 0),
        direction: Direction.east,
        filter: const ConveyorFilter(),
      );
      final port = BuildingPort(
        buildingId: 'b1',
        type: PortType.input,
        position: const Point(0, 0),
        direction: Direction.north,
        filter: ConveyorFilter.single('gold'),
      );
      // wood passes tile but fails port (only gold allowed)
      final result = useCase.evaluateFilterChain(
        resourceId: 'wood',
        sourceTile: tile,
        destinationPort: port,
      );
      expect(result.blockedBy, equals(FilterBlockReason.portFilter));
    });
  });

  group('ApplyFilterUseCase.createWhitelistFilter', () {
    test('returns filter with valid items', () {
      final filter = useCase.createWhitelistFilter(['wood', 'stone']);
      expect(filter, isNotNull);
      expect(filter!.mode, equals(FilterMode.whitelist));
      expect(filter.resourceIds, equals(['wood', 'stone']));
    });

    test('returns null with empty list', () {
      final filter = useCase.createWhitelistFilter([]);
      expect(filter, isNull);
    });

    test('returns null with more than 3 items', () {
      final filter = useCase.createWhitelistFilter(['a', 'b', 'c', 'd']);
      expect(filter, isNull);
    });

    test('returns filter with exactly 3 items', () {
      final filter = useCase.createWhitelistFilter(['a', 'b', 'c']);
      expect(filter, isNotNull);
    });
  });

  group('ApplyFilterUseCase.createBlacklistFilter', () {
    test('returns filter with valid items', () {
      final filter = useCase.createBlacklistFilter(['coal']);
      expect(filter, isNotNull);
      expect(filter!.mode, equals(FilterMode.blacklist));
    });

    test('returns null with empty list', () {
      final filter = useCase.createBlacklistFilter([]);
      expect(filter, isNull);
    });

    test('returns null with more than 3 items', () {
      final filter = useCase.createBlacklistFilter(['a', 'b', 'c', 'd']);
      expect(filter, isNull);
    });
  });

  group('ApplyFilterUseCase.createSingleFilter', () {
    test('creates single filter', () {
      final filter = useCase.createSingleFilter('iron');
      expect(filter.mode, equals(FilterMode.single));
      expect(filter.singleResourceId, equals('iron'));
    });
  });

  group('ApplyFilterUseCase.getFilterStats', () {
    test('returns empty stats for empty network', () {
      const network = ConveyorNetwork();
      final stats = useCase.getFilterStats(network);
      expect(stats.totalTiles, equals(0));
      expect(stats.allowAllCount, equals(0));
      expect(stats.filteredTiles, equals(0));
    });

    test('counts filter types correctly', () {
      final tile1 = ConveyorTile(
        id: 't1',
        position: const Point(0, 0),
        direction: Direction.east,
        filter: const ConveyorFilter(),
      );
      final tile2 = ConveyorTile(
        id: 't2',
        position: const Point(1, 0),
        direction: Direction.east,
        filter: ConveyorFilter.whitelist(['wood']),
      );
      final tile3 = ConveyorTile(
        id: 't3',
        position: const Point(2, 0),
        direction: Direction.east,
        filter: ConveyorFilter.blacklist(['coal']),
      );
      final tile4 = ConveyorTile(
        id: 't4',
        position: const Point(3, 0),
        direction: Direction.east,
        filter: ConveyorFilter.single('iron'),
      );

      var network = const ConveyorNetwork()
          .addTile(tile1)
          .addTile(tile2)
          .addTile(tile3)
          .addTile(tile4);

      final stats = useCase.getFilterStats(network);
      expect(stats.totalTiles, equals(4));
      expect(stats.allowAllCount, equals(1));
      expect(stats.whitelistCount, equals(1));
      expect(stats.blacklistCount, equals(1));
      expect(stats.singleCount, equals(1));
      expect(stats.filteredTiles, equals(3));
      expect(stats.filteredPercentage, equals(75.0));
    });
  });

  group('FilterEvaluationResult factories', () {
    test('passed factory creates success result', () {
      final result = FilterEvaluationResult.passed();
      expect(result.passes, isTrue);
      expect(result.blockedBy, isNull);
    });

    test('blockedByTile factory creates tile block result', () {
      final result = FilterEvaluationResult.blockedByTile('test reason');
      expect(result.passes, isFalse);
      expect(result.blockedBy, equals(FilterBlockReason.tileFilter));
      expect(result.blockReason, equals('test reason'));
    });

    test('blockedByPort factory creates port block result', () {
      final result = FilterEvaluationResult.blockedByPort('port reason');
      expect(result.passes, isFalse);
      expect(result.blockedBy, equals(FilterBlockReason.portFilter));
      expect(result.blockReason, equals('port reason'));
    });

    test('blockedByGlobal factory creates global block result', () {
      final result = FilterEvaluationResult.blockedByGlobal('global reason');
      expect(result.passes, isFalse);
      expect(result.blockedBy, equals(FilterBlockReason.globalFilter));
      expect(result.blockReason, equals('global reason'));
    });
  });
}
