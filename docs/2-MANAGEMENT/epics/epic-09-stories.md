# Epic 9: Firebase Backend - User Stories

<!-- AI-INDEX: epic, stories, firebase, auth, cloud-save, sync -->

**Epic:** EPIC-09 - Firebase Backend
**Total Stories:** 6
**Total SP:** 24
**Sprint:** 1-2
**Status:** 📋 Ready for Implementation

---

## Story Overview

| Story ID | Title | SP | Priority | Dependencies |
|----------|-------|-----|----------|--------------|
| STORY-09.1 | Firebase Authentication Flow | 5 | P0 | STORY-00.2 |
| STORY-09.2 | Firestore Cloud Save Schema | 5 | P0 | STORY-09.1 |
| STORY-09.3 | Offline-First Architecture | 6 | P0 | STORY-00.4, STORY-09.2 |
| STORY-09.4 | Security Rules Anti-Cheat | 3 | P0 | STORY-09.2 |
| STORY-09.5 | Cloud Functions (REQUIRED) | 3 | P0 | STORY-09.2 |
| STORY-09.6 | Firebase Cost Monitoring | 2 | P1 | STORY-09.2 |

---

## STORY-09.1: Firebase Authentication Flow

### Objective
Zaimplementować flow autentykacji Firebase z anonymous-first approach i opcjonalnym upgrade do Google/Apple.

### User Story
**As a** player
**I want** to sign in easily
**So that** my progress is saved automatically

### Description
System autentykacji rozpoczyna od anonymous sign-in przy pierwszym uruchomieniu (bez akcji gracza). Opcjonalnie gracz może upgrade'ować do Google/Apple Sign-In zachowując postęp.

### Acceptance Criteria

- [ ] **AC1:** Anonymous sign-in automatyczny przy pierwszym uruchomieniu
```dart
class AuthService {
  Future<User> signInAnonymously() async {
    final credential = await FirebaseAuth.instance.signInAnonymously();
    return credential.user!;
  }
}
```

- [ ] **AC2:** Google Sign-In upgrade (optional)
```dart
Future<User> upgradeToGoogle() async {
  final googleUser = await GoogleSignIn().signIn();
  final googleAuth = await googleUser!.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Link anonymous account with Google
  final currentUser = FirebaseAuth.instance.currentUser!;
  await currentUser.linkWithCredential(credential);
  return currentUser;
}
```

- [ ] **AC3:** Apple Sign-In upgrade (iOS only, optional)

- [ ] **AC4:** Account linking preserves all progress

- [ ] **AC5:** Sign-out option in Settings menu

### Implementation Notes

**Auth Flow:**
1. App launch → Check `FirebaseAuth.instance.currentUser`
2. If null → `signInAnonymously()` automatically
3. If exists → Use cached user
4. Optional: Settings → "Link Account" → Google/Apple

**Packages:**
- `firebase_auth: ^4.15.0`
- `google_sign_in: ^6.1.5`
- `sign_in_with_apple: ^5.0.0`

### Definition of Done
- [ ] Anonymous auth works automatically
- [ ] Google/Apple sign-in optional
- [ ] Account linking preserves progress
- [ ] Unit tests pass

**Story Points:** 5 SP
**Priority:** P1
**Sprint:** Sprint 1

---

## STORY-09.2: Firestore Cloud Save Schema

### Objective
Zaprojektować i zaimplementować optymalizowany schemat Firestore minimalizujący koszty.

### User Story
**As a** developer
**I want** optimized Firestore schema
**So that** costs are minimized

### Description
Single-document schema `/users/{userId}/gameState` z debounced writes (30s) i last-write-wins conflict resolution.

### Acceptance Criteria

- [ ] **AC1:** Schema structure: `/users/{userId}/gameState`
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
      buildings: [...],
      inventory: {...},
      conveyors: [...],
    }

  - purchases: {
      totalSpent: number,
      transactions: [...],
    }
```

- [ ] **AC2:** Document fields correctly serialized

- [ ] **AC3:** Max document size <1 MB validated

- [ ] **AC4:** Write strategy debounced (30 seconds)
```dart
class CloudSaveService {
  Timer? _saveTimer;

  void scheduleAutoSave(PlayerEconomy economy) {
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 30), () {
      _saveToFirestore(economy);
    });
  }
}
```

- [ ] **AC5:** Conflict resolution: Last-write-wins with timestamp

### Implementation Notes

**Cost Optimization:**
- Single document per user (not subcollections)
- Debounced writes reduce Firestore operations by 90%
- `lastSeen` timestamp for conflict resolution

### Definition of Done
- [ ] Schema optimized for cost
- [ ] Auto-save debounced (30s)
- [ ] Document size <1 MB validated
- [ ] Serialization/deserialization tests pass

**Story Points:** 5 SP
**Priority:** P1
**Sprint:** Sprint 1

---

## STORY-09.3: Offline-First Architecture (Hive + Firestore)

### Objective
Zaimplementować offline-first architekturę z Hive jako lokalnym cache i Firestore jako cloud storage.

### User Story
**As a** player
**I want** game to work offline
**So that** I can play anywhere

### Description
Gra zawsze działa offline dzięki Hive. Sync z Firestore w tle. On app resume - merge z last-write-wins strategy.

### Acceptance Criteria

- [ ] **AC1:** Hive as local cache (10× faster than Firestore)

- [ ] **AC2:** Load order: Hive first → Firestore fallback
```dart
class SyncService {
  Future<PlayerEconomy> loadGame() async {
    // Try Hive first (local)
    final local = await _hive.loadGameState();
    if (local != null) return local;

    // Fallback to Firestore (cloud)
    final cloud = await _firestore.loadGameState();
    if (cloud != null) {
      await _hive.saveGameState(cloud); // Cache locally
      return cloud;
    }

    // New player
    return PlayerEconomy.initial();
  }
}
```

- [ ] **AC3:** Save order: Hive immediately → Firestore debounced
```dart
Future<void> saveGame(PlayerEconomy economy) async {
  // Save to Hive immediately (fast)
  await _hive.saveGameState(economy);

  // Save to Firestore debounced (slow)
  _scheduledFirestoreSave(economy);
}
```

- [ ] **AC4:** Sync on app resume: Merge Hive + Firestore
```dart
Future<PlayerEconomy> syncOnResume() async {
  final local = await _hive.loadGameState();
  final cloud = await _firestore.loadGameState();

  // Merge: use most recent
  if (cloud != null && cloud.lastSeen.isAfter(local.lastSeen)) {
    await _hive.saveGameState(cloud);
    return cloud;
  }

  return local;
}
```

- [ ] **AC5:** Conflict resolution via timestamp comparison

### Implementation Notes

**Sync Strategy:**
1. Game changes → Save to Hive immediately (fast)
2. Timer (30s) → Batch save to Firestore
3. App resume → Compare timestamps, use most recent
4. Network restore → Sync pending changes

**Performance:**
- Hive load: <50ms
- Firestore sync: async background

### Definition of Done
- [ ] Offline play works (no Firestore required)
- [ ] Sync resolves conflicts correctly
- [ ] Performance: Hive loads in <50ms
- [ ] Integration tests pass

**Story Points:** 8 SP (complex sync logic)
**Priority:** P1
**Sprint:** Sprint 2

---

## STORY-09.4: Firestore Security Rules - Anti-Cheat

### Objective
Zaimplementować security rules zapobiegające cheatingowi poprzez server-side validation.

### User Story
**As a** developer
**I want** server-side validation
**So that** players can't cheat

### Description
Firestore security rules walidują każdy write: user ownership, gold limits, building counts, tier progression.

### Acceptance Criteria

- [ ] **AC1:** User can only read/write their own data
```javascript
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

- [ ] **AC2:** Gold can't increase by >10,000 in single write
```javascript
function validateGoldIncrease() {
  let oldGold = resource.data.gold;
  let newGold = request.resource.data.gold;
  return newGold - oldGold <= 10000;
}
```

- [ ] **AC3:** Buildings can't exceed max count (10 Tier 1, 50 Tier 2)
```javascript
function validateBuildingCount() {
  let buildingCount = request.resource.data.buildings.size();
  let tier = request.resource.data.tier;
  return tier == 1 ? buildingCount <= 10 : buildingCount <= 50;
}
```

- [ ] **AC4:** Tier can only increase by 1
```javascript
function validateTierProgression() {
  let oldTier = resource.data.tier;
  let newTier = request.resource.data.tier;
  return newTier <= oldTier + 1;
}
```

- [ ] **AC5:** 20 security rule tests pass (Firestore emulator)
```dart
// test/firestore_rules_test.dart
test('User can only read own data', () async {
  await expectFirestorePermissionDenied(
    path: '/users/user123/gameState',
    auth: 'user456', // Different user
    operation: 'get',
  );
});

test('Gold increase >10k rejected', () async {
  await expectFirestorePermissionDenied(
    path: '/users/user123/gameState',
    data: { gold: 50000 }, // Old: 30k, New: 50k = +20k (INVALID)
    operation: 'update',
  );
});
```

### Implementation Notes

**Rules File:** `firestore.rules`
**Testing:** Firebase Emulator Suite

### Definition of Done
- [ ] Security rules deployed
- [ ] 20 rule tests pass (Firestore emulator)
- [ ] Cheat attempts blocked

**Story Points:** 5 SP
**Priority:** P1
**Sprint:** Sprint 2

---

## STORY-09.5: Cloud Functions - Server Logic (REQUIRED for MVP)

### Objective
Zaimplementować Cloud Functions dla server-side walidacji (time validation, receipt validation).

### User Story
**As a** developer
**I want** Cloud Functions for server-side validation
**So that** players can't cheat offline production and IAP is secure

### Description
**REQUIRED dla MVP:** Funkcje time validation (anti-cheat dla offline produkcji) i receipt validation (weryfikacja zakupów IAP).

### Acceptance Criteria

- [ ] **AC1:** Cloud Function: `validateOfflineProduction` (time anti-cheat)
```javascript
// functions/src/index.ts
exports.validateOfflineProduction = functions.https.onCall(async (data, context) => {
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
```

- [ ] **AC2:** Cloud Function: `validateReceipt` (IAP receipt validation)
```javascript
exports.validateReceipt = functions.https.onCall(async (data, context) => {
  const { platform, receipt, productId, userId } = data;

  // Validate with platform (Google Play / Apple App Store)
  const isValid = await validateWithPlatform(platform, receipt);

  if (isValid) {
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
```

- [ ] **AC3:** Cloud Function: `detectSuspiciousActivity` (triggered on game state write)
```javascript
exports.detectSuspiciousActivity = functions.firestore
  .document('users/{userId}/gameState')
  .onWrite(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (after.gold - before.gold > 50000) {
      await flagUser(context.params.userId, 'impossible_gold_gain');
    }
  });
```

- [ ] **AC4:** Deploy to Firebase (Node.js 18 runtime)

- [ ] **AC5:** Dart client wrapper for Cloud Functions calls

### Implementation Notes

**THIS STORY IS REQUIRED FOR MVP.** Cloud Functions are critical for:
- Time validation (offline production anti-cheat)
- Receipt validation (IAP security)
- Suspicious activity detection

### Definition of Done
- [ ] Cloud Functions deployed
- [ ] Time validation works (blocks time manipulation)
- [ ] Receipt validation works (verifies IAP)
- [ ] Dart client wrapper tests pass

**Story Points:** 3 SP
**Priority:** P0 (REQUIRED)
**Sprint:** Sprint 9

---

## STORY-09.6: Firebase Cost Monitoring

### Objective
Skonfigurować monitoring kosztów Firebase z alertami budżetowymi.

### User Story
**As a** product manager
**I want** cost monitoring for Firebase
**So that** I don't exceed budget

### Description
Budget alerts, quota monitoring, cost optimization dashboard.

### Acceptance Criteria

- [ ] **AC1:** Firebase budget alert: Email if >$50/month

- [ ] **AC2:** Firestore quota monitoring: Reads, writes, deletes

- [ ] **AC3:** Analytics: Track read/write patterns

- [ ] **AC4:** Optimization: Identify expensive queries

- [ ] **AC5:** Target: <$45/month at 100k MAU

### Cost Breakdown (100k MAU - Before Optimization)
```
Firestore:
- Reads: 10M/day × $0.06/100k = $6/day = $180/month
- Writes: 2M/day × $0.18/100k = $3.60/day = $108/month
- Storage: 50 GB × $0.18/GB = $9/month

Cloud Functions (optional):
- 1M invocations × $0.40/M = $0.40/month

Firebase Analytics: FREE

Total: ~$300/month at 100k MAU (need optimization!)
```

### Optimization Strategy
- Reduce write frequency (30s debounce) → 90% reduction
- Use Hive for reads (10× cost reduction) → 95% reduction
- Compress game state JSON
- Target after optimization: <$45/month

### Definition of Done
- [ ] Budget alerts configured
- [ ] Cost dashboard visible
- [ ] Optimization plan documented

**Story Points:** 2 SP
**Priority:** P1
**Sprint:** Sprint 2

---

## Dependencies Graph

```
STORY-00.2 (Firebase Setup)
    │
    ▼
STORY-09.1 (Auth Flow)
    │
    ▼
STORY-09.2 (Cloud Save Schema)
    │
    ├──────────────────┬──────────────────┐
    ▼                  ▼                  ▼
STORY-09.3         STORY-09.4         STORY-09.5
(Offline-First)    (Security Rules)   (Cloud Functions)
                       │
                       ▼
                   STORY-09.6
                   (Cost Monitoring)
```

---

**Total:** 6 stories, 24 SP
**Status:** 📋 Ready for Implementation
**Last Updated:** 2025-12-03
