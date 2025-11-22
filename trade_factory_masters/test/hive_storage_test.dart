import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:trade_factory_masters/domain/entities/resource.dart';
import 'package:trade_factory_masters/domain/entities/building.dart';
import 'package:trade_factory_masters/domain/entities/player_economy.dart';

void main() {
  setUpAll(() {
    // Initialize Hive for testing
    Hive.init('test/hive_test_db');

    // Register adapters
    Hive.registerAdapter(ResourceAdapter());
    Hive.registerAdapter(ResourceTypeAdapter());
    Hive.registerAdapter(BuildingAdapter());
    Hive.registerAdapter(BuildingTypeAdapter());
    Hive.registerAdapter(GridPositionAdapter());
    Hive.registerAdapter(PlayerEconomyAdapter());
    Hive.registerAdapter(ProductionConfigAdapter());
    Hive.registerAdapter(UpgradeConfigAdapter());
  });

  tearDownAll(() async {
    // Clean up after tests
    await Hive.close();
  });

  group('Hive Storage Tests', () {
    test('Save and Load PlayerEconomy', () async {
      // Create test data
      final testEconomy = PlayerEconomy(
        gold: 5000,
        tier: 1,
        inventory: {
          'wood': const Resource(
            id: 'wood',
            displayName: 'Wood',
            type: ResourceType.tier1,
            amount: 100,
            maxCapacity: 1000,
            iconPath: 'assets/images/resources/wood.png',
          ),
          'stone': const Resource(
            id: 'stone',
            displayName: 'Stone',
            type: ResourceType.tier1,
            amount: 75,
            maxCapacity: 1000,
            iconPath: 'assets/images/resources/stone.png',
          ),
        },
        buildings: [
          Building(
            id: 'collector_1',
            type: BuildingType.collector,
            level: 2,
            gridPosition: const GridPosition(x: 5, y: 10),
            production: const ProductionConfig(
              baseRate: 10.0,
              resourceType: 'wood',
            ),
            upgradeConfig: const UpgradeConfig(
              baseCost: 100,
              costIncrement: 20,
            ),
            lastCollected: DateTime.now(),
            isActive: true,
          ),
        ],
        lastSeen: DateTime.now(),
      );

      // Open box and save
      final box = await Hive.openBox<PlayerEconomy>('player_economy_test');
      await box.put('current_player', testEconomy);

      // Load and verify
      final loaded = box.get('current_player');

      expect(loaded, isNotNull);
      expect(loaded!.gold, equals(5000));
      expect(loaded.tier, equals(1));
      expect(loaded.inventory.length, equals(2));
      expect(loaded.inventory['wood']!.displayName, equals('Wood'));
      expect(loaded.inventory['wood']!.amount, equals(100));
      expect(loaded.buildings.length, equals(1));
      expect(loaded.buildings[0].type, equals(BuildingType.collector));
      expect(loaded.buildings[0].level, equals(2));

      // Clean up
      await box.clear();
      await box.close();
    });

    test('Clear cache functionality', () async {
      // Create test data
      final testEconomy = PlayerEconomy(
        gold: 1000,
        tier: 1,
        inventory: const {},
        buildings: const [],
        lastSeen: DateTime.now(),
      );

      // Open box and save
      final box = await Hive.openBox<PlayerEconomy>('player_economy_test2');
      await box.put('player_data', testEconomy);

      expect(box.length, equals(1));

      // Clear cache
      await box.clear();

      expect(box.length, equals(0));
      expect(box.get('player_data'), isNull);

      // Clean up
      await box.close();
    });

    test('Multiple PlayerEconomy instances', () async {
      final box = await Hive.openBox<PlayerEconomy>('multi_player_test');

      // Create multiple players
      for (int i = 1; i <= 5; i++) {
        final economy = PlayerEconomy(
          gold: 1000 * i,
          tier: 1,
          inventory: const {},
          buildings: const [],
          lastSeen: DateTime.now(),
        );
        await box.put('player_$i', economy);
      }

      expect(box.length, equals(5));

      // Verify all saved correctly
      for (int i = 1; i <= 5; i++) {
        final loaded = box.get('player_$i');
        expect(loaded, isNotNull);
        expect(loaded!.gold, equals(1000 * i));
        expect(loaded.tier, equals(1));
      }

      // Clean up
      await box.clear();
      await box.close();
    });

    test('Performance: Save 1000 PlayerEconomy instances', () async {
      final box = await Hive.openBox<PlayerEconomy>('performance_test');
      final stopwatch = Stopwatch()..start();

      // Save 1000 instances
      for (int i = 0; i < 1000; i++) {
        final economy = PlayerEconomy(
          gold: 1000 + i,
          tier: 1,
          inventory: {
            'res_$i': Resource(
              id: 'res_$i',
              displayName: 'Resource $i',
              type: ResourceType.tier1,
              amount: i * 10,
              maxCapacity: 1000,
              iconPath: 'assets/images/resources/resource_$i.png',
            ),
          },
          buildings: const [],
          lastSeen: DateTime.now(),
        );
        await box.put('perf_$i', economy);
      }

      stopwatch.stop();
      final saveTime = stopwatch.elapsedMilliseconds;

      debugPrint('✅ Saved 1000 PlayerEconomy in ${saveTime}ms');
      expect(saveTime, lessThan(2000), reason: 'Should save 1000 items in <2s');

      // Test read performance
      stopwatch.reset();
      stopwatch.start();

      for (int i = 0; i < 1000; i++) {
        final loaded = box.get('perf_$i');
        expect(loaded, isNotNull);
      }

      stopwatch.stop();
      final readTime = stopwatch.elapsedMilliseconds;

      debugPrint('✅ Read 1000 PlayerEconomy in ${readTime}ms');
      expect(readTime, lessThan(500), reason: 'Should read 1000 items in <500ms');

      // Clean up
      await box.clear();
      await box.close();
    });
  });
}
