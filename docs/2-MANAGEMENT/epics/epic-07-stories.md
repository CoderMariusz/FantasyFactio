# Epic 7: Discovery Tutorial - Detailed Stories

<!-- AI-INDEX: epic, stories, acceptance-criteria, tutorial, onboarding -->

**Epic:** EPIC-07 - Discovery Tutorial
**Total Stories:** 5
**Total SP:** 21
**Sprint:** 10 (post-MVP, after EPIC-06)
**Status:** 📋 Ready for Implementation
**Tech-Spec:** [epic-07-tech-spec.md](epic-07-tech-spec.md)

**Prerequisites:**
- ✅ EPIC-01 (Building placement)
- ✅ EPIC-02 (Resource collection, market)
- ⚠️ EPIC-06 (Progression tracker for Tier 2 step)

**Design Philosophy:** "Show don't tell" - gracze uczą się przez działanie.

---

## Story Overview

| Story ID | Title | SP | Priority | Implementation Status |
|----------|-------|-----|----------|----------------------|
| STORY-07.1 | Tutorial State Machine | 5 | P0 | 📋 Ready |
| STORY-07.2 | Tooltip System | 5 | P0 | 📋 Ready |
| STORY-07.3 | First-Time User Experience (FTUE) | 5 | P0 | 📋 Ready |
| STORY-07.4 | Tutorial Analytics Tracking | 3 | P1 | 📋 Ready |
| STORY-07.5 | Skip Tutorial Option | 3 | P1 | 📋 Ready |

---

## STORY-07.1: Tutorial State Machine (5 SP)

### Objective
Implement state machine for tutorial progression with event-driven transitions.

### User Story
As a developer, I want a state machine for tutorial progression so the tutorial adapts to player actions.

### Description
The tutorial state machine tracks which step the player is on and transitions based on game events. State persists across sessions so players don't repeat completed steps.

### Acceptance Criteria

#### AC1: TutorialState Enum
```dart
✅ TutorialState enum:
   - welcome: Initial state, show welcome screen
   - firstBuilding: Prompt to place building
   - firstCollect: Prompt to collect resources
   - firstUpgrade: Prompt to upgrade building
   - openMarket: Prompt to visit market
   - tier2Unlock: Encourage progress to Tier 2
   - complete: Tutorial finished
```

#### AC2: TutorialManager Service
```dart
✅ TutorialManager class:
   - currentState: TutorialState
   - onEvent(GameEvent): Trigger transitions
   - skipTutorial(): Jump to complete
   - resetTutorial(): Start over (dev only)

✅ State transitions:
   - welcome → firstBuilding: On "Start" button
   - firstBuilding → firstCollect: On BuildingPlacedEvent
   - firstCollect → firstUpgrade: On ResourceCollectedEvent
   - firstUpgrade → openMarket: On BuildingUpgradedEvent
   - openMarket → tier2Unlock: On MarketOpenedEvent
   - tier2Unlock → complete: On Tier2UnlockedEvent
```

#### AC3: Event Listeners
```dart
✅ Listen to game events:
   - BuildingPlacedEvent
   - ResourceCollectedEvent
   - BuildingUpgradedEvent
   - MarketOpenedEvent
   - Tier2UnlockedEvent

✅ Integration:
   - Subscribe in game initialization
   - Unsubscribe when tutorial complete
```

#### AC4: Persistence
```
✅ Hive storage:
   - Save currentState on each transition
   - Load on app start
   - Survive app restart/reinstall

✅ TutorialRepository:
   - getTutorialState() → TutorialState
   - saveTutorialState(state)
   - isComplete() → bool
```

#### AC5: Unit Tests Pass
```
✅ Test: Initial state is 'welcome'
✅ Test: BuildingPlacedEvent transitions to 'firstCollect'
✅ Test: Skip jumps to 'complete'
✅ Test: State persists to Hive
✅ Test: Completed tutorial doesn't show again
✅ Test: All 7 transitions work correctly
```

### Implementation Notes

**Files to Create:**
- `lib/domain/entities/tutorial_state.dart` - Enum
- `lib/domain/services/tutorial_manager.dart` - State machine
- `lib/domain/repositories/tutorial_repository.dart` - Interface
- `lib/data/repositories/tutorial_repository_impl.dart` - Hive impl
- `test/domain/services/tutorial_manager_test.dart` - Tests

**Event Integration:**
```dart
// In game initialization
eventBus.on<BuildingPlacedEvent>().listen((event) {
  tutorialManager.onEvent(event);
});
```

**Dependencies:**
- Hive (EPIC-00)
- Event bus pattern

**Blocks:**
- STORY-07.2 (Tooltips need state)
- STORY-07.3 (FTUE needs state)

---

## STORY-07.2: Tooltip System (5 SP)

### Objective
Implement contextual tooltips with arrows pointing at target elements.

### User Story
As a player, I want helpful tooltips guiding me so I learn mechanics naturally.

### Description
Each tutorial step shows a tooltip with helpful text and an arrow pointing at the relevant UI element. Tooltips auto-dismiss after action or timeout.

### Acceptance Criteria

#### AC1: Tooltip Widget
```dart
✅ TutorialTooltip widget:
   - title: String (e.g., "Tap to collect!")
   - description: String (e.g., "+10 Wood is ready")
   - targetPosition: Offset (where arrow points)
   - arrowDirection: Direction (up/down/left/right)
   - onDismiss: VoidCallback

✅ Visual design:
   - Dark background (#1E1E1E, 90% opacity)
   - White text (14sp body, 16sp title)
   - Rounded corners (12px)
   - Arrow triangle (12px)
```

#### AC2: Arrow Positioning
```
✅ Arrow calculates position:
   - Points at target element center
   - Tooltip stays on screen (no overflow)
   - Arrow direction auto-adjusts

✅ Positions:
   - Above target: Arrow points down
   - Below target: Arrow points up
   - Left of target: Arrow points right
   - Right of target: Arrow points left
```

#### AC3: Seven Tooltips Content
```
✅ Tooltip definitions:
   1. firstBuilding: "Tap the grid to place your first building"
   2. firstCollect: "Tap the building to collect resources"
   3. firstUpgrade: "Great! Now tap Upgrade to improve it"
   4. openMarket: "Visit the Market to trade resources"
   5. tier2Unlock: "Keep building to unlock automation!"
   6. complete: "Tutorial complete! Enjoy the game!"

✅ Each tooltip has:
   - Target element reference
   - Text content
   - Auto-dismiss condition
```

#### AC4: Auto-Dismiss Behavior
```
✅ Dismissal triggers:
   - Player completes action (state advances)
   - 10 seconds timeout
   - Tap on tooltip
   - Tap "Skip Tutorial" button

✅ Animations:
   - Fade in (200ms)
   - Fade out (150ms)
```

#### AC5: Skip Tutorial Button
```
✅ Skip button:
   - Appears on all tooltips
   - Text: "Skip Tutorial"
   - Style: Text button, subtle
   - Action: Call tutorialManager.skipTutorial()
```

#### AC6: Unit Tests Pass
```
✅ Test: Tooltip renders with correct text
✅ Test: Arrow points in correct direction
✅ Test: Auto-dismiss after 10 seconds
✅ Test: Skip button calls skipTutorial()
✅ Test: Tooltip stays on screen (no overflow)
```

### Implementation Notes

**Files to Create:**
- `lib/presentation/widgets/tutorial_tooltip.dart` - Widget
- `lib/presentation/widgets/tooltip_arrow.dart` - Arrow painter
- `lib/domain/entities/tutorial_step.dart` - Step definition
- `test/presentation/widgets/tutorial_tooltip_test.dart` - Tests

**Arrow CustomPainter:**
```dart
class TooltipArrow extends CustomPainter {
  final Direction direction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    // Draw triangle based on direction
    canvas.drawPath(path, Paint()..color = color);
  }
}
```

**Dependencies:**
- STORY-07.1 (State machine)

**Blocks:**
- STORY-07.3 (FTUE uses tooltips)

---

## STORY-07.3: First-Time User Experience (FTUE) (5 SP)

### Objective
Implement complete first-time user flow with welcome screen and guided first actions.

### User Story
As a new player, I want a gentle introduction to the game so I don't feel overwhelmed.

### Description
The FTUE guides new players through their first game loop: placing a building, collecting resources, and understanding the core mechanics. Duration: 3-5 minutes.

### Acceptance Criteria

#### AC1: Welcome Screen
```
✅ Welcome modal:
   - Title: "Welcome to Trade Factory Masters!"
   - Subtitle: "Build your industrial empire"
   - 4 bullet points explaining game
   - "Start Building" primary button
   - "Skip Tutorial" secondary link

✅ Shown when:
   - First app launch
   - Tutorial state is 'welcome'
```

#### AC2: First Building Placement
```
✅ Guided placement:
   - Tooltip: "Tap the grid to place your first building"
   - Highlight suggested location (10, 10)
   - Auto-select Lumbermill in build menu
   - Success feedback on placement

✅ Optional auto-place:
   - If player doesn't act in 30 seconds
   - Place building automatically
   - Show "I placed a building for you!"
```

#### AC3: First Resource Collection
```
✅ Collection guidance:
   - Wait for resource to be ready (~5 seconds)
   - Tooltip: "Tap to collect! +10 Wood ready"
   - Arrow points at building
   - Celebrate on collection

✅ Feedback:
   - "+10 Wood" floating text
   - Light haptic
   - Inventory counter animates
```

#### AC4: First Upgrade
```
✅ Upgrade guidance:
   - Tooltip: "Upgrade your building for more resources!"
   - Arrow points at upgrade button
   - Show cost and benefit

✅ Completion:
   - "Great job! Your building is now Level 2"
   - Progress to next step
```

#### AC5: Market Introduction
```
✅ Market step:
   - Tooltip: "Visit the Market to trade with NPCs"
   - Arrow points at Market button
   - Brief market tour on open

✅ Tour content:
   - "This is the market. Trade resources for gold!"
   - Highlight one NPC
```

#### AC6: Duration Target
```
✅ Timing:
   - Welcome: 15 seconds
   - First building: 30 seconds
   - First collect: 30 seconds
   - First upgrade: 30 seconds
   - Market: 45 seconds
   - TOTAL: 2.5-4 minutes

✅ Pacing:
   - Don't rush player
   - Wait for action before advancing
   - Timeout auto-advances if stuck
```

#### AC7: Unit Tests Pass
```
✅ Test: Welcome screen shows on first launch
✅ Test: Building placement advances tutorial
✅ Test: Collection shows correct feedback
✅ Test: Upgrade completes correctly
✅ Test: Market tour shows
✅ Test: Total flow takes 3-5 minutes
```

### Implementation Notes

**Files to Create:**
- `lib/presentation/screens/welcome_screen.dart` - Welcome modal
- `lib/presentation/widgets/ftue_overlay.dart` - Full overlay
- `lib/presentation/providers/ftue_provider.dart` - State
- `integration_test/ftue_flow_test.dart` - Flow test

**Auto-Place Logic:**
```dart
Timer? _autoPlaceTimer;

void startAutoPlaceTimer() {
  _autoPlaceTimer = Timer(Duration(seconds: 30), () {
    if (tutorialState == TutorialState.firstBuilding) {
      _autoPlaceBuilding();
      _showAutoPlaceMessage();
    }
  });
}
```

**Dependencies:**
- STORY-07.1 (State machine)
- STORY-07.2 (Tooltips)

**Blocks:**
- Nothing (complete FTUE)

---

## STORY-07.4: Tutorial Analytics Tracking (3 SP)

### Objective
Implement analytics events for tutorial funnel analysis.

### User Story
As a product manager, I want analytics on tutorial completion so I identify drop-off points.

### Description
Track every tutorial step with Firebase Analytics. Create funnel to see where players drop off and optimize those steps.

### Acceptance Criteria

#### AC1: Tutorial Events
```dart
✅ Events to log:
   - tutorial_started: When welcome shown
   - tutorial_step_completed: Each step done
   - tutorial_skipped: Skip button pressed
   - tutorial_completed: All steps finished

✅ Parameters:
   - step_name: String (e.g., "firstBuilding")
   - duration_seconds: int (time on step)
   - at_step: String (for skipped)
   - total_duration_seconds: int (for completed)
```

#### AC2: Firebase Analytics Integration
```dart
✅ Log events:
   FirebaseAnalytics.instance.logEvent(
     name: 'tutorial_step_completed',
     parameters: {
       'step_name': 'firstCollect',
       'duration_seconds': 25,
       'step_index': 2,
     },
   );
```

#### AC3: Funnel Analysis Setup
```
✅ Expected funnel (target):
   100% tutorial_started
    95% step: firstBuilding
    85% step: firstCollect
    75% step: firstUpgrade
    65% step: openMarket
    55% step: tier2Unlock
    50% tutorial_completed

✅ Firebase console:
   - Create funnel in Analytics
   - Set up dashboard
```

#### AC4: Drop-Off Alerts
```
✅ Monitoring:
   - Alert if any step < 60% completion
   - Track daily/weekly trends
   - Compare cohorts

✅ Dashboard metrics:
   - Completion rate per step
   - Average time per step
   - Skip rate
```

#### AC5: Unit Tests Pass
```
✅ Test: tutorial_started logged on welcome
✅ Test: step_completed logged with correct params
✅ Test: skipped logged with at_step
✅ Test: completed logged with duration
```

### Implementation Notes

**Files to Create:**
- `lib/data/services/tutorial_analytics_service.dart` - Analytics wrapper
- `test/data/services/tutorial_analytics_service_test.dart` - Tests

**Analytics Service:**
```dart
class TutorialAnalyticsService {
  static void logStepCompleted(TutorialState step, int durationSeconds) {
    FirebaseAnalytics.instance.logEvent(
      name: 'tutorial_step_completed',
      parameters: {
        'step_name': step.name,
        'duration_seconds': durationSeconds,
        'step_index': step.index,
      },
    );
  }

  static void logSkipped(TutorialState atStep, int totalTimeSeconds) {
    FirebaseAnalytics.instance.logEvent(
      name: 'tutorial_skipped',
      parameters: {
        'at_step': atStep.name,
        'time_in_tutorial': totalTimeSeconds,
      },
    );
  }
}
```

**Dependencies:**
- Firebase Analytics (EPIC-00)
- STORY-07.1 (State transitions)

**Blocks:**
- Nothing (analytics layer)

---

## STORY-07.5: Skip Tutorial Option (3 SP)

### Objective
Implement skip tutorial functionality for returning players and impatient users.

### User Story
As a returning player, I want to skip the tutorial on subsequent playthroughs so I'm not annoyed.

### Description
Players can skip the tutorial at any time. A confirmation dialog prevents accidental skips. Skipped state persists so tutorial doesn't show again.

### Acceptance Criteria

#### AC1: Skip Button Placement
```
✅ Skip button locations:
   - Welcome screen: "Skip Tutorial" link
   - All tooltips: Small skip button
   - Settings: "Reset Tutorial" option (for testing)

✅ Button styling:
   - Subtle, not prominent
   - Text: "Skip Tutorial" or "Skip"
   - Color: Gray/secondary
```

#### AC2: Skip Confirmation Dialog
```
✅ Confirmation modal:
   - Title: "Skip Tutorial?"
   - Message: "You can always replay it from Settings."
   - Buttons: "Cancel" | "Skip"

✅ No confirmation if:
   - Player is on last step (tier2Unlock)
   - Less than 30 seconds in tutorial (accidental)
```

#### AC3: Skip Action
```dart
✅ skipTutorial() method:
   - Set state to 'complete'
   - Save to Hive
   - Log analytics: tutorial_skipped
   - Dismiss all tooltips
   - Show brief "Tutorial skipped" toast
```

#### AC4: Reset Tutorial (Dev/Settings)
```
✅ Settings option:
   - "Replay Tutorial" button
   - Resets state to 'welcome'
   - Shows confirmation
   - Restarts FTUE flow
```

#### AC5: Unit Tests Pass
```
✅ Test: Skip button visible on tooltips
✅ Test: Confirmation dialog appears
✅ Test: Skip sets state to complete
✅ Test: Analytics logged on skip
✅ Test: Reset restarts tutorial
```

### Implementation Notes

**Files to Create:**
- `lib/presentation/widgets/skip_tutorial_button.dart` - Button
- `lib/presentation/widgets/skip_confirmation_dialog.dart` - Dialog
- `test/presentation/widgets/skip_tutorial_button_test.dart` - Tests

**Skip Logic:**
```dart
void showSkipConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Skip Tutorial?'),
      content: Text('You can always replay it from Settings.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            tutorialManager.skipTutorial();
            TutorialAnalyticsService.logSkipped(
              tutorialManager.currentState,
              _elapsedSeconds,
            );
            Navigator.pop(context);
          },
          child: Text('Skip'),
        ),
      ],
    ),
  );
}
```

**Dependencies:**
- STORY-07.1 (State machine)
- STORY-07.4 (Analytics)

**Blocks:**
- Nothing (feature complete)

---

## Story Summary Table

| Story | SP | Focus | Dependencies |
|-------|----|----|------|
| **STORY-07.1** | 5 | Tutorial State Machine | EPIC-00 |
| **STORY-07.2** | 5 | Tooltip System | 07.1 |
| **STORY-07.3** | 5 | First-Time User Experience | 07.1, 07.2 |
| **STORY-07.4** | 3 | Analytics Tracking | 07.1 |
| **STORY-07.5** | 3 | Skip Tutorial Option | 07.1, 07.4 |
| **TOTAL** | **21 SP** | Discovery Tutorial | - |

---

## Implementation Order

**Recommended Sprint 10:**

**Week 1:** Core System
1. STORY-07.1: Tutorial State Machine (5 SP)
2. STORY-07.2: Tooltip System (5 SP)
3. STORY-07.4: Analytics Tracking (3 SP)

**Week 2:** User Experience
4. STORY-07.3: First-Time User Experience (5 SP)
5. STORY-07.5: Skip Tutorial Option (3 SP)

---

## Success Metrics

**After EPIC-07 Complete:**
- ✅ 80%+ complete first 3 steps
- ✅ 50%+ complete full tutorial
- ✅ Tutorial duration: 3-5 minutes
- ✅ Skip rate: <30%
- ✅ 7 tooltips functional
- ✅ Analytics funnel visible

**When EPIC-07 Complete:**
- Overall Progress: ~71% (202/289 SP)
- Onboarding optimized
- New player retention improved
- Drop-off points identified

---

**Document Status:** 📋 Ready for Development
**Last Updated:** 2025-12-03
**Version:** 1.0
**Next Review:** After STORY-07.1 complete
