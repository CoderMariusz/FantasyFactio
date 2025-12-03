import 'package:equatable/equatable.dart';

/// Types of unlock conditions for buildings
enum UnlockType {
  /// Available from game start
  gameStart,

  /// Unlocked after completing a specific action X times
  afterAction,

  /// Unlocked after reaching a skill level
  afterSkillLevel,
}

/// Represents a condition that must be met to unlock a building
class UnlockCondition extends Equatable {
  /// Type of unlock condition
  final UnlockType type;

  /// Action ID for afterAction type (e.g., 'smelt_iron_ore')
  final String? actionId;

  /// Required count for afterAction type
  final int? requiredCount;

  /// Skill ID for afterSkillLevel type
  final String? skillId;

  /// Required level for afterSkillLevel type
  final int? requiredLevel;

  /// Building is available from game start
  const UnlockCondition.gameStart()
      : type = UnlockType.gameStart,
        actionId = null,
        requiredCount = null,
        skillId = null,
        requiredLevel = null;

  /// Building unlocks after completing action X times
  const UnlockCondition.afterAction(String action, int count)
      : type = UnlockType.afterAction,
        actionId = action,
        requiredCount = count,
        skillId = null,
        requiredLevel = null;

  /// Building unlocks after reaching skill level
  const UnlockCondition.afterSkillLevel(String skill, int level)
      : type = UnlockType.afterSkillLevel,
        actionId = null,
        requiredCount = null,
        skillId = skill,
        requiredLevel = level;

  /// Check if condition is met based on player progress
  bool isMet({
    required Map<String, int> actionCounts,
    required Map<String, int> skillLevels,
  }) {
    switch (type) {
      case UnlockType.gameStart:
        return true;
      case UnlockType.afterAction:
        final count = actionCounts[actionId] ?? 0;
        return count >= (requiredCount ?? 0);
      case UnlockType.afterSkillLevel:
        final level = skillLevels[skillId] ?? 0;
        return level >= (requiredLevel ?? 0);
    }
  }

  /// Get human-readable description
  String get description {
    switch (type) {
      case UnlockType.gameStart:
        return 'Available at game start';
      case UnlockType.afterAction:
        return 'Unlock after: $actionId x$requiredCount';
      case UnlockType.afterSkillLevel:
        return 'Requires $skillId Level $requiredLevel';
    }
  }

  @override
  List<Object?> get props => [type, actionId, requiredCount, skillId, requiredLevel];
}
