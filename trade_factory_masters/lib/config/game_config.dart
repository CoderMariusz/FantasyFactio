/// Game configuration constants for Trade Factory Masters
/// Centralized configuration to avoid hardcoded values throughout the codebase
library;

/// Grid configuration constants
class GridConstants {
  /// Default grid width in tiles
  static const int gridWidth = 50;

  /// Default grid height in tiles
  static const int gridHeight = 50;

  /// Tile size in pixels (square tiles for top-down view)
  static const double tileSize = 32.0;

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
  /// Building size multiplier relative to tile size (square buildings)
  static const double sizeMultiplier = 0.9;

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

/// Resource type identifiers
/// Use these instead of magic strings for resource types
class ResourceIds {
  // Raw resources
  static const String wood = 'Wood';
  static const String stone = 'Stone';
  static const String ironOre = 'Iron Ore';
  static const String coal = 'Coal';
  static const String copperOre = 'Copper Ore';
  static const String copper = 'Copper Ore'; // Alias for copperOre
  static const String cotton = 'Cotton'; // Wata
  static const String salt = 'Salt'; // Sól
  static const String clay = 'Clay'; // Glina

  // Processed resources
  static const String ironBar = 'Iron Bar';
  static const String copperBar = 'Copper Bar';
  static const String steel = 'Steel';

  // Currency
  static const String gold = 'Gold';

  // Crafted items
  static const String hammer = 'Hammer';
  static const String concrete = 'Concrete'; // Beton

  ResourceIds._(); // Prevent instantiation
}

/// Collection mechanics constants
class CollectionConstants {
  /// Minimum seconds between collections to get resources
  /// Prevents spam-tapping with no effect
  static const int minimumCollectionSeconds = 60;

  /// Storage capacity multiplier (hours of production stored)
  static const double storageHoursMultiplier = 10.0;

  CollectionConstants._(); // Prevent instantiation
}
