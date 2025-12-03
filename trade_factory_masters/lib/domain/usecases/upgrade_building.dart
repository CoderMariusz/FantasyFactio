import '../entities/player_economy.dart';
import '../entities/building.dart';
import '../core/result.dart';

/// Possible errors when upgrading a building
enum UpgradeError {
  /// Building is already at maximum level
  maxLevelReached,

  /// Player doesn't have enough gold
  insufficientGold,

  /// Building is not active
  buildingInactive,

  /// Building not found in economy
  buildingNotFound,
}

/// Use case for upgrading a building to increase production rate
/// Validates upgrade requirements and deducts gold from player's economy
class UpgradeBuildingUseCase {
  /// Execute the building upgrade
  ///
  /// Performs the following checks:
  /// 1. Building is active
  /// 2. Building is not at max level
  /// 3. Player has enough gold
  ///
  /// If all checks pass:
  /// - Deducts upgrade cost from player's gold
  /// - Increases building level by 1
  /// - Updates building in economy's building list
  ///
  /// Returns:
  /// - Success(PlayerEconomy) with updated state
  /// - Failure(UpgradeError) if any validation fails
  Result<PlayerEconomy, UpgradeError> execute({
    required PlayerEconomy economy,
    required Building building,
  }) {
    // Validate building is active
    if (!building.isActive) {
      return Result.failure(UpgradeError.buildingInactive);
    }

    // Validate building is not at max level
    if (building.level >= building.upgradeConfig.maxLevel) {
      return Result.failure(UpgradeError.maxLevelReached);
    }

    // Calculate upgrade cost
    final upgradeCost = building.calculateUpgradeCost();

    // Validate player can afford upgrade
    if (!economy.canAfford(upgradeCost)) {
      return Result.failure(UpgradeError.insufficientGold);
    }

    // Deduct gold from economy
    final economyAfterPayment = economy.deductGold(upgradeCost);

    // Upgrade building (increase level)
    final upgradedBuilding = building.copyWith(
      level: building.level + 1,
    );

    // Update building in economy's building list
    final buildingIndex = economy.buildings.indexWhere((b) => b.id == building.id);
    if (buildingIndex == -1) {
      return Result.failure(UpgradeError.buildingNotFound);
    }

    final updatedBuildings = List<Building>.from(economyAfterPayment.buildings);
    updatedBuildings[buildingIndex] = upgradedBuilding;

    final finalEconomy = economyAfterPayment.copyWith(
      buildings: updatedBuildings,
    );

    return Result.success(finalEconomy);
  }
}

/// Extension to provide human-readable error messages
extension UpgradeErrorMessage on UpgradeError {
  String get message {
    switch (this) {
      case UpgradeError.maxLevelReached:
        return 'Building is already at maximum level';
      case UpgradeError.insufficientGold:
        return 'Not enough gold to upgrade';
      case UpgradeError.buildingInactive:
        return 'Cannot upgrade inactive building';
      case UpgradeError.buildingNotFound:
        return 'Building not found in player economy';
    }
  }
}
