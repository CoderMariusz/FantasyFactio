# Trade Factory Masters - Product Requirements Document

**Author:** Mariusz (CoderMariusz)
**Date:** 2025-11-17
**Version:** 1.0
**Status:** In Progress
**Product Brief:** docs/product-brief-trade-factory-masters-2025-11-17.md

---

## Executive Summary

**Trade Factory Masters** is a mobile factory automation game that fills a critical market gap: **desktop-quality automation for Factorio fans on mobile devices**. This PRD transforms the strategic vision (captured in Product Brief) into detailed, implementable requirements.

### Vision Alignment

3.5M+ Factorio players want a mobile version - but Factorio has no official mobile port planned. Mobile "factory builders" like Builderment (1.5M downloads) are too casual, simplifying mechanics for mass appeal. Trade Factory Masters proves that **mobile can handle mid-core complexity** by delivering Factorio-inspired depth optimized for touch controls and flexible session lengths (30s to 60min).

**Market Opportunity:** $135B mobile gaming industry + $400M SAM (factory automation + educational mobile games) with ZERO desktop-quality competitors on mobile.

### What Makes This Special

**"Factorio in 1 Tap"** - Progressive complexity unlock transforms automation into achievement:

1. **Conveyors are REWARDS, not starting features** - Players manually tap resources (Tier 1), creating desire for automation. Conveyors unlock at Tier 2 as achievement, triggering the "aha moment" that hooks players.

2. **Economic education through gameplay** - Supply/demand learned via events (dragon attacks drop wood supply → prices spike), not tutorials. Parents approve (68% prioritize educational value), players learn economics naturally.

3. **Ethical F2P ($10 complete game)** - Industry standard is $50-200 for "complete" F2P experience. TFM caps at $10 total, building trust and regulatory compliance (EU 2025 loot box laws favor transparency).

4. **Smart AI-assisted automation** - Player places START/END points, AI suggests optimal conveyor path (A* pathfinding), player confirms. Not tedious manual placement like desktop games.

5. **Offline production with O(1) calculation** - 1 week offline = 1ms calculation (not simulating every second). Respects player time, battery-friendly, differentiates from web idle games.

6. **Cross-platform ready** - Flutter/Flame native support: Mobile MVP → Desktop port in 3-4 weeks (85% code reuse validated in Technical Research).

---

## Project Classification

**Technical Type:** Mobile Game (Flutter/Flame)
**Domain:** Gaming - Factory Automation + Economics Education
**Complexity:** High (Mid-core game mechanics, mobile performance optimization, cross-platform)
**Target Platform:** Mobile-first (Android primary, iOS secondary), Desktop expansion (Month 6-7)
**Development Approach:** Solo indie, Enterprise BMAD Method (greenfield)

### Project Context

**Research Foundation:**
- Domain Research: 510 lines (mobile gaming industry 2025, ethical F2P movement, factory automation gap)
- Market Research: 677 lines (competitive analysis, revenue validation, Builderment competitor profile)
- Technical Research: 1,143 lines (Flutter/Flame 60 FPS validated, Firebase costs, Riverpod state management)
- Brainstorming: 6 technique sessions (Core Gameplay, Technical Challenges, MVP Scope, Retention, Monetization, Multiplayer)

**Key Validation:**
- ✅ Tech stack validated (60 FPS on Snapdragon 660 budget Android)
- ✅ Market gap confirmed (no desktop-quality automation on mobile)
- ✅ Firebase costs validated ($3/month for 10k users, $45/month for 100k)
- ✅ Revenue model validated ($20-30k Year 1 conservative, requires 35-40% D7 retention)

### Domain Context: Mobile Gaming (Mid-Core Segment)

**Industry Landscape (2025):**
- Mobile gaming market: $135B (growing 6.5% CAGR)
- Mid-core segment rising: 10 titles in top 200 grossing (vs 5 in 2023)
- Average D7 retention: 20% (mid-core), 40%+ (top performers)
- Industry LTV: $4-6 average, $10+ achievable with 40% D7 retention
- CPI (Cost Per Install): $2.03 mid-core vs $0.98 casual

**Regulatory Environment:**
- EU loot box regulations (2025) favor ethical F2P
- Brazil transparency laws favor upfront pricing
- COPPA compliance required (kids play mobile games: 73% US children <12 own device)

**Technical Constraints:**
- Budget device target: 60% of users on low-end Android (India, Africa markets)
- Performance expectation: 60 FPS standard, <3s load time, <1% crash rate
- Session length distribution: 40% short (30s-2min), 40% medium (5-10min), 20% long (30-60min)

**Monetization Standards:**
- Conversion rate: 2% industry standard (mid-core)
- ARPPU: $10-30 typical, $5-10 for ethical F2P
- Ad eCPM: $10-25 (US/EU markets)
- Rewarded video adoption: 60-80% of DAU willing to watch ads for rewards

---

## Success Criteria

### Critical Success Metrics (MVP Launch - First 30 Days)

**User Acquisition:**
- ✅ **10,000 organic downloads** (Reddit r/factorio + r/AndroidGaming + YouTube ASO)
  - **Measurement:** Google Play Console + App Store Connect download counts
  - **Target Breakdown:** 60% Android (6k), 40% iOS (4k)

**Retention (Make-or-Break Metric):**
- ✅ **D1 Retention: 45%+** (standard mid-core)
  - **Measurement:** Firebase Analytics cohort analysis
  - **Benchmark:** Industry mid-core average is 45%

- ✅ **D7 Retention: 30-35%** (minimum viable, target 35-40%)
  - **Measurement:** Firebase Analytics 7-day cohort retention
  - **Benchmark:** 20% industry average, 40% top 10% performers
  - **Critical:** <30% D7 = core loop problem, DO NOT scale marketing

- ✅ **D30 Retention: 20%+**
  - **Measurement:** Firebase Analytics 30-day cohort
  - **Benchmark:** 10% industry average

**Performance:**
- ✅ **60 FPS on budget Android** (Snapdragon 660 benchmark device)
  - **Measurement:** Flame performance overlay, real device testing
  - **Acceptance:** 60 FPS sustained with 50 conveyors + 10 buildings + 20 moving resources
  - **Failure Condition:** <45 FPS = performance optimization required before launch

**Stability:**
- ✅ **Crash rate: <1%** (industry standard)
  - **Measurement:** Firebase Crashlytics
  - **Acceptance:** <1% crash-free sessions

- ✅ **Load time: <3 seconds** (cold start)
  - **Measurement:** Firebase Performance Monitoring
  - **Benchmark:** 53% of users abandon if >3s load time

**Player Progression:**
- ✅ **Tier 2 unlock rate: 60%+** (players reaching automation "aha moment")
  - **Measurement:** Firebase Analytics custom event tracking
  - **Critical:** Tier 2 = conveyor unlock = automation value demonstrated
  - **Failure:** <50% = Tier 1 too boring OR too hard, onboarding broken

**Ratings:**
- ✅ **4.0+ star rating** (App Store + Google Play average)
  - **Measurement:** Store dashboards
  - **Target:** 4.2+ optimal, 4.0+ acceptable, <3.8 = critical issues

### Business Metrics

**Revenue Targets (Conservative - 10k downloads, 35% D7):**
- **Year 1 Total: $20-30k** (realistic range)
  - Ad revenue: $18k/year (60% ad watch rate, $20 eCPM, US/EU focus)
  - IAP revenue: $8k/year (2% conversion, $10 ARPPU)
- **LTV Target:** $2-3 (if D7=35%), $10+ (if D7=40%)
- **Break-Even:** 5,000 downloads with 30% D7 = ~$10k revenue (covers $500-1k costs)

**Conversion Metrics:**
- **Conversion Rate: 2%+** (industry standard)
  - **Measurement:** Firebase Analytics purchase events / DAU
  - **Failure:** <1% = pricing issue, value proposition unclear

- **Ad Watch Rate: 60%+** (rewarded video engagement)
  - **Measurement:** Ad impressions / DAU
  - **Target:** 80%+ optimal (2x offline production incentive)

**Cost Metrics:**
- **Firebase Costs: <$50/month** (even at 100k MAU)
  - **Measurement:** Firebase Console billing
  - **Alert:** Set billing alert at $20/month threshold

- **CAC (Cost of Acquisition): $0** (organic only in MVP)
  - Optional: Google Ads test ($100-500 budget post-launch if metrics hit)

### Growth Indicators (Month 2-6)

- **Download Growth: 10-20%/month** (organic word-of-mouth + ASO optimization)
- **D7 Retention Improvement: +5%** (from onboarding iteration based on analytics)
- **Featured Placement:** Google Play or App Store editorial (aspirational accelerator)
- **Community Formation:** Discord server, Reddit presence, YouTube coverage

### Long-Term Success (Year 1)

- **100k downloads** (viral/featured scenario)
- **D7 Retention: 40%+** (top tier, drives $200k+ revenue)
- **Desktop Port Launched** (Month 6-7, cross-platform cloud saves)
- **Active Community:** Discord 1k+ members, r/TradeFactoryMasters subreddit

---

## Product Scope

### MVP - Minimum Viable Product (Tier 1-2 ONLY, 0-7 hours gameplay)

**Ruthless Scope Decision:** Tier 1-2 only (reduces development by 60% vs full Tier 1-4). Prove core loop works FIRST, monetize Tier 3-4 as paid DLC ($2.99) post-launch.

**Core MVP Features (10 Must-Haves):**

1. **3-Step Core Gameplay Loop** (CRITICAL)
2. **Tier 1 Economy System** (0-5h content)
3. **Tier 2 Automation System** (5-7h, conveyor unlock)
4. **Offline Production System** (O(1) calculation)
5. **Mobile-First UX** (one-handed, 60 FPS)
6. **Progression System** (Tier 1 → Tier 2 unlocks)
7. **Discovery-Based Tutorial** (no text, learn by events)
8. **Ethical F2P Monetization** ($10 cap, ads optional)
9. **Firebase Backend** (auth, cloud saves, leaderboards)
10. **Analytics & Metrics Tracking** (D7, session length, crashes)

### Growth Features (Post-MVP Updates)

**Update 1.1 (Month 2) - Polish & Balance:**
- Performance optimizations (based on analytics)
- Balance tweaks (building costs, prices, progression pacing)
- Bug fixes, crash resolution
- QoL improvements (UI feedback, tooltips, settings)

**Update 1.2 (Month 3) - Social Features:**
- Leaderboards expansion (regional, friend-based)
- Basic guilds (join, chat, shared goals)
- Friend codes (invite system)
- Blueprint sharing (export/import factory layouts)

**Update 1.3 (Month 4) - Tier 3 DLC:**
- **Paid DLC: $2.99** unlocks Tier 3 content (15-30h gameplay)
- 8 new buildings, 3 new resources
- Manual optimization mechanics
- Full dynamic economy

### Vision Features (Year 2+)

**Update 2.0 (Month 6) - Desktop Port:**
- Windows/Mac/Linux version (Flutter native cross-platform)
- Cross-platform cloud saves (play on mobile, continue on desktop)
- Mouse + keyboard controls optimized
- Same codebase (85% code reuse)
- Premium pricing option: $9.99 desktop standalone

**Update 2.1 (Month 7) - Competitive Features:**
- Ranked seasons (monthly leaderboards, reset every 30 days)
- Guild competitions (team efficiency challenges)
- Spectator mode (watch top factories in real-time)
- Rewards (cosmetics, titles, badges)

**Year 2+ Vision:**
- **Tier 4 Endgame:** Player market, advanced automation, guild projects
- **Modding Support:** Custom buildings via JSON config files
- **Cross-Platform Multiplayer:** Shared factories (mobile + desktop players together)
- **Educational Partnerships:** Schools, economics courses integration
- **Localization:** 10+ languages (EU: German/French/Spanish, Asia: Chinese/Japanese/Korean)

---

## Functional Requirements

### FR-001: Core Gameplay Loop (CRITICAL - P0)

**Description:** The 3-step core gameplay loop (COLLECT → DECIDE → UPGRADE) is the foundation of Trade Factory Masters. This loop must be satisfying in both 30-second commute sessions AND 60-minute deep dives, proving mobile viability for mid-core factory automation.

**Priority:** P0 (Blocker - nothing works without this)
**Dependencies:** None (foundational feature)
**Estimated Complexity:** High (affects all other systems)

---

#### User Stories

**US-001.1: Resource Collection (COLLECT - 10 seconds)**
```
As a player
I want to tap buildings to collect resources they produce
So that I can gather raw materials and start my factory economy

Acceptance Criteria:
- GIVEN a building is producing resources (Lumbermill with Wood)
  WHEN I tap the building
  THEN resources are added to my inventory
  AND a visual animation shows resources moving from building to inventory
  AND haptic feedback confirms the tap (mobile best practice)
  AND a "+X Wood" text appears briefly above the building

- GIVEN a building has NO resources ready
  WHEN I tap the building
  THEN no resources are collected
  AND a "Empty" or production timer is shown
  AND no haptic feedback occurs (indicates nothing happened)

- GIVEN my inventory is FULL (at capacity limit)
  WHEN I tap a building with resources ready
  THEN collection is blocked
  AND a "Inventory Full!" warning appears
  AND I must sell/use resources before collecting more
```

**US-001.2: Economic Decision Making (DECIDE - 20 seconds)**
```
As a player
I want to buy and sell resources at different prices
So that I can make profit by understanding supply/demand economics

Acceptance Criteria:
- GIVEN I have resources in my inventory (10 Wood)
  WHEN I open the NPC Market interface
  THEN I see current buy/sell prices for all resources
  AND prices are clearly labeled (Sell: 5 gold, Buy: 8 gold per Wood)

- GIVEN current market prices show profit opportunity
  WHEN I sell resources
  THEN gold is added to my wallet
  AND a profit calculation is shown ("+50 gold profit!")
  AND resources are removed from inventory

- GIVEN I see a resource is needed for a building recipe
  WHEN I buy resources from the market
  THEN gold is deducted from wallet
  AND resources are added to inventory
  AND transaction is recorded in game state

- GIVEN prices are FIXED in Tier 1 (no fluctuations)
  WHEN I check prices multiple times
  THEN prices remain constant (e.g., Wood always 5 gold)
  AND this teaches basic economics before complexity increases
```

**US-001.3: Building Upgrades (UPGRADE - 30 seconds)**
```
As a player
I want to upgrade buildings to increase production rates
So that I can optimize my factory and progress faster

Acceptance Criteria:
- GIVEN I have sufficient gold and resources for an upgrade
  WHEN I select a building and tap "Upgrade"
  THEN the building level increases (Level 1 → Level 2)
  AND production rate increases by 20% (e.g., 1 Wood/min → 1.2 Wood/min)
  AND upgrade cost is deducted (gold + resources)
  AND building visual changes slightly (level indicator appears)

- GIVEN a building is at MAX level (Level 5 in Tier 1)
  WHEN I select the building
  THEN "Upgrade" button is disabled/grayed out
  AND "MAX LEVEL" indicator is shown
  AND tooltip suggests unlocking Tier 2 for further upgrades

- GIVEN I don't have enough resources for upgrade
  WHEN I tap "Upgrade"
  THEN upgrade is blocked
  AND missing resources are highlighted in red
  AND tooltip shows "Need: 10 Wood, 5 Ore"
```

**US-001.4: Loop Completion & Feedback (Full Cycle)**
```
As a player
I want to complete the COLLECT → DECIDE → UPGRADE loop quickly
So that I feel productive even in short 30-second sessions

Acceptance Criteria:
- GIVEN I play for 30 seconds
  WHEN I tap lumbermill (COLLECT 10s)
  AND sell wood for profit (DECIDE 10s)
  AND upgrade lumbermill to Level 2 (UPGRADE 10s)
  THEN the full loop completes in ≤30 seconds
  AND I see measurable progress (higher production rate)
  AND positive feedback reinforces loop ("Factory Improved! +20% production")

- GIVEN I play for 60 minutes (long session)
  WHEN I repeat the loop 100+ times
  THEN each loop feels rewarding (progressive unlocks, achievements)
  AND complexity increases naturally (Tier 2 unlocks at ~5h)
  AND session doesn't feel repetitive (events, price changes in Tier 2)
```

---

#### Technical Specifications

**Data Models:**

```dart
// Resource Model
class Resource {
  final String id;           // "wood", "ore", "food", etc.
  final String displayName;  // "Wood", "Ore", "Food"
  final int amount;          // Current inventory count
  final int maxCapacity;     // Inventory limit (e.g., 1000 per resource)
  final String iconPath;     // Asset path for sprite

  Resource({
    required this.id,
    required this.displayName,
    required this.amount,
    required this.maxCapacity,
    required this.iconPath,
  });
}

// Building Model
class Building {
  final String id;                  // "lumbermill_01"
  final BuildingType type;          // BuildingType.lumbermill
  final int level;                  // 1-5 in Tier 1
  final Point<int> gridPosition;    // (x, y) on 50×50 grid
  final ProductionConfig production; // What it produces
  final UpgradeConfig upgradeConfig; // Cost to upgrade

  double get productionRate => production.baseRate * (1 + (level - 1) * 0.2);
  // Level 1: 1.0x, Level 2: 1.2x, Level 3: 1.4x, etc.

  DateTime lastCollected;    // Timestamp for offline production

  Building({
    required this.id,
    required this.type,
    required this.level,
    required this.gridPosition,
    required this.production,
    required this.upgradeConfig,
    required this.lastCollected,
  });
}

// Production Config
class ProductionConfig {
  final Resource outputResource;  // What building produces
  final double baseRate;          // Units per minute (e.g., 1.0 Wood/min)
  final int storageCapacity;      // How much building can hold before full

  ProductionConfig({
    required this.outputResource,
    required this.baseRate,
    required this.storageCapacity,
  });
}

// Upgrade Config
class UpgradeConfig {
  final int goldCost;                    // Base gold cost
  final Map<String, int> resourceCosts;  // Required resources (e.g., {"wood": 10, "ore": 5})
  final int maxLevel;                    // Max level for this tier (5 in Tier 1)

  int calculateCost(int currentLevel) {
    // Linear scaling in Tier 1
    return goldCost * currentLevel;
  }

  UpgradeConfig({
    required this.goldCost,
    required this.resourceCosts,
    required this.maxLevel,
  });
}

// Player Economy State
class PlayerEconomy {
  int gold;                              // Current gold balance
  Map<String, Resource> inventory;       // All resources player owns
  List<Building> buildings;              // All placed buildings

  PlayerEconomy({
    required this.gold,
    required this.inventory,
    required this.buildings,
  });
}
```

**Core Calculations:**

```dart
// Resource collection calculation
int calculateResourcesReady(Building building, DateTime now) {
  final elapsed = now.difference(building.lastCollected);
  final minutesElapsed = elapsed.inSeconds / 60.0;
  final produced = (building.productionRate * minutesElapsed).floor();

  return min(produced, building.production.storageCapacity);
}

// Profit calculation (for UI feedback)
int calculateProfit(String resourceId, int amount, int sellPrice) {
  // In Tier 1, profit is simple: sell price × amount
  return sellPrice * amount;
}

// Upgrade cost scaling (Tier 1 linear)
UpgradeCost calculateUpgradeCost(Building building) {
  final baseCost = building.upgradeConfig.goldCost;
  final currentLevel = building.level;

  return UpgradeCost(
    gold: baseCost * currentLevel,
    resources: building.upgradeConfig.resourceCosts.map(
      (resourceId, baseAmount) => MapEntry(
        resourceId,
        baseAmount * currentLevel, // Linear scaling
      ),
    ),
  );
}
```

**State Management (Riverpod):**

```dart
// Game state provider
@riverpod
class GameState extends _$GameState {
  @override
  PlayerEconomy build() {
    return PlayerEconomy.initial(); // Load from Firestore or create new
  }

  void collectResources(Building building) {
    final now = DateTime.now();
    final resourcesReady = calculateResourcesReady(building, now);

    if (resourcesReady > 0) {
      // Add to inventory
      final resource = building.production.outputResource;
      state = state.copyWith(
        inventory: {
          ...state.inventory,
          resource.id: resource.copyWith(amount: resource.amount + resourcesReady),
        },
      );

      // Update building's lastCollected timestamp
      final updatedBuilding = building.copyWith(lastCollected: now);
      state = state.copyWith(
        buildings: state.buildings.map((b) =>
          b.id == building.id ? updatedBuilding : b
        ).toList(),
      );

      // Trigger haptic feedback & UI animation
      HapticFeedback.lightImpact();
      _showFloatingText("+$resourcesReady ${resource.displayName}");
    }
  }

  void sellResources(String resourceId, int amount) {
    final resource = state.inventory[resourceId]!;
    final price = MarketPrices.getSellPrice(resourceId); // Fixed in Tier 1
    final profit = price * amount;

    state = state.copyWith(
      gold: state.gold + profit,
      inventory: {
        ...state.inventory,
        resourceId: resource.copyWith(amount: resource.amount - amount),
      },
    );

    _showFloatingText("+$profit gold profit!");
  }

  void upgradeBuilding(String buildingId) {
    final building = state.buildings.firstWhere((b) => b.id == buildingId);
    final cost = calculateUpgradeCost(building);

    // Check if player can afford
    if (state.gold >= cost.gold && _hasResources(cost.resources)) {
      // Deduct costs
      state = state.copyWith(
        gold: state.gold - cost.gold,
        inventory: _deductResources(state.inventory, cost.resources),
      );

      // Upgrade building
      final upgraded = building.copyWith(level: building.level + 1);
      state = state.copyWith(
        buildings: state.buildings.map((b) =>
          b.id == buildingId ? upgraded : b
        ).toList(),
      );

      _showFloatingText("Factory Improved! +20% production");

      // Track analytics
      FirebaseAnalytics.logEvent('building_upgraded', {
        'building_type': building.type.name,
        'level': upgraded.level,
      });
    } else {
      _showWarning("Insufficient resources");
    }
  }
}
```

**Grid & Camera System (CRITICAL for conveyor planning):**

```dart
// Grid Camera with dual zoom modes
class GridCamera {
  Point<double> position;          // Camera center (x, y in grid coordinates)
  ZoomMode currentMode;            // Planning vs Build mode
  double zoomLevel;                // Current zoom (0.5x - 2.0x)

  Size viewportSize;               // Screen size in pixels
  Rect gridBounds;                 // 50×50 grid bounds

  // Zoom mode configuration
  static const Map<ZoomMode, CameraConfig> modeConfigs = {
    ZoomMode.planning: CameraConfig(
      zoom: 0.5,                   // See entire 50×50 grid
      description: "Plan conveyors, view whole factory",
      icon: Icons.map,
    ),
    ZoomMode.build: CameraConfig(
      zoom: 1.5,                   // Focus on ~15×15 area
      description: "Tap buildings, collect resources",
      icon: Icons.build,
    ),
  };
}

enum ZoomMode {
  planning,  // 0.5x zoom - entire factory visible
  build,     // 1.5x zoom - interact with buildings
}

// Camera Controls
class CameraController {
  void onSwipe(Offset delta) {
    // Pan camera (any zoom level)
    camera.position += delta / camera.zoomLevel;
    camera.position = camera.position.clamp(gridBounds);
  }

  void onPinchZoom(double scale) {
    // Pinch to zoom (0.5x - 2.0x continuous)
    camera.zoomLevel = (camera.zoomLevel * scale).clamp(0.5, 2.0);
  }

  void toggleZoomMode() {
    // Quick toggle button (UI button or double-tap)
    camera.currentMode = camera.currentMode == ZoomMode.planning
        ? ZoomMode.build
        : ZoomMode.planning;

    // Animate to new zoom level
    animateZoom(
      from: camera.zoomLevel,
      to: modeConfigs[camera.currentMode].zoom,
      duration: Duration(milliseconds: 300),
    );
  }

  void doubleTapRecenter() {
    // Double tap to recenter on factory center
    animateTo(
      position: Point(25, 25), // Center of 50×50 grid
      duration: Duration(milliseconds: 400),
    );
  }
}
```

**Camera UX Specifications:**

**Gesture Controls:**
- **Swipe (1 finger):** Pan camera across grid
  - Works at any zoom level
  - Smooth momentum/inertia on release
  - Bounds: Cannot pan outside 50×50 grid

- **Pinch (2 fingers):** Continuous zoom 0.5x - 2.0x
  - Zoom centered on pinch midpoint
  - Smooth interpolation (no jitter)

- **Double Tap:** Recenter to factory center (25, 25)
  - 400ms smooth animation
  - Helpful when player gets lost in grid

**Zoom Mode Toggle:**
- **UI Button:** Bottom-right corner toggle
  - Icon changes: Map icon (Planning) ↔ Build icon (Build)
  - Shows current mode ("Planning Mode" / "Build Mode")
  - 300ms zoom animation on toggle

**Planning Mode (0.5x zoom):**
- **Purpose:** View entire 50×50 grid, plan conveyor layouts
- **Visible Area:** Full factory (all buildings visible)
- **Interaction:** Limited to viewing + conveyor planning
  - CAN place conveyor START/END points
  - CAN see AI-suggested paths
  - CANNOT tap buildings to collect (too small tap targets)
- **UI Elements:** Minimap hidden (redundant at 0.5x)

**Build Mode (1.5x zoom - DEFAULT):**
- **Purpose:** Tap buildings, collect resources, interact
- **Visible Area:** ~15×15 tiles (enough to see local area)
- **Interaction:** Full gameplay
  - CAN tap buildings to collect
  - CAN upgrade buildings
  - CAN place new buildings
- **UI Elements:** Minimap visible (corner, shows full 50×50 grid)

**Minimap (Build Mode only):**
- **Location:** Top-right corner, 80×80 pixels
- **Shows:** Full 50×50 grid overview
  - Buildings as colored dots
  - Player camera viewport as white rectangle
  - Conveyors as thin lines
- **Tap to Jump:** Tap minimap to pan camera to that location

**Performance Requirements:**
- **Pan/Zoom Performance:** 60 FPS during camera movement
- **Zoom Animation:** 300ms smooth interpolation (Planning ↔ Build toggle)
- **Sprite Batching:** All tiles rendered in single draw call (regardless of zoom)
- **Culling:** Only render visible tiles + 1-tile buffer (performance optimization)

**Acceptance Criteria:**

✅ **Camera Navigation:**
- Player can swipe to pan entire 50×50 grid smoothly (60 FPS)
- Pinch zoom works intuitively (0.5x - 2.0x range)
- Double tap recenters to factory center

✅ **Zoom Mode Toggle:**
- Toggle button clearly indicates current mode
- Transition animates smoothly in 300ms
- Player understands difference (tested with playtesters)

✅ **Planning Mode Use Case:**
- Player can see entire factory to plan conveyor routes
- Conveyor START/END placement works at 0.5x zoom
- AI pathfinding suggestions are visible

✅ **Build Mode Use Case:**
- Buildings are large enough to tap (44×44px minimum)
- Minimap provides overview without zooming out
- All core loop actions (COLLECT/DECIDE/UPGRADE) work smoothly

**Performance Requirements:**

- **Tap Response Time:** <50ms from tap to haptic feedback
- **Collection Animation:** 200-400ms smooth animation (resource → inventory)
- **State Update:** <16ms (maintain 60 FPS during collection/upgrade)
- **UI Feedback:** Floating text appears within 100ms of action
- **Camera Pan:** 60 FPS during swipe gestures
- **Zoom Animation:** 300ms smooth transition (Planning ↔ Build)

**UI/UX Specifications:**

- **Tap Target Size:** Minimum 44×44 pixels (Apple HIG, mobile best practice)
  - **Build Mode (1.5x zoom):** Buildings are 60×60px = easy to tap
  - **Planning Mode (0.5x zoom):** Buildings are 20×20px = too small for tap, conveyor planning only
- **Visual Feedback:**
  - Tappable buildings pulse subtly when resources ready (Build Mode only)
  - Collected resources animate from building to inventory bar
  - Upgrade button glows green when affordable, gray when locked
  - Zoom mode indicator shows current state (Map icon or Build icon)
- **Haptic Feedback:**
  - Light impact on successful tap
  - Medium impact on upgrade completion
  - No haptic on blocked actions (empty building, full inventory)
  - Light haptic on zoom mode toggle

---

#### Acceptance Criteria Summary

**Must Pass Before Launch:**

✅ **Loop Completion Time:**
- 30-second session completes full COLLECT → DECIDE → UPGRADE cycle
- Player sees measurable progress (gold increases, building upgrades)

✅ **Performance:**
- 60 FPS maintained during resource collection (tested with 10 buildings)
- <50ms tap response time on budget Android (Snapdragon 660)

✅ **Economic Learning:**
- Players understand "buy low, sell high" within first 5 minutes
- Profit calculation is visible and clear ("+50 gold profit!")

✅ **Progression Feel:**
- Each upgrade provides noticeable benefit (+20% visible in production)
- Loop doesn't feel repetitive in 60-minute session (tested with playtesters)

**Analytics to Track:**
- Average loop completion time (target: 30-60 seconds)
- Session length distribution (40% <2min, 40% 5-10min, 20% >30min)
- Upgrade frequency (how often players upgrade vs save gold)
- D1 retention (target: 45%+ if loop is engaging)

---

#### Dependencies

**Required Before FR-001:**
- None (this is the foundational feature)

**Required After FR-001:**
- FR-002: Tier 1 Economy System (buildings, resources, market prices)
- FR-005: Mobile-First UX (touch controls, haptics, animations)
- FR-010: Analytics Tracking (measure loop engagement metrics)

---

#### Open Questions

1. **Inventory capacity:** Should be per-resource (1000 Wood, 1000 Ore) or total (1000 total across all resources)?
   - **Recommendation:** Per-resource (simpler UX, less frustrating)

2. **Upgrade cost scaling:** Linear in Tier 1, exponential in Tier 2+?
   - **Recommendation:** Linear Tier 1 (accessible), exponential Tier 2+ (longevity)

3. **Building storage capacity:** Should buildings hold more resources as they level up?
   - **Recommendation:** Yes, +10% per level (incentivizes upgrades for offline players)

---

**Status:** ✅ FR-001 Specification Complete
**Next:** FR-002 Tier 1 Economy System

---

### FR-002: Tier 1 Economy System (HIGH - P1)

**Description:** The Tier 1 Economy System establishes the foundational economic gameplay (0-5 hours content) with 5 building types, 7 resources, and fixed market prices. This tier teaches basic factory automation and supply chain management without overwhelming complexity (no price fluctuations, no automation). Players manually collect resources, learn supply chains, and prepare for Tier 2's automation unlock.

**Priority:** P1 (High - Core content, blocks Tier 2 unlock)
**Dependencies:** FR-001 (Core Gameplay Loop must exist first)
**Estimated Complexity:** High (defines all Tier 1 content balance, progression pacing)

---

#### User Stories

**US-002.1: Building Types & Placement**
```
As a player
I want to build 5 different building types on the grid
So that I can create a diverse factory producing multiple resources

Acceptance Criteria:
- GIVEN I'm in Build Mode
  WHEN I open the "Build Menu"
  THEN I see 5 available building types:
    1. Lumbermill (produces Wood from nothing - basic resource)
    2. Mine (produces Ore from nothing - basic resource)
    3. Farm (produces Food from nothing - basic resource)
    4. Smelter (converts Wood + Ore → Bars - intermediate resource)
    5. Workshop (converts Bars + Ore → Tools - advanced resource)

- GIVEN I select a building to place (e.g., Lumbermill)
  WHEN I tap an empty grid tile
  THEN the building is placed at that location
  AND construction cost is deducted (Gold: 100, Resources: none for Tier 1)
  AND building starts producing immediately
  AND building shows "Level 1" indicator

- GIVEN I try to place a building on occupied tile
  WHEN I tap the tile
  THEN placement is blocked
  AND error message shows "Tile Occupied!"
  AND I must choose a different location

- GIVEN I reach 10 buildings placed (Tier 1 limit)
  WHEN I try to place another building
  THEN placement is blocked
  AND message shows "Max Buildings! Upgrade to Tier 2 to build more"
```

**US-002.2: Resource Production Chains**
```
As a player
I want to understand which buildings produce which resources
So that I can plan supply chains and optimize my factory

Acceptance Criteria:
- GIVEN I have basic resource buildings (Lumbermill/Mine/Farm)
  WHEN they produce resources
  THEN they require NO input (produce from nothing)
  AND production is simple (1 Wood/min, 1 Ore/min, 1 Food/min base rate)

- GIVEN I build a Smelter (intermediate building)
  WHEN it produces Bars
  THEN it requires input resources (1 Wood + 1 Ore → 1 Bar)
  AND I must manually provide input by tapping "Add Resources"
  AND production happens after resources are provided

- GIVEN I build a Workshop (advanced building)
  WHEN it produces Tools
  THEN it requires 2 Bars + 1 Ore → 1 Tool (multi-step chain)
  AND I must have Bars (from Smelter) + Ore (from Mine)
  AND this teaches complex supply chains

Resource Dependency Tree:
- Tier 1 Basic: Wood, Ore, Food (no inputs)
- Tier 1 Intermediate: Bars (Wood + Ore)
- Tier 1 Advanced: Tools (Bars + Ore)
- Tier 2 Unlocks: Circuits (Tools + Ore), Machines (Circuits + Bars)
```

**US-002.3: NPC Market Trading System**
```
As a player
I want to buy and sell resources at the NPC Market
So that I can balance my economy and afford upgrades

Acceptance Criteria:
- GIVEN I open the NPC Market interface
  WHEN I view available trades
  THEN I see all 7 resources with FIXED prices:
    - Wood: Buy 8g, Sell 5g (3g spread)
    - Ore: Buy 10g, Sell 7g (3g spread)
    - Food: Buy 6g, Sell 4g (2g spread)
    - Bars: Buy 20g, Sell 15g (5g spread - intermediate)
    - Tools: Buy 50g, Sell 40g (10g spread - advanced)
    - Circuits: Buy 100g, Sell 80g (Tier 2 resource)
    - Machines: Buy 200g, Sell 150g (Tier 2 resource)

- GIVEN prices are FIXED in Tier 1
  WHEN I check prices at different times
  THEN prices NEVER change
  AND no supply/demand mechanics yet (Tier 2 feature)
  AND this teaches basic trading before complexity

- GIVEN I select a resource to sell (e.g., 10 Wood)
  WHEN I tap "Sell"
  THEN I receive 5g × 10 = 50 gold
  AND Wood inventory decreases by 10
  AND transaction appears in history log

- GIVEN I want to buy resources (e.g., 5 Ore)
  WHEN I tap "Buy"
  THEN I spend 10g × 5 = 50 gold
  AND Ore inventory increases by 5
  AND transaction recorded

- GIVEN I try to sell more than I own
  WHEN I enter amount > inventory
  THEN transaction is blocked
  AND error shows "Insufficient Resources!"

- GIVEN I try to buy without enough gold
  WHEN I tap "Buy"
  THEN transaction is blocked
  AND error shows "Insufficient Gold!"
```

**US-002.4: Supply Chain Management (Manual in Tier 1)**
```
As a player
I want to manage multi-step supply chains manually
So that I learn economic optimization before automation unlocks

Acceptance Criteria:
- GIVEN I want to produce Tools (advanced resource)
  WHEN I plan the supply chain
  THEN I realize I need:
    1. Mine (produces Ore)
    2. Lumbermill (produces Wood)
    3. Smelter (Wood + Ore → Bars)
    4. Workshop (Bars + Ore → Tools)

- GIVEN I have all buildings in chain
  WHEN I produce Tools manually
  THEN I must:
    1. Tap Mine to collect Ore
    2. Tap Lumbermill to collect Wood
    3. Tap Smelter, provide Wood + Ore, wait for Bars
    4. Tap Smelter to collect Bars
    5. Tap Workshop, provide Bars + Ore, wait for Tools
    6. Tap Workshop to collect Tools
  AND this 6-step process is tedious
  AND creates desire for Tier 2 automation (conveyors)

- GIVEN I complete a complex supply chain
  WHEN I sell Tools at market (40g each)
  THEN I earn significant profit
  AND I understand value-add through production chains
  AND I feel rewarded for planning
```

---

#### Technical Specifications

**Building Definitions:**

```dart
enum BuildingType {
  lumbermill,  // Basic: Wood production
  mine,        // Basic: Ore production
  farm,        // Basic: Food production
  smelter,     // Intermediate: Wood + Ore → Bars
  workshop,    // Advanced: Bars + Ore → Tools
}

class BuildingDefinition {
  final BuildingType type;
  final String displayName;
  final String description;
  final ProductionRecipe recipe;
  final BuildingCosts costs;
  final BuildingStats stats;

  BuildingDefinition({
    required this.type,
    required this.displayName,
    required this.description,
    required this.recipe,
    required this.costs,
    required this.stats,
  });
}

// Tier 1 Building Catalog
final Map<BuildingType, BuildingDefinition> tier1Buildings = {
  BuildingType.lumbermill: BuildingDefinition(
    type: BuildingType.lumbermill,
    displayName: "Lumbermill",
    description: "Produces Wood from forest resources",
    recipe: ProductionRecipe(
      inputs: {},  // No inputs (basic resource)
      outputs: {"wood": 1},
      productionTime: Duration(minutes: 1),  // 1 Wood/min
    ),
    costs: BuildingCosts(
      construction: 100,  // 100 gold to build
      upgradeTier1: [100, 150, 200, 250, 300],  // Level 2-6 costs
    ),
    stats: BuildingStats(
      baseProductionRate: 1.0,  // 1 unit/min
      baseStorageCapacity: 10,  // Holds 10 Wood
      gridSize: Size(2, 2),     // 2×2 tiles
    ),
  ),

  BuildingType.mine: BuildingDefinition(
    type: BuildingType.mine,
    displayName: "Mine",
    description: "Extracts Ore from underground deposits",
    recipe: ProductionRecipe(
      inputs: {},  // No inputs
      outputs: {"ore": 1},
      productionTime: Duration(minutes: 1),  // 1 Ore/min
    ),
    costs: BuildingCosts(
      construction: 120,  // Slightly more expensive than Lumbermill
      upgradeTier1: [120, 180, 240, 300, 360],
    ),
    stats: BuildingStats(
      baseProductionRate: 1.0,
      baseStorageCapacity: 10,
      gridSize: Size(2, 2),
    ),
  ),

  BuildingType.farm: BuildingDefinition(
    type: BuildingType.farm,
    displayName: "Farm",
    description: "Grows Food for your workers",
    recipe: ProductionRecipe(
      inputs: {},  // No inputs
      outputs: {"food": 1},
      productionTime: Duration(minutes: 1),  // 1 Food/min
    ),
    costs: BuildingCosts(
      construction: 80,  // Cheapest basic building
      upgradeTier1: [80, 120, 160, 200, 240],
    ),
    stats: BuildingStats(
      baseProductionRate: 1.0,
      baseStorageCapacity: 10,
      gridSize: Size(2, 2),
    ),
  ),

  BuildingType.smelter: BuildingDefinition(
    type: BuildingType.smelter,
    displayName: "Smelter",
    description: "Converts Wood + Ore into Bars",
    recipe: ProductionRecipe(
      inputs: {"wood": 1, "ore": 1},  // Requires 2 inputs
      outputs: {"bars": 1},
      productionTime: Duration(minutes: 2),  // 1 Bar/2min (slower)
    ),
    costs: BuildingCosts(
      construction: 200,  // More expensive (intermediate)
      upgradeTier1: [200, 300, 400, 500, 600],
    ),
    stats: BuildingStats(
      baseProductionRate: 0.5,  // 0.5 Bars/min (slower production)
      baseStorageCapacity: 5,   // Holds 5 Bars
      gridSize: Size(3, 3),     // Larger building (3×3)
    ),
  ),

  BuildingType.workshop: BuildingDefinition(
    type: BuildingType.workshop,
    displayName: "Workshop",
    description: "Crafts Tools from Bars and Ore",
    recipe: ProductionRecipe(
      inputs: {"bars": 2, "ore": 1},  // Complex recipe (3 inputs)
      outputs: {"tools": 1},
      productionTime: Duration(minutes: 3),  // 1 Tool/3min (slowest)
    ),
    costs: BuildingCosts(
      construction: 300,  // Most expensive Tier 1 building
      upgradeTier1: [300, 450, 600, 750, 900],
    ),
    stats: BuildingStats(
      baseProductionRate: 0.33,  // ~0.33 Tools/min
      baseStorageCapacity: 3,    // Holds 3 Tools
      gridSize: Size(3, 3),
    ),
  ),
};
```

**Resource Definitions:**

```dart
enum ResourceType {
  // Tier 1 Basic (no inputs)
  wood,
  ore,
  food,

  // Tier 1 Intermediate (1-2 inputs)
  bars,
  tools,

  // Tier 2 Advanced (unlocks with Tier 2)
  circuits,
  machines,
}

class ResourceDefinition {
  final ResourceType type;
  final String displayName;
  final String iconPath;
  final ResourceTier tier;
  final MarketPrices prices;

  ResourceDefinition({
    required this.type,
    required this.displayName,
    required this.iconPath,
    required this.tier,
    required this.prices,
  });
}

enum ResourceTier {
  basic,         // Wood, Ore, Food (produced from nothing)
  intermediate,  // Bars (1 production step)
  advanced,      // Tools (2 production steps)
}

class MarketPrices {
  final int buyPrice;   // Price to buy from NPC Market
  final int sellPrice;  // Price to sell to NPC Market

  int get spread => buyPrice - sellPrice;  // Profit margin

  MarketPrices({
    required this.buyPrice,
    required this.sellPrice,
  });
}

// Tier 1 Resource Catalog
final Map<ResourceType, ResourceDefinition> tier1Resources = {
  ResourceType.wood: ResourceDefinition(
    type: ResourceType.wood,
    displayName: "Wood",
    iconPath: "assets/resources/wood.png",
    tier: ResourceTier.basic,
    prices: MarketPrices(buyPrice: 8, sellPrice: 5),  // 3g spread
  ),

  ResourceType.ore: ResourceDefinition(
    type: ResourceType.ore,
    displayName: "Ore",
    iconPath: "assets/resources/ore.png",
    tier: ResourceTier.basic,
    prices: MarketPrices(buyPrice: 10, sellPrice: 7),  // 3g spread
  ),

  ResourceType.food: ResourceDefinition(
    type: ResourceType.food,
    displayName: "Food",
    iconPath: "assets/resources/food.png",
    tier: ResourceTier.basic,
    prices: MarketPrices(buyPrice: 6, sellPrice: 4),  // 2g spread
  ),

  ResourceType.bars: ResourceDefinition(
    type: ResourceType.bars,
    displayName: "Bars",
    iconPath: "assets/resources/bars.png",
    tier: ResourceTier.intermediate,
    prices: MarketPrices(buyPrice: 20, sellPrice: 15),  // 5g spread (higher)
  ),

  ResourceType.tools: ResourceDefinition(
    type: ResourceType.tools,
    displayName: "Tools",
    iconPath: "assets/resources/tools.png",
    tier: ResourceTier.advanced,
    prices: MarketPrices(buyPrice: 50, sellPrice: 40),  // 10g spread (highest)
  ),
};
```

**Market Trading System:**

```dart
class NPCMarket {
  // Tier 1: FIXED prices (no fluctuations)
  Map<ResourceType, MarketPrices> getCurrentPrices() {
    // In Tier 1, prices never change
    return tier1Resources.map((type, def) => MapEntry(type, def.prices));
  }

  // Buy resources from market
  TransactionResult buyResource(
    PlayerEconomy player,
    ResourceType resourceType,
    int amount,
  ) {
    final price = tier1Resources[resourceType]!.prices.buyPrice;
    final totalCost = price * amount;

    if (player.gold < totalCost) {
      return TransactionResult.failure("Insufficient Gold! Need $totalCost gold");
    }

    // Deduct gold, add resources
    player.gold -= totalCost;
    player.inventory[resourceType.toString()]!.amount += amount;

    FirebaseAnalytics.logEvent('market_buy', {
      'resource': resourceType.toString(),
      'amount': amount,
      'cost': totalCost,
    });

    return TransactionResult.success("Bought $amount ${resourceType.toString()} for $totalCost gold");
  }

  // Sell resources to market
  TransactionResult sellResource(
    PlayerEconomy player,
    ResourceType resourceType,
    int amount,
  ) {
    final currentAmount = player.inventory[resourceType.toString()]!.amount;

    if (currentAmount < amount) {
      return TransactionResult.failure("Insufficient Resources! Have $currentAmount, need $amount");
    }

    final price = tier1Resources[resourceType]!.prices.sellPrice;
    final totalEarned = price * amount;

    // Add gold, remove resources
    player.gold += totalEarned;
    player.inventory[resourceType.toString()]!.amount -= amount;

    FirebaseAnalytics.logEvent('market_sell', {
      'resource': resourceType.toString(),
      'amount': amount,
      'earned': totalEarned,
    });

    return TransactionResult.success("Sold $amount ${resourceType.toString()} for $totalEarned gold");
  }

  // Calculate profit for selling produced resources
  int calculateProductionProfit(ProductionRecipe recipe) {
    int inputCost = 0;
    recipe.inputs.forEach((resourceId, amount) {
      final resourceType = ResourceType.values.firstWhere((t) => t.toString().endsWith(resourceId));
      inputCost += tier1Resources[resourceType]!.prices.buyPrice * amount;
    });

    int outputValue = 0;
    recipe.outputs.forEach((resourceId, amount) {
      final resourceType = ResourceType.values.firstWhere((t) => t.toString().endsWith(resourceId));
      outputValue += tier1Resources[resourceType]!.prices.sellPrice * amount;
    });

    return outputValue - inputCost;  // Profit per production cycle
  }
}

class TransactionResult {
  final bool success;
  final String message;

  TransactionResult.success(this.message) : success = true;
  TransactionResult.failure(this.message) : success = false;
}
```

**Supply Chain Economics:**

```dart
// Tier 1 Supply Chain Profitability Analysis
class SupplyChainAnalysis {
  // Example: Producing 1 Tool
  static ProductionProfitability analyzeToolProduction() {
    // Inputs needed:
    // - 2 Bars (each Bar needs 1 Wood + 1 Ore)
    // - 1 Ore
    // Total: 2 Wood, 3 Ore

    int costWood = 2 * 8;   // Buy 2 Wood = 16g
    int costOre = 3 * 10;   // Buy 3 Ore = 30g
    int totalCost = costWood + costOre;  // 46g

    int sellTool = 1 * 40;  // Sell 1 Tool = 40g

    int profit = sellTool - totalCost;  // -6g (LOSS if buying inputs!)

    return ProductionProfitability(
      totalInputCost: totalCost,
      totalOutputValue: sellTool,
      netProfit: profit,
      recommendation: profit > 0
          ? "Profitable! Produce and sell."
          : "Loss if buying inputs. Produce your own resources!",
    );
  }

  // Key Learning: Players must PRODUCE basic resources (Wood/Ore/Food)
  // to make profit on advanced items. Buying all inputs = loss!
  static ProductionProfitability analyzeWithOwnProduction() {
    // If player produces own Wood (0 cost) and Ore (0 cost):
    int totalCost = 0;  // All inputs produced, not bought
    int sellTool = 1 * 40;  // Sell 1 Tool = 40g
    int profit = sellTool - totalCost;  // 40g PROFIT!

    return ProductionProfitability(
      totalInputCost: totalCost,
      totalOutputValue: sellTool,
      netProfit: profit,
      recommendation: "Highly profitable! Build Lumbermills and Mines.",
    );
  }
}

class ProductionProfitability {
  final int totalInputCost;
  final int totalOutputValue;
  final int netProfit;
  final String recommendation;

  ProductionProfitability({
    required this.totalInputCost,
    required this.totalOutputValue,
    required this.netProfit,
    required this.recommendation,
  });
}
```

---

#### Performance Requirements

- **Market Interface Load Time:** <200ms to open NPC Market
- **Transaction Processing:** <50ms for buy/sell operations
- **Price Display:** All 7 resource prices visible simultaneously (no scrolling)
- **Building Placement:** <100ms from tap to building placed (visual feedback)
- **Supply Chain Visualization:** Recipe tooltips load in <100ms

---

#### UI/UX Specifications

**Build Menu Interface:**
- **Layout:** Bottom sheet with 5 building cards (horizontal scroll)
- **Building Card Shows:**
  - Building icon (64×64px)
  - Display name ("Lumbermill")
  - Construction cost ("100 gold")
  - Production info ("1 Wood/min")
  - "Build" button (green if affordable, gray if not)
- **Placement Mode:**
  - After selecting building, grid tiles highlight (green = valid, red = occupied)
  - Drag to position, tap to confirm
  - Cancel button visible at top

**NPC Market Interface:**
- **Layout:** Full-screen modal with 2 tabs (BUY | SELL)
- **Resource Row Shows:**
  - Resource icon + name
  - Current inventory amount ("10 Wood")
  - Buy price ("8g") or Sell price ("5g")
  - Amount slider (1-100)
  - "Buy"/"Sell" button
- **Transaction Feedback:**
  - Success: Green flash + "+50 gold" floating text
  - Failure: Red shake + error message toast

**Supply Chain Tooltips:**
- **Tap building → Shows recipe card:**
  - Inputs (left): "1 Wood + 1 Ore"
  - Arrow → Outputs (right): "1 Bar"
  - Production time: "2 minutes"
  - Profitability: "+15g profit if inputs are free"

---

#### Acceptance Criteria Summary

**Must Pass Before Launch:**

✅ **Building Variety:**
- All 5 Tier 1 buildings placeable and functional
- Each building produces correct resources at correct rates

✅ **Supply Chain Functionality:**
- Basic buildings (Lumbermill/Mine/Farm) produce without inputs
- Intermediate buildings (Smelter) require correct inputs
- Advanced buildings (Workshop) handle multi-step chains correctly

✅ **Market Trading:**
- All 7 resources available in NPC Market
- Prices are FIXED (never change in Tier 1)
- Buy/sell transactions process correctly
- Profit/loss calculations visible to player

✅ **Economic Learning:**
- Players understand "produce your own inputs = profit" within 30 minutes
- Supply chain tooltips explain dependencies clearly
- Tier 1 feels rewarding but tedious (motivates Tier 2 automation)

**Analytics to Track:**
- Building placement distribution (which buildings are popular?)
- Resource production rates (are players producing enough?)
- Market transaction frequency (how often buy vs sell?)
- Time to first advanced resource (Tools) produced
- Tier 1 completion time (target: 5 hours to max out Tier 1)

---

#### Dependencies

**Required Before FR-002:**
- ✅ FR-001: Core Gameplay Loop (must have COLLECT/DECIDE/UPGRADE working)

**Required After FR-002:**
- FR-003: Tier 2 Automation System (conveyors unlock, uses Tier 1 economy as base)
- FR-006: Progression System (Tier 1 → Tier 2 unlock requirements)
- FR-007: Discovery-Based Tutorial (teach supply chains through events)

---

#### Open Questions

1. **Building limit in Tier 1:** Should be 10 buildings total, or 10 per building type?
   - **Recommendation:** 10 buildings TOTAL (forces strategic choices, rewards Tier 2 unlock)

2. **Starting resources:** Should players start with 100 gold and 10 of each basic resource, or empty?
   - **Recommendation:** Start with 100 gold, 0 resources (forces engagement with buildings immediately)

3. **Food resource purpose:** Food is produced but has no use in Tier 1 recipes. Should it be required for building operation, or just for selling?
   - **Recommendation:** Just for selling in Tier 1 (simplicity), becomes worker wages in Tier 2

4. **Building placement restrictions:** Should certain buildings require adjacency (e.g., Smelter near Mine)?
   - **Recommendation:** No restrictions in Tier 1 (player freedom), conveyors handle logistics in Tier 2

5. **Grid size for buildings:** All buildings 2×2, or vary by type?
   - **Recommendation:** Basic buildings 2×2, advanced buildings 3×3 (visual importance hierarchy)

---

**Status:** ✅ FR-002 Specification Complete
**Next:** FR-003 Tier 2 Automation System
