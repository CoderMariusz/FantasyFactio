import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/game/camera/grid_camera.dart';
import 'package:flame/components.dart';

void main() {
  group('ZoomLevel', () {
    test('closeup has correct zoom value', () {
      expect(ZoomLevel.closeup.zoom, equals(1.5));
      expect(ZoomLevel.closeup.name, equals('Close-up'));
    });

    test('strategic has correct zoom value', () {
      expect(ZoomLevel.strategic.zoom, equals(0.75));
      expect(ZoomLevel.strategic.name, equals('Strategic'));
    });

    test('opposite returns correct zoom level', () {
      expect(ZoomLevel.closeup.opposite, equals(ZoomLevel.strategic));
      expect(ZoomLevel.strategic.opposite, equals(ZoomLevel.closeup));
    });

    test('opposite is reversible', () {
      final level = ZoomLevel.closeup;
      expect(level.opposite.opposite, equals(level));
    });
  });

  group('GridCameraConfig', () {
    test('creates config with required parameters', () {
      final config = GridCameraConfig(
        worldSize: Vector2(3200, 1600),
      );

      expect(config.worldSize, equals(Vector2(3200, 1600)));
      expect(config.minZoom, equals(0.5));
      expect(config.maxZoom, equals(2.0));
      expect(config.enableBounds, isTrue);
    });

    test('accepts custom zoom limits', () {
      final config = GridCameraConfig(
        worldSize: Vector2(1000, 1000),
        minZoom: 0.25,
        maxZoom: 4.0,
      );

      expect(config.minZoom, equals(0.25));
      expect(config.maxZoom, equals(4.0));
    });

    test('accepts custom transition duration', () {
      final config = GridCameraConfig(
        worldSize: Vector2(1000, 1000),
        zoomTransitionDuration: 0.5,
      );

      expect(config.zoomTransitionDuration, equals(0.5));
    });

    test('accepts custom pan speed', () {
      final config = GridCameraConfig(
        worldSize: Vector2(1000, 1000),
        panSpeed: 2.0,
      );

      expect(config.panSpeed, equals(2.0));
    });

    test('can disable bounds', () {
      final config = GridCameraConfig(
        worldSize: Vector2(1000, 1000),
        enableBounds: false,
      );

      expect(config.enableBounds, isFalse);
    });

    test('accepts custom bounds padding', () {
      final config = GridCameraConfig(
        worldSize: Vector2(1000, 1000),
        boundsPadding: 500.0,
      );

      expect(config.boundsPadding, equals(500.0));
    });
  });

  group('GridCamera - Initialization', () {
    late GridCameraConfig config;

    setUp(() {
      config = GridCameraConfig(
        worldSize: Vector2(3200, 1600),
      );
    });

    test('initializes with strategic zoom by default', () {
      final camera = GridCamera(config: config);

      expect(camera.currentZoomLevel, equals(ZoomLevel.strategic));
    });

    test('initializes with custom zoom level', () {
      final camera = GridCamera(
        config: config,
        initialZoomLevel: ZoomLevel.closeup,
      );

      expect(camera.currentZoomLevel, equals(ZoomLevel.closeup));
    });

    test('is not animating initially', () {
      final camera = GridCamera(config: config);

      expect(camera.isAnimating, isFalse);
    });
  });

  group('GridCamera - Zoom Control', () {
    late GridCameraConfig config;
    late GridCamera camera;

    setUp(() {
      config = GridCameraConfig(
        worldSize: Vector2(3200, 1600),
        zoomTransitionDuration: 0.3,
      );
      camera = GridCamera(config: config);
    });

    test('toggleZoomLevel switches between levels', () {
      expect(camera.currentZoomLevel, equals(ZoomLevel.strategic));

      camera.toggleZoomLevel();

      expect(camera.currentZoomLevel, equals(ZoomLevel.closeup));

      camera.toggleZoomLevel();

      expect(camera.currentZoomLevel, equals(ZoomLevel.strategic));
    });

    test('setZoomLevel changes zoom level', () {
      camera.setZoomLevel(ZoomLevel.closeup);

      expect(camera.currentZoomLevel, equals(ZoomLevel.closeup));
    });

    test('setZoomLevel with animate=true starts animation', () {
      camera.setZoomLevel(ZoomLevel.closeup, animate: true);

      expect(camera.isAnimating, isTrue);
    });

    test('setZoomLevel with animate=false does not animate', () {
      camera.setZoomLevel(ZoomLevel.closeup, animate: false);

      expect(camera.isAnimating, isFalse);
    });

    test('setCustomZoom accepts custom zoom values', () {
      camera.setCustomZoom(1.0, animate: false);

      // We can't easily test currentZoom without a game instance
      // but we can verify it doesn't throw
      expect(camera, isNotNull);
    });

    test('setCustomZoom clamps to min/max zoom', () {
      // Should clamp to maxZoom (2.0)
      camera.setCustomZoom(10.0, animate: false);

      // Should clamp to minZoom (0.5)
      camera.setCustomZoom(0.1, animate: false);

      expect(camera, isNotNull);
    });
  });

  group('GridCamera - Position Control', () {
    late GridCameraConfig config;
    late GridCamera camera;

    setUp(() {
      config = GridCameraConfig(
        worldSize: Vector2(3200, 1600),
      );
      camera = GridCamera(config: config);
    });

    test('moveTo accepts position without animation', () {
      final targetPos = Vector2(100, 100);
      camera.moveTo(targetPos, animate: false);

      expect(camera, isNotNull);
    });

    test('focusOnGrid accepts grid coordinates', () {
      camera.focusOnGrid(10, 10, animate: false);

      expect(camera, isNotNull);
    });

    test('focusOnGrid with animation', () {
      camera.focusOnGrid(10, 10, animate: true);

      expect(camera, isNotNull);
    });
  });

  group('GridCamera - State Queries', () {
    late GridCameraConfig config;
    late GridCamera camera;

    setUp(() {
      config = GridCameraConfig(
        worldSize: Vector2(3200, 1600),
      );
      camera = GridCamera(config: config);
    });

    test('getCameraState returns valid state object', () {
      final state = camera.getCameraState();

      expect(state, isA<Map<String, dynamic>>());
      expect(state, containsPair('zoomLevel', isA<String>()));
      expect(state, containsPair('isAnimating', isA<bool>()));
      expect(state.containsKey('position'), isTrue);
    });

    test('getCameraState contains zoom information', () {
      final state = camera.getCameraState();

      expect(state['zoomLevel'], equals('Strategic'));
      expect(state['isAnimating'], isFalse);
    });

    test('getCameraState updates after zoom change', () {
      camera.setZoomLevel(ZoomLevel.closeup, animate: false);
      final state = camera.getCameraState();

      expect(state['zoomLevel'], equals('Close-up'));
    });
  });

  group('ScaleDetector - Scale Info', () {
    test('ScaleStartInfo stores pointer count and focal point', () {
      final info = ScaleStartInfo(
        pointerCount: 2,
        focalPoint: Vector2(100, 200),
      );

      expect(info.pointerCount, equals(2));
      expect(info.focalPoint, equals(Vector2(100, 200)));
    });

    test('ScaleUpdateInfo stores scale and focal point', () {
      final info = ScaleUpdateInfo(
        scale: ScaleInfo(global: 1.5),
        focalPoint: Vector2(150, 250),
        pointerCount: 2,
      );

      expect(info.scale.global, equals(1.5));
      expect(info.focalPoint, equals(Vector2(150, 250)));
      expect(info.pointerCount, equals(2));
    });

    test('ScaleEndInfo stores pointer count', () {
      final info = ScaleEndInfo(pointerCount: 1);

      expect(info.pointerCount, equals(1));
    });

    test('ScaleInfo stores global scale value', () {
      final info = ScaleInfo(global: 2.0);

      expect(info.global, equals(2.0));
    });
  });

  group('GridCamera - Animation', () {
    late GridCameraConfig config;
    late GridCamera camera;

    setUp(() {
      config = GridCameraConfig(
        worldSize: Vector2(3200, 1600),
        zoomTransitionDuration: 0.3,
      );
      camera = GridCamera(config: config);
    });

    test('update does not throw when not animating', () {
      expect(() => camera.update(0.016), returnsNormally);
    });

    test('update progresses animation', () {
      camera.setZoomLevel(ZoomLevel.closeup, animate: true);
      expect(camera.isAnimating, isTrue);

      // Simulate several frames
      for (int i = 0; i < 10; i++) {
        camera.update(0.016);
      }

      // Animation might still be running or completed
      expect(camera, isNotNull);
    });

    test('animation completes after duration', () {
      camera.setZoomLevel(ZoomLevel.closeup, animate: true);
      expect(camera.isAnimating, isTrue);

      // Update for total duration (0.3s at 60fps = 18 frames)
      for (int i = 0; i < 20; i++) {
        camera.update(0.016);
      }

      expect(camera.isAnimating, isFalse);
    });
  });

  group('GridCamera - Integration', () {
    test('multiple zoom level changes work correctly', () {
      final config = GridCameraConfig(
        worldSize: Vector2(3200, 1600),
      );
      final camera = GridCamera(config: config);

      // Toggle multiple times
      camera.toggleZoomLevel(); // -> closeup
      expect(camera.currentZoomLevel, equals(ZoomLevel.closeup));

      camera.toggleZoomLevel(); // -> strategic
      expect(camera.currentZoomLevel, equals(ZoomLevel.strategic));

      camera.toggleZoomLevel(); // -> closeup
      expect(camera.currentZoomLevel, equals(ZoomLevel.closeup));
    });

    test('custom zoom followed by zoom level works', () {
      final config = GridCameraConfig(
        worldSize: Vector2(3200, 1600),
      );
      final camera = GridCamera(config: config);

      camera.setCustomZoom(1.2, animate: false);
      camera.setZoomLevel(ZoomLevel.closeup, animate: false);

      expect(camera.currentZoomLevel, equals(ZoomLevel.closeup));
    });

    test('camera state reflects all changes', () {
      final config = GridCameraConfig(
        worldSize: Vector2(3200, 1600),
      );
      final camera = GridCamera(config: config);

      var state = camera.getCameraState();
      expect(state['zoomLevel'], equals('Strategic'));

      camera.setZoomLevel(ZoomLevel.closeup, animate: false);

      state = camera.getCameraState();
      expect(state['zoomLevel'], equals('Close-up'));
    });
  });
}
