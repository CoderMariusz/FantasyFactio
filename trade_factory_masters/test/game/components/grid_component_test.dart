import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/game/components/grid_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

void main() {
  group('GridConfig', () {
    test('default configuration creates 50x50 grid with 32px tiles', () {
      const config = GridConfig();

      expect(config.gridWidth, equals(50));
      expect(config.gridHeight, equals(50));
      expect(config.tileSize, equals(32.0));
      // Backwards compatibility
      expect(config.tileWidth, equals(32.0));
      expect(config.tileHeight, equals(32.0));
    });

    test('custom configuration accepts custom values', () {
      const config = GridConfig(
        gridWidth: 100,
        gridHeight: 100,
        tileSize: 64.0,
      );

      expect(config.gridWidth, equals(100));
      expect(config.gridHeight, equals(100));
      expect(config.tileSize, equals(64.0));
    });

    group('gridToScreen conversion (top-down)', () {
      const config = GridConfig();

      test('converts (0,0) to origin', () {
        final screenPos = config.gridToScreen(0, 0);

        expect(screenPos.x, equals(0.0));
        expect(screenPos.y, equals(0.0));
      });

      test('converts (1,0) correctly', () {
        final screenPos = config.gridToScreen(1, 0);

        // Top-down: screenX = gridX * tileSize = 1 * 32 = 32
        expect(screenPos.x, equals(32.0));
        // Top-down: screenY = gridY * tileSize = 0 * 32 = 0
        expect(screenPos.y, equals(0.0));
      });

      test('converts (0,1) correctly', () {
        final screenPos = config.gridToScreen(0, 1);

        // Top-down: screenX = 0 * 32 = 0
        expect(screenPos.x, equals(0.0));
        // Top-down: screenY = 1 * 32 = 32
        expect(screenPos.y, equals(32.0));
      });

      test('converts (5,5) correctly', () {
        final screenPos = config.gridToScreen(5, 5);

        // Top-down: screenX = 5 * 32 = 160
        expect(screenPos.x, equals(160.0));
        // Top-down: screenY = 5 * 32 = 160
        expect(screenPos.y, equals(160.0));
      });
    });

    group('screenToGrid conversion', () {
      const config = GridConfig();

      test('converts origin to (0,0)', () {
        final gridPos = config.screenToGrid(0.0, 0.0);

        expect(gridPos.x, closeTo(0.0, 0.01));
        expect(gridPos.y, closeTo(0.0, 0.01));
      });

      test('converts screen coordinates back to grid (inverse test)', () {
        // Test round-trip conversion
        final originalGrid = Vector2(10, 15);
        final screenPos = config.gridToScreen(10, 15);
        final convertedGrid = config.screenToGrid(screenPos.x, screenPos.y);

        expect(convertedGrid.x, closeTo(originalGrid.x, 0.01));
        expect(convertedGrid.y, closeTo(originalGrid.y, 0.01));
      });
    });

    group('isValidGridPosition', () {
      const config = GridConfig();

      test('returns true for valid positions', () {
        expect(config.isValidGridPosition(0, 0), isTrue);
        expect(config.isValidGridPosition(25, 25), isTrue);
        expect(config.isValidGridPosition(49, 49), isTrue);
      });

      test('returns false for negative positions', () {
        expect(config.isValidGridPosition(-1, 0), isFalse);
        expect(config.isValidGridPosition(0, -1), isFalse);
        expect(config.isValidGridPosition(-1, -1), isFalse);
      });

      test('returns false for out-of-bounds positions', () {
        expect(config.isValidGridPosition(50, 0), isFalse);
        expect(config.isValidGridPosition(0, 50), isFalse);
        expect(config.isValidGridPosition(50, 50), isFalse);
      });
    });

    test('getWorldBounds returns correct bounding box for top-down', () {
      const config = GridConfig();
      final bounds = config.getWorldBounds();

      expect(bounds, isA<Rect>());
      // Top-down: width = gridWidth * tileSize = 50 * 32 = 1600
      expect(bounds.width, equals(1600.0));
      expect(bounds.height, equals(1600.0));
      expect(bounds.left, equals(0.0));
      expect(bounds.top, equals(0.0));
    });
  });

  group('GridCullingManager', () {
    late GridConfig config;
    late GridCullingManager cullingManager;

    setUp(() {
      config = const GridConfig();
      cullingManager = GridCullingManager(config);
    });

    test('calculates visible range for small viewport', () {
      final viewport = Rect.fromLTWH(0, 0, 800, 600);
      final range = cullingManager.calculateVisibleRange(viewport);

      expect(range.minX, greaterThanOrEqualTo(0));
      expect(range.maxX, lessThan(config.gridWidth));
      expect(range.minY, greaterThanOrEqualTo(0));
      expect(range.maxY, lessThan(config.gridHeight));
    });

    test('visible range respects grid bounds', () {
      // Viewport far outside grid
      final viewport = Rect.fromLTWH(-1000, -1000, 100, 100);
      final range = cullingManager.calculateVisibleRange(viewport);

      expect(range.minX, greaterThanOrEqualTo(0));
      expect(range.maxX, lessThan(config.gridWidth));
      expect(range.minY, greaterThanOrEqualTo(0));
      expect(range.maxY, lessThan(config.gridHeight));
    });

    test('isCellVisible correctly identifies visible cells', () {
      final viewport = Rect.fromLTWH(0, 0, 800, 600);
      final range = cullingManager.calculateVisibleRange(viewport);

      // Cells within range should be visible
      expect(
        cullingManager.isCellVisible(range.minX, range.minY, range),
        isTrue,
      );

      // Cells outside range should not be visible
      expect(
        cullingManager.isCellVisible(range.maxX + 10, range.maxY + 10, range),
        isFalse,
      );
    });

    test('visible range tile count is correct', () {
      final viewport = Rect.fromLTWH(0, 0, 800, 600);
      final range = cullingManager.calculateVisibleRange(viewport);

      final expectedCount =
          (range.maxX - range.minX + 1) * (range.maxY - range.minY + 1);
      expect(range.tileCount, equals(expectedCount));
    });
  });

  group('VisibleGridRange', () {
    test('calculates tile count correctly', () {
      const range = VisibleGridRange(
        minX: 0,
        maxX: 9,
        minY: 0,
        maxY: 9,
      );

      expect(range.tileCount, equals(100)); // 10 * 10
    });

    test('toString provides readable output', () {
      const range = VisibleGridRange(
        minX: 5,
        maxX: 15,
        minY: 10,
        maxY: 20,
      );

      final str = range.toString();
      expect(str, contains('5-15'));
      expect(str, contains('10-20'));
      expect(str, contains('121')); // (15-5+1) * (20-10+1) = 11 * 11 = 121
    });
  });

  group('GridComponent', () {
    test('initializes with default configuration', () {
      final grid = GridComponent();

      expect(grid.config.gridWidth, equals(50));
      expect(grid.config.gridHeight, equals(50));
    });

    test('initializes with custom configuration', () {
      const customConfig = GridConfig(
        gridWidth: 100,
        gridHeight: 100,
      );
      final grid = GridComponent(config: customConfig);

      expect(grid.config.gridWidth, equals(100));
      expect(grid.config.gridHeight, equals(100));
    });

    test('gridSize returns correct dimensions', () {
      final grid = GridComponent();
      final size = grid.gridSize;

      expect(size.x, equals(50.0));
      expect(size.y, equals(50.0));
    });

    test('isValidPosition delegates to config', () {
      final grid = GridComponent();

      expect(grid.isValidPosition(0, 0), isTrue);
      expect(grid.isValidPosition(49, 49), isTrue);
      expect(grid.isValidPosition(50, 50), isFalse);
      expect(grid.isValidPosition(-1, -1), isFalse);
    });

    test('gridToScreen delegates to config (top-down)', () {
      final grid = GridComponent();
      final screenPos = grid.gridToScreen(5, 5);

      // Top-down: x = 5 * 32 = 160, y = 5 * 32 = 160
      expect(screenPos.x, equals(160.0));
      expect(screenPos.y, equals(160.0));
    });

    test('screenToGrid returns null for invalid positions', () {
      final grid = GridComponent();

      // Far outside grid
      final gridPos = grid.screenToGrid(Vector2(10000, 10000));

      expect(gridPos, isNull);
    });

    test('getPerformanceMetrics returns valid data', () {
      final grid = GridComponent();
      final metrics = grid.getPerformanceMetrics();

      expect(metrics, containsPair('renderedTiles', isA<int>()));
      expect(metrics, containsPair('totalTiles', 2500)); // 50 * 50
      expect(metrics, containsPair('cullRate', isA<double>()));
    });
  });
}
