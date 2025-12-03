# Epic 4: Offline Production - Detailed Stories

<!-- AI-INDEX: epic, stories, acceptance-criteria, offline, retention -->

**Epic:** EPIC-04 - Offline Production
**Total SP:** 26
**Duration:** 2 weeks (Sprints 4-5)
**Status:** 📋 Ready for Implementation
**Tech-Spec:** [epic-04-tech-spec.md](epic-04-tech-spec.md)

**Prerequisites:**
- ✅ EPIC-01 (Core Gameplay Loop)
- ✅ EPIC-02 (Farm building, resources, skills)
- ✅ EPIC-03 (Conveyor chains for Tier 2 calculation)

---

## STORY-04.1: Offline Production Calculator (6 SP)

### Objective
Implement the core offline production calculation system with 80% efficiency for Farm buildings.

### User Story
As a player, I want my Farm to continue producing gold while I'm away so I feel rewarded when I return to the game.

### Description
The offline production system calculates resources earned during player absence. Farm operates at 80% efficiency offline to encourage active play while still rewarding returning players.

### Acceptance Criteria

#### AC1: Offline Calculation Formula
```dart
✅ OfflineCalculator class:
   - calculateOfflineRewards(lastLogout, returnTime, farmState)
   - Returns: OfflineRewards (gold, itemsProcessed, xpEarned)

✅ Formula implementation:
   offlineTimeSeconds = returnTime - lastLogoutTime
   itemsProcessed = MIN(
     farmQueue.length,
     (offlineTimeSeconds / cycleTime) * 0.80
   )
   goldEarned = itemsProcessed * baseValue * (1.0 + tradingSkillBonus)
```

#### AC2: 80% Efficiency Rule
```
✅ Efficiency applied correctly:
   - Online production: 100%
   - Offline production: 80%
   - Example: 100 possible cycles → 80 actual

✅ Rationale documented:
   - Encourages active play
   - Still rewards returning players
   - Balance between retention and engagement
```

#### AC3: Queue Processing
```
✅ Input buffer handling:
   - Process items in FIFO order
   - Stop when queue empty
   - Cap by actual queue length (can't create items)

✅ Resource tracking:
   - Track each resource type separately
   - Apply correct baseValue per resource
   - Sum total gold earned

✅ Example:
   Queue: 50 Węgiel (1g), 30 Ruda (1g)
   Offline: 2 hours, cycle: 3s
   Max items: (7200/3) * 0.8 = 1920
   Actual: MIN(1920, 80) = 80 items
   Gold: 50*1 + 30*1 = 80g
```

#### AC4: Skill Bonus Integration
```
✅ Trading skill applies:
   - Lvl 1: 1.0x multiplier
   - Lvl 5: 1.25x multiplier (+25%)
   - Lvl 10: 1.5x multiplier (+50%)

✅ Calculation:
   baseGold * (1.0 + tradingSkillBonus)
   Example: 80g * 1.15 = 92g (Skill Lvl 3)
```

#### AC5: Time Caps
```
✅ Maximum offline time:
   - Tier 1 (Farm only): 12 hours max
   - Tier 2 (with conveyors): 24 hours max

✅ Overflow handling:
   - Time > cap: Use cap value
   - No penalty, just capped
   - Display actual vs capped time
```

#### AC6: Unit Tests Pass
```
✅ Test: Basic calculation with 50 items, 2h offline
✅ Test: 80% efficiency applied correctly
✅ Test: Queue cap limits items processed
✅ Test: Trading skill bonus applies
✅ Test: 12h cap enforced for Tier 1
✅ Test: Empty queue returns 0 rewards
✅ Test: Mixed resource types calculated correctly
✅ Test: XP earned matches items processed
```

### Implementation Notes

**Files to Create:**
- `lib/domain/entities/offline_rewards.dart` - Reward data class
- `lib/domain/usecases/calculate_offline_rewards_usecase.dart` - Calculator
- `test/domain/usecases/calculate_offline_rewards_usecase_test.dart` - Tests

**Key Constants:**
```dart
const OFFLINE_EFFICIENCY = 0.80;
const TIER1_MAX_OFFLINE_HOURS = 12;
const TIER2_MAX_OFFLINE_HOURS = 24;
```

**Dependencies:**
- EPIC-02 Farm building & Trading skill
- EPIC-02 Resource base values

**Blocks:**
- STORY-04.2 (Tier 2 extends this)
- STORY-04.3 (Welcome modal displays results)

---

## STORY-04.2: Tier 2 Offline (Conveyor Chains) (6 SP)

### Objective
Extend offline calculation to handle complete conveyor automation chains.

### User Story
As a player with automation, I want my entire production chain to work offline so my investment in conveyors pays off even when I'm away.

### Description
Tier 2 offline production simulates entire conveyor networks: Mining → Smelter → Workshop → Farm. Uses topological sort to process buildings in correct dependency order.

### Acceptance Criteria

#### AC1: Dependency Graph Builder
```dart
✅ BuildDependencyGraph class:
   - buildGraph(conveyorNetwork) → DirectedGraph
   - Nodes: All buildings with production
   - Edges: Conveyor connections (source → dest)

✅ Graph properties:
   - Detects cycles (warn, process anyway)
   - Handles multiple inputs per building
   - Handles multiple outputs per building
```

#### AC2: Topological Sort
```
✅ Kahn's algorithm implementation:
   - Sort buildings by dependency order
   - Process sources first (Mining)
   - Then intermediate (Smelter, Workshop)
   - Finally sinks (Farm)

✅ Example order:
   Mining A → Mining B → Smelter → Workshop → Farm
   (sources processed first, then dependents)
```

#### AC3: Chain Simulation
```
✅ For each building in order:
   1. Calculate production capacity (time * rate * 0.8)
   2. Check input availability
   3. Process MIN(capacity, inputs)
   4. Add outputs to next building's input
   5. Respect storage limits

✅ Bottleneck handling:
   - If input < capacity: Limited by input
   - If storage full: Limited by storage
   - Track unused capacity
```

#### AC4: Example Chain Calculation
```
Chain: Mining → Smelter → Workshop → Farm
Offline: 2 hours

1. Mining: 2h * 60 items/h * 0.8 = 96 ore
   (capped at storage 100, produces 96)

2. Smelter: 96 ore / 30 per bar * 0.8 = 2.56 bars → 2 bars
   (floor, partial bars don't count)

3. Workshop: 2 bars / 10 per tool * 0.8 = 0.16 tools → 0 tools
   (not enough for full tool)

4. Farm: Process residual items in queue
   (add 2 bars to farm queue if not Workshop input)

Total gold: Farm queue processing only
```

#### AC5: 24h Extended Cap
```
✅ Tier 2 cap:
   - With any conveyor: 24 hours max
   - Rewards automation investment
   - Still prevents infinite production

✅ Detection:
   - Check if player has ≥1 conveyor
   - Apply extended cap automatically
```

#### AC6: Unit Tests Pass
```
✅ Test: Simple 2-building chain
✅ Test: Full 4-building chain
✅ Test: Bottleneck at smelter (input limited)
✅ Test: Bottleneck at storage (capacity limited)
✅ Test: Topological sort correct order
✅ Test: Cycle detection doesn't crash
✅ Test: 24h cap for Tier 2
✅ Test: Partial production floors correctly
```

### Implementation Notes

**Files to Create:**
- `lib/domain/entities/production_chain.dart` - Chain definition
- `lib/domain/usecases/simulate_chain_offline_usecase.dart` - Simulation
- `lib/domain/algorithms/topological_sort.dart` - Kahn's algorithm
- `test/domain/usecases/simulate_chain_offline_usecase_test.dart` - Tests

**Algorithm Pseudocode:**
```dart
List<Building> topologicalSort(Graph g) {
  final inDegree = computeInDegrees(g);
  final queue = buildings.where((b) => inDegree[b] == 0);
  final result = <Building>[];

  while (queue.isNotEmpty) {
    final current = queue.removeFirst();
    result.add(current);
    for (final neighbor in g.neighbors(current)) {
      inDegree[neighbor]--;
      if (inDegree[neighbor] == 0) queue.add(neighbor);
    }
  }
  return result;
}
```

**Dependencies:**
- STORY-04.1 (Base calculation)
- EPIC-03 Conveyor network

**Blocks:**
- STORY-04.3 (Display chain results)

---

## STORY-04.3: Welcome-Back Modal UI (5 SP)

### Objective
Implement the welcome-back notification screen that displays offline earnings with animations.

### User Story
As a player returning to the game, I want to see an exciting summary of what I earned offline so I feel motivated to continue playing.

### Description
The welcome-back modal creates a satisfying "reveal" moment showing offline production. Gold counter animates, coins fall, and players can optionally watch an ad to double rewards.

### Acceptance Criteria

#### AC1: Modal Trigger
```
✅ Show modal when:
   - App launches after offline
   - Offline time ≥ 5 minutes
   - Offline rewards > 0

✅ Don't show modal when:
   - First launch (no lastLogout)
   - Offline < 5 minutes
   - No production (empty queue)
```

#### AC2: Modal Layout
```
✅ Header section:
   - "Welcome Back!" title (large, centered)
   - "Away for: Xh Ym" subtitle
   - Sparkle/star animation around title

✅ Earnings section:
   - Gold counter (animated 0 → total)
   - Items processed count
   - XP earned

✅ Breakdown (expandable):
   - Per-resource breakdown
   - Skill bonus applied
   - Each building's contribution

✅ Action buttons:
   - [Watch Ad for 2×] - Primary, highlighted
   - [Collect] - Secondary
   - [Show Breakdown] - Tertiary/link
```

#### AC3: Gold Animation
```
✅ Counter animation:
   - Duration: 2 seconds
   - Easing: easeOutCubic
   - Counts from 0 to total
   - Thousand separators (1,234)

✅ Coin rain effect:
   - Gold coins fall from top
   - Accumulate at bottom
   - Random x positions
   - 10-20 coins

✅ Sound effects:
   - Coin clink (each coin)
   - Counter tick (rapid)
   - Complete fanfare (at end)
```

#### AC4: Breakdown View
```
✅ Expandable section:
   - Tap "Show Breakdown" to expand
   - Smooth animation (300ms)

✅ Content:
   ├─ Farm Production:
   │   ├─ Węgiel (50): 50g
   │   ├─ Ruda Żelaza (30): 30g
   │   └─ Subtotal: 80g
   ├─ Trading Skill (+15%): +12g
   └─ TOTAL: 92g

✅ If Tier 2:
   - Show chain contribution
   - Mining: X ore produced
   - Smelter: X bars produced
   - etc.
```

#### AC5: Responsive Design
```
✅ Mobile layout:
   - Full-screen modal
   - Touch-friendly buttons (48dp min)
   - Scrollable if content long

✅ Tablet layout:
   - Centered card (max 400px wide)
   - Larger animations
```

#### AC6: Unit Tests Pass
```
✅ Test: Modal shows for offline ≥ 5 min
✅ Test: Modal hidden for offline < 5 min
✅ Test: Gold counter animates correctly
✅ Test: Breakdown expands/collapses
✅ Test: Ad button visible and functional
✅ Test: Collect button closes modal
✅ Test: Offline data cleared after collect
```

### Implementation Notes

**Files to Create:**
- `lib/presentation/screens/welcome_back_modal.dart` - Modal screen
- `lib/presentation/widgets/gold_counter.dart` - Animated counter
- `lib/presentation/widgets/coin_rain.dart` - Particle effect
- `lib/presentation/widgets/earnings_breakdown.dart` - Expandable list
- `test/presentation/welcome_back_modal_test.dart` - Tests

**Animation Code:**
```dart
// Gold counter
AnimatedBuilder(
  animation: _controller,
  builder: (_, __) => Text(
    '${(_controller.value * totalGold).toInt()}g',
    style: goldTextStyle,
  ),
);
```

**Dependencies:**
- STORY-04.1 (Calculation results)
- STORY-04.2 (Chain results for Tier 2)

**Blocks:**
- STORY-04.4 (Ad button integration)

---

## STORY-04.4: Rewarded Video Ad Integration (4 SP)

### Objective
Integrate Google AdMob rewarded video ads for the 2× offline boost.

### User Story
As a player, I want to watch an optional ad to double my offline rewards so I can progress faster.

### Description
The 2× boost is a key monetization and engagement feature. Players can watch a 30-second video ad to double their offline production rewards.

### Acceptance Criteria

#### AC1: AdMob Integration
```dart
✅ AdMob SDK setup:
   - google_mobile_ads package
   - App ID configured
   - Rewarded video ad unit ID
   - Test mode for development

✅ Ad loading:
   - Pre-load ad on app start
   - Load new ad after each use
   - Handle load failures gracefully
```

#### AC2: Ad Flow
```
✅ User taps "Watch Ad for 2×":
   1. Show loading indicator
   2. Display 30-second video
   3. On complete: Apply 2× multiplier
   4. On dismiss: Award 1× (no penalty)
   5. On error: Award 1×, log error

✅ Cooldown:
   - One ad per offline session
   - Button disabled after watching
   - Shows "2× Applied!" badge
```

#### AC3: Reward Application
```dart
✅ Double rewards:
   offlineRewards.gold *= 2;
   offlineRewards.xp *= 2;
   // Items processed stays same (already consumed)

✅ Display update:
   - Counter animates to new total
   - "2× BONUS!" banner appears
   - Confetti effect
```

#### AC4: Error Handling
```
✅ No ad available:
   - Show toast: "Ad not available"
   - Award 1× rewards
   - Log: ad_not_available

✅ Network error:
   - Show toast: "Network error"
   - Award 1× rewards
   - Log: ad_network_error

✅ User cancelled:
   - Award 1× rewards
   - Log: ad_cancelled
   - No penalty message
```

#### AC5: Analytics Events
```
✅ Track events:
   - ad_offered (every modal show)
   - ad_watch_started
   - ad_watch_completed
   - ad_watch_cancelled
   - ad_watch_error
   - ad_not_available

✅ Metrics:
   - Calculate ad adoption rate
   - Track revenue per ad
```

#### AC6: Unit Tests Pass
```
✅ Test: Ad button shows when ad available
✅ Test: Ad button hidden when ad not loaded
✅ Test: Rewards doubled on ad complete
✅ Test: Rewards 1× on ad cancelled
✅ Test: Cooldown prevents second ad
✅ Test: Analytics events fired correctly
```

### Implementation Notes

**Files to Create:**
- `lib/data/services/admob_service.dart` - AdMob wrapper
- `lib/domain/usecases/apply_ad_boost_usecase.dart` - Boost logic
- `test/domain/usecases/apply_ad_boost_usecase_test.dart` - Tests

**AdMob Setup:**
```yaml
# pubspec.yaml
dependencies:
  google_mobile_ads: ^3.0.0
```

```dart
// Initialize in main.dart
await MobileAds.instance.initialize();
```

**Dependencies:**
- STORY-04.3 (Modal UI)
- AdMob account setup

**Blocks:**
- EPIC-08 (Monetization strategy)

---

## STORY-04.5: Time Validation & Anti-Cheat (3 SP)

### Objective
Implement server timestamp validation to prevent time manipulation cheats.

### User Story
As a game developer, I need to validate offline time against server time so players can't cheat by changing their device clock.

### Description
Time validation compares device time against Firebase server time. Large discrepancies indicate potential cheating and result in reduced or zero rewards.

### Acceptance Criteria

#### AC1: Server Time Fetch
```dart
✅ Firebase timestamp:
   - Use Firebase serverTimestamp()
   - Fallback to NTP server if Firebase fails
   - Cache last known server time

✅ Implementation:
   Future<DateTime> getServerTime() async {
     final ref = FirebaseDatabase.instance.ref('.info/serverTimeOffset');
     final offset = await ref.get();
     return DateTime.now().add(Duration(milliseconds: offset.value));
   }
```

#### AC2: Drift Detection
```
✅ Calculate drift:
   drift = abs(deviceTime - serverTime)

✅ Thresholds:
   - drift < 1 minute: Normal, award full
   - drift 1-5 minutes: Warning, award full
   - drift > 5 minutes: Suspicious, award 0

✅ Logging:
   - Log all drift > 1 minute
   - Include device info
   - Track patterns for analysis
```

#### AC3: Edge Case Handling
```
✅ Device time backward:
   - offlineTime = 0 (can't go back in time)
   - Log as suspicious

✅ Very long offline (>30 days):
   - Cap at 30 days maximum
   - Prevent database overflow
   - Log for analysis

✅ Network unavailable:
   - Use cached server time
   - Add warning flag
   - Still award rewards (benefit of doubt)
```

#### AC4: Cheat Response
```
✅ On detected cheat:
   - Award 0 rewards
   - Show generic message (don't reveal detection)
   - Log event with details
   - Don't ban (soft response)

✅ Message:
   "Unable to calculate offline rewards."
   "Please check your device time settings."
```

#### AC5: Unit Tests Pass
```
✅ Test: Normal drift (<1 min) awards full
✅ Test: Suspicious drift (>5 min) awards 0
✅ Test: Backward time awards 0
✅ Test: >30 days capped at 30
✅ Test: Network error uses cache
✅ Test: Logging captures all events
```

### Implementation Notes

**Files to Create:**
- `lib/data/services/time_validation_service.dart` - Validator
- `lib/domain/usecases/validate_offline_time_usecase.dart` - Logic
- `test/domain/usecases/validate_offline_time_usecase_test.dart` - Tests

**Security Note:**
```dart
// Don't reveal detection method
// Generic error message
// Log details server-side only
```

**Dependencies:**
- Firebase Realtime Database (for server time)
- STORY-04.1 (Calculation uses validated time)

**Blocks:**
- Nothing (security layer)

---

## STORY-04.6: Integration Testing & Persistence (2 SP)

### Objective
Validate complete offline flow works end-to-end and data persists correctly.

### User Story
As a developer, I need to verify the entire offline system works from logout to login so players have a reliable experience.

### Description
This story tests the complete flow: app close → time passes → app open → calculate → display → collect. Also verifies Hive persistence.

### Acceptance Criteria

#### AC1: Full Flow Test
```
✅ Complete flow:
   1. Player has Farm with 50 items queued
   2. App closes (lastLogout saved)
   3. 2 hours pass (simulated)
   4. App opens
   5. Time validated
   6. Rewards calculated
   7. Modal displays
   8. Player collects
   9. Gold added to economy
   10. Queue updated
```

#### AC2: Data Persistence
```
✅ Hive storage:
   - lastLogoutTime persists
   - farmQueueAtLogout persists
   - App survives force close
   - Data loads on cold start

✅ Edge cases:
   - First install (no data)
   - Corrupted data (reset gracefully)
   - Migration (version upgrade)
```

#### AC3: State Updates
```
✅ After collect:
   - PlayerEconomy.gold increased
   - Farm.inputBuffer reduced
   - XP added to player
   - lastLogoutTime cleared
   - Modal won't show again

✅ If ad watched:
   - 2× applied before adding
   - adWatchedThisSession = true
```

#### AC4: Performance
```
✅ Calculation time:
   - Tier 1: <20ms
   - Tier 2 (20 buildings): <50ms
   - Tier 2 (50 conveyors): <100ms

✅ Modal render:
   - First frame: <100ms
   - Animation smooth: 60 FPS
```

#### AC5: Integration Tests Pass
```
✅ Test: Logout → 2h → Login flow complete
✅ Test: Data persists across app restart
✅ Test: Corrupted data handled gracefully
✅ Test: Gold added to economy correctly
✅ Test: Queue reduced after processing
✅ Test: Modal shows once per session
✅ Test: Ad boost persists through collect
✅ Test: Performance under 100ms
```

### Implementation Notes

**Files to Create:**
- `integration_test/offline_flow_test.dart` - Full flow
- `integration_test/persistence_test.dart` - Hive tests
- `lib/data/repositories/offline_repository.dart` - Data access

**Test Setup:**
```dart
// Simulate time passage
Future<void> simulateOffline(Duration duration) async {
  final box = Hive.box('offlineData');
  final current = box.get('lastSession');
  current.lastLogoutTime = DateTime.now().subtract(duration);
  await box.put('lastSession', current);
}
```

**Dependencies:**
- All STORY-04.x complete
- Hive setup

**Blocks:**
- Epic sign-off

---

## Story Summary Table

| Story | SP | Focus | Dependencies |
|-------|----|----|------|
| **STORY-04.1** | 6 | Offline Calculator | EPIC-02 |
| **STORY-04.2** | 6 | Tier 2 Chain Simulation | 04.1, EPIC-03 |
| **STORY-04.3** | 5 | Welcome-Back Modal | 04.1, 04.2 |
| **STORY-04.4** | 4 | Ad Integration | 04.3 |
| **STORY-04.5** | 3 | Time Validation | 04.1 |
| **STORY-04.6** | 2 | Integration & Persistence | 04.1-04.5 |
| **TOTAL** | **26 SP** | Offline Production | - |

---

## Implementation Order

**Recommended Sprint 4-5:**

**Week 1:** Core System
1. STORY-04.1: Offline Calculator (6 SP)
2. STORY-04.5: Time Validation (3 SP)
3. STORY-04.2: Tier 2 Chain Simulation (6 SP)

**Week 2:** UI & Integration
4. STORY-04.3: Welcome-Back Modal (5 SP)
5. STORY-04.4: Ad Integration (4 SP)
6. STORY-04.6: Integration Testing (2 SP)

---

## Success Metrics

**After EPIC-04 Complete:**
- ✅ 80% efficiency calculation correct
- ✅ Tier 2 chain simulation accurate
- ✅ Welcome-back modal engaging
- ✅ Ad boost works with 60%+ adoption
- ✅ Time validation prevents cheats
- ✅ Full flow works end-to-end

**Business Metrics:**
- D1 Retention: +15% expected
- D7 Retention: +10% expected
- Ad adoption: 60%+ target

**When EPIC-04 Complete:**
- Overall Progress: ~39% (141/289 SP)
- Ready to start: EPIC-05 (Mobile UX) or EPIC-08 (Monetization)
- Retention hooks in place
- Monetization foundation ready

---

**Document Status:** 📋 Ready for Development
**Last Updated:** 2025-12-03
**Version:** 1.0
**Next Review:** After STORY-04.1 complete
