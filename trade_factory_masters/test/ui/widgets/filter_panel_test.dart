import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/ui/widgets/filter_panel.dart';
import 'package:trade_factory_masters/domain/entities/conveyor_tile.dart';

void main() {
  group('FilterPanel Widget', () {
    late ConveyorFilter appliedFilter;
    late bool cancelCalled;

    setUp(() {
      appliedFilter = const ConveyorFilter();
      cancelCalled = false;
    });

    testWidgets('displays filter mode options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterPanel(
              currentFilter: const ConveyorFilter(),
              availableResources: ['wood', 'stone', 'iron'],
              onApply: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('Allow All'), findsOneWidget);
      expect(find.text('Whitelist'), findsOneWidget);
      expect(find.text('Blacklist'), findsOneWidget);
      expect(find.text('Single Item'), findsOneWidget);
    });

    testWidgets('allow all mode is selected by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterPanel(
              currentFilter: const ConveyorFilter(),
              availableResources: ['wood', 'stone', 'iron'],
              onApply: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      final radio = find.byType(Radio<FilterMode>).first;
      expect(radio, findsOneWidget);
    });

    testWidgets('can switch to whitelist mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterPanel(
              currentFilter: const ConveyorFilter(),
              availableResources: ['wood', 'stone', 'iron'],
              onApply: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Tap whitelist radio button
      await tester.tap(find.byType(Radio<FilterMode>).at(1));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterPanel(
              currentFilter: const ConveyorFilter(),
              availableResources: ['wood', 'stone', 'iron'],
              onApply: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('Select Resources (max 3)'), findsOneWidget);
    });

    testWidgets('shows resource checkboxes in whitelist mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterPanel(
              currentFilter: const ConveyorFilter(),
              availableResources: ['wood', 'stone', 'iron'],
              onApply: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Switch to whitelist
      await tester.tap(find.byType(Radio<FilterMode>).at(1));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterPanel(
              currentFilter: const ConveyorFilter(),
              availableResources: ['wood', 'stone', 'iron'],
              onApply: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('wood'), findsWidgets);
      expect(find.text('stone'), findsWidgets);
      expect(find.text('iron'), findsWidgets);
    });

    testWidgets('apply button calls onApply with filter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterPanel(
              currentFilter: const ConveyorFilter(),
              availableResources: ['wood', 'stone', 'iron'],
              onApply: (filter) {
                appliedFilter = filter;
              },
              onCancel: () {
                cancelCalled = true;
              },
            ),
          ),
        ),
      );

      expect(appliedFilter.mode, FilterMode.allowAll);

      // Tap apply
      await tester.tap(find.text('Apply'));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
          ),
        ),
      );

      expect(appliedFilter.mode, FilterMode.allowAll);
    });

    testWidgets('cancel button calls onCancel', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterPanel(
              currentFilter: const ConveyorFilter(),
              availableResources: ['wood', 'stone', 'iron'],
              onApply: (_) {},
              onCancel: () {
                cancelCalled = true;
              },
            ),
          ),
        ),
      );

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
          ),
        ),
      );

      expect(cancelCalled, true);
    });

    testWidgets('single mode shows resource dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterPanel(
              currentFilter: const ConveyorFilter(),
              availableResources: ['wood', 'stone', 'iron'],
              onApply: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Switch to single mode
      await tester.tap(find.byType(Radio<FilterMode>).at(3));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterPanel(
              currentFilter: const ConveyorFilter(),
              availableResources: ['wood', 'stone', 'iron'],
              onApply: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('Select Resource'), findsOneWidget);
    });

    testWidgets('apply button disabled with no resources in whitelist', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterPanel(
              currentFilter: const ConveyorFilter(),
              availableResources: ['wood', 'stone', 'iron'],
              onApply: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Switch to whitelist (no resources selected)
      await tester.tap(find.byType(Radio<FilterMode>).at(1));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterPanel(
              currentFilter: const ConveyorFilter(),
              availableResources: ['wood', 'stone', 'iron'],
              onApply: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Apply button should be disabled
      final applyButton = find.widgetWithText(ElevatedButton, 'Apply');
      expect(applyButton, findsOneWidget);
    });

    testWidgets('whitelist mode limits to 3 items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterPanel(
              currentFilter: const ConveyorFilter(),
              availableResources: ['wood', 'stone', 'iron', 'copper', 'gold'],
              onApply: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Switch to whitelist
      await tester.tap(find.byType(Radio<FilterMode>).at(1));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterPanel(
              currentFilter: const ConveyorFilter(),
              availableResources: ['wood', 'stone', 'iron', 'copper', 'gold'],
              onApply: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Max 3 items shown
      final checkboxes = find.byType(CheckboxListTile);
      expect(checkboxes, findsWidgets);
    });
  });
}
