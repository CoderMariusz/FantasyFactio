# Epic 6: Progression & Quality System - Detailed Stories

<!-- AI-INDEX: epic, stories, acceptance-criteria, progression, skills -->

**Epic:** EPIC-06 - Progression & Quality System
**Total Stories:** 6
**Total SP:** 28
**Sprint:** 9 (post-MVP, blocks EPIC-03 Tier 2)
**Status:** 📋 Ready for Implementation
**Tech-Spec:** [epic-06-tech-spec.md](epic-06-tech-spec.md)

**Prerequisites:**
- ✅ EPIC-01 (Building placement)
- ✅ EPIC-02 (Gold tracking, basic skills)

**Design Philosophy:** "Clear goals drive engagement" - jasne cele = lepsza retencja.

> **Note:** This epic defines Tier 2 unlock requirements which gate EPIC-03 content. Review sprint assignment.

---

## Story Overview

| Story ID | Title | SP | Priority | Implementation Status |
|----------|-------|-----|----------|----------------------|
| STORY-06.1 | Tier 2 Unlock Requirements System | 5 | P0 | 📋 Ready |
| STORY-06.2 | Progression Tracker UI | 4 | P0 | 📋 Ready |
| STORY-06.3 | Tier 2 Unlock Celebration | 5 | P1 | 📋 Ready |
| STORY-06.4 | Achievement System | 5 | P1 | 📋 Ready |
| STORY-06.5 | Extended Skill System | 6 | P1 | 📋 Ready |
| STORY-06.6 | Achievements Screen | 3 | P2 | 📋 Ready |

---

## STORY-06.1: Tier 2 Unlock Requirements System (5 SP)

### Objective
Implement the Tier 2 unlock requirements validation with real-time progress tracking.

### User Story
As a player, I want to see clear requirements for unlocking Tier 2 so I know what to work toward.

### Description
This story implements the core progression logic: tracking building types, building count, and gold earned. When all requirements are met, Tier 2 (conveyors) becomes available.

### Acceptance Criteria

#### AC1: Requirements Definition
```dart
✅ Tier 2 Requirements:
   - 5/5 building types placed (Mining, Storage, Smelter, Workshop, Farm)
   - 10 total buildings
   - 500 gold earned (lifetime)

✅ CheckTierUnlockUseCase:
   - execute(state) → bool
   - calculateProgress(state) → double (0.0 to 1.0)
   - getProgressDetails(state) → Map<String, ProgressDetail>
```

#### AC2: ProgressionState Entity
```dart
✅ ProgressionState class:
   - placedBuildingTypes: List<BuildingType>
   - totalBuildingsPlaced: int
   - totalGoldEarned: int
   - tier2Unlocked: bool
   - tier2UnlockTime: DateTime?
   - accountCreationTime: DateTime

✅ Methods:
   - copyWith() for immutable updates
   - factory initial() for new players
```

#### AC3: Progress Tracking
```
✅ TrackProgressionUseCase:
   - onBuildingPlaced(state, building) → updates types + count
   - onGoldEarned(state, amount) → updates gold
   - onTier2Unlocked(state) → marks unlocked, logs analytics

✅ Auto-check after each action:
   - If requirements met + not yet unlocked → trigger unlock
```

#### AC4: Persistence
```
✅ ProgressionRepository:
   - getProgressionState() → from Hive + Firestore
   - saveProgressionState(state) → to both
   - Conflict resolution: latest timestamp wins

✅ Offline support:
   - Works offline (Hive cache)
   - Syncs when connection restored
```

#### AC5: Unit Tests Pass
```
✅ Test: 5 types + 10 buildings + 500g = unlocked
✅ Test: 4 types + 10 buildings + 500g = NOT unlocked
✅ Test: calculateProgress returns correct %
✅ Test: onBuildingPlaced updates state correctly
✅ Test: State persists to Hive
✅ Test: State syncs to Firestore
```

### Implementation Notes

**Files to Create:**
- `lib/domain/entities/progression_state.dart`
- `lib/domain/entities/tier_unlock_requirements.dart`
- `lib/domain/usecases/progression/check_tier_unlock_usecase.dart`
- `lib/domain/usecases/progression/track_progression_usecase.dart`
- `lib/data/repositories/progression_repository_impl.dart`
- `test/domain/usecases/progression/` - Tests

**Dependencies:**
- EPIC-01 Building entity
- EPIC-02 Gold tracking

**Blocks:**
- STORY-06.2 (Celebration needs unlock trigger)
- STORY-06.3 (Tracker UI needs state)

---

## STORY-06.2: Progression Tracker UI (4 SP)

### Objective
Implement always-visible progression tracker widget with expandable details.

### User Story
As a player, I want to see my Tier 2 progress at all times so I stay motivated.

### Description
The tracker shows overall progress percentage when collapsed. Tapping expands to show detailed breakdown of each requirement with animated progress bars.

### Acceptance Criteria

#### AC1: Collapsed State
```
✅ Compact widget:
   - Shows: "TIER 2 PROGRESS" title
   - Overall % progress bar
   - Percentage text (e.g., "75%")
   - Tap indicator (▼)

✅ Position:
   - Top of game screen
   - Below top HUD
   - Width: Full screen with padding
```

#### AC2: Expanded State
```
✅ Detailed breakdown:
   - Building Types: 5/5 with progress bar
   - Total Buildings: 7/10 with progress bar
   - Gold Earned: 350/500 with progress bar

✅ Visual indicators:
   - ✓ Green checkmark for completed
   - ○ Gray circle for incomplete
   - Progress bars color-coded (green = done)
```

#### AC3: Animations
```
✅ Expand/collapse:
   - Smooth height animation (300ms)
   - Tap to toggle

✅ Progress updates:
   - Animated progress bar fill
   - Number counter animation (350 → 360)
   - Debounce: Max 1 update per 500ms
```

#### AC4: Responsive Layout
```
✅ Adapts to screen size:
   - Small phones: Compact text
   - Large phones: Normal spacing
   - Respects safe areas
```

#### AC5: Unit Tests Pass
```
✅ Test: Widget renders with correct data
✅ Test: Tap expands/collapses
✅ Test: Progress bars fill correctly
✅ Test: Checkmarks show for completed
✅ Test: Animation runs smoothly
```

### Implementation Notes

**Files to Create:**
- `lib/presentation/widgets/progression_tracker_widget.dart`
- `lib/presentation/widgets/progress_requirement_row.dart`
- `lib/presentation/providers/progression_provider.dart`
- `test/presentation/widgets/progression_tracker_widget_test.dart`

**Layout Structure:**
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  child: Column(
    children: [
      _ProgressHeader(progress: state.overallProgress),
      if (isExpanded) ...[
        _RequirementRow('Building Types', state.types, 5),
        _RequirementRow('Buildings', state.buildings, 10),
        _RequirementRow('Gold', state.gold, 500),
      ],
    ],
  ),
)
```

**Dependencies:**
- STORY-06.1 (ProgressionState)

**Blocks:**
- Nothing (UI layer)

---

## STORY-06.3: Tier 2 Unlock Celebration (5 SP)

### Objective
Implement full-screen celebration modal with particle effects when Tier 2 is unlocked.

### User Story
As a player, I want an exciting celebration when I unlock Tier 2 so the achievement feels rewarding.

### Description
When all requirements are met, a full-screen modal appears with fireworks, confetti, and a list of unlocked features. This creates a "magical moment" that players remember.

### Acceptance Criteria

#### AC1: Modal Trigger
```
✅ Trigger conditions:
   - All 3 requirements met
   - Not previously unlocked
   - Immediately after final action

✅ Blocks gameplay:
   - Modal is full-screen
   - Must tap "Continue" to dismiss
   - Can't interact with game behind
```

#### AC2: Visual Design
```
✅ Layout:
   - Semi-transparent dark overlay
   - Centered card (max 400px)
   - "🎉 TIER 2 UNLOCKED! 🎉" title
   - Feature list with checkmarks
   - "Continue" button at bottom

✅ Colors:
   - Gold accent for title
   - Green checkmarks
   - White text on dark bg
```

#### AC3: Particle Effects
```
✅ Fireworks:
   - Burst from center
   - Multiple colors (gold, red, blue)
   - 2-second duration
   - GPU-accelerated (Flame)

✅ Confetti:
   - Falls from top
   - Random colors
   - Slight drift
   - Fades out at bottom
```

#### AC4: Animation Timeline
```
✅ Sequence:
   0.0s: Modal fades in (300ms)
   0.3s: Title scales in
   0.6s: Fireworks start
   0.8s: Confetti starts
   1.0s: Feature list animates in (staggered)
   2.0s: Continue button appears with pulse
```

#### AC5: Analytics & Haptics
```
✅ Firebase Analytics:
   - Log 'tier2_unlocked' event
   - Include time_to_unlock_minutes
   - Include buildings_placed, gold_earned

✅ Haptics:
   - Medium impact on modal appear
   - Light impact on button tap
```

#### AC6: Unit Tests Pass
```
✅ Test: Modal appears when requirements met
✅ Test: Fireworks particle system runs
✅ Test: Confetti particle system runs
✅ Test: Continue button dismisses modal
✅ Test: Analytics event logged
✅ Test: 60 FPS maintained
```

### Implementation Notes

**Files to Create:**
- `lib/presentation/widgets/tier_unlock_celebration_modal.dart`
- `lib/game/components/celebration_particle_system.dart`
- `lib/presentation/animations/confetti_animation.dart`
- `test/presentation/widgets/tier_unlock_celebration_modal_test.dart`

**Particle System:**
```dart
class CelebrationParticleSystem extends ParticleSystemComponent {
  // Fireworks burst
  // Confetti fall
  // Object pooling for performance
}
```

**Dependencies:**
- STORY-06.1 (Unlock trigger)
- Flame engine (particles)

**Blocks:**
- Nothing (celebration layer)

---

## STORY-06.4: Achievement System (5 SP)

### Objective
Implement achievement tracking, unlock notifications, and persistent storage.

### User Story
As a player, I want to earn achievements for my progress so I feel recognized for my accomplishments.

### Description
The achievement system tracks 7 Tier 1 achievements. When unlocked, a toast notification appears. Achievements persist across sessions and sync to cloud.

### Acceptance Criteria

#### AC1: Achievement Definitions
```dart
✅ 7 Tier 1 Achievements:
   - first_building: "First Steps" - Place 1 building
   - five_buildings: "Small Factory" - Place 5 buildings
   - ten_buildings: "Growing Empire" - Place 10 buildings
   - all_types: "Master Builder" - All 5 building types
   - 100_gold: "First Fortune" - Earn 100 gold
   - 500_gold: "Wealthy Trader" - Earn 500 gold
   - tier2_unlocked: "Automation Master" - Unlock Tier 2

✅ Achievement entity:
   - id, title, description, icon
   - unlocked: bool
   - unlockedAt: DateTime?
```

#### AC2: Achievement Checking
```dart
✅ CheckAchievementsUseCase:
   - checkAndUnlock(progression, achievements) → newlyUnlocked[]
   - Runs after every progression update
   - Returns list of newly unlocked achievements

✅ Multiple unlocks:
   - Can unlock several achievements at once
   - Queue notifications (show one at a time)
```

#### AC3: Notification Toast
```
✅ Toast appearance:
   - Slides in from top
   - Shows: Icon + Title + "Achievement Unlocked!"
   - Auto-dismiss after 3 seconds
   - Tap to dismiss early

✅ Queue system:
   - Multiple achievements queue
   - 500ms delay between toasts
   - Max 3 visible (older fade out)
```

#### AC4: Persistence
```
✅ Storage:
   - Hive: Local cache
   - Firestore: Cloud backup
   - Sync on app start

✅ AchievementRepository:
   - getAllAchievements() → List<Achievement>
   - saveAchievement(achievement)
   - getUnlockedCount() → int
```

#### AC5: Analytics
```
✅ Firebase events:
   - 'achievement_unlocked' with achievement_id
   - Track unlock_order (1st, 2nd, 3rd...)
   - Track time since account creation
```

#### AC6: Unit Tests Pass
```
✅ Test: 100 gold triggers '100_gold' achievement
✅ Test: Already unlocked not re-triggered
✅ Test: Multiple achievements unlock together
✅ Test: Toast notification appears
✅ Test: Achievements persist to Hive
✅ Test: Analytics events logged
```

### Implementation Notes

**Files to Create:**
- `lib/domain/entities/achievement.dart`
- `lib/domain/usecases/achievements/check_achievements_usecase.dart`
- `lib/domain/usecases/achievements/unlock_achievement_usecase.dart`
- `lib/data/repositories/achievement_repository_impl.dart`
- `lib/presentation/widgets/achievement_notification.dart`
- `lib/presentation/providers/achievement_provider.dart`
- `test/domain/usecases/achievements/` - Tests

**Notification Queue:**
```dart
class AchievementNotificationQueue {
  final _queue = Queue<Achievement>();

  void add(Achievement achievement) {
    _queue.add(achievement);
    _showNext();
  }

  void _showNext() {
    if (_queue.isEmpty) return;
    final achievement = _queue.removeFirst();
    // Show toast, then delay, then _showNext()
  }
}
```

**Dependencies:**
- STORY-06.1 (Progression state)

**Blocks:**
- STORY-06.5 (Skill points from achievements)

---

## STORY-06.5: Extended Skill System (6 SP)

### Objective
Implement extended skill trees with skill points earned through gameplay.

### User Story
As a player, I want to level up skills to make my factory more efficient and feel a sense of progression.

### Description
The extended skill system builds on EPIC-02's basic skills. Players earn Skill Points (SP) through milestones and achievements, then spend them to level up 5 skill trees.

### Acceptance Criteria

#### AC1: Skill Definitions
```dart
✅ 5 Skill Trees:
   - Mining (Lv 1-10): -5% cycle time per level
   - Smelting (Lv 1-10): +5% yield per level
   - Trading (Lv 1-10): +5% sell price per level
   - Crafting (Lv 1-10): -5% recipe cost per level
   - Automation (Lv 1-10): +10% conveyor speed per level

✅ SkillTree entity:
   - skillType: SkillType
   - currentLevel: int (0-10)
   - bonusPerLevel: double
   - totalBonus: double (calculated)
```

#### AC2: Skill Point Earning
```
✅ SP Sources:
   - Every 50 gold earned: +1 SP
   - Every 5 buildings placed: +1 SP
   - Every achievement unlocked: +1 SP
   - Tier 2 unlock bonus: +5 SP

✅ Tracking:
   - totalSkillPoints: int (earned)
   - spentSkillPoints: int
   - availableSkillPoints: int (total - spent)
```

#### AC3: Skill Upgrade Flow
```
✅ Upgrade requirements:
   - Have ≥1 available SP
   - Skill not at max level (10)

✅ UpgradeSkillUseCase:
   - upgrade(skillType) → Result<SkillTree>
   - Deducts 1 SP
   - Increases skill level by 1
   - Recalculates bonuses
```

#### AC4: Skill UI Panel
```
✅ Skill panel layout:
   - Header: "SKILLS" + "SP: X available"
   - 5 rows (one per skill)
   - Each row: Icon, Name, Level, Progress bar, Bonus %
   - Upgrade button (disabled if no SP or max level)

✅ Interactions:
   - Tap upgrade: Confirm dialog
   - Tap skill row: Show details (bonus breakdown)
```

#### AC5: Bonus Application
```dart
✅ CalculateSkillBonusUseCase:
   - getMiningBonus() → timeMultiplier
   - getSmeltingBonus() → yieldMultiplier
   - getTradingBonus() → priceMultiplier
   - getCraftingBonus() → costMultiplier
   - getAutomationBonus() → speedMultiplier

✅ Integration:
   - Production cycles use mining/smelting
   - NPC trades use trading bonus
   - Crafting uses crafting bonus
   - Conveyors use automation bonus (EPIC-03)
```

#### AC6: Skill Reset (Optional)
```
✅ Reset feature:
   - Cost: 100 gold
   - Refunds all spent SP
   - Confirmation dialog
   - Analytics: 'skills_reset' event
```

#### AC7: Unit Tests Pass
```
✅ Test: SP earned on 50 gold milestone
✅ Test: SP earned on achievement unlock
✅ Test: Upgrade increases level and deducts SP
✅ Test: Max level blocks further upgrades
✅ Test: Mining bonus reduces cycle time
✅ Test: Trading bonus increases prices
✅ Test: Reset refunds all SP
```

### Implementation Notes

**Files to Create:**
- `lib/domain/entities/skill_tree.dart`
- `lib/domain/entities/skill_state.dart`
- `lib/domain/usecases/skills/upgrade_skill_usecase.dart`
- `lib/domain/usecases/skills/calculate_skill_bonus_usecase.dart`
- `lib/data/repositories/skill_repository_impl.dart`
- `lib/presentation/widgets/skill_tree_panel.dart`
- `lib/presentation/providers/skill_provider.dart`
- `test/domain/usecases/skills/` - Tests

**Bonus Calculation:**
```dart
double getMiningBonus(int level) {
  // Level 1: 0.95 (5% faster)
  // Level 10: 0.50 (50% faster)
  return 1.0 - (level * 0.05);
}
```

**Dependencies:**
- STORY-06.1 (Progression for SP earning)
- STORY-06.4 (Achievements for SP)
- EPIC-02 (Basic skills foundation)

**Blocks:**
- EPIC-03 (Automation skill for conveyors)

---

## STORY-06.6: Achievements Screen (3 SP)

### Objective
Implement dedicated achievements screen showing all achievements with unlock status.

### User Story
As a player, I want to see all my achievements so I can track what I've accomplished and what's left.

### Description
A scrollable screen showing all achievements in a grid or list. Unlocked achievements are highlighted with unlock date. Locked achievements show requirements.

### Acceptance Criteria

#### AC1: Screen Layout
```
✅ Structure:
   - Header: "Achievements" + "X/Y Unlocked"
   - Grid or list of achievement cards
   - Each card: Icon, Title, Description, Status

✅ Navigation:
   - Accessible from Settings or Hub
   - Back button returns
```

#### AC2: Achievement Cards
```
✅ Unlocked state:
   - Full color icon
   - Green border/background
   - "Unlocked: Dec 3, 2025" date
   - Checkmark badge

✅ Locked state:
   - Grayscale icon
   - Gray border/background
   - Requirements text
   - Lock icon
```

#### AC3: Progress Indicators
```
✅ For trackable achievements:
   - Progress bar (e.g., 7/10 buildings)
   - Percentage text
   - Updates in real-time
```

#### AC4: Unit Tests Pass
```
✅ Test: Screen shows all 7 achievements
✅ Test: Unlocked achievements highlighted
✅ Test: Locked achievements show requirements
✅ Test: Progress bars update correctly
```

### Implementation Notes

**Files to Create:**
- `lib/presentation/screens/achievements_screen.dart`
- `lib/presentation/widgets/achievement_card.dart`
- `test/presentation/screens/achievements_screen_test.dart`

**Dependencies:**
- STORY-06.4 (Achievement system)

**Blocks:**
- Nothing (view layer)

---

## Story Summary Table

| Story | SP | Focus | Dependencies |
|-------|----|----|------|
| **STORY-06.1** | 5 | Tier 2 Requirements | EPIC-01, EPIC-02 |
| **STORY-06.2** | 4 | Progression Tracker UI | 06.1 |
| **STORY-06.3** | 5 | Unlock Celebration | 06.1 |
| **STORY-06.4** | 5 | Achievement System | 06.1 |
| **STORY-06.5** | 6 | Extended Skill System | 06.1, 06.4 |
| **STORY-06.6** | 3 | Achievements Screen | 06.4 |
| **TOTAL** | **28 SP** | Progression & Quality | - |

---

## Implementation Order

**Recommended Sprint 9:**

**Week 1:** Core Systems
1. STORY-06.1: Tier 2 Requirements (5 SP)
2. STORY-06.2: Progression Tracker UI (4 SP)
3. STORY-06.4: Achievement System (5 SP)

**Week 2:** Features & Polish
4. STORY-06.3: Unlock Celebration (5 SP)
5. STORY-06.5: Extended Skill System (6 SP)
6. STORY-06.6: Achievements Screen (3 SP)

---

## Success Metrics

**After EPIC-06 Complete:**
- ✅ 60%+ players unlock Tier 2 within 2-3 hours
- ✅ Progression tracker visible 100% of gameplay
- ✅ 90%+ watch full celebration animation
- ✅ 7 achievements trackable
- ✅ 5 skill trees functional
- ✅ 60 FPS on all animations
- ✅ 100% test coverage for progression logic

**When EPIC-06 Complete:**
- Overall Progress: ~64% (181/289 SP)
- Player retention hooks in place
- Clear progression path for users
- Ready for Tier 2 content (EPIC-03)

---

**Document Status:** 📋 Ready for Development
**Last Updated:** 2025-12-03
**Version:** 1.0
**Next Review:** After STORY-06.1 complete
