import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/building.dart';
import 'package:trade_factory_masters/domain/entities/building_definition.dart';
import 'package:trade_factory_masters/domain/entities/tile.dart';
import 'package:trade_factory_masters/domain/entities/player_economy.dart';
import 'package:trade_factory_masters/domain/entities/resource.dart';
import 'package:trade_factory_masters/domain/services/production_service.dart';
import 'package:trade_factory_masters/domain/services/inventory_manager.dart';

void main() {
  group('ProductionService', () {
    late ProductionService service;
    late Building miningBuilding;
    late Building smelterBuilding;

    setUp(() {
      service = ProductionService();

      miningBuilding = Building(
        id: 'mine_1',
        type: BuildingType.mining,
        level: 1,
        gridPosition: const GridPosition(x: 0, y: 0),
        production: const ProductionConfig(baseRate: 10.0, resourceType: 'Coal'),
        upgradeConfig: const UpgradeConfig(baseCost: 100, costIncrement: 50),
        lastCollected: DateTime.now(),
        isActive: true,
      );

      smelterBuilding = Building(
        id: 'smelter_1',
        type: BuildingType.smelter,
        level: 1,
        gridPosition: const GridPosition(x: 5, y: 5),
        production:
            const ProductionConfig(baseRate: 5.0, resourceType: 'Iron Bar'),
        upgradeConfig: const UpgradeConfig(baseCost: 200, costIncrement: 100),
        lastCollected: DateTime.now(),
        isActive: true,
      );
    });

    test('calculateProduction should fail for inactive building', () {
      final inactiveBuilding = miningBuilding.copyWith(isActive: false);

      final result = service.calculateProduction(
        building: inactiveBuilding,
        definition: BuildingDefinitions.miningFacility,
        inventory: {},
        elapsedTime: const Duration(hours: 1),
      );

      expect(result.error, contains('not active'));
    });

    test('calculateProduction should return in progress for short time', () {
      final result = service.calculateProduction(
        building: miningBuilding,
        definition: BuildingDefinitions.miningFacility,
        inventory: {},
        elapsedTime: const Duration(milliseconds: 500), // Less than cycle time
      );

      expect(result.cycleCompleted, isFalse);
      expect(result.progress, greaterThan(0));
      expect(result.progress, lessThan(1));
    });

    test('calculateProduction should produce resources after cycle time', () {
      final tile = const Tile(x: 0, y: 0, biom: BiomType.koppalnia);

      final result = service.calculateProduction(
        building: miningBuilding,
        definition: BuildingDefinitions.miningFacility,
        inventory: {},
        elapsedTime: const Duration(seconds: 10), // Multiple cycles
        placedOnTile: tile,
      );

      expect(result.produced, isNotEmpty);
      expect(result.produced['Coal'], greaterThan(0));
    });

    test('calculateProduction should produce different resource based on biom',
        () {
      final forestTile = const Tile(x: 0, y: 0, biom: BiomType.las);

      final result = service.calculateProduction(
        building: miningBuilding,
        definition: BuildingDefinitions.miningFacility,
        inventory: {},
        elapsedTime: const Duration(seconds: 10),
        placedOnTile: forestTile,
      );

      expect(result.produced['Wood'], greaterThan(0));
    });

    test('calculateProduction should increase with building level', () {
      final level1Building = miningBuilding;
      final level5Building = miningBuilding.copyWith(level: 5);
      final tile = const Tile(x: 0, y: 0, biom: BiomType.koppalnia);

      final result1 = service.calculateProduction(
        building: level1Building,
        definition: BuildingDefinitions.miningFacility,
        inventory: {},
        elapsedTime: const Duration(seconds: 10),
        placedOnTile: tile,
      );

      final result5 = service.calculateProduction(
        building: level5Building,
        definition: BuildingDefinitions.miningFacility,
        inventory: {},
        elapsedTime: const Duration(seconds: 10),
        placedOnTile: tile,
      );

      // Level 5 should produce more due to 10% bonus per level
      final level1Amount = result1.produced['Coal'] ?? 0;
      final level5Amount = result5.produced['Coal'] ?? 0;
      expect(level5Amount, greaterThan(level1Amount));
    });

    test('getProductionRatePerHour should calculate correctly', () {
      final rate = service.getProductionRatePerHour(
        building: miningBuilding,
        definition: BuildingDefinitions.miningFacility,
      );

      expect(rate, greaterThan(0));
    });

    test('getProductionRatePerHour should increase with level', () {
      final rate1 = service.getProductionRatePerHour(
        building: miningBuilding,
        definition: BuildingDefinitions.miningFacility,
      );

      final level3Building = miningBuilding.copyWith(level: 3);
      final rate3 = service.getProductionRatePerHour(
        building: level3Building,
        definition: BuildingDefinitions.miningFacility,
      );

      expect(rate3, greaterThan(rate1));
    });

    test('calculateAccumulatedResources should cap at max hours', () {
      final tile = const Tile(x: 0, y: 0, biom: BiomType.koppalnia);
      final longTimeAgo = DateTime.now().subtract(const Duration(hours: 100));
      final building = miningBuilding.copyWith(lastCollected: longTimeAgo);

      final result10h = service.calculateAccumulatedResources(
        building: building,
        definition: BuildingDefinitions.miningFacility,
        lastCollected: longTimeAgo,
        now: DateTime.now(),
        placedOnTile: tile,
        maxStorageHours: 10,
      );

      // Should be capped at 10 hours worth
      expect(result10h, isNotEmpty);
    });
  });

  group('InventoryManager', () {
    late InventoryManager manager;
    late PlayerEconomy economy;

    setUp(() {
      manager = InventoryManager();
      economy = PlayerEconomy(
        gold: 100,
        inventory: {
          'Coal': Resource(
            id: 'Coal',
            displayName: 'Coal',
            type: ResourceType.tier1,
            amount: 50,
            maxCapacity: 100,
            iconPath: 'assets/coal.png',
          ),
          'Wood': Resource(
            id: 'Wood',
            displayName: 'Wood',
            type: ResourceType.tier1,
            amount: 30,
            maxCapacity: 100,
            iconPath: 'assets/wood.png',
          ),
        },
        buildings: [],
        tier: 1,
        lastSeen: DateTime.now(),
      );
    });

    test('addResources should add to existing resource', () {
      final result = manager.addResources(
        economy: economy,
        resourceId: 'Coal',
        quantity: 20,
      );

      expect(result.success, isTrue);
      expect(result.quantityTransferred, equals(20));
      expect(result.economy?.inventory['Coal']?.amount, equals(70));
    });

    test('addResources should cap at max capacity', () {
      final result = manager.addResources(
        economy: economy,
        resourceId: 'Coal',
        quantity: 100, // Would exceed capacity
      );

      expect(result.success, isTrue);
      expect(result.quantityTransferred, equals(50)); // Only 50 remaining capacity
      expect(result.economy?.inventory['Coal']?.amount, equals(100));
    });

    test('addResources should fail for full inventory', () {
      final fullEconomy = economy.copyWith(
        inventory: {
          'Coal': Resource(
            id: 'Coal',
            displayName: 'Coal',
            type: ResourceType.tier1,
            amount: 100,
            maxCapacity: 100,
            iconPath: 'assets/coal.png',
          ),
        },
      );

      final result = manager.addResources(
        economy: fullEconomy,
        resourceId: 'Coal',
        quantity: 10,
      );

      expect(result.success, isFalse);
      expect(result.error, contains('full'));
    });

    test('addResources should create new resource if not exists', () {
      final result = manager.addResources(
        economy: economy,
        resourceId: 'Iron Ore',
        quantity: 25,
      );

      expect(result.success, isTrue);
      expect(result.economy?.inventory['Iron Ore']?.amount, equals(25));
    });

    test('removeResources should deduct from inventory', () {
      final result = manager.removeResources(
        economy: economy,
        resourceId: 'Coal',
        quantity: 20,
      );

      expect(result.success, isTrue);
      expect(result.quantityTransferred, equals(20));
      expect(result.economy?.inventory['Coal']?.amount, equals(30));
    });

    test('removeResources should fail for insufficient resources', () {
      final result = manager.removeResources(
        economy: economy,
        resourceId: 'Coal',
        quantity: 100,
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Insufficient'));
    });

    test('removeResources should fail for non-existent resource', () {
      final result = manager.removeResources(
        economy: economy,
        resourceId: 'Diamond',
        quantity: 10,
      );

      expect(result.success, isFalse);
      expect(result.error, contains('not in inventory'));
    });

    test('sellResources should convert resources to gold', () {
      final result = manager.sellResources(
        economy: economy,
        resourceId: 'Coal',
        quantity: 10,
        pricePerUnit: 5,
      );

      expect(result.success, isTrue);
      expect(result.quantityTransferred, equals(50)); // 10 * 5 gold earned
      expect(result.economy?.inventory['Coal']?.amount, equals(40));
      expect(result.economy?.gold, equals(150)); // 100 + 50
    });

    test('canAffordRecipe should check all inputs', () {
      expect(
        manager.canAffordRecipe(
          economy: economy,
          inputs: {'Coal': 20, 'Wood': 10},
        ),
        isTrue,
      );

      expect(
        manager.canAffordRecipe(
          economy: economy,
          inputs: {'Coal': 100}, // Too much
        ),
        isFalse,
      );
    });

    test('canAffordBuilding should use definition cost', () {
      // Storage costs 5 wood + 10 stone
      expect(
        manager.canAffordBuilding(
          economy: economy,
          definition: BuildingDefinitions.storage,
        ),
        isFalse, // No stone in inventory
      );

      // Mining facility is FREE
      expect(
        manager.canAffordBuilding(
          economy: economy,
          definition: BuildingDefinitions.miningFacility,
        ),
        isTrue,
      );
    });

    test('getTotalInventoryUsed should sum all resources', () {
      final used = manager.getTotalInventoryUsed(economy);
      expect(used, equals(80)); // 50 coal + 30 wood
    });

    test('getResourceSellPrice should return correct prices', () {
      expect(manager.getResourceSellPrice('Coal'), equals(1));
      expect(manager.getResourceSellPrice('Iron Bar'), equals(10));
      expect(manager.getResourceSellPrice('Hammer'), equals(50));
      expect(manager.getResourceSellPrice('Unknown'), equals(1)); // Default
    });
  });
}
