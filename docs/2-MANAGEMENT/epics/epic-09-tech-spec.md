# Epic 9: Firebase Backend - Technical Specification

<!-- AI-INDEX: epic, tech-spec, firebase, auth, cloud-save, security -->

**Epic:** EPIC-09 - Firebase Backend
**Total SP:** 24
**Duration:** 2 weeks (Sprints 1-2)
**Status:** 📋 Ready for Implementation
**Date:** 2025-12-03
**Priority:** P1 (High - infrastructure)

---

## Overview

EPIC-09 implementuje pełną integrację Firebase: autentykację (Anonymous → Google/Apple), cloud save z optymalizacją kosztów, security rules anti-cheat, oraz offline-first architekturę z Hive jako cache.

**Design Philosophy:** "Offline-first, cloud-synced" - gra działa bez internetu, sync w tle.

**Kluczowe cele:**
- **Anonymous-first auth** - natychmiastowy start bez rejestracji
- **Offline-first architecture** - Hive lokalnie, Firestore w chmurze
- **Cost optimization** - <$45/month przy 100k MAU
- **Anti-cheat rules** - server-side walidacja

---

## Objectives and Scope

### In Scope

**Firebase Authentication:**
- ✅ Anonymous sign-in (automatic on first launch)
- ✅ Google Sign-In upgrade (optional)
- ✅ Apple Sign-In upgrade (iOS, optional)
- ✅ Account linking (preserve progress)
- ✅ Sign-out option

**Cloud Save (Firestore):**
- ✅ Single-document schema: `/users/{userId}/gameState`
- ✅ Debounced saves (every 30 seconds)
- ✅ Last-write-wins conflict resolution
- ✅ Document size <1 MB

**Offline-First Architecture:**
- ✅ Hive as local cache (10× faster)
- ✅ Load order: Hive first → Firestore fallback
- ✅ Sync on app resume
- ✅ Conflict resolution via timestamps

**Security Rules:**
- ✅ User can only access own data
- ✅ Gold increase limit: max +10,000/write
- ✅ Building count validation
- ✅ Tier progression validation
- ✅ 20 security rule tests

**Cost Monitoring:**
- ✅ Budget alerts ($50/month)
- ✅ Firestore quota monitoring
- ✅ Cost optimization strategy

**Cloud Functions (REQUIRED for MVP):**
- ✅ Time validation function (anti-cheat for offline production)
- ✅ Receipt validation function (IAP verification)
- ✅ Server-side gold increment validation
- ✅ Suspicious activity detection
- ✅ Function deployment via Firebase CLI

### Out of Scope

- ❌ Real-time multiplayer sync (v2.0)
- ❌ Social features (leaderboards - Phase 2)
- ❌ Custom authentication providers
- ❌ Advanced analytics (see EPIC-10)

---

## System Architecture

### Domain Layer
```
lib/domain/entities/
├── user_profile.dart            # User profile entity
└── sync_state.dart              # Sync status tracking

lib/domain/usecases/
└── auth/
    ├── sign_in_anonymous_usecase.dart
    ├── upgrade_to_google_usecase.dart
    └── sign_out_usecase.dart
```

### Data Layer
```
lib/data/
├── services/
│   ├── auth_service.dart        # Firebase Auth wrapper
│   ├── cloud_save_service.dart  # Firestore operations
│   └── sync_service.dart        # Hive + Firestore sync
├── datasources/
│   ├── local/
│   │   └── hive_datasource.dart # Local storage
│   └── remote/
│       └── firestore_datasource.dart
└── repositories/
    └── user_repository_impl.dart
```

---

## Firestore Schema

```javascript
/users/{userId}/
  - profile: {
      displayName: string,
      createdAt: timestamp,
      tier: number,
      totalPlayTime: number,
    }

  - gameState: {
      gold: number,
      tier: number,
      lastSeen: timestamp,
      buildings: [
        { id, type, level, gridPosition: {x, y}, lastCollected },
        ...
      ],
      inventory: {
        wood: { amount, maxCapacity },
        ore: { amount, maxCapacity },
        ...
      },
      conveyors: [
        { id, startBuildingId, endBuildingId, path: [{x, y}, ...] },
        ...
      ],
    }

  - purchases: {
      totalSpent: number,
      transactions: [
        { productId, price, timestamp },
        ...
      ],
    }
```

---

## Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /gameState {
        allow read: if request.auth.uid == userId;
        allow write: if request.auth.uid == userId &&
                        validateGoldIncrease() &&
                        validateBuildingCount() &&
                        validateTierProgression();
      }
    }

    function validateGoldIncrease() {
      let oldGold = resource.data.gold;
      let newGold = request.resource.data.gold;
      return newGold - oldGold <= 10000; // Max 10k gold per save
    }

    function validateBuildingCount() {
      let buildingCount = request.resource.data.buildings.size();
      let tier = request.resource.data.tier;
      return tier == 1 ? buildingCount <= 10 : buildingCount <= 50;
    }

    function validateTierProgression() {
      let oldTier = resource.data.tier;
      let newTier = request.resource.data.tier;
      return newTier <= oldTier + 1; // Can only advance 1 tier at a time
    }
  }
}
```

---

## Sync Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                    SYNC ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────┐                     ┌─────────────┐          │
│   │  GAME   │                     │  FIRESTORE  │          │
│   │ ENGINE  │                     │   (Cloud)   │          │
│   └────┬────┘                     └──────┬──────┘          │
│        │                                 │                  │
│        │ Save (immediate)                │                  │
│        ▼                                 │                  │
│   ┌─────────┐     Sync (30s debounce)   │                  │
│   │  HIVE   │◄──────────────────────────►│                  │
│   │ (Local) │                            │                  │
│   └─────────┘                            │                  │
│        │                                 │                  │
│        │ Load (first priority)           │                  │
│        ▼                                 │                  │
│   ┌─────────┐     Fallback              │                  │
│   │   UI    │◄──────────────────────────┘                  │
│   └─────────┘                                              │
│                                                             │
│   ─────────────────────────────────────────────────────    │
│                  ON APP RESUME                             │
│   ─────────────────────────────────────────────────────    │
│   1. Load local (Hive)                                     │
│   2. Fetch remote (Firestore)                              │
│   3. Compare timestamps                                     │
│   4. Use most recent                                       │
│   5. Update cache if cloud is newer                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Cloud Functions Architecture

```javascript
// functions/src/index.ts

/**
 * Time Validation (Anti-Cheat for Offline Production)
 * Called when player claims offline resources
 * Validates that claimed time is reasonable
 */
export const validateOfflineProduction = functions.https.onCall(async (data, context) => {
  const { userId, claimedHours, lastSeen, buildings } = data;

  // Server-side time check
  const serverTime = admin.firestore.Timestamp.now();
  const timeDelta = serverTime.seconds - lastSeen;
  const maxHours = Math.min(claimedHours, 24); // 24h cap

  // Validate reasonable production
  if (claimedHours > timeDelta / 3600 * 1.1) { // 10% tolerance
    return { valid: false, reason: 'time_manipulation' };
  }

  return { valid: true, approvedHours: maxHours };
});

/**
 * Receipt Validation (IAP Verification)
 * Called after in-app purchase completion
 * Validates purchase receipt with platform
 */
export const validateReceipt = functions.https.onCall(async (data, context) => {
  const { platform, receipt, productId, userId } = data;

  // Validate with platform (Google Play / Apple App Store)
  const isValid = await validateWithPlatform(platform, receipt);

  if (isValid) {
    // Update user's purchase history
    await admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('purchases')
      .add({
        productId,
        timestamp: admin.firestore.Timestamp.now(),
        verified: true,
      });
  }

  return { valid: isValid };
});

/**
 * Suspicious Activity Detection
 * Triggered on unusual game state changes
 */
export const detectSuspiciousActivity = functions.firestore
  .document('users/{userId}/gameState')
  .onWrite(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Check for impossible gold gains
    if (after.gold - before.gold > 50000) {
      await flagUser(context.params.userId, 'impossible_gold_gain');
    }

    // Check for tier skip
    if (after.tier - before.tier > 1) {
      await flagUser(context.params.userId, 'tier_skip');
    }
  });
```

---

## Cost Projections

| MAU | Reads/day | Writes/day | Monthly Cost |
|-----|-----------|------------|--------------|
| 10k | 1M | 200k | ~$30/month |
| 50k | 5M | 1M | ~$90/month |
| 100k | 10M | 2M | ~$180/month |

**Optimization Targets:**
- Debounce writes: 30s → reduces writes by 90%
- Hive cache: reduces reads by 95%
- Target: <$45/month at 100k MAU (with optimizations)

---

## Performance Requirements

| Metric | Target |
|--------|--------|
| Anonymous auth | <500ms |
| Google/Apple auth | <2s |
| Hive load | <50ms |
| Firestore sync | <1s |
| Save debounce | 30s |

---

## Dependencies

**Depends On:**
- ✅ EPIC-00 (Firebase setup)

**Blocks:**
- → EPIC-08 (IAP receipt validation)
- → EPIC-10 (Analytics)
- → EPIC-04 (Cloud sync for offline)

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Auth success rate | 99%+ |
| Cloud sync reliability | 99.9% |
| Conflict resolution | 100% automated |
| Firebase costs | <$45/month at 100k MAU |
| Security rule tests | 20+ tests pass |

---

**Status:** 📋 Ready for Implementation
**Last Updated:** 2025-12-03
**Version:** 1.0
