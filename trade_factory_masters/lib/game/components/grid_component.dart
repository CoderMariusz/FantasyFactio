import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Grid configuration for the game world
/// Defines the size and visual properties of the grid
class GridConfig {
  /// Grid dimensions (50x50 for Trade Factory Masters)
  final int gridWidth;
  final int gridHeight;

  /// Tile size in pixels (isometric diamond size)
  final double tileWidth;
  final double tileHeight;

  /// Grid line colors
  final Color primaryLineColor;
  final Color secondaryLineColor;

  /// Enable/disable grid lines rendering
  final bool showGridLines;

  const GridConfig({
    this.gridWidth = 50,
    this.gridHeight = 50,
    this.tileWidth = 64.0,
    this.tileHeight = 32.0,
    this.primaryLineColor = const Color(0xFF333333),
    this.secondaryLineColor = const Color(0xFF222222),
    this.showGridLines = true,
  });

  /// Convert grid coordinates to isometric screen coordinates
  /// Formula for isometric projection:
  /// screenX = (gridX - gridY) * (tileWidth / 2)
  /// screenY = (gridX + gridY) * (tileHeight / 2)
  Vector2 gridToScreen(int gridX, int gridY) {
    final screenX = (gridX - gridY) * (tileWidth / 2);
    final screenY = (gridX + gridY) * (tileHeight / 2);
    return Vector2(screenX, screenY);
  }

  /// Convert screen coordinates to grid coordinates
  /// Inverse of gridToScreen transformation
  Vector2 screenToGrid(double screenX, double screenY) {
    final gridX = (screenX / (tileWidth / 2) + screenY / (tileHeight / 2)) / 2;
    final gridY = (screenY / (tileHeight / 2) - screenX / (tileWidth / 2)) / 2;
    return Vector2(gridX, gridY);
  }

  /// Check if grid coordinates are valid
  bool isValidGridPosition(int x, int y) {
    return x >= 0 && x < gridWidth && y >= 0 && y < gridHeight;
  }

  /// Get world bounds (in screen coordinates)
  Rect getWorldBounds() {
    final topLeft = gridToScreen(0, 0);
    final topRight = gridToScreen(gridWidth - 1, 0);
    final bottomLeft = gridToScreen(0, gridHeight - 1);
    final bottomRight = gridToScreen(gridWidth - 1, gridHeight - 1);

    final minX = math.min(topLeft.x, bottomLeft.x);
    final maxX = math.max(topRight.x, bottomRight.x);
    final minY = math.min(topLeft.y, topRight.y);
    final maxY = math.max(bottomLeft.y, bottomRight.y);

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

/// Spatial culling manager for performance optimization
/// Only renders tiles visible in the camera viewport
class GridCullingManager {
  final GridConfig config;

  GridCullingManager(this.config);

  /// Calculate visible grid range based on camera viewport
  /// Returns (minX, minY, maxX, maxY) for grid coordinates
  VisibleGridRange calculateVisibleRange(Rect cameraViewport) {
    // Add padding to ensure tiles at edges are rendered
    const padding = 2.0;
    final expandedViewport = cameraViewport.inflate(
      config.tileWidth * padding,
    );

    // Convert viewport corners to grid coordinates
    final topLeft = config.screenToGrid(
      expandedViewport.left,
      expandedViewport.top,
    );
    final topRight = config.screenToGrid(
      expandedViewport.right,
      expandedViewport.top,
    );
    final bottomLeft = config.screenToGrid(
      expandedViewport.left,
      expandedViewport.bottom,
    );
    final bottomRight = config.screenToGrid(
      expandedViewport.right,
      expandedViewport.bottom,
    );

    // Find min/max grid coordinates
    final minX = math.min(
      math.min(topLeft.x, topRight.x),
      math.min(bottomLeft.x, bottomRight.x),
    ).floor().clamp(0, config.gridWidth - 1);

    final maxX = math.max(
      math.max(topLeft.x, topRight.x),
      math.max(bottomLeft.x, bottomRight.x),
    ).ceil().clamp(0, config.gridWidth - 1);

    final minY = math.min(
      math.min(topLeft.y, topRight.y),
      math.min(bottomLeft.y, bottomRight.y),
    ).floor().clamp(0, config.gridHeight - 1);

    final maxY = math.max(
      math.max(topLeft.y, topRight.y),
      math.max(bottomLeft.y, bottomRight.y),
    ).ceil().clamp(0, config.gridHeight - 1);

    return VisibleGridRange(
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
    );
  }

  /// Check if a specific grid cell is visible
  bool isCellVisible(int gridX, int gridY, VisibleGridRange range) {
    return gridX >= range.minX &&
        gridX <= range.maxX &&
        gridY >= range.minY &&
        gridY <= range.maxY;
  }
}

/// Visible grid range for culling
class VisibleGridRange {
  final int minX;
  final int maxX;
  final int minY;
  final int maxY;

  const VisibleGridRange({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  /// Total number of visible tiles
  int get tileCount => (maxX - minX + 1) * (maxY - minY + 1);

  @override
  String toString() =>
      'VisibleGridRange(x: $minX-$maxX, y: $minY-$maxY, tiles: $tileCount)';
}

/// Main grid component for rendering isometric grid
/// Handles grid rendering with spatial culling for performance
class GridComponent extends Component with HasGameReference {
  final GridConfig config;
  late final GridCullingManager cullingManager;

  /// Cached tile vertices for rendering
  final Map<String, List<Offset>> _tileCache = {};

  /// Performance metrics
  int _renderedTiles = 0;
  int _totalTiles = 0;

  GridComponent({
    GridConfig? config,
  }) : config = config ?? const GridConfig() {
    cullingManager = GridCullingManager(this.config);
    _totalTiles = this.config.gridWidth * this.config.gridHeight;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildTileCache();
  }

  /// Pre-build tile diamond vertices for performance
  void _buildTileCache() {
    final halfWidth = config.tileWidth / 2;
    final halfHeight = config.tileHeight / 2;

    // Diamond shape for isometric tile
    _tileCache['diamond'] = [
      Offset(0, -halfHeight), // Top
      Offset(halfWidth, 0), // Right
      Offset(0, halfHeight), // Bottom
      Offset(-halfWidth, 0), // Left
    ];
  }

  /// Render the grid with spatial culling
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (!config.showGridLines) return;

    // Get camera viewport for culling
    final camera = game.camera;
    final viewport = camera.viewport;

    // Calculate viewport in world coordinates
    final viewportRect = Rect.fromLTWH(
      -camera.viewfinder.position.x,
      -camera.viewfinder.position.y,
      viewport.size.x / camera.viewfinder.zoom,
      viewport.size.y / camera.viewfinder.zoom,
    );

    // Calculate visible range
    final visibleRange = cullingManager.calculateVisibleRange(viewportRect);
    _renderedTiles = visibleRange.tileCount;

    // Render only visible tiles
    _renderVisibleTiles(canvas, visibleRange);
  }

  /// Render tiles within visible range
  void _renderVisibleTiles(Canvas canvas, VisibleGridRange range) {
    final primaryPaint = Paint()
      ..color = config.primaryLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final secondaryPaint = Paint()
      ..color = config.secondaryLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final diamondVertices = _tileCache['diamond']!;

    for (int y = range.minY; y <= range.maxY; y++) {
      for (int x = range.minX; x <= range.maxX; x++) {
        if (!config.isValidGridPosition(x, y)) continue;

        final screenPos = config.gridToScreen(x, y);

        // Use primary lines every 5 tiles, secondary otherwise
        final paint = (x % 5 == 0 || y % 5 == 0) ? primaryPaint : secondaryPaint;

        // Draw diamond shape
        _drawDiamond(canvas, screenPos, diamondVertices, paint);
      }
    }
  }

  /// Draw isometric diamond tile
  void _drawDiamond(
    Canvas canvas,
    Vector2 position,
    List<Offset> vertices,
    Paint paint,
  ) {
    final path = Path();
    path.moveTo(
      position.x + vertices[0].dx,
      position.y + vertices[0].dy,
    );

    for (int i = 1; i < vertices.length; i++) {
      path.lineTo(
        position.x + vertices[i].dx,
        position.y + vertices[i].dy,
      );
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  /// Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'renderedTiles': _renderedTiles,
      'totalTiles': _totalTiles,
      'cullRate': (_totalTiles - _renderedTiles) / _totalTiles,
    };
  }

  /// Convert screen point to grid coordinates
  Vector2? screenToGrid(Vector2 screenPoint) {
    final gridPos = config.screenToGrid(screenPoint.x, screenPoint.y);
    final gridX = gridPos.x.round();
    final gridY = gridPos.y.round();

    if (config.isValidGridPosition(gridX, gridY)) {
      return Vector2(gridX.toDouble(), gridY.toDouble());
    }
    return null;
  }

  /// Convert grid coordinates to screen position
  Vector2 gridToScreen(int x, int y) {
    return config.gridToScreen(x, y);
  }

  /// Check if a grid position is valid
  bool isValidPosition(int x, int y) {
    return config.isValidGridPosition(x, y);
  }

  /// Get grid dimensions
  Vector2 get gridSize => Vector2(
        config.gridWidth.toDouble(),
        config.gridHeight.toDouble(),
      );
}
