# Epic 2 Deep Dive Analysis - Błędy, Niezgodności, Pytania

<!-- AI-INDEX: epic-2, analysis, bugs, inconsistencies, issues, economics, validation -->

**Date:** 2025-12-02
**Analyzer:** Claude (Code Quality Agent)
**Scope:** Complete Epic 2 documentation review
**Status:** 🔴 CRITICAL ISSUES FOUND - See below

---

## Executive Summary

Przeanalizowałem 3 dokumenty Epic 2:
1. `tech-spec-epic-02.md` (840 lines)
2. `sprint-planning-epic-2.md` (730 lines)
3. `epics-stories-trade-factory-masters-2025-11-17.md` (200 lines)

**Znalazłem:**
- 🔴 **3 CRITICAL błędy ekonomiczne** (mogą całkowicie złamać balans gry)
- 🟠 **7 MEDIUM niezgodności** między dokumentami
- 🟡 **9 LOW pytań wymagających wyjaśnienia**

---

## 🔴 CRITICAL ISSUES (Muszą być naprawione)

### Critical Issue #1: SPRZECZNA Specyfikacja Zasobów

**Problem:** Liczba zasobów jest różna w każdym dokumencie!

**tech-spec-epic-02.md:**
```
Line 33-37: "7 typów zasobów, 5 w Tier 1"
- Podstawowe: Wood, Ore, Food (3)
- Średniozaawansowane: Bars (1)
- Zaawansowane: Tools (1)
- Tier 2: Circuits, Machines (2 - ale "nie implementowane w tym epiku")
TOTAL = 7? Ale czemu Food jest jeśli:
```

**sprint-planning-epic-2.md:**
```
Line 18: "7 zasobów (Wood, Ore, Bars, Tools, Stone, Clay, Bricks)"
CAŁKOWICIE INNE zasoby!!!

List zasobów z lines 18:
1. Wood
2. Ore
3. Bars
4. Tools
5. Stone  ← NIE MA W TECH SPEC!
6. Clay   ← NIE MA W TECH SPEC!
7. Bricks ← NIE MA W TECH SPEC!

A Food, Circuits, Machines??? Zniknęły!
```

**Resource Definitions w tech-spec (lines 209-227):**
```dart
class ResourceDefinitions {
  static final Map<String, ResourceDefinition> tier1 = {
    'wood': ...,
    'ore': ...,
    // ... 'Food, Bars, Tools' mentioned but NOT in example
  };
}
```

**❓ PYTANIA:**

1. **Które zasoby są rzeczywiście w Tier 1?**
   - Tech spec mówi: Wood, Ore, Food, Bars, Tools (5 zasobów)
   - Sprint planning mówi: Wood, Ore, Bars, Tools, Stone, Clay, Bricks (7 zasobów)
   - **Która specyfikacja jest prawidłowa?**

2. **Co z Food?**
   - Tech spec wymienia Food jako "Podstawowe" (produkuje Farm)
   - Sprint planning zupełnie nie wspomina Food
   - Czy Food powinno być w grze czy nie?

3. **Stone, Clay, Bricks?**
   - Pojawia się w sprint planning ale **nigdzie nie ma ich definicji w tech spec**
   - Które budynki je produkują?
   - Jakie mają ceny?
   - Do czego służą?

**Impact:** 🔴 CRITICAL
- Jeśli zasoby się zmienią, wszystkie ceny ekonomiczne będą błędne
- Jeśli brakuje zasobów w tech spec, ci devloprzy będą mieć niekompletne specyfikacje
- Unit testy będą testować złe zasoby

**Fix Required:** Uzgodnij listę zasobów raz na zawsze i uaktualnij oba dokumenty.

---

### Critical Issue #2: Sprzeczne Ceny Zasobów

**Scenariusz 1: Tech Spec (lines 216-225)**

```dart
'wood': baseMarketPrice: 5,
'ore': baseMarketPrice: 7,
'food': baseMarketPrice: 4,
'bars': baseMarketPrice: 15,
'tools': baseMarketPrice: 40,
```

**Buy Price = basePrice × 1.2:**
- Wood: 5 × 1.2 = **6 gold**
- Ore: 7 × 1.2 = **8.4g** (czy rounding do 8 czy 9?)
- Bars: 15 × 1.2 = **18g**
- Tools: 40 × 1.2 = **48g**

**Sell Price = basePrice × 0.8:**
- Wood: 5 × 0.8 = **4 gold**
- Ore: 7 × 0.8 = **5.6g** (czy rounding do 5 czy 6?)
- Bars: 15 × 0.8 = **12g**
- Tools: 40 × 0.8 = **32g**

**Scenariusz 2: Sprint Planning (lines 133)**

```
Wood 5g, Ore 7g, Bars 15g, Tools 30g, Stone 3g, Clay 4g, Bricks 12g
```

**SPRZECZNOŚĆ:** Tools to 40g w tech spec ale 30g w sprint planning!

**MarketTransaction Use Case (tech-spec, lines 284):**
```dart
final buyPrice = (resource.baseMarketPrice * 1.2).toInt();
```

**❓ PYTANIE: Jak zaokrąglać ułamkowe ceny?**

Przykład: Ore 7 × 1.2 = 8.4g
- `.toInt()` zwróci 8g
- Ale co jeśli chcemy 8g czy 9g?

**Ryzyko:** 🔴 CRITICAL
- Jeśli Tools = 30g vs 40g, cała ekonomia zmienia się
- Zaokrąglanie może spowodować arbitrage loops:
  - Jeśli Buy price = 8g, Sell price = 6g
  - A jakiś crafting daje profit = mogą być pętle arbitrażu

---

### Critical Issue #3: Sprzeczna Produkcja Zasobów

**Tech Spec mówi (lines 26-31, lines 196-200):**

```
Lumbermill - produkuje Wood (1 Wood/min)
Mine - produkuje Ore (1 Ore/min)
Farm - produkuje Food (1 Food/min)
Smelter - przetwarza Wood + Ore → Bars (0.5 Bars/min)
Workshop - przetwarza 2 Bars + 1 Ore → Tools (0.33 Tools/min)
```

**Sprint Planning mówi (line 95):**

```
Produkcja zbalansowana (1 Wood/min = 1 Ore/min = 0.5 Bars/min)
```

**Ale nigdzie nie ma specyfikacji jak pracują Smelter + Workshop!**

**❓ PYTANIA:**

1. **Smelter production rate - co to znaczy?**
   - "0.5 Bars/min" - to jaki jest input rate?
   - Czy to znaczy: "Potrzebuję 2 Wood + 2 Ore żeby dostać 1 Bars w ciągu 2 minut?"
   - Czy "Potrzebuję 1 Wood + 1 Ore żeby dostać 0.5 Bars per minute?"

2. **Workshop - 2 Bars + 1 Ore → 0.33 Tools/min**
   - Ile czasu trwa przetworzenie?
   - Czy to "per minute" czy "całkowity rate"?
   - Czy potrzebuję 2 Bar + 1 Ore per craftingu?

3. **Jak gracz transportuje zasoby między budynkami?**
   - Tech spec mówi "Manualne przenoszenie zasobów jest wymagane w Tier 1" (line 633)
   - Ale nigdzie nie ma specyfikacji MECHANIKI transportu!
   - Czy to "drag & drop", "tap & select", "conveyor system"?
   - **Conveyory są w EPIC-03, nie EPIC-02 - więc jak to działa bez nich???**

---

## 🟠 MEDIUM Issues (Poważne niezgodności)

### Medium Issue #4: Storage Capacity vs Production

**Tech Spec (lines 199, 261):**
```dart
storageCapacity: 10,  // Dla Lumbermill
```

**Ale:**
- Lumbermill produkuje 1 Wood/min
- W ciągu 10 minut zupełnie się zapełni
- Potem gracz będzie zmuszony sprzedawać co 10 minut
- **Czy to jest UX design czy bug?**

**❓ PYTANIE:** Czy storage capacity (10) jest celowe, czy powinno być większe (np. 100)?

---

### Medium Issue #5: Building Definitions brakuje kluczowych informacji

**Tech Spec (lines 189-204):**
```dart
static final Map<BuildingType, BuildingDefinition> tier1 = {
  BuildingType.lumbermill: BuildingDefinition(
    type: BuildingType.lumbermill,
    displayName: 'Lumbermill',
    description: 'Produkuje Wood z lasów',
    costs: BuildingCosts(construction: 100, upgradeTier1: [120, 140, 160, 180]),
    // ... production config
  ),
};
```

**Ale brakuje:**
1. **Grid size** - czy Lumbermill to 2×2 czy 3×3 tiles?
   - Tech spec mówi (line 602): "64×64px dla 2×2 buildings, 96×96px dla 3×3 buildings"
   - Ale które budynki jakie rozmiary mają?

2. **Upgrade formula validation**
   - Costs: [120, 140, 160, 180] - to liniowe?
   - Tech spec mówi (line 48): "Koszty liniowe: cost × level"
   - Ale [120, 140, 160, 180] to NIE jest liniowe!
   - To powinno być: [120, 240, 360, 480] jeśli базис = 120

3. **Production formula mismatch**
   - Tech spec (line 126-127):
   ```dart
   double get productionRate =>
     production.baseRate * (1 + (level - 1) * 0.2);
   ```
   - Level 1: 1.0x, Level 2: 1.2x, Level 3: 1.4x ✅
   - **ALE Building definitions w lines 195 nie pokazują jakiś będą production config!**

---

### Medium Issue #6: NPC Market - brakuje ključnych features

**Tech Spec (lines 39-43):**
```
- ✅ Stałe ceny (Buy Price = basePrice × 1.2, Sell Price = basePrice × 0.8)
- ✅ Interfejs z zakładkami BUY/SELL
- ✅ Slider do wyboru ilości (1-100)
- ✅ Transakcje z walidacją
```

**Sprint Planning (lines 157-182):**
```
- [BUY] [SELL] tabs
- Resource list with prices
- Slider for quantity
```

**ALE:**

1. **Brakuje UI elementów:**
   - Jak wygląda "Close" button?
   - Czy to bottom sheet czy fullscreen?
   - Jak animuje się? (Slide up, fade in, etc.)
   - **Tech spec nie specyfikuje!**

2. **Brakuje edge cases:**
   - Co jeśli gracz nie ma żadnych zasobów do sprzedania?
   - Co jeśli gracz nie ma żadnego złota do kupienia?
   - Czy buttony są disabled czy hidden?
   - **Nie ma specyfikacji!**

3. **Brakuje feedback:**
   - Czy jest toast notification po transakcji?
   - Czy jest haptic feedback? (Tech spec mówi yes, linia 164)
   - Czy jest floating text animation?
   - **Sprint planning nie specyfikuje!**

---

### Medium Issue #7: Economic Balance Test - Nierealistyczne założenia

**Tech Spec (lines 649-652):**
```
AC-5: Economic Balance
- [ ] Gracz może zarobić 1000 gold w 30 minut gameplay
- [ ] Kupowanie wszystkich inputów → strata
- [ ] Produkcja własnych inputów → zysk
- [ ] Nie ma arbitrage loops
```

**Sprint Planning (lines 330-351):**
```dart
test('Player earns 1000g in 30 minutes (Tier 1)', () {
  // Minute 0: Build Lumbermill (100g) → 400g left
  // Minute 5: Collect 5 Wood, sell for 20g → 420g
  // ... simulate 30 minutes
  expect(economy.gold, greaterThanOrEqualTo(1000));
});
```

**❓ PYTANIE: Czy to jest realistyczne?**

**Scenario:**
- Starting gold: 500g
- Build Lumbermill: -100g (gold = 400)
- Lumbermill produces 1 Wood/min × 5 min = 5 Wood
- Sell 5 Wood @ 4g each = +20g (gold = 420)

**Do osiągnąć 1000g potrzebujesz +580g.**

- Jeśli sprzedajesz 5 Wood co 5 minut = +20g co 5 minut
- Potrzebujesz 580 ÷ 20 = 29 × 5 minut = **145 minut (2.4 godziny!)**

**Ale test mówi "30 minut"! To niemożliwe!**

**Czy to powinno być:**
- 1000g w 2+ godziny? (realistyczne)
- Czy zasoby powinny być droższe? (np. Wood = 10g nie 4g)
- Czy gracz powinien zarabiać szybciej?

---

### Medium Issue #8: Building Placement Logic - incomplete

**Tech Spec (lines 277-302):**
```dart
class BuildingPlacementSystem {
  bool isValidPlacement(...) {
    // Check grid bounds
    // Check occupied tiles
    return !existingBuildings.any((b) => b.gridPosition == gridPosition);
  }
}
```

**ALE:**

1. **Brakuje:**
   - Czy można budować na krawędzi gridu (x=49)?
   - Czy można budować w pozycji (0,0)?
   - Czy jest safe zone blisko startu?

2. **Grid size inconsistency:**
   - Tech spec mówi (line 50): "50×50 tiles"
   - Ale czy to 50×50 valid placements czy 50×50 tiles gdzie każdy zajmuje 2×2 lub 3×3?
   - **Nie ma jasności!**

3. **10 Building Limit:**
   - Tech spec mówi (line 715): "Limit 10 budynków w Tier 1"
   - Sprint planning mówi (line 272): "10 building limit (Tier 1) enforced"
   - **ALE: Z 50×50 gridem i 10 budynkami można mieć maksimum ~20-30% occupancy!**
   - Czy to jest celowe? Czy powinno być więcej budynków?

---

## 🟡 LOW Priority Questions

### Question #9: Farm - co to robi?

- Tech spec wymienia Farm produkuje Food (line 29)
- Sprint planning nie wspomina Food
- **Pytanie: Czy Food jest używany gdziekolwiek?**
  - Czy to jest tylko na sprzedaż?
  - Czy pracownicy je jedzą (ale workers są w Tier 2)?
  - Czy powinno być usunięte z Tier 1?

---

### Question #10: Market Building - co to robi?

- Tech spec wymienia "Market" jako building (line 92)
- **ALE nigdzie nie ma specyfikacji co robi!**
  - Czy to jest where NPC Market appears?
  - Czy gracz musi go zbudować żeby mieć dostęp do Market?
  - Czy to coś innego?

---

### Question #11: Upgrade costs formula error

**Tech Spec mówi (line 48):**
```
Koszty liniowe: cost × level
```

**Ale Building Definitions pokazuje (line 195):**
```
costs: BuildingCosts(construction: 100, upgradeTier1: [120, 140, 160, 180])
```

**To jest [120, 140, 160, 180] - czy to jest:**
- Liniowe: 120, 240, 360, 480? (NO - to co jest w array)
- Lub: 120+20, 140+20, 160+20, 180+20? (to co jest w array)

**❓ Która formuła jest prawidłowa?**

```dart
// Opcja A: costs[level] = costs[level-1] + 20
cost = baseCost + (level * incremental)  // Liniowe
// For level 1-5: 120, 140, 160, 180, 200

// Opcja B: costs[level] = costs[level] from array
// For level 1-5: 120, 140, 160, 180, ??? (brakuje 5 levelu!)

// Opcja C: costs[level] = baseCost × level
// For level 1-5: 120, 240, 360, 480, 600
```

---

### Question #12: MarketTransaction rounding errors

**Tech Spec (lines 284, 304):**
```dart
final buyPrice = (resource.baseMarketPrice * 1.2).toInt();
final sellPrice = (resource.baseMarketPrice * 0.8).toInt();
```

**Problem: `.toInt()` truncates, not rounds!**

Example: Ore (7g)
- buyPrice = (7 × 1.2).toInt() = 8.4.toInt() = **8g** (lost 0.4g)
- sellPrice = (7 × 0.8).toInt() = 5.6.toInt() = **5g** (lost 0.6g)

**Cumulative error over many transactions:**
- Sell 100 Ore @ 5.6g each = 560g
- But code gives 5g × 100 = 500g
- **Lost 60g!**

**❓ Pytanie: Czy to jest celowe czy bug?**
- Może should be `.round()` zamiast `.toInt()`?
- Lub keep prices w integers (Wood=5, Ore=8, itd.)?

---

### Question #13: CollectResourcesUseCase - nie uwzględnia inputów

**Tech Spec mówi (line 243-272):**
```dart
class CollectResourcesUseCase {
  Result<PlayerEconomy, CollectionError> execute(...) {
    // Calculate produced
    final produced = (building.productionRate * minutesElapsed).toInt();
  }
}
```

**ALE co z budynkami wymagającymi inputów?**
- Smelter wymaga Wood + Ore
- Workshop wymaga Bars + Ore
- **Ale CollectResourcesUseCase nie sprawdza czy są inputy!**

**❓ Pytanie: Czy to będzie implementowane w Story-02.4?**
- Czy gracz manualnie musi transportować zasoby do Smelter?
- Czy Smelter automatycznie bierze z inventory?
- Czy użytkownik musi mieć zasoby na hand a potem "craft" button?

---

### Question #14: Production rate formula for upgraded buildings

**Tech Spec mówi (line 126-127):**
```dart
double get productionRate =>
  production.baseRate * (1 + (level - 1) * 0.2);
```

**Ale nigdzie nie specyfikuje jak collectResourcesUseCase aktualizuje building.lastCollected po upgrade!**

**Scenariusz:**
1. Level 1 Lumbermill: baseRate = 1.0/min
2. Upgreide to Level 2: baseRate = 1.2/min
3. Collect now?

**❓ Pytanie:**
- Czy upgrade resetuje timer? (tak - sensowne)
- Czy upgrade zwraca zasoby które zostały w starym rate? (fair mechanic?)
- Czy nowy rate obowiązuje do natychmiast?

---

### Question #15: Grid position representation

**Tech Spec (lines 119, 165):**
```dart
final Point<int> gridPosition;  // (x, y) na gridzie 50×50
```

**Sprint Planning (lines 275-279):**
```dart
if (gridPosition.x < 0 || gridPosition.x >= 50) return false;
if (gridPosition.y < 0 || gridPosition.y >= 50) return false;
```

**❓ Pytania:**
- Czy gridy są 0-indexed (0-49) czy 1-indexed (1-50)?
- Tech spec mówi "50×50 grid" - czy to 2500 tiles czy 2500 cells?
- Czy Point<int> to best reprezentacja czy powinno być custom GridPosition?

---

## 📊 Podsumowanie Issues

| # | Title | Severity | Category | Fix Time | Depends On |
|---|-------|----------|----------|----------|-----------|
| 1 | Resource mismatch (5 vs 7) | 🔴 CRITICAL | Spec | 30 min | Decision |
| 2 | Tools price (30g vs 40g) | 🔴 CRITICAL | Spec | 15 min | Decision |
| 3 | Smelter/Workshop production unclear | 🔴 CRITICAL | Spec | 30 min | Design |
| 4 | Storage capacity 10 (too small?) | 🟠 MEDIUM | Design | 15 min | Playtest |
| 5 | Building definitions incomplete | 🟠 MEDIUM | Spec | 30 min | Completion |
| 6 | NPC Market UI incomplete | 🟠 MEDIUM | Spec | 20 min | Design |
| 7 | Economic balance (1000g in 30m?) | 🟠 MEDIUM | Balance | 1-2 hours | Math |
| 8 | Building placement logic | 🟠 MEDIUM | Spec | 20 min | Clarification |
| 9 | Farm resource purpose | 🟡 LOW | Spec | 5 min | Decision |
| 10 | Market building role | 🟡 LOW | Spec | 10 min | Design |
| 11 | Upgrade costs formula | 🟡 LOW | Spec | 10 min | Clarification |
| 12 | Price rounding errors | 🟡 LOW | Code | 20 min | Implementation |
| 13 | Smelter inputs handling | 🟡 LOW | Spec | 30 min | Design |
| 14 | Production rate updates | 🟡 LOW | Spec | 10 min | Clarification |
| 15 | Grid position representation | 🟡 LOW | Tech | 15 min | Decision |

---

## ⚠️ RECOMMENDATIONS

### Immediate Actions (Before Starting Epic 2)

1. **Align Resource List** (CRITICAL)
   - Decide: 5 resources (Wood, Ore, Food, Bars, Tools) vs 7 resources (Wood, Ore, Bars, Tools, Stone, Clay, Bricks)?
   - Update BOTH documents
   - Create ResourceDefinitions class with ALL resources + prices

2. **Verify Economic Balance** (CRITICAL)
   - Calculate: Can player really earn 1000g in 30 minutes?
   - If not: adjust production rates or selling prices
   - Run simulation test BEFORE starting implementation

3. **Complete Building Definitions** (CRITICAL)
   - Specify: Grid size (2×2 or 3×3) for each building
   - Specify: Production config (inputs, rates) for Smelter + Workshop
   - Clarify: How does manual resource transport work?

4. **Fix Upgrade Costs** (MEDIUM)
   - Use consistent formula: either level-based array OR linear formula
   - Currently inconsistent between spec and code example

### Questions for Product Manager

1. **Farm Resource (Food):**
   - Is Food a real resource or should it be removed?
   - What game purpose does it serve?

2. **Market Building:**
   - Is this just flavor text or an actual gameplay mechanic?
   - Does player need to BUILD Market to access trading?

3. **10 Building Limit:**
   - Is this realistic for a 50×50 grid?
   - Should we increase to 20-30?

4. **Stone, Clay, Bricks:**
   - Why appear in sprint-planning but not in tech-spec?
   - Are these Tier 2 resources accidentally included?

5. **1000g in 30 minutes:**
   - Is this target realistic with current rates?
   - Or should we adjust production/selling prices?

---

## 🔗 Related Documents

- `/docs/sprint-artifacts/tech-spec-epic-02.md` - Technical specification
- `/docs/sprint-planning-epic-2.md` - Sprint planning with stories
- `/docs/epics-stories-trade-factory-masters-2025-11-17.md` - Story definitions

---

## Next Steps

### For You (Mariusz)

Please review this report and:
1. Clarify the resource list (5 vs 7)
2. Decide on Tools pricing (30g vs 40g)
3. Explain Smelter/Workshop production mechanics
4. Confirm if economic balance is achievable

### For Me (Claude)

Once you clarify these points, I can:
1. Create corrected Epic 2 specification
2. Identify any remaining inconsistencies
3. Generate implementation-ready story details
4. Create comprehensive acceptance criteria

---

## Status

🔴 **BLOCKED** on clarifications
⏳ **READY TO PROCEED** once critical questions answered

**Estimated Fix Time:** 1-2 hours to resolve all critical issues

---

**Document Owner:** Code Quality Review
**Last Updated:** 2025-12-02
**Next Review:** After answers to critical questions
