# Epic 10: Analytics & Metrics - User Stories

<!-- AI-INDEX: epic, stories, analytics, firebase-analytics, retention, events -->

**Epic:** EPIC-10 - Analytics & Metrics
**Total Stories:** 4
**Total SP:** 13
**Sprint:** 8
**Status:** 📋 Ready for Implementation

---

## Story Overview

| Story ID | Title | SP | Priority | Dependencies |
|----------|-------|-----|----------|--------------|
| STORY-10.1 | Firebase Analytics Integration | 3 | P0 | STORY-00.2 |
| STORY-10.2 | D7 Retention Tracking | 2 | P0 | STORY-10.1 |
| STORY-10.3 | Success Metrics - Tier 2 Unlock Rate | 3 | P0 | STORY-10.1, STORY-06.2 |
| STORY-10.4 | Custom Events - Gameplay Metrics | 5 | P1 | STORY-10.1 |

---

## STORY-10.1: Firebase Analytics Integration

### Objective
Skonfigurować Firebase Analytics z screen tracking, user properties i podstawowymi eventami.

### User Story
**As a** developer
**I want** Firebase Analytics configured
**So that** I can track user behavior

### Description
Podstawowa integracja Firebase Analytics: automatyczne screen tracking, user properties (tier, playtime, payer status), default events.

### Acceptance Criteria

- [ ] **AC1:** Firebase Analytics enabled in app
```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Analytics automatically enabled
  runApp(MyApp());
}
```

- [ ] **AC2:** Screen tracking for all screens
```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  void logScreenView(String screenName) {
    _analytics.logScreenView(screenName: screenName);
  }
}
```

- [ ] **AC3:** User properties set correctly
```dart
void setUserProperties({
  required int tier,
  required int totalPlayTime,
  required bool isPayer,
}) {
  _analytics.setUserProperty(name: 'tier', value: tier.toString());
  _analytics.setUserProperty(name: 'total_play_time', value: totalPlayTime.toString());
  _analytics.setUserProperty(name: 'is_payer', value: isPayer.toString());
}
```

- [ ] **AC4:** Default events logged: app_open, session_start, first_open

- [ ] **AC5:** Custom events: building_placed, resource_collected, tier_unlocked
```dart
void logBuildingPlaced(BuildingType type) {
  _analytics.logEvent(
    name: 'building_placed',
    parameters: {'building_type': type.name},
  );
}

void logResourceCollected(String resourceId, int amount) {
  _analytics.logEvent(
    name: 'resource_collected',
    parameters: {
      'resource_id': resourceId,
      'amount': amount,
    },
  );
}
```

### Implementation Notes

**Package:** `firebase_analytics: ^10.7.0`

**Integration Points:**
- GameScreen: log screen view on enter
- BuildingComponent: log on placement
- CollectResourcesUseCase: log on collection

### Definition of Done
- [ ] Analytics events appear in Firebase console (24h delay)
- [ ] Screen views tracked automatically
- [ ] User properties set correctly
- [ ] Unit tests for AnalyticsService

**Story Points:** 3 SP
**Priority:** P0
**Sprint:** Sprint 8

---

## STORY-10.2: D7 Retention Tracking

### Objective
Skonfigurować cohort analysis w Firebase do śledzenia D1, D7, D30 retention.

### User Story
**As a** product manager
**I want** D7 retention cohort analysis
**So that** I measure product-market fit

### Description
Firebase cohort analysis dla retention metrics. Target D7: 30-35% (top quartile for mid-core games).

### Acceptance Criteria

- [ ] **AC1:** Firebase cohort analysis configured

- [ ] **AC2:** Retention metrics visible: D1, D7, D30
```
Cohort: Users who installed on Jan 1 = 1000 users

D1 Retention: 450 users returned on Jan 2 = 45%
D7 Retention: 320 users returned on Jan 8 = 32%
D30 Retention: 180 users returned on Feb 1 = 18%
```

- [ ] **AC3:** Target: D7 30-35% (top quartile for mid-core)

- [ ] **AC4:** Retention dashboard visible in Firebase Analytics

- [ ] **AC5:** A/B test support preparation (for future tutorial variations)

### Implementation Notes

**Firebase Console:**
1. Navigate to Analytics → Retention
2. View cohort table (installation date × day N retention)
3. Export data for detailed analysis

**No code changes required** - Firebase automatic tracking

### Definition of Done
- [ ] Retention metrics visible in Firebase
- [ ] D7 retention tracked correctly
- [ ] Dashboard configured for team viewing

**Story Points:** 2 SP (configuration)
**Priority:** P0
**Sprint:** Sprint 8

---

## STORY-10.3: Success Metrics - Tier 2 Unlock Rate

### Objective
Zaimplementować tracking Tier 2 unlock rate z funnel analysis i time-to-unlock metrics.

### User Story
**As a** product manager
**I want** to track Tier 2 unlock rate
**So that** I validate progression pacing

### Description
Kluczowa metryka sukcesu: 60%+ graczy powinno odblokować Tier 2 w 2-3 godziny. Funnel analysis od instalacji do unlocka.

### Acceptance Criteria

- [ ] **AC1:** Log event: `tier_2_unlocked` with time_to_unlock
```dart
void logTier2Unlocked(Duration timeSinceInstall) {
  _analytics.logEvent(
    name: 'tier_2_unlocked',
    parameters: {
      'time_to_unlock_minutes': timeSinceInstall.inMinutes,
    },
  );
}
```

- [ ] **AC2:** Funnel tracking: install → tier_2_unlocked
```
100% app_install (10,000 users)
 95% first_building_placed (9,500 users)
 85% first_collect (8,500 users)
 75% first_upgrade (7,500 users)
 65% market_opened (6,500 users)
 60% tier_2_unlocked (6,000 users) ← Target
```

- [ ] **AC3:** Target: 60%+ unlock rate within 3 hours

- [ ] **AC4:** Average time to unlock: 2-3 hours tracking

- [ ] **AC5:** Firebase funnel configured

### Implementation Notes

**Integration:**
- Hook into `UnlockTierUseCase`
- Calculate time since first_open
- Log event with duration

**Funnel Steps:**
1. `first_open` (automatic)
2. `first_building_placed`
3. `first_collect`
4. `first_upgrade`
5. `market_opened`
6. `tier_2_unlocked`

### Definition of Done
- [ ] Tier 2 unlock rate visible in Firebase
- [ ] Average time to unlock calculated
- [ ] Funnel dashboard configured

**Story Points:** 3 SP
**Priority:** P0
**Sprint:** Sprint 8

---

## STORY-10.4: Custom Events - Gameplay Metrics

### Objective
Zaimplementować szczegółowe eventy gameplay dla optymalizacji balansu gry.

### User Story
**As a** product manager
**I want** detailed gameplay metrics
**So that** I optimize game balance

### Description
Custom events dla wszystkich kluczowych akcji: building upgrades, conveyors, market transactions, offline production, session length.

### Acceptance Criteria

- [ ] **AC1:** Event: `building_upgraded`
```dart
void logBuildingUpgraded(BuildingType type, int fromLevel, int toLevel, int goldSpent) {
  _analytics.logEvent(
    name: 'building_upgraded',
    parameters: {
      'building_type': type.name,
      'from_level': fromLevel,
      'to_level': toLevel,
      'gold_spent': goldSpent,
    },
  );
}
```

- [ ] **AC2:** Event: `conveyor_created`
```dart
void logConveyorCreated(int pathLength, int goldSpent) {
  _analytics.logEvent(
    name: 'conveyor_created',
    parameters: {
      'path_length': pathLength,
      'gold_spent': goldSpent,
    },
  );
}
```

- [ ] **AC3:** Event: `market_transaction`
```dart
void logMarketTransaction(String type, String resourceId, int quantity, int goldAmount) {
  _analytics.logEvent(
    name: 'market_transaction',
    parameters: {
      'transaction_type': type, // buy/sell
      'resource_id': resourceId,
      'quantity': quantity,
      'gold_amount': goldAmount,
    },
  );
}
```

- [ ] **AC4:** Event: `offline_production_collected`
```dart
void logOfflineProductionCollected(int minutesOffline, int resourcesCollected, bool adBoostUsed) {
  _analytics.logEvent(
    name: 'offline_production_collected',
    parameters: {
      'minutes_offline': minutesOffline,
      'resources_collected': resourcesCollected,
      'ad_boost_used': adBoostUsed,
    },
  );
}
```

- [ ] **AC5:** Event: `session_length`
```dart
void logSessionLength(int durationMinutes) {
  _analytics.logEvent(
    name: 'session_length',
    parameters: {'duration_minutes': durationMinutes},
  );
}
```

### Expected Metrics Dashboard

```
Top Metrics:
- Avg buildings per player: 8.5
- Avg conveyors per player: 12.3
- Market usage rate: 75% (7,500 / 10,000 users)
- Ad boost adoption: 68% (6,800 / 10,000 users)
- Avg session length: 12 minutes
```

### Implementation Notes

**Integration Points:**
- `UpgradeBuildingUseCase` → building_upgraded
- `CreateConveyorUseCase` → conveyor_created
- `MarketTransactionUseCase` → market_transaction
- `CollectOfflineProductionUseCase` → offline_production_collected
- `AppLifecycleObserver` → session_length

### Definition of Done
- [ ] All custom events logged correctly
- [ ] Metrics visible in Firebase dashboard
- [ ] Event parameters validated

**Story Points:** 5 SP (many events)
**Priority:** P1
**Sprint:** Sprint 8

---

## Dependencies Graph

```
STORY-00.2 (Firebase Setup)
    │
    ▼
STORY-10.1 (Analytics Integration)
    │
    ├──────────────────┬──────────────────┐
    ▼                  ▼                  ▼
STORY-10.2         STORY-10.3         STORY-10.4
(D7 Retention)     (Tier 2 Metrics)   (Custom Events)
                        │
                        ▼
                   STORY-06.2
                   (Tier 2 Unlock)
```

---

**Total:** 4 stories, 13 SP
**Status:** 📋 Ready for Implementation
**Last Updated:** 2025-12-03
