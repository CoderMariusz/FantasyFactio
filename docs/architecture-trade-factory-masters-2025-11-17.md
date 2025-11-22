# Trade Factory Masters - System Architecture Document

**Author:** Claude (BMAD Architecture Agent)
**Date:** 2025-11-17
**Version:** 1.0
**Status:** Draft
**Based on:** PRD v1.0, UX Design v1.0

---

## Executive Summary

This Architecture Document defines the **technical foundation** for Trade Factory Masters, a mobile-first factory automation game built with **Flutter/Flame** targeting **60 FPS on budget Android devices** (Snapdragon 660).

**Architecture Goals:**
1. **Performance:** 60 FPS sustained gameplay with 50+ conveyors, 20 buildings
2. **Scalability:** Support 100k MAU on Firebase with <$50/month costs
3. **Maintainability:** Clean architecture, separation of concerns, testable code
4. **Cross-Platform:** 85% code reuse for future desktop port (Month 6-7)
5. **Offline-First:** O(n) offline production calculation, works without network

**Key Decisions:**
- **Framework:** Flutter 3.16+ (Dart 3.2, Material Design 3)
- **Game Engine:** Flame 1.12+ (ECS architecture, sprite batching)
- **State Management:** Riverpod 3.0 (@riverpod code generation)
- **Backend:** Firebase (Auth, Firestore, Analytics, Cloud Functions)
- **Architecture Pattern:** Clean Architecture (Domain, Data, Presentation layers)

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Technology Stack](#2-technology-stack)
3. [Application Architecture](#3-application-architecture)
4. [Data Architecture](#4-data-architecture)
5. [State Management](#5-state-management)
6. [Firebase Integration](#6-firebase-integration)
7. [Game Engine Architecture](#7-game-engine-architecture)
8. [Performance Architecture](#8-performance-architecture)
9. [Offline System](#9-offline-system)
10. [Security Architecture](#10-security-architecture)
11. [Deployment Architecture](#11-deployment-architecture)
12. [Testing Strategy](#12-testing-strategy)

---

## 1. System Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Mobile Application                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │           Presentation Layer (Flutter UI)              │ │
│  │  - Screens (Main Game, Build Menu, Market)             │ │
│  │  - Widgets (Cards, Buttons, Modals)                    │ │
│  │  - Riverpod Providers (ConsumerWidget)                 │ │
│  └────────────────────────────────────────────────────────┘ │
│                          ↕                                   │
│  ┌────────────────────────────────────────────────────────┐ │
│  │          Domain Layer (Business Logic)                 │ │
│  │  - Entities (Building, Resource, ConveyorRoute)        │ │
│  │  - Use Cases (CollectResources, UpgradeBuilding)       │ │
│  │  - Repositories (Abstract Interfaces)                  │ │
│  └────────────────────────────────────────────────────────┘ │
│                          ↕                                   │
│  ┌────────────────────────────────────────────────────────┐ │
│  │            Data Layer (Persistence)                    │ │
│  │  - Repository Implementations (Firestore, Local)       │ │
│  │  - Data Models (JSON serialization)                    │ │
│  │  - Caching (Hive for offline)                          │ │
│  └────────────────────────────────────────────────────────┘ │
│                          ↕                                   │
│  ┌────────────────────────────────────────────────────────┐ │
│  │          Game Engine Layer (Flame)                     │ │
│  │  - Grid Rendering (50×50 tiles)                        │ │
│  │  - Sprite Management (Buildings, Conveyors, Resources) │ │
│  │  - Camera System (GridCamera, zoom modes)              │ │
│  │  - Animation System (Resource flow, effects)           │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────────┐
│                    Firebase Backend                          │
│  - Authentication (Anonymous, Google, Apple Sign-In)         │
│  - Cloud Firestore (Game state, user profiles)              │
│  - Firebase Analytics (Custom events, funnels)              │
│  - Cloud Functions (Leaderboards, daily rewards, events)    │
│  - Crashlytics (Crash reporting, performance monitoring)    │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Component Interaction Flow

**Example: Player Collects Resources**

```
User Tap → Presentation Layer → Domain Layer → Data Layer → Firebase
    ↓
1. User taps building in GameScreen (Presentation)
    ↓
2. Tap handled by TouchController (Flame)
    ↓
3. Calls GameStateNotifier.collectResources() (Riverpod)
    ↓
4. CollectResourcesUseCase.execute() (Domain)
    ↓
5. BuildingRepository.updateLastCollected() (Data)
    ↓
6. Firestore batch update (Firebase - async, don't wait)
    ↓
7. UI updates immediately (optimistic update)
    ↓
8. Haptic feedback + floating text animation (Presentation)
```

**Key Principle:** Optimistic updates for UI (don't wait for Firebase), background sync

---

## 2. Technology Stack

### 2.1 Core Technologies

| Component | Technology | Version | Justification |
|-----------|------------|---------|---------------|
| **Framework** | Flutter | 3.16+ | Cross-platform, 60 FPS capable, Material Design 3 |
| **Language** | Dart | 3.2+ | Type-safe, AOT compilation, async/await built-in |
| **Game Engine** | Flame | 1.12+ | 2D game engine, ECS architecture, Flutter-native |
| **State Management** | Riverpod | 3.0+ | Code generation, compile-time safety, testable |
| **Backend** | Firebase | Latest SDK | Serverless, auto-scaling, $3-45/month at scale |
| **Local Storage** | Hive | 2.2+ | Fast NoSQL, offline-first, 10x faster than SQLite |
| **Serialization** | json_serializable | 6.7+ | Code generation, type-safe JSON |
| **Routing** | go_router | 13.0+ | Declarative routing, deep linking support |

### 2.2 Flutter Packages

**Essential Packages:**
```yaml
dependencies:
  flutter:
    sdk: flutter

  # Game Engine
  flame: ^1.12.0

  # State Management
  flutter_riverpod: ^3.0.0
  riverpod_annotation: ^3.0.0

  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_analytics: ^10.7.0
  firebase_crashlytics: ^3.4.0

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Serialization
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1

  # Utils
  google_sign_in: ^6.1.5
  sign_in_with_apple: ^5.0.0
  google_mobile_ads: ^4.0.0

dev_dependencies:
  # Code Generation
  riverpod_generator: ^3.0.0
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  freezed: ^2.4.6

  # Testing
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.1
  integration_test:
    sdk: flutter
```

### 2.3 Development Tools

- **IDE:** Android Studio / VS Code with Flutter/Dart extensions
- **Version Control:** Git + GitHub
- **CI/CD:** GitHub Actions (build, test, deploy)
- **Analytics Dashboard:** Firebase Console
- **Crash Monitoring:** Firebase Crashlytics
- **Performance Profiling:** Flutter DevTools + Flame FPS overlay

---

## 3. Application Architecture

### 3.1 Clean Architecture Pattern

**Layer Responsibilities:**

```
┌─────────────────────────────────────────────────────────┐
│  Presentation Layer (lib/presentation/)                 │
│  - Screens, Widgets, UI State                           │
│  - Depends on: Domain Layer                             │
│  - No Firebase/Hive imports (use repositories)          │
└─────────────────────────────────────────────────────────┘
                      ↓ Uses ↓
┌─────────────────────────────────────────────────────────┐
│  Domain Layer (lib/domain/)                             │
│  - Entities (pure Dart classes)                         │
│  - Use Cases (business logic)                           │
│  - Repository Interfaces (abstract)                     │
│  - No Flutter/Firebase imports (pure Dart)              │
└─────────────────────────────────────────────────────────┘
                      ↑ Implements ↑
┌─────────────────────────────────────────────────────────┐
│  Data Layer (lib/data/)                                 │
│  - Repository Implementations                           │
│  - Data Models (Firestore ↔ Entity mapping)            │
│  - Data Sources (Firestore, Hive, APIs)                │
│  - Depends on: Domain Layer (implements interfaces)     │
└─────────────────────────────────────────────────────────┘
```

**Dependency Rule:** Dependencies point inward (Presentation → Domain ← Data)

### 3.2 Project Structure

```
lib/
├── main.dart                         # App entry point
├── app.dart                          # MaterialApp configuration
│
├── core/                             # Shared utilities
│   ├── constants/
│   │   ├── colors.dart               # Design system colors
│   │   ├── spacing.dart              # 8-point grid values
│   │   └── typography.dart           # Text styles
│   ├── theme/
│   │   └── app_theme.dart            # ThemeData configuration
│   ├── utils/
│   │   ├── haptic_feedback.dart      # Haptic patterns
│   │   └── logger.dart               # Debug logging
│   └── errors/
│       └── failures.dart             # Error types
│
├── domain/                           # Business Logic (Pure Dart)
│   ├── entities/
│   │   ├── building.dart             # Building entity
│   │   ├── resource.dart             # Resource entity
│   │   ├── conveyor_route.dart       # ConveyorRoute entity
│   │   └── player_economy.dart       # PlayerEconomy aggregate
│   ├── repositories/
│   │   ├── game_repository.dart      # Abstract interface
│   │   └── analytics_repository.dart
│   └── usecases/
│       ├── collect_resources.dart    # CollectResourcesUseCase
│       ├── upgrade_building.dart     # UpgradeBuildingUseCase
│       ├── create_conveyor.dart      # CreateConveyorUseCase
│       └── calculate_offline.dart    # CalculateOfflineProductionUseCase
│
├── data/                             # Data Persistence
│   ├── models/
│   │   ├── building_model.dart       # Firestore model (json_serializable)
│   │   ├── resource_model.dart
│   │   └── player_model.dart
│   ├── repositories/
│   │   ├── game_repository_impl.dart # Implements GameRepository
│   │   └── analytics_repository_impl.dart
│   ├── datasources/
│   │   ├── remote/
│   │   │   ├── firestore_datasource.dart
│   │   │   └── auth_datasource.dart
│   │   └── local/
│   │       └── hive_datasource.dart  # Offline cache
│   └── cache/
│       └── cache_manager.dart        # Cache invalidation logic
│
├── presentation/                     # UI Layer
│   ├── providers/
│   │   ├── game_state_provider.dart  # @riverpod GameState
│   │   ├── market_provider.dart      # @riverpod MarketState
│   │   └── auth_provider.dart        # @riverpod AuthState
│   ├── screens/
│   │   ├── main_game/
│   │   │   ├── main_game_screen.dart
│   │   │   └── widgets/
│   │   │       ├── top_hud.dart
│   │   │       ├── bottom_toolbar.dart
│   │   │       └── minimap.dart
│   │   ├── build_menu/
│   │   │   ├── build_menu_screen.dart
│   │   │   └── widgets/
│   │   │       └── building_card.dart
│   │   ├── market/
│   │   │   ├── market_screen.dart
│   │   │   └── widgets/
│   │   │       └── resource_row.dart
│   │   └── welcome_back/
│   │       └── welcome_back_modal.dart
│   └── widgets/                      # Shared widgets
│       ├── buttons/
│       │   └── primary_button.dart
│       ├── cards/
│       │   └── info_card.dart
│       └── animations/
│           └── floating_text.dart
│
├── game/                             # Flame Game Engine
│   ├── trade_factory_game.dart       # Main FlameGame class
│   ├── components/
│   │   ├── grid/
│   │   │   ├── grid_component.dart   # 50×50 grid rendering
│   │   │   └── grid_tile.dart
│   │   ├── buildings/
│   │   │   ├── building_component.dart
│   │   │   ├── lumbermill_component.dart
│   │   │   └── mine_component.dart
│   │   ├── conveyors/
│   │   │   ├── conveyor_component.dart
│   │   │   └── resource_sprite.dart
│   │   └── camera/
│   │       ├── grid_camera.dart      # GridCamera implementation
│   │       └── camera_controller.dart
│   ├── systems/
│   │   ├── resource_flow_system.dart # Updates resource sprites
│   │   ├── pathfinding_system.dart   # A* algorithm
│   │   └── animation_system.dart
│   └── utils/
│       └── sprite_loader.dart        # Preload sprites
│
└── services/                         # External Services
    ├── firebase/
    │   ├── firebase_service.dart     # Firebase initialization
    │   └── analytics_service.dart
    ├── ads/
    │   └── ad_manager.dart           # Google AdMob integration
    └── performance/
        └── performance_monitor.dart  # FPS tracking
```

**File Count Estimate:** ~120 files for MVP (manageable for solo dev)

---

## 4. Data Architecture

### 4.1 Domain Entities (Pure Dart)

**Building Entity:**
```dart
// lib/domain/entities/building.dart
class Building {
  final String id;
  final BuildingType type;
  final int level;
  final Point<int> gridPosition;
  final ProductionConfig production;
  final UpgradeConfig upgradeConfig;
  final DateTime lastCollected;

  // Computed property (business logic in entity)
  double get productionRate =>
    production.baseRate * (1 + (level - 1) * 0.2);

  Building({
    required this.id,
    required this.type,
    required this.level,
    required this.gridPosition,
    required this.production,
    required this.upgradeConfig,
    required this.lastCollected,
  });

  // copyWith for immutability
  Building copyWith({
    int? level,
    DateTime? lastCollected,
  }) {
    return Building(
      id: id,
      type: type,
      level: level ?? this.level,
      gridPosition: gridPosition,
      production: production,
      upgradeConfig: upgradeConfig,
      lastCollected: lastCollected ?? this.lastCollected,
    );
  }
}
```

**Resource Entity:**
```dart
// lib/domain/entities/resource.dart
class Resource {
  final String id;
  final String displayName;
  final int amount;
  final int maxCapacity;
  final String iconPath;

  Resource({
    required this.id,
    required this.displayName,
    required this.amount,
    required this.maxCapacity,
    required this.iconPath,
  });

  Resource copyWith({int? amount}) {
    return Resource(
      id: id,
      displayName: displayName,
      amount: amount ?? this.amount,
      maxCapacity: maxCapacity,
      iconPath: iconPath,
    );
  }
}
```

### 4.2 Data Models (Firestore Mapping)

**BuildingModel (json_serializable):**
```dart
// lib/data/models/building_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'building_model.g.dart';

@JsonSerializable()
class BuildingModel {
  final String id;
  final String type;  // Stored as string "lumbermill"
  final int level;
  @JsonKey(fromJson: _pointFromJson, toJson: _pointToJson)
  final Point<int> gridPosition;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime lastCollected;

  BuildingModel({
    required this.id,
    required this.type,
    required this.level,
    required this.gridPosition,
    required this.lastCollected,
  });

  // JSON serialization (code generated)
  factory BuildingModel.fromJson(Map<String, dynamic> json) =>
      _$BuildingModelFromJson(json);

  Map<String, dynamic> toJson() => _$BuildingModelToJson(this);

  // Entity conversion
  Building toEntity() {
    return Building(
      id: id,
      type: BuildingType.values.firstWhere((e) => e.name == type),
      level: level,
      gridPosition: gridPosition,
      production: _getProductionConfig(type),
      upgradeConfig: _getUpgradeConfig(type),
      lastCollected: lastCollected,
    );
  }

  factory BuildingModel.fromEntity(Building entity) {
    return BuildingModel(
      id: entity.id,
      type: entity.type.name,
      level: entity.level,
      gridPosition: entity.gridPosition,
      lastCollected: entity.lastCollected,
    );
  }

  // Firestore Timestamp conversion
  static DateTime _timestampFromJson(Timestamp timestamp) =>
      timestamp.toDate();

  static Timestamp _timestampToJson(DateTime dateTime) =>
      Timestamp.fromDate(dateTime);

  static Point<int> _pointFromJson(Map<String, dynamic> json) =>
      Point(json['x'] as int, json['y'] as int);

  static Map<String, dynamic> _pointToJson(Point<int> point) =>
      {'x': point.x, 'y': point.y};
}
```

### 4.3 Firestore Schema

**Collection Structure:**

```
/users/{userId}/
  - profile:
      displayName: string
      createdAt: timestamp
      tier: int (1 or 2)
      totalPlayTime: int (minutes)

  - gameState:
      gold: int
      lastSeen: timestamp
      tier1Complete: bool
      tier2Unlocked: bool

  - inventory/{resourceId}:
      amount: int
      maxCapacity: int

  - buildings/{buildingId}:
      type: string ("lumbermill", "mine", etc.)
      level: int
      gridPosition: {x: int, y: int}
      lastCollected: timestamp

  - conveyors/{conveyorId}:
      startBuildingId: string
      endBuildingId: string
      path: array of {x: int, y: int}
      resourceType: string
      state: string ("active", "paused", "broken")
```

**Why Subcollections:**
- Better query performance (index only what you need)
- Firestore pricing: Charged per document read, not collection size
- Easy to add more data later without migration

**Firestore Read/Write Costs:**
- Profile read: 1 document (at app launch)
- GameState read: 1 document (at app launch)
- Inventory read: 7 documents (Tier 1 resources)
- Buildings read: 10 documents (Tier 1 limit)
- Conveyors read: 0-20 documents (Tier 2)
- **Total reads per session:** ~20 documents = $0.0000006 (60 reads per penny)

---

## 5. State Management

### 5.1 Riverpod Architecture

**Provider Types:**

1. **@riverpod (Code Generated):**
   - Primary state management
   - Compile-time safety
   - Auto-generated .g.dart files

2. **StateNotifier (for complex state):**
   - Game state (PlayerEconomy)
   - Market state (prices, events)
   - Conveyor system state

3. **FutureProvider (for async data):**
   - Firebase data fetching
   - Offline production calculation

**Example: GameStateNotifier:**

```dart
// lib/presentation/providers/game_state_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_state_provider.g.dart';

@riverpod
class GameState extends _$GameState {
  @override
  Future<PlayerEconomy> build() async {
    // Load game state from Firestore
    final repo = ref.read(gameRepositoryProvider);
    return await repo.loadGameState();
  }

  Future<void> collectResources(Building building) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final currentState = state.value!;

      // Business logic (use case)
      final useCase = ref.read(collectResourcesUseCaseProvider);
      final newState = await useCase.execute(
        currentState,
        building,
      );

      // Optimistic update (UI updates immediately)
      return newState;
    });

    // Background sync to Firestore (don't await)
    _syncToFirestore();
  }

  void _syncToFirestore() {
    final repo = ref.read(gameRepositoryProvider);
    repo.saveGameState(state.value!);
    // Firebase write happens in background
  }
}
```

### 5.2 State Flow

```
User Action → Provider Method → Use Case → Repository → Firebase
    ↓                                                        ↓
UI Updates (Optimistic)                          Background Sync
```

**Key Principle:** UI never waits for Firebase (optimistic updates)

---

## 6. Firebase Integration

### 6.1 Firebase Services

**Firebase Initialization:**

```dart
// lib/services/firebase/firebase_service.dart
class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable offline persistence (Firestore)
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Initialize Crashlytics
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(true);

    // Set user properties for Analytics
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  }
}
```

### 6.2 Authentication Flow

```
App Launch
    ↓
Check if user exists (Hive cache)
    ↓
    ├─ YES → Sign in anonymously with cached UID
    │   ↓
    │   Check if account upgraded (Google Sign-In)
    │   ↓
    │   ├─ YES → Use Google auth token
    │   └─ NO → Stay anonymous
    │
    └─ NO → Create new anonymous user
        ↓
        Cache UID in Hive
        ↓
        Create Firestore /users/{uid} document
```

**AuthService Implementation:**

```dart
// lib/data/datasources/remote/auth_datasource.dart
class AuthDataSource {
  final FirebaseAuth _auth;

  Future<User> signInAnonymously() async {
    final userCredential = await _auth.signInAnonymously();
    return userCredential.user!;
  }

  Future<User> upgradeToGoogle() async {
    // Link anonymous account to Google
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final currentUser = _auth.currentUser!;
    final userCredential = await currentUser.linkWithCredential(credential);

    return userCredential.user!;
  }
}
```

### 6.3 Analytics Events

**Custom Events:**

```dart
// lib/services/firebase/analytics_service.dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  void logBuildingPlaced(BuildingType type, int tier) {
    _analytics.logEvent(
      name: 'building_placed',
      parameters: {
        'building_type': type.name,
        'tier': tier,
      },
    );
  }

  void logTier2Unlocked(Duration timeToUnlock) {
    _analytics.logEvent(
      name: 'tier2_unlocked',
      parameters: {
        'time_to_unlock_minutes': timeToUnlock.inMinutes,
      },
    );
  }

  void logOfflineProduction(
    Duration offlineDuration,
    int resourcesProduced,
    bool adWatched,
  ) {
    _analytics.logEvent(
      name: 'offline_production',
      parameters: {
        'offline_duration_minutes': offlineDuration.inMinutes,
        'resources_produced': resourcesProduced,
        'ad_watched': adWatched,
      },
    );
  }
}
```

---

## 7. Game Engine Architecture

### 7.1 Flame Game Class

**TradeFactoryGame:**

```dart
// lib/game/trade_factory_game.dart
class TradeFactoryGame extends FlameGame with HasTappableComponents {
  late GridComponent grid;
  late GridCamera gridCamera;
  late CameraController cameraController;

  @override
  Future<void> onLoad() async {
    // Load sprites
    await SpriteLoader.loadAll();

    // Create 50×50 grid
    grid = GridComponent(size: 50);
    add(grid);

    // Setup camera
    gridCamera = GridCamera(
      viewportSize: size,
      gridBounds: Rect.fromLTWH(0, 0, 50, 50),
    );
    camera = gridCamera;

    // Setup camera controls
    cameraController = CameraController(gridCamera);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update resource flow (conveyors)
    final conveyorSystem = ref.read(conveyorSystemProvider);
    conveyorSystem.updateResourceFlow(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render order (back to front):
    // 1. Grid tiles (lowest)
    // 2. Conveyors
    // 3. Buildings
    // 4. Resource sprites (on conveyors)
    // 5. UI overlays (highest)
  }
}
```

### 7.2 Component Hierarchy

```
FlameGame (TradeFactoryGame)
├─ GridComponent (50×50 tiles)
│  └─ TileComponents (2500 tiles, sprite batched)
├─ BuildingComponents (10-20 buildings)
│  ├─ LumbermillComponent
│  ├─ MineComponent
│  └─ SmelterComponent
├─ ConveyorComponents (0-50 routes)
│  └─ ResourceSpriteComponents (moving resources)
└─ UIComponents (overlays)
   ├─ MinimapComponent
   └─ FloatingTextComponent
```

### 7.3 Camera System

**GridCamera Implementation:**

```dart
// lib/game/components/camera/grid_camera.dart
class GridCamera extends Camera {
  Point<double> position;
  ZoomMode currentMode;
  double zoomLevel;

  final Size viewportSize;
  final Rect gridBounds;

  void animateZoom(double targetZoom, Duration duration) {
    // Tween animation from current zoom to target
    final tween = Tween<double>(begin: zoomLevel, end: targetZoom);
    final animation = tween.animate(
      CurvedAnimation(
        parent: AnimationController(
          duration: duration,
          vsync: this,
        ),
        curve: Curves.easeInOut,
      ),
    );

    animation.addListener(() {
      zoomLevel = animation.value;
      zoom = Vector2.all(zoomLevel);
    });

    animation.controller.forward();
  }

  void panTo(Point<double> target, Duration duration) {
    // Animate camera position
    final start = position;
    final tween = Tween<Point<double>>(begin: start, end: target);
    // ... animation logic
  }
}
```

---

## 8. Performance Architecture

### 8.1 60 FPS Budget

**Frame Budget: 16.67ms**

```
Breakdown per frame:
- Input processing:    2ms  (tap detection, gestures)
- Game logic:          4ms  (resource flow, A* pathfinding)
- Rendering:           8ms  (sprite rendering, animations)
- Flutter UI:          2ms  (HUD, buttons, modals)
- Buffer:              0.67ms (safety margin)
---------------------------------
Total:                 16.67ms
```

### 8.2 Optimization Strategies

**1. Sprite Batching:**
```dart
// Batch render all conveyors in single draw call
class ConveyorBatch {
  final List<ConveyorComponent> conveyors;

  void render(Canvas canvas) {
    // Group by direction (horizontal vs vertical)
    final horizontal = conveyors.where((c) => c.isHorizontal);
    final vertical = conveyors.where((c) => !c.isHorizontal);

    // Single draw call per batch
    canvas.drawAtlas(
      conveyorSpriteSheet,
      horizontal.map((c) => c.transform).toList(),
      horizontal.map((c) => c.sourceRect).toList(),
      null, // colors
      BlendMode.src,
      null, // cullRect
      Paint(),
    );

    // Repeat for vertical
  }
}
```

**2. Spatial Culling:**
```dart
// Only render objects visible in camera viewport
class CullingSystem {
  List<Component> getVisibleComponents(
    List<Component> all,
    Rect viewport,
  ) {
    return all.where((component) {
      final bounds = component.toRect();
      return viewport.overlaps(bounds.inflate(32)); // +1 tile buffer
    }).toList();
  }
}
```

**3. Object Pooling:**
```dart
// Reuse ResourceSprite objects instead of creating new ones
class ResourceSpritePool {
  final List<ResourceSprite> _available = [];
  final List<ResourceSprite> _active = [];

  ResourceSprite acquire(ResourceType type) {
    final sprite = _available.isEmpty
        ? ResourceSprite(type) // Create new if pool empty
        : _available.removeLast(); // Reuse existing

    _active.add(sprite);
    return sprite;
  }

  void release(ResourceSprite sprite) {
    _active.remove(sprite);
    sprite.reset(); // Clear state
    _available.add(sprite);
  }
}
```

**4. Progressive Quality Reduction:**
```dart
// Auto-reduce quality if FPS drops below 45
class PerformanceManager {
  void update(double fps) {
    if (fps < 45) {
      _reduceQuality();
    } else if (fps > 58 && qualityLevel < QualityLevel.high) {
      _increaseQuality();
    }
  }

  void _reduceQuality() {
    // Disable shadows
    RenderSettings.shadowsEnabled = false;

    // Reduce particle count
    ParticleSystem.maxParticles = 10; // Was 20

    // Increase culling margin (render fewer off-screen tiles)
    CullingSystem.margin = 0.5; // Was 1.0
  }
}
```

### 8.3 Memory Management

**Target Memory Usage:**
- App baseline: 80-100 MB
- Game assets loaded: +50 MB (sprites, sounds)
- Runtime state: +20 MB (game state, components)
- **Total:** ~150 MB (safe for budget Android devices with 2GB RAM)

**Memory Optimization:**
- Lazy load sprites (only load visible buildings)
- Compress PNG sprites (use TinyPNG, 50% size reduction)
- Use sprite sheets (1 large image vs 50 small images = less memory overhead)
- Dispose unused components (remove ConveyorComponents when deleted)

---

## 9. Offline System

### 9.1 Offline Production Algorithm

**O(n) where n = building count:**

```dart
// lib/domain/usecases/calculate_offline.dart
class CalculateOfflineProductionUseCase {
  FactoryProductionResult execute(
    List<Building> buildings,
    List<ConveyorRoute> conveyors,
    DateTime lastSeen,
    DateTime now,
  ) {
    final elapsed = now.difference(lastSeen);
    final maxOfflineHours = conveyors.isEmpty ? 12.0 : 24.0;
    final cappedElapsed = min(elapsed.inMinutes / 60.0, maxOfflineHours);

    if (conveyors.isEmpty) {
      // Tier 1: Simple calculation (no dependencies)
      return _calculateSimpleProduction(buildings, cappedElapsed);
    } else {
      // Tier 2: Dependency graph (topological sort)
      return _calculateAutomatedProduction(
        buildings,
        conveyors,
        cappedElapsed,
      );
    }
  }

  FactoryProductionResult _calculateSimpleProduction(
    List<Building> buildings,
    double hours,
  ) {
    final results = <Building, ProductionResult>{};

    for (final building in buildings) {
      final totalProduced =
          (building.productionRate * hours * 60).floor(); // hours → minutes

      final storageCap = building.production.storageCapacity *
                         (1 + (building.level - 1) * 0.10);

      final cappedProduction = min(totalProduced, storageCap.floor());

      results[building] = ProductionResult(
        resource: building.production.outputResource,
        amount: cappedProduction,
        wasCapped: totalProduced > cappedProduction,
      );
    }

    return FactoryProductionResult(
      buildingResults: results,
      offlineDuration: Duration(minutes: (hours * 60).round()),
    );
  }

  FactoryProductionResult _calculateAutomatedProduction(
    List<Building> buildings,
    List<ConveyorRoute> conveyors,
    double hours,
  ) {
    // Build dependency graph
    final graph = _buildDependencyGraph(buildings, conveyors);

    // Topological sort (O(n + e) where e = conveyor count)
    final sortedBuildings = _topologicalSort(graph);

    final results = <Building, ProductionResult>{};
    final resourceBuffer = <String, int>{}; // Simulated conveyor transport

    // Process buildings in dependency order
    for (final building in sortedBuildings) {
      // Check input availability
      var limitingFactor = double.infinity;
      for (final entry in building.production.recipe.inputs.entries) {
        final available = resourceBuffer[entry.key] ?? 0;
        final required = entry.value;
        limitingFactor = min(limitingFactor, available / required);
      }

      // Calculate actual production
      final timeBasedProd = (building.productionRate * hours * 60).floor();
      final actualProd = min(timeBasedProd, limitingFactor.floor());

      // Consume inputs
      for (final entry in building.production.recipe.inputs.entries) {
        resourceBuffer[entry.key] =
            (resourceBuffer[entry.key] ?? 0) - (entry.value * actualProd);
      }

      // Add outputs
      final output = building.production.recipe.outputs.entries.first;
      resourceBuffer[output.key] =
          (resourceBuffer[output.key] ?? 0) + (output.value * actualProd);

      results[building] = ProductionResult(
        resource: building.production.outputResource,
        amount: actualProd,
        wasCapped: actualProd < timeBasedProd,
        limitedBy: limitingFactor.isFinite ? 'inputs' : null,
      );
    }

    return FactoryProductionResult(
      buildingResults: results,
      offlineDuration: Duration(minutes: (hours * 60).round()),
    );
  }
}
```

**Performance:** O(n + e) where n = buildings, e = conveyors
- Tier 1: O(10) = 10 iterations
- Tier 2: O(20 + 50) = 70 iterations
- **< 50ms target easily achieved**

---

## 10. Security Architecture

### 10.1 Firebase Security Rules

**Firestore Rules:**

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Prevent client-side tampering
      match /gameState {
        allow write: if
          // Gold can only increase by reasonable amounts
          request.resource.data.gold <= resource.data.gold + 10000 &&
          // Tier progression is linear (can't skip Tier 1)
          (request.resource.data.tier == resource.data.tier ||
           request.resource.data.tier == resource.data.tier + 1);
      }

      match /buildings/{buildingId} {
        allow write: if
          // Building level can only increase by 1 at a time
          request.resource.data.level <= resource.data.level + 1 &&
          // Level cannot exceed Tier limits
          request.resource.data.level <= 10;
      }
    }

    // Leaderboards (read-only for clients)
    match /leaderboards/{entry} {
      allow read: if request.auth != null;
      allow write: if false; // Only Cloud Functions can write
    }
  }
}
```

### 10.2 Client-Side Validation

**Never trust client:**
- All critical calculations done server-side (Cloud Functions)
- Client sends intent ("upgrade building"), server validates cost
- Firestore Security Rules prevent tampering

**Example: Building Upgrade Validation:**

```dart
// Cloud Function (server-side)
exports.validateBuildingUpgrade = functions.firestore
  .document('users/{userId}/buildings/{buildingId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Validate level increase
    if (after.level !== before.level + 1) {
      throw new Error('Invalid level increase');
    }

    // Check player has enough resources
    const playerState = await admin.firestore()
      .collection('users').doc(context.params.userId)
      .collection('gameState').doc('main').get();

    const cost = calculateUpgradeCost(before.type, before.level);

    if (playerState.data().gold < cost.gold) {
      // Revert upgrade (client cheated)
      await change.after.ref.set(before);
      throw new Error('Insufficient gold');
    }

    // Deduct cost
    await playerState.ref.update({
      gold: admin.firestore.FieldValue.increment(-cost.gold),
    });
  });
```

### 10.3 Anti-Cheat Measures

1. **Server-Side Validation:** All economic transactions validated by Cloud Functions
2. **Rate Limiting:** Max 10 building upgrades per minute (prevent scripts)
3. **Anomaly Detection:** Flag users with impossible progress (10,000 gold in 5 minutes)
4. **Offline Cap:** 12h/24h max offline production (prevent time manipulation)
5. **Firestore Security Rules:** Prevent direct database manipulation

---

## 11. Deployment Architecture

### 11.1 Build Configuration

**Android Build:**
```bash
# Release build with optimizations
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols \
  --target-platform android-arm,android-arm64
```

**iOS Build:**
```bash
# Release build for App Store
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/ios/outputs/symbols
```

**Build Variants:**
- **Debug:** Development, debug logging, Flame FPS overlay
- **Profile:** Performance profiling, no logging
- **Release:** Production, minified, obfuscated

### 11.2 CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/build.yml
name: Build & Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2

      - run: flutter build apk --release

      - uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  deploy-firebase:
    needs: [test, build-android]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3

      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: trade-factory-masters
```

### 11.3 Deployment Targets

**MVP Launch:**
- Google Play Store (Android)
- Apple App Store (iOS)
- Firebase Hosting (web landing page)

**Post-MVP:**
- Desktop (Windows/Mac/Linux) - Month 6-7
- Amazon Appstore (Kindle Fire tablets)

---

## 12. Testing Strategy

### 12.1 Test Pyramid

```
         ┌───────────────┐
        /  E2E Tests (5%) \
       /     - 10 tests    \
      ┌─────────────────────┐
     /  Integration (15%)   \
    /    - 50 tests          \
   ┌───────────────────────────┐
  /   Unit Tests (80%)         \
 /     - 300+ tests             \
└─────────────────────────────────┘
```

**Test Coverage Target:** 80%+ for business logic (Domain layer)

### 12.2 Unit Tests

**Example: CollectResourcesUseCase Test:**

```dart
// test/domain/usecases/collect_resources_test.dart
void main() {
  late CollectResourcesUseCase useCase;
  late MockBuildingRepository mockRepo;

  setUp(() {
    mockRepo = MockBuildingRepository();
    useCase = CollectResourcesUseCase(mockRepo);
  });

  group('CollectResourcesUseCase', () {
    test('should add resources to inventory when building has production', () {
      // Arrange
      final building = Building(
        id: 'lumbermill_1',
        type: BuildingType.lumbermill,
        level: 3,
        lastCollected: DateTime.now().subtract(Duration(minutes: 10)),
        // ... other props
      );

      final initialEconomy = PlayerEconomy(
        gold: 100,
        inventory: {'wood': Resource(id: 'wood', amount: 0)},
        buildings: [building],
      );

      // Act
      final result = useCase.execute(initialEconomy, building);

      // Assert
      expect(result.inventory['wood']!.amount, greaterThan(0));
      expect(result.inventory['wood']!.amount, lessThanOrEqualTo(
        building.production.storageCapacity,
      ));
    });

    test('should not collect if building is empty', () {
      // Arrange
      final building = Building(
        // lastCollected = now (no time elapsed)
        lastCollected: DateTime.now(),
      );

      // Act
      final result = useCase.execute(initialEconomy, building);

      // Assert
      expect(result.inventory['wood']!.amount, equals(0));
    });
  });
}
```

### 12.3 Widget Tests

**Example: PrimaryButton Test:**

```dart
// test/presentation/widgets/buttons/primary_button_test.dart
void main() {
  testWidgets('PrimaryButton calls onPressed when tapped', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Test Button',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    // Find button
    final button = find.text('Test Button');
    expect(button, findsOneWidget);

    // Tap button
    await tester.tap(button);
    await tester.pump();

    // Verify callback
    expect(pressed, isTrue);
  });

  testWidgets('PrimaryButton is disabled when onPressed is null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Disabled',
            onPressed: null,
          ),
        ),
      ),
    );

    final button = find.byType(ElevatedButton);
    final elevatedButton = tester.widget<ElevatedButton>(button);

    expect(elevatedButton.enabled, isFalse);
  });
}
```

### 12.4 Integration Tests

**Example: Full Game Flow Test:**

```dart
// integration_test/game_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete game flow: place building → collect → upgrade', (tester) async {
    await tester.pumpWidget(TradeFactoryApp());

    // Wait for app to load
    await tester.pumpAndSettle();

    // 1. Tap "Build" button
    await tester.tap(find.text('Build'));
    await tester.pumpAndSettle();

    // 2. Select Lumbermill
    await tester.tap(find.text('Lumbermill'));
    await tester.pumpAndSettle();

    // 3. Tap grid to place (center of screen)
    await tester.tapAt(Offset(200, 400));
    await tester.pumpAndSettle();

    // 4. Wait for production (fast-forward time in test)
    await tester.binding.delayed(Duration(seconds: 5));
    await tester.pumpAndSettle();

    // 5. Tap building to collect
    await tester.tapAt(Offset(200, 400));
    await tester.pumpAndSettle();

    // 6. Verify resources collected
    expect(find.text('+5 Wood'), findsOneWidget);

    // 7. Tap "Upgrade" button
    await tester.tap(find.text('Upgrade'));
    await tester.pumpAndSettle();

    // 8. Verify level increased
    expect(find.text('Level 2'), findsOneWidget);
  });
}
```

### 12.5 Performance Tests

**FPS Monitoring:**

```dart
// test/performance/fps_test.dart
void main() {
  test('Game maintains 60 FPS with 50 conveyors', () async {
    final game = TradeFactoryGame();
    await game.onLoad();

    // Add 50 conveyor routes
    for (int i = 0; i < 50; i++) {
      game.add(ConveyorComponent(/* ... */));
    }

    // Measure FPS over 10 seconds
    final fpsReadings = <double>[];
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsedMilliseconds < 10000) {
      final frameStart = DateTime.now();
      game.update(0.016); // 16ms per frame
      game.render(MockCanvas());
      final frameDuration = DateTime.now().difference(frameStart);

      fpsReadings.add(1000 / frameDuration.inMilliseconds);

      await Future.delayed(Duration(milliseconds: 16));
    }

    final averageFPS = fpsReadings.reduce((a, b) => a + b) / fpsReadings.length;

    // Assert 60 FPS ± 5
    expect(averageFPS, greaterThanOrEqualTo(55));
    expect(averageFPS, lessThanOrEqualTo(65));
  });
}
```

---

## 13. Architecture Decision Records (ADRs)

### ADR-001: Why Flutter/Flame instead of Unity?

**Status:** Accepted

**Context:**
- Need 60 FPS on budget Android devices
- Cross-platform (mobile + future desktop)
- Solo developer (easy to learn, fast iteration)

**Decision:** Use Flutter/Flame instead of Unity

**Rationale:**
- Flutter: 85% code reuse for desktop port (validated in Technical Research)
- Flame: Native Flutter integration, no WebGL overhead like Unity WebGL
- Lighter weight: 50MB app vs 200MB Unity build
- Faster iteration: Hot reload vs Unity's slow recompile

**Consequences:**
- Pro: Smaller app size, faster builds, easier debugging
- Con: Less mature game engine, fewer tutorials than Unity

---

### ADR-002: Why Riverpod instead of Bloc?

**Status:** Accepted

**Context:**
- Need state management for complex game state (buildings, resources, conveyors)
- Must support offline-first architecture
- Solo developer prefers less boilerplate

**Decision:** Use Riverpod 3.0 with code generation

**Rationale:**
- Less boilerplate than Bloc (no events/states classes)
- Compile-time safety (@riverpod macro catches errors early)
- Better testability (easier to mock providers)
- Growing community (Riverpod is becoming Flutter standard)

**Consequences:**
- Pro: Faster development, safer refactoring
- Con: Newer library, some breaking changes between versions

---

### ADR-003: Why Firestore instead of REST API?

**Status:** Accepted

**Context:**
- Need cloud saves, user authentication, analytics
- Budget: <$50/month at 100k MAU
- Solo developer (no DevOps time)

**Decision:** Use Firebase (Firestore + Auth + Analytics) instead of custom REST API

**Rationale:**
- Serverless: No server management, auto-scaling
- Cost: $3-45/month validated (vs $50-200/month for EC2)
- Offline persistence: Built-in with Firestore SDK
- Real-time: Future multiplayer features easier to add

**Consequences:**
- Pro: Zero DevOps, cheap at scale, offline-first
- Con: Vendor lock-in to Google, harder to migrate later

---

## 14. Next Steps (Implementation Roadmap)

### Phase 1: Foundation (Week 1-2)
1. ✅ Setup Flutter project
2. ✅ Configure Firebase
3. ✅ Create design system (colors, typography, spacing)
4. ✅ Implement authentication (anonymous + Google)
5. ✅ Setup Riverpod providers structure

### Phase 2: Core Gameplay (Week 3-5)
1. Implement Flame game engine (50×50 grid)
2. Create Building components (Lumbermill, Mine, Farm)
3. Implement tap to collect (Resource collection use case)
4. Build NPC Market (buy/sell UI)
5. Implement building upgrades

### Phase 3: Tier 1 Economy (Week 6-7)
1. Add all 5 Tier 1 buildings
2. Implement supply chains (Smelter, Workshop)
3. Create Build Menu UI
4. Add progression tracking (towards Tier 2)

### Phase 4: Automation (Week 8-10)
1. Implement A* pathfinding for conveyors
2. Create conveyor components
3. Implement resource flow animation (1 tile/sec)
4. Build conveyor placement UI
5. Tier 2 unlock celebration

### Phase 5: Polish & Launch (Week 11-12)
1. Offline production system
2. Welcome Back modal
3. Analytics integration
4. Performance optimization (60 FPS)
5. Beta testing (5-10 users)
6. App Store submission

---

## 15. Architecture Validation Checklist

✅ **Scalability:**
- Firestore can handle 100k MAU ✓
- Flame rendering optimized for 60 FPS ✓
- Offline-first architecture (works without network) ✓

✅ **Maintainability:**
- Clean Architecture (3 layers: Presentation, Domain, Data) ✓
- 80%+ test coverage for business logic ✓
- Code generation (Riverpod, json_serializable) ✓

✅ **Performance:**
- 60 FPS budget (16.67ms per frame) ✓
- Sprite batching, culling, object pooling ✓
- O(n) offline calculation (<50ms for 20 buildings) ✓

✅ **Security:**
- Firestore Security Rules prevent tampering ✓
- Server-side validation (Cloud Functions) ✓
- Anti-cheat measures (rate limiting, anomaly detection) ✓

✅ **Cross-Platform:**
- 85% code reuse for desktop port ✓
- Flutter Web support (future landing page) ✓

---

**End of Architecture Document**

**Status:** ✅ Ready for Implementation
**Next:** Test Design → Sprint Planning → Start Coding
