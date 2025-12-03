# Epic 10: Analytics & Metrics - Technical Specification

<!-- AI-INDEX: epic, tech-spec, analytics, firebase-analytics, retention, metrics -->

**Epic:** EPIC-10 - Analytics & Metrics
**Total SP:** 13
**Duration:** 1 week (Sprint 11, post-MVP)
**Status:** 📋 Ready for Implementation
**Date:** 2025-12-03
**Priority:** P0 (Critical - success measurement)

---

## Overview

EPIC-10 implementuje Firebase Analytics do mierzenia sukcesu produktu: D7 retention, Tier 2 unlock rate, custom gameplay events. Metryki są krytyczne dla walidacji product-market fit.

**Design Philosophy:** "Data-driven decisions" - każda zmiana gameplayu musi być mierzalna.

**Kluczowe cele:**
- **D7 retention 30-35%** - top quartile dla mid-core games
- **Tier 2 unlock rate 60%+** - walidacja progression pacing
- **Custom events** - building, conveyor, market, offline metrics
- **Funnel analysis** - install → tier 2 conversion

---

## Objectives and Scope

### In Scope

**Firebase Analytics Setup:**
- ✅ Firebase Analytics enabled
- ✅ Screen tracking (automatic)
- ✅ User properties: tier, totalPlayTime, isPayer
- ✅ Default events: app_open, session_start, first_open

**Retention Tracking:**
- ✅ D1, D7, D30 retention cohorts
- ✅ Firebase cohort analysis
- ✅ Retention dashboard

**Success Metrics:**
- ✅ Tier 2 unlock funnel
- ✅ Time to unlock tracking
- ✅ Conversion rates

**Custom Events:**
- ✅ building_placed, building_upgraded
- ✅ conveyor_created
- ✅ market_transaction
- ✅ offline_production_collected
- ✅ session_length

### Out of Scope

- ❌ A/B testing framework (Phase 2)
- ❌ Third-party analytics (Amplitude, Mixpanel)
- ❌ Real-time dashboards
- ❌ ML-based predictions

---

## System Architecture

### Presentation Layer
```
lib/presentation/
└── services/
    └── analytics_service.dart   # Firebase Analytics wrapper
```

### Event Definitions
```
lib/domain/constants/
└── analytics_events.dart        # Event name constants
```

---

## Analytics Service

```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Screen Tracking
  void logScreenView(String screenName) {
    _analytics.logScreenView(screenName: screenName);
  }

  // User Properties
  void setUserProperties({
    required int tier,
    required int totalPlayTime,
    required bool isPayer,
  }) {
    _analytics.setUserProperty(name: 'tier', value: tier.toString());
    _analytics.setUserProperty(name: 'total_play_time', value: totalPlayTime.toString());
    _analytics.setUserProperty(name: 'is_payer', value: isPayer.toString());
  }

  // Gameplay Events
  void logBuildingPlaced(BuildingType type) {
    _analytics.logEvent(
      name: 'building_placed',
      parameters: {'building_type': type.name},
    );
  }

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

  void logConveyorCreated(int pathLength, int goldSpent) {
    _analytics.logEvent(
      name: 'conveyor_created',
      parameters: {
        'path_length': pathLength,
        'gold_spent': goldSpent,
      },
    );
  }

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

  void logTier2Unlocked(Duration timeSinceInstall) {
    _analytics.logEvent(
      name: 'tier_2_unlocked',
      parameters: {
        'time_to_unlock_minutes': timeSinceInstall.inMinutes,
      },
    );
  }

  void logSessionLength(int durationMinutes) {
    _analytics.logEvent(
      name: 'session_length',
      parameters: {'duration_minutes': durationMinutes},
    );
  }
}
```

---

## Key Metrics & Targets

### Retention Metrics

| Metric | Target | Industry Benchmark |
|--------|--------|-------------------|
| D1 Retention | 40-45% | 35% average |
| D7 Retention | 30-35% | 20% average |
| D30 Retention | 15-20% | 10% average |

### Funnel Analysis

```
100% app_install (10,000 users)
 95% first_building_placed (9,500 users)
 85% first_collect (8,500 users)
 75% first_upgrade (7,500 users)
 65% market_opened (6,500 users)
 60% tier_2_unlocked (6,000 users) ← Target
```

### Custom Event Metrics

| Metric | Expected Value |
|--------|---------------|
| Avg buildings per player | 8-10 |
| Avg conveyors per player | 10-15 |
| Market usage rate | 70-80% |
| Ad boost adoption | 60-70% |
| Avg session length | 10-15 minutes |

---

## User Properties

| Property | Type | Description |
|----------|------|-------------|
| `tier` | int | Current player tier (1-3) |
| `total_play_time` | int | Total minutes played |
| `is_payer` | bool | Has made any purchase |
| `buildings_count` | int | Total buildings placed |
| `install_date` | date | First app open |

---

## Firebase Console Configuration

### Audiences to Create:
1. **New Players** - first_open within 7 days
2. **Engaged Players** - session_count > 10
3. **Payers** - is_payer = true
4. **Tier 2 Players** - tier = 2
5. **Churned Players** - last_session > 14 days ago

### Funnels to Track:
1. **FTUE Funnel** - install → first_building → first_collect → first_upgrade
2. **Tier 2 Funnel** - install → 5_types → 10_buildings → 500_gold → tier_2_unlocked
3. **Monetization Funnel** - install → view_shop → purchase

---

## Performance Requirements

| Metric | Target |
|--------|--------|
| Event logging | <5ms |
| Analytics SDK init | <100ms |
| Event queue size | <100 events |
| Batch upload | Every 60s |

---

## Dependencies

**Depends On:**
- ✅ EPIC-09 (Firebase setup)

**Blocks:**
- Nothing (analytics is observational)

---

## Success Metrics

| Metric | Target |
|--------|--------|
| D7 retention | 30-35% |
| Tier 2 unlock rate | 60%+ |
| Analytics event coverage | 100% key actions |
| Firebase data delay | <24 hours |

---

**Status:** 📋 Ready for Implementation
**Last Updated:** 2025-12-03
**Version:** 1.0
