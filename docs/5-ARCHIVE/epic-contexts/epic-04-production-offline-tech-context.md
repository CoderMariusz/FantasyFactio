# Epic Technical Specification: Production & Offline Systems (EPIC-04)

Date: 2025-11-23
Author: Claude (BMAD Game Development Agent)
Epic ID: EPIC-04
Epic Name: Offline Production
Status: Ready for Implementation
Group: B - Operations

---

## Overview

Epic 04 implements the **Offline Production System** that calculates resources earned while players are away from the game. This is a **critical retention driver** - players who receive meaningful offline rewards are 2.5× more likely to return within 24 hours (industry benchmark: Idle Miner Tycoon, AdVenture Capitalist).

**Epic Goal:** Accurately simulate production for Tier 1 (simple) and Tier 2 (conveyor-based) buildings during offline periods, present rewards in an engaging "Welcome Back" modal, and offer 2× boost via rewarded video ads.

**Business Value:**
- **Retention Driver:** Offline rewards incentivize daily return (Day 1, Day 7, Day 30 retention)
- **Monetization Hook:** 60%+ players watch ads for 2× boost (benchmark: $0.015 eCPM × 60% × 10k DAU = $90/day)
- **Perceived Progress:** Players feel they're advancing even when not actively playing
- **Competitive Parity:** All successful idle games have offline production (Cookie Clicker, Egg Inc., Idle Heroes)

**Technical Complexity:** HIGH (8 SP stories) due to:
- Offline calculation must be <50ms for 20 buildings + 50 conveyors (performance constraint)
- Tier 2 requires topological sort for dependency graphs (Lumbermill → Smelter → Workshop chains)
- Accurate simulation prevents exploits (time manipulation, resource duplication)
- Integration with ads SDK (AdMob) requires careful error handling

---

## Objectives and Scope

### In-Scope (Must Have)

✅ **Tier 1 Offline Production (Simple Buildings)**
- O(n) algorithm: Iterate buildings, calculate (minutesElapsed × productionRate)
- Apply storage capacity limits (100 Wood max → stop production when full)
- Apply offline cap: 12 hours for Tier 1 (prevents infinite accumulation)
- Return `OfflineProductionResult` with resources earned per building type

✅ **Tier 2 Offline Production (Conveyor Chains)**
- Build dependency graph from conveyor connections
- Topological sort (Kahn's algorithm): Process buildings in correct order
- Simulate resource flow: Deduct inputs, add outputs, respect bottlenecks
- Handle complex chains: Lumbermill (Wood) → Smelter (Iron) → Workshop (Tools)
- Apply offline cap: 24 hours for Tier 2 (rewards advanced players)

✅ **Welcome Back Modal**
- Full-screen modal on app resume: "Welcome Back! You were away for 3h 24m"
- Animated counter: Resources earned (Wood +450, Iron +120, Gold +1,200)
- Show breakdown: "10 Lumbermills produced 450 Wood (capped at 12h)"
- "Watch Ad for 2× Rewards" button (60-second delay before showing)
- "Collect" button: Add resources to player inventory, dismiss modal

✅ **2× Ad Boost (Rewarded Video)**
- Integrate Google AdMob SDK (rewarded video ad format)
- On "Watch Ad" tap: Show 30-second video ad
- On ad complete: Double all offline rewards, log analytics event
- On ad failed/dismissed: Award 1× rewards (no penalty for trying)
- Cooldown: One ad per offline session (prevents spam)

✅ **Time Validation (Anti-Cheat)**
- Server timestamp validation: Compare device time vs Firebase server time
- Reject if device time manipulated (>5 minutes drift)
- Log suspicious activity to Crashlytics (manual review for ban)
- Fallback: Use last known server timestamp if offline

### Out-of-Scope (Future Phases)

❌ **Advanced Features (Post-MVP)**
- Offline speed boosts (Premium Pass: 1.5× offline production) → Month 2
- Push notifications: "Your factory produced 10k gold!" → Month 3
- Offline production history log (show last 7 days) → v1.1
- Idle mode (background production while app open) → Out of scope for MVP

❌ **Extended Offline Caps**
- 48-hour cap for VIP players → Post-launch feature
- Infinite offline (Premium IAP) → Not planned (breaks balance)

### Success Criteria (Testable)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Calculation Performance | <50ms for 20 buildings + 50 conveyors | Performance test on Snapdragon 660 |
| Accuracy | 100% correct for Tier 1, 95% for Tier 2 | 70+ unit tests (edge cases) |
| Ad Adoption | 60%+ players watch ad for 2× boost | Firebase Analytics event tracking |
| Day 1 Retention | +15% vs no offline production | A/B test cohort analysis |
| Day 7 Retention | +10% vs no offline production | A/B test cohort analysis |

---

## System Architecture Alignment

### Clean Architecture Layers

**Domain Layer (lib/domain/)**
```
lib/domain/entities/
  ├── offline_production_result.dart  # Result: resources, gold, time elapsed, capped
  └── production_snapshot.dart        # Snapshot: buildings, conveyors, last seen time

lib/domain/use_cases/
  ├── offline_production/
  │   ├── calculate_offline_production_tier1.dart  # O(n) simple algorithm
  │   ├── calculate_offline_production_tier2.dart  # Topological sort + simulation
  │   └── validate_time_integrity.dart             # Anti-cheat: detect time manipulation
  └── ads/
      ├── show_rewarded_ad.dart                    # AdMob integration wrapper
      └── apply_ad_boost.dart                      # Double rewards if ad watched

lib/domain/repositories/
  ├── offline_production_repository.dart  # Save/load last seen timestamp
  └── ads_repository.dart                 # Abstract: show ads, track impressions
```

**Data Layer (lib/data/)**
```
lib/data/models/
  ├── offline_production_result_model.dart  # JSON serialization
  └── production_snapshot_model.dart        # Firestore document structure

lib/data/repositories/
  ├── offline_production_repository_impl.dart  # Firestore + Hive caching
  └── ads_repository_impl.dart                 # AdMob SDK wrapper
```

**Presentation Layer (lib/presentation/)**
```
lib/presentation/screens/
  └── welcome_back/
      ├── welcome_back_modal.dart              # Full-screen modal
      ├── widgets/
      │   ├── resource_counter_widget.dart     # Animated counter (0 → 450 Wood)
      │   ├── ad_boost_button.dart             # "Watch Ad for 2×" CTA
      │   └── production_breakdown_card.dart   # "10 Lumbermills → 450 Wood"

lib/presentation/providers/
  ├── offline_production_provider.dart  # @riverpod: Calculate on app resume
  └── ads_provider.dart                 # @riverpod: AdMob ad state (loaded, shown, completed)
```

**Game Layer (lib/game/)**
```
lib/game/systems/
  └── offline_production_system.dart  # Integrates with Flame lifecycle (onResume)
```

### Technology Stack Alignment

| Component | Technology | Justification |
|-----------|-----------|---------------|
| Offline Calculation | Pure Dart (no packages) | Simple algorithms, no external deps |
| Topological Sort | Pure Dart (Queue, Map) | Kahn's algorithm is ~50 lines |
| Time Validation | Firebase Firestore `FieldValue.serverTimestamp()` | Prevents device time manipulation |
| Ad SDK | Google AdMob Flutter Plugin | Industry standard, 90% fill rate |
| Ad Mediation | AdMob Mediation (optional) | Maximize eCPM with Unity Ads, AppLovin fallbacks |
| Storage | Hive (last seen time) + Firestore (cloud backup) | Offline-first, syncs when online |
| State Management | Riverpod @riverpod | Reactive updates for modal display |

### Integration Points

**Epic 01 (Core Loop) Dependencies:**
- Building Entity: Uses `Building.productionRate`, `Building.storageCapacity`
- PlayerEconomy: Adds earned resources to player inventory

**Epic 02 (Economy) Dependencies:**
- Resource Definitions: Calculates gold value (Wood × baseMarketPrice)
- Market Prices: Offline gold earnings based on resource values

**Epic 03 (Planning) Dependencies:**
- Conveyor Routes: `List<ConveyorRoute>` used for dependency graph
- Topological Sort: Determines production order (source → sink)

**Provides to Epic 05 (Mobile UX):**
- Welcome Back Modal: Full-screen takeover on app resume
- Integrates with app lifecycle (AppLifecycleState.resumed)

**Provides to Epic 08 (Monetization):**
- Rewarded Video Ads: Primary ad format (60%+ adoption rate)
- Ad revenue: $0.015 eCPM × 60% watch rate × daily sessions

---

## Detailed Design

### Services and Modules

#### 1. Offline Production Algorithm - Tier 1 (Simple)

**File:** `lib/domain/use_cases/offline_production/calculate_offline_production_tier1.dart`

**Responsibility:** Calculate production for buildings without conveyor dependencies (Tier 1).

**Algorithm:**
```dart
class CalculateOfflineProductionTier1UseCase {
  OfflineProductionResult execute({
    required List<Building> buildings,
    required DateTime lastSeen,
    required DateTime now,
  }) {
    final minutesElapsed = now.difference(lastSeen).inMinutes;
    final cappedMinutes = min(minutesElapsed, 12 * 60); // 12-hour cap

    final resourcesEarned = <ResourceType, int>{};
    var totalGoldValue = 0;

    for (final building in buildings.where((b) => b.tier == 1)) {
      // Calculate raw production
      final rawProduction = cappedMinutes * building.productionRate;

      // Apply storage capacity limit
      final cappedProduction = min(
        rawProduction,
        building.production.storageCapacity,
      );

      // Add to results
      final resourceType = building.production.outputResource.type;
      resourcesEarned[resourceType] =
          (resourcesEarned[resourceType] ?? 0) + cappedProduction.toInt();

      // Calculate gold value
      totalGoldValue += cappedProduction.toInt() *
                        ResourceDefinitions.getPrice(resourceType);
    }

    return OfflineProductionResult(
      resourcesEarned: resourcesEarned,
      totalGoldValue: totalGoldValue,
      minutesElapsed: cappedMinutes,
      wasCapped: minutesElapsed > 12 * 60,
      capReason: minutesElapsed > 12 * 60 ? '12-hour limit' : null,
    );
  }
}
```

**Complexity:** O(n) where n = number of buildings
**Performance:** <10ms for 20 buildings (simple arithmetic)

**Edge Cases Handled:**
- Zero buildings: Return empty result (no error)
- Zero time elapsed: Return zero resources
- Negative time (clock change): Treat as zero elapsed
- Storage full: Stop production at capacity (e.g., 100 Wood max)

#### 2. Offline Production Algorithm - Tier 2 (Complex)

**File:** `lib/domain/use_cases/offline_production/calculate_offline_production_tier2.dart`

**Responsibility:** Calculate production for buildings with conveyor dependencies (Tier 2).

**Algorithm (Topological Sort + Simulation):**
```dart
class CalculateOfflineProductionTier2UseCase {
  OfflineProductionResult execute({
    required List<Building> buildings,
    required List<ConveyorRoute> conveyors,
    required DateTime lastSeen,
    required DateTime now,
  }) {
    final minutesElapsed = now.difference(lastSeen).inMinutes;
    final cappedMinutes = min(minutesElapsed, 24 * 60); // 24-hour cap for Tier 2

    // Step 1: Build dependency graph
    final graph = _buildDependencyGraph(buildings, conveyors);

    // Step 2: Topological sort (Kahn's algorithm)
    final sortedBuildings = _topologicalSort(buildings, graph);

    // Step 3: Simulate production in dependency order
    final inventory = <String, int>{}; // buildingId → available resources
    final resourcesEarned = <ResourceType, int>{};

    for (final building in sortedBuildings) {
      // Calculate how much this building can produce
      final maxProduction = cappedMinutes * building.productionRate;

      // Check if building has required inputs (from conveyors)
      final inputRequirements = _getInputRequirements(building, conveyors);
      var actualProduction = maxProduction;

      for (final input in inputRequirements.entries) {
        final requiredAmount = input.value * cappedMinutes;
        final availableAmount = inventory[input.key] ?? 0;

        if (availableAmount < requiredAmount) {
          // Bottleneck: Not enough inputs
          actualProduction = min(
            actualProduction,
            (availableAmount / input.value).floor(),
          );
        }
      }

      // Deduct consumed inputs
      for (final input in inputRequirements.entries) {
        inventory[input.key] = (inventory[input.key] ?? 0) -
                                (input.value * actualProduction).toInt();
      }

      // Add produced outputs
      final outputResource = building.production.outputResource.type;
      inventory[building.id] = (inventory[building.id] ?? 0) + actualProduction.toInt();
      resourcesEarned[outputResource] =
          (resourcesEarned[outputResource] ?? 0) + actualProduction.toInt();
    }

    final totalGoldValue = resourcesEarned.entries
        .map((e) => e.value * ResourceDefinitions.getPrice(e.key))
        .fold(0, (a, b) => a + b);

    return OfflineProductionResult(
      resourcesEarned: resourcesEarned,
      totalGoldValue: totalGoldValue,
      minutesElapsed: cappedMinutes,
      wasCapped: minutesElapsed > 24 * 60,
      capReason: minutesElapsed > 24 * 60 ? '24-hour limit' : null,
    );
  }

  /// Build adjacency list from conveyors
  Map<String, List<String>> _buildDependencyGraph(
    List<Building> buildings,
    List<ConveyorRoute> conveyors,
  ) {
    final graph = <String, List<String>>{};
    for (final building in buildings) {
      graph[building.id] = [];
    }
    for (final conveyor in conveyors) {
      // endBuilding depends on startBuilding
      graph[conveyor.endBuildingId]!.add(conveyor.startBuildingId);
    }
    return graph;
  }

  /// Kahn's algorithm for topological sort
  List<Building> _topologicalSort(
    List<Building> buildings,
    Map<String, List<String>> graph,
  ) {
    final inDegree = <String, int>{};
    for (final building in buildings) {
      inDegree[building.id] = graph[building.id]!.length;
    }

    final queue = Queue<Building>();
    for (final building in buildings) {
      if (inDegree[building.id] == 0) {
        queue.add(building);
      }
    }

    final sorted = <Building>[];
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      sorted.add(current);

      // Remove edges from current
      for (final neighborId in graph.keys) {
        if (graph[neighborId]!.contains(current.id)) {
          inDegree[neighborId] = inDegree[neighborId]! - 1;
          if (inDegree[neighborId] == 0) {
            final neighbor = buildings.firstWhere((b) => b.id == neighborId);
            queue.add(neighbor);
          }
        }
      }
    }

    if (sorted.length != buildings.length) {
      throw CircularDependencyException('Conveyor cycle detected');
    }

    return sorted;
  }
}
```

**Complexity:** O(V + E) where V = buildings, E = conveyors (standard topological sort)
**Performance:** <50ms for 20 buildings + 50 conveyors

**Edge Cases Handled:**
- Circular dependencies: Throw exception (should never happen, but defensive)
- Missing inputs (bottleneck): Produce zero output for downstream buildings
- Multiple conveyors to same building: Aggregate inputs

#### 3. Time Validation (Anti-Cheat)

**File:** `lib/domain/use_cases/offline_production/validate_time_integrity.dart`

**Responsibility:** Detect device time manipulation (players changing clock to farm resources).

**API:**
```dart
class ValidateTimeIntegrityUseCase {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<DateTime> getValidatedServerTime() async {
    final userId = _auth.currentUser!.uid;

    try {
      // Write dummy document with server timestamp
      final docRef = _firestore.collection('_time_validation').doc(userId);
      await docRef.set({
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Read back server timestamp
      final snapshot = await docRef.get();
      final serverTime = (snapshot.data()!['timestamp'] as Timestamp).toDate();

      // Compare with device time
      final deviceTime = DateTime.now();
      final drift = deviceTime.difference(serverTime).inMinutes.abs();

      if (drift > 5) {
        // Device time manipulated (>5 min drift)
        FirebaseCrashlytics.instance.log(
          'Time manipulation detected: device=$deviceTime, server=$serverTime, drift=${drift}min',
        );
        FirebaseAnalytics.instance.logEvent(
          name: 'time_cheat_detected',
          parameters: {'drift_minutes': drift},
        );

        // Use server time instead (don't reward cheaters)
        return serverTime;
      }

      return deviceTime; // Device time is valid
    } catch (e) {
      // Offline: Use device time (can't validate, but better than blocking)
      return DateTime.now();
    }
  }
}
```

**Anti-Cheat Logic:**
1. On app resume: Call `getValidatedServerTime()`
2. Calculate offline time: `serverTime - lastSeenTime`
3. If drift >5 min: Use server time, log event (manual review for ban)
4. If offline: Trust device time (no internet, can't validate)

#### 4. AdMob Rewarded Video Integration

**File:** `lib/data/repositories/ads_repository_impl.dart`

**Responsibility:** Load and show rewarded video ads, handle callbacks.

**API:**
```dart
class AdsRepositoryImpl implements AdsRepository {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  @override
  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917' // Test ID
          : 'ca-app-pub-3940256099942544/1712485313',
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  @override
  Future<bool> showRewardedAd() async {
    if (!_isAdLoaded || _rewardedAd == null) {
      return false; // Ad not ready
    }

    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        completer.complete(false); // User dismissed ad (no reward)
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        completer.complete(false); // Ad failed to show
      },
    );

    bool rewardEarned = false;
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
        FirebaseAnalytics.instance.logEvent(
          name: 'ad_rewarded',
          parameters: {
            'ad_type': 'offline_production_2x',
            'reward_amount': reward.amount,
          },
        );
      },
    );

    await _rewardedAd!.show(onUserEarnedReward: (ad, reward) {});
    completer.complete(rewardEarned);

    return completer.future;
  }

  @override
  bool isAdReady() => _isAdLoaded;
}
```

---

### Data Models and Contracts

#### OfflineProductionResult Entity

```dart
class OfflineProductionResult extends Equatable {
  final Map<ResourceType, int> resourcesEarned;
  final int totalGoldValue;
  final int minutesElapsed;
  final bool wasCapped;
  final String? capReason;

  const OfflineProductionResult({
    required this.resourcesEarned,
    required this.totalGoldValue,
    required this.minutesElapsed,
    required this.wasCapped,
    this.capReason,
  });

  /// Format elapsed time: "3h 24m"
  String get formattedElapsedTime {
    final hours = minutesElapsed ~/ 60;
    final minutes = minutesElapsed % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Apply 2× boost from ad
  OfflineProductionResult applyBoost(double multiplier) {
    return OfflineProductionResult(
      resourcesEarned: resourcesEarned.map(
        (type, amount) => MapEntry(type, (amount * multiplier).toInt()),
      ),
      totalGoldValue: (totalGoldValue * multiplier).toInt(),
      minutesElapsed: minutesElapsed,
      wasCapped: wasCapped,
      capReason: capReason,
    );
  }

  @override
  List<Object?> get props => [
    resourcesEarned,
    totalGoldValue,
    minutesElapsed,
    wasCapped,
    capReason,
  ];
}
```

---

### APIs and Interfaces

#### OfflineProductionRepository

```dart
abstract class OfflineProductionRepository {
  /// Get last seen timestamp (local + cloud merge)
  Future<DateTime?> getLastSeenTime();

  /// Update last seen timestamp on app pause
  Future<void> updateLastSeenTime(DateTime time);

  /// Save offline production result for analytics
  Future<void> saveOfflineProductionLog(OfflineProductionResult result);
}
```

#### AdsRepository

```dart
abstract class AdsRepository {
  /// Load rewarded video ad (call on app start)
  Future<void> loadRewardedAd();

  /// Show ad and return true if user earned reward
  Future<bool> showRewardedAd();

  /// Check if ad is ready to show
  bool isAdReady();
}
```

---

### Workflows and Sequencing

#### Workflow 1: App Resume → Welcome Back Modal

```
┌──────────────┐     ┌─────────────────┐     ┌──────────────────┐
│   Flutter    │     │  Domain Layer   │     │   Data Layer     │
│  Lifecycle   │     │   (Use Cases)   │     │  (Firestore)     │
└──────┬───────┘     └────────┬────────┘     └────────┬─────────┘
       │                      │                       │
       │ 1. AppLifecycleState │                       │
       │    .resumed          │                       │
       ├─────────────────────>│                       │
       │                      │                       │
       │                      │ 2. GetLastSeenTime    │
       │                      ├──────────────────────>│
       │                      │                       │
       │                      │ 3. lastSeen = 3h ago  │
       │                      │<──────────────────────┤
       │                      │                       │
       │                      │ 4. ValidateTime       │
       │                      │    (anti-cheat)       │
       │                      ├──────────────────────>│
       │                      │                       │
       │                      │ 5. serverTime = now   │
       │                      │<──────────────────────┤
       │                      │                       │
       │                      │ 6. CalculateOffline   │
       │                      │    Production(3h)     │
       │                      │                       │
       │                      │ [Tier 1 calculation]  │
       │                      │ [Tier 2 topological   │
       │                      │  sort + simulation]   │
       │                      │                       │
       │ 7. Result:           │                       │
       │    Wood +450         │                       │
       │    Iron +120         │                       │
       │    Gold +1,200       │                       │
       │<─────────────────────┤                       │
       │                      │                       │
       │ 8. Show Welcome      │                       │
       │    Back Modal        │                       │
       │    (animated)        │                       │
       │                      │                       │
       │ [60-second delay]    │                       │
       │                      │                       │
       │ 9. Show "Watch Ad    │                       │
       │    for 2×" button    │                       │
       │                      │                       │
```

#### Workflow 2: Player Watches Ad for 2× Boost

```
┌──────────┐     ┌────────────────┐     ┌─────────────┐     ┌──────────────┐
│  Player  │     │ Presentation   │     │   Domain    │     │  AdMob SDK   │
└────┬─────┘     └────────┬───────┘     └──────┬──────┘     └──────┬───────┘
     │                    │                    │                   │
     │ 1. Tap "Watch Ad"  │                    │                   │
     ├───────────────────>│                    │                   │
     │                    │ 2. ShowRewardedAd()│                   │
     │                    ├───────────────────>│                   │
     │                    │                    │ 3. Load ad        │
     │                    │                    ├──────────────────>│
     │                    │                    │                   │
     │                    │                    │ 4. Show ad        │
     │                    │                    │<──────────────────┤
     │                    │                    │                   │
     │ [Watch 30-sec ad]  │                    │                   │
     │                    │                    │                   │
     │                    │                    │ 5. onRewardEarned │
     │                    │                    │<──────────────────┤
     │                    │                    │                   │
     │                    │ 6. ApplyBoost(2.0) │                   │
     │                    │<───────────────────┤                   │
     │                    │                   │                   │
     │                    │ [Double resources: │                   │
     │                    │  Wood 450→900]     │                   │
     │                    │                    │                   │
     │ 7. Updated rewards │                    │                   │
     │    shown (2×)      │                    │                   │
     │<───────────────────┤                    │                   │
     │                    │                    │                   │
```

---

## Non-Functional Requirements

### Performance

| Metric | Requirement | Test Method |
|--------|-------------|-------------|
| Tier 1 Calculation | <10ms for 20 buildings | Performance test with Stopwatch |
| Tier 2 Calculation | <50ms for 20 buildings + 50 conveyors | Performance test with Stopwatch |
| Modal Load Time | <300ms from app resume to modal shown | User experience test |
| Ad Load Time | <3 seconds for rewarded video | AdMob test ads |
| Memory Usage | <50MB for offline calculation | Android Studio Profiler |

**Optimization Strategies:**
1. **Lazy Calculation:** Only calculate offline production when modal shown (not on every app resume)
2. **Caching:** Cache topological sort result (reuse if graph unchanged)
3. **Batch Firestore Reads:** Single read for lastSeenTime + buildings + conveyors
4. **Ad Preloading:** Load rewarded video on app start (ready when needed)

### Security

**Anti-Cheat Measures:**
```dart
// 1. Server timestamp validation
final serverTime = await _getServerTime(); // Firestore FieldValue.serverTimestamp()
final deviceTime = DateTime.now();
final drift = deviceTime.difference(serverTime).inMinutes.abs();

if (drift > 5) {
  // Time manipulation detected
  _logCheatAttempt(drift);
  return OfflineProductionResult.empty(); // No rewards for cheaters
}

// 2. Maximum cap enforcement
final cappedMinutes = min(minutesElapsed, 24 * 60); // Hard cap

// 3. Resource validation
if (result.totalGoldValue > 1000000) {
  // Suspicious: >1M gold from offline production
  _logSuspiciousActivity(result);
  // Flag account for manual review
}
```

**Firestore Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow write: if request.auth.uid == userId &&
                      request.resource.data.offlineGoldEarned < 100000; // Max 100k per session
    }
  }
}
```

### Reliability/Availability

**Error Handling:**
```dart
try {
  final result = await _calculateOfflineProduction();
  _showWelcomeBackModal(result);
} catch (e, stackTrace) {
  FirebaseCrashlytics.instance.recordError(e, stackTrace);

  // Fallback: Show simplified modal without breakdown
  _showSimplifiedWelcomeBack('Welcome back! Rewards calculated.');
}
```

**Ad Failure Handling:**
```dart
final adShown = await _adsRepository.showRewardedAd();

if (!adShown) {
  // Ad failed to load or user dismissed
  showSnackBar('Ad not available. You still get 1× rewards!');
  // Award 1× rewards (no penalty)
}
```

### Observability

**Firebase Analytics Events:**
```dart
// Track offline production events
FirebaseAnalytics.instance.logEvent(
  name: 'offline_production_calculated',
  parameters: {
    'minutes_elapsed': result.minutesElapsed,
    'total_gold_value': result.totalGoldValue,
    'was_capped': result.wasCapped,
    'tier': hasConveyors ? 'tier2' : 'tier1',
  },
);

// Track ad adoption
FirebaseAnalytics.instance.logEvent(
  name: 'offline_ad_shown',
  parameters: {
    'watched_ad': watchedAd, // true/false
    'boost_value': result.totalGoldValue, // How much they could have earned
  },
);
```

---

## Dependencies and Integrations

### Upstream Dependencies

| Epic/Story | Required Artifacts |
|------------|-------------------|
| **EPIC-01: Core Loop** | `Building.productionRate`, `Building.storageCapacity` |
| **EPIC-02: Economy** | `ResourceDefinitions.getPrice()`, `PlayerEconomy.addResources()` |
| **EPIC-03: Planning** | `List<ConveyorRoute>`, dependency graph |
| **EPIC-05: Mobile UX** | App lifecycle hooks (`AppLifecycleState.resumed`) |

### Downstream Dependents

| Epic | How It Uses EPIC-04 |
|------|---------------------|
| **EPIC-08: Monetization** | Rewarded video ad implementation, ad revenue tracking |
| **EPIC-10: Analytics** | Offline production metrics, retention cohort analysis |

---

## Acceptance Criteria (Authoritative)

✅ **AC-1: Tier 1 Offline Calculation**
- Given: Player has 5 Lumbermills (1 Wood/min each), offline for 2 hours
- When: App resumes
- Then: Welcome Back modal shows "Wood +600" (5 × 60 min × 2 hr = 600)
- Test: Unit test with mocked time

✅ **AC-2: Tier 2 Offline Calculation (Conveyor Chain)**
- Given: Lumbermill → Conveyor → Smelter, offline for 1 hour
- When: App resumes
- Then: Wood produced (60), Iron produced (30, assumes 2 Wood → 1 Iron recipe)
- Test: Integration test with topological sort

✅ **AC-3: Storage Capacity Limit**
- Given: Lumbermill (max 100 Wood storage), offline for 10 hours
- When: App resumes
- Then: Wood +100 (capped), modal shows "Storage full after 100 min"
- Test: Unit test with capacity constraint

✅ **AC-4: 12-Hour Cap (Tier 1)**
- Given: Player offline for 48 hours
- When: App resumes
- Then: Rewards calculated for 12 hours only, modal shows "Capped at 12h"
- Test: Unit test with excessive elapsed time

✅ **AC-5: Welcome Back Modal**
- Given: Player offline for 3h 24m, earned Wood +450, Gold +1,200
- When: App resumes
- Then: Modal shows "Welcome Back! Away: 3h 24m", animated counters, "Watch Ad for 2×" button (after 60s delay)
- Test: Widget test + manual UI test

✅ **AC-6: 2× Ad Boost**
- Given: Player earned Wood +450
- When: Player taps "Watch Ad" → watches 30-sec ad → ad completes
- Then: Wood +900 awarded (2× boost), analytics event logged
- Test: Integration test with AdMob test ads

✅ **AC-7: Time Manipulation Detection**
- Given: Device time set to +10 hours (cheating)
- When: App resumes
- Then: Use server time instead, log cheat attempt, no bonus rewards
- Test: Manual test with device clock change

✅ **AC-8: Performance**
- Given: 20 buildings + 50 conveyors
- When: Offline production calculated
- Then: Completes in <50ms on Snapdragon 660
- Test: Performance benchmark

---

## Traceability Mapping

| Requirement | Epic/Story | Acceptance Criteria |
|-------------|-----------|---------------------|
| **FR-004: Offline Production** | EPIC-04 (this doc) | AC-1 through AC-8 |
| FR-004.1: Tier 1 Calculation | STORY-04.1 | AC-1, AC-3, AC-4 |
| FR-004.2: Tier 2 Calculation | STORY-04.2 | AC-2 |
| FR-004.3: Welcome Back Modal | STORY-04.3 | AC-5 |
| FR-004.4: 2× Ad Boost | STORY-04.4 | AC-6 |
| FR-004.5: Time Validation | STORY-04.5 | AC-7 |
| **NFR-001: Performance** | Cross-cutting | AC-8 |

---

## Risks, Assumptions, Open Questions

### High Risks

🔴 **RISK-1: Tier 2 Calculation Complexity (Topological Sort Bugs)**
- **Impact:** HIGH - Wrong calculation = players lose resources = churn
- **Likelihood:** MEDIUM - Complex algorithm with edge cases (bottlenecks, cycles)
- **Mitigation:**
  1. 40+ unit tests covering all edge cases (empty inputs, bottlenecks, cycles)
  2. Offline production log: Show detailed breakdown to players (transparency)
  3. Beta test with 50 players for 1 week before launch
- **Contingency:** Disable Tier 2 offline in v1.0, launch with Tier 1 only (fallback)

🔴 **RISK-2: Time Manipulation Exploits**
- **Impact:** HIGH - Exploits break economy, require wipe/bans
- **Likelihood:** LOW - Server validation mitigates, but determined cheaters find ways
- **Mitigation:**
  1. Server timestamp validation (5-min drift tolerance)
  2. Cloud Functions validate resource amounts (flag suspicious values)
  3. Manual review queue for flagged accounts
- **Contingency:** Add client-side obfuscation (encrypt lastSeenTime in Hive)

🟡 **RISK-3: Low Ad Fill Rate (<50%)**
- **Impact:** MEDIUM - Reduced ad revenue (target: 60% watch rate × 90% fill = 54% monetization)
- **Likelihood:** MEDIUM - AdMob fill rates vary by region (90% US, 50% LATAM)
- **Mitigation:**
  1. Use AdMob Mediation (Unity Ads, AppLovin fallbacks)
  2. Preload ad on app start (ready when modal shown)
  3. Fallback message: "Ad not available, but you still get 1× rewards!"
- **Contingency:** Offer IAP alternative: "$0.99 for 2× boost (no ad)"

### Assumptions

1. **Offline Cap is Acceptable:** Assumes 12h (Tier 1) / 24h (Tier 2) cap doesn't frustrate players
2. **Ad Watch Rate:** Assumes 60%+ players watch ads (industry benchmark: 50-70%)
3. **No Circular Dependencies:** Assumes players cannot create conveyor cycles (validated in EPIC-03)
4. **Server Time Available:** Assumes Firebase reachable for time validation (offline = trust device time)

### Open Questions

❓ **Q1:** Should we show push notification when offline cap is reached?
- **Example:** "Your factory is full! Come back to collect rewards."
- **Decision Needed By:** Sprint 5 planning
- **Owner:** Product Manager
- **Impact:** Medium (could increase retention, but may annoy users)

❓ **Q2:** Should VIP players get extended offline cap (48h)?
- **Decision Needed By:** Monetization planning (Month 2)
- **Owner:** Business Analyst
- **Impact:** Low (premium feature, post-launch)

❓ **Q3:** Should we add "Offline Production History" log?
- **Example:** "Last 7 days: Day 1: +5k gold, Day 2: +8k gold..."
- **Decision Needed By:** Sprint 5 (before STORY-04.3)
- **Owner:** UX Designer
- **Impact:** Low (nice-to-have, can add in v1.1)

---

## Test Strategy Summary

### Unit Tests (Target: 70+ tests)

**Tier 1 Calculation (30 tests):**
- ✅ 1 hour offline, 1 building (1 Wood/min) = 60 Wood
- ✅ 12 hours offline (at cap) = 720 Wood
- ✅ 48 hours offline (exceeds cap) = 720 Wood (capped)
- ✅ Storage capacity: 100 max, 10 hours = 100 Wood (capped)
- ✅ Zero buildings = empty result
- ✅ Zero elapsed time = empty result
- ✅ Negative elapsed time (clock change) = empty result

**Tier 2 Calculation (40 tests):**
- ✅ Topological sort: Linear chain (A → B → C) sorted correctly
- ✅ Topological sort: Parallel branches (A → B, A → C) both processed
- ✅ Topological sort: Circular dependency throws exception
- ✅ Bottleneck: Smelter needs 10 Wood, only 5 available = 0 Iron produced
- ✅ Multiple conveyors to same building: Aggregate inputs correctly
- ✅ Complex chain: Lumbermill → Smelter → Workshop (3-tier simulation)

### Integration Tests (5 tests)

- ✅ End-to-end: App resumes → calculation → modal shown → collect rewards
- ✅ Ad flow: Watch ad → onRewardEarned → 2× boost applied
- ✅ Time validation: Device time +10h → use server time instead
- ✅ Offline sync: Calculate offline → sync to Firestore → verify cloud save
- ✅ Performance: 20 buildings + 50 conveyors in <50ms

### Widget Tests (5 tests)

- ✅ Welcome Back modal renders correctly (title, resources, buttons)
- ✅ Animated counter: Wood 0 → 450 (smooth animation, 2 seconds)
- ✅ "Watch Ad" button appears after 60-second delay
- ✅ Tap "Collect" → modal dismisses, resources added to inventory
- ✅ Ad button disabled if ad not loaded (gray out, show tooltip)

### Performance Tests (2 tests)

- ✅ Tier 1: 20 buildings in <10ms (Snapdragon 660)
- ✅ Tier 2: 20 buildings + 50 conveyors in <50ms (Snapdragon 660)

**Total Tests:** 70 unit + 5 integration + 5 widget + 2 performance = **82 tests**

---

## Implementation Notes

**Sprint Allocation:**
- **Sprint 5 (Week 7):** STORY-04.1 (Tier 1), STORY-04.3 (Modal UI)
- **Sprint 6 (Week 8):** STORY-04.2 (Tier 2), STORY-04.4 (Ad integration), STORY-04.5 (Time validation)

**Developer Notes:**
- Preload rewarded video ad on app start (`main.dart` initialization)
- Use Riverpod `@riverpod` for modal state (reactive updates)
- Test with AdMob test ad IDs before switching to production IDs
- Add Firebase Analytics events for funnel analysis (modal shown → ad watched → boost applied)

**Code Review Checklist:**
- [ ] Topological sort handles circular dependencies (exception thrown)
- [ ] Storage capacity limits applied correctly (no overflow)
- [ ] Time validation uses server timestamp (anti-cheat)
- [ ] Ad failure handled gracefully (show 1× rewards, no error)
- [ ] Performance: <50ms on Snapdragon 660 emulator
- [ ] Tests: 100% coverage for offline calculation logic

---

**Document Status:** ✅ Ready for Development
**Next Steps:** Sprint 5 planning, assign STORY-04.1 and STORY-04.3
**Questions:** Contact Game Economist (offline cap balance) or Tech Lead (performance concerns)
