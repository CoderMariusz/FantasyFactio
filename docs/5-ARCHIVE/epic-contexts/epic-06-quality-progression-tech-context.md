# Epic Technical Specification: Quality & Progression Systems (EPIC-06)

Date: 2025-11-23
Author: Claude (BMAD Game Development Agent)
Epic ID: EPIC-06
Epic Name: Progression System
Status: Ready for Implementation
Group: B - Operations

---

## Overview

Epic 06 implements the **Progression & Quality System** that guides players from Tier 1 (basic collection) to Tier 2 (automation) through clear milestones and rewarding celebrations. This epic is critical for **player retention** and **session depth** - clear progression goals increase Day 7 retention by 25-40% (benchmark: Clash of Clans progression systems).

**Epic Goal:** Create a progression framework that tracks player achievements (building diversity, resource milestones, gold earned), validates Tier 2 unlock requirements, and celebrates milestones with engaging animations and rewards.

**Business Value:**
- **Retention Driver:** Clear goals → 60%+ players unlock Tier 2 within 2-3 hours (target metric)
- **Engagement Hook:** Achievement tracking creates "completionist" gameplay loop
- **Tutorial Replacement:** Progression UI teaches mechanics organically (place buildings → earn gold → unlock Tier 2)
- **Quality Assurance:** Progression gates ensure players master Tier 1 before complexity increases

**Technical Complexity:** MEDIUM (5 SP stories) - Straightforward logic with UI/animation focus.

**Quality Focus:** This epic emphasizes **player experience quality** through:
- Clear visual feedback (progress bars, completion checkmarks)
- Satisfying celebration moments (unlock animations, rewards)
- Intuitive UI (always visible progression tracker)
- Smooth animations (60 FPS during celebrations)

---

## Objectives and Scope

### In-Scope (Must Have)

✅ **Tier 2 Unlock Requirements System**
- Define requirements: All 5 building types placed + 10 buildings total + 500 gold earned
- Validate requirements before unlock (prevent cheating)
- Track progress in real-time (update on every building placement, resource collection)
- Persist progress to Firestore (survive app restarts)

✅ **Progression Tracker UI**
- Always-visible widget: Shows "Tier 2 Progress: 3/5 types, 7/10 buildings, 350/500 gold"
- Progress bars with visual indicators (green = complete, gray = incomplete)
- Animated progress updates (smooth transitions, not instant jumps)
- Tap to expand: Show detailed breakdown of requirements

✅ **Unlock Celebration Animation**
- Full-screen modal: "🎉 TIER 2 UNLOCKED! 🎉"
- Fireworks/confetti particle effects (2-second animation)
- List unlocked features: "Conveyors, Automation, Advanced Buildings"
- "Continue" button to dismiss (blocks gameplay during celebration)
- Log achievement to Firebase Analytics

✅ **Achievement System Foundation**
- Define achievement data model: id, title, description, progress, unlocked
- Track achievements: "First Building Placed", "100 Gold Earned", "Tier 2 Unlocked"
- Persistent storage: Hive + Firestore sync
- Achievement notifications: Toast/snackbar when unlocked

✅ **Quality Assurance Testing**
- 100% test coverage for progression logic (15 unit tests)
- Widget tests for UI components (5 tests)
- Manual testing checklist (celebration animations, edge cases)
- Performance: Progression UI updates at 60 FPS

### Out-of-Scope (Future Phases)

❌ **Advanced Features (Post-MVP)**
- Tier 3+ progression systems → Month 2-3
- Achievement leaderboards (Firebase rankings) → v1.1
- Daily/weekly challenges → Phase 2
- Achievement rewards (gems, cosmetics) → Monetization phase

❌ **Extended Progression**
- Building mastery levels (Level 10 → Gold Star) → Post-launch
- Prestige system (reset for permanent bonuses) → v2.0
- Story-driven progression (narrative quests) → Out of scope

### Success Criteria (Testable)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Tier 2 Unlock Rate | 60%+ players unlock within 2-3 hours | Firebase Analytics funnel |
| Progression UI Visibility | 100% players see tracker within first 60 seconds | Session recordings |
| Celebration Engagement | 90%+ players watch full celebration animation | Event tracking (dismiss vs complete) |
| Achievement Awareness | 50%+ players tap achievement notifications | Click-through rate tracking |
| Code Quality | 100% test coverage for progression logic | Unit test coverage report |

---

## System Architecture Alignment

### Clean Architecture Layers

**Domain Layer (lib/domain/)**
```
lib/domain/entities/
  ├── progression_state.dart      # Player progression data: requirements, unlocked tiers
  ├── achievement.dart             # Achievement: id, title, description, progress, unlocked
  └── tier_unlock_requirements.dart # Requirements: building types, count, gold

lib/domain/use_cases/
  ├── progression/
  │   ├── check_tier_unlock.dart           # Validate if requirements met
  │   ├── track_progression.dart           # Update progress on player actions
  │   └── unlock_tier.dart                 # Execute unlock (log analytics, trigger celebration)
  └── achievements/
      ├── check_achievements.dart          # Check if any achievements newly unlocked
      ├── unlock_achievement.dart          # Mark achievement as unlocked
      └── get_all_achievements.dart        # Fetch achievement list

lib/domain/repositories/
  ├── progression_repository.dart   # Save/load progression state
  └── achievement_repository.dart   # Save/load achievements
```

**Data Layer (lib/data/)**
```
lib/data/models/
  ├── progression_state_model.dart  # JSON serialization, Hive TypeAdapter
  └── achievement_model.dart        # JSON serialization, Hive TypeAdapter

lib/data/repositories/
  ├── progression_repository_impl.dart   # Firestore + Hive caching
  └── achievement_repository_impl.dart   # Firestore + Hive caching
```

**Presentation Layer (lib/presentation/)**
```
lib/presentation/screens/
  └── game/
      └── widgets/
          ├── progression_tracker_widget.dart     # Always-visible tracker
          ├── tier_unlock_celebration_modal.dart  # Full-screen celebration
          ├── achievement_notification.dart       # Toast notification
          └── progression_details_sheet.dart      # Bottom sheet with details

lib/presentation/providers/
  ├── progression_provider.dart    # @riverpod: Real-time progression state
  └── achievement_provider.dart    # @riverpod: Achievement list + notifications
```

**Game Layer (lib/game/)**
```
lib/game/components/
  └── celebration_particle_system.dart  # Flame particle effects (fireworks, confetti)
```

### Technology Stack Alignment

| Component | Technology | Justification |
|-----------|-----------|---------------|
| Progression Logic | Pure Dart | Simple validation, no external deps |
| UI Components | Flutter Material 3 | Modern design, smooth animations |
| Animations | Flutter AnimatedContainer, Tween | Built-in animations, 60 FPS performance |
| Particle Effects | Flame ParticleSystemComponent | Game engine integration, GPU-accelerated |
| State Management | Riverpod @riverpod | Reactive updates when progress changes |
| Storage | Hive (local) + Firestore (cloud) | Offline-first, syncs when online |
| Analytics | Firebase Analytics | Track unlock funnel, engagement metrics |

### Integration Points

**Epic 01 (Core Loop) Dependencies:**
- Building Placement: Increment building count, track building types
- Resource Collection: Increment gold earned

**Epic 02 (Economy) Dependencies:**
- Gold Tracking: Monitor `PlayerEconomy.totalGoldEarned`
- Building Inventory: Check building type diversity

**Epic 05 (Mobile UX) Dependencies:**
- Main Game Screen: Embed progression tracker widget
- Modal System: Show celebration on unlock

**Provides to Epic 03 (Planning):**
- Tier 2 Unlock: Gates conveyor system access
- Tutorial Flow: Progression UI teaches building diversity

**Provides to Epic 10 (Analytics):**
- Funnel Events: Progression milestones (25% → 50% → 75% → 100%)
- Cohort Analysis: Time-to-Tier-2 distribution

---

## Detailed Design

### Services and Modules

#### 1. Progression Tracking System

**File:** `lib/domain/use_cases/progression/track_progression.dart`

**Responsibility:** Update progression state when player performs actions.

**API:**
```dart
class TrackProgressionUseCase {
  final ProgressionRepository _repository;
  final CheckTierUnlockUseCase _checkTierUnlock;

  TrackProgressionUseCase(this._repository, this._checkTierUnlock);

  /// Call when player places a building
  Future<ProgressionState> onBuildingPlaced(
    ProgressionState current,
    Building building,
  ) async {
    final buildingTypes = current.placedBuildingTypes.toSet()
      ..add(building.type);

    final updated = current.copyWith(
      placedBuildingTypes: buildingTypes.toList(),
      totalBuildingsPlaced: current.totalBuildingsPlaced + 1,
    );

    await _repository.saveProgressionState(updated);

    // Check if Tier 2 now unlocked
    if (_checkTierUnlock.execute(updated) && !current.tier2Unlocked) {
      FirebaseAnalytics.instance.logEvent(
        name: 'tier2_requirements_met',
        parameters: {
          'buildings_placed': updated.totalBuildingsPlaced,
          'building_types': buildingTypes.length,
          'gold_earned': updated.totalGoldEarned,
        },
      );
    }

    return updated;
  }

  /// Call when player collects resources (gold earned)
  Future<ProgressionState> onGoldEarned(
    ProgressionState current,
    int goldAmount,
  ) async {
    final updated = current.copyWith(
      totalGoldEarned: current.totalGoldEarned + goldAmount,
    );

    await _repository.saveProgressionState(updated);
    return updated;
  }

  /// Call when Tier 2 is unlocked
  Future<ProgressionState> onTier2Unlocked(
    ProgressionState current,
  ) async {
    final updated = current.copyWith(
      tier2Unlocked: true,
      tier2UnlockTime: DateTime.now(),
    );

    await _repository.saveProgressionState(updated);

    FirebaseAnalytics.instance.logEvent(
      name: 'tier2_unlocked',
      parameters: {
        'time_to_unlock_minutes': updated.tier2UnlockTime!
            .difference(current.accountCreationTime)
            .inMinutes,
      },
    );

    return updated;
  }
}
```

#### 2. Tier Unlock Validation

**File:** `lib/domain/use_cases/progression/check_tier_unlock.dart`

**Responsibility:** Check if player meets Tier 2 unlock requirements.

**API:**
```dart
class CheckTierUnlockUseCase {
  static const requiredBuildingTypes = 5; // All 5 types
  static const requiredBuildingCount = 10;
  static const requiredGoldEarned = 500;

  /// Returns true if all requirements met
  bool execute(ProgressionState state) {
    return state.placedBuildingTypes.length >= requiredBuildingTypes &&
           state.totalBuildingsPlaced >= requiredBuildingCount &&
           state.totalGoldEarned >= requiredGoldEarned;
  }

  /// Calculate overall progress (0.0 to 1.0)
  double calculateProgress(ProgressionState state) {
    final buildingTypeProgress =
        state.placedBuildingTypes.length / requiredBuildingTypes;
    final buildingCountProgress =
        state.totalBuildingsPlaced / requiredBuildingCount;
    final goldProgress =
        state.totalGoldEarned / requiredGoldEarned;

    // Average of all three requirements
    return (buildingTypeProgress + buildingCountProgress + goldProgress) / 3.0;
  }

  /// Get detailed progress breakdown for UI
  Map<String, ProgressDetail> getProgressDetails(ProgressionState state) {
    return {
      'building_types': ProgressDetail(
        label: 'Building Types',
        current: state.placedBuildingTypes.length,
        required: requiredBuildingTypes,
        isComplete: state.placedBuildingTypes.length >= requiredBuildingTypes,
      ),
      'building_count': ProgressDetail(
        label: 'Total Buildings',
        current: state.totalBuildingsPlaced,
        required: requiredBuildingCount,
        isComplete: state.totalBuildingsPlaced >= requiredBuildingCount,
      ),
      'gold_earned': ProgressDetail(
        label: 'Gold Earned',
        current: state.totalGoldEarned,
        required: requiredGoldEarned,
        isComplete: state.totalGoldEarned >= requiredGoldEarned,
      ),
    };
  }
}

class ProgressDetail {
  final String label;
  final int current;
  final int required;
  final bool isComplete;

  ProgressDetail({
    required this.label,
    required this.current,
    required this.required,
    required this.isComplete,
  });

  double get progress => (current / required).clamp(0.0, 1.0);
}
```

#### 3. Achievement System

**File:** `lib/domain/use_cases/achievements/check_achievements.dart`

**Responsibility:** Check if player actions unlock any achievements.

**API:**
```dart
class CheckAchievementsUseCase {
  final AchievementRepository _repository;

  CheckAchievementsUseCase(this._repository);

  /// Check achievements based on progression state
  Future<List<Achievement>> checkAndUnlock(
    ProgressionState progression,
    List<Achievement> currentAchievements,
  ) async {
    final newlyUnlocked = <Achievement>[];

    for (final achievement in currentAchievements.where((a) => !a.unlocked)) {
      if (_checkAchievementCondition(achievement, progression)) {
        final unlocked = achievement.copyWith(
          unlocked: true,
          unlockedAt: DateTime.now(),
        );

        await _repository.saveAchievement(unlocked);
        newlyUnlocked.add(unlocked);

        FirebaseAnalytics.instance.logEvent(
          name: 'achievement_unlocked',
          parameters: {'achievement_id': achievement.id},
        );
      }
    }

    return newlyUnlocked;
  }

  bool _checkAchievementCondition(
    Achievement achievement,
    ProgressionState progression,
  ) {
    switch (achievement.id) {
      case 'first_building':
        return progression.totalBuildingsPlaced >= 1;
      case 'five_buildings':
        return progression.totalBuildingsPlaced >= 5;
      case 'ten_buildings':
        return progression.totalBuildingsPlaced >= 10;
      case 'all_building_types':
        return progression.placedBuildingTypes.length >= 5;
      case '100_gold':
        return progression.totalGoldEarned >= 100;
      case '500_gold':
        return progression.totalGoldEarned >= 500;
      case 'tier2_unlocked':
        return progression.tier2Unlocked;
      default:
        return false;
    }
  }
}
```

**Predefined Achievements:**
```dart
class AchievementDefinitions {
  static final List<Achievement> tier1Achievements = [
    Achievement(
      id: 'first_building',
      title: 'First Steps',
      description: 'Place your first building',
      icon: '🏠',
      unlocked: false,
    ),
    Achievement(
      id: 'five_buildings',
      title: 'Small Factory',
      description: 'Place 5 buildings',
      icon: '🏭',
      unlocked: false,
    ),
    Achievement(
      id: 'ten_buildings',
      title: 'Growing Empire',
      description: 'Place 10 buildings',
      icon: '🌆',
      unlocked: false,
    ),
    Achievement(
      id: 'all_building_types',
      title: 'Master Builder',
      description: 'Place all 5 building types',
      icon: '⚙️',
      unlocked: false,
    ),
    Achievement(
      id: '100_gold',
      title: 'First Fortune',
      description: 'Earn 100 gold',
      icon: '💰',
      unlocked: false,
    ),
    Achievement(
      id: '500_gold',
      title: 'Wealthy Trader',
      description: 'Earn 500 gold',
      icon: '💎',
      unlocked: false,
    ),
    Achievement(
      id: 'tier2_unlocked',
      title: 'Automation Master',
      description: 'Unlock Tier 2 (Conveyors)',
      icon: '🎉',
      unlocked: false,
    ),
  ];
}
```

---

### Data Models and Contracts

#### ProgressionState Entity

```dart
import 'package:equatable/equatable.dart';

class ProgressionState extends Equatable {
  final List<BuildingType> placedBuildingTypes;
  final int totalBuildingsPlaced;
  final int totalGoldEarned;
  final bool tier2Unlocked;
  final DateTime? tier2UnlockTime;
  final DateTime accountCreationTime;

  const ProgressionState({
    required this.placedBuildingTypes,
    required this.totalBuildingsPlaced,
    required this.totalGoldEarned,
    required this.tier2Unlocked,
    this.tier2UnlockTime,
    required this.accountCreationTime,
  });

  /// Initial state for new players
  factory ProgressionState.initial() {
    return ProgressionState(
      placedBuildingTypes: [],
      totalBuildingsPlaced: 0,
      totalGoldEarned: 0,
      tier2Unlocked: false,
      tier2UnlockTime: null,
      accountCreationTime: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    placedBuildingTypes,
    totalBuildingsPlaced,
    totalGoldEarned,
    tier2Unlocked,
    tier2UnlockTime,
    accountCreationTime,
  ];

  ProgressionState copyWith({
    List<BuildingType>? placedBuildingTypes,
    int? totalBuildingsPlaced,
    int? totalGoldEarned,
    bool? tier2Unlocked,
    DateTime? tier2UnlockTime,
  }) {
    return ProgressionState(
      placedBuildingTypes: placedBuildingTypes ?? this.placedBuildingTypes,
      totalBuildingsPlaced: totalBuildingsPlaced ?? this.totalBuildingsPlaced,
      totalGoldEarned: totalGoldEarned ?? this.totalGoldEarned,
      tier2Unlocked: tier2Unlocked ?? this.tier2Unlocked,
      tier2UnlockTime: tier2UnlockTime ?? this.tier2UnlockTime,
      accountCreationTime: accountCreationTime,
    );
  }
}
```

#### Achievement Entity

```dart
class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon; // Emoji or asset path
  final bool unlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.unlockedAt,
  });

  @override
  List<Object?> get props => [id, title, description, icon, unlocked, unlockedAt];

  Achievement copyWith({
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
```

---

### APIs and Interfaces

#### ProgressionRepository

```dart
abstract class ProgressionRepository {
  /// Get current progression state (local + cloud merge)
  Future<ProgressionState> getProgressionState();

  /// Save progression state to local cache and Firestore
  Future<void> saveProgressionState(ProgressionState state);

  /// Reset progression (for testing or prestige systems)
  Future<void> resetProgression();
}
```

#### AchievementRepository

```dart
abstract class AchievementRepository {
  /// Get all achievements (local + cloud merge)
  Future<List<Achievement>> getAllAchievements();

  /// Save single achievement
  Future<void> saveAchievement(Achievement achievement);

  /// Get unlocked achievements count
  Future<int> getUnlockedCount();
}
```

---

### Workflows and Sequencing

#### Workflow 1: Player Progresses Toward Tier 2

```
┌──────────┐     ┌────────────────┐     ┌──────────────┐     ┌────────────┐
│  Player  │     │ Presentation   │     │   Domain     │     │    Data    │
└────┬─────┘     └────────┬───────┘     └──────┬───────┘     └─────┬──────┘
     │                    │                    │                   │
     │ 1. Place Building  │                    │                   │
     ├───────────────────>│                    │                   │
     │                    │ 2. TrackProgression│                   │
     │                    │    (building+1)    │                   │
     │                    ├───────────────────>│                   │
     │                    │                    │ 3. SaveState      │
     │                    │                    ├──────────────────>│
     │                    │                    │                   │
     │                    │ 4. CheckTierUnlock │                   │
     │                    │<───────────────────┤                   │
     │                    │                    │                   │
     │                    │ Result: 3/5 types, │                   │
     │                    │         7/10 bldgs,│                   │
     │                    │         350/500g   │                   │
     │                    │                    │                   │
     │ 5. UI Update:      │                    │                   │
     │    Progress bar    │                    │                   │
     │    fills +10%      │                    │                   │
     │<───────────────────┤                    │                   │
     │                    │                    │                   │
     │ [Player continues  │                    │                   │
     │  playing...]       │                    │                   │
     │                    │                    │                   │
     │ 6. Place 10th      │                    │                   │
     │    Building (last  │                    │                   │
     │    requirement)    │                    │                   │
     ├───────────────────>│                    │                   │
     │                    │ 7. TrackProgression│                   │
     │                    ├───────────────────>│                   │
     │                    │                    │                   │
     │                    │ 8. CheckTierUnlock │                   │
     │                    │    = TRUE ✅       │                   │
     │                    │<───────────────────┤                   │
     │                    │                    │                   │
     │                    │ 9. UnlockTier2     │                   │
     │                    ├───────────────────>│                   │
     │                    │                    │ 10. SaveState     │
     │                    │                    │     (unlocked)    │
     │                    │                    ├──────────────────>│
     │                    │                    │                   │
     │                    │ 11. Show           │                   │
     │                    │     Celebration    │                   │
     │                    │     Modal          │                   │
     │                    │                    │                   │
     │ 12. 🎉 TIER 2      │                    │                   │
     │     UNLOCKED! 🎉   │                    │                   │
     │     [Fireworks]    │                    │                   │
     │<───────────────────┤                    │                   │
     │                    │                    │                   │
```

#### Workflow 2: Tier 2 Unlock Celebration

```
┌──────────────────────────────────────────────────────────────┐
│             Tier 2 Unlock Celebration Modal                   │
│                                                              │
│  [Fullscreen overlay with semi-transparent background]      │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                                                        │ │
│  │              🎉 TIER 2 UNLOCKED! 🎉                    │ │
│  │                                                        │ │
│  │         [Fireworks particle animation]                │ │
│  │         [Confetti falling from top]                   │ │
│  │                                                        │ │
│  │  ✨ Congratulations! You've mastered the basics! ✨   │ │
│  │                                                        │ │
│  │  New Features Unlocked:                               │ │
│  │  ✓ Conveyors (Automated resource transport)           │ │
│  │  ✓ Advanced Buildings (Smelter, Workshop)            │ │
│  │  ✓ Complex Production Chains                          │ │
│  │                                                        │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │           Continue to Tier 2                     │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  │                                                        │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
└──────────────────────────────────────────────────────────────┘

Animation Timeline:
0.0s: Modal fades in (300ms)
0.3s: Title text appears with scale animation
0.6s: Fireworks start (particle system, 2-second duration)
0.8s: Confetti falls (particle system, 2-second duration)
1.0s: Feature list animates in (staggered, 100ms each item)
2.0s: "Continue" button appears with pulse animation
```

---

## Non-Functional Requirements

### Performance

| Metric | Requirement | Test Method |
|--------|-------------|-------------|
| Progression UI Updates | <16ms (60 FPS) | Flutter DevTools performance overlay |
| Celebration Animation | 60 FPS sustained | FPS counter during 2-second animation |
| State Save Time | <50ms to Hive | Performance test with Stopwatch |
| Achievement Check | <10ms per action | Unit test benchmark |
| Modal Load Time | <300ms from trigger to visible | Manual timing test |

**Optimization Strategies:**
1. **Debouncing:** Update progression UI max once per 500ms (prevent spam on rapid building placement)
2. **Memoization:** Cache `CheckTierUnlockUseCase.getProgressDetails()` result until state changes
3. **Lazy Loading:** Load achievement list only when achievements screen opened (not on app start)
4. **Particle Pooling:** Reuse particle components in celebration animation

### Security

**Anti-Cheat Measures:**
```dart
// Validate progression state on Firestore write
// Cloud Function: validate_progression.js
exports.validateProgression = functions.firestore
  .document('users/{userId}/progression')
  .onWrite((change, context) => {
    const after = change.after.data();

    // Check if gold earned matches building count (rough validation)
    const expectedMinGold = after.totalBuildingsPlaced * 10; // ~10 gold per building
    if (after.totalGoldEarned < expectedMinGold * 0.5) {
      // Suspicious: Too little gold for this many buildings
      console.error(`Suspicious progression: ${context.params.userId}`);
      // Flag for manual review, don't block (could be false positive)
    }

    // Check if building types is valid (max 5 types in Tier 1)
    if (after.placedBuildingTypes.length > 5) {
      // Invalid: More than 5 building types
      console.error(`Invalid building types: ${context.params.userId}`);
      return change.after.ref.update({ placedBuildingTypes: after.placedBuildingTypes.slice(0, 5) });
    }

    return null;
  });
```

### Reliability/Availability

**Error Handling:**
```dart
try {
  final updated = await _trackProgression.onBuildingPlaced(current, building);
  _progressionProvider.update(updated);
} catch (e, stackTrace) {
  FirebaseCrashlytics.instance.recordError(e, stackTrace);
  // Fallback: Continue without updating progression (don't block gameplay)
  showSnackBar('Progress tracking temporarily unavailable');
}
```

**Offline Support:**
- All progression state cached in Hive (works offline)
- Sync to Firestore when connection restored
- Conflict resolution: Latest timestamp wins (last-write-wins)

### Observability

**Firebase Analytics Events:**
```dart
// Track progression milestones
FirebaseAnalytics.instance.logEvent(
  name: 'progression_milestone',
  parameters: {
    'milestone': '25_percent', // 25%, 50%, 75%, 100%
    'time_to_milestone_minutes': DateTime.now().difference(accountCreation).inMinutes,
  },
);

// Track Tier 2 unlock
FirebaseAnalytics.instance.logEvent(
  name: 'tier2_unlocked',
  parameters: {
    'time_to_unlock_minutes': timeToUnlock,
    'buildings_placed': state.totalBuildingsPlaced,
    'gold_earned': state.totalGoldEarned,
  },
);

// Track achievement unlocks
FirebaseAnalytics.instance.logEvent(
  name: 'achievement_unlocked',
  parameters: {
    'achievement_id': achievement.id,
    'unlock_order': unlockedCount + 1, // 1st, 2nd, 3rd achievement unlocked
  },
);
```

**Funnel Analysis:**
- Track % of players at each progression milestone (0% → 25% → 50% → 75% → 100%)
- Identify drop-off points (e.g., 40% quit at 50% progress)
- Cohort analysis: Time-to-Tier-2 distribution (median, p50, p90, p99)

---

## Dependencies and Integrations

### Upstream Dependencies

| Epic/Story | Required Artifacts |
|------------|-------------------|
| **EPIC-01: Core Loop** | `Building` entity, building placement logic |
| **EPIC-02: Economy** | `PlayerEconomy.totalGoldEarned`, resource tracking |
| **EPIC-05: Mobile UX** | Main game screen, modal system |

### Downstream Dependents

| Epic | How It Uses EPIC-06 |
|------|---------------------|
| **EPIC-03: Planning** | Tier 2 unlock gates conveyor access |
| **EPIC-07: Tutorial** | Progression UI teaches mechanics organically |
| **EPIC-10: Analytics** | Progression milestones for funnel analysis |

---

## Acceptance Criteria (Authoritative)

✅ **AC-1: Tier 2 Requirements Validation**
- Given: Player has 5 building types, 10 buildings, 500 gold
- When: `CheckTierUnlockUseCase.execute()` called
- Then: Returns true (all requirements met)
- Test: Unit test with mocked progression state

✅ **AC-2: Progression Tracker UI**
- Given: Player has 3 building types, 7 buildings, 350 gold
- When: Progression tracker widget rendered
- Then: Shows "Tier 2 Progress: 3/5 types, 7/10 buildings, 350/500 gold"
- Test: Widget test with mocked state

✅ **AC-3: Real-Time Progress Updates**
- Given: Player at 7/10 buildings
- When: Player places 8th building
- Then: UI updates to "8/10 buildings" within 500ms (smooth animation)
- Test: Integration test + manual test

✅ **AC-4: Unlock Celebration Animation**
- Given: Player meets all Tier 2 requirements
- When: 10th building placed (final requirement)
- Then: Full-screen modal appears with fireworks, confetti, feature list, "Continue" button
- Test: Widget test + manual test (verify 60 FPS)

✅ **AC-5: Achievement Unlocks**
- Given: Player earns 100 gold (achievement: "First Fortune")
- When: `CheckAchievementsUseCase` runs
- Then: Achievement marked as unlocked, notification shown, Firebase event logged
- Test: Unit test + widget test for notification

✅ **AC-6: Persistence**
- Given: Progression at 8/10 buildings
- When: Player closes app → reopens app
- Then: Progression state restored (8/10 buildings shown)
- Test: Integration test with Hive

✅ **AC-7: Performance**
- Given: Progression UI rendered
- When: Player rapidly places 10 buildings (1 per second)
- Then: UI updates at 60 FPS (no frame drops)
- Test: Performance test with Flutter DevTools

---

## Traceability Mapping

| Requirement | Epic/Story | Acceptance Criteria |
|-------------|-----------|---------------------|
| **FR-006: Progression System** | EPIC-06 (this doc) | AC-1 through AC-7 |
| FR-006.1: Tier 2 Requirements | STORY-06.1 | AC-1, AC-2 |
| FR-006.2: Unlock Celebration | STORY-06.2 | AC-4 |
| FR-006.3: Achievement System | STORY-06.3 | AC-5 |
| FR-006.4: Progression UI | STORY-06.4 | AC-2, AC-3 |
| **NFR-001: Performance** | Cross-cutting | AC-7 |
| **NFR-003: Quality** | Cross-cutting | All ACs (test coverage) |

---

## Risks, Assumptions, Open Questions

### Risks

🟡 **RISK-1: Requirements Too Easy/Hard**
- **Impact:** MEDIUM - If too easy: Players unlock Tier 2 in <1 hour (bored). If too hard: <40% unlock within 3 hours (frustrated)
- **Likelihood:** MEDIUM - Balance is subjective, needs playtesting
- **Mitigation:**
  1. A/B test different requirements (500g vs 750g, 10 buildings vs 15)
  2. Monitor Day 1 analytics: Unlock rate at 1h, 2h, 3h marks
  3. Adjust requirements in hotfix if needed (Firestore Remote Config)
- **Contingency:** Reduce requirements to 8 buildings, 400 gold if <50% unlock rate

🟡 **RISK-2: Celebration Animation Lag (Low-End Devices)**
- **Impact:** MEDIUM - Frame drops during celebration ruin "magical moment"
- **Likelihood:** LOW - Flame particle systems are GPU-accelerated
- **Mitigation:**
  1. Test on Snapdragon 660 (target device)
  2. Use object pooling for particles (reuse components)
  3. Fallback: Reduce particle count on low-end devices (detect via device specs)
- **Contingency:** Simplify animation (static confetti PNG instead of particles)

### Assumptions

1. **Linear Progression:** Assumes all players follow Tier 1 → Tier 2 path (no skipping)
2. **Single Unlock Celebration:** Assumes celebration shown once per player (not repeatable)
3. **No Negative Progress:** Assumes players cannot lose progress (buildings can't be deleted in MVP)

### Open Questions

❓ **Q1:** Should we show progression tracker after first building placed (tutorial)?
- **Decision Needed By:** Sprint 5 (before STORY-06.4)
- **Owner:** UX Designer
- **Impact:** Low (tutorial flow decision)

❓ **Q2:** Should achievements grant rewards (gems, cosmetics)?
- **Decision Needed By:** Monetization planning (Month 2)
- **Owner:** Game Designer
- **Impact:** Medium (affects monetization balance)

❓ **Q3:** Should Tier 2 unlock be reversible (for testing)?
- **Decision Needed By:** Sprint 5 (before STORY-06.1)
- **Owner:** Tech Lead
- **Impact:** Low (dev tooling decision)

---

## Test Strategy Summary

### Unit Tests (Target: 15 tests)

**Progression Logic (10 tests):**
- ✅ Check unlock: 5 types, 10 buildings, 500 gold = TRUE
- ✅ Check unlock: 4 types, 10 buildings, 500 gold = FALSE
- ✅ Calculate progress: 3 types, 7 buildings, 350 gold = 65%
- ✅ Track building placed: 7 → 8 buildings
- ✅ Track gold earned: 350 → 450 gold
- ✅ Unlock Tier 2: Set `tier2Unlocked = true`, log analytics

**Achievement Logic (5 tests):**
- ✅ Check achievement: 100 gold earned → unlock "First Fortune"
- ✅ Check achievement: 10 buildings → unlock "Growing Empire"
- ✅ Multiple achievements unlock simultaneously
- ✅ Already unlocked achievement not re-triggered

### Widget Tests (5 tests)

- ✅ Progression tracker renders: "3/5 types, 7/10 buildings, 350/500 gold"
- ✅ Progress bars fill correctly (60% gold = 60% filled)
- ✅ Checkmarks shown for completed requirements (green ✓)
- ✅ Celebration modal renders: Title, fireworks, feature list, button
- ✅ Achievement notification toast appears

### Integration Tests (3 tests)

- ✅ End-to-end: Place buildings → progress updates → Tier 2 unlocked → celebration shown
- ✅ Persistence: Save progression → close app → reopen → state restored
- ✅ Offline sync: Update offline → go online → syncs to Firestore

### Manual Tests (Checklist)

- [ ] Celebration animation runs at 60 FPS (visual inspection)
- [ ] Fireworks/confetti look visually appealing (aesthetic check)
- [ ] Progress tracker always visible on game screen (UI placement)
- [ ] Achievement notifications don't block critical gameplay
- [ ] Tier 2 unlock feels "rewarding" (playtest with 5 users)

**Total Tests:** 15 unit + 5 widget + 3 integration + 5 manual = **28 tests**

---

## Implementation Notes

**Sprint Allocation:**
- **Sprint 5 (Week 7):** STORY-06.1 (Requirements), STORY-06.4 (Tracker UI)
- **Sprint 6 (Week 8):** STORY-06.2 (Celebration), STORY-06.3 (Achievements)

**Developer Notes:**
- Use `AnimatedContainer` for smooth progress bar fills (60 FPS)
- Flame `ParticleSystemComponent` for fireworks (GPU-accelerated)
- Riverpod `@riverpod` with `.autoDispose` for progression state (memory management)
- Firebase Analytics events must match naming convention: `tier2_*`, `achievement_*`

**Code Review Checklist:**
- [ ] Progression requirements validated both client-side and server-side (anti-cheat)
- [ ] Celebration animation tested on Snapdragon 660 (60 FPS confirmed)
- [ ] Achievement conditions cover all edge cases (0 buildings, negative gold)
- [ ] UI updates debounced (max 1 update per 500ms, prevent spam)
- [ ] Tests: 100% coverage for progression logic, achievement checks

---

**Document Status:** ✅ Ready for Development
**Next Steps:** Sprint 5 planning, assign STORY-06.1 and STORY-06.4
**Questions:** Contact Game Designer (requirement balance) or UX Designer (celebration animation specs)
