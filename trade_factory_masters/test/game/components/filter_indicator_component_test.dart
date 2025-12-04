import 'package:flutter_test/flutter_test.dart';
import 'package:flame/geometry.dart';
import 'package:trade_factory_masters/game/components/filter_indicator_component.dart';
import 'package:trade_factory_masters/domain/entities/conveyor_tile.dart';

void main() {
  group('FilterIndicatorComponent', () {
    test('creates with correct size', () {
      final indicator = FilterIndicatorComponent(
        filter: const ConveyorFilter(),
        position: Vector2(100, 100),
      );

      expect(indicator.size.x, equals(FilterIndicatorComponent.iconSize));
      expect(indicator.size.y, equals(FilterIndicatorComponent.iconSize));
    });

    test('initializes with provided filter', () {
      final filter = ConveyorFilter.whitelist(['wood']);
      final indicator = FilterIndicatorComponent(
        filter: filter,
        position: Vector2(100, 100),
      );

      expect(indicator.filter.mode, equals(FilterMode.whitelist));
      expect(indicator.filter.resourceIds, contains('wood'));
    });

    test('updates filter when updateFilter is called', () {
      final initialFilter = const ConveyorFilter();
      final indicator = FilterIndicatorComponent(
        filter: initialFilter,
        position: Vector2(100, 100),
      );

      expect(indicator.filter.mode, equals(FilterMode.allowAll));

      final newFilter = ConveyorFilter.whitelist(['stone']);
      indicator.updateFilter(newFilter);

      expect(indicator.filter.mode, equals(FilterMode.whitelist));
      expect(indicator.filter.resourceIds, contains('stone'));
    });

    test('getTooltip for allowAll filter', () {
      final indicator = FilterIndicatorComponent(
        filter: const ConveyorFilter(),
        position: Vector2(100, 100),
      );

      expect(
        indicator.getTooltip(),
        equals('No filter - all items pass'),
      );
    });

    test('getTooltip for whitelist filter', () {
      final filter = ConveyorFilter.whitelist(['wood', 'stone']);
      final indicator = FilterIndicatorComponent(
        filter: filter,
        position: Vector2(100, 100),
      );

      expect(
        indicator.getTooltip(),
        contains('Whitelist'),
      );
      expect(indicator.getTooltip(), contains('wood'));
      expect(indicator.getTooltip(), contains('stone'));
    });

    test('getTooltip for blacklist filter', () {
      final filter = ConveyorFilter.blacklist(['iron']);
      final indicator = FilterIndicatorComponent(
        filter: filter,
        position: Vector2(100, 100),
      );

      expect(
        indicator.getTooltip(),
        contains('Blacklist'),
      );
      expect(indicator.getTooltip(), contains('iron'));
    });

    test('getTooltip for single filter', () {
      final filter = ConveyorFilter.single('gold');
      final indicator = FilterIndicatorComponent(
        filter: filter,
        position: Vector2(100, 100),
      );

      expect(
        indicator.getTooltip(),
        contains('Single'),
      );
      expect(indicator.getTooltip(), contains('gold'));
    });

    test('renders without error for all modes', () {
      final modes = [
        const ConveyorFilter(),
        ConveyorFilter.whitelist(['wood']),
        ConveyorFilter.blacklist(['stone']),
        ConveyorFilter.single('iron'),
      ];

      for (final filter in modes) {
        final indicator = FilterIndicatorComponent(
          filter: filter,
          position: Vector2(100, 100),
        );

        // Component should be renderable
        expect(indicator.shouldRemove, false);
      }
    });

    test('position is set correctly', () {
      const testPosition = Vector2(50, 75);
      final indicator = FilterIndicatorComponent(
        filter: const ConveyorFilter(),
        position: testPosition,
      );

      expect(indicator.position, equals(testPosition));
    });

    test('multiple indicators can exist independently', () {
      final indicator1 = FilterIndicatorComponent(
        filter: ConveyorFilter.whitelist(['wood']),
        position: Vector2(0, 0),
      );

      final indicator2 = FilterIndicatorComponent(
        filter: ConveyorFilter.blacklist(['stone']),
        position: Vector2(100, 100),
      );

      expect(indicator1.filter.mode, equals(FilterMode.whitelist));
      expect(indicator2.filter.mode, equals(FilterMode.blacklist));

      // Update one shouldn't affect other
      indicator1.updateFilter(const ConveyorFilter());
      expect(indicator1.filter.mode, equals(FilterMode.allowAll));
      expect(indicator2.filter.mode, equals(FilterMode.blacklist));
    });
  });
}
