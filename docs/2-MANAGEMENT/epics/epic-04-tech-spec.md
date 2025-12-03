# Epic 4: Offline Production - Technical Specification

**Epic:** EPIC-04 - Offline Production
**Total SP:** 26
**Duration:** 2 weeks (Sprints 6-7)
**Status:** 📋 Ready for Implementation
**Date:** 2025-12-03

---

## Overview

EPIC-04 implementuje **system produkcji offline** który oblicza zasoby zarobione podczas nieobecności gracza. Jest to **krytyczny driver retencji** - gracze którzy otrzymują znaczące nagrody offline są 2.5× bardziej skłonni wrócić w ciągu 24h.

**Business Value:**
- Retention Driver: D1, D7, D30 retention boost
- Monetization Hook: 60%+ graczy ogląda reklamy za 2× boost
- Perceived Progress: Postęp nawet gdy nie gra

---

## 1. Offline Production System

> **Source:** Przeniesione z Epic 2 SYSTEMS.md

### Overview

**Purpose:** Reward players for returning, provide passive income, create session motivation

**Core Mechanic:** Farm produces at 80% efficiency while offline

### Offline Production Calculation

**Formula:**
```
offlineTimeSeconds = returnTime - lastLogoutTime

itemsProcessedInQueue = MIN(
  farm.inputBuffer.length,
  (offlineTimeSeconds / itemCycleTime) * 0.80
)

goldEarned = itemsProcessedInQueue * baseValue * (1.0 + tradingSkillBonus)
```

**Example Calculation:**
```
Player logs out with Farm queue:
- 50 Węgiel in input
- 30 Ruda Żelaza in input
- Item cycle time: 3 seconds

Offline for: 2 hours (7,200 seconds)

Processing calculation:
- Items that could process: 7,200s / 3s = 2,400 items
- At 80% efficiency: 2,400 * 0.80 = 1,920 items
- Limited by queue: MIN(1,920, 80) = 80 items
- All 50 Węgiel + 30 Ruda processed

Gold earned:
- Węgiel (base 1g): 50 * 1g * 1.0 = 50g
- Ruda (base 1g): 30 * 1g * 1.0 = 30g
- Total: 80g earned offline
```

**Key Rules:**
- 80% efficiency (not 100%, encourages active play)
- Capped by input buffer length (can't create items)
- Respects farm processing speed
- Trading skill multiplier applies
- NO overflow losses (items stay in queue if can't process)
- NO decay for storage items (safe to log off)

---

## 2. Tier 2 Offline Production (Conveyor Chains)

### Algorithm

**Build dependency graph from conveyor connections:**
- Topological sort (Kahn's algorithm): Process buildings in correct order
- Simulate resource flow: Deduct inputs, add outputs, respect bottlenecks
- Handle complex chains: Lumbermill → Smelter → Workshop → Farm

**Example Chain:**
```
Chain: Mining → Smelter → Workshop → Farm

Offline 2 hours:
1. Mining produces: 2h * 60min * 1 ore/min = 120 Ore (capped at storage 100)
2. Smelter processes: 100 ore / 30 per bar * 0.8 = 2.67 bars → 2 bars
3. Workshop processes: 2 bars → 0.2 tools → 0 tools (floor)
4. Farm income: 0g from tools, but residual from storage

Total: Mining + Smelter contributions only
```

### Offline Caps

| Tier | Max Offline Time | Reason |
|------|------------------|--------|
| Tier 1 | 12 hours | Simple buildings, prevent infinite |
| Tier 2 | 24 hours | Reward automation investment |

---

## 3. Welcome-Back Notification System

**Trigger:** When player logs in after offline time > 5 minutes

### Notification Screen Elements

**1. Title & Time Display**
```
"Welcome Back!"
"Away for: 2 hours 34 minutes"
```

**2. Earnings Breakdown**
```
Farm Production Summary:
├─ Węgiel (50 items): 50g
├─ Ruda Żelaza (30 items): 30g
├─ Trading Skill Bonus (+15%): +12g
└─ TOTAL: 92g
```

**3. Gold Animation**
- Duration: 2 seconds
- Counter animates from 0 → 92g
- Coins fall from top, accumulate at bottom
- Satisfying sound effects (clink, accumulate, complete)
- +XP notification (earned 18 XP from 18 trades)

**4. Action Buttons**
- [OK] - Close and start playing
- [View Breakdown] - More details (optional)
- [Watch Ad for 2×] - Double rewards (AdMob integration)

### UI Layout (Mobile)

```
┌────────────────────────────────┐
│                                │
│      ✨ Welcome Back! ✨        │
│                                │
│    Away for: 2h 34m            │
│                                │
│  ┌──────────────────────────┐  │
│  │  💰 Gold Earned: 92g     │  │
│  │  📦 Items: 80 processed  │  │
│  │  ⭐ XP: +18              │  │
│  └──────────────────────────┘  │
│                                │
│  [Show Breakdown]              │
│                                │
│  ┌────────────────────────┐    │
│  │  📺 Watch Ad for 2×    │    │
│  └────────────────────────┘    │
│                                │
│  ┌────────────────────────┐    │
│  │     [  Collect  ]      │    │
│  └────────────────────────┘    │
│                                │
└────────────────────────────────┘
```

---

## 4. 2× Ad Boost (Rewarded Video)

### Integration

**SDK:** Google AdMob (rewarded video format)

**Flow:**
1. Player taps "Watch Ad for 2×"
2. Show 30-second video ad
3. On ad complete: Double all offline rewards
4. On ad failed/dismissed: Award 1× rewards (no penalty)
5. Cooldown: One ad per offline session

### Error Handling

```dart
void onWatchAdTapped() async {
  try {
    final result = await AdMob.showRewardedAd();
    if (result == AdResult.completed) {
      offlineRewards *= 2;
      Analytics.log('ad_watch_success');
    } else {
      // Award 1× rewards
      Analytics.log('ad_watch_cancelled');
    }
  } catch (e) {
    // Network error, still award 1× rewards
    Analytics.log('ad_watch_error', error: e);
  }

  collectRewards();
}
```

---

## 5. Time Validation (Anti-Cheat)

### Server Timestamp Validation

```dart
Future<Duration> calculateOfflineTime() async {
  final deviceTime = DateTime.now();
  final serverTime = await FirebaseTimestamp.getServerTime();

  final drift = (deviceTime.difference(serverTime)).abs();

  if (drift > Duration(minutes: 5)) {
    // Time manipulation detected
    Analytics.log('time_cheat_detected', drift: drift);
    Crashlytics.log('Suspicious time drift: $drift');
    return Duration.zero; // No offline rewards
  }

  return serverTime.difference(lastLogoutTime);
}
```

### Edge Cases

| Scenario | Handling |
|----------|----------|
| Device time backward | Use 0 minutes offline |
| Farm demolished | No offline production |
| Game crash | Last logoutTime not updated (no production) |
| Time > 30 days | Cap at 30 days max (prevent exploits) |

---

## 6. Data Persistence

### Storage Schema

```dart
class OfflineData {
  DateTime lastLogoutTime;
  int lastSessionGold;
  int lastOfflineMinutes;
  List<ResourceStack> farmQueueAtLogout;
  bool adWatchedThisSession;
}
```

### Hive Box Structure

```dart
// On app close
final box = Hive.box<OfflineData>('offlineData');
box.put('lastSession', OfflineData(
  lastLogoutTime: DateTime.now(),
  farmQueueAtLogout: farmBuilding.inputBuffer,
));

// On app open
final offlineData = box.get('lastSession');
if (offlineData != null) {
  final rewards = calculateOfflineRewards(offlineData);
  showWelcomeBackModal(rewards);
}
```

---

## 7. Offline Calculation Timing

**When Calculated:**
- On game launch, if lastLogoutTime exists
- Before any player action
- Used to populate welcome notification
- Farm input buffer updated

---

## Dependencies

**Depends On:**
- ✅ EPIC-01 (Core Gameplay Loop)
- ✅ EPIC-02 (Farm building, resources, skills)
- ✅ EPIC-03 (Conveyor chains for Tier 2 calculation)

**Blocks:**
- → EPIC-08 (Monetization - ad boost integration)

---

## Testing Requirements

### Unit Tests

- [ ] Offline calculation formula accuracy (20 tests)
- [ ] 80% efficiency applied correctly
- [ ] Buffer cap respects queue length
- [ ] Trading skill bonus applies
- [ ] Time limits enforced (12h/24h)
- [ ] Time validation rejects manipulation

### Integration Tests

- [ ] Full offline session: logout → 2h → login → modal
- [ ] Ad reward doubles correctly
- [ ] Data persists across app restarts
- [ ] Welcome modal displays correct amounts

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Calculation Performance | <50ms for 20 buildings + 50 conveyors |
| Accuracy | 100% correct for Tier 1, 95% for Tier 2 |
| Ad Adoption | 60%+ players watch ad for 2× boost |
| Day 1 Retention | +15% vs no offline production |
| Day 7 Retention | +10% vs no offline production |

---

## Premium Features (Future - NOT MVP)

These are outlined but NOT in MVP scope:
- Offline production > 100% (premium boost)
- Skip welcome notification (premium setting)
- Offline time multiplier (2× production, premium)
- Scheduled farming (set production for specific hours)
- Push notifications: "Your factory produced 10k gold!"

---

**Status:** 📋 Ready for Implementation
**Last Updated:** 2025-12-03
**Version:** 2.0 (Merged from Epic 2 SYSTEMS.md)
