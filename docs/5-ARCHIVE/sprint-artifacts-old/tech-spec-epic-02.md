# Epic Technical Specification: EPIC-02 - Tier 1 Economy

Date: 2025-11-23
Author: Mariusz
Epic ID: EPIC-02
Status: Draft

---

## Overview

EPIC-02 implementuje fundament systemu ekonomicznego gry Trade Factory Masters - 5 typów budynków produkcyjnych, 7 zasobów oraz NPC Market z ustalonymi cenami. Epic ten wprowadza podstawowy loop ekonomiczny: produkcja zasobów → handel na rynku → zarabianie złota → rozbudowa fabryki.

System ekonomii Tier 1 jest zaprojektowany aby:
- Nauczyć graczy podstawowych mechanik ekonomicznych (kup tanio, sprzedaj drogo)
- Wprowadzić koncepcję łańcuchów produkcyjnych (Wood + Ore → Bars → Tools)
- Stworzyć motywację do automatyzacji (manualne przenoszenie zasobów jest żmudne → motywuje do Tier 2)
- Zapewnić 0-5 godzin rozgrywki przed odblokowaniem Tier 2

Kluczowym celem jest stworzenie satysfakcjonującego ale celowo żmudnego systemu, który naturalnie motywuje gracza do rozwoju w kierunku automatyzacji.

## Objectives and Scope

### In Scope

**Budynki (5 typów):**
- ✅ Lumbermill - produkuje Wood bez inputów (1 Wood/min)
- ✅ Mine - produkuje Ore bez inputów (1 Ore/min)
- ✅ Farm - produkuje Food bez inputów (1 Food/min)
- ✅ Smelter - przetwarza Wood + Ore → Bars (0.5 Bars/min)
- ✅ Workshop - przetwarza 2 Bars + 1 Ore → Tools (0.33 Tools/min)

**Zasoby (7 typów, 5 w Tier 1):**
- ✅ Podstawowe: Wood (5g), Ore (7g), Food (4g)
- ✅ Średniozaawansowane: Bars (15g)
- ✅ Zaawansowane: Tools (40g)
- ✅ Tier 2: Circuits, Machines (nie implementowane w tym epiku)

**NPC Market:**
- ✅ Stałe ceny (Buy Price = basePrice × 1.2, Sell Price = basePrice × 0.8)
- ✅ Interfejs z zakładkami BUY/SELL
- ✅ Slider do wyboru ilości (1-100)
- ✅ Transakcje z walidacją (insufficient gold, insufficient resources)

**System upgradów:**
- ✅ Budynki poziomów 1-5 w Tier 1
- ✅ Wzrost produkcji: baseRate × (1 + (level - 1) × 0.2)
- ✅ Koszty liniowe: cost × level

**Analityka:**
- ✅ Tracking zdarzeń: building_placed, building_upgraded, market_buy, market_sell, resource_collected

### Out of Scope

- ❌ Tier 2 zasoby (Circuits, Machines) - EPIC-03
- ❌ Automatyczne przenoszenie zasobów (conveyors) - EPIC-03
- ❌ Dynamiczne ceny rynkowe - nie planowane w Tier 1
- ❌ Handel między graczami - przyszła funkcjonalność
- ❌ Produkcja offline - EPIC-04
- ❌ Wymagania workers/wages - Tier 2 only

## System Architecture Alignment

Epic EPIC-02 wykorzystuje Clean Architecture z trzema warstwami:

**Domain Layer (Business Logic):**
- `Building` entity - reprezentuje budynek z produkcją
- `Resource` entity - reprezentuje zasób w inventory
- `PlayerEconomy` aggregate - zarządza stanem ekonomicznym gracza
- `CollectResourcesUseCase` - logika zbierania zasobów
- `UpgradeBuildingUseCase` - logika ulepszania budynków
- `MarketTransactionUseCase` - logika transakcji rynkowych

**Data Layer (Persistence):**
- Firestore schema: `/users/{userId}/gameState`, `/inventory/{resourceId}`, `/buildings/{buildingId}`
- `BuildingModel`, `ResourceModel` - modele z json_serializable
- `GameRepositoryImpl` - implementacja repozytorium
- Hive cache dla offline access

**Presentation Layer (UI):**
- Riverpod providers: `GameStateProvider`, `MarketProvider`
- Screens: Build Menu, Market Screen, Building Details Panel
- Optymistyczne aktualizacje UI (nie czekamy na Firebase)

**Integracja z Flame Engine:**
- `BuildingComponent` - renderuje budynki na gridzie
- `GridComponent` - 50×50 grid system
- Tap detection dla kolekcji zasobów

**Security:**
- Firestore Security Rules - walidacja po stronie serwera
- Anti-cheat: limit gold increases (+10000 max), level increments (+1 max)
- Rate limiting: max 10 building upgrades per minute

## Detailed Design

### Services and Modules

| Moduł | Odpowiedzialność | Input | Output | Owner |
|-------|------------------|-------|--------|-------|
| **BuildingDefinitions** | Statyczne definicje 5 typów budynków | BuildingType enum | BuildingDefinition | Domain |
| **ResourceDefinitions** | Statyczne definicje 7 zasobów | ResourceId string | ResourceDefinition | Domain |
| **CollectResourcesUseCase** | Logika zbierania zasobów z budynków | PlayerEconomy, Building | Updated PlayerEconomy | Domain |
| **UpgradeBuildingUseCase** | Logika ulepszania budynków | PlayerEconomy, Building | Updated PlayerEconomy | Domain |
| **MarketTransactionUseCase** | Logika kupna/sprzedaży na rynku | PlayerEconomy, ResourceId, qty | Transaction Result | Domain |
| **GameStateProvider** | State management (Riverpod) | UseCases | AsyncValue<PlayerEconomy> | Presentation |
| **MarketProvider** | State dla Market UI | MarketTransactionUseCase | MarketState | Presentation |
| **FirestoreDataSource** | Persistence do Firestore | PlayerEconomy | Future<void> | Data |
| **HiveDataSource** | Offline cache | PlayerEconomy | Future<void> | Data |

### Data Models and Contracts

**Building Entity (Domain):**
```dart
class Building {
  final String id;                  // "lumbermill_01"
  final BuildingType type;          // BuildingType.lumbermill
  final int level;                  // 1-5 w Tier 1
  final Point<int> gridPosition;    // (x, y) na gridzie 50×50
  final ProductionConfig production; // Konfiguracja produkcji
  final UpgradeConfig upgradeConfig; // Konfiguracja upgradów
  final DateTime lastCollected;     // Timestamp dla offline production

  // Computed property
  double get productionRate =>
    production.baseRate * (1 + (level - 1) * 0.2);
    // Level 1: 1.0x, Level 2: 1.2x, Level 3: 1.4x, etc.
}
```

**Resource Entity (Domain):**
```dart
class Resource {
  final String id;           // "wood", "ore", "food"
  final String displayName;  // "Wood", "Ore", "Food"
  final int amount;          // Aktualna ilość w inventory
  final int maxCapacity;     // Limit (1000 per resource)
  final String iconPath;     // Ścieżka do sprite'a
}
```

**PlayerEconomy Aggregate (Domain):**
```dart
class PlayerEconomy {
  final int gold;                              // Aktualny balans złota
  final Map<String, Resource> inventory;       // Wszystkie zasoby gracza
  final List<Building> buildings;              // Wszystkie postawione budynki

  // Methods
  PlayerEconomy deductGold(int amount);
  PlayerEconomy addGold(int amount);
  PlayerEconomy addResource(String resourceId, int amount);
  PlayerEconomy removeResource(String resourceId, int amount);
  bool canAfford(int goldCost);
}
```

**BuildingModel (Data Layer - Firestore):**
```dart
@JsonSerializable()
class BuildingModel {
  final String id;
  final String type;                // Stored as string
  final int level;
  @JsonKey(fromJson: _pointFromJson, toJson: _pointToJson)
  final Point<int> gridPosition;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime lastCollected;

  factory BuildingModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();

  Building toEntity(); // Konwersja do domain entity
}
```

**ProductionConfig:**
```dart
class ProductionConfig {
  final Resource outputResource;  // Co produkuje budynek
  final double baseRate;          // Jednostek na minutę (np. 1.0 Wood/min)
  final int storageCapacity;      // Ile budynek może przechowywać
  final Map<String, int>? inputs; // Opcjonalne inputy (dla Smelter, Workshop)
}
```

**BuildingDefinition (Static Data):**
```dart
class BuildingDefinitions {
  static final Map<BuildingType, BuildingDefinition> tier1 = {
    BuildingType.lumbermill: BuildingDefinition(
      type: BuildingType.lumbermill,
      displayName: 'Lumbermill',
      description: 'Produkuje Wood z lasów',
      costs: BuildingCosts(construction: 100, upgradeTier1: [120, 140, 160, 180]),
      production: ProductionConfig(
        outputResource: Resource(id: 'wood'),
        baseRate: 1.0,        // 1 Wood/min
        storageCapacity: 10,
      ),
    ),
    // ... Mine, Farm, Smelter, Workshop
  };
}
```

**ResourceDefinition (Static Data):**
```dart
class ResourceDefinitions {
  static final Map<String, ResourceDefinition> tier1 = {
    'wood': ResourceDefinition(
      id: 'wood',
      displayName: 'Wood',
      description: 'Drewno z drzew, używane do konstrukcji',
      iconPath: 'assets/images/resources/wood.png',
      baseMarketPrice: 5,    // 5 gold per Wood
    ),
    'ore': ResourceDefinition(
      id: 'ore',
      displayName: 'Ore',
      description: 'Ruda żelaza z kopalń',
      iconPath: 'assets/images/resources/ore.png',
      baseMarketPrice: 7,    // 7 gold per Ore
    ),
    // ... Food, Bars, Tools
  };
}
```

### APIs and Interfaces

**GameRepository Interface (Domain):**
```dart
abstract class GameRepository {
  Future<PlayerEconomy> loadGameState();
  Future<void> saveGameState(PlayerEconomy economy);
  Future<List<Building>> loadBuildings();
  Future<void> saveBuilding(Building building);
  Future<void> deleteBuilding(String buildingId);
}
```

**CollectResourcesUseCase:**
```dart
class CollectResourcesUseCase {
  Result<PlayerEconomy, CollectionError> execute(
    PlayerEconomy economy,
    Building building,
  ) {
    // Walidacja
    final now = DateTime.now();
    final timeSinceLastCollection = now.difference(building.lastCollected);
    final minutesElapsed = timeSinceLastCollection.inMinutes;

    if (minutesElapsed == 0) {
      return Failure(CollectionError.noResourcesReady);
    }

    // Kalkulacja produkcji
    final produced = (building.productionRate * minutesElapsed).toInt();
    final available = min(produced, building.production.storageCapacity);

    // Update economy
    final updatedEconomy = economy
        .addResource(building.production.outputResource.id, available);

    // Update building timestamp
    final updatedBuilding = building.copyWith(lastCollected: now);

    return Success(updatedEconomy);
  }
}
```

**MarketTransactionUseCase:**
```dart
class MarketTransactionUseCase {
  Result<PlayerEconomy, TransactionError> buyResource(
    PlayerEconomy economy,
    String resourceId,
    int quantity,
  ) {
    final resource = ResourceDefinitions.tier1[resourceId]!;
    final buyPrice = (resource.baseMarketPrice * 1.2).toInt();
    final totalCost = buyPrice * quantity;

    if (!economy.canAfford(totalCost)) {
      return Failure(TransactionError.insufficientGold);
    }

    final updatedEconomy = economy
        .deductGold(totalCost)
        .addResource(resourceId, quantity);

    return Success(updatedEconomy);
  }

  Result<PlayerEconomy, TransactionError> sellResource(
    PlayerEconomy economy,
    String resourceId,
    int quantity,
  ) {
    final resource = ResourceDefinitions.tier1[resourceId]!;
    final sellPrice = (resource.baseMarketPrice * 0.8).toInt();
    final totalRevenue = sellPrice * quantity;

    final currentAmount = economy.inventory[resourceId]?.amount ?? 0;
    if (currentAmount < quantity) {
      return Failure(TransactionError.insufficientResources);
    }

    final updatedEconomy = economy
        .addGold(totalRevenue)
        .removeResource(resourceId, quantity);

    return Success(updatedEconomy);
  }
}
```

**GameStateProvider (Riverpod):**
```dart
@riverpod
class GameState extends _$GameState {
  @override
  Future<PlayerEconomy> build() async {
    final repo = ref.read(gameRepositoryProvider);
    return await repo.loadGameState();
  }

  Future<void> collectResources(Building building) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final useCase = ref.read(collectResourcesUseCaseProvider);
      final result = useCase.execute(currentState, building);

      return result.fold(
        onSuccess: (newState) {
          // Background sync to Firestore (don't await)
          _syncToFirestore(newState);
          return newState;
        },
        onFailure: (error) => throw error,
      );
    });
  }

  void _syncToFirestore(PlayerEconomy economy) {
    final repo = ref.read(gameRepositoryProvider);
    repo.saveGameState(economy); // Fire-and-forget
  }
}
```

### Workflows and Sequencing

**Sequence: Player Collects Resources**
```
1. User taps building sprite (Presentation)
   ↓
2. TouchController detects tap → identifies Building (Flame)
   ↓
3. GameStateNotifier.collectResources(building) (Riverpod)
   ↓
4. CollectResourcesUseCase.execute(economy, building) (Domain)
   ↓
5. Calculates: minutesElapsed × productionRate = resources produced
   ↓
6. Updates PlayerEconomy.inventory (Domain)
   ↓
7. Returns new PlayerEconomy to Notifier
   ↓
8. UI updates immediately (optimistic update)
   ↓
9. Background: GameRepository.saveGameState() → Firestore
   ↓
10. Animation: Resource sprite flies to inventory bar
    ↓
11. Haptic feedback (light impact)
    ↓
12. Floating text: "+X Resource" appears
```

**Sequence: Player Buys Resource from Market**
```
1. User opens Market screen → taps BUY tab
   ↓
2. Selects resource (e.g., Wood)
   ↓
3. Adjusts slider → quantity = 25
   ↓
4. Button updates: "BUY 25 for 150g" (live calculation)
   ↓
5. User taps "BUY 25" button
   ↓
6. MarketProvider.buyResource('wood', 25)
   ↓
7. MarketTransactionUseCase.buyResource() validates
   ↓
8. Deducts 150 gold, adds 25 Wood to inventory
   ↓
9. Returns updated PlayerEconomy
   ↓
10. UI updates: Gold counter decreases, Wood count increases
    ↓
11. Green flash animation on button
    ↓
12. Floating text: "+25 Wood!"
    ↓
13. Haptic: Light impact
    ↓
14. Background: Sync to Firestore
    ↓
15. Analytics: logEvent('market_buy', {resource: 'wood', amount: 25, cost: 150})
```

**Sequence: Player Upgrades Building**
```
1. User taps building → Building Details Panel slides in
   ↓
2. Panel shows: Current level, production rate, upgrade cost
   ↓
3. User taps "Upgrade for 150g" button
   ↓
4. UpgradeBuildingUseCase.execute() validates
   ↓
5. Checks: economy.canAfford(150) && building.level < maxLevel
   ↓
6. Deducts 150 gold, increments building.level
   ↓
7. Calculates new productionRate: baseRate × (1 + (newLevel - 1) × 0.2)
   ↓
8. Returns updated PlayerEconomy + Building
   ↓
9. UI updates immediately
   ↓
10. Animation: Sparkle particles around building (20 particles)
     ↓
11. Building glows green (500ms pulse)
     ↓
12. Level indicator pops up with new number
     ↓
13. Floating text: "+20% production" (gold color)
     ↓
14. Haptic: Medium impact (celebration)
     ↓
15. Background: Sync to Firestore
     ↓
16. Analytics: logEvent('building_upgraded', {id, old_level, new_level, cost})
```

## Non-Functional Requirements

### Performance

**Response Times:**
- Market Interface Load: <200ms do otwarcia NPC Market
- Transaction Processing: <50ms dla operacji buy/sell
- Price Display: Wszystkie 7 cen zasobów widoczne jednocześnie (bez scrollowania)
- Building Placement: <100ms od tap do umieszczenia budynku
- Supply Chain Tooltips: <100ms load czasu dla recipe tooltips
- Collection: 60 FPS podczas zbierania zasobów (testowane z 10 budynkami)
- Tap Response: <50ms na urządzeniach budget Android (Snapdragon 660)

**Memory Constraints:**
- Building definitions: ~5 KB (static data)
- Resource definitions: ~3 KB (static data)
- Market UI state: ~10 KB
- Total dla EPIC-02 components: ~50 MB

**Firestore Costs:**
- Profile read: 1 document (at app launch)
- GameState read: 1 document (at app launch)
- Inventory read: 7 documents (Tier 1 resources)
- Buildings read: 10 documents (Tier 1 limit)
- **Total reads per session:** ~20 documents = $0.0000006 USD

### Security

**Firestore Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /gameState {
        allow write: if
          // Gold może rosnąć tylko o rozsądne kwoty
          request.resource.data.gold <= resource.data.gold + 10000 &&
          // Tier progression jest liniowa
          (request.resource.data.tier == resource.data.tier ||
           request.resource.data.tier == resource.data.tier + 1);
      }

      match /buildings/{buildingId} {
        allow write: if
          // Level może rosnąć tylko o 1 na raz
          request.resource.data.level <= resource.data.level + 1 &&
          // Level nie może przekroczyć limitów
          request.resource.data.level <= 10;
      }
    }
  }
}
```

**Anti-Cheat Measures:**
1. Server-Side Validation: Wszystkie transakcje ekonomiczne walidowane przez Cloud Functions
2. Rate Limiting: Max 10 building upgrades per minute
3. Anomaly Detection: Flagowanie użytkowników z niemożliwym progresem
4. Offline Cap: 12h/24h max offline production (EPIC-04)
5. Firestore Security Rules: Zapobieganie bezpośredniej manipulacji bazą danych

### Reliability/Availability

**Offline Support:**
- Hive cache przechowuje ostatni stan gry
- Gracze mogą grać offline, sync przy reconnect
- Conflict resolution: Last Write Wins (LWW)

**Error Handling:**
- Insufficient Gold → wyświetl toast: "Niewystarczająco złota!"
- Insufficient Resources → wyświetl toast: "Brak zasobów!"
- Network errors → retry z exponential backoff (3 próby)
- Firestore failures → fallback to Hive cache

**Data Consistency:**
- Optimistic updates dla UI (natychmiastowa reakcja)
- Background sync do Firestore (nie blokujemy UI)
- Rollback jeśli server odrzuca transakcję

### Observability

**Logging:**
- Debug: Building placement events
- Info: Market transactions (buy/sell amounts)
- Warning: Failed transactions (insufficient gold/resources)
- Error: Firestore sync failures

**Metrics (Firebase Analytics):**
- `building_placed`: {building_type, tier, gold_spent}
- `building_upgraded`: {building_id, old_level, new_level, cost}
- `market_buy`: {resource, amount, cost}
- `market_sell`: {resource, amount, earned}
- `resource_collected`: {building_id, resource_type, amount}

**Key Metrics to Monitor:**
- Building placement distribution (które budynki są popularne?)
- Resource production rates (czy gracze produkują wystarczająco?)
- Market transaction frequency (jak często buy vs sell?)
- Time to first advanced resource (Tools) produced
- Tier 1 completion time (target: 5 godzin do max out Tier 1)

**Performance Monitoring:**
- Firebase Performance SDK
- FPS tracking (Flame overlay)
- Transaction latency (Firestore response times)

## Dependencies and Integrations

### Internal Dependencies

**Required Before EPIC-02:**
- ✅ EPIC-00: Project Setup (Flutter, Flame, Riverpod setup)
- ✅ EPIC-01: Core Gameplay Loop (COLLECT/DECIDE/UPGRADE working)

**Blocks:**
- EPIC-03: Tier 2 Automation System (conveyors unlock po Tier 1)
- EPIC-06: Progression System (Tier 1 → Tier 2 unlock requirements)
- EPIC-07: Discovery-Based Tutorial (teach supply chains)

### External Dependencies

**Flutter Packages:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.12.0                    # Game engine
  flutter_riverpod: ^3.0.0          # State management
  riverpod_annotation: ^3.0.0       # Code generation
  json_annotation: ^4.8.0           # JSON serialization

dev_dependencies:
  riverpod_generator: ^3.0.0
  json_serializable: ^6.6.0
  build_runner: ^2.4.0
```

**Firebase Services:**
- Firebase Auth (user authentication)
- Firestore (game state persistence)
- Firebase Analytics (event tracking)
- Cloud Functions (server-side validation)

**Assets:**
- Resource sprites: `assets/resources/wood.png`, `ore.png`, `food.png`, `bars.png`, `tools.png`
- Building sprites: 64×64px dla 2×2 buildings, 96×96px dla 3×3 buildings
- UI icons: Build icon, Market icon, Upgrade icon

### Integration Points

**Flame Engine Integration:**
- `BuildingComponent` renderuje budynki na gridzie
- Tap detection dla kolekcji zasobów
- Animation system dla resource collection

**Riverpod Integration:**
- `GameStateProvider` zarządza stanem gry
- `MarketProvider` zarządza stanem Market UI
- Providers are watched by Widgets (auto-rebuild)

**Firestore Integration:**
- Collections: `/users/{userId}/gameState`, `/inventory`, `/buildings`
- Real-time listeners dla multiplayer (future feature)

## Acceptance Criteria (Authoritative)

### AC-1: Building Variety
- [ ] Wszystkie 5 budynków Tier 1 są możliwe do postawienia i funkcjonalne
- [ ] Każdy budynek produkuje poprawne zasoby z poprawnymi rate'ami
- [ ] Production formula: baseRate × (1 + (level - 1) × 0.2) działa poprawnie
- [ ] Poziomy 1-5 są dostępne w Tier 1

### AC-2: Supply Chain Functionality
- [ ] Podstawowe budynki (Lumbermill/Mine/Farm) produkują bez inputów
- [ ] Średniozaawansowane budynki (Smelter) wymagają poprawnych inputów
- [ ] Zaawansowane budynki (Workshop) obsługują multi-step chains poprawnie
- [ ] Manualne przenoszenie zasobów jest wymagane w Tier 1

### AC-3: Market Trading
- [ ] Wszystkie 7 zasobów są dostępne w NPC Market (5 w Tier 1)
- [ ] Ceny są STAŁE (nigdy się nie zmieniają w Tier 1)
- [ ] Transakcje buy/sell przetwarzają się poprawnie
- [ ] Kalkulacje profit/loss są widoczne dla gracza
- [ ] Buy Price = basePrice × 1.2
- [ ] Sell Price = basePrice × 0.8

### AC-4: Economic Learning
- [ ] Gracze rozumieją "produce your own inputs = profit" w ciągu 30 minut
- [ ] Supply chain tooltips wyjaśniają zależności jasno
- [ ] Tier 1 czuje się satysfakcjonujący ale żmudny (motywuje do Tier 2)

### AC-5: Economic Balance
- [ ] Gracz może zarobić 1000 gold w 30 minut gameplay
- [ ] Kupowanie wszystkich inputów → strata (np. 1 Tool kosztuje 46g w inputs, sprzedaje się za 40g)
- [ ] Produkcja własnych inputów → zysk (0g cost, 40g sell = 40g profit)
- [ ] Nie ma arbitrage loops (żadna kombinacja buy → craft → sell nie daje instant profit)

### AC-6: Building Upgrades
- [ ] Upgrade zwiększa produkcję o 20% per level
- [ ] Koszty upgradów są liniowe: baseCost × level
- [ ] Level cap w Tier 1: 5
- [ ] Upgrade animation działa (sparkles, glow, floating text)

### AC-7: Performance
- [ ] Market Interface Load Time: <200ms
- [ ] Transaction Processing: <50ms
- [ ] 60 FPS maintained podczas resource collection (10 buildings)
- [ ] <50ms tap response time na budget Android (Snapdragon 660)

### AC-8: Data Persistence
- [ ] Game state zapisuje się do Firestore po każdej akcji
- [ ] Offline cache w Hive działa
- [ ] Reload aplikacji przywraca ostatni stan gry
- [ ] Conflict resolution działa (Last Write Wins)

## Traceability Mapping

| AC | Spec Section | Components/APIs | Test Idea |
|----|--------------|-----------------|-----------|
| AC-1 | Building Definitions | BuildingDefinitions, BuildingComponent | Unit test: verify all 5 buildings exist with correct configs |
| AC-2 | Supply Chain | ProductionConfig, inputs field | Integration test: Smelter requires Wood+Ore, Workshop requires Bars+Ore |
| AC-3 | NPC Market | MarketTransactionUseCase, MarketProvider | Widget test: Buy/Sell transactions update gold/inventory |
| AC-4 | Economic Learning | Tooltips, UI feedback | Manual test: Playtester feedback after 30min session |
| AC-5 | Economic Balance | ResourceDefinitions.baseMarketPrice | Unit test: Verify no arbitrage (buy → craft → sell = loss without production) |
| AC-6 | Building Upgrades | UpgradeBuildingUseCase, upgrade animation | Integration test: Upgrade increases productionRate by 20% |
| AC-7 | Performance | All components | Performance test: FPS counter, stopwatch tap response |
| AC-8 | Data Persistence | GameRepository, Firestore/Hive | Integration test: Save → close app → reopen → verify state |

## Risks, Assumptions, Open Questions

### Risks

**RISK-1: Economic Balance Too Complex**
- Gracze mogą nie zrozumieć dlaczego kupowanie inputów = strata
- **Mitigation:** Tooltips wyjaśniające supply chains, tutorial pokazujący profitable production
- **Severity:** Medium
- **Probability:** Medium

**RISK-2: Firestore Costs Escalation**
- 20 dokumentów per session × 100k users = 2M reads/day = $0.12/day = $43/month
- **Mitigation:** Batch updates, cache aggressively w Hive
- **Severity:** Medium
- **Probability:** Low (only if 100k MAU reached quickly)

**RISK-3: Performance Degradation**
- 10 budynków × 60 FPS × resource animations = możliwe frame drops
- **Mitigation:** Sprite batching, object pooling, spatial culling
- **Severity:** High
- **Probability:** Low (prototyp już testowany)

### Assumptions

**ASSUMPTION-1:** Gracze mają wystarczająco motywacji aby grać 5 godzin w Tier 1
- Validated with: Playtesting sessions

**ASSUMPTION-2:** Stałe ceny w Tier 1 są wystarczająco interesujące
- Dynamic prices mogą być dodane w Tier 2 jeśli needed

**ASSUMPTION-3:** Limit 10 budynków w Tier 1 wymusza strategic choices
- Validated with: Economic model calculations

### Open Questions

**Q1:** Czy Food powinno mieć funkcję w Tier 1 oprócz sprzedaży?
- **Recommendation:** Nie, Food = tylko selling for gold w Tier 1, worker wages w Tier 2
- **Decision:** Zatwierdzone

**Q2:** Czy building placement powinno mieć adjacency restrictions?
- **Recommendation:** Nie w Tier 1 (add complexity w Tier 2 jeśli needed)
- **Decision:** Zatwierdzone

**Q3:** Czy grid sizes (2×2 vs 3×3) są intuitive dla graczy?
- **Recommendation:** Tak, visual hierarchy (basic = mały, advanced = duży)
- **Decision:** Zatwierdzone, verify w playtesting

## Test Strategy Summary

### Test Pyramid

```
         ┌───────────────┐
        /  E2E Tests (5%) \
       /     - 10 tests    \
      ┌─────────────────────┐
     /  Integration (15%)   \
    /    - 30 tests          \
   ┌───────────────────────────┐
  /   Unit Tests (80%)         \
 /     - 120+ tests             \
└─────────────────────────────────┘
```

### Unit Tests (120+ tests)

**Domain Layer Tests:**
- `building_test.dart`: Verify productionRate calculation (10 tests)
- `resource_test.dart`: Verify copyWith, immutability (8 tests)
- `player_economy_test.dart`: Test deductGold, addResource, canAfford (15 tests)
- `collect_resources_usecase_test.dart`: Test all edge cases (20 tests)
  - No resources ready → error
  - Resources ready → correct amount added
  - Storage capacity limit enforced
  - Timestamp updates correctly
- `upgrade_building_usecase_test.dart`: Test upgrade logic (15 tests)
  - Insufficient gold → error
  - Max level reached → error
  - Successful upgrade → level +1, productionRate increases
- `market_transaction_usecase_test.dart`: Test buy/sell (30 tests)
  - Buy with insufficient gold → error
  - Sell with insufficient resources → error
  - Correct prices applied (buy = 1.2×, sell = 0.8×)
  - No arbitrage (buy → sell = loss)

**Data Layer Tests:**
- `building_model_test.dart`: JSON serialization (10 tests)
- `game_repository_impl_test.dart`: Mock Firestore/Hive (12 tests)

### Integration Tests (30 tests)

**Game Flow Tests:**
- `place_building_test.dart`: Tap Build → Select → Place → Verify on grid
- `collect_resources_test.dart`: Place building → wait → tap → verify inventory
- `upgrade_building_test.dart`: Collect → tap upgrade → verify level +1
- `market_transaction_test.dart`: Open market → buy/sell → verify gold/inventory

**Firestore Integration:**
- `firestore_sync_test.dart`: Perform action → verify Firestore document updated

### E2E Tests (10 tests)

**Complete Gameplay Loops:**
- `tier1_economic_loop_test.dart`:
  1. Place Lumbermill
  2. Wait 1 minute (simulate time)
  3. Collect Wood
  4. Sell Wood at Market
  5. Verify gold increases
  6. Buy Ore
  7. Place Smelter
  8. Collect Bars
  9. Verify profitable production chain

### Performance Tests

**FPS Tests:**
```dart
test('Maintain 60 FPS with 10 buildings collecting simultaneously', () {
  // Setup: 10 buildings all ready to collect
  // Action: Tap all 10 in sequence
  // Assert: FPS stays >55 throughout
});
```

**Response Time Tests:**
```dart
test('Market transaction completes in <50ms', () {
  final stopwatch = Stopwatch()..start();
  await marketProvider.buyResource('wood', 10);
  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(50));
});
```

### Manual Testing Checklist

- [ ] Playtest 5-hour Tier 1 session (verify no boredom)
- [ ] Test on budget Android (Snapdragon 660) - verify 60 FPS
- [ ] Test on iPhone 8 - verify performance
- [ ] Verify tooltips are understandable (user feedback)
- [ ] Verify economic balance (can player earn 1000g in 30min?)
- [ ] Test offline mode → reconnect → verify sync

### Test Coverage Target

- **Domain Layer:** 90%+ coverage (business logic is critical)
- **Data Layer:** 80%+ coverage
- **Presentation Layer:** 70%+ coverage (widget tests)
- **Overall:** 80%+ coverage

---

**Status:** Ready for Implementation
**Next Steps:** Load SM agent and run `create-story` to begin implementing the first story under EPIC-02.
