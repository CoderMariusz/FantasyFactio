import 'package:equatable/equatable.dart';

/// Types of biomes available in the game
/// Each biom produces different resources when a mining facility is placed
enum BiomType {
  /// Mine biom - produces coal, iron ore, copper ore
  koppalnia,

  /// Forest biom - produces wood
  las,

  /// Mountains biom - produces stone, iron ore
  gory,

  /// Lake biom - produces salt, clay
  jezioro,

  /// Plains biom - general purpose, no special resources
  rownina,
}

/// Extension to get biom properties
extension BiomTypeExtension on BiomType {
  /// Get display name in Polish
  String get displayName {
    switch (this) {
      case BiomType.koppalnia:
        return 'Kopalnia';
      case BiomType.las:
        return 'Las';
      case BiomType.gory:
        return 'Góry';
      case BiomType.jezioro:
        return 'Jezioro';
      case BiomType.rownina:
        return 'Równina';
    }
  }

  /// Get biom identifier string for placement rules
  String get id {
    switch (this) {
      case BiomType.koppalnia:
        return 'koppalnia';
      case BiomType.las:
        return 'las';
      case BiomType.gory:
        return 'gory';
      case BiomType.jezioro:
        return 'jezioro';
      case BiomType.rownina:
        return 'rownina';
    }
  }

  /// Get resources produced by this biom
  List<String> get producesResources {
    switch (this) {
      case BiomType.koppalnia:
        return ['Coal', 'Iron Ore', 'Copper Ore'];
      case BiomType.las:
        return ['Wood'];
      case BiomType.gory:
        return ['Stone', 'Iron Ore'];
      case BiomType.jezioro:
        return ['Salt', 'Clay'];
      case BiomType.rownina:
        return [];
    }
  }

  /// Get gathering speed multiplier for this biom
  double get gatherSpeedMultiplier {
    switch (this) {
      case BiomType.koppalnia:
        return 1.0;
      case BiomType.las:
        return 1.2; // Faster wood gathering
      case BiomType.gory:
        return 0.8; // Slower due to terrain
      case BiomType.jezioro:
        return 0.9;
      case BiomType.rownina:
        return 1.0;
    }
  }
}

/// Represents a single tile on the game grid
class Tile extends Equatable {
  /// Grid X coordinate
  final int x;

  /// Grid Y coordinate
  final int y;

  /// Biom type of this tile
  final BiomType biom;

  /// ID of building placed on this tile (null if empty)
  final String? buildingId;

  /// Number of layers on this tile (for conveyor stacking)
  final int layers;

  const Tile({
    required this.x,
    required this.y,
    required this.biom,
    this.buildingId,
    this.layers = 0,
  });

  /// Check if tile is occupied by a building
  bool get isOccupied => buildingId != null;

  /// Check if this tile can accept another layer
  bool canAddLayer(int maxLayers) => layers < maxLayers;

  /// Create copy with building placed
  Tile withBuilding(String id) => Tile(
        x: x,
        y: y,
        biom: biom,
        buildingId: id,
        layers: 1,
      );

  /// Create copy with additional layer
  Tile withLayer() => Tile(
        x: x,
        y: y,
        biom: biom,
        buildingId: buildingId,
        layers: layers + 1,
      );

  /// Create copy with building removed
  Tile withoutBuilding() => Tile(
        x: x,
        y: y,
        biom: biom,
        buildingId: null,
        layers: 0,
      );

  @override
  List<Object?> get props => [x, y, biom, buildingId, layers];
}

/// Represents the entire game grid
class GameGrid extends Equatable {
  /// Grid width in tiles
  final int width;

  /// Grid height in tiles
  final int height;

  /// All tiles indexed by position
  final Map<String, Tile> _tiles;

  GameGrid({
    required this.width,
    required this.height,
    Map<String, Tile>? tiles,
  }) : _tiles = tiles ?? {};

  /// Get tile at position
  Tile? getTile(int x, int y) => _tiles[_key(x, y)];

  /// Get all tiles
  Iterable<Tile> get allTiles => _tiles.values;

  /// Check if position is valid
  bool isValidPosition(int x, int y) =>
      x >= 0 && x < width && y >= 0 && y < height;

  /// Set tile at position
  GameGrid setTile(Tile tile) {
    final newTiles = Map<String, Tile>.from(_tiles);
    newTiles[_key(tile.x, tile.y)] = tile;
    return GameGrid(width: width, height: height, tiles: newTiles);
  }

  /// Place building at position
  GameGrid placeBuilding(int x, int y, String buildingId) {
    final tile = getTile(x, y);
    if (tile == null) return this;
    return setTile(tile.withBuilding(buildingId));
  }

  /// Remove building at position
  GameGrid removeBuilding(int x, int y) {
    final tile = getTile(x, y);
    if (tile == null) return this;
    return setTile(tile.withoutBuilding());
  }

  /// Generate key for tile lookup
  static String _key(int x, int y) => '$x,$y';

  /// Initialize grid with random bioms
  static GameGrid generate({
    required int width,
    required int height,
    int? seed,
  }) {
    final random = seed != null
        ? _SeededRandom(seed)
        : _SeededRandom(DateTime.now().millisecondsSinceEpoch);

    final tiles = <String, Tile>{};

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final biom = _generateBiom(x, y, width, height, random);
        tiles[_key(x, y)] = Tile(x: x, y: y, biom: biom);
      }
    }

    return GameGrid(width: width, height: height, tiles: tiles);
  }

  /// Generate biom based on position (clusters similar bioms)
  static BiomType _generateBiom(
    int x,
    int y,
    int width,
    int height,
    _SeededRandom random,
  ) {
    // Create biom clusters using noise-like pattern
    final noiseX = (x / 10).floor();
    final noiseY = (y / 10).floor();
    final clusterSeed = noiseX * 100 + noiseY;

    // Deterministic biom based on cluster
    final bioms = BiomType.values;
    final index = (clusterSeed + random.nextInt(bioms.length)) % bioms.length;
    return bioms[index];
  }

  @override
  List<Object?> get props => [width, height, _tiles];
}

/// Simple seeded random for deterministic generation
class _SeededRandom {
  int _seed;

  _SeededRandom(this._seed);

  int nextInt(int max) {
    _seed = (_seed * 1103515245 + 12345) & 0x7FFFFFFF;
    return _seed % max;
  }
}
