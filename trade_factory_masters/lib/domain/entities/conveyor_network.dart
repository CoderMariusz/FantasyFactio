import 'dart:math';

import 'package:equatable/equatable.dart';

import 'conveyor_tile.dart';
import 'pathfinder_node.dart';

/// Connection point for buildings (input/output ports)
class BuildingPort extends Equatable {
  /// Building ID
  final String buildingId;

  /// Port type
  final PortType type;

  /// Grid position of the port (adjacent to building)
  final Point<int> position;

  /// Direction from building to port
  final Direction direction;

  /// Filter for this port
  final ConveyorFilter filter;

  const BuildingPort({
    required this.buildingId,
    required this.type,
    required this.position,
    required this.direction,
    this.filter = const ConveyorFilter(),
  });

  @override
  List<Object?> get props => [buildingId, type, position, direction, filter];
}

/// Port type
enum PortType {
  /// Input port (receives items)
  input,

  /// Output port (sends items)
  output,
}

/// Conveyor network managing all conveyor tiles and connections
class ConveyorNetwork extends Equatable {
  /// All conveyor tiles by position (layer 1)
  final Map<Point<int>, ConveyorTile> tilesLayer1;

  /// All conveyor tiles by position (layer 2)
  final Map<Point<int>, ConveyorTile> tilesLayer2;

  /// Building input ports
  final Map<Point<int>, BuildingPort> inputPorts;

  /// Building output ports
  final Map<Point<int>, BuildingPort> outputPorts;

  /// Items dropped on ground (no destination)
  final List<ResourceStack> droppedItems;

  /// Maximum layers per tile
  static const int maxLayers = 2;

  const ConveyorNetwork({
    this.tilesLayer1 = const {},
    this.tilesLayer2 = const {},
    this.inputPorts = const {},
    this.outputPorts = const {},
    this.droppedItems = const [],
  });

  /// Get all tiles at position (both layers)
  List<ConveyorTile> getTilesAt(Point<int> position) {
    final tiles = <ConveyorTile>[];
    final l1 = tilesLayer1[position];
    final l2 = tilesLayer2[position];
    if (l1 != null) tiles.add(l1);
    if (l2 != null) tiles.add(l2);
    return tiles;
  }

  /// Get tile at position and layer
  ConveyorTile? getTile(Point<int> position, int layer) {
    return layer == 1 ? tilesLayer1[position] : tilesLayer2[position];
  }

  /// Get tile by ID
  ConveyorTile? getTileById(String id) {
    for (final tile in tilesLayer1.values) {
      if (tile.id == id) return tile;
    }
    for (final tile in tilesLayer2.values) {
      if (tile.id == id) return tile;
    }
    return null;
  }

  /// Check if position has room for another layer
  bool canAddLayer(Point<int> position) {
    return getTilesAt(position).length < maxLayers;
  }

  /// Get next available layer at position
  int getNextAvailableLayer(Point<int> position) {
    if (tilesLayer1[position] == null) return 1;
    if (tilesLayer2[position] == null) return 2;
    return -1; // No available layer
  }

  /// Add a conveyor tile to the network
  ConveyorNetwork addTile(ConveyorTile tile) {
    if (tile.layer == 1) {
      return copyWith(
        tilesLayer1: {...tilesLayer1, tile.position: tile},
      );
    } else {
      return copyWith(
        tilesLayer2: {...tilesLayer2, tile.position: tile},
      );
    }
  }

  /// Remove a conveyor tile from the network
  ConveyorNetwork removeTile(Point<int> position, int layer) {
    if (layer == 1) {
      final newTiles = Map<Point<int>, ConveyorTile>.from(tilesLayer1);
      newTiles.remove(position);
      return copyWith(tilesLayer1: newTiles);
    } else {
      final newTiles = Map<Point<int>, ConveyorTile>.from(tilesLayer2);
      newTiles.remove(position);
      return copyWith(tilesLayer2: newTiles);
    }
  }

  /// Update a tile in the network
  ConveyorNetwork updateTile(ConveyorTile tile) {
    if (tile.layer == 1) {
      return copyWith(
        tilesLayer1: {...tilesLayer1, tile.position: tile},
      );
    } else {
      return copyWith(
        tilesLayer2: {...tilesLayer2, tile.position: tile},
      );
    }
  }

  /// Register a building input port
  ConveyorNetwork addInputPort(BuildingPort port) {
    return copyWith(
      inputPorts: {...inputPorts, port.position: port},
    );
  }

  /// Register a building output port
  ConveyorNetwork addOutputPort(BuildingPort port) {
    return copyWith(
      outputPorts: {...outputPorts, port.position: port},
    );
  }

  /// Remove building ports
  ConveyorNetwork removeBuildingPorts(String buildingId) {
    final newInputs = Map<Point<int>, BuildingPort>.from(inputPorts);
    final newOutputs = Map<Point<int>, BuildingPort>.from(outputPorts);

    newInputs.removeWhere((_, port) => port.buildingId == buildingId);
    newOutputs.removeWhere((_, port) => port.buildingId == buildingId);

    return copyWith(
      inputPorts: newInputs,
      outputPorts: newOutputs,
    );
  }

  /// Get input port at position
  BuildingPort? getInputPortAt(Point<int> position) {
    return inputPorts[position];
  }

  /// Get output port at position
  BuildingPort? getOutputPortAt(Point<int> position) {
    return outputPorts[position];
  }

  /// Check if position has a building input port
  bool hasInputPort(Point<int> position) {
    return inputPorts.containsKey(position);
  }

  /// Check if position has a building output port
  bool hasOutputPort(Point<int> position) {
    return outputPorts.containsKey(position);
  }

  /// Add dropped item
  ConveyorNetwork addDroppedItem(ResourceStack item) {
    return copyWith(
      droppedItems: [...droppedItems, item],
    );
  }

  /// Clear dropped items
  ConveyorNetwork clearDroppedItems() {
    return copyWith(droppedItems: []);
  }

  /// Get total number of tiles
  int get totalTiles => tilesLayer1.length + tilesLayer2.length;

  /// Get total items in transit
  int get totalItemsInTransit {
    int count = 0;
    for (final tile in tilesLayer1.values) {
      count += tile.queue.length;
    }
    for (final tile in tilesLayer2.values) {
      count += tile.queue.length;
    }
    return count;
  }

  /// Get all tiles as flat list
  List<ConveyorTile> get allTiles => [
        ...tilesLayer1.values,
        ...tilesLayer2.values,
      ];

  /// Create a copy with updated fields
  ConveyorNetwork copyWith({
    Map<Point<int>, ConveyorTile>? tilesLayer1,
    Map<Point<int>, ConveyorTile>? tilesLayer2,
    Map<Point<int>, BuildingPort>? inputPorts,
    Map<Point<int>, BuildingPort>? outputPorts,
    List<ResourceStack>? droppedItems,
  }) {
    return ConveyorNetwork(
      tilesLayer1: tilesLayer1 ?? this.tilesLayer1,
      tilesLayer2: tilesLayer2 ?? this.tilesLayer2,
      inputPorts: inputPorts ?? this.inputPorts,
      outputPorts: outputPorts ?? this.outputPorts,
      droppedItems: droppedItems ?? this.droppedItems,
    );
  }

  @override
  List<Object?> get props => [tilesLayer1, tilesLayer2, inputPorts, outputPorts, droppedItems];
}

/// Network statistics for diagnostics
class NetworkStats extends Equatable {
  final int totalTiles;
  final int itemsInTransit;
  final int blockedTiles;
  final int droppedItems;
  final double throughputPerMinute;

  const NetworkStats({
    required this.totalTiles,
    required this.itemsInTransit,
    required this.blockedTiles,
    required this.droppedItems,
    required this.throughputPerMinute,
  });

  @override
  List<Object?> get props => [
        totalTiles,
        itemsInTransit,
        blockedTiles,
        droppedItems,
        throughputPerMinute,
      ];
}
