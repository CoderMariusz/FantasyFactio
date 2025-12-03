# Epic 0: Project Setup - User Stories

<!-- AI-INDEX: epic, stories, project-setup, flutter, firebase, hive, ci-cd -->

**Epic:** EPIC-00 - Project Setup
**Total Stories:** 4
**Total SP:** 13
**Sprint:** 1
**Status:** ✅ Implemented

---

## Story Overview

| Story ID | Title | SP | Priority | Status |
|----------|-------|-----|----------|--------|
| STORY-00.1 | Flutter Project Initialization | 2 | P0 | ✅ Done |
| STORY-00.2 | Firebase Project Configuration | 3 | P0 | ✅ Done |
| STORY-00.3 | CI/CD Pipeline Setup | 3 | P1 | ✅ Done |
| STORY-00.4 | Hive Local Storage Setup | 5 | P1 | ✅ Done |

---

## STORY-00.1: Flutter Project Initialization ✅

### Objective
Zainicjalizować projekt Flutter z Flame game engine.

### User Story
**As a** developer
**I want** to initialize Flutter project with Flame game engine
**So that** I have a working foundation for game development

### Acceptance Criteria

- [x] **AC1:** Flutter 3.16+ project created
```bash
flutter create trade_factory_masters --org com.codermariusz
```

- [x] **AC2:** Flame 1.33+ added to pubspec.yaml

- [x] **AC3:** Riverpod 3.0 configured with code generation

- [x] **AC4:** Project structure created per Architecture doc
```
lib/
├── domain/
├── data/
├── game/
└── presentation/
```

- [x] **AC5:** HelloWorld Flame game renders at 60 FPS

- [x] **AC6:** README.md with setup instructions

### Definition of Done
- [x] Project builds successfully (`flutter build apk`)
- [x] Flame game renders on screen
- [x] CI pipeline runs flutter analyze

**Story Points:** 2 SP
**Status:** ✅ DONE

---

## STORY-00.2: Firebase Project Configuration ✅

### Objective
Skonfigurować Firebase backend services.

### User Story
**As a** developer
**I want** to configure Firebase backend services
**So that** I can implement authentication, cloud save, and analytics

### Acceptance Criteria

- [x] **AC1:** Firebase project created: `trade-factory-masters`

- [x] **AC2:** FlutterFire configured
```bash
flutterfire configure --project=trade-factory-masters
```

- [x] **AC3:** Firebase Auth enabled (Anonymous, Google, Apple)

- [x] **AC4:** Firestore database with security rules

- [x] **AC5:** Firebase Analytics enabled

- [x] **AC6:** Firebase Crashlytics integrated

- [x] **AC7:** Anonymous sign-in works

### Definition of Done
- [x] Firebase console shows project
- [x] Anonymous auth works on emulator
- [x] Firestore write test succeeds

**Story Points:** 3 SP
**Status:** ✅ DONE

---

## STORY-00.3: CI/CD Pipeline Setup ✅

### Objective
Skonfigurować automated testing i deployment pipeline.

### User Story
**As a** developer
**I want** automated testing and deployment pipeline
**So that** I catch bugs early and streamline releases

### Acceptance Criteria

- [x] **AC1:** GitHub Actions workflow created
```yaml
# .github/workflows/ci.yml
name: CI Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
```

- [x] **AC2:** Workflow runs on push to main/develop

- [x] **AC3:** Automated tests: flutter analyze, unit tests, widget tests

- [x] **AC4:** Coverage report generated (80%+ target)

- [x] **AC5:** Build APK on successful test pass

- [x] **AC6:** Pre-commit hook installed

### Definition of Done
- [x] GitHub Actions badge shows "passing"
- [x] Coverage badge visible
- [x] Pre-commit hook blocks failing commits

**Story Points:** 3 SP
**Status:** ✅ DONE

---

## STORY-00.4: Hive Local Storage Setup ✅

### Objective
Skonfigurować Hive local storage dla offline-first architecture.

### User Story
**As a** developer
**I want** Hive local storage configured
**So that** I can implement offline-first architecture

### Acceptance Criteria

- [x] **AC1:** Hive 2.2+ added to pubspec.yaml

- [x] **AC2:** Hive initialized in main.dart
```dart
Future<void> initHive() async {
  await Hive.initFlutter();
  // Register adapters
  await Hive.openBox<PlayerEconomy>('gameState');
}
```

- [x] **AC3:** Type adapters generated for all models
  - Resource, ResourceType
  - Building, BuildingType, GridPosition
  - PlayerEconomy
  - ProductionConfig, UpgradeConfig

- [x] **AC4:** Save/load PlayerEconomy works

- [x] **AC5:** Clear cache functionality implemented

### Definition of Done
- [x] Hive box opens successfully
- [x] Data persists after app restart
- [x] Performance: 10× faster than SQLite

**Story Points:** 5 SP
**Status:** ✅ DONE

---

## Dependencies Graph

```
STORY-00.1 (Flutter Init)
    │
    ├─────────────────┬──────────────────┐
    ▼                 ▼                  ▼
STORY-00.2        STORY-00.3        STORY-00.4
(Firebase)        (CI/CD)           (Hive)
    │                 │                  │
    └─────────────────┴──────────────────┘
                      │
                      ▼
                  EPIC-01
              (Core Gameplay)
```

---

**Total:** 4 stories, 13 SP
**Implemented:** 4/4 working
**Status:** ✅ Complete
**Last Updated:** 2025-12-03
