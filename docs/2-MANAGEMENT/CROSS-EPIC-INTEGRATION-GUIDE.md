# Cross-Epic Integration Guide

<!-- AI-INDEX: integration, dependencies, cross-epic, architecture -->

**Version:** 1.0
**Date:** 2025-12-03
**Purpose:** Document how epics interact and share data/systems

---

## Overview

Trade Factory Masters składa się z 12 epiców (00-11). Ten dokument opisuje jak poszczególne epiki się integrują i zależą od siebie.

---

## Critical Path

```
EPIC-00 (13 SP) ✅
    │
    ▼
EPIC-01 (34 SP) ✅
    │
    ▼
EPIC-02 (26 SP)  ← Sprint 2-3
    │
    ▼
EPIC-03 (42 SP)  ← Sprint 4-5 [LONGEST]
    │
    ├─────────────────────────┐
    ▼                         ▼
EPIC-04 (26 SP)          EPIC-06 (28 SP)
    │                         │
    │                         ▼
    │                    EPIC-07 (21 SP)
    │
    ├─────────────────────────┐
    ▼                         ▼
EPIC-08 (23 SP)          EPIC-09 (24 SP)
    │                         │
    └────────────┬────────────┘
                 ▼
           EPIC-10 (13 SP)
                 │
                 ▼
           EPIC-11 (20 SP)
                 │
                 ▼
            🚀 MVP LAUNCH
```

---

## Epic Dependencies Matrix

| Epic | Depends On | Blocks | Shared Systems |
|------|------------|--------|----------------|
| **00** | - | 01, 05, 09 | Firebase, Hive, Project Structure |
| **01** | 00 | 02, 03, 05, 07 | Building, Grid, Camera |
| **02** | 01 | 03, 04, 05 | Resources, NPCs, Economy |
| **03** | 02 | 04, 06 | Conveyor, A* Pathfinding |
| **04** | 03 | 06, 07 | Offline Calculator, Welcome Back |
| **05** | 00, 02 | 08 | Touch Controls, UI Framework |
| **06** | 03, 04 | 07 | Tier System, Achievements |
| **07** | 04, 06 | 10 | Tutorial State Machine |
| **08** | 05, 09 | 10 | IAP, Ads, Shop |
| **09** | 00 | 04, 08, 10 | Auth, Cloud Save, Security |
| **10** | 08, 09 | 11 | Analytics Events |
| **11** | 10 | - | Testing Infrastructure |

---

## Shared Data Structures

### PlayerEconomy (Wszystkie Epiki)

```dart
class PlayerEconomy {
  final int gold;                      // EPIC-01, 02, 08
  final Map<String, Resource> inventory; // EPIC-01, 02, 03
  final List<Building> buildings;      // EPIC-01, 02, 03
  final int tier;                      // EPIC-02, 06
  final DateTime lastSeen;             // EPIC-04, 09
}
```

**Użycie po epikach:**
- **EPIC-01:** Tworzenie podstawowej struktury
- **EPIC-02:** Rozszerzenie o inventory i tier
- **EPIC-03:** Dodanie conveyorów
- **EPIC-04:** Wykorzystanie `lastSeen` dla offline
- **EPIC-09:** Serializacja do Firestore

### Building Entity (EPIC-01, 02, 03)

```dart
enum BuildingType {
  mining,   // EPIC-02: Wydobycie surowców
  storage,  // EPIC-02: Przechowywanie
  smelter,  // EPIC-02: Przetwarzanie
  conveyor, // EPIC-03: Transport
  workshop, // EPIC-02: Crafting
  farm,     // EPIC-02: Konwersja na gold
}
```

### Resource Types (EPIC-02, 03, 04)

```dart
// 7 Tier 1 Resources
final tier1Resources = [
  'coal',      // Węgiel
  'iron_ore',  // Ruda żelaza
  'wood',      // Drewno
  'stone',     // Kamień
  'copper',    // Miedź
  'salt',      // Sól
  'clay',      // Glina
];
```

---

## System Integration Points

### 1. Firebase Integration (EPIC-00 → EPIC-09)

**EPIC-00:** Konfiguracja Firebase (Auth, Firestore, Analytics)
**EPIC-09:** Full implementation (Cloud Save, Security Rules, Cloud Functions)

```dart
// Shared Firebase initialization (EPIC-00)
await Firebase.initializeApp();

// Cloud Save Service (EPIC-09)
class CloudSaveService {
  Future<void> saveGame(PlayerEconomy economy) async {
    await _firestore.doc('users/$userId/gameState').set(economy.toJson());
  }
}
```

### 2. Hive Local Storage (EPIC-00 → EPIC-04 → EPIC-09)

**EPIC-00:** Hive initialization, adapters registration
**EPIC-04:** Offline production storage
**EPIC-09:** Sync with Firestore

```dart
// Shared Hive adapters (EPIC-00)
Hive.registerAdapter(PlayerEconomyAdapter());
Hive.registerAdapter(BuildingAdapter());

// Offline storage (EPIC-04)
await Hive.box('gameState').put('lastSession', economy);

// Sync service (EPIC-09)
final local = await _hive.loadGameState();
final cloud = await _firestore.loadGameState();
// Use most recent...
```

### 3. Building System (EPIC-01 → EPIC-02 → EPIC-03)

**EPIC-01:** Building entity, placement, upgrade logic
**EPIC-02:** 6 specific building types with costs
**EPIC-03:** Conveyor connections and transport

```dart
// Building placement (EPIC-01)
void placeBuilding(Building building, GridPosition position);

// Building costs (EPIC-02)
final buildingCosts = {
  BuildingType.mining: {'wood': 0, 'stone': 0}, // FREE
  BuildingType.storage: {'wood': 5, 'stone': 10},
  BuildingType.smelter: {'wood': 15, 'stone': 10, 'copper': 5},
  // ...
};

// Conveyor connections (EPIC-03)
void connectBuildings(Building source, Building target, List<GridPosition> path);
```

### 4. Offline Production (EPIC-04 → EPIC-09)

**EPIC-04:** Offline calculator, Welcome Back modal
**EPIC-09:** Cloud Functions time validation (anti-cheat)

```dart
// Offline calculator (EPIC-04)
class OfflineProductionCalculator {
  OfflineProductionResult calculate(
    PlayerEconomy economy,
    Duration offlineTime,
    double efficiencyMultiplier, // 0.8 = 80%
  );
}

// Server validation (EPIC-09 Cloud Functions)
exports.validateOfflineProduction = functions.https.onCall(async (data) => {
  // Verify claimed time against server time
  // Return approved hours
});
```

### 5. Monetization (EPIC-08 ← EPIC-05, EPIC-09)

**EPIC-05:** Touch UI for shop screens
**EPIC-08:** IAP products, purchase flow
**EPIC-09:** Receipt validation via Cloud Functions

```dart
// Shop UI (EPIC-05)
class ShopScreen extends StatelessWidget {
  // Touch-optimized product tiles
}

// Purchase flow (EPIC-08)
class PurchaseManager {
  Future<PurchaseResult> purchase(String productId) async {
    // Platform IAP
    // Then validate with Cloud Function (EPIC-09)
  }
}
```

### 6. Analytics (EPIC-10 ← EPIC-07, EPIC-08, EPIC-09)

**EPIC-07:** Tutorial completion events
**EPIC-08:** Purchase events
**EPIC-09:** Firebase Analytics setup
**EPIC-10:** Custom events, funnels

```dart
// Tutorial events (EPIC-07)
analytics.logEvent('tutorial_step_completed', {'step': 3});

// Purchase events (EPIC-08)
analytics.logEvent('purchase_completed', {'product': 'gold_pack_5'});

// Custom gameplay events (EPIC-10)
analytics.logEvent('tier_unlocked', {'tier': 2, 'time_played': 3600});
```

---

## Cross-Epic Testing Strategy

### Unit Tests Per Epic

| Epic | Min Tests | Coverage Target |
|------|-----------|-----------------|
| 01 | 50 | 80% |
| 02 | 60 | 80% |
| 03 | 80 | 80% |
| 04 | 30 | 80% |
| 05 | 40 | 70% |
| 06 | 30 | 80% |
| 07 | 20 | 70% |
| 08 | 30 | 80% |
| 09 | 40 | 80% |
| 10 | 20 | 70% |
| 11 | - | Meta-testing |

### Integration Tests

```dart
// Cross-epic integration test example
testWidgets('Complete gameplay loop across epics', (tester) async {
  // EPIC-01: Place building
  await gameEngine.placeBuilding(BuildingType.mining, position);

  // EPIC-01: Collect resources
  final result = await collectResourcesUseCase.execute(building);

  // EPIC-02: Trade at NPC
  await tradingService.sellResource('wood', 10);

  // EPIC-03: Setup conveyor
  await conveyorService.connect(building1, building2);

  // EPIC-04: Simulate offline
  await offlineCalculator.calculate(economy, Duration(hours: 2));

  // EPIC-08: Purchase (mock)
  await purchaseManager.purchase('gold_pack_5');

  // EPIC-09: Sync to cloud
  await cloudSaveService.saveGame(economy);

  // Verify final state
  expect(economy.gold, greaterThan(1000));
});
```

---

## Performance Integration Points

### Memory Budget

| System | Max Memory | Epic |
|--------|------------|------|
| Grid (50×50) | 5 MB | EPIC-01 |
| Buildings (100) | 2 MB | EPIC-02 |
| Conveyors (50) | 3 MB | EPIC-03 |
| Hive cache | 10 MB | EPIC-00, 04, 09 |
| UI textures | 20 MB | EPIC-05 |
| **Total** | **<50 MB** | - |

### Frame Time Budget

| System | Max ms | Epic |
|--------|--------|------|
| Grid render | 4 ms | EPIC-01 |
| Building update | 2 ms | EPIC-01, 02 |
| Conveyor transport | 3 ms | EPIC-03 |
| UI update | 4 ms | EPIC-05 |
| Input handling | 2 ms | EPIC-05 |
| **Total** | **<16 ms** | - |

---

## Migration Notes

### Breaking Changes Between Epics

**EPIC-01 → EPIC-02:**
- BuildingType changes from generic (`collector`, `processor`) to specific (`mining`, `smelter`, `workshop`, `farm`)
- ResourceType expansion from 1 to 7 types

**EPIC-02 → EPIC-03:**
- Building gains `connectedConveyors` property
- New Conveyor entity added

**EPIC-04 → EPIC-09:**
- PlayerEconomy gains cloud sync fields
- Security validation on all writes

---

## Quick Reference

### Which Epic For What?

| Need | Epic |
|------|------|
| Add new building type | EPIC-02 |
| Add new resource | EPIC-02 |
| Add conveyor feature | EPIC-03 |
| Modify offline logic | EPIC-04 |
| Touch/UI changes | EPIC-05 |
| Tier/progression changes | EPIC-06 |
| Tutorial changes | EPIC-07 |
| IAP/monetization | EPIC-08 |
| Cloud/auth changes | EPIC-09 |
| Analytics events | EPIC-10 |
| Test infrastructure | EPIC-11 |

---

**Status:** 📋 Active
**Last Updated:** 2025-12-03
**Version:** 1.0
