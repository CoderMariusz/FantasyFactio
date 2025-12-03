import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/tile.dart';
import 'package:trade_factory_masters/domain/entities/building_definition.dart';
import 'package:trade_factory_masters/domain/entities/player_economy.dart';
import 'package:trade_factory_masters/domain/entities/resource.dart';
import 'package:trade_factory_masters/domain/services/building_placement_service.dart';

void main() {
  group('Tile', () {
    test('should create tile with default values', () {
      const tile = Tile(x: 0, y: 0, biom: BiomType.rownina);
      expect(tile.isOccupied, isFalse);
      expect(tile.layers, equals(0));
    });

    test('withBuilding should set buildingId and layer', () {
      const tile = Tile(x: 0, y: 0, biom: BiomType.rownina);
      final occupied = tile.withBuilding('building_1');
      expect(occupied.isOccupied, isTrue);
      expect(occupied.buildingId, equals('building_1'));
      expect(occupied.layers, equals(1));
    });

    test('withoutBuilding should clear buildingId and layers', () {
      final occupied = const Tile(
        x: 0,
        y: 0,
        biom: BiomType.rownina,
        buildingId: 'test',
        layers: 2,
      ).withoutBuilding();
      expect(occupied.isOccupied, isFalse);
      expect(occupied.layers, equals(0));
    });
  });

  group('BiomType', () {
    test('koppalnia should produce coal, iron ore, copper ore', () {
      expect(
        BiomType.koppalnia.producesResources,
        containsAll(['Coal', 'Iron Ore', 'Copper Ore']),
      );
    });

    test('las should produce wood', () {
      expect(BiomType.las.producesResources, equals(['Wood']));
    });

    test('rownina should produce no resources', () {
      expect(BiomType.rownina.producesResources, isEmpty);
    });

    test('biom ids should match placement rule strings', () {
      expect(BiomType.koppalnia.id, equals('koppalnia'));
      expect(BiomType.las.id, equals('las'));
      expect(BiomType.gory.id, equals('gory'));
      expect(BiomType.jezioro.id, equals('jezioro'));
    });
  });

  group('GameGrid', () {
    test('should generate grid with correct dimensions', () {
      final grid = GameGrid.generate(width: 10, height: 10, seed: 42);
      expect(grid.width, equals(10));
      expect(grid.height, equals(10));
    });

    test('should have tiles at all positions', () {
      final grid = GameGrid.generate(width: 5, height: 5, seed: 42);
      for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 5; x++) {
          expect(grid.getTile(x, y), isNotNull);
        }
      }
    });

    test('isValidPosition should validate bounds', () {
      final grid = GameGrid.generate(width: 10, height: 10, seed: 42);
      expect(grid.isValidPosition(0, 0), isTrue);
      expect(grid.isValidPosition(9, 9), isTrue);
      expect(grid.isValidPosition(-1, 0), isFalse);
      expect(grid.isValidPosition(10, 0), isFalse);
    });

    test('placeBuilding should update tile', () {
      final grid = GameGrid.generate(width: 10, height: 10, seed: 42);
      final updated = grid.placeBuilding(5, 5, 'test_building');
      expect(updated.getTile(5, 5)?.isOccupied, isTrue);
      expect(updated.getTile(5, 5)?.buildingId, equals('test_building'));
    });

    test('removeBuilding should clear tile', () {
      final grid = GameGrid.generate(width: 10, height: 10, seed: 42)
          .placeBuilding(5, 5, 'test');
      final updated = grid.removeBuilding(5, 5);
      expect(updated.getTile(5, 5)?.isOccupied, isFalse);
    });
  });

  group('BuildingPlacementService', () {
    late BuildingPlacementService service;
    late GameGrid grid;

    setUp(() {
      service = BuildingPlacementService();
      // Create grid with known bioms for testing
      final tiles = <String, Tile>{};
      for (int y = 0; y < 20; y++) {
        for (int x = 0; x < 20; x++) {
          // Set up specific bioms for testing
          BiomType biom;
          if (x < 5 && y < 5) {
            biom = BiomType.koppalnia;
          } else if (x >= 5 && x < 10 && y < 5) {
            biom = BiomType.las;
          } else {
            biom = BiomType.rownina;
          }
          tiles['$x,$y'] = Tile(x: x, y: y, biom: biom);
        }
      }
      grid = GameGrid(width: 20, height: 20, tiles: tiles);
    });

    test('validatePlacement should succeed for valid position', () {
      final result = service.validatePlacement(
        definition: BuildingDefinitions.storage,
        grid: grid,
        x: 10,
        y: 10,
      );
      expect(result.isValid, isTrue);
      expect(result.affectedTiles.length, equals(4)); // 2x2 building
    });

    test('validatePlacement should fail for out of bounds', () {
      final result = service.validatePlacement(
        definition: BuildingDefinitions.storage,
        grid: grid,
        x: 19,
        y: 19,
      );
      expect(result.isValid, isFalse);
      expect(result.error, contains('outside grid bounds'));
    });

    test('validatePlacement should fail for occupied tile', () {
      final occupiedGrid = grid.placeBuilding(10, 10, 'existing');
      final result = service.validatePlacement(
        definition: BuildingDefinitions.storage,
        grid: occupiedGrid,
        x: 10,
        y: 10,
      );
      expect(result.isValid, isFalse);
      expect(result.error, contains('occupied'));
    });

    test('validatePlacement should enforce biom restriction', () {
      // Mining facility requires koppalnia, las, gory, or jezioro
      final result = service.validatePlacement(
        definition: BuildingDefinitions.miningFacility,
        grid: grid,
        x: 10, // This is rownina biom
        y: 10,
      );
      expect(result.isValid, isFalse);
      expect(result.error, contains('biom'));
    });

    test('validatePlacement should succeed on correct biom', () {
      // Mining facility on koppalnia (x < 5, y < 5)
      final result = service.validatePlacement(
        definition: BuildingDefinitions.miningFacility,
        grid: grid,
        x: 0,
        y: 0,
      );
      expect(result.isValid, isTrue);
    });

    test('canAfford should check resource requirements', () {
      final economy = PlayerEconomy(
        gold: 100,
        inventory: {
          'Wood': Resource(
            id: 'Wood',
            displayName: 'Wood',
            type: ResourceType.tier1,
            amount: 10,
            iconPath: 'assets/wood.png',
          ),
          'Stone': Resource(
            id: 'Stone',
            displayName: 'Stone',
            type: ResourceType.tier1,
            amount: 5,
            iconPath: 'assets/stone.png',
          ),
        },
        buildings: [],
        tier: 1,
        lastSeen: DateTime.now(),
      );

      // Storage costs 5 wood + 10 stone
      expect(
        service.canAfford(
          definition: BuildingDefinitions.storage,
          economy: economy,
        ),
        isFalse, // Only have 5 stone, need 10
      );

      // Mining facility is free
      expect(
        service.canAfford(
          definition: BuildingDefinitions.miningFacility,
          economy: economy,
        ),
        isTrue,
      );
    });

    test('placeBuilding should deduct resources', () {
      final economy = PlayerEconomy(
        gold: 100,
        inventory: {
          'Wood': Resource(
            id: 'Wood',
            displayName: 'Wood',
            type: ResourceType.tier1,
            amount: 20,
            iconPath: 'assets/wood.png',
          ),
          'Stone': Resource(
            id: 'Stone',
            displayName: 'Stone',
            type: ResourceType.tier1,
            amount: 20,
            iconPath: 'assets/stone.png',
          ),
        },
        buildings: [],
        tier: 1,
        lastSeen: DateTime.now(),
      );

      final result = service.placeBuilding(
        definition: BuildingDefinitions.storage,
        grid: grid,
        economy: economy,
        x: 10,
        y: 10,
        buildingId: 'storage_1',
      );

      expect(result.success, isTrue);
      expect(result.updatedEconomy?.inventory['Wood']?.amount, equals(15));
      expect(result.updatedEconomy?.inventory['Stone']?.amount, equals(10));
    });

    test('placeBuilding should update grid for multi-tile building', () {
      final economy = PlayerEconomy(
        gold: 100,
        inventory: {},
        buildings: [],
        tier: 1,
        lastSeen: DateTime.now(),
      );

      final result = service.placeBuilding(
        definition: BuildingDefinitions.miningFacility,
        grid: grid,
        economy: economy,
        x: 0,
        y: 0,
        buildingId: 'mine_1',
      );

      expect(result.success, isTrue);
      // 2x2 building should occupy 4 tiles
      expect(result.updatedGrid?.getTile(0, 0)?.isOccupied, isTrue);
      expect(result.updatedGrid?.getTile(1, 0)?.isOccupied, isTrue);
      expect(result.updatedGrid?.getTile(0, 1)?.isOccupied, isTrue);
      expect(result.updatedGrid?.getTile(1, 1)?.isOccupied, isTrue);
    });

    test('placeBuilding should fail if cannot afford', () {
      final economy = PlayerEconomy(
        gold: 100,
        inventory: {},
        buildings: [],
        tier: 1,
        lastSeen: DateTime.now(),
      );

      final result = service.placeBuilding(
        definition: BuildingDefinitions.storage,
        grid: grid,
        economy: economy,
        x: 10,
        y: 10,
        buildingId: 'storage_1',
      );

      expect(result.success, isFalse);
      expect(result.error, contains('afford'));
    });

    test('removeBuilding should clear all tiles', () {
      final occupied = grid
          .placeBuilding(5, 5, 'test')
          .placeBuilding(6, 5, 'test')
          .placeBuilding(5, 6, 'test')
          .placeBuilding(6, 6, 'test');

      final cleared = service.removeBuilding(
        grid: occupied,
        x: 5,
        y: 5,
        width: 2,
        height: 2,
      );

      expect(cleared.getTile(5, 5)?.isOccupied, isFalse);
      expect(cleared.getTile(6, 5)?.isOccupied, isFalse);
      expect(cleared.getTile(5, 6)?.isOccupied, isFalse);
      expect(cleared.getTile(6, 6)?.isOccupied, isFalse);
    });

    test('getValidPlacements should find all valid positions', () {
      // For mining facility (2x2, biom-restricted)
      final validPositions = service.getValidPlacements(
        definition: BuildingDefinitions.miningFacility,
        grid: grid,
      );

      // Should only find positions in koppalnia (x < 5, y < 5) and las (5 <= x < 10, y < 5)
      // For 2x2 building: koppalnia gives (0,0)-(3,3) and las gives (5,0)-(7,3)
      expect(validPositions, isNotEmpty);
      for (final (x, y) in validPositions) {
        expect(x + 1 < grid.width, isTrue);
        expect(y + 1 < grid.height, isTrue);
      }
    });
  });
}
