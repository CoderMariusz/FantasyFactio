import 'dart:math';

import '../entities/conveyor_tile.dart';
import '../entities/conveyor_network.dart';
import '../entities/pathfinder_node.dart';

/// Result of a network tick (transport cycle)
class TransportTickResult {
  /// Updated network after tick
  final ConveyorNetwork network;

  /// Number of items moved
  final int itemsMoved;

  /// Number of items blocked (backpressure)
  final int itemsBlocked;

  /// Number of items dropped (no destination)
  final int itemsDropped;

  /// Items delivered to building input ports
  final Map<String, List<ResourceStack>> deliveredToBuildings;

  /// Transport results for debugging
  final List<TransportResult> results;

  const TransportTickResult({
    required this.network,
    required this.itemsMoved,
    required this.itemsBlocked,
    required this.itemsDropped,
    required this.deliveredToBuildings,
    required this.results,
  });
}

/// Use case for transporting items through conveyor network
class TransportItemsUseCase {
  const TransportItemsUseCase();

  /// Execute one transport cycle (tick)
  ///
  /// Should be called every [ConveyorTile.transportIntervalMs] milliseconds
  /// or more frequently for smooth animations
  TransportTickResult tick({
    required ConveyorNetwork network,
    required DateTime now,
  }) {
    var updatedNetwork = network;
    final results = <TransportResult>[];
    final deliveries = <String, List<ResourceStack>>{};
    int moved = 0;
    int blocked = 0;
    int dropped = 0;

    // Process all tiles in both layers
    final allTiles = [...network.tilesLayer1.values, ...network.tilesLayer2.values];

    for (final tile in allTiles) {
      if (!tile.isActive || tile.isEmpty) continue;

      // Check if first item is ready to move
      final item = tile.getReadyItem(now);
      if (item == null) {
        results.add(TransportResult.waiting());
        continue;
      }

      // Try to move the item
      final result = _tryMoveItem(
        tile: tile,
        item: item,
        network: updatedNetwork,
      );

      results.add(result);

      switch (result.status) {
        case TransportStatus.success:
          moved++;
          // Remove from source tile and update splitter state if applicable
          var sourceTile = tile.removeFirstItem();
          if (tile.splitter != null && result.destination != null) {
            // Update splitter state after successful send
            final sentDirection = _getDirectionToPosition(tile.position, result.destination!);
            if (sentDirection != null) {
              final updatedSplitter = tile.splitter!.afterSend(sentDirection);
              sourceTile = sourceTile.copyWith(splitter: updatedSplitter);
            }
          }
          updatedNetwork = updatedNetwork.updateTile(sourceTile);

          // Add to destination (tile or building)
          if (result.destination != null) {
            final destTile = _getDestinationTile(updatedNetwork, result.destination!, tile.layer);
            if (destTile != null) {
              final updatedDest = destTile.addItem(item);
              updatedNetwork = updatedNetwork.updateTile(updatedDest);
            } else if (updatedNetwork.hasInputPort(result.destination!)) {
              // Delivered to building
              final port = updatedNetwork.getInputPortAt(result.destination!);
              if (port != null) {
                deliveries.putIfAbsent(port.buildingId, () => []);
                deliveries[port.buildingId]!.add(item);
              }
            }
          }
          break;

        case TransportStatus.blocked:
          blocked++;
          // Item stays in source queue
          break;

        case TransportStatus.filtered:
          blocked++;
          // Item stays in source queue
          break;

        case TransportStatus.dropped:
          dropped++;
          // Remove from source and add to dropped items
          final sourceTile = tile.removeFirstItem();
          updatedNetwork = updatedNetwork.updateTile(sourceTile);
          updatedNetwork = updatedNetwork.addDroppedItem(item);
          break;

        case TransportStatus.waiting:
          // Item not ready yet
          break;
      }
    }

    return TransportTickResult(
      network: updatedNetwork,
      itemsMoved: moved,
      itemsBlocked: blocked,
      itemsDropped: dropped,
      deliveredToBuildings: deliveries,
      results: results,
    );
  }

  /// Try to move an item from a tile
  TransportResult _tryMoveItem({
    required ConveyorTile tile,
    required ResourceStack item,
    required ConveyorNetwork network,
  }) {
    // Determine destination based on splitter or direction
    final destinations = _getDestinations(tile, network);

    if (destinations.isEmpty) {
      // For splitters, check if destinations exist but are blocked (full)
      if (tile.splitter != null) {
        // Check if any splitter output has a valid destination
        for (final dir in tile.splitter!.outputs) {
          final pos = tile.getNextPosition(dir);
          if (network.hasInputPort(pos) ||
              _getDestinationTile(network, pos, tile.layer) != null ||
              _getDestinationTile(network, pos, tile.layer == 1 ? 2 : 1) != null) {
            // Destination exists but all are blocked/full
            return TransportResult.blocked(item);
          }
        }
      }
      return TransportResult.dropped(item);
    }

    // Try each destination
    for (final dest in destinations) {
      // Check if destination is a building input port
      if (network.hasInputPort(dest.position)) {
        final port = network.getInputPortAt(dest.position)!;
        if (port.filter.canPass(item.resourceId)) {
          return TransportResult.success(item, dest.position);
        }
        continue; // Try next destination
      }

      // Check if destination is a conveyor tile
      final destTile = _getDestinationTile(network, dest.position, tile.layer);
      if (destTile != null) {
        if (!destTile.canAccept(item.resourceId)) {
          if (destTile.isFull) {
            // Try next destination or report blocked
            continue;
          } else {
            // Filtered
            return TransportResult.filtered(item);
          }
        }
        return TransportResult.success(item, dest.position);
      }

      // Try other layer at same position
      final otherLayer = tile.layer == 1 ? 2 : 1;
      final otherLayerTile = _getDestinationTile(network, dest.position, otherLayer);
      if (otherLayerTile != null && otherLayerTile.canAccept(item.resourceId)) {
        return TransportResult.success(item, dest.position);
      }
    }

    // Check if there was any valid destination at all
    // If loop completed without finding anything, check why
    bool hadValidDestination = false;
    for (final dest in destinations) {
      if (network.hasInputPort(dest.position) ||
          _getDestinationTile(network, dest.position, tile.layer) != null ||
          _getDestinationTile(network, dest.position, tile.layer == 1 ? 2 : 1) != null) {
        hadValidDestination = true;
        break;
      }
    }

    if (hadValidDestination) {
      // There was a destination but it was full or filtered
      return TransportResult.blocked(item);
    }

    // No valid destination exists at all
    return TransportResult.dropped(item);
  }

  /// Get possible destinations for a tile
  List<_Destination> _getDestinations(ConveyorTile tile, ConveyorNetwork network) {
    final destinations = <_Destination>[];

    if (tile.splitter != null) {
      // Splitter: try multiple outputs
      final blockedOutputs = <Direction>{};

      // Check which outputs are blocked
      for (final dir in tile.splitter!.outputs) {
        final pos = tile.getNextPosition(dir);
        if (!_canReachDestination(network, pos, tile.layer)) {
          blockedOutputs.add(dir);
        }
      }

      // Get next output from splitter
      final nextDir = tile.splitter!.getNextOutput(blockedOutputs);
      if (nextDir != null) {
        destinations.add(_Destination(
          position: tile.getNextPosition(nextDir),
          direction: nextDir,
        ));
      }
    } else {
      // Normal conveyor: single direction
      final nextPos = tile.getNextPosition();
      destinations.add(_Destination(
        position: nextPos,
        direction: tile.direction,
      ));
    }

    return destinations;
  }

  /// Check if destination can potentially receive items
  bool _canReachDestination(ConveyorNetwork network, Point<int> position, int preferredLayer) {
    // Check for building input port
    if (network.hasInputPort(position)) return true;

    // Check for conveyor tile on preferred layer
    final tile = network.getTile(position, preferredLayer);
    if (tile != null && !tile.isFull) return true;

    // Check for conveyor tile on other layer
    final otherLayer = preferredLayer == 1 ? 2 : 1;
    final otherTile = network.getTile(position, otherLayer);
    if (otherTile != null && !otherTile.isFull) return true;

    return false;
  }

  /// Get destination tile (preferring same layer)
  ConveyorTile? _getDestinationTile(ConveyorNetwork network, Point<int> position, int preferredLayer) {
    // Try preferred layer first
    var tile = network.getTile(position, preferredLayer);
    if (tile != null) return tile;

    // Try other layer
    final otherLayer = preferredLayer == 1 ? 2 : 1;
    return network.getTile(position, otherLayer);
  }

  /// Get direction from source position to destination position
  Direction? _getDirectionToPosition(Point<int> from, Point<int> to) {
    final dx = to.x - from.x;
    final dy = to.y - from.y;

    if (dx == 1 && dy == 0) return Direction.east;
    if (dx == -1 && dy == 0) return Direction.west;
    if (dx == 0 && dy == 1) return Direction.south;
    if (dx == 0 && dy == -1) return Direction.north;

    return null;
  }

  /// Inject items from building output to connected conveyor
  ConveyorNetwork injectFromBuilding({
    required ConveyorNetwork network,
    required String buildingId,
    required List<ResourceStack> items,
  }) {
    var updatedNetwork = network;

    // Find output ports for this building
    final ports = network.outputPorts.values
        .where((port) => port.buildingId == buildingId)
        .toList();

    if (ports.isEmpty) return network;

    for (final item in items) {
      // Try each output port
      bool injected = false;

      for (final port in ports) {
        if (!port.filter.canPass(item.resourceId)) continue;

        // Find conveyor tile connected to this port
        final tiles = network.getTilesAt(port.position);
        for (final tile in tiles) {
          if (tile.canAccept(item.resourceId)) {
            final updatedTile = tile.addItem(item);
            updatedNetwork = updatedNetwork.updateTile(updatedTile);
            injected = true;
            break;
          }
        }

        if (injected) break;
      }

      if (!injected) {
        // No available port, item dropped
        updatedNetwork = updatedNetwork.addDroppedItem(item);
      }
    }

    return updatedNetwork;
  }

  /// Create conveyor path from pathfinding result
  ConveyorNetwork createConveyorPath({
    required ConveyorNetwork network,
    required List<Point<int>> path,
    int layer = 1,
    String? idPrefix,
  }) {
    if (path.length < 2) return network;

    var updatedNetwork = network;
    final prefix = idPrefix ?? 'conveyor_${DateTime.now().millisecondsSinceEpoch}';

    for (int i = 0; i < path.length - 1; i++) {
      final current = path[i];
      final next = path[i + 1];

      // Determine direction to next tile
      final direction = Direction.fromPoints(current, next);
      if (direction == null) continue;

      // Determine layer
      final actualLayer = network.canAddLayer(current)
          ? network.getNextAvailableLayer(current)
          : -1;

      if (actualLayer == -1) continue; // Skip if no layer available

      final tile = ConveyorTile(
        id: '${prefix}_$i',
        position: current,
        direction: direction,
        layer: actualLayer,
      );

      updatedNetwork = updatedNetwork.addTile(tile);
    }

    return updatedNetwork;
  }
}

/// Internal class for destination info
class _Destination {
  final Point<int> position;
  final Direction direction;

  const _Destination({
    required this.position,
    required this.direction,
  });
}
