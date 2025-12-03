import 'package:equatable/equatable.dart';

import '../entities/conveyor_tile.dart';
import '../entities/conveyor_network.dart';

/// Result of filter evaluation
class FilterEvaluationResult extends Equatable {
  /// Whether item passes all filters
  final bool passes;

  /// Which filter blocked the item (if any)
  final FilterBlockReason? blockedBy;

  /// Description of why item was blocked
  final String? blockReason;

  const FilterEvaluationResult({
    required this.passes,
    this.blockedBy,
    this.blockReason,
  });

  /// Item passed all filters
  factory FilterEvaluationResult.passed() {
    return const FilterEvaluationResult(passes: true);
  }

  /// Item blocked by conveyor tile filter
  factory FilterEvaluationResult.blockedByTile(String reason) {
    return FilterEvaluationResult(
      passes: false,
      blockedBy: FilterBlockReason.tileFilter,
      blockReason: reason,
    );
  }

  /// Item blocked by port filter
  factory FilterEvaluationResult.blockedByPort(String reason) {
    return FilterEvaluationResult(
      passes: false,
      blockedBy: FilterBlockReason.portFilter,
      blockReason: reason,
    );
  }

  /// Item blocked by global storage filter
  factory FilterEvaluationResult.blockedByGlobal(String reason) {
    return FilterEvaluationResult(
      passes: false,
      blockedBy: FilterBlockReason.globalFilter,
      blockReason: reason,
    );
  }

  @override
  List<Object?> get props => [passes, blockedBy, blockReason];
}

/// Reason why item was blocked
enum FilterBlockReason {
  /// Blocked by conveyor tile filter
  tileFilter,

  /// Blocked by destination port filter
  portFilter,

  /// Blocked by storage global filter
  globalFilter,
}

/// Storage filter configuration for buildings
/// Supports global filter and per-port filters
class StorageFilterConfig extends Equatable {
  /// Global filter applied to all ports
  final ConveyorFilter globalFilter;

  /// Per-port filters (key: port name like 'input', 'output_n', etc.)
  final Map<String, ConveyorFilter> portFilters;

  const StorageFilterConfig({
    this.globalFilter = const ConveyorFilter(),
    this.portFilters = const {},
  });

  /// Get effective filter for a port
  /// Port filter takes priority, falls back to global
  ConveyorFilter getFilterForPort(String portName) {
    return portFilters[portName] ?? globalFilter;
  }

  /// Check if item can pass through specific port
  /// Port filter overrides global filter if present
  /// If no port filter, global filter applies
  bool canPassPort(String resourceId, String portName) {
    // If port has specific filter, use it (overrides global)
    final portFilter = portFilters[portName];
    if (portFilter != null) {
      return portFilter.canPass(resourceId);
    }

    // Otherwise use global filter
    return globalFilter.canPass(resourceId);
  }

  /// Create copy with updated fields
  StorageFilterConfig copyWith({
    ConveyorFilter? globalFilter,
    Map<String, ConveyorFilter>? portFilters,
  }) {
    return StorageFilterConfig(
      globalFilter: globalFilter ?? this.globalFilter,
      portFilters: portFilters ?? this.portFilters,
    );
  }

  @override
  List<Object?> get props => [globalFilter, portFilters];
}

/// Use case for applying and evaluating filters
class ApplyFilterUseCase {
  const ApplyFilterUseCase();

  /// Check if item can pass through a conveyor tile
  bool canPassTile(String resourceId, ConveyorTile tile) {
    return tile.filter.canPass(resourceId);
  }

  /// Check if item can pass through a building port
  bool canPassPort(String resourceId, BuildingPort port) {
    return port.filter.canPass(resourceId);
  }

  /// Check if item can pass through storage with global + port filter
  bool canPassStorage({
    required String resourceId,
    required StorageFilterConfig storageConfig,
    required String portName,
  }) {
    return storageConfig.canPassPort(resourceId, portName);
  }

  /// Evaluate complete filter chain: tile → port → global
  /// Used when moving item from conveyor to building
  FilterEvaluationResult evaluateFilterChain({
    required String resourceId,
    ConveyorTile? sourceTile,
    BuildingPort? destinationPort,
    StorageFilterConfig? storageConfig,
  }) {
    // Step 1: Check source tile filter (if provided)
    if (sourceTile != null && !sourceTile.filter.canPass(resourceId)) {
      return FilterEvaluationResult.blockedByTile(
        'Item $resourceId blocked by conveyor tile filter (${sourceTile.filter.mode})',
      );
    }

    // Step 2: Check destination port filter (if provided)
    if (destinationPort != null && !destinationPort.filter.canPass(resourceId)) {
      return FilterEvaluationResult.blockedByPort(
        'Item $resourceId blocked by port filter (${destinationPort.filter.mode})',
      );
    }

    // Step 3: Check storage filter config (if provided)
    // Port filter overrides global filter (same logic as canPassPort)
    if (storageConfig != null) {
      // Get port name from destination port if available
      final portName = destinationPort != null
          ? _getPortName(destinationPort)
          : 'input';

      // Check port-specific filter first (overrides global)
      final portFilter = storageConfig.portFilters[portName];
      if (portFilter != null) {
        if (!portFilter.canPass(resourceId)) {
          return FilterEvaluationResult.blockedByPort(
            'Item $resourceId blocked by storage port filter for $portName',
          );
        }
        // Port filter passed, skip global filter (override behavior)
      } else {
        // No port filter, check global filter
        if (!storageConfig.globalFilter.canPass(resourceId)) {
          return FilterEvaluationResult.blockedByGlobal(
            'Item $resourceId blocked by storage global filter',
          );
        }
      }
    }

    return FilterEvaluationResult.passed();
  }

  /// Get port name from BuildingPort direction
  String _getPortName(BuildingPort port) {
    if (port.type == PortType.input) {
      return 'input';
    }
    return 'output_${port.direction.name}';
  }

  /// Create a whitelist filter with validation
  /// Returns null if more than 3 items provided
  ConveyorFilter? createWhitelistFilter(List<String> resourceIds) {
    if (resourceIds.isEmpty || resourceIds.length > ConveyorFilter.maxListItems) {
      return null;
    }
    return ConveyorFilter.whitelist(resourceIds);
  }

  /// Create a blacklist filter with validation
  /// Returns null if more than 3 items provided
  ConveyorFilter? createBlacklistFilter(List<String> resourceIds) {
    if (resourceIds.isEmpty || resourceIds.length > ConveyorFilter.maxListItems) {
      return null;
    }
    return ConveyorFilter.blacklist(resourceIds);
  }

  /// Create a single-item filter
  ConveyorFilter createSingleFilter(String resourceId) {
    return ConveyorFilter.single(resourceId);
  }

  /// Get filter statistics for debugging
  FilterStats getFilterStats(ConveyorNetwork network) {
    int allowAllCount = 0;
    int whitelistCount = 0;
    int blacklistCount = 0;
    int singleCount = 0;

    for (final tile in network.allTiles) {
      switch (tile.filter.mode) {
        case FilterMode.allowAll:
          allowAllCount++;
          break;
        case FilterMode.whitelist:
          whitelistCount++;
          break;
        case FilterMode.blacklist:
          blacklistCount++;
          break;
        case FilterMode.single:
          singleCount++;
          break;
      }
    }

    return FilterStats(
      totalTiles: network.totalTiles,
      allowAllCount: allowAllCount,
      whitelistCount: whitelistCount,
      blacklistCount: blacklistCount,
      singleCount: singleCount,
    );
  }
}

/// Statistics about filter usage in network
class FilterStats extends Equatable {
  final int totalTiles;
  final int allowAllCount;
  final int whitelistCount;
  final int blacklistCount;
  final int singleCount;

  const FilterStats({
    required this.totalTiles,
    required this.allowAllCount,
    required this.whitelistCount,
    required this.blacklistCount,
    required this.singleCount,
  });

  /// Tiles with active filtering (not allowAll)
  int get filteredTiles => whitelistCount + blacklistCount + singleCount;

  /// Percentage of tiles with active filtering
  double get filteredPercentage =>
      totalTiles > 0 ? filteredTiles / totalTiles * 100 : 0;

  @override
  List<Object?> get props => [
        totalTiles,
        allowAllCount,
        whitelistCount,
        blacklistCount,
        singleCount,
      ];
}
