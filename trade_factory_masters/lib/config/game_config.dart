/// Game configuration constants for Trade Factory Masters
/// Centralized configuration to avoid hardcoded values throughout the codebase
library;

/// Grid configuration constants
class GridConstants {
  /// Default grid width in tiles
  static const int gridWidth = 50;

  /// Default grid height in tiles
  static const int gridHeight = 50;

  /// Tile width in pixels (for isometric projection)
  static const double tileWidth = 64.0;

  /// Tile height in pixels (for isometric projection)
  static const double tileHeight = 32.0;

  /// Whether to show grid lines by default
  static const bool showGridLines = true;

  GridConstants._(); // Prevent instantiation
}

/// Camera configuration constants
class CameraConstants {
  /// Minimum zoom level (zoomed out)
  static const double minZoom = 0.3;

  /// Maximum zoom level (zoomed in)
  static const double maxZoom = 2.0;

  /// Zoom transition duration in seconds
  static const double zoomTransitionDuration = 0.3;

  /// Pan speed multiplier
  static const double panSpeed = 1.0;

  /// Padding around world bounds (prevents edge tiles from being cut off)
  static const double boundsPadding = 300.0;

  CameraConstants._(); // Prevent instantiation
}

/// Player economy starting values
class EconomyConstants {
  /// Starting gold for new players
  static const int startingGold = 1000;

  /// Starting tier for new players
  static const int startingTier = 1;

  /// Default resource max capacity
  static const int defaultMaxCapacity = 1000;

  EconomyConstants._(); // Prevent instantiation
}

/// Building configuration constants
class BuildingConstants {
  /// Building size multiplier relative to tile width
  static const double widthMultiplier = 0.8;

  /// Building height multiplier relative to tile height
  static const double heightMultiplier = 1.5;

  /// Level scale increment (percentage per level)
  static const double levelScaleIncrement = 0.01;

  BuildingConstants._(); // Prevent instantiation
}

/// UI and display constants
class DisplayConstants {
  /// FPS counter position X
  static const double fpsCounterX = 10.0;

  /// FPS counter position Y
  static const double fpsCounterY = 10.0;

  /// Camera info display position X
  static const double cameraInfoX = 10.0;

  /// Camera info display position Y
  static const double cameraInfoY = 40.0;

  DisplayConstants._(); // Prevent instantiation
}
