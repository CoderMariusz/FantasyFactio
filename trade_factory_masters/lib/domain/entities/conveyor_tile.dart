import 'dart:math';

import 'package:equatable/equatable.dart';

import 'pathfinder_node.dart';

/// Item stack being transported on conveyor
class ResourceStack extends Equatable {
  /// Resource type ID
  final String resourceId;

  /// Quantity in stack
  final int quantity;

  /// Timestamp when item entered this tile
  final DateTime enteredAt;

  const ResourceStack({
    required this.resourceId,
    required this.quantity,
    required this.enteredAt,
  });

  /// Create a single-item stack
  factory ResourceStack.single(String resourceId) {
    return ResourceStack(
      resourceId: resourceId,
      quantity: 1,
      enteredAt: DateTime.now(),
    );
  }

  /// Time spent on current tile in milliseconds
  int getTimeOnTile(DateTime now) {
    return now.difference(enteredAt).inMilliseconds;
  }

  /// Create copy with new entry time
  ResourceStack resetEntryTime() {
    return ResourceStack(
      resourceId: resourceId,
      quantity: quantity,
      enteredAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [resourceId, quantity, enteredAt];

  @override
  String toString() => 'ResourceStack($resourceId x$quantity)';
}

/// Filter mode for conveyor tiles and storage ports
enum FilterMode {
  /// All items pass through
  allowAll,

  /// Only specified items pass (whitelist)
  whitelist,

  /// Specified items blocked (blacklist)
  blacklist,

  /// Only single item type passes
  single,
}

/// Filter configuration for conveyor or port
class ConveyorFilter extends Equatable {
  /// Filter mode
  final FilterMode mode;

  /// List of resource IDs (for whitelist/blacklist)
  final List<String> resourceIds;

  /// Single resource ID (for single mode)
  final String? singleResourceId;

  /// Maximum items allowed in whitelist/blacklist
  static const int maxListItems = 3;

  const ConveyorFilter({
    this.mode = FilterMode.allowAll,
    this.resourceIds = const [],
    this.singleResourceId,
  });

  /// Validate filter configuration
  /// Returns true if configuration is valid
  bool get isValid {
    switch (mode) {
      case FilterMode.allowAll:
        return true;
      case FilterMode.whitelist:
      case FilterMode.blacklist:
        return resourceIds.isNotEmpty && resourceIds.length <= maxListItems;
      case FilterMode.single:
        return singleResourceId != null && singleResourceId!.isNotEmpty;
    }
  }

  /// Default filter that allows all
  static const allowAll = ConveyorFilter();

  /// Check if item can pass through filter
  bool canPass(String resourceId) {
    switch (mode) {
      case FilterMode.allowAll:
        return true;
      case FilterMode.whitelist:
        return resourceIds.contains(resourceId);
      case FilterMode.blacklist:
        return !resourceIds.contains(resourceId);
      case FilterMode.single:
        return resourceId == singleResourceId;
    }
  }

  /// Create whitelist filter
  factory ConveyorFilter.whitelist(List<String> resourceIds) {
    return ConveyorFilter(
      mode: FilterMode.whitelist,
      resourceIds: resourceIds,
    );
  }

  /// Create blacklist filter
  factory ConveyorFilter.blacklist(List<String> resourceIds) {
    return ConveyorFilter(
      mode: FilterMode.blacklist,
      resourceIds: resourceIds,
    );
  }

  /// Create single-item filter
  factory ConveyorFilter.single(String resourceId) {
    return ConveyorFilter(
      mode: FilterMode.single,
      singleResourceId: resourceId,
    );
  }

  @override
  List<Object?> get props => [mode, resourceIds, singleResourceId];
}

/// Splitter distribution mode
enum SplitterMode {
  /// Distribute items in rotation
  roundRobin,

  /// Try outputs in priority order
  priority,

  /// Balance items across outputs
  equal,
}

/// Splitter configuration for conveyor tiles
class SplitterConfig extends Equatable {
  /// Output directions (2-3)
  final List<Direction> outputs;

  /// Distribution mode
  final SplitterMode mode;

  /// Current output index (for round-robin)
  final int currentIndex;

  /// Item counts per output (for equal mode)
  final Map<Direction, int> outputCounts;

  const SplitterConfig({
    required this.outputs,
    this.mode = SplitterMode.roundRobin,
    this.currentIndex = 0,
    this.outputCounts = const {},
  });

  /// Get next output direction
  /// Returns null if all outputs are blocked
  Direction? getNextOutput(Set<Direction> blockedOutputs) {
    switch (mode) {
      case SplitterMode.roundRobin:
        // Try each output starting from currentIndex
        for (int i = 0; i < outputs.length; i++) {
          final idx = (currentIndex + i) % outputs.length;
          if (!blockedOutputs.contains(outputs[idx])) {
            return outputs[idx];
          }
        }
        return null;

      case SplitterMode.priority:
        // Try outputs in order
        for (final output in outputs) {
          if (!blockedOutputs.contains(output)) {
            return output;
          }
        }
        return null;

      case SplitterMode.equal:
        // Find output with lowest count
        Direction? best;
        int bestCount = 0x7FFFFFFF;
        for (final output in outputs) {
          if (blockedOutputs.contains(output)) continue;
          final count = outputCounts[output] ?? 0;
          if (count < bestCount) {
            bestCount = count;
            best = output;
          }
        }
        return best;
    }
  }

  /// Create updated config after sending item to direction
  SplitterConfig afterSend(Direction direction) {
    final newIndex = mode == SplitterMode.roundRobin
        ? (outputs.indexOf(direction) + 1) % outputs.length
        : currentIndex;

    final newCounts = Map<Direction, int>.from(outputCounts);
    newCounts[direction] = (newCounts[direction] ?? 0) + 1;

    return SplitterConfig(
      outputs: outputs,
      mode: mode,
      currentIndex: newIndex,
      outputCounts: newCounts,
    );
  }

  @override
  List<Object?> get props => [outputs, mode, currentIndex, outputCounts];
}

/// Single conveyor tile that transports items
class ConveyorTile extends Equatable {
  /// Unique ID for this tile
  final String id;

  /// Grid position
  final Point<int> position;

  /// Direction items flow
  final Direction direction;

  /// Layer (1 = under buildings, 2 = over buildings)
  final int layer;

  /// Items currently on this tile (max 10)
  final List<ResourceStack> queue;

  /// Filter configuration
  final ConveyorFilter filter;

  /// Splitter configuration (if this tile splits)
  final SplitterConfig? splitter;

  /// Whether this tile is active
  final bool isActive;

  /// Maximum items per tile
  static const int maxQueueSize = 10;

  /// Transport rate: 1 item per 2 seconds (0.5 items/sec)
  static const int transportIntervalMs = 2000;

  const ConveyorTile({
    required this.id,
    required this.position,
    required this.direction,
    this.layer = 1,
    this.queue = const [],
    this.filter = const ConveyorFilter(),
    this.splitter,
    this.isActive = true,
  });

  /// Check if queue is full
  bool get isFull => queue.length >= maxQueueSize;

  /// Check if queue is empty
  bool get isEmpty => queue.isEmpty;

  /// Get next position based on direction (or splitter)
  Point<int> getNextPosition([Direction? overrideDirection]) {
    final dir = overrideDirection ?? direction;
    return Point(
      position.x + dir.delta.x,
      position.y + dir.delta.y,
    );
  }

  /// Check if item can be accepted (not full, passes filter)
  bool canAccept(String resourceId) {
    if (!isActive) return false;
    if (isFull) return false;
    return filter.canPass(resourceId);
  }

  /// Add item to queue
  ConveyorTile addItem(ResourceStack item) {
    if (isFull) return this;
    return copyWith(queue: [...queue, item.resetEntryTime()]);
  }

  /// Remove first item from queue
  ConveyorTile removeFirstItem() {
    if (isEmpty) return this;
    return copyWith(queue: queue.skip(1).toList());
  }

  /// Get first item ready to move (waited at least transportIntervalMs)
  ResourceStack? getReadyItem(DateTime now) {
    if (isEmpty) return null;
    final first = queue.first;
    if (first.getTimeOnTile(now) >= transportIntervalMs) {
      return first;
    }
    return null;
  }

  /// Create a copy with updated fields
  ConveyorTile copyWith({
    String? id,
    Point<int>? position,
    Direction? direction,
    int? layer,
    List<ResourceStack>? queue,
    ConveyorFilter? filter,
    SplitterConfig? splitter,
    bool? isActive,
  }) {
    return ConveyorTile(
      id: id ?? this.id,
      position: position ?? this.position,
      direction: direction ?? this.direction,
      layer: layer ?? this.layer,
      queue: queue ?? this.queue,
      filter: filter ?? this.filter,
      splitter: splitter ?? this.splitter,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, position, direction, layer, queue, filter, splitter, isActive];

  @override
  String toString() =>
      'ConveyorTile($id at ${position.x},${position.y} → $direction, ${queue.length} items)';
}

/// Status of item transport attempt
enum TransportStatus {
  /// Item moved successfully
  success,

  /// Destination tile is full (backpressure)
  blocked,

  /// Item filtered out
  filtered,

  /// No destination (item dropped)
  dropped,

  /// Item not ready to move yet
  waiting,
}

/// Result of transport operation for single item
class TransportResult extends Equatable {
  final TransportStatus status;
  final ResourceStack? item;
  final Point<int>? destination;
  final String? message;

  const TransportResult({
    required this.status,
    this.item,
    this.destination,
    this.message,
  });

  factory TransportResult.success(ResourceStack item, Point<int> destination) {
    return TransportResult(
      status: TransportStatus.success,
      item: item,
      destination: destination,
    );
  }

  factory TransportResult.blocked(ResourceStack item) {
    return TransportResult(
      status: TransportStatus.blocked,
      item: item,
      message: 'Destination full',
    );
  }

  factory TransportResult.filtered(ResourceStack item) {
    return TransportResult(
      status: TransportStatus.filtered,
      item: item,
      message: 'Item filtered',
    );
  }

  factory TransportResult.dropped(ResourceStack item) {
    return TransportResult(
      status: TransportStatus.dropped,
      item: item,
      message: 'No destination',
    );
  }

  factory TransportResult.waiting() {
    return const TransportResult(
      status: TransportStatus.waiting,
      message: 'Item not ready',
    );
  }

  @override
  List<Object?> get props => [status, item, destination, message];
}
