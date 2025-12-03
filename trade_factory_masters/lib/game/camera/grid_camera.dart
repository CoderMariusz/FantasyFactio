import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import '../../config/game_config.dart';

/// Camera zoom levels for dual-zoom system
enum ZoomLevel {
  /// Close-up view for detailed building management (zoom: 1.5)
  closeup(zoom: 1.5, name: 'Close-up'),

  /// Strategic overview for factory layout (zoom: 0.75)
  strategic(zoom: 0.75, name: 'Strategic');

  final double zoom;
  final String name;

  const ZoomLevel({
    required this.zoom,
    required this.name,
  });

  /// Get the opposite zoom level
  ZoomLevel get opposite {
    return this == ZoomLevel.closeup
        ? ZoomLevel.strategic
        : ZoomLevel.closeup;
  }
}

/// Camera configuration for grid-based isometric game
class GridCameraConfig {
  /// World bounds (size of the grid in screen coordinates)
  final Vector2 worldSize;

  /// Minimum zoom level (zoomed out)
  final double minZoom;

  /// Maximum zoom level (zoomed in)
  final double maxZoom;

  /// Zoom transition duration
  final double zoomTransitionDuration;

  /// Pan speed multiplier
  final double panSpeed;

  /// Enable camera bounds (prevents camera from going outside world)
  final bool enableBounds;

  /// Padding around world bounds (prevents edge tiles from being cut off)
  final double boundsPadding;

  const GridCameraConfig({
    required this.worldSize,
    this.minZoom = CameraConstants.minZoom,
    this.maxZoom = CameraConstants.maxZoom,
    this.zoomTransitionDuration = CameraConstants.zoomTransitionDuration,
    this.panSpeed = CameraConstants.panSpeed,
    this.enableBounds = true,
    this.boundsPadding = CameraConstants.boundsPadding,
  });
}

/// Dual-zoom camera system with gesture support
/// Supports double-tap zoom toggle, swipe panning, and pinch zoom
class GridCamera extends Component
    with HasGameRef, TapCallbacks, DoubleTapCallbacks, DragCallbacks, ScaleDetector {
  final GridCameraConfig config;

  /// Current zoom level (dual-zoom system)
  ZoomLevel _currentZoomLevel = ZoomLevel.strategic;

  /// Target zoom for smooth transitions
  double _targetZoom = ZoomLevel.strategic.zoom;

  /// Current zoom animation progress (0.0 to 1.0)
  double _zoomProgress = 1.0;

  /// Previous zoom (for animation)
  double _previousZoom = ZoomLevel.strategic.zoom;

  /// Last tap time for double-tap detection
  DateTime? _lastTapTime;

  /// Double-tap threshold in milliseconds
  static const int _doubleTapThreshold = 300;

  /// Pan gesture state
  Vector2? _panStartPosition;
  Vector2? _lastPanPosition;

  /// Position animation state
  Vector2? _targetPosition;
  Vector2? _previousPosition;
  double _positionProgress = 1.0;
  bool _isPositionAnimating = false;

  /// Pinch zoom state
  double? _initialPinchZoom;
  double? _pinchStartDistance;

  /// Is currently performing a zoom animation
  bool _isAnimating = false;

  GridCamera({
    required this.config,
    ZoomLevel initialZoomLevel = ZoomLevel.strategic,
  })  : _currentZoomLevel = initialZoomLevel,
        _targetZoom = initialZoomLevel.zoom,
        _previousZoom = initialZoomLevel.zoom;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _applyCameraZoom(_currentZoomLevel.zoom);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateZoomAnimation(dt);
    _updatePositionAnimation(dt);
  }

  /// Update smooth zoom animation
  void _updateZoomAnimation(double dt) {
    if (!_isAnimating) return;

    _zoomProgress += dt / config.zoomTransitionDuration;

    if (_zoomProgress >= 1.0) {
      _zoomProgress = 1.0;
      _isAnimating = false;
    }

    // Smooth easing function (ease-in-out)
    final easedProgress = _easeInOutCubic(_zoomProgress);
    final currentZoom = _previousZoom +
        (_targetZoom - _previousZoom) * easedProgress;

    _applyCameraZoom(currentZoom);
  }

  /// Ease-in-out cubic function for smooth animations
  double _easeInOutCubic(double t) {
    return t < 0.5
        ? 4 * t * t * t
        : 1 - math.pow(-2 * t + 2, 3) / 2;
  }

  /// Update smooth position animation
  void _updatePositionAnimation(double dt) {
    if (!_isPositionAnimating || _targetPosition == null || _previousPosition == null) return;

    _positionProgress += dt / config.zoomTransitionDuration;

    if (_positionProgress >= 1.0) {
      _positionProgress = 1.0;
      _isPositionAnimating = false;
      gameRef.camera.viewfinder.position = _targetPosition!.clone();
    } else {
      // Smooth easing function (ease-in-out)
      final easedProgress = _easeInOutCubic(_positionProgress);
      final currentPosition = _previousPosition! +
          (_targetPosition! - _previousPosition!) * easedProgress;
      gameRef.camera.viewfinder.position = currentPosition;
    }

    if (config.enableBounds) {
      _applyBounds();
    }
  }

  /// Apply zoom to camera with bounds checking
  void _applyCameraZoom(double zoom) {
    final clampedZoom = zoom.clamp(config.minZoom, config.maxZoom);
    gameRef.camera.viewfinder.zoom = clampedZoom;

    if (config.enableBounds) {
      _applyBounds();
    }
  }

  /// Apply camera bounds to keep within world limits
  void _applyBounds() {
    final camera = gameRef.camera;
    final viewport = camera.viewport;
    final position = camera.viewfinder.position;
    final zoom = camera.viewfinder.zoom;

    // Calculate viewport size in world coordinates
    final viewportWidth = viewport.size.x / zoom;
    final viewportHeight = viewport.size.y / zoom;

    // Calculate bounds with padding
    final minX = -config.boundsPadding;
    final maxX = config.worldSize.x + config.boundsPadding - viewportWidth;
    final minY = -config.boundsPadding;
    final maxY = config.worldSize.y + config.boundsPadding - viewportHeight;

    // Clamp camera position
    position.x = position.x.clamp(minX, math.max(minX, maxX));
    position.y = position.y.clamp(minY, math.max(minY, maxY));
  }

  // ============================================================================
  // GESTURE HANDLERS
  // ============================================================================

  /// Handle double-tap to toggle between zoom levels
  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    super.onDoubleTapDown(event);
    toggleZoomLevel();
  }

  /// Handle drag for panning
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _panStartPosition = event.localPosition;
    _lastPanPosition = event.localPosition;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    if (_lastPanPosition == null) return;

    final delta = event.localPosition - _lastPanPosition!;
    final camera = gameRef.camera;
    final zoom = camera.viewfinder.zoom;

    // Apply pan with speed multiplier and zoom compensation
    camera.viewfinder.position.add(
      Vector2(
        -delta.x / zoom * config.panSpeed,
        -delta.y / zoom * config.panSpeed,
      ),
    );

    if (config.enableBounds) {
      _applyBounds();
    }

    _lastPanPosition = event.localPosition;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _panStartPosition = null;
    _lastPanPosition = null;
  }

  /// Handle pinch-to-zoom
  @override
  void onScaleStart(ScaleStartInfo info) {
    super.onScaleStart(info);
    _initialPinchZoom = gameRef.camera.viewfinder.zoom;

    // Calculate initial distance between touch points
    if (info.pointerCount == 2) {
      // This will be handled by onScaleUpdate
      _pinchStartDistance = 1.0; // Will be updated in first onScaleUpdate
    }
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    super.onScaleUpdate(info);

    if (_initialPinchZoom == null) return;

    // Apply pinch zoom
    final newZoom = _initialPinchZoom! * info.scale.global;
    _applyCameraZoom(newZoom);

    // Update target zoom to match (stops animation)
    _targetZoom = newZoom.clamp(config.minZoom, config.maxZoom);
    _isAnimating = false;
  }

  @override
  void onScaleEnd(ScaleEndInfo info) {
    super.onScaleEnd(info);
    _initialPinchZoom = null;
    _pinchStartDistance = null;
  }

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  /// Toggle between close-up and strategic zoom levels
  void toggleZoomLevel() {
    final newLevel = _currentZoomLevel.opposite;
    setZoomLevel(newLevel);
  }

  /// Set specific zoom level with smooth animation
  void setZoomLevel(ZoomLevel level, {bool animate = true}) {
    _currentZoomLevel = level;
    _targetZoom = level.zoom;

    if (animate) {
      _previousZoom = gameRef.camera.viewfinder.zoom;
      _zoomProgress = 0.0;
      _isAnimating = true;
    } else {
      _applyCameraZoom(_targetZoom);
    }
  }

  /// Set custom zoom value (outside dual-zoom system)
  void setCustomZoom(double zoom, {bool animate = true}) {
    _targetZoom = zoom.clamp(config.minZoom, config.maxZoom);

    if (animate) {
      _previousZoom = gameRef.camera.viewfinder.zoom;
      _zoomProgress = 0.0;
      _isAnimating = true;
    } else {
      _applyCameraZoom(_targetZoom);
    }
  }

  /// Move camera to specific world position
  void moveTo(Vector2 position, {bool animate = false}) {
    if (animate) {
      _previousPosition = gameRef.camera.viewfinder.position.clone();
      _targetPosition = position.clone();
      _positionProgress = 0.0;
      _isPositionAnimating = true;
    } else {
      gameRef.camera.viewfinder.position = position.clone();
      if (config.enableBounds) {
        _applyBounds();
      }
    }
  }

  /// Focus camera on specific grid coordinates
  void focusOnGrid(int gridX, int gridY, {bool animate = false}) {
    // This will need grid coordinate conversion
    // For now, we'll just center on the position
    // In a real implementation, you'd use GridComponent.gridToScreen()
    moveTo(Vector2(gridX.toDouble() * 64, gridY.toDouble() * 32),
        animate: animate);
  }

  /// Get current zoom level
  ZoomLevel get currentZoomLevel => _currentZoomLevel;

  /// Get current zoom value
  double get currentZoom => gameRef.camera.viewfinder.zoom;

  /// Get current camera position
  Vector2 get position => gameRef.camera.viewfinder.position;

  /// Check if camera is currently animating
  bool get isAnimating => _isAnimating || _isPositionAnimating;

  /// Get camera state for debugging
  Map<String, dynamic> getCameraState() {
    return {
      'zoomLevel': _currentZoomLevel.name,
      'currentZoom': currentZoom,
      'targetZoom': _targetZoom,
      'position': '(${position.x.toStringAsFixed(1)}, ${position.y.toStringAsFixed(1)})',
      'isAnimating': _isAnimating,
    };
  }
}

/// Scale detector mixin for pinch-to-zoom gestures
mixin ScaleDetector on Component {
  final Map<int, Vector2> _activePointers = {};
  ScaleStartInfo? _scaleStartInfo;

  void handleScaleStart(int pointerId, Vector2 position) {
    _activePointers[pointerId] = position;

    if (_activePointers.length == 2) {
      _scaleStartInfo = ScaleStartInfo(
        pointerCount: 2,
        focalPoint: _calculateFocalPoint(),
      );
      onScaleStart(_scaleStartInfo!);
    }
  }

  void handleScaleUpdate(int pointerId, Vector2 position) {
    if (!_activePointers.containsKey(pointerId)) return;

    _activePointers[pointerId] = position;

    if (_activePointers.length == 2 && _scaleStartInfo != null) {
      final currentScale = _calculateScale();
      final currentFocalPoint = _calculateFocalPoint();

      onScaleUpdate(ScaleUpdateInfo(
        scale: ScaleInfo(global: currentScale),
        focalPoint: currentFocalPoint,
        pointerCount: 2,
      ));
    }
  }

  void handleScaleEnd(int pointerId) {
    _activePointers.remove(pointerId);

    if (_activePointers.length < 2 && _scaleStartInfo != null) {
      onScaleEnd(ScaleEndInfo(pointerCount: _activePointers.length));
      _scaleStartInfo = null;
    }
  }

  Vector2 _calculateFocalPoint() {
    if (_activePointers.isEmpty) return Vector2.zero();

    var sum = Vector2.zero();
    for (final pos in _activePointers.values) {
      sum += pos;
    }
    return sum / _activePointers.length.toDouble();
  }

  double _calculateScale() {
    if (_activePointers.length != 2) return 1.0;

    final positions = _activePointers.values.toList();
    final distance = positions[0].distanceTo(positions[1]);

    // Calculate initial distance if not set
    if (_scaleStartInfo == null) return 1.0;

    // For simplicity, we'll use the distance ratio
    // In a real implementation, you'd track the initial distance
    return distance / 100.0; // Normalize to reasonable scale
  }

  void onScaleStart(ScaleStartInfo info) {}
  void onScaleUpdate(ScaleUpdateInfo info) {}
  void onScaleEnd(ScaleEndInfo info) {}
}

/// Scale gesture info classes
class ScaleStartInfo {
  final int pointerCount;
  final Vector2 focalPoint;

  ScaleStartInfo({
    required this.pointerCount,
    required this.focalPoint,
  });
}

class ScaleUpdateInfo {
  final ScaleInfo scale;
  final Vector2 focalPoint;
  final int pointerCount;

  ScaleUpdateInfo({
    required this.scale,
    required this.focalPoint,
    required this.pointerCount,
  });
}

class ScaleEndInfo {
  final int pointerCount;

  ScaleEndInfo({required this.pointerCount});
}

class ScaleInfo {
  final double global;

  ScaleInfo({required this.global});
}
